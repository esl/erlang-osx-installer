//
//  Terminal.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/12/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

protocol ErlangTerminal {
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
        terminalsDictionary["iTerm"] = iTerm()
        terminalsDictionary["Terminal"] = Terminal()
    }
}

class Terminal: AnyObject, ErlangTerminal {
    
    let applicationName = "Terminal"
    
    func open(release: Release) {
        let source =
            "tell application \"\(self.applicationName)\"\n" +
                "  activate\n" +
                "  set currentTab to do script (\"set PATH '\(release.binPath)' $PATH\")\n" +
            "end tell\n"
        Utils.execute(source)
    }
}

class iTerm: AnyObject, ErlangTerminal {
    
    let applicationName = "iTerm"
    
    func open(release: Release) {
        let source =
        "tell application \"\(self.applicationName)\"\n" +
        "  activate\n" +
        "  set t to (make new terminal)\n" +
        "  tell t\n" +
        "    set s to (make new session at the end of sessions)\n" +
        "    tell s\n" +
        "      exec command \"set PATH '\(release.binPath)' $PATH\")\n" +
        "    end tell\n" +
        "  end tell\n" +
        "end tell\n"
        Utils.execute(source)
    }
}