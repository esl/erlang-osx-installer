//
//  ReleaseTableCell.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleaseTableCell: NSTableCellView {

    @IBOutlet weak var checkButton: NSButton!
    
    @IBAction func checkClickAction(checkButton: NSButton) {
        if(checkButton.state == 1) {
            ReleaseManager.install(checkButton.title)
        } else {
            ReleaseManager.uninstall(checkButton.title)
        }
        checkButton.state = (ReleaseManager.isInstalled(checkButton.title) ? 1 : 0)
    }
}
