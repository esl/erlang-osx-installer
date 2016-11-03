
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
        get { return ReleaseManager.manager._releases.values.sort({x, y in x.name < y.name})}
    }
    static var installed : [Release] {
        get { return ReleaseManager.manager._releases.values.filter { $0.installed }.sort({x, y in x.name < y.name})}
    }

    static var releases : [String: Release] {
        get { return ReleaseManager.manager._releases }
    }
    
    private var _releases = [String: Release]()
    
    static var availableReleasesUrl: NSURL? {
        get { return Utils.supportResourceUrl(Constants.ReleasesJSONFilename) }
    }
    
    static func load(onLoaded: () -> Void) {
        ReleaseManager.manager.load(onLoaded)
    }

    static func isInstalled(name : String) -> Bool {
        return Utils.fileExists(Utils.supportResourceUrl(name))
    }
    
    static func checkNewReleases(successHandler: ([Release]) -> Void) {
         manager.fetch() { (content: String) -> Void in
            do {
                let latestReleases = try manager.releasesFromString(content)
                
                let latestReleasesNames = Set(latestReleases.keys)
                let diff = latestReleasesNames.subtract(manager._releases.keys)
                
                var newReleases: [Release] = []
                for name in diff {
                    newReleases.append(latestReleases[name]!)
                }

                manager._releases = latestReleases
                manager.save(content)

                successHandler(newReleases)
            }
            catch let error as NSError
            {
                Utils.alert(error.localizedDescription)
                NSLog("Loading File Error: \(error.debugDescription)")
            }
        }
    }

    private func load(onLoaded: () -> Void) {
        if(!Utils.fileExists(ReleaseManager.availableReleasesUrl)) {
            self.fetchSave() { self.loadFromFile(onLoaded) }
        } else {
            self.loadFromFile(onLoaded)
        }
    }

    private func loadFromFile(onLoaded: () -> Void) {
        do{
            let content = try String(contentsOfURL: ReleaseManager.availableReleasesUrl!)
            self._releases = try releasesFromString(content)
            onLoaded()
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Loading File Error: \(error.debugDescription)")
        }
    }

    private func releasesFromString(content: String) throws -> [String: Release] {
        var releases = [String: Release]()
        let data = content.dataUsingEncoding(NSUTF8StringEncoding)
        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
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
            self.save(content)
            successHandler()
        }
    }
    
    static func makeSymbolicLinks(release: Release) throws
    {
        let fileManager = NSFileManager.defaultManager()
        let filesToLink = ["erl","erlc","escript"]
        
        try filesToLink.forEach
        {
            let destination = "/usr/local/bin/" + $0
            if(fileManager.fileExistsAtPath(destination))
            {
               try fileManager.removeItemAtPath(destination);
            }
            
            try fileManager.createSymbolicLinkAtPath(destination, withDestinationPath: release.binPath + "/" + $0)
        }
    }

    private func save(content: String) {
        do {
            var authRef: AuthorizationRef = nil
            let authFlags = AuthorizationFlags.ExtendRights
            let osStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)

            if(osStatus == errAuthorizationSuccess) {
                let fileManager = NSFileManager.defaultManager()
                try fileManager.createDirectoryAtPath(Utils.supportResourceUrl("")!.path!, withIntermediateDirectories: true, attributes: nil)
                fileManager.createFileAtPath(ReleaseManager.availableReleasesUrl!.path!, contents: nil, attributes: nil)
                
                try content.writeToFile(ReleaseManager.availableReleasesUrl!.path!, atomically: true, encoding: NSUTF8StringEncoding)
            }
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Saving releases list failed: \(error.debugDescription)")
        }
    }
    
    private func fetch(successHandler: (String) -> Void) {
        let stringHandler = {
            do {
                let content = try String(contentsOfURL: Constants.ReleasesListUrl!)
                successHandler(content)
            }
            catch let error as NSError
            {
                Utils.alert(error.localizedDescription)
                NSLog("Loading File Error: \(error.debugDescription)")
                return
            }
        }
        
        let errorHandler = { (error: NSError?) -> Void in
            Utils.alert(error!.localizedDescription)
        }
        
        Utils.resourceAvailable(Constants.ReleasesListUrl, successHandler: stringHandler, errorHandler: errorHandler)
    }
}
