
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
    
    private var availableReleasesUrl: NSURL? {
        get { return Utils.supportResourceUrl(Constants.ReleasesJSONFilename) }
    }
    
    static func load(onLoaded: () -> Void) {
        ReleaseManager.manager.load(onLoaded)
    }

    static func isInstalled(name : String) -> Bool {
        return Utils.fileExists(Utils.supportResourceUrl(name))
    }
    
    static func checkNewReleases(successHandler: ([Release]) -> Void) throws {
        manager.fetch() { (content: String) -> Void in
            let latestReleases = manager.releasesFromString(content)
            
            let latestReleasesNames = Set(latestReleases.keys)
            let diff = latestReleasesNames.subtract(manager._releases.keys)
            
            var newReleases: [Release] = []
            for name in diff {
                newReleases.append(latestReleases[name]!)
            }

            if newReleases.count > 0 {
                manager._releases = latestReleases
                try! manager.save(content)
            }

            successHandler(newReleases)
        }
    }

    private func load(onLoaded: () -> Void) {
        if(!Utils.fileExists(availableReleasesUrl)) {
            self.fetchSave() { self.loadFromFile(onLoaded) }
        } else {
            self.loadFromFile(onLoaded)
        }
    }

    private func loadFromFile(onLoaded: () -> Void) {
        let content = try! String(contentsOfURL: self.availableReleasesUrl!)
        self._releases = releasesFromString(content)
        onLoaded()
    }

    private func releasesFromString(content: String) -> [String: Release] {
        var releases = [String: Release]()
        let data = content.dataUsingEncoding(NSUTF8StringEncoding)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
        if let releasesJson = json as? [[String: AnyObject]]
        {
            for releaseJson in releasesJson {
                let name = releaseJson["version"] as? String ?? "Missing version"
                let path = releaseJson["path"] as? String ?? "Missing path"
                releases[name] =  Release(name: name, path: path)
            }
        }

        return releases
    }
    
    private func fetchSave(successHandler: () -> Void) {
        self.fetch() { (content: String) -> Void in
            try! self.save(content)
            successHandler()
        }
    }

    private func save(content: String) throws {
        let fileManager = NSFileManager.defaultManager()
        try! fileManager.createDirectoryAtPath(Utils.supportResourceUrl("")!.path!, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFileAtPath(self.availableReleasesUrl!.path!, contents: nil, attributes: nil)
        
        try content.writeToFile(self.availableReleasesUrl!.path!, atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    private func fetch(successHandler: (String) -> Void) {
        let stringHandler = {
            let content = try! String(contentsOfURL: Constants.ReleasesListUrl!)
            successHandler(content)
        }
        let errorHandler = { (error: NSError?) -> Void in
            Utils.alert(error!.localizedDescription)
        }
        Utils.resourceAvailable(Constants.ReleasesListUrl, successHandler: stringHandler, errorHandler: errorHandler)
    }
}