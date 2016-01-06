//
//  TableViewPindonga.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleasesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var installationPanel: InstallationPanel!
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return ReleaseManager.available.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?,row rowIndex: Int) -> NSView? {
        let cellView : ReleaseTableCell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! ReleaseTableCell
        let release = ReleaseManager.available[rowIndex]
        cellView.checkButton.title = release.name
        cellView.checkButton.state = (release.installed ? 1 : 0)
        return cellView
    }
}
