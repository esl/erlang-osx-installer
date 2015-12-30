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
        checkFirstLaunch()
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
            installPreferenecesPane()
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

    func checkFirstLaunch() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let alreadyBeenLaunched = "AlreadyBeenLaunched"
        if(!userDefaults.boolForKey(alreadyBeenLaunched)) {
            installPreferenecesPane()
            userDefaults.setValue(NSNumber(bool: true), forKey: alreadyBeenLaunched)
        }
    }
    
    func installPreferenecesPane() {
        let result = confirmPreferencesPaneInstallation()
        switch(result) {
        case NSAlertFirstButtonReturn:
            let path = NSBundle.mainBundle().pathForResource("ErlangInstallerPreferences", ofType: "prefPane")
            NSWorkspace.sharedWorkspace().openFile(path!)
        case NSAlertSecondButtonReturn:
            quitApplication(self)
        default:
            break
        }
    }
    
    func confirmPreferencesPaneInstallation() -> NSModalResponse {
        let alert = NSAlert()
        alert.messageText = "Erlang Installer needs to add a pane in your System Preferences so you can manage the application's preferences."
        alert.informativeText = "Do you want to install it now? (If you choose not to the application will quit)"
        alert.addButtonWithTitle("Yes")
        alert.addButtonWithTitle("No")
        return alert.runModal()
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.menu = self.mainMenu
    }
}