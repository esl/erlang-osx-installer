//
//  ReleaseDownloadDelegate.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

class ReleaseDownloadDelegate: NSObject, NSURLDownloadDelegate {
    var installationProgress: InstallationProgress
    
    init(installationProgress: InstallationProgress) {
        self.installationProgress = installationProgress
    }
    
    func download(download: NSURLDownload, didReceiveResponse response: NSURLResponse) {
        self.installationProgress.downloading(Double(response.expectedContentLength))
    }
    
    func download(download: NSURLDownload, didReceiveDataOfLength length: Int) {
        self.installationProgress.download(progress: Double(length))
    }
    
    func download(download: NSURLDownload, didFailWithError error: NSError) {
        Utils.alert("\(error)")
    }

    func download(download: NSURLDownload, shouldDecodeSourceDataOfMIMEType encodingType: String) -> Bool {
        // Otherwise the .tar.gz files are decompressed on the fly and the completion
        // precentage doesn't make sense
        return false
    }
    
    func downloadDidFinish(download: NSURLDownload) {
        Utils.alert("downloadDidFinish")
    }
}

public protocol InstallationProgress {
    func start(releaseName: String)
    func downloading(maxValue: Double)
    func download(progress delta: Double)
}