//
//  UserDefaults.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/11/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa
import CoreFoundation

class UserDefaults {
    static private let userDefaults = NSUserDefaults.standardUserDefaults()

    //-------------------
    // Default values
    //-------------------
    
    static private let terminalAppDefault = "Terminal" //NSWorkspace.sharedWorkspace().URLForApplicationWithBundleIdentifier("com.apple.Terminal")!.path!
    static private let openAtLoginDefault = false
    static private let checkForNewReleasesDefault = true
    static private let checkForUpdatesDefault = true
    static private var defaultReleaseDefault: String? = nil

    //-------------------
    // Accessors
    //-------------------
    
    static private func set(key: String, value: AnyObject?) {
        CFPreferencesSetAppValue(key, value, Constants.applicationId)
    }
    
    static private func getString(key: String) -> String? {
        return CFPreferencesCopyAppValue(key, Constants.applicationId) as! String?
    }
    
    static private func getBool(key: String) -> Bool? {
        return CFPreferencesCopyAppValue(key, Constants.applicationId) as! Bool?
    }
    
    //-------------------
    // Values
    //-------------------

    static var firstLaunch: Bool {
        set { set("firstLaunch", value: newValue) }
        get { return getBool("firstLaunch") ?? true}
    }
    
    static var terminalApp: String {
        set { set("terminalApp", value: newValue) }
        get { return getString("terminalApp") ?? terminalAppDefault}
    }
    
    static var openAtLogin: Bool {
        set { set("openAtLogin", value: newValue) }
        get { return getBool("openAtLogin") ?? openAtLoginDefault}
    }

    static var checkForNewReleases: Bool {
        set { set("checkForNewReleases", value: newValue) }
        get { return getBool("checkForNewReleases") ?? checkForNewReleasesDefault}
    }
    
    static var checkForUpdates: Bool {
        set { set("checkForUpdates", value: newValue) }
        get { return getBool("checkForUpdates") ?? checkForUpdatesDefault}
    }

    static var defaultRelease: String? {
        set { set("defaultRelease", value: newValue) }
        get { return getString("defaultRelease") ?? defaultReleaseDefault}
    }
}