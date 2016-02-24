//
//  Terminal.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/12/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation
import ScriptingBridge
import CoreServices

protocol ErlangTerminal {
    var applicationName: String { get }
    var applicationId: String { get }
    func open(release: Release)
}

extension ErlangTerminal {
    var installed: Bool {
        get {
            let appURL = UnsafeMutablePointer<Unmanaged<CFError>?>()
            let result = LSCopyApplicationURLsForBundleIdentifier(self.applicationId, appURL)
            return result != nil
        }
    }

    private var shell: String {
        get {
            return NSProcessInfo.processInfo().environment["SHELL"] ?? "bash"
        }
    }
    
    private func shellCommands(release: Release) -> String {
        let erl = release.binPath.stringByReplacingOccurrencesOfString(" ", withString: "\\ ")
        let changePathCommand = Utils.setPathCommandForShell(self.shell, path: erl)
        return "\(changePathCommand); clear; erl"
    }
}

class TerminalApplications {
    private static let terminalsInstance = TerminalApplications()

    static var terminals: [String: ErlangTerminal] {
        get {
            return terminalsInstance.terminalsDictionary
        }
    }
    
    private var terminalsDictionary = [String: ErlangTerminal]()

    init() {
        let allTerminals: [ErlangTerminal] = [iTerm(), Terminal()]
        for terminal in allTerminals {
            if terminal.installed {
                terminalsDictionary[terminal.applicationName] = terminal
            }
        }
    }
}

class Terminal: ErlangTerminal {
    var applicationName: String { get { return "Terminal" } }
    var applicationId: String { get { return "com.apple.Terminal" } }
    var app: SBTerminalApplication {
        get {
            return SBApplication(bundleIdentifier: self.applicationId) as! SBTerminalApplication
        }
    }

    func open(release: Release) {
        app.doScript!(self.shellCommands(release), `in`: nil)

        if !app.frontmost! {
            app.activate()
        }
    }
}

class iTerm: AnyObject, ErlangTerminal {
    var applicationName: String { get { return "iTerm2" } }
    var applicationId: String { get { return "com.googlecode.iterm2" } }
    var app: SBiTermITermApplication {
        get {
            return SBApplication(bundleIdentifier: self.applicationId) as! SBiTermITermApplication
        }
    }

    func open(release: Release) {
        let sessionClass = app.classForScriptingClass!("session") as! SBiTermSession.Type
        let session = sessionClass.init()

        if app.terminals!().count == 0 {
            let terminalClass = app.classForScriptingClass!("terminal") as! SBiTermTerminal.Type
            let terminal = terminalClass.init()
            app.terminals!().addObject(terminal)
            terminal.sessions!().addObject(session)
        } else {
            app.currentTerminal!.sessions!().addObject(session)
        }
        
        app.currentTerminal!.currentSession!.execCommand!(self.shell)
        app.currentTerminal!.currentSession!.writeContentsOfFile!(nil, text: self.shellCommands(release))
        
        if !app.frontmost! {
            app.activate()
        }
    }
}