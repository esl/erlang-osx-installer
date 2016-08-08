//
//  AppDelegate.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/28/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var mainMenu: MainMenu!
	
	let popover = NSPopover()
	
	let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)

	
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if(UserDefaults.firstLaunch) {
            Utils.maybeRemovePackageInstallation()
            UserDefaults.firstLaunch = false
        }
		UserDefaults.firstLaunch = true // FIXME:


        ReleaseManager.load() {
            self.mainMenu.listenNotifications()
            self.mainMenu.loadReleases()
            self.mainMenu.addStatusItem()
            self.mainMenu.scheduleCheckNewReleases()
        }
    }
	
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }	
}