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
    static var delegate: AppDelegate? {
        get {
            return _delegate
        }
    }
    
    private static var _delegate: AppDelegate?    

    @IBOutlet weak var mainMenu: MainMenu!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        AppDelegate._delegate = self

        if(UserDefaults.firstLaunch) {
            Utils.maybeRemovePackageInstallation()
            UserDefaults.firstLaunch = false
        }

        ReleaseManager.load() {
            self.mainMenu.loadReleases()
            self.mainMenu.addStatusItem()
            self.mainMenu.scheduleCheckNewReleases()
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}