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
			 popover.contentViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)
			self.showPopover(nil)
        }

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
	func showPopover(sender: AnyObject?) {
  if let button = statusItem.button {
	popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
  }
	}
 
	func closePopover(sender: AnyObject?) {
  popover.performClose(sender)
	}
 
	func togglePopover(sender: AnyObject?) {
  if popover.shown {
	closePopover(sender)
} else {
	showPopover(sender)
  }
	}
}