//
//  ReleaseInstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import PreferencePanes

public protocol InstallationProgress {
    func start()
    func downloading(maxValue: Double)
    func download(progress delta: Double)
    func extracting()
    func finished()
    func error(error: NSError)
}

class ReleaseInstaller: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    let release : Release
    let progress: InstallationProgress
    var urlConnection: NSURLConnection?
    var extractTask: NSTask?
    var data: NSMutableData?

    var destinationTarGz : NSURL? {
        get { return Utils.supportResourceUrl("release_\(self.release.name).tar.gz") }
    }
    var releaseDir: NSURL? {
        get { return Utils.supportResourceUrl(self.release.name) }
    }

    init(releaseName: String, progress: InstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }

    func start() {
        let result = Utils.confirm("Do you want to install Erlang release \(self.release.name)?", additionalInfo: "This might take a while.")
        if(result) {
            self.urlConnection = NSURLConnection(request: NSURLRequest(URL: tarballUrl(release)), delegate: self, startImmediately: false)
            self.urlConnection?.setDelegateQueue(NSOperationQueue())
            self.urlConnection?.start()

            runInMain() { self.progress.start() }
        }
    }
    
    func cancel() {
        self.urlConnection?.cancel()
        self.extractTask?.interrupt()
        Utils.delete(self.destinationTarGz!)
        Utils.delete(self.releaseDir!)
        self.done()
    }
    
    private func extract() {
        runInMain() { self.progress.extracting() }

        runInMain() {
            let fileManager = NSFileManager.defaultManager()
            try! fileManager.createDirectoryAtURL(self.releaseDir!, withIntermediateDirectories: true, attributes: nil)
            self.extractTask = NSTask()
            self.extractTask?.launchPath = "/usr/bin/tar"
            self.extractTask?.arguments = ["zxf", self.destinationTarGz!.path!, "-C", self.releaseDir!.path!, "--strip", "1"]
            self.extractTask?.launch()
            self.extractTask?.waitUntilExit()

            try! fileManager.removeItemAtURL(self.destinationTarGz!)

            self.done()
        }
    }
    
    private func done() {
        runInMain() { self.progress.finished() }
        
        self.urlConnection = nil
        self.extractTask = nil
        self.data = nil
    }
    
    private func tarballUrl(release: Release) -> NSURL {
        let filename = "release_\(release.name).tar.gz"
        return NSURL(string: filename, relativeToURL: Constants.TarballsUrl!)!
    }
    
    private func runInMain(block: () -> Void) {
        NSOperationQueue.mainQueue().addOperationWithBlock(block)
    }

    //------------------------------------------
    // NSURLDownloadDelegate protocol
    //------------------------------------------
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.runInMain() {
            self.progress.downloading(Double(response.expectedContentLength))
            self.data = NSMutableData()
        }
    }

    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.runInMain() {
            self.progress.download(progress: Double(data.length))
            self.data?.appendData(data)
        }
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.runInMain() {
            self.progress.error(error)
        }
    }

    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.runInMain() {
            self.data?.writeToURL(self.destinationTarGz!, atomically: true)
            self.extract()
        }
    }
}