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
	
    var mainWindow: ErlangInstallerPreferences!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		// Uncomment to delete userdefaults in OSX El Capitan
		// let domainName: String = NSBundle.mainBundle().bundleIdentifier!
		// NSUserDefaults.standardUserDefaults().removePersistentDomainForName(domainName)
		// exit(0)
		
        if(UserDefaults.firstLaunch) {
            Utils.maybeRemovePackageInstallation()
            //UserDefaults.firstLaunch = false // FIXME there are 2 firstLaunch operations
        }

        ReleaseManager.load() {
            self.mainMenu.listenNotifications()
            self.mainMenu.loadReleases()
            self.mainMenu.addStatusItem()
            self.mainMenu.scheduleCheckNewReleases()
        }
        
        let theStoryboard :NSStoryboard? = NSStoryboard(name: "ErlangInstallerPreferences", bundle: nil)
        self.mainWindow = theStoryboard?.instantiateInitialController() as? ErlangInstallerPreferences
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }	
}
