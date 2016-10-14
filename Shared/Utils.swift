//
//  Utils.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa
import SystemConfiguration

class Utils {
    static func alert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }

    static func confirm(message: String) -> Bool {
        return confirm(message, additionalInfo: nil)
    }

    static func confirm(message: String, additionalInfo: String?) -> Bool {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = (additionalInfo == nil ? "" : additionalInfo!)
        alert.addButtonWithTitle("Yes")
        alert.addButtonWithTitle("No")
        return alert.runModal() == NSAlertFirstButtonReturn
    }

    static func supportResourceUrl(name : String) -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let appSupportUrl = fileManager.URLsForDirectory(.ApplicationDirectory, inDomains: .UserDomainMask).first
        let urlname = "Erlang/" + name;
        let url = NSURL(string: urlname.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! , relativeToURL:  appSupportUrl);
        
        return url;
    }
    
    static func preferencePanesUrl(name : String) -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let appSupportUrl = fileManager.URLsForDirectory(.PreferencePanesDirectory, inDomains: .UserDomainMask).first
        return NSURL(string: name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!, relativeToURL:  appSupportUrl)
    }

    static func fileExists(url : NSURL?) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(url!.path!)
    }

    static func delete(url: NSURL) {
        if(fileExists(url)) {
            let fileManager = NSFileManager.defaultManager()
            do {
                try fileManager.removeItemAtURL(url)
            } catch {
                Utils.log("\(error)")
            }

        }
    }

    static func iconForApp(path: String) -> NSImage {
        return NSWorkspace.sharedWorkspace().iconForFile(path)
    }

    static func execute(source: String) {
        let script = NSAppleScript(source: source)
        let errorInfo = AutoreleasingUnsafeMutablePointer<NSDictionary?>()
        let error = script?.executeAndReturnError(errorInfo)
        if(error != nil) {
            log("Error : " + error!.description)
        }
    }

    static func log(message: String) {
        NSLog("%@", message)
    }
	
	static func resourceAvailable(url: NSURL?, successHandler: () -> Void, errorHandler: (error: NSError?) -> Void) {
		if let url = url {
			let request = NSMutableURLRequest(URL: url)
			request.HTTPMethod = "HEAD"
			request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
			request.timeoutInterval = 10.0
			
			let completionHandler = { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
				var status = false
				if let httpResponse = response as? NSHTTPURLResponse {
					if httpResponse.statusCode == 200 {
						status = true
					}
				}
				if(status) {
					successHandler()
				} else {
					errorHandler(error: error)
				}
			}
			
			NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: completionHandler)
		}
	}
	
    static func notifyNewReleases(delegate: NSUserNotificationCenterDelegate, release: Release) {
        let notification = NSUserNotification()
        notification.title = "There's a new Erlang release!"
        notification.informativeText = "Erlang/OTP \(release.name)"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.deliveryDate = NSDate(timeIntervalSinceNow: NSTimeInterval.init())
        
        notification.actionButtonTitle = "Download Now"
        notification.otherButtonTitle = "Dismiss"
        notification.hasActionButton = true
        
        let center = NSUserNotificationCenter.defaultUserNotificationCenter()
        center.delegate = delegate
        center.scheduleNotification(notification)
    }
    
    static func maybeRemovePackageInstallation() {
        let eslOtpVersionUrl = NSURL(string: "esl_otp_version", relativeToURL: Constants.ErlangEslInstallationDir)

        if !self.fileExists(eslOtpVersionUrl) {
            return
        }
        
        if !confirm("A deprecated ESL Erlang installation has been found. Do you want to uninstall it?") {
            return
        }

        // Remove MacUpdaterSwift from the login items
        let macUpdaterSwift = Constants.ErlangEslInstallationDir.URLByAppendingPathComponent("MacUpdaterSwift.app")
        setLaunchAtLogin(macUpdaterSwift, enabled: false)

        // Remove EslErlangUpdater.app from the login items
        let eslErlangUpdater = Constants.ErlangEslInstallationDir.URLByAppendingPathComponent("EslErlangUpdater.app")
        setLaunchAtLogin(eslErlangUpdater, enabled: false)
        
        // Delete all symlinks to Erlang executables in /usr/local/bin
        let fileManager = NSFileManager.defaultManager()
        let localBinDir = "/usr/local/bin/"
        let files = try! fileManager.contentsOfDirectoryAtPath(localBinDir)
        for file in files {
            let filePath = localBinDir + file
            let attrs = try! fileManager.attributesOfItemAtPath(filePath)
            if attrs[NSFileType] as? String == NSFileTypeSymbolicLink {
                let dest = try! fileManager.destinationOfSymbolicLinkAtPath(filePath)
                if(dest.hasPrefix("../lib/erlang/")) {
                    delete(NSURL(fileURLWithPath: filePath))
                }
            }
        }

        // Delete ESL Erlang installation dir
        // TODO: do this with admin privileges
        delete(Constants.ErlangEslInstallationDir)
    }
    
    static func setPathCommandForShell(shell: String, path: String) -> String {
        let shellName = NSURL(fileURLWithPath: shell).lastPathComponent!
        var command: String?
        
        switch shellName {
        case "fish":
            command = "setenv PATH \(path) $PATH"
        default:
            command = "export PATH=\(path):$PATH"
        }
        
        return command!
    }
    
    /*******************************************************************
     ** Login items 
     *******************************************************************/
    
    static func willLaunchAtLogin(itemURL : NSURL) -> Bool {
        return existingItem(itemURL) != nil
    }
    
    static func setLaunchAtLogin(itemURL: NSURL, enabled: Bool) -> Bool {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {return false}
        let loginItems = loginItems_!
        
        let item = existingItem(itemURL)
        if item != nil && !enabled {
            LSSharedFileListItemRemove(loginItems, item)
        } else if enabled {
            LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeUnretainedValue(), nil, nil, itemURL as CFURL, nil, nil)
        }
        return true
    }
    
    private static func getLoginItems() -> LSSharedFileList? {
        let allocator : CFAllocator! = CFAllocatorGetDefault().takeUnretainedValue()
        let kLoginItems : CFString! = kLSSharedFileListSessionLoginItems.takeUnretainedValue()
        let loginItems_ = LSSharedFileListCreate(allocator, kLoginItems, nil)
        if loginItems_ == nil {return nil}
        let loginItems : LSSharedFileList! = loginItems_.takeRetainedValue()
        return loginItems
    }
    
    private static func existingItem(itemURL : NSURL) -> LSSharedFileListItem? {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {return nil}
        let loginItems = loginItems_!
        
        var seed : UInt32 = 0
        let currentItems = LSSharedFileListCopySnapshot(loginItems, &seed).takeRetainedValue() as NSArray
        
        for item in currentItems {
            let resolutionFlags : UInt32 = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
            let url = LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, resolutionFlags, nil).takeRetainedValue() as NSURL
            if url.isEqual(itemURL) {
                let result = item as! LSSharedFileListItem
                return result
            }
        }
        
        return nil
    }
}