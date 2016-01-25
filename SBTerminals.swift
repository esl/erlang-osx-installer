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


// MARK: SBiTermITermApplication
@objc public protocol SBiTermITermApplication: SBApplicationProtocol {
    optional var name: String { get }
    optional var version: String { get }
}
extension SBApplication: SBiTermITermApplication {}