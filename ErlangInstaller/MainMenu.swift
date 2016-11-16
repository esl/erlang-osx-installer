//
//  MainMenu.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 2/26/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa
import ScriptingBridge

protocol PopoverDelegate: class {
	func closePopoverFromMainMenu(sender: AnyObject?)
}

class MainMenu: NSMenu, NSUserNotificationCenterDelegate, PopoverDelegate {

	let popover = NSPopover()
	
	private var statusItem : NSStatusItem?
    private var timer : NSTimer?
    
    @IBOutlet weak var erlangTerminalDefault: NSMenuItem!
    @IBOutlet weak var erlangTerminals: NSMenuItem!
	
    @IBAction func quitApplication(sender: AnyObject) {
        NSApp.terminate(self)
    }
	
    @IBAction func showPreferencesPane(sender: AnyObject) {
        self.showNewPreferencesPane(selectingTabWithIdentifier: "erlang")
	}
	
	func showPreferencesPaneAndOpenReleasesTab(sender: AnyObject) {
		self.showNewPreferencesPane(selectingTabWithIdentifier: "releases")
	}
	
    func showNewPreferencesPane(selectingTabWithIdentifier identifier: String? = nil) {
        
        if let appDelegate = NSApp.delegate as? AppDelegate
        {
            appDelegate.mainWindow.showWindow(self)
            appDelegate.mainWindow.revealElementForKey(identifier!)
        }
    }
    
	func showPopover(sender: AnyObject?) {
		if let button = statusItem!.button {
			popover.showRelativeToRect(button.bounds, ofView: button, preferredEdge: NSRectEdge.MinY)
			if let controller  = popover.contentViewController as? PopoverViewController {
			controller.delegate = self
				_ = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: #selector(self.closePopover(_:)), userInfo: nil, repeats: false)
			}
  		}
	}
	
	func closePopoverFromMainMenu(sender: AnyObject?) {
		self.closePopover(sender)
	}
	
	func closePopover(sender: AnyObject?) {
		popover.performClose(sender)
	}
 
	
    @IBAction func checkNewReleases(sender: AnyObject) {
        ReleaseManager.checkNewReleases() { (newReleases: [Release]) -> Void in
            for release in newReleases {
                Utils.notifyNewReleases(self, release: release)
            }
            self.loadReleases()
        }
    }
	
    @IBAction func openTerminalDefault(sender: AnyObject) {
        if(UserDefaults.defaultRelease != nil) {
            if let release = ReleaseManager.releases[UserDefaults.defaultRelease!]
            {
                let erlangTerminal = TerminalApplications.terminals[UserDefaults.terminalApp]
                erlangTerminal?.open(release)
            }
        }
    }
    
    @IBAction func downloadInstallRelease(sender: AnyObject) {
        self.showPreferencesPaneAndOpenReleasesTab(sender)
		
		// FIXME: get releases from the list of available 
//        let systemPreferencesApp = SBApplication(bundleIdentifier: Constants.SystemPreferencesId) as! SystemPreferencesApplication
//        if let pane = findPreferencePane(systemPreferencesApp)
//        {
//            let anchors = pane.anchors!()
//            let releasesAnchor = anchors.filter({ $0.name == "releases" }).first
//            releasesAnchor?.reveal!()
//        }
    }
	
	// FIXME: get releases from the pane
//	func findPreferencePane(systemPreferencesApp: SystemPreferencesApplication) -> SystemPreferencesPane? {
//		let panes = systemPreferencesApp.panes!() as NSArray as! [SystemPreferencesPane]
//		let pane = panes.filter { (pane) -> Bool in
//			pane.id!().containsString(Constants.ErlangInstallerPreferencesId)
//			}.first
//		
//		return pane
//	}
	
    func listenNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenu.handleLoadReleases(_:)), name: "loadReleases", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainMenu.handleScheduleCheckNewReleases(_:)), name: "loadReleases", object: nil)
    }

    func handleLoadReleases(notification: NSNotification) {
        self.loadReleases()
    }
    
    func handleScheduleCheckNewReleases(notification: NSNotification) {
        self.scheduleCheckNewReleases()
    }
    
    func loadReleases() {
        self.erlangTerminals.submenu?.removeAllItems()
        for release in ReleaseManager.available {
            let item = NSMenuItem(title: release.name, action: Selector(""), keyEquivalent: "")
            self.erlangTerminals.submenu?.addItem(item)
            
            item.enabled = release.installed
            if(release.installed) {
                item.action = #selector(MainMenu.openTerminal(_:))
                item.target = self
            }
        }
        
		let defaultRelease = UserDefaults.defaultRelease ?? "None"
        
        let release = ReleaseManager.releases[defaultRelease]
    
        let enableTerminalMenuEntries = release?.installed ?? false
        self.erlangTerminalDefault.enabled = enableTerminalMenuEntries
		self.erlangTerminals.enabled = enableTerminalMenuEntries
    }
    
    func openTerminal(menuItem: NSMenuItem) {
        let release = ReleaseManager.releases[menuItem.title]!
        let erlangTerminal = TerminalApplications.terminals[UserDefaults.terminalApp]
        erlangTerminal?.open(release)
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.menu = self
		if (UserDefaults.firstLaunch) {
			popover.contentViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)
			_ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.showPopover(_:)), userInfo: nil, repeats: false)
			UserDefaults.firstLaunch = false
		}
    }
    
    func scheduleCheckNewReleases() {
        if(UserDefaults.checkForNewReleases) {
            let now = NSDate()
            let userCalendar = NSCalendar.currentCalendar()
            
            let dateUnits = NSCalendarUnit.Year.union(NSCalendarUnit.Month.union(NSCalendarUnit.Day))
            let timeUnits = NSCalendarUnit.Hour.union(NSCalendarUnit.Minute.union(NSCalendarUnit.Second))
            let components = userCalendar.components(dateUnits.union(timeUnits), fromDate: now)
            components.hour = 13
            components.minute = 0
            components.second = 0
            
            let interval: Double = 24 * 60 * 60 // 24 hours in seconds
            let fireDate = userCalendar.dateFromComponents(components)!
            
            self.timer = NSTimer(fireDate: fireDate, interval: interval, target: self, selector: #selector(MainMenu.checkNewReleases(_:)), userInfo: nil, repeats: true)
            
            NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSDefaultRunLoopMode)
        } else {
            self.timer?.invalidate()
        }
    }
    
    /*******************************************************************
     ** User Notification Delegate Callbacks
     *******************************************************************/
    
    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        if(notification.activationType == NSUserNotificationActivationType.ActionButtonClicked) {
            self.downloadInstallRelease(self)
        }
    }
}
