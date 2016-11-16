//
//  ReleasesTabViewController.swift
//  ErlangInstaller
//
//  Created by Sebastian Cancinos on 11/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa
import CoreFoundation

class ReleasesTabViewController: NSViewController
{
    @IBOutlet var releasesTableView: NSTableView!

    
    func loadPreferencesValues() {
        self.releasesTableView.reloadData()
    }

}
