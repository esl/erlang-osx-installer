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

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.frame.size
    }
    
    func refresh() {
        if let tableView = self.releasesTableView
        {
            tableView.reloadData()
        }
    }

}
