//
//  TableViewPindonga.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleasesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return ReleaseManager.available.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?,row rowIndex: Int) -> NSView? {
        let cellView : ReleaseTableCell = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! ReleaseTableCell
        let release = ReleaseManager.available[rowIndex]
        
		if UserDefaults.defaultRelease == release.name {
            cellView.releaseNameLabel.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize())
		}else {
			cellView.releaseNameLabel.font = NSFont.systemFont(ofSize: NSFont.systemFontSize())
		}
        
        if let appDelegate = NSApp.delegate as? AppDelegate {
            cellView.preferencesPane = appDelegate.mainWindow
        }
        
        
        cellView.releaseNameLabel.stringValue = release.name
        cellView.updateButtonsVisibility()
        
        return cellView
    }
}
