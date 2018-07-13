//
//  AppDelegate.swift
//  ErlangSolutions
//
//  Created by Sauron on 12/07/18.
//  Copyright © 2018 Sauron. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // properties
    let popover = NSPopover()
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    var eventMonitor: EventMonitor?
    
    // Application Functions
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // create a button on the menu bar
        if let button = statusItem.button {
            button.image = NSImage(named: "menu-bar-icon")
            button.target = self
        }
        // instantiate a Popover window
        popover.contentViewController = ErlangHelperViewController.freshController()
        
        // when the menu bar button is clicked, it shows a menu
        showMenu()
        
        // the event monitor watches mouse events in order to
        eventMonitor = EventMonitor(mask: [.leftMouseUp, .rightMouseUp]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        Utils.maybeRemovePackageInstallation()
        
        ReleaseManager.load() {
            self.mainMenu.listenNotifications()
            self.mainMenu.loadReleases()
            self.mainMenu.addStatusItem()
            self.mainMenu.scheduleCheckNewReleases()
        }
        
        func applicationWillTerminate(_ aNotification: Notification) {
            // Insert code here to tear down your application
        }
        
// Menu Functions
        
        func togglePopover(sender: Any?) {
            if popover.isShown {
                closePopover(sender: sender)
            } else {
                showPopover(sender: sender)
            }
        }
        
        func showPopover(sender: Any?) {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
            eventMonitor?.start()
        }
        
        func closePopover(sender: Any?) {
            popover.performClose(sender)
            // eventMonitor?.stop()
        }
        
        func showDefaultTerminal(sender: Any?) {
        }
        
        func showTerminalOptions(sender: Any?) {
        }
        
        func downAndInstallRelease(sender: Any?) {
        }
        
        func checkNewReleases(sender: Any?) {
            popover.contentViewController = ErlangHelperViewController.freshController()
            
        }
        
        func checkForUpdates(sender: Any?) {
        }
        
        
        func showMenu() {
            
            let menu = NSMenu()
            
            // menu choices
            menu.addItem(NSMenuItem(title: "Erlang Terminal (Default)", action: #selector(AppDelegate.showDefaultTerminal(sender:)), keyEquivalent: "e"))
            menu.addItem(NSMenuItem(title: "Erlang Terminal", action: #selector(AppDelegate.showTerminalOptions(sender:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Download & Install Release", action: #selector(AppDelegate.downAndInstallRelease(sender:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.togglePopover(sender:)), keyEquivalent: ","))
            menu.addItem(NSMenuItem(title: "Check for New Releases...", action: #selector(AppDelegate.checkNewReleases(sender:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Check for Updates...", action: #selector(AppDelegate.checkForUpdates(sender:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem.menu = menu
        }
        
        
        
}

// LEGACY code




//
//  AppDelegate.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/28/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//
//
//import Cocoa
//
//@NSApplicationMain
//class AppDelegate: NSObject, NSApplicationDelegate {
//
//    @IBOutlet weak var mainMenu: MainMenu!
//
//    var mainWindow: ErlangInstallerPreferences!
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//
//		// Uncomment to delete userdefaults in OSX El Capitan
//		// let domainName: String = NSBundle.mainBundle().bundleIdentifier!
//		// NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domainName)
//		// exit(0)
//
//        Utils.maybeRemovePackageInstallation()
//        ReleaseManager.load() {
//            self.mainMenu.listenNotifications()
//            self.mainMenu.loadReleases()
//            self.mainMenu.addStatusItem()
//            self.mainMenu.scheduleCheckNewReleases()
//        }
//
//        let theStoryboard :NSStoryboard? = NSStoryboard(name: NSStoryboard.Name(rawValue: "ErlangInstallerPreferences"), bundle: nil)
//        self.mainWindow = theStoryboard?.instantiateInitialController() as? ErlangInstallerPreferences
//    }
//    
//    func applicationWillTerminate(_ aNotification: Notification) {
//        // Insert code here to tear down your application
//    }	
//}
