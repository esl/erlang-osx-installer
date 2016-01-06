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
    
    @IBOutlet weak var delegate: ReleasesTableViewDelegate!
    
    @IBAction func checkClickAction(checkButton: NSButton) {
        if(checkButton.state == 1) {
            ReleaseManager.install(checkButton.title, installationProgress: self.delegate.installationPanel)
        } else {
            ReleaseManager.uninstall(checkButton.title)
        }
        checkButton.state = (ReleaseManager.isInstalled(checkButton.title) ? 1 : 0)
    }
}
