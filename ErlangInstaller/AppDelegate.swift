//
//  AppDelegate.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/28/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import Cocoa
import ScriptingBridge

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static var delegate: AppDelegate? {
        get {
            return _delegate
        }
    }
    
    private static var _delegate: AppDelegate?
    
    var statusItem : NSStatusItem?

    @IBOutlet weak var mainMenu: NSMenu!
    @IBOutlet weak var erlangTerminalDefault: NSMenuItem!
    @IBOutlet weak var erlangTerminals: NSMenuItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AppDelegate._delegate = self
        loadReleases()
        addStatusItem()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    @IBAction func quitApplication(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func showPreferencesPane(sender: AnyObject) {
        let systemPreferencesApp = SBApplication(bundleIdentifier: Constants.SystemPreferencesId) as! SystemPreferencesApplication
        let pane = findPreferencePane(systemPreferencesApp)
        
        if (pane == nil) {
            installPreferenecesPane()
        } else {
            systemPreferencesApp.setCurrentPane!(pane)
            systemPreferencesApp.activate()
        }
    }

    @IBAction func openTerminalDefault(sender: AnyObject) {
        if(UserDefaults.defaultRelease != nil) {
            let release = ReleaseManager.releases[UserDefaults.defaultRelease!]!
            let erlangTerminal = TerminalApplications.terminals[UserDefaults.terminalApp]
            erlangTerminal?.open(release)
        }
    }

    @IBAction func downloadInstallRelease(sender: AnyObject) {
        showPreferencesPane(sender)
        let systemPreferencesApp = SBApplication(bundleIdentifier: Constants.SystemPreferencesId) as! SystemPreferencesApplication
        let pane = findPreferencePane(systemPreferencesApp)
        let anchors = pane!.anchors!()
        let releasesAnchor = anchors.filter({ $0.name == "releases" }).first
        releasesAnchor?.reveal!()
    }

    func findPreferencePane(systemPreferencesApp: SystemPreferencesApplication) -> SystemPreferencesPane? {
        let panes = systemPreferencesApp.panes!() as NSArray as! [SystemPreferencesPane]
        let pane = panes.filter { (pane) -> Bool in
            pane.id!().containsString(Constants.ErlangInstallerPreferencesId)
        }.first

        return pane
    }

    func installPreferenecesPane() {
        let fileManager = NSFileManager.defaultManager()
        let path = NSBundle.mainBundle().pathForResource("ErlangInstallerPreferences", ofType: "prefPane")
        let destinationUrl = Utils.preferencePanesUrl("ErlangInstallerPreferences.prefPane")
        if(!Utils.fileExists(destinationUrl)) {
            try! fileManager.copyItemAtPath(path!, toPath: destinationUrl!.path!)
        }
        NSWorkspace.sharedWorkspace().openFile(destinationUrl!.path!)
    }

    func loadReleases() {
        self.erlangTerminals.submenu?.removeAllItems()
        for release in ReleaseManager.available {
            let item = NSMenuItem(title: release.name, action: "", keyEquivalent: "")
            self.erlangTerminals.submenu?.addItem(item)
            
            item.enabled = release.installed
            if(release.installed) {
                item.action = "openTerminal:"
                item.target = self
            }
        }

        let enableTerminalDefault = (UserDefaults.defaultRelease != nil) && (ReleaseManager.releases[UserDefaults.defaultRelease!]!.installed)
        self.erlangTerminalDefault.enabled = enableTerminalDefault
    }

    func openTerminal(menuItem: NSMenuItem) {
        let release = ReleaseManager.releases[menuItem.title]!
        let erlangTerminal = TerminalApplications.terminals[UserDefaults.terminalApp]
        erlangTerminal?.open(release)
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.menu = self.mainMenu
    }
}