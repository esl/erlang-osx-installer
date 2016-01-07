//
//  ReleaseInstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

class ReleaseInstaller: NSObject, NSURLDownloadDelegate {
    let release : Release
    let progress: InstallationProgress
    
    init(releaseName: String, progress: InstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }

    func start() {
        let result = Utils.confirm("Do you want to install Erlang release \(self.release.name)?", additionalInfo: "This might take a while.")
        if(result) {
            let destination = Utils.supportResourceUrl("release.tar.gz")
            let urlDownload = NSURLDownload(request: NSURLRequest(URL: tarballUrl(release)), delegate: self)
            urlDownload.setDestination(destination!.path!, allowOverwrite: true)
            self.progress.start()
        }
    }
    
    func cancel() {
        
    }
    
    private func build() {
        
    }
    
    func uninstall(releaseName: String) {
        let result = Utils.confirm("Do you want to uninstall Erlang release \(releaseName)?")
        if(result) {
            print("Uninstalling \(releaseName)...")
        }
    }
    
    private func tarballUrl(release: Release) -> NSURL {
        let filename = "download/otp_src_\(release.name).tar.gz"
        return NSURL(string: filename, relativeToURL: ReleaseManager.DownloadUrl!)!
    }

    //------------------------------------------
    // NSURLDownloadDelegate protocol
    //------------------------------------------
    
    func download(download: NSURLDownload, didReceiveResponse response: NSURLResponse) {
        self.progress.downloading(Double(response.expectedContentLength))
    }
    
    func download(download: NSURLDownload, shouldDecodeSourceDataOfMIMEType encodingType: String) -> Bool {
        // Otherwise the .tar.gz files are decompressed on the fly and the completion
        // precentage doesn't make sense
        return false
    }
    
    func download(download: NSURLDownload, didReceiveDataOfLength length: Int) {
        self.progress.download(progress: Double(length))
    }
    
    func download(download: NSURLDownload, didFailWithError error: NSError) {
        self.progress.error(error)
    }
    
    func downloadDidFinish(download: NSURLDownload) {
        self.build()
        self.progress.downloadFinished()
    }
}

public protocol InstallationProgress {
    func start()
    func downloading(maxValue: Double)
    func download(progress delta: Double)
    func downloadFinished()
    func error(error: NSError)
    
}