//
//  Terminal.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/12/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation
import ScriptingBridge

protocol ErlangTerminal {
    var applicationName: String { get }
    var applicationId: String { get }
    func open(release: Release)
}

class TerminalApplications {
    private static let terminalsInstance = TerminalApplications()
    static var shell: String {
        get { return NSProcessInfo.processInfo().environment["SHELL"] ?? "bash" }
    }
    
    static var terminals: [String: ErlangTerminal] {
        get {
            return terminalsInstance.terminalsDictionary
        }
    }
    
    private var terminalsDictionary = [String: ErlangTerminal]()

    init() {
        let allTerminals: [ErlangTerminal] = [iTerm(), Terminal()]
        for terminal in allTerminals {
            terminalsDictionary[terminal.applicationName] = terminal
        }
    }
}

class Terminal: AnyObject, ErlangTerminal {
    var applicationName: String { get { return "Terminal" } }
    var applicationId: String { get { return "com.apple.Terminal" } }
    var app: SBTerminalApplication {
        get {
            return SBApplication(bundleIdentifier: self.applicationId) as! SBTerminalApplication
        }
    }

    func open(release: Release) {
        let erl = release.binPath.stringByReplacingOccurrencesOfString(" ", withString: "\\ ")
        let command = "bash"

        app.doScript!(command, `in`: nil)
        let window = app.windows!().firstObject

        app.doScript!("export PATH=\(erl):$PATH", `in`: window!)
        // app.doScript!(TerminalApplications.shell, `in`: window!)
        app.doScript!("clear; erl", `in`: window!)

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
        let erlPath = release.binPath.stringByReplacingOccurrencesOfString(" ", withString: "\\ ")
        let command = "bash "
        
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
        
        app.currentTerminal!.currentSession!.execCommand!(command)
        app.currentTerminal!.currentSession!.writeContentsOfFile!(nil, text: "export PATH=\(erlPath):$PATH")
        app.currentTerminal!.currentSession!.writeContentsOfFile!(nil, text: TerminalApplications.shell)
        app.currentTerminal!.currentSession!.writeContentsOfFile!(nil, text: "clear; erl")
        
        if !app.frontmost! {
            app.activate()
        }
    }
}