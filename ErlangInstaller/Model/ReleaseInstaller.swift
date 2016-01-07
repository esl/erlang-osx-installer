//
//  ReleaseInstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import PreferencePanes

class ReleaseInstaller: NSObject, NSURLDownloadDelegate {
    let release : Release?
    let progress: InstallationProgress?

    var destinationTarGz : NSURL? {
        get { return Utils.supportResourceUrl("release_\(self.release!.name).tar.gz") }
    }

    init(releaseName: String, progress: InstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }

    func start() {
        let result = Utils.confirm("Do you want to install Erlang release \(self.release!.name)?", additionalInfo: "This might take a while.")
        if(result) {
            let urlDownload = NSURLDownload(request: NSURLRequest(URL: tarballUrl(release!)), delegate: self)
            urlDownload.setDestination(self.destinationTarGz!.path!, allowOverwrite: true)
            self.progress!.start()
        }
    }
    
    func cancel() {
        
    }
    
    private func extract() {
        self.progress!.extracting()
        
        let fileManager = NSFileManager.defaultManager()
        let releaseDir = Utils.supportResourceUrl(self.release!.name)
        try! fileManager.createDirectoryAtPath(releaseDir!.path!, withIntermediateDirectories: true, attributes: nil)
        let task = NSTask()
        task.launchPath = "/usr/bin/tar"
        task.arguments = ["zxf", self.destinationTarGz!.path!, "-C", releaseDir!.path!, "--strip", "1"]
        task.launch()
        task.waitUntilExit()

        try! fileManager.removeItemAtURL(self.destinationTarGz!)
        
        self.done()
    }
    
    private func done() {
        self.progress?.finished()
    }
    
    func uninstall(releaseName: String) {
        let result = Utils.confirm("Do you want to uninstall Erlang release \(releaseName)?")
        if(result) {
            print("Uninstalling \(releaseName)...")
        }
    }
    
    private func tarballUrl(release: Release) -> NSURL {
        let filename = "release_\(release.name).tar.gz"
        return NSURL(string: filename, relativeToURL: Constants.TarballsUrl!)!
    }

    //------------------------------------------
    // NSURLDownloadDelegate protocol
    //------------------------------------------
    
    func download(download: NSURLDownload, didReceiveResponse response: NSURLResponse) {
        self.progress!.downloading(Double(response.expectedContentLength))
    }
    
    func download(download: NSURLDownload, shouldDecodeSourceDataOfMIMEType encodingType: String) -> Bool {
        // Otherwise the .tar.gz files are decompressed on the fly and the 
        // precentage doesn't make sense
        return false
    }
    
    func download(download: NSURLDownload, didReceiveDataOfLength length: Int) {
        self.progress!.download(progress: Double(length))
    }
    
    func download(download: NSURLDownload, didFailWithError error: NSError) {
        self.progress!.error(error)
    }
    
    func downloadDidFinish(download: NSURLDownload) {
        self.extract()
    }
}

public protocol InstallationProgress {
    func start()
    func downloading(maxValue: Double)
    func download(progress delta: Double)
    func extracting()
    func finished()
    func error(error: NSError)
    
}