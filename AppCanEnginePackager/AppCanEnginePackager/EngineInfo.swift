//
//  EngineInfo.swift
//  AppCanEnginePackager
//
//  Created by CeriNo on 2017/2/9.
//  Copyright © 2017年 AppCan. All rights reserved.
//

import Foundation

struct Version {
    let major: Int
    let minor: Int
    let build: Int
    static func from(string: String) -> Version {
        var helper = [0,0,0]
        let nums = string.components(separatedBy: ".")
        for i in 0..<3 {
            guard i < nums.count else {
                break
            }
            helper[i] = Int(nums[i]) ?? 0
        }
        return Version(major: helper[0], minor: helper[1], build: helper[2])
    }
}



extension Version: Comparable{
    private var versionNumber: Int{
        get {
            return build + minor * 10000 + major * 1000000
        }
    }
    public static func ==(lhs: Version, rhs: Version) -> Bool{
        return lhs.versionNumber == rhs.versionNumber
    }
    public static func <(lhs: Version, rhs: Version) -> Bool {
        return lhs.versionNumber < rhs.versionNumber
    }
}


struct EngineInfo {
    let suffix: String
    let version: Version
    let description: String
    let buildNumber: Int
    let date: String
}

extension EngineInfo{

    
    static func parseChangelog() -> (version: Version,summary: String){
        let changelogURL = rootURL.appendingPathComponent("AppCanEngine").appendingPathComponent("Changelog.plist")
        let fm = FileManager.default
        print(changelogURL.path)
        guard fm.fileExists(atPath: changelogURL.path) else{
            fatalError("Changelog.plist not exist")
        }
        guard
            let plistData = try? Data(contentsOf: changelogURL),
            let plist = (try? PropertyListSerialization.propertyList(from: plistData, format: nil))
            else{
                fatalError("Changelog.plist Invalid!")
        }

        guard let dict = plist as? [String: [String]] else{
            fatalError("Changelog.plist format error!")
        }
        
        let lastVersion = Array(dict.keys).sorted {
            Version.from(string: $0) < Version.from(string: $1)
        }.last!
        let version = Version.from(string: lastVersion)
        let summary = dict[lastVersion]!.joined(separator: ";")
        return (version,summary)
    }
    
    init(versionString: String?,summary: String?,suffix: String?) {
        if
            let versionString = versionString,
            let summary = summary,
            versionString.characters.count > 0{
            version = Version.from(string: versionString)
            description = summary
        }else{
            (version,description) = EngineInfo.parseChangelog()
        }
        if let suffix = suffix,suffix.characters.count > 0{
            self.suffix = "_\(suffix)"
        }else{
            self.suffix = ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        let date = formatter.string(from: Date())
        self.date = date
        
        let lastBuildDateKey = "kLastBuildDate"
        let buildNumberKey = "kBuildNumber"
        let ud = UserDefaults.standard
        
        
        guard let lastBuildDate = ud.string(forKey: lastBuildDateKey),lastBuildDate == date else{
            ud.set(date, forKey: lastBuildDateKey)
            ud.set(1, forKey: buildNumberKey)
            buildNumber = 1
            return
        }
        let number = ud.integer(forKey: buildNumberKey) + 1
        ud.set(number, forKey: buildNumberKey)
        buildNumber = number
    }
}


extension EngineInfo{
    
    var build: String{
        get{
            return buildNumber < 10 ? "0\(self.buildNumber)" : "\(buildNumber)"
        }
    }
    
    var package: String{
        get{
            return "iOS_Engine_\(version.major).\(version.minor).\(version.build)_\(date)_\(build)\(suffix)"
        }
    }
    private var dssVersion: String{
        get {
            return "4.0.0"
        }
    }
    private var versionString: String{
        get{
            return "sdksuit_\(version.major).\(version.minor)_\(date)_\(build)\(suffix)"
        }
    }
    

    
    func XMLInfo() -> String{
        var xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
        xml += "<info>\n"
        xml += "\t<version>\(versionString)</version>\n"
        xml += "\t<package>\(package)</package>\n"
        xml += "\t<description>\(description)</description>\n"
        xml += "\t<dssVersion>\(dssVersion)</dssVersion>\n"
        xml += "</info>"
        return xml
    }
    
}


