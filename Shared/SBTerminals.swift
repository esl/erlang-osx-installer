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
    @objc optional func windows() -> SBElementArray
    
    @objc optional var name: String { get }
    @objc optional var version: String { get }
    @objc optional var frontmost: Bool { get }
    
    @objc optional func doScript(_ script: String, in: AnyObject?) -> SBTerminalTab
}
extension SBApplication: SBTerminalApplication {}

// MARK: SBTerminalApplication
@objc public protocol SBTerminalWindow: NSObjectProtocol {
    @objc optional func tabs() -> SBElementArray
    
    @objc optional var name: String { get }
    @objc optional func id() -> Int
    @objc optional var index: String { get set }
    @objc optional var bounds: NSRect { get set }
    @objc optional var selectedTab: SBTerminalTab { get set }
}
extension SBObject: SBTerminalWindow {
}

// MARK: SBTerminalApplication
@objc public protocol SBTerminalTab: NSObjectProtocol {
}
extension SBObject: SBTerminalTab {}

/**************************************************
 * iTerm
 **************************************************/

@objc public protocol SBiTermGenericMethods: NSObjectProtocol {
    @objc optional func execCommand(_ command: NSString)  // Executes a command in a session (attach a trailing space for commands without carriage return)
    @objc optional func launchSession(_ session: NSString?) -> SBiTermSession  // Launches a default or saved session
    @objc optional func writeContentsOfFile(_ contentsOfFile: String?, text: String)
}
extension SBObject: SBiTermGenericMethods {}

@objc public protocol SBiTermItem: SBiTermGenericMethods {
    init()
}
extension SBObject: SBiTermItem {}

// MARK: SBiTermITermApplication
@objc public protocol SBiTermITermApplication: SBApplicationProtocol {
    @objc optional func windows() -> SBElementArray
    @objc optional func documents() -> SBElementArray
    
    @objc optional var name: String { get }
    @objc optional var version: String { get }
    @objc optional var frontmost: Bool { get }
    
    @objc optional func terminals() -> SBElementArray
    @objc optional var currentTerminal: SBiTermTerminal { get }  // currently active terminal
    @objc optional var uriToken: String { get } // URI token
    
    @objc optional func `class`(forScriptingClass className: String) -> Swift.AnyClass?
    
}
extension SBApplication: SBiTermITermApplication {}

@objc public protocol SBiTermTerminal: SBiTermItem {
    @objc optional func sessions() -> SBElementArray
    
    @objc optional var antiAlias: Bool { get }  // Anti alias for window
    @objc optional var currentSession: SBiTermSession { get }   // current session in the terminal
    @objc optional var numberOfColumns: Int { get }  // Number of columns
    @objc optional var numberOfRows: Int { get }  // Number of rows
}
extension SBObject: SBiTermTerminal {}

@objc public protocol SBiTermSession: SBiTermItem {
    @objc optional var contents: String { get }
}
extension SBObject: SBiTermSession {}

@objc public protocol SBiTermWindow: SBiTermItem {
}
extension SBObject: SBiTermWindow {}


