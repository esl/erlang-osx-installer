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
        let pane = findPreferencePane(systemPreferencesApp)
        if (pane != nil) {
            systemPreferencesApp.setCurrentPane!(pane)
        } else {
            
        }
        systemPreferencesApp.activate()
    }
    
    func findPreferencePane(systemPreferencesApp : SystemPreferencesApplication) -> SystemPreferencesPane? {
        let panes = systemPreferencesApp.panes!() as NSArray as! [SystemPreferencesPane]
        let pane = panes.filter { (pane) -> Bool in
            pane.name!.containsString("Erlang Installer")
        }.first
        
        return pane
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

