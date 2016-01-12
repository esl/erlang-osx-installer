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
        print(error)
    }
}