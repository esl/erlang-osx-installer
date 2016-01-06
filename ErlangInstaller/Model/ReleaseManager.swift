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
    static let manager = ReleaseManager()

    static var available : [Release] {
        get { return ReleaseManager.manager.releases }
    }
    static var installed : [Release] {
        get { return ReleaseManager.manager.releases.filter { $0.installed } }
    }
    
    static private let ReleasesUrl = NSURL(string: "http://www.erlang.org/download")
    static private let ReleaseRegex = "/download/otp_src_(R?[0-9_.]+?.*?)\\.tar\\.gz"

    private var releases : [Release] = []
    
    private override init() {
        super.init()
        self.releases = load()
    }
    
    func isInstalled(name : String) -> Bool {
        return fileExists(supportResourceUrl(name))
    }
    
    func openTerminal(menuItem : NSMenuItem) {        
        print(menuItem.title)
    }
    
    static func install(releaseName: String) {
        let result = Utils.confirm("Do you want to install Erlang release \(releaseName)?", additionalInfo: "This might take a while.")
        if(result) {
            print("Installing \(releaseName)...")
        }
    }

    static func uninstall(releaseName: String) {
        let result = Utils.confirm("Do you want to uninstall Erlang release \(releaseName)?")
        if(result) {
            print("Uninstalling \(releaseName)...")
        }
    }
    
    private func load() -> [Release] {
        let availableReleasesUrl = supportResourceUrl("available-releases")
        var releases : [Release] = []
        
        if(!fileExists(availableReleasesUrl)) {
            try! fetchSave(availableReleasesUrl!)
        }
        
        let content = try! String(contentsOfURL: availableReleasesUrl!)
        let releaseNames = content.characters.split{ $0 == "\n" }.map(String.init)
        for name in releaseNames {
            releases.append(Release(name: name, installed: isInstalled(name)))
        }
        
        return releases
    }
    
    private func fetchSave(path : NSURL) throws {
        let fileManager = NSFileManager.defaultManager()
        var fileContent = ""
        
        let regex = try NSRegularExpression(pattern: ReleaseManager.ReleaseRegex, options: .CaseInsensitive)
        let content = try String(contentsOfURL: ReleaseManager.ReleasesUrl!)
        let matches = regex.matchesInString(content, options: .WithoutAnchoringBounds, range: NSMakeRange(0, content.characters.count))
        
        try! fileManager.createDirectoryAtPath(supportResourceUrl("")!.path!, withIntermediateDirectories: true, attributes: nil)
        fileManager.createFileAtPath(path.path!, contents: nil, attributes: nil)
        
        for match : NSTextCheckingResult in matches {
            let releaseName = (content as NSString).substringWithRange(match.rangeAtIndex(1))
            fileContent += releaseName + "\n"
        }

        try fileContent.writeToFile(path.path!, atomically: true, encoding: NSUTF8StringEncoding)
    }

    
    private func supportResourceUrl(name : String) -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let appSupportUrl = fileManager.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask).first
        return NSURL(string: "ErlangInstaller/" + name, relativeToURL:  appSupportUrl)
    }
    
    private func fileExists(url : NSURL?) -> Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(url!.path!)
    }

}