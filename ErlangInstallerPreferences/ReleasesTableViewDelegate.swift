//
//  TableViewPindonga.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleasesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return ReleaseManager.available.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?,row rowIndex: Int) -> NSView? {
        let cellView : ReleaseTableCell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! ReleaseTableCell
        let release = ReleaseManager.available[rowIndex]
        
		if UserDefaults.defaultRelease == release.name {
			cellView.releaseNameLabel.font =  NSFont.boldSystemFontOfSize(NSFont.systemFontSize())
		}else {
			cellView.releaseNameLabel.font = NSFont.systemFontOfSize(NSFont.systemFontSize())
		}
        
        if let appDelegate = NSApp.delegate as? AppDelegate {
            cellView.preferencesPane = appDelegate.mainWindow
        }
        
        
        cellView.releaseNameLabel.stringValue = release.name
        cellView.updateButtonsVisibility()
        
        return cellView
    }
}
