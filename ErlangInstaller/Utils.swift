//
//  Utils.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

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
        let appSupportUrl = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first
        return NSURL(string: "ErlangInstaller/" + name, relativeToURL:  appSupportUrl)
    }

    static func fileExists(url : NSURL?) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(url!.path!)
    }

    static func delete(url: NSURL) {
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.removeItemAtURL(url)
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
    
    /** Login items **/
    
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