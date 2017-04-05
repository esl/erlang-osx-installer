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
    func open(_ release: Release)
}

extension ErlangTerminal {
    var installed: Bool {
        get {
            let appURL: UnsafeMutablePointer<Unmanaged<CFError>?>? = nil
            let result = LSCopyApplicationURLsForBundleIdentifier(self.applicationId as CFString, appURL)
            return result != nil
        }
    }

    fileprivate var shell: String {
        get {
            return ProcessInfo().environment["SHELL"] ?? "bash"
        }
    }
    
    fileprivate func shellCommands(_ release: Release) -> String {
        let erl = release.binPath.replacingOccurrences(of: " ", with: "\\ ")
        let changePathCommand = Utils.setPathCommandForShell(self.shell, path: erl)
        return "\(changePathCommand); clear; erl"
    }
}

class TerminalApplications {
    fileprivate static let terminalsInstance = TerminalApplications()

    static var terminals: [String: ErlangTerminal] {
        get {
            return terminalsInstance.terminalsDictionary
        }
    }
    
    fileprivate var terminalsDictionary = [String: ErlangTerminal]()

    init() {
        let allTerminals: [ErlangTerminal] = [Terminal()]
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

    func open(_ release: Release) {
        _ = app.doScript!(self.shellCommands(release), in:nil)

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

    func open(_ release: Release) {
        let sessionClass = app.classForScriptingClass!("session") as! SBiTermSession.Type
        let session = sessionClass.init()

        if app.terminals!().count == 0 {
            let terminalClass = app.classForScriptingClass!("terminal") as! SBiTermTerminal.Type
            let terminal = terminalClass.init()
            app.terminals!().add(terminal)
            terminal.sessions!().add(session)
        } else {
            app.currentTerminal!.sessions!().add(session)
        }
        
        app.currentTerminal!.currentSession!.execCommand!(self.shell as NSString)
        app.currentTerminal!.currentSession!.writeContentsOfFile!(nil, text: self.shellCommands(release))
        
        if !app.frontmost! {
            app.activate()
        }
    }
}
