//
//  TableViewPindonga.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleasesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var preferencesPane: ErlangInstallerPreferences!
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return ReleaseManager.available.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?,row rowIndex: Int) -> NSView? {
        let cellView : ReleaseTableCell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! ReleaseTableCell
        let release = ReleaseManager.available[rowIndex]
        cellView.releaseNameLabel.stringValue = release.name
		if UserDefaults.defaultRelease == release.name {
			cellView.releaseNameLabel.font =  NSFont.boldSystemFontOfSize(NSFont.systemFontSize())
		}
		else {
			cellView.releaseNameLabel.font = NSFont.systemFontOfSize(NSFont.systemFontSize())
		}
        cellView.updateButtonsVisibility()
        return cellView
    }
}
