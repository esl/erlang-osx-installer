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
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func quitApplication(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func showPreferencesPane(sender: AnyObject) {
        let systemPreferencesApp = SBApplication(bundleIdentifier: "com.apple.systempreferences") as!SystemPreferencesApplication
        let pane = findPreferencePane(systemPreferencesApp)
        
        if (pane == nil) {
            installPreferenecesPane(systemPreferencesApp)
        } else {
            systemPreferencesApp.setCurrentPane!(pane)
            systemPreferencesApp.activate()
        }
    }
    
    func findPreferencePane(systemPreferencesApp : SystemPreferencesApplication) -> SystemPreferencesPane? {
        let panes = systemPreferencesApp.panes!() as NSArray as! [SystemPreferencesPane]
        let pane = panes.filter { (pane) -> Bool in
            pane.id!().containsString("com.erlang-solutions.ErlangInstallerPreferences")
        }.first

        return pane
    }

    func installPreferenecesPane(systemPreferencesApp : SystemPreferencesApplication) {
        let path = NSBundle.mainBundle().pathForResource("ErlangInstallerPreferences", ofType: "prefPane")
        NSWorkspace.sharedWorkspace().openFile(path!)
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.menu = self.mainMenu
    }
}