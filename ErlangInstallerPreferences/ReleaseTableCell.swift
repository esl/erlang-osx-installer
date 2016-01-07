//
//  ReleaseTableCell.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleaseTableCell: NSTableCellView, InstallationProgress {

    @IBOutlet weak var releaseNameLabel: NSTextField!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var delegate: ReleasesTableViewDelegate!

    @IBAction func installClickAction(checkButton: NSButton) {
        cancelButton.hidden = false
        progressIndicator.hidden = false
        informationLabel.hidden = false
        installButton.hidden = true
        ReleaseManager.install(releaseNameLabel.stringValue, installationProgress: self)
   }

    @IBAction func uninstallClickAction(checkButton: NSButton) {
        ReleaseManager.uninstall(releaseNameLabel.stringValue)
    }

    @IBAction func cancelClickAction(checkButton: NSButton) {
        //ReleaseManager.cancel()
    }
    
    func updateButtonsVisibility() {
        let installed = ReleaseManager.isInstalled(releaseNameLabel.stringValue)
        cancelButton.hidden = true
        installButton.hidden = installed
        uninstallButton.hidden = !installed
    }
    
    func start(releaseName: String) {
        self.informationLabel.stringValue = "Installing..."
    }
    
    func downloading(maxValue: Double) {
        self.informationLabel.stringValue = "Downloading..."
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = maxValue
    }
    
    func download(progress delta: Double) {
        self.progressIndicator.incrementBy(delta)
    }
}
