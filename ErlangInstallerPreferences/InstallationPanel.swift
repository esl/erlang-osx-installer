//
//  InstallationPanel.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/6/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class InstallationPanel: NSPanel, InstallationProgress {
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var releaseName: NSTextField!
    @IBOutlet weak var informationMessage: NSTextField!

    func start(releaseName: String) {
        self.releaseName.stringValue = "Release " + releaseName
        self.informationMessage.stringValue = ""
        self.makeKeyAndOrderFront(self)
    }

    func downloading(maxValue: Double) {
        self.informationMessage.stringValue = "Downloading..."
        self.progressBar.minValue = 0
        self.progressBar.maxValue = maxValue
    }

    func download(progress delta: Double) {
        self.progressBar.incrementBy(delta)
    }
}
