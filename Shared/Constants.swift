//
//  Constants.swift
//  ErlangInstaller
//
//  Created by Juan Facorro on 1/7/16.
//  Copyright © 2016 Erlang Solutions. All rights reserved.
//

import Cocoa

class ConstantsLoader {
    static func getBundle() -> Bundle?
    {
        let bundle = Bundle.main
        
        if(bundle.bundleIdentifier == Constants.applicationId)
        {
            return bundle
        }
        else
        {
            _ = Bundle.allBundles
        }
        
        return nil
    }
    
    static func getUrl(_ key: String) -> URL? {
        
        if let bundle = ConstantsLoader.getBundle()
        {
            if let url = bundle.object(forInfoDictionaryKey: key) as? String
            {
                Utils.log("Loading url for \(key): \(url)")
                return URL(string: url)
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
    static let ErlangEslInstallationDir = URL(fileURLWithPath: "/usr/local/lib/erlang/")
}
