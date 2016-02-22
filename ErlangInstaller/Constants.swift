//
//  Constants.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class Constants {
    // static let ReleasesListUrl = NSURL(string: "http://packages.erlang-solutions.com/site/erlang/osxupdater/general/compiled/packs.json")
    static let ReleasesListUrl = NSURL(string: "http://localhost:9090/")
    static let BaseTarballsUrl = NSURL(string: "file:///Users/jfacorro/.kerl/")
    static let ReleasesJSONFilename = "available-releases.json"
    static let applicationId = "com.erlang-solutions.ErlangInstaller"
    static let SystemPreferencesId = "com.apple.systempreferences"
    static let ErlangInstallerPreferencesId = "com.erlang-solutions.ErlangInstallerPreferences"
    
    // Package installation
    static let ErlangEslInstallationDir = NSURL(fileURLWithPath: "/usr/local/lib/erlang/")
}