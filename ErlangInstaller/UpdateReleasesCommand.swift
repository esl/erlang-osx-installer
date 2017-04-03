//
//  UpdateReleasesCommand.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

class UpdateReleasesCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "loadReleases"), object: nil)
        return nil
    }
}

class CheckNewReleasesCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "scheduleCheckNewReleases"), object: nil)
        return nil
    }
}
