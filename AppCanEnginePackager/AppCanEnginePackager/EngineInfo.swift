//
//  EngineInfo.swift
//  AppCanEnginePackager
//
//  Created by CeriNo on 2017/2/9.
//  Copyright © 2017年 AppCan. All rights reserved.
//

import Foundation

enum EngineVersionError: LocalizedError {
    case invalidVersion(String)
    case invalidChangelog(String)
    case invalidPlist(String)
    case verificationFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidVersion(let value):
            return "无效引擎版本：\(value)，必须为三段非负整数，例如4.7.48"
        case .invalidChangelog(let path):
            return "Changelog为空或格式错误：\(path)"
        case .invalidPlist(let path):
            return "引擎Info.plist格式错误或缺少版本字段：\(path)"
        case .verificationFailed(let path):
            return "引擎版本或plist内容核验失败：\(path)"
        }
    }
}

struct Version {
    let major: Int
    let minor: Int
    let build: Int
    static func from(string: String) throws -> Version {
        let nums = string.components(separatedBy: ".")
        guard nums.count == 3 else {
            throw EngineVersionError.invalidVersion(string)
        }
        let values = try nums.map { component -> Int in
            guard !component.isEmpty,
                component.utf8.allSatisfy({ $0 >= 48 && $0 <= 57 }),
                let number = Int(component) else {
                throw EngineVersionError.invalidVersion(string)
            }
            return number
        }
        return Version(major: values[0], minor: values[1], build: values[2])
    }

    // framework、包名和XML都从同一个已解析的版本取值，不混入日期、流水号或suffix。
    var string: String {
        return "\(major).\(minor).\(build)"
    }

    /// 只改实际构建输入的两个版本键；已同步时不重写文件，失败则交由出包入口停止。
    func synchronizeInfoPlist(at url: URL) throws {
        var format = PropertyListSerialization.PropertyListFormat.xml
        let data = try Data(contentsOf: url)
        guard var plist = try PropertyListSerialization.propertyList(from: data, format: &format) as? [String: Any],
            plist["CFBundleShortVersionString"] is String,
            plist["CFBundleVersion"] is String else {
            throw EngineVersionError.invalidPlist(url.path)
        }
        if plist["CFBundleShortVersionString"] as? String != string || plist["CFBundleVersion"] as? String != string {
            plist["CFBundleShortVersionString"] = string
            plist["CFBundleVersion"] = string
            let updated = try PropertyListSerialization.data(fromPropertyList: plist, format: format, options: 0)
            try updated.write(to: url, options: .atomic)
        }
        // 读回全部字段，既核验版本，也防止其他plist配置在写入时发生变化。
        let verified = try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
        guard (verified as? NSDictionary)?.isEqual(plist as NSDictionary) == true else {
            throw EngineVersionError.verificationFailed(url.path)
        }
    }

    /// 封包前核验基础工程实际使用的framework，避免旧产物带着新包名交付。
    func verifyInfoPlist(at url: URL) throws {
        let value = try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil)
        guard let plist = value as? [String: Any],
            plist["CFBundleShortVersionString"] as? String == string,
            plist["CFBundleVersion"] as? String == string else {
            throw EngineVersionError.verificationFailed(url.path)
        }
    }
}



extension Version: Comparable{
    public static func ==(lhs: Version, rhs: Version) -> Bool{
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.build == rhs.build
    }
    public static func <(lhs: Version, rhs: Version) -> Bool {
        return (lhs.major, lhs.minor, lhs.build) < (rhs.major, rhs.minor, rhs.build)
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

    
    static func parseChangelog() throws -> (version: Version,summary: String){
        let changelogURL = rootURL.appendingPathComponent("AppCanEngine").appendingPathComponent("Changelog.plist")
        print(changelogURL.path)
        let plistData = try Data(contentsOf: changelogURL)
        let plist = try PropertyListSerialization.propertyList(from: plistData, format: nil)
        guard let dict = plist as? [String: [String]], !dict.isEmpty else {
            throw EngineVersionError.invalidChangelog(changelogURL.path)
        }
        // 每个条目仅解析一次，拒绝把格式错误的版本静默转换成0。
        let entries = try dict.map { (version: try Version.from(string: $0.key), summary: $0.value.joined(separator: ";")) }
        return entries.max { $0.version < $1.version }!
    }

    static func resolveVersion(versionString: String?, summary: String?) throws -> (version: Version, summary: String) {
        // 保留旧优先级：非空version与summary同时提供时覆盖，否则读取Changelog。
        if
            let versionString = versionString,
            let summary = summary,
            !versionString.isEmpty{
            return (try Version.from(string: versionString), summary)
        }
        return try parseChangelog()
    }

    // 版本解析和plist同步完成后只创建一次，避免一个包重复递增当日流水号。
    init(version: Version, summary: String, suffix: String?) {
        self.version = version
        self.description = summary
        if let suffix = suffix,!suffix.isEmpty{
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


