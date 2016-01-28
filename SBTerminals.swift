//
//  SBTerminal.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/19/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import ScriptingBridge

// MARK: SBTerminalApplication
@objc public protocol SBTerminalApplication: SBApplicationProtocol {
    optional func windows() -> SBElementArray

    optional var name: String { get }
    optional var version: String { get }
    optional var frontmost: Bool { get }

    optional func doScript(script: String, `in`: AnyObject?) -> SBTerminalTab
}
extension SBApplication: SBTerminalApplication {}

// MARK: SBTerminalApplication
@objc public protocol SBTerminalWindow: SBObjectProtocol {
    optional func tabs() -> SBElementArray

    optional var name: String { get }
    optional func id() -> Int
    optional var index: String { get set }
    optional var bounds: NSRect { get set }
    optional var selectedTab: SBTerminalTab { get set }
}
extension SBObject: SBTerminalWindow {}

// MARK: SBTerminalApplication
@objc public protocol SBTerminalTab: SBObjectProtocol {
}
extension SBObject: SBTerminalTab {}

/**************************************************
 * iTerm
 **************************************************/

@objc public protocol SBiTermGenericMethods: SBObjectProtocol {
    optional func execCommand(command: NSString)  // Executes a command in a session (attach a trailing space for commands without carriage return)
    optional func launchSession(session: NSString?) -> SBiTermSession  // Launches a default or saved session
    optional func writeContentsOfFile(contentsOfFile: String?, text: String)
}
extension SBObject: SBiTermGenericMethods {}

@objc public protocol SBiTermItem: SBiTermGenericMethods {
    init()
}
extension SBObject: SBiTermItem {}

// MARK: SBiTermITermApplication
@objc public protocol SBiTermITermApplication: SBApplicationProtocol {
    optional func windows() -> SBElementArray
    optional func documents() -> SBElementArray

    optional var name: String { get }
    optional var version: String { get }
    optional var frontmost: Bool { get }
    optional var running: Bool { get }
    
    optional func terminals() -> SBElementArray
    optional var currentTerminal: SBiTermTerminal { get }  // currently active terminal
    optional var uriToken: String { get } // URI token

    optional func classForScriptingClass(className: String) -> AnyClass?
}
extension SBApplication: SBiTermITermApplication {}

@objc public protocol SBiTermTerminal: SBiTermItem {
    optional func sessions() -> SBElementArray

    optional var antiAlias: Bool { get }  // Anti alias for window
    optional var currentSession: SBiTermSession { get }   // current session in the terminal
    optional var numberOfColumns: Int { get }  // Number of columns
    optional var numberOfRows: Int { get }  // Number of rows
}
extension SBObject: SBiTermTerminal {}

@objc public protocol SBiTermSession: SBiTermItem {
    optional var contents: String { get }
}
extension SBObject: SBiTermSession {}

@objc public protocol SBiTermWindow: SBiTermItem {
}
extension SBObject: SBiTermWindow {}


