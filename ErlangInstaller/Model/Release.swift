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
    var installed: Bool {
        get { return ReleaseManager.isInstalled(self.name) }
    }
    var binPath : String {
        get { return Utils.supportResourceUrl("\(self.name)/bin")!.path! }
    }
    
    init(name: String){
        self.name = name
    }
}