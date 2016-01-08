//
//  Release.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/4/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation

class Release: AnyObject {    
    var name: String
    var installed: Bool
    
    init(name: String, installed: Bool){
        self.name = name
        self.installed = installed
    }
}