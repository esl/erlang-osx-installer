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

    var statusItem : NSStatusItem?

    override init() {
        self.statusItem = nil
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        addStatusItem()
    }
    
    func showMessage(sender : AnyObject) {
        let alert = NSAlert()
        alert.messageText = "Important Information: I'm closing myself, peace out!"
        alert.runModal()
        NSApp.terminate(self)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    func addStatusItem() {
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem?.image = NSImage(named: "menu-bar-icon.png")
        self.statusItem?.button!.target = self
        self.statusItem?.button!.action = "showMessage:"

    }
}

