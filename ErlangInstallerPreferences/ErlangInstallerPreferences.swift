//
//  ErlangInstallerPreferences.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/31/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import PreferencePanes
import CoreFoundation
import ScriptingBridge

class ErlangInstallerPreferences: NSPreferencePane {

    @IBOutlet var _window: NSWindow!
    
    @IBOutlet weak var localMainView: NSView!
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var openAtLogin: NSButton!
    @IBOutlet weak var checkForNewReleases: NSButton!
    @IBOutlet weak var checkForUpdates: NSButton!
    @IBOutlet weak var defaultRelease: NSComboBox!
    @IBOutlet weak var terminalApplication: NSComboBox!

    override func assignMainView() {
        self.mainView = self.localMainView
    }

    override func mainViewDidLoad() {
        self.loadPreferencesValues()
    }
    
    func loadPreferencesValues() {
        // Load current preferences
        self.openAtLogin.state = (UserDefaults.openAtLogin ? 1 : 0)
        self.checkForNewReleases.state = (UserDefaults.checkForNewReleases ? 1 : 0)
        self.checkForUpdates.state = (UserDefaults.checkForUpdates ? 1 : 0)

        self.defaultRelease.removeAllItems()
        self.defaultRelease.addItemsWithObjectValues(ReleaseManager.installed.map({release in return release.name}))
        if(UserDefaults.defaultRelease != nil) {
            self.defaultRelease.stringValue = UserDefaults.defaultRelease!
        }

        self.terminalApplication.removeAllItems()
        self.terminalApplication.addItemsWithObjectValues(TerminalApplications.terminals.keys.sort())
        self.terminalApplication.stringValue = UserDefaults.terminalApp
    }
    
    func updateReleasesForAgent() {
        let erlangInstallerApp = SBApplication(bundleIdentifier: Constants.SystemPreferencesId) as! ErlangInstallerApplication
        erlangInstallerApp.updateReleases!()
    }
    
    @IBAction func openAtLoginClick(sender: AnyObject) {
        UserDefaults.openAtLogin = self.openAtLogin.state == 1
        let url = NSWorkspace.sharedWorkspace().URLForApplicationWithBundleIdentifier(Constants.applicationId)
        Utils.setLaunchAtLogin(url!, enabled: UserDefaults.openAtLogin)
    }

    @IBAction func checkNewReleasesClick(sender: AnyObject) {
        UserDefaults.checkForNewReleases = self.checkForNewReleases.state == 1
    }
    
    @IBAction func checkUpdatesClick(sender: AnyObject) {
        UserDefaults.checkForUpdates = self.checkForUpdates.state == 1
    }

    @IBAction func defaultReleaseSelection(sender: AnyObject) {
        UserDefaults.defaultRelease = self.defaultRelease.selectedCell()!.title
    }
    
    @IBAction func terminalAppSelection(sender: AnyObject) {
        UserDefaults.terminalApp = self.terminalApplication.selectedCell()!.title
    }

    func revealElementForKey(key: String) {
        self.tabView.selectTabViewItemWithIdentifier(key)
    }
}
