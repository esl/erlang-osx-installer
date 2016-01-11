//
//  UserDefaults.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/11/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class UserDefaults {
    static private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //-------------------
    // Default values
    //-------------------
    
    static private let terminalAppDefault = NSWorkspace.sharedWorkspace().URLForApplicationWithBundleIdentifier("com.apple.Terminal")!.path!
    
    //-------------------
    // Accessors
    //-------------------
    
    static private func set(key: String, value: AnyObject?) {
        userDefaults.setValue(value, forKey: key)
    }
    
    static private func getString(key: String) -> String? {
        return userDefaults.stringForKey(key)
    }
    
    //-------------------
    // Values
    //-------------------
    
    static var terminalApp: String {
        set { set("terminalApp", value: newValue) }
        get { return getString("terminalApp") ?? terminalAppDefault}
    }
}