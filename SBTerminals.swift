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
    optional func update()
}
extension SBApplication: SBTerminalApplication {}

// MARK: SBiTermITermApplication
@objc public protocol SBiTermITermApplication: SBApplicationProtocol {
    optional func update()
}
extension SBApplication: SBiTermITermApplication {}