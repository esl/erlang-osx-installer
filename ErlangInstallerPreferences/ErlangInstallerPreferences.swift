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

    private var queue: dispatch_queue_t?
    private var source: dispatch_source_t?
		
    
	init() {
    	super.init(window: nil)

		if let window = self.window, screen = window.screen {
			
            
			let offsetFromLeftOfScreen: CGFloat = 200
			let offsetFromTopOfScreen: CGFloat = 200
			let screenRect = screen.visibleFrame
			let newOriginY = screenRect.origin.y + screenRect.height - window.frame.height
				- offsetFromTopOfScreen
			window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
			window.makeKeyAndOrderFront(window)
			window.releasedWhenClosed = false
		}
	}
	
	override init(window: NSWindow!)
	{
		super.init(window: window)
		if let window = self.window, screen = window.screen {
			
			let offsetFromLeftOfScreen: CGFloat = 200
			let offsetFromTopOfScreen: CGFloat = 200
			let screenRect = screen.visibleFrame
			let newOriginY = screenRect.origin.y + screenRect.height - window.frame.height
				- offsetFromTopOfScreen
			window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
			window.releasedWhenClosed = false
		}
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func showWindow(sender: AnyObject?) {
	super.showWindow(sender)
		if let window = self.window {
		window.makeKeyAndOrderFront(window)
        window.orderFrontRegardless()
        window.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
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
            self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(file),
                                                DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_DELETE,queue)
            
            dispatch_source_set_event_handler(self.source!) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reloadReleases()
                }

                let reload = dispatch_time(DISPATCH_TIME_NOW, 1);
                dispatch_after(reload, self.queue!, {
                    dispatch_source_cancel(self.source!)
                    self.checkForFileUpdate()
                })
            }
            
            dispatch_resume(self.source!)
        }
        else
        {
            Utils.log("Couldn't open \(ReleaseManager.availableReleasesUrl!.path!)")
        }
        
    }
    
    func reloadReleases()
    {
        ReleaseManager.load() {
            self.refresh()
        }
    }

    func revealElementForKey(key: String) {
        if let tabBarController = self.window?.contentViewController as? NSTabViewController
        {
            let identifier: Int
            switch key {
            case "erlang":
                identifier = 0
            case "releases":
                identifier = 1
            default:
                NSLog("Unknown identifier: \(key)")
                return
            }
            tabBarController.selectedTabViewItemIndex = identifier
        }
    }
	
	func refresh() {
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
