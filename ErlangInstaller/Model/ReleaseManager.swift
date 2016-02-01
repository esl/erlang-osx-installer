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
    
    static func checkNewReleases() throws -> [Release] {
        let content = try manager.fetch()
        let releases = manager.releasesFromString(content)

        let newReleasesNames = Set(releases.keys)
        let diff = newReleasesNames.subtract(manager._releases.keys)
        
        var newReleases: [Release] = []
        for name in diff {
            newReleases.append(releases[name]!)
        }
        
        if newReleases.count > 0 {
            let availableReleasesUrl = Utils.supportResourceUrl(Constants.ReleasesJSONFilename)
            try! manager.fetchSave(availableReleasesUrl!)
        }
        
        return newReleases
    }
    
    private func load() -> [String: Release] {
        let availableReleasesUrl = Utils.supportResourceUrl(Constants.ReleasesJSONFilename)
        
        if(!Utils.fileExists(availableReleasesUrl)) {
            try! fetchSave(availableReleasesUrl!)
        }

        let content = try! String(contentsOfURL: availableReleasesUrl!)
        
        return releasesFromString(content)
    }
    
    private func releasesFromString(content: String) -> [String: Release] {
        var releases = [String: Release]()
        let data = content.dataUsingEncoding(NSUTF8StringEncoding)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
        let releaseNames = json as! [String]
        for name in releaseNames {
            releases[name] =  Release(name: name)
        }

        return releases
    }
    
    private func fetchSave(path : NSURL) throws {
        let content = try self.fetch()
        try self.save(path, content: content)
    }
    
    private func save(path: NSURL, content: String) throws {
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.createDirectoryAtPath(Utils.supportResourceUrl("")!.path!, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFileAtPath(path.path!, contents: nil, attributes: nil)
        
        try content.writeToFile(path.path!, atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    private func fetch() throws -> String {
        if(Utils.resourceAvailable(Constants.ReleasesListUrl)) {
            return try String(contentsOfURL: Constants.ReleasesListUrl!)
        } else {
            throw NSError(domain: "releases", code: 0, userInfo: nil)
        }
    }
}