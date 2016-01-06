//
//  Utils.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class Utils {
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
}