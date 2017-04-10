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
    var path: String

    var installed: Bool {
        get { return ReleaseManager.isInstalled(self.name) }
    }
    var binPath : String {
        get { return Utils.supportResourceUrl("\(self.name)/bin")!.path }
    }
    var releasePath : String {
        get { return Utils.supportResourceUrl("\(self.name)")!.path }
    }
    init(name: String, path: String){
        self.name = name
        self.path = path
    }
}
