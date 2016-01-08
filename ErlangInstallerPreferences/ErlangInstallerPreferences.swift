//
//  ErlangInstallerPreferences.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/31/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import PreferencePanes

class ErlangInstallerPreferences: NSPreferencePane {

    @IBOutlet var _window: NSWindow!
    
    @IBOutlet weak var localMainView: NSView!
    
    @IBOutlet weak var terminalApp: NSTextField!
    
    override func assignMainView() {
        self.mainView = self.localMainView
    }

    override func mainViewDidLoad() {
        // load current preferences

        terminalApp.stringValue = UserDefaults.getString("terminalApp") ?? "bla"
    }
    
    @IBAction func selectTerminalAppClick(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["app"]
        panel.runModal()
        UserDefaults.terminalApp = panel.URLs.last!.path!
        terminalApp.stringValue = panel.URLs.last!.lastPathComponent!
    }
}

class UserDefaults {
    static let userDefaults = NSUserDefaults.standardUserDefaults()

    static func set(key: String, value: AnyObject?) {
        userDefaults.setValue(value, forKey: key)
    }

    static func getString(key: String) -> String? {
        return userDefaults.stringForKey(key)
    }
    
    static var terminalApp: String? {
        set { UserDefaults.set("terminalApp", value: newValue) }
        get { return UserDefaults.getString("terminalApp") }
    }
}
