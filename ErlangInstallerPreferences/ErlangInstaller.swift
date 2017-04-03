//
//  ErlangInstaller.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/15/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import ScriptingBridge

@objc public protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    @objc optional var running: Bool { get }
    var delegate: SBApplicationDelegate! { get set }
}

// MARK: SystemPreferencesApplication
@objc public protocol ErlangInstallerApplication: SBApplicationProtocol {
    @objc optional func update()
    @objc optional func checkNewReleases()
}
extension SBApplication: ErlangInstallerApplication {}
