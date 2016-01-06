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
    
    func tableView(aTableView: NSTableView, objectValueForTableColumn aTableColumn: NSTableColumn?,row rowIndex: Int) -> AnyObject? {
        if aTableColumn != nil {
            return ReleaseManager.available[rowIndex].name
        } else {
            return nil
        }
    }
}
