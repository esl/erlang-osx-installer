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
	func closePopoverFromMainMenu(_ sender: AnyObject?)
}

class MainMenu: NSMenu, NSUserNotificationCenterDelegate, PopoverDelegate {

	let popover = NSPopover()
	
	fileprivate var statusItem : NSStatusItem?
    fileprivate var timer : Timer?
    
    @IBOutlet weak var erlangTerminalDefault: NSMenuItem!
    @IBOutlet weak var erlangTerminals: NSMenuItem!
	
    @IBAction func quitApplication(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
	
    @IBAction func showPreferencesPane(_ sender: AnyObject) {
        self.showNewPreferencesPane(selectingTabWithIdentifier: "erlang")
	}
	
	func showPreferencesPaneAndOpenReleasesTab(_ sender: AnyObject) {
		self.showNewPreferencesPane(selectingTabWithIdentifier: "releases")
	}
	
    func showNewPreferencesPane(selectingTabWithIdentifier identifier: String? = nil) {
        
        if let appDelegate = NSApp.delegate as? AppDelegate
        {
            appDelegate.mainWindow.showWindow(self)
            appDelegate.mainWindow.revealElementForKey(identifier!)
        }
    }
    
	func showPopover(_ sender: AnyObject?) {
		if let button = statusItem!.button {
			popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
			if let controller  = popover.contentViewController as? PopoverViewController {
			controller.delegate = self
				_ = Timer.scheduledTimer(timeInterval: 8.0, target: self, selector: #selector(self.closePopover(_:)), userInfo: nil, repeats: false)
			}
  		}
	}
	
	func closePopoverFromMainMenu(_ sender: AnyObject?) {
		self.closePopover(sender)
	}
	
	func closePopover(_ sender: AnyObject?) {
		popover.performClose(sender)
	}
 
	
    @IBAction func checkNewReleases(_ sender: AnyObject) {
        ReleaseManager.checkNewReleases() { (newReleases: [Release]) -> Void in
            for release in newReleases {
                Utils.notifyNewReleases(self, release: release)
            }
            self.loadReleases()
        }
    }
	
    @IBAction func openTerminalDefault(_ sender: AnyObject) {
        if(UserDefaults.defaultRelease != nil) {
            if let release = ReleaseManager.releases[UserDefaults.defaultRelease!]
            {
                let erlangTerminal = TerminalApplications.terminals[UserDefaults.terminalApp]
                erlangTerminal?.open(release)
            }
        }
    }
    
    @IBAction func downloadInstallRelease(_ sender: AnyObject) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(MainMenu.handleLoadReleases(_:)), name: NSNotification.Name(rawValue: "loadReleases"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainMenu.handleScheduleCheckNewReleases(_:)), name: NSNotification.Name(rawValue: "loadReleases"), object: nil)
    }

    func handleLoadReleases(_ notification: Notification) {
        self.loadReleases()
    }
    
    func handleScheduleCheckNewReleases(_ notification: Notification) {
        self.scheduleCheckNewReleases()
    }
    
    func loadReleases() {
        self.erlangTerminals.submenu?.removeAllItems()
        for release in ReleaseManager.available {
            let item = NSMenuItem(title: release.name, action: nil, keyEquivalent: "")
            self.erlangTerminals.submenu?.addItem(item)
            
            item.isEnabled = release.installed
            if(release.installed) {
                item.action = #selector(MainMenu.openTerminal(_:))
                item.target = self
            }
        }
        
		let defaultRelease = UserDefaults.defaultRelease ?? "None"
        
        let release = ReleaseManager.releases[defaultRelease]
    
        let enableTerminalMenuEntries = release?.installed ?? false
        self.erlangTerminalDefault.isEnabled = enableTerminalMenuEntries
		self.erlangTerminals.isEnabled = enableTerminalMenuEntries
    }
    
    func openTerminal(_ menuItem: NSMenuItem) {
        let release = ReleaseManager.releases[menuItem.title]!
        let erlangTerminal = TerminalApplications.terminals[UserDefaults.terminalApp]
        erlangTerminal?.open(release)
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.menu = self
		if (UserDefaults.firstLaunch) {
			popover.contentViewController = PopoverViewController(nibName: "PopoverViewController", bundle: nil)
			_ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.showPopover(_:)), userInfo: nil, repeats: false)
			UserDefaults.firstLaunch = false
		}
    }
    
    func scheduleCheckNewReleases() {
        if(UserDefaults.checkForNewReleases) {
            let now = Date()
            let userCalendar = Calendar.current
            
            let dateUnits = NSCalendar.Unit.year.union(NSCalendar.Unit.month.union(NSCalendar.Unit.day))
            let timeUnits = NSCalendar.Unit.hour.union(NSCalendar.Unit.minute.union(NSCalendar.Unit.second))
            var components = (userCalendar as NSCalendar).components(dateUnits.union(timeUnits), from: now)
            components.hour = 13
            components.minute = 0
            components.second = 0
            
            let interval: Double = 24 * 60 * 60 // 24 hours in seconds
            let fireDate = userCalendar.date(from: components)!
            
            self.timer = Timer(fireAt: fireDate, interval: interval, target: self, selector: #selector(MainMenu.checkNewReleases(_:)), userInfo: nil, repeats: true)
            
            RunLoop.current.add(self.timer!, forMode: RunLoopMode.defaultRunLoopMode)
        } else {
            self.timer?.invalidate()
        }
    }
    
    /*******************************************************************
     ** User Notification Delegate Callbacks
     *******************************************************************/
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if(notification.activationType == NSUserNotification.ActivationType.actionButtonClicked) {
            self.downloadInstallRelease(self)
        }
    }
}
