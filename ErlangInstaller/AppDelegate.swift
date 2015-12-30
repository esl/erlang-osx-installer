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

    var statusItem : NSStatusItem?
    
    @IBOutlet weak var mainMenu: NSMenu!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        addStatusItem()
    }
    
    @IBAction func quitApplication(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func showPreferencesPane(sender: AnyObject) {
        let systemPreferencesApp = SBApplication(bundleIdentifier: "com.apple.systempreferences") as!SystemPreferencesApplication
        var pane = findPreferencePane(systemPreferencesApp)
        
        if (pane == nil) {
            installPreferenecesPane(systemPreferencesApp)
            pane = findPreferencePane(systemPreferencesApp)
        }
        
        systemPreferencesApp.setCurrentPane!(pane)
        systemPreferencesApp.activate()
    }
    
    func findPreferencePane(systemPreferencesApp : SystemPreferencesApplication) -> SystemPreferencesPane? {
        let panes = systemPreferencesApp.panes!() as NSArray as! [SystemPreferencesPane]
        let pane = panes.filter { (pane) -> Bool in
            pane.id!().containsString("com.erlang-solutions.ErlangInstallerPreferences")
        }.first

        return pane
    }

    func installPreferenecesPane(systemPreferencesApp : SystemPreferencesApplication) {
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.menu = self.mainMenu
    }
}