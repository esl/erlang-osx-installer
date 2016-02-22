//
//  Constants.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ConstantsLoader {
    static func getUrl(key: String) -> NSURL? {
        let url = NSBundle.mainBundle().objectForInfoDictionaryKey(key) as! String
        return NSURL(string: url)
    }

}

class Constants {
    static let ReleasesListUrl = ConstantsLoader.getUrl("ReleasesUrl")
    static let BaseTarballsUrl = ConstantsLoader.getUrl("BaseTarballUrl")
    static let ReleasesJSONFilename = "available-releases.json"
    static let applicationId = "com.erlang-solutions.ErlangInstaller"
    static let SystemPreferencesId = "com.apple.systempreferences"
    static let ErlangInstallerPreferencesId = "com.erlang-solutions.ErlangInstallerPreferences"
    
    // Package installation
    static let ErlangEslInstallationDir = NSURL(fileURLWithPath: "/usr/local/lib/erlang/")
}