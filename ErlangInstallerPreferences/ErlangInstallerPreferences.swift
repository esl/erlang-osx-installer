//
//  ErlangInstallerPreferences.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/31/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import PreferencePanes
import CoreFoundation
import ScriptingBridge
import ServiceManagement

class ErlangInstallerPreferences: NSWindowController, refreshPreferences {
    
    fileprivate var queue: DispatchQueue?
    fileprivate var source: DispatchSource?
    
    
    init() {
        super.init(window: nil)
        
        if let window = self.window, let screen = window.screen {
            
            
            let offsetFromLeftOfScreen: CGFloat = 200
            let offsetFromTopOfScreen: CGFloat = 200
            let screenRect = screen.visibleFrame
            let newOriginY = screenRect.origin.y + screenRect.height - window.frame.height
                - offsetFromTopOfScreen
            window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
            window.makeKeyAndOrderFront(window)
            window.isReleasedWhenClosed = false
        }
    }
    
    override init(window: NSWindow!)
    {
        super.init(window: window)
        if let window = self.window, let screen = window.screen {
            
            let offsetFromLeftOfScreen: CGFloat = 200
            let offsetFromTopOfScreen: CGFloat = 200
            let screenRect = screen.visibleFrame
            let newOriginY = screenRect.origin.y + screenRect.height - window.frame.height
                - offsetFromTopOfScreen
            window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
            window.isReleasedWhenClosed = false
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        if let window = self.window {
            window.makeKeyAndOrderFront(window)
            window.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // FIXME: store & recall the last position self.windowFrameAutosaveName = "ErlangInstallerPreferencesPosition"
        
        reloadReleases()
        self.checkForFileUpdate()
    }
    
    func checkForFileUpdate()
    {
        let file = open((ReleaseManager.availableReleasesUrl?.path)!, O_EVTONLY)
        if(file > 0)
        {
            self.queue = DispatchQueue.global(qos: .default)
            let eventMask: DispatchSource.FileSystemEvent = [.write, .extend, .delete]
            self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: file, eventMask: eventMask, queue: queue) /*Migrator FIXME: Use DispatchSourceFileSystemObject to avoid the cast*/ as? DispatchSource
            
            self.source!.setEventHandler {
                DispatchQueue.main.async {
                    self.reloadReleases()
                }
                
                let reload = DispatchTime.now() + Double(1) / Double(NSEC_PER_SEC);
                self.queue!.asyncAfter(deadline: reload, execute: {
                    self.source!.cancel()
                    self.checkForFileUpdate()
                })
            }
            
            self.source!.resume()
        }
        else
        {
            Utils.log("Couldn't open \(ReleaseManager.availableReleasesUrl!.path)")
        }
        
    }
    
    func reloadReleases()
    {
        ReleaseManager.load() {
            self.refresh()
        }
    }
    
    func revealElementForKey(_ key: String) {
        if let tabBarController = self.window?.contentViewController as? NSTabViewController
        {
            let tabBarIdentifierIndex: Int
            switch key {
            case "erlang":
                tabBarIdentifierIndex = 0
            case "releases":
                tabBarIdentifierIndex = 1
            default:
                NSLog("Unknown identifier: \(key)")
                return
            }
            tabBarController.selectedTabViewItemIndex = tabBarIdentifierIndex
        }
    }
    
    func refresh() {
        if let appDelegate = NSApp.delegate as? AppDelegate
        {
            appDelegate.mainMenu.loadReleases()
        }
        if let tabBarController = self.window?.contentViewController as? NSTabViewController
        {
            tabBarController.tabView.tabViewItems.forEach({ (tab: NSTabViewItem) in
                if let refreshableView = tab.viewController as? refreshPreferences
                {
                    refreshableView.refresh()
                }
            })
        }
    }
}
