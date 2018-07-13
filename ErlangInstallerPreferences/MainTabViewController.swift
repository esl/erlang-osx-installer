//
//  MainTabViewController.swift
//  ErlangInstaller
//
//  Created by Sebastian Cancinos on 11/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa
import CoreFoundation
import ScriptingBridge

class MainTabViewController: NSViewController, NSTextFieldDelegate
{
    
    @IBOutlet var openAtLogin: NSButton!
    @IBOutlet var checkForNewReleases: NSButton!
    @IBOutlet var defaultRelease: NSComboBox!
    @IBOutlet var terminalApplication: NSComboBox!
    @IBOutlet var instalationFolder: NSTextField!
    @IBOutlet var versionAndBuildNumber: NSTextField! // TODO Check align when adding the new description text.
    
    fileprivate var erlangInstallerApp: ErlangInstallerApplication?

    override func viewDidLoad() {
        preferredContentSize = view.frame.size
        self.erlangInstallerApp = SBApplication(bundleIdentifier: Constants.applicationId)
       	self.loadVersionAndBuildNumber()
        self.loadPreferencesValues()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.showReleasesList()
    }
    
    func loadPreferencesValues() {
        // Load current preferences
        self.openAtLogin.state = (NSControl.StateValue(rawValue: UserDefaults.openAtLogin ? 1 : 0))
        self.checkForNewReleases.state = (NSControl.stateValue(rawValue: UserDefaults.checkForNewReleases ? 1 : 0))
        self.showReleasesList()
        
        self.terminalApplication.removeAllItems()
        self.terminalApplication.addItems(withObjectValues: TerminalApplications.terminals.keys.sorted())
        self.terminalApplication.stringValue = UserDefaults.terminalApp
        
        self.instalationFolder.stringValue = UserDefaults.defaultPath!
    }
    
    
    fileprivate func showReleasesList() {
        // Check if the default release is currently installed
        self.defaultRelease.removeAllItems()
        self.defaultRelease.addItems(withObjectValues: ReleaseManager.installed.map({release in return release.name}))
        self.defaultRelease.stringValue = UserDefaults.defaultRelease ?? ""
    }
    
    override func controlTextDidEndEditing(_ obj: Notification)
    {
        UserDefaults.defaultPath = self.instalationFolder.stringValue
    }
    
    func updateReleasesForAgent() {
        self.erlangInstallerApp?.update!()
    }
    
    func scheduleCheckNewReleasesForAgent() {
        self.erlangInstallerApp?.checkNewReleases!()
    }

    func loadVersionAndBuildNumber() {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        self.versionAndBuildNumber.stringValue = "Version " + version! + " Build " + build!
    }

    @IBAction func openAtLogin(_ sender: AnyObject) {
    
        // FIXME: sub project not necessary when this is fixed.
        //			if !SMLoginItemSetEnabled(("com.erlang-solutions.ErlangInstaller-Helper" as CFString), Bool(sender.state)) {
        //				print("Setting as login item was not successful")
        //			}
        UserDefaults.openAtLogin = self.openAtLogin.state == 1
        let url = NSWorkspace.shared().urlForApplication(withBundleIdentifier: Constants.applicationId)
        _ = Utils.setLaunchAtLogin(url!, enabled: UserDefaults.openAtLogin)
    }
    
    @IBAction func checkNewReleasesClick(_ sender: AnyObject) {
    
        UserDefaults.checkForNewReleases = self.checkForNewReleases.stateValue == 1
        self.scheduleCheckNewReleasesForAgent()
    }
    
    @IBAction func defaultReleaseSelection(_ sender: AnyObject) {
        do {
            if let defaultRelease = self.defaultRelease.selectedCell()
            {
                UserDefaults.defaultRelease = defaultRelease.title
                
                if let selectedRelease = ReleaseManager.releases[UserDefaults.defaultRelease!]
                {
                  try ReleaseManager.makeSymbolicLinks(selectedRelease)
                }
                
                self.updateReleasesForAgent()
               // self.releasesTableView.reloadData()
            }
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Creating Symbolic links failed: \(error.debugDescription)")
        }
    }
    
    @IBAction func terminalAppSelection(_ sender: AnyObject) {
        UserDefaults.terminalApp = self.terminalApplication.selectedCell()!.title
    }
    

}
