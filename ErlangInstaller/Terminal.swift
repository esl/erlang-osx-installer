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

    func open(release: Release) {
        let app = SBApplication(bundleIdentifier: self.applicationId) as! SBTerminalApplication
        let erl = release.binPath.stringByReplacingOccurrencesOfString(" ", withString: "\\\\ ") + "/erl"
        if app.windows!().count == 0 {
            app.doScript!("bash -c '\(erl)'", `in`: nil)
        } else {
            let window = app.windows!().firstObject
            app.doScript!("bash -c '\(erl)'", `in`: window)
        }

        app.activate()
    }
}

class iTerm: AnyObject, ErlangTerminal {

    var applicationName: String { get { return "iTerm" } }
    var applicationId: String { get { return "com.googlecode.iterm2" } }

    func open(release: Release) {
        let erl = release.binPath.stringByReplacingOccurrencesOfString(" ", withString: "\\\\ ") + "/erl"
        let source =
        "tell application \"\(self.applicationName)\"\n" +
        "  activate\n" +
        "  set t to (make new terminal)\n" +
        "  tell t\n" +
        "    set s to (make new session at the end of sessions)\n" +
        "    tell s\n" +
        "      exec command \"bash -c '\(erl)'\"\n" +
        "    end tell\n" +
        "  end tell\n" +
        "end tell\n"
        Utils.execute(source)
    }
}