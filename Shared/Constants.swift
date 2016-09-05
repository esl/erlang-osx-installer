//
//  Constants.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ConstantsLoader {
    static func getBundle() -> NSBundle?
    {
        let bundle = NSBundle.mainBundle()
        
        if(bundle.bundleIdentifier == Constants.applicationId)
        {
            return bundle
        }
        else
        {
            let bundles = NSBundle.allBundles()
            
//            let filteredBundles = bundles.filter({ (bundle: NSBundle) -> Bool in
//                return bundle.bundleIdentifier == Constants.ErlangInstallerPreferencesId
//            })
			
//            if(filteredBundles.count > 0)
//            {
//                return filteredBundles.first
//            }
        }
        
        return nil
    }
    
    static func getUrl(key: String) -> NSURL? {
        
        if let bundle = ConstantsLoader.getBundle()
        {
            if let url = bundle.objectForInfoDictionaryKey(key) as? String
            {
                Utils.log("Loading url for \(key): \(url)")
                return NSURL(string: url)
            }
        }
        
        return nil
    }
}

class Constants {
    static let ReleasesListUrl = ConstantsLoader.getUrl("ReleasesUrl")
    static let BaseTarballsUrl = ConstantsLoader.getUrl("BaseTarballUrl")
    static let ReleasesJSONFilename = "available-releases.json"
    static let applicationId = "com.erlang-solutions.ErlangInstaller"
    
    // Package installation
    static let ErlangEslInstallationDir = NSURL(fileURLWithPath: "/usr/local/lib/erlang/")
}