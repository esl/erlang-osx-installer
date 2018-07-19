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
    static fileprivate let userDefaults = Foundation.UserDefaults.standard
    
    //-------------------
    // Default values
    //-------------------
    
    static fileprivate let terminalAppDefault = "Terminal" //NSWorkspace.sharedWorkspace().URLForApplicationWithBundleIdentifier("com.apple.Terminal")!.path!
    static fileprivate let openAtLoginDefault = false
    static fileprivate let checkForNewReleasesDefault = true
    static fileprivate var defaultReleaseDefault: String? = nil
    static fileprivate var defaultReleasePath:String? = NSHomeDirectory() + "/.erlangInstaller/"
    
    //-------------------
    // Accessors
    //-------------------
    
    static fileprivate func set(_ key: String, value: AnyObject?) {
        CFPreferencesSetAppValue(key as CFString, value, Constants.applicationId as CFString)
    }
    
    static fileprivate func getString(_ key: String) -> String? {
        return CFPreferencesCopyAppValue(key as CFString, Constants.applicationId as CFString) as! String?
    }
    
    static fileprivate func getBool(_ key: String) -> Bool? {
        return CFPreferencesCopyAppValue(key as CFString, Constants.applicationId as CFString) as! Bool?
    }
    
    //-------------------
    // Values
    //-------------------
    
    static var firstLaunch: Bool {
        set { set("firstLaunch", value: newValue as AnyObject?) }
        get { return getBool("firstLaunch") ?? true}
    }
    
    static var terminalApp: String {
        set { set("terminalApp", value: newValue as AnyObject?) }
        get { return getString("terminalApp") ?? terminalAppDefault}
    }
    
    static var openAtLogin: Bool {
        set { set("openAtLogin", value: newValue as AnyObject?) }
        get { return getBool("openAtLogin") ?? openAtLoginDefault}
    }
    
    static var checkForNewReleases: Bool {
        set { set("checkForNewReleases", value: newValue as AnyObject?) }
        get { return getBool("checkForNewReleases") ?? checkForNewReleasesDefault}
    }
    
    static var defaultRelease: String? {
        set { set("defaultRelease", value: newValue as AnyObject?) }
        get { return getString("defaultRelease") ?? defaultReleaseDefault}
    }
    static var defaultPath: String? {
        set { set("defaultPath", value: newValue as AnyObject?)}
        get { return getString("defaultPath") ?? defaultReleasePath}
    }
    
    static var dontBotherWithOldReleaseAlert: Bool {
        set { set("dontBotherWithOldReleaseAlert", value: newValue as AnyObject?) }
        get { return getBool("dontBotherWithOldReleaseAlert") ?? false}
    }
}
