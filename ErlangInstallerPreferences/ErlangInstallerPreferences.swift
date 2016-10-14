//
//  ErlangInstallerPreferences.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 12/31/15.
//  Copyright © 2015 Erlang Solutions. All rights reserved.
//

import PreferencePanes
import CoreFoundation
import ScriptingBridge
import ServiceManagement

class ErlangInstallerPreferences: NSWindowController, refreshPreferences{
	static internal let sharedInstance = ErlangInstallerPreferences()

	private var erlangInstallerApp: ErlangInstallerApplication?
	
    @IBOutlet var _window: NSWindow!
	
    @IBOutlet weak var localMainView: NSView!
	
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var openAtLogin: NSButton!
	@IBOutlet weak var checkForNewReleases: NSButton!
    @IBOutlet weak var defaultRelease: NSComboBox!
    @IBOutlet weak var terminalApplication: NSComboBox!
    @IBOutlet weak var releasesTableView: NSTableView!
	@IBOutlet weak var versionAndBuildNumber: NSTextField! // TODO Check align when adding the new description text.
	
    private var queue: dispatch_queue_t?
    private var source: dispatch_source_t?
	
	override var windowNibName : String! {
		return "ErlangInstallerPreferences"
	}
	
	init() {
		super.init(window: nil)
		NSBundle.mainBundle().loadNibNamed("ErlangInstallerPreferences", owner: self, topLevelObjects: nil)
		if let window = self._window, screen = window.screen {
			
			let offsetFromLeftOfScreen: CGFloat = 200
			let offsetFromTopOfScreen: CGFloat = 200
			let screenRect = screen.visibleFrame
			let newOriginY = screenRect.origin.y + screenRect.height - window.frame.height
				- offsetFromTopOfScreen
			window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
			window.makeKeyAndOrderFront(window)
			window.releasedWhenClosed = false
		}
	}
	
	override init(window: NSWindow!)
	{
		super.init(window: window)
		if let window = self.window, screen = window.screen {
			
			let offsetFromLeftOfScreen: CGFloat = 200
			let offsetFromTopOfScreen: CGFloat = 200
			let screenRect = screen.visibleFrame
			let newOriginY = screenRect.origin.y + screenRect.height - window.frame.height
				- offsetFromTopOfScreen
			window.setFrameOrigin(NSPoint(x: offsetFromLeftOfScreen, y: newOriginY))
			window.releasedWhenClosed = false
		}
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func showWindow(sender: AnyObject?) {
	super.showWindow(sender)
		if let window = self._window {
		window.makeKeyAndOrderFront(window)
		}
	}
    override func windowDidLoad() {
		super.windowDidLoad()
		
		// FIXME: store & recall the last position self.windowFrameAutosaveName = "ErlangInstallerPreferencesPosition"

        self.erlangInstallerApp = SBApplication(bundleIdentifier: Constants.applicationId)
        reloadReleases()
       	self.loadVersionAndBuildNumber()
        self.checkForFileUpdate()
    }

	func loadVersionAndBuildNumber() {
		let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as? String
		let build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String
		self.versionAndBuildNumber.stringValue = "Version " + version! + " Build " + build!
	}
	
    func checkForFileUpdate()
    {
        let file = open((ReleaseManager.availableReleasesUrl?.path)!, O_EVTONLY)
        if(file > 0)
        {
            self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
            self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, UInt(file),
                                                DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_DELETE,queue)
            
            dispatch_source_set_event_handler(self.source!) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.reloadReleases()
                }
					self.close() // FIXME revise close to a specific file
                let reload = dispatch_time(DISPATCH_TIME_NOW, 1);
                dispatch_after(reload, self.queue!, {
                    dispatch_source_cancel(self.source!)
                    self.checkForFileUpdate()
                })
            }
            
            dispatch_resume(self.source!)
        }
        else
        {
            Utils.log("Couldn't open \(ReleaseManager.availableReleasesUrl!.path!)")
        }
        
    }
    
    func reloadReleases()
    {
        ReleaseManager.load() {
            self.loadPreferencesValues()
        }
    }

    func loadPreferencesValues() {
        // Load current preferences
        self.openAtLogin.state = (UserDefaults.openAtLogin ? 1 : 0)
        self.checkForNewReleases.state = (UserDefaults.checkForNewReleases ? 1 : 0)

        // Check if the default release is currently installed
        self.defaultRelease.removeAllItems()
        self.defaultRelease.addItemsWithObjectValues(ReleaseManager.installed.map({release in return release.name}))
        self.defaultRelease.stringValue = UserDefaults.defaultRelease ?? ""

        self.terminalApplication.removeAllItems()
        self.terminalApplication.addItemsWithObjectValues(TerminalApplications.terminals.keys.sort())
        self.terminalApplication.stringValue = UserDefaults.terminalApp
        
        self.releasesTableView.reloadData()
    }

    func updateReleasesForAgent() {
        self.erlangInstallerApp?.update!()
    }

    func scheduleCheckNewReleasesForAgent() {
        self.erlangInstallerApp?.checkNewReleases!()
    }

	@IBAction func openAtLoginClick(sender: AnyObject) {
		// FIXME: sub project not necessary when this is fixed.
		//			if !SMLoginItemSetEnabled(("com.erlang-solutions.ErlangInstaller-Helper" as CFString), Bool(sender.state)) {
		//				print("Setting as login item was not successful")
		//			}
        UserDefaults.openAtLogin = self.openAtLogin.state == 1
        let url = NSWorkspace.sharedWorkspace().URLForApplicationWithBundleIdentifier(Constants.applicationId)
        Utils.setLaunchAtLogin(url!, enabled: UserDefaults.openAtLogin)
    }

    @IBAction func checkNewReleasesClick(sender: AnyObject) {
        UserDefaults.checkForNewReleases = self.checkForNewReleases.state == 1
        self.scheduleCheckNewReleasesForAgent()
    }
	
    @IBAction func defaultReleaseSelection(sender: AnyObject) {
        UserDefaults.defaultRelease = self.defaultRelease.selectedCell()!.title
        
        let selectedRelease = ReleaseManager.releases[UserDefaults.defaultRelease!]
        try! ReleaseManager.makeSymbolicLinks(selectedRelease!)
        
        self.updateReleasesForAgent()
		self.releasesTableView.reloadData()
    }
    
    @IBAction func terminalAppSelection(sender: AnyObject) {
        UserDefaults.terminalApp = self.terminalApplication.selectedCell()!.title
    }

    func revealElementForKey(key: String) {
        self.tabView.selectTabViewItemWithIdentifier(key)
    }
	
	func refresh() {
		self.loadPreferencesValues()
	}
}
