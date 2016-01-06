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
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func checkClickAction(checkButton: NSButton) {
        if(checkButton.state == 1) {
            ReleaseManager.install(checkButton.title)
        } else {
            ReleaseManager.uninstall(checkButton.title)
        }
        checkButton.state = (ReleaseManager.manager.isInstalled(checkButton.title) ? 1 : 0)
    }
}
