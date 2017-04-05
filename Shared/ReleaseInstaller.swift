//
//  ReleaseInstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import PreferencePanes
import Security
import SecurityFoundation

public protocol InstallationProgress {
    func start()
    func downloading(_ maxValue: Double)
    func download(progress delta: Double)
    func extracting()
    func installing()
    func finished()
    func error(_ error: NSError)
}

class ReleaseInstaller: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    let release : Release
    let progress: InstallationProgress
    var urlConnection: NSURLConnection?
    var extractTask: Process?
    var installTask: Process?
    var data: NSMutableData?
    var backgroundQueue = OperationQueue()

    var delegate: refreshPreferences!
    
    var destinationTarGz : URL? {
        get { return Utils.supportResourceUrl("release_\(self.release.name).tar.gz") }
    }
    var releaseDir: URL? {
        get { return Utils.supportResourceUrl(self.release.name) }
    }
    
    static func install(_ releaseName: String, progress: InstallationProgress) -> ReleaseInstaller {
        let installer = ReleaseInstaller(releaseName: releaseName, progress: progress)
        installer.run() {
            installer.start()
        }
        return installer
    }
    
    fileprivate init(releaseName: String, progress: InstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }

    fileprivate func start() {
        self.urlConnection = NSURLConnection(request: URLRequest(url: tarballUrl(release)), delegate: self, startImmediately: false)
        self.urlConnection?.setDelegateQueue(OperationQueue())
        self.urlConnection?.start()

        runInMain() { self.progress.start() }
    }

    func cancel() {
        self.run() {
            self.urlConnection?.cancel()
            self.extractTask?.interrupt()
            Utils.delete(self.destinationTarGz!)
            Utils.delete(self.releaseDir!)
            self.done()
        }
    }
    
    fileprivate func extract() {
        self.runInMain() { self.progress.extracting() }

        do
        {
            let fileManager = FileManager.default
            try fileManager.createDirectory(at: self.releaseDir!, withIntermediateDirectories: true, attributes: nil)
            self.extractTask = Process()
            self.extractTask?.launchPath = "/usr/bin/tar"
            self.extractTask?.arguments = ["zxf", self.destinationTarGz!.path, "-C", self.releaseDir!.path, "--strip", "1"]
            self.extractTask?.terminationHandler =  { (_: Process) -> Void in
                self.run() {
                    Utils.delete(self.destinationTarGz!)
                    self.install()
                }
            }
            self.extractTask?.launch()
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Couldn't create directory: \(error.debugDescription)")
            self.done()
        }
    }
    
    fileprivate func install() {
        self.runInMain() { self.progress.installing() }
        var authRef: AuthorizationRef? = nil
        let authFlags = AuthorizationFlags.extendRights
        let osStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)
        
        if(osStatus == errAuthorizationSuccess ) {
        
            self.installTask = Process()
            self.installTask?.launchPath = self.releaseDir?.appendingPathComponent("Install").path
            self.installTask?.arguments = ["-sasl", (self.releaseDir?.path)!]
            self.installTask?.terminationHandler =  { (_: Process) -> Void in
                
                self.run() {
                    do{
                        UserDefaults.defaultRelease = self.release.name
                    
                        try ReleaseManager.makeSymbolicLinks(self.release)
                    }
                    catch let error as NSError
                    {
                        Utils.alert(error.localizedDescription)
                        NSLog("Creating Symbolic links failed: \(error.debugDescription)")
                        self.done()

                    }
                    self.done()
                }
            }
            self.installTask?.launch()
        }
        
        AuthorizationFree(authRef!, AuthorizationFlags.destroyRights)
    }
    
    fileprivate func done() {
        self.runInMain() {
            
            self.progress.finished()
            self.delegate.refresh()
        }

        self.urlConnection = nil
        self.extractTask = nil
        self.data = nil
    }
    
    fileprivate func tarballUrl(_ release: Release) -> URL {
        return URL(string: release.path, relativeTo: Constants.BaseTarballsUrl!)!
    }
    
    fileprivate func runInMain(_ block: @escaping () -> Void) {
        OperationQueue.main.addOperation(block)
    }
    
    fileprivate func run(_ block: @escaping () -> Void) {
        self.backgroundQueue.addOperation(block)
    }

    //------------------------------------------
    // NSURLDownloadDelegate protocol
    //------------------------------------------
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.runInMain() {
            self.progress.downloading(Double(response.expectedContentLength))
        }
        self.data = NSMutableData()
    }

    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.runInMain() {
            self.progress.download(progress: Double(data.count))
        }
        self.data?.append(data)
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        self.runInMain() {
            self.progress.error(error as NSError)
        }
    }

    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        self.runInMain() {
            self.data?.write(to: self.destinationTarGz!, atomically: true)
            self.run() {
                self.extract()
            }
        }
    }
}
