//
//  AppDelegate.swift
//  ErlangInstaller-Helper
//
//  Created by Inaka on 9/7/16.
//  Copyright © 2016 Erlang-Solutions. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		var path = self.stringByDeletingLastPathComponentFourTimes(NSBundle.mainBundle().bundlePath)
			
		NSWorkspace.sharedWorkspace().launchApplication(path)
		NSApp.terminate(nil)
		
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}

	func stringByDeletingLastPathComponentFourTimes(thisString: String) -> String  {
		
		return ((((thisString as NSString).stringByDeletingLastPathComponent as NSString).stringByDeletingPathExtension as NSString).stringByDeletingPathExtension as NSString).stringByDeletingPathExtension as String // Ridiculous to do this four times,  but it's like that.

	}
}

