//
//  ReleaseUninstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

public protocol UninstallationProgress {
    func deleting()
    func finished()
    func error(error: NSError)
}

class ReleaseUninstaller {
    let release: Release
    let progress: UninstallationProgress
    
    init(releaseName: String, progress: UninstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }
    
    func start() {
        let result = Utils.confirm("Do you want to uninstall Erlang release \(release.name)?")
        if(result) {
            progress.deleting()
            Utils.delete(Utils.supportResourceUrl(release.name)!)
            progress.finished()
        }
    }
}