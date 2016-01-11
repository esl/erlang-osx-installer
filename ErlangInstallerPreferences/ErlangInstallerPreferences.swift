//
//  ErlangInstallerPreferences.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/31/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import PreferencePanes

class ErlangInstallerPreferences: NSPreferencePane {

    @IBOutlet var _window: NSWindow!
    
    @IBOutlet weak var localMainView: NSView!
    
    @IBOutlet weak var appIcon: NSImageView!
    
    override func assignMainView() {
        self.mainView = self.localMainView
    }

    override func mainViewDidLoad() {
        // load current preferences        
        appIcon.image = Utils.iconForApp(UserDefaults.terminalApp)
    }
    
    @IBAction func selectTerminalAppClick(sender: AnyObject) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["app"]
        panel.runModal()
        UserDefaults.terminalApp = panel.URLs.last!.path!
        appIcon.image = Utils.iconForApp(UserDefaults.terminalApp)
    }
}
