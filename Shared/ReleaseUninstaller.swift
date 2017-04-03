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
    func error(_ error: NSError)
}

public protocol refreshPreferences {
	func refresh()
}

class ReleaseUninstaller {
    let release: Release
    let progress: UninstallationProgress
	
	 var delegate: refreshPreferences!
	
    init(releaseName: String, progress: UninstallationProgress) {
        self.release = ReleaseManager.releases[releaseName]!
        self.progress = progress
    }
    
    func start() {
        let result = Utils.confirm("Do you want to uninstall Erlang release \(release.name)?")
		if(result) {
            var authRef: AuthorizationRef? = nil
            let authFlags = AuthorizationFlags.extendRights
            let osStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)
            
            if(osStatus == errAuthorizationSuccess) {

                progress.deleting()
                Utils.delete(Utils.supportResourceUrl(release.name)!)
                progress.finished()
                if let lastRelease = ReleaseManager.installed.last as Release? {
                    UserDefaults.defaultRelease = lastRelease.name
                    do {
                        try ReleaseManager.makeSymbolicLinks(lastRelease)
                    }catch let error as NSError {
                        Utils.alert(error.localizedDescription)
                        NSLog("Creating Symbolic links failed: \(error.debugDescription)")
                    }
                    
                }else {
                    UserDefaults.defaultRelease = ""
                }
                self.delegate.refresh()
            }
		}
    }
}
