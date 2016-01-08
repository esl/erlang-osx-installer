//
//  ReleaseManager.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/5/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Foundation
import Cocoa

class ReleaseManager: NSObject {
    private static let manager = ReleaseManager()

    static var available : [Release] {
        get { return ReleaseManager.manager._releases.values.filter { _ in true }.sort({x, y in x.name < y.name})}
    }
    static var installed : [Release] {
        get { return ReleaseManager.manager._releases.values.filter { $0.installed } }
    }

    static var releases : [String: Release] {
        get { return ReleaseManager.manager._releases }
    }
    
    private var _releases = [String: Release]()
    
    private override init() {
        super.init()
        self._releases = load()
    }
    
    static func isInstalled(name : String) -> Bool {
        return Utils.fileExists(Utils.supportResourceUrl(name))
    }
    
    static func openTerminal(releaseName: String) {
        print(releaseName)
    }
    
    private func load() -> [String: Release] {
        let availableReleasesUrl = Utils.supportResourceUrl(Constants.ReleasesJSONFilename)
        var releases = [String: Release]()
        
        if(!Utils.fileExists(availableReleasesUrl)) {
            try! fetchSave(availableReleasesUrl!)
        }

        let content = try! String(contentsOfURL: availableReleasesUrl!)
        let data = content.dataUsingEncoding(NSUTF8StringEncoding)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
        let releaseNames = json as! [String]
        for name in releaseNames {
            releases[name] =  Release(name: name, installed: ReleaseManager.isInstalled(name))
        }
        
        return releases
    }
    
    private func fetchSave(path : NSURL) throws {
        let fileManager = NSFileManager.defaultManager()
        
        let content = try String(contentsOfURL: Constants.ReleasesListUrl!)
        
        try! fileManager.createDirectoryAtPath(Utils.supportResourceUrl("")!.path!, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFileAtPath(path.path!, contents: nil, attributes: nil)
        
        try content.writeToFile(path.path!, atomically: true, encoding: NSUTF8StringEncoding)
    }
}