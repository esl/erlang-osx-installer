
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
    fileprivate static let manager = ReleaseManager()

    static var available : [Release] {
        get { return ReleaseManager.manager._releases.values.sorted(by: {x, y in x.name < y.name})}
    }
    static var installed : [Release] {
        get { return ReleaseManager.manager._releases.values.filter { $0.installed }.sorted(by: {x, y in x.name < y.name})}
    }

    static var releases : [String: Release] {
        get { return ReleaseManager.manager._releases }
    }
    
    fileprivate var _releases = [String: Release]()
    
    static var availableReleasesUrl: URL? {
        get { return Utils.supportResourceUrl(Constants.ReleasesJSONFilename) }
    }
    
    static func load(_ onLoaded: @escaping () -> Void) {
        ReleaseManager.manager.load(onLoaded)
    }

    static func isInstalled(_ name : String) -> Bool {
        return Utils.fileExists(Utils.supportResourceUrl(name))
    }
    
    static func checkNewReleases(_ successHandler: @escaping ([Release]) -> Void) {
         manager.fetch() { (content: String) -> Void in
            do {
                let latestReleases = try manager.releasesFromString(content)
                
                let latestReleasesNames = Set(latestReleases.keys)
                let diff = latestReleasesNames.subtracting(manager._releases.keys)
                
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

    fileprivate func load(_ onLoaded: @escaping () -> Void) {
        if(!Utils.fileExists(ReleaseManager.availableReleasesUrl)) {
            self.fetchSave() { self.loadFromFile(onLoaded) }
        } else {
            self.loadFromFile(onLoaded)
        }
    }

    fileprivate func loadFromFile(_ onLoaded: () -> Void) {
        do{
            let content = try String(contentsOf: ReleaseManager.availableReleasesUrl!)
            self._releases = try releasesFromString(content)
            onLoaded()
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Loading File Error: \(error.debugDescription)")
        }
    }

    fileprivate func releasesFromString(_ content: String) throws -> [String: Release] {
        var releases = [String: Release]()
        let data = content.data(using: String.Encoding.utf8)
        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
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
    
    fileprivate func fetchSave(_ successHandler: @escaping () -> Void) {
        self.fetch() { (content: String) -> Void in
            self.save(content)
            successHandler()
        }
    }
    
    static func makeSymbolicLinks(_ release: Release) throws
    {
        let fileManager = FileManager.default
        let filesToLink = ["default"]
        
        try filesToLink.forEach
            {
                let destination = NSHomeDirectory() + "/.erlangInstaller/" + $0
                
                do {
                    try fileManager.attributesOfItem(atPath: destination)
                    do {
                        try fileManager.removeItem(atPath: destination);
                    }catch let errorDelete as NSError {
                        print("\(errorDelete.localizedDescription)")
                    }
                    
                } catch let errorExists as NSError {
                    print("\(errorExists.localizedDescription)")
                }
                
                try fileManager.createSymbolicLink(atPath: destination, withDestinationPath: release.binPath )
                
                // Ensure PATH
                guard let  scriptPath = Bundle.main.path(forResource: "EnsurePATH",ofType:"command") else {
                    NSLog("Unable to locate EnsurePath.command")
                    return
                }
                
                let task = Process()
                
                task.launchPath = "/bin/sh"
                task.arguments = [scriptPath]
                
                task.launch()
                task.waitUntilExit()
                
            
        }
    }
    
    fileprivate func save(_ content: String) {
        do {
            var authRef: AuthorizationRef? = nil
            let authFlags = AuthorizationFlags.extendRights
            let osStatus = AuthorizationCreate(nil, nil, authFlags, &authRef)

            if(osStatus == errAuthorizationSuccess) {
                let fileManager = FileManager.default
                try fileManager.createDirectory(atPath: Utils.supportResourceUrl("")!.path, withIntermediateDirectories: true, attributes: nil)
                fileManager.createFile(atPath: ReleaseManager.availableReleasesUrl!.path, contents: nil, attributes: nil)
                
                try content.write(toFile: ReleaseManager.availableReleasesUrl!.path, atomically: true, encoding: String.Encoding.utf8)
            }
        }
        catch let error as NSError
        {
            Utils.alert(error.localizedDescription)
            NSLog("Saving releases list failed: \(error.debugDescription)")
        }
    }
    
    fileprivate func fetch(_ successHandler: @escaping (String) -> Void) {
        let stringHandler = {
            do {
                let content = try String(contentsOf: Constants.ReleasesListUrl!)
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
