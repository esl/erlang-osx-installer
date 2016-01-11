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
    
    @IBOutlet weak var openAtLogin: NSButton!
    @IBOutlet weak var checkForNewReleases: NSButton!
    @IBOutlet weak var checkForUpdates: NSButton!
    @IBOutlet weak var defaultRelease: NSComboBox!
    @IBOutlet weak var appIcon: NSImageView!
    
    override func assignMainView() {
        self.mainView = self.localMainView
    }

    override func mainViewDidLoad() {
        // load current preferences
        self.openAtLogin.state = (UserDefaults.openAtLogin ? 1 : 0)
        self.checkForNewReleases.state = (UserDefaults.checkForNewReleases ? 1 : 0)
        self.checkForUpdates.state = (UserDefaults.checkForUpdates ? 1 : 0)
        self.defaultRelease.addItemsWithObjectValues(ReleaseManager.releases.keys.sort())
        self.appIcon.image = Utils.iconForApp(UserDefaults.terminalApp)
    }
    
    @IBAction func selectTerminalAppClick(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["app"]
        panel.runModal()
        UserDefaults.terminalApp = panel.URLs.last!.path!
        appIcon.image = Utils.iconForApp(UserDefaults.terminalApp)
    }
}
