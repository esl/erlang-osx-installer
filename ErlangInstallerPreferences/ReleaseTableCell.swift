//
//  ReleaseTableCell.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ReleaseTableCell: NSTableCellView, InstallationProgress, UninstallationProgress {

    fileprivate var installer : ReleaseInstaller? //= nil
    
    @IBOutlet weak var releaseNameLabel: NSTextField!
    @IBOutlet weak var informationLabel: NSTextField!
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    weak var preferencesPane: ErlangInstallerPreferences!

    @IBAction func installClickAction(_ checkButton: NSButton) {
        self.installer = ReleaseInstaller.install(releaseNameLabel.stringValue, progress: self)
        self.installer?.delegate = self.preferencesPane
   }

    @IBAction func uninstallClickAction(_ checkButton: NSButton) {
        let uninstaller = ReleaseUninstaller(releaseName: releaseNameLabel.stringValue, progress: self)
		uninstaller.delegate = self.preferencesPane
        uninstaller.start()
    }

    @IBAction func cancelClickAction(_ checkButton: NSButton) {
        self.installer!.cancel()
    }
    
    func updateButtonsVisibility() {
        let installed = ReleaseManager.isInstalled(releaseNameLabel.stringValue)
        cancelButton.isHidden = true
        progressIndicator.isHidden = true
        informationLabel.isHidden = true
        installButton.isHidden = installed
        uninstallButton.isHidden = !installed
    }
    
    func deleting() {
        self.informationLabel.stringValue = "Removing..."
        informationLabel.isHidden = false
        progressIndicator.isIndeterminate = true
        progressIndicator.startAnimation(self)
        uninstallButton.isHidden = true
    }
    
    func start() {
        self.informationLabel.stringValue = "Installing..."
        cancelButton.isHidden = false

        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = false

        informationLabel.isHidden = false
        installButton.isHidden = true
    }
    
    func downloading(_ maxValue: Double) {
        self.informationLabel.stringValue = "Downloading..."
        progressIndicator.isIndeterminate = false
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = maxValue
    }
    
    func download(progress delta: Double) {
        self.progressIndicator.increment(by: delta)
    }
    
    func extracting() {
        self.informationLabel.stringValue = "Extracting..."
        progressIndicator.isIndeterminate = true
        progressIndicator.startAnimation(self)
        progressIndicator.isHidden = false
    }
    
    func installing() {
        self.informationLabel.stringValue = "Installing..."
        progressIndicator.isIndeterminate = true
        progressIndicator.startAnimation(self)
        progressIndicator.isHidden = false
    }
    
    func finished() {
        progressIndicator.stopAnimation(self)
        self.updateButtonsVisibility()
    }
    
    func error(_ error: NSError) {
        Utils.alert("\(error)")
    }
}
