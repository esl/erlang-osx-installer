//
//  ReleasesTabViewController.swift
//  ErlangInstaller
//
//  Created by Sebastian Cancinos on 11/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa
import CoreFoundation

class ReleasesTabViewController: NSViewController, refreshPreferences
{
    @IBOutlet var releasesTableView: NSTableView!

    var releasesTableViewDataSource: ReleasesTableViewDataSource!
    
    weak var preferencesPane: ErlangInstallerPreferences!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if self.releasesTableView.dataSource != nil { return }
        self.releasesTableViewDataSource = ReleasesTableViewDataSource()
        self.releasesTableViewDataSource.preferencesPane = self.preferencesPane
        self.releasesTableView.dataSource = self.releasesTableViewDataSource
        self.releasesTableView.delegate = self.releasesTableViewDataSource
    }
    
    func refresh() {
        if let tableView = self.releasesTableView
        {
            tableView.reloadData()
        }
    }

}
