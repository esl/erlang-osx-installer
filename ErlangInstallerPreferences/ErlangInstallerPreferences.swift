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
    private var erlangInstallerApp: ErlangInstallerApplication?
    
    @IBOutlet var _window: NSWindow!
    
    @IBOutlet weak var localMainView: NSView!
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var openAtLogin: NSButton!
    @IBOutlet weak var checkForNewReleases: NSButton!
    @IBOutlet weak var checkForUpdates: NSButton!
    @IBOutlet weak var defaultRelease: NSComboBox!
    @IBOutlet weak var terminalApplication: NSComboBox!
    @IBOutlet weak var releasesTableView: NSTableView!

    
    private var queue: dispatch_queue_t?
    private var source: dispatch_source_t?
    
    override func assignMainView() {
        self.mainView = self.localMainView
    }

    override func mainViewDidLoad() {
        self.erlangInstallerApp = SBApplication(bundleIdentifier: Constants.applicationId)
        reloadReleases()
        
        self.checkForFileUpdate()
    }
    
    func checkForFileUpdate()
    {
        let file = open((ReleaseManager.availableReleasesUrl?.path)!, O_EVTONLY)
        if(file > 0)
        {
            self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(file),
                                                DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_DELETE,queue)
            
            dispatch_source_set_event_handler(self.source!) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reloadReleases()
                }
                
                close(file)
            
        }
        
    }
    
    func reloadReleases()
    {
        ReleaseManager.load() {
            self.loadPreferencesValues()
        }
    }

    func loadPreferencesValues() {
        // Load current preferences
        self.openAtLogin.state = (UserDefaults.openAtLogin ? 1 : 0)
        self.checkForNewReleases.state = (UserDefaults.checkForNewReleases ? 1 : 0)
        self.checkForUpdates.state = (UserDefaults.checkForUpdates ? 1 : 0)

        // Check if the default release is currently installed
        self.defaultRelease.removeAllItems()
        self.defaultRelease.addItemsWithObjectValues(ReleaseManager.installed.map({release in return release.name}))
        self.defaultRelease.stringValue = UserDefaults.defaultRelease ?? ""

        self.terminalApplication.removeAllItems()
        self.terminalApplication.addItemsWithObjectValues(TerminalApplications.terminals.keys.sort())
        self.terminalApplication.stringValue = UserDefaults.terminalApp
        
        self.releasesTableView.reloadData()
    }

    func updateReleasesForAgent() {
        self.erlangInstallerApp?.update!()
    }

    func scheduleCheckNewReleasesForAgent() {
        self.erlangInstallerApp?.checkNewReleases!()
    }

    @IBAction func openAtLoginClick(sender: AnyObject) {
        UserDefaults.openAtLogin = self.openAtLogin.state == 1
        let url = NSWorkspace.sharedWorkspace().URLForApplicationWithBundleIdentifier(Constants.applicationId)
        Utils.setLaunchAtLogin(url!, enabled: UserDefaults.openAtLogin)
    }

    @IBAction func checkNewReleasesClick(sender: AnyObject) {
        UserDefaults.checkForNewReleases = self.checkForNewReleases.state == 1
        self.scheduleCheckNewReleasesForAgent()
    }
    
    @IBAction func checkUpdatesClick(sender: AnyObject) {
        UserDefaults.checkForUpdates = self.checkForUpdates.state == 1
    }

    @IBAction func defaultReleaseSelection(sender: AnyObject) {
        UserDefaults.defaultRelease = self.defaultRelease.selectedCell()!.title
        self.updateReleasesForAgent()
    }
    
    @IBAction func terminalAppSelection(sender: AnyObject) {
        UserDefaults.terminalApp = self.terminalApplication.selectedCell()!.title
    }

    func revealElementForKey(key: String) {
        self.tabView.selectTabViewItemWithIdentifier(key)
    }
}
