//
//  ErlangInstallerPreferences.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/31/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import PreferencePanes

class ErlangInstallerPreferences: NSPreferencePane, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet var _window: NSWindow!
    
    @IBOutlet weak var localMainView: NSView!
    
    override func assignMainView() {
        self.mainView = self.localMainView
    }

    override func mainViewDidLoad() {
    }
    
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
