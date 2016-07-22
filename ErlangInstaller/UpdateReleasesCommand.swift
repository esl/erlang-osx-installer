//
//  UpdateReleasesCommand.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

class UpdateReleasesCommand: NSScriptCommand {
    override func performDefaultImplementation() -> AnyObject? {
        NSNotificationCenter.defaultCenter().postNotificationName("loadReleases", object: nil)
        return nil
    }
}

class CheckNewReleasesCommand: NSScriptCommand {
    override func performDefaultImplementation() -> AnyObject? { 
        NSNotificationCenter.defaultCenter().postNotificationName("scheduleCheckNewReleases", object: nil)
        return nil
    }
}