//
//  ReleaseTableCell.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleaseTableCell: NSTableCellView, InstallationProgress, UninstallationProgress {

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
        self.installer?.start()
   }

    @IBAction func uninstallClickAction(checkButton: NSButton) {
        let uninstaller = ReleaseUninstaller(releaseName: releaseNameLabel.stringValue, progress: self)
        uninstaller.start()
    }

    @IBAction func cancelClickAction(checkButton: NSButton) {
        self.installer?.cancel()
    }
    
    func updateButtonsVisibility() {
        let installed = ReleaseManager.isInstalled(releaseNameLabel.stringValue)
        cancelButton.hidden = true
        progressIndicator.hidden = true
        informationLabel.hidden = true
        installButton.hidden = installed
        uninstallButton.hidden = !installed
    }
    
    func deleting() {
        self.informationLabel.stringValue = "Removing..."
        informationLabel.hidden = false
        progressIndicator.indeterminate = true
        progressIndicator.startAnimation(self)
        uninstallButton.hidden = true
    }
    
    func start() {
        self.informationLabel.stringValue = "Installing..."
        cancelButton.hidden = false

        progressIndicator.doubleValue = 0
        progressIndicator.hidden = false

        informationLabel.hidden = false
        installButton.hidden = true
    }
    
    func downloading(maxValue: Double) {
        self.informationLabel.stringValue = "Downloading..."
        progressIndicator.indeterminate = false
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = maxValue
    }
    
    func download(progress delta: Double) {
        self.progressIndicator.incrementBy(delta)
    }
    
    func extracting() {
        self.informationLabel.stringValue = "Extracting..."
    }
    
    func finished() {
        progressIndicator.stopAnimation(self)
        self.updateButtonsVisibility()
        self.delegate.preferencesPane.loadPreferencesValues()
        self.delegate.preferencesPane.updateReleasesForAgent()
    }
    
    func error(error: NSError) {
        Utils.alert("\(error)")
    }
}
