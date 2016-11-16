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
    func downloading(maxValue: Double)
    func download(progress delta: Double)
    func extracting()
    func installing()
    func finished()
    func error(error: NSError)
}

class ReleaseInstaller: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    let release : Release
    let progress: InstallationProgress
    var urlConnection: NSURLConnection?
    var extractTask: NSTask?
    var installTask: NSTask?
    var data: NSMutableData?
    var backgroundQueue = NSOperationQueue()

    var destinationTarGz : NSURL? {
        get { return Utils.supportResourceUrl("release_\(self.release.name).tar.gz") }
    }
    var releaseDir: NSURL? {
        get { return Utils.supportResourceUrl(self.release.name) }
    }
    
    static func install(releaseName: String, progress: InstallationProgress) -> ReleaseInstaller {
        let installer = ReleaseInstaller(releaseName: releaseName, progress: progress)
        installer.run() {
            installer.start()
        }
        return installer
    }
    
    private init(releaseName: String, progress: InstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }

    private func start() {
        self.urlConnection = NSURLConnection(request: NSURLRequest(URL: tarballUrl(release)), delegate: self, startImmediately: false)
        self.urlConnection?.setDelegateQueue(NSOperationQueue())
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
    
    private func extract() {
        self.runInMain() { self.progress.extracting() }

        do
        {
            let fileManager = NSFileManager.defaultManager()
            try fileManager.createDirectoryAtURL(self.releaseDir!, withIntermediateDirectories: true, attributes: nil)
            self.extractTask = NSTask()
            self.extractTask?.launchPath = "/usr/bin/tar"
            self.extractTask?.arguments = ["zxf", self.destinationTarGz!.path!, "-C", self.releaseDir!.path!, "--strip", "1"]
            self.extractTask?.terminationHandler =  { (_: NSTask) -> Void in
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
    
    private func install() {
        self.runInMain() { self.progress.installing() }
        var authRef: AuthorizationRef = nil
        let authFlags = AuthorizationFlags.ExtendRights
        let osStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)
        
        if(osStatus == errAuthorizationSuccess ) {
        
            self.installTask = NSTask()
            self.installTask?.launchPath = self.releaseDir?.URLByAppendingPathComponent("Install")!.path
            self.installTask?.arguments = ["-sasl", (self.releaseDir?.path)!]
            self.installTask?.terminationHandler =  { (_: NSTask) -> Void in
                
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
        
        AuthorizationFree(authRef, AuthorizationFlags.DestroyRights)
    }
    
    private func done() {
        self.runInMain() {
            
            self.progress.finished()
        }

        self.urlConnection = nil
        self.extractTask = nil
        self.data = nil
    }
    
    private func tarballUrl(release: Release) -> NSURL {
        return NSURL(string: release.path, relativeToURL: Constants.BaseTarballsUrl!)!
    }
    
    private func runInMain(block: () -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock(block)
    }
    
    private func run(block: () -> Void) {
        self.backgroundQueue.addOperationWithBlock(block)
    }

    //------------------------------------------
    // NSURLDownloadDelegate protocol
    //------------------------------------------
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.runInMain() {
            self.progress.downloading(Double(response.expectedContentLength))
        }
        self.data = NSMutableData()
    }

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.runInMain() {
            self.progress.download(progress: Double(data.length))
        }
        self.data?.appendData(data)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.runInMain() {
            self.progress.error(error)
        }
    }

    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.runInMain() {
            self.data?.writeToURL(self.destinationTarGz!, atomically: true)
            self.run() {
                self.extract()
            }
        }
    }
}
