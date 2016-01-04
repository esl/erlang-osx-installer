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
    
    init(name: String){
        self.name = name
    }
    
    static private var releases: [Release] = []

    static func loadAll() {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        print(paths.first)
    }
}