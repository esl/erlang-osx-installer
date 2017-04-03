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
    static func alert(_ message: String) {
        DispatchQueue.main.async(execute: {
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
        })
    }

    static func confirm(_ message: String) -> Bool {
        return confirm(message, additionalInfo: nil)
    }

    static func confirm(_ message: String, additionalInfo: String?) -> Bool {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = (additionalInfo == nil ? "" : additionalInfo!)
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        return alert.runModal() == NSAlertFirstButtonReturn
    }

    static func supportResourceUrl(_ name : String) -> URL? {
        let appSupportUrl = URL.init(fileURLWithPath: UserDefaults.defaultPath!)

        let urlname = name;
        let url = URL(string: urlname.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! , relativeTo:  appSupportUrl);
        
        return url;
    }
    
    static func preferencePanesUrl(_ name : String) -> URL? {
        let fileManager = FileManager.default
        let appSupportUrl = fileManager.urls(for: .preferencePanesDirectory, in: .userDomainMask).first
        return URL(string: name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!, relativeTo:  appSupportUrl)
    }

    static func fileExists(_ url : URL?) -> Bool {
        return FileManager.default.fileExists(atPath: url!.path)
    }

    static func delete(_ url: URL) {
        if(fileExists(url)) {
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: url)
            } catch let error as NSError {
                Utils.log("\(error)")
                Utils.alert(error.localizedDescription)
            }
        }
    }

    static func iconForApp(_ path: String) -> NSImage {
        return NSWorkspace.shared().icon(forFile: path)
    }

    static func execute(_ source: String) {
        let script = NSAppleScript(source: source)
        let errorInfo: AutoreleasingUnsafeMutablePointer<NSDictionary?> = nil
        let error = script?.executeAndReturnError(errorInfo)
        if(error != nil) {
            log("Error : " + error!.description)
        }
    }

    static func log(_ message: String) {
        NSLog("%@", message)
    }
	
	static func resourceAvailable(_ url: URL?, successHandler: @escaping () -> Void, errorHandler: @escaping (_ error: NSError?) -> Void) {
		if let url = url {
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = "HEAD"
			request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
			request.timeoutInterval = 10.0
			
			let completionHandler = { (response: URLResponse?, data: Data?, err: NSError?) -> Void in
				var status = false
				if let httpResponse = response as? HTTPURLResponse {
					if httpResponse.statusCode == 200 {
						status = true
					}
				}
				if(status) {
					successHandler()
				} else {
					errorHandler(err)
				}
			}
			
			NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main, completionHandler: completionHandler as! (URLResponse?, Data?, Error?) -> Void)
		}
	}
	
    static func notifyNewReleases(_ delegate: NSUserNotificationCenterDelegate, release: Release) {
        let notification = NSUserNotification()
        notification.title = "There's a new Erlang release!"
        notification.informativeText = "Erlang/OTP \(release.name)"
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.deliveryDate = Date(timeIntervalSinceNow: TimeInterval.init())
        
        notification.actionButtonTitle = "Download Now"
        notification.otherButtonTitle = "Dismiss"
        notification.hasActionButton = true
        
        let center = NSUserNotificationCenter.default
        center.delegate = delegate
        center.scheduleNotification(notification)
    }
    
    static func maybeRemovePackageInstallation() {
        do {
            let eslOtpVersionUrl = URL(string: "esl_otp_version", relativeTo: Constants.ErlangEslInstallationDir as URL)

            if !self.fileExists(eslOtpVersionUrl) {
                return
            }
            
            if !confirm("A deprecated ESL Erlang installation has been found. Do you want to uninstall it?") {
                return
            }
            
            var authRef: AuthorizationRef? = nil
            let authFlags = AuthorizationFlags.extendRights
            let osStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)
            
            if(osStatus == errAuthorizationSuccess) {
                // Remove MacUpdaterSwift from the login items
                let macUpdaterSwift = Constants.ErlangEslInstallationDir.appendingPathComponent("MacUpdaterSwift.app")
                setLaunchAtLogin(macUpdaterSwift, enabled: false)

                // Remove EslErlangUpdater.app from the login items
                let eslErlangUpdater = Constants.ErlangEslInstallationDir.appendingPathComponent("EslErlangUpdater.app")
                setLaunchAtLogin(eslErlangUpdater, enabled: false)
                
                // Delete all symlinks to Erlang executables in /usr/local/bin
                let fileManager = FileManager.default
                let localBinDir = "/usr/local/bin/"
                let files = try fileManager.contentsOfDirectory(atPath: localBinDir)
                for file in files {
                    let filePath = localBinDir + file
                    let attrs = try fileManager.attributesOfItem(atPath: filePath)
                    if attrs[FileAttributeKey.type] as? String == FileAttributeType.typeSymbolicLink {
                        let dest = try fileManager.destinationOfSymbolicLink(atPath: filePath)
                        if(dest.hasPrefix("../lib/erlang/")) {
                            delete(URL(fileURLWithPath: filePath))
                        }
                    }
                }

                // Delete ESL Erlang installation dir
                // TODO: do this with admin privileges
                delete(Constants.ErlangEslInstallationDir as URL)
            }
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Error deleting files: \(error.debugDescription)")
        }
    }

    static func setPathCommandForShell(_ shell: String, path: String) -> String {
        let shellName = URL(fileURLWithPath: shell).lastPathComponent
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
    
    static func willLaunchAtLogin(_ itemURL : URL) -> Bool {
        return existingItem(itemURL) != nil
    }
    
    static func setLaunchAtLogin(_ itemURL: URL, enabled: Bool) -> Bool {
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
    
    fileprivate static func getLoginItems() -> LSSharedFileList? {
        let allocator : CFAllocator! = CFAllocatorGetDefault().takeUnretainedValue()
        let kLoginItems : CFString! = kLSSharedFileListSessionLoginItems.takeUnretainedValue()
        let loginItems_ = LSSharedFileListCreate(allocator, kLoginItems, nil)
        if loginItems_ == nil {return nil}
        let loginItems : LSSharedFileList! = loginItems_!.takeRetainedValue()
        return loginItems
    }
    
    fileprivate static func existingItem(_ itemURL : URL) -> LSSharedFileListItem? {
        let loginItems_ = getLoginItems()
        if loginItems_ == nil {return nil}
        let loginItems = loginItems_!
        
        var seed : UInt32 = 0
        let currentItems = LSSharedFileListCopySnapshot(loginItems, &seed).takeRetainedValue() as NSArray
        
        for item in currentItems {
            let resolutionFlags : UInt32 = UInt32(kLSSharedFileListNoUserInteraction | kLSSharedFileListDoNotMountVolumes)
            let url = LSSharedFileListItemCopyResolvedURL(item as! LSSharedFileListItem, resolutionFlags, nil).takeRetainedValue() as URL
            if url == itemURL {
                let result = item as! LSSharedFileListItem
                return result
            }
        }
        
        return nil
    }
}
