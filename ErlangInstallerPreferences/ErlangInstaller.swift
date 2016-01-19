//
//  ErlangInstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import ScriptingBridge

@objc public protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> AnyObject!
}

@objc public protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    var delegate: SBApplicationDelegate! { get set }
}

// MARK: SystemPreferencesApplication
@objc public protocol ErlangInstallerApplication: SBApplicationProtocol {
    optional func update()
}
extension SBApplication: ErlangInstallerApplication {}