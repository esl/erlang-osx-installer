//
//  ReleaseTableCell.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleaseTableCell: NSTableCellView, InstallationProgress {

    private var installer : ReleaseInstaller? = nil
    
    @IBOutlet weak var releaseNameLabel: NSTextField!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var delegate: ReleasesTableViewDelegate!

    @IBAction func installClickAction(checkButton: NSButton) {
        self.installer = ReleaseInstaller(releaseName: releaseNameLabel.stringValue, progress: self)
        self.installer!.start()
   }

    @IBAction func uninstallClickAction(checkButton: NSButton) {
        // Create instance of uninstaller
        // let uninstaller = ReleaseUnInstaller(releaseName: releaseNameLabel.stringValue, progress: self)
        // uninstaller.start()
    }

    @IBAction func cancelClickAction(checkButton: NSButton) {
        // installer.cancel()
    }
    
    func updateButtonsVisibility() {
        let installed = ReleaseManager.isInstalled(releaseNameLabel.stringValue)
        cancelButton.hidden = true
        installButton.hidden = installed
        uninstallButton.hidden = !installed
    }
    
    func start() {
        self.informationLabel.stringValue = "Installing..."
        cancelButton.hidden = false
        progressIndicator.hidden = false
        informationLabel.hidden = false
        installButton.hidden = true
    }
    
    func downloading(maxValue: Double) {
        self.informationLabel.stringValue = "Downloading..."
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = maxValue
    }
    
    func download(progress delta: Double) {
        self.progressIndicator.incrementBy(delta)
    }
    
    func downloadFinished() {
    }
    
    func error(error: NSError) {
        Utils.alert("\(error)")
    }
}
