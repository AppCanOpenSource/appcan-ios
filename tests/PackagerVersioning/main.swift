import Foundation

// 与EngineInfo.swift一起编译；所有夹具放在命令行指定的隔离目录。
var rootURL = URL(fileURLWithPath: CommandLine.arguments[1])
let fm = FileManager.default
try fm.createDirectory(at: rootURL.appendingPathComponent("AppCanEngine"), withIntermediateDirectories: true)
var assertions = 0

func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    precondition(condition(), message)
    assertions += 1
}

func rejects(_ message: String, _ action: () throws -> Void) {
    do {
        try action()
        preconditionFailure("应当拒绝：\(message)")
    } catch {
        assertions += 1
    }
}

func writePlist(_ value: Any, to url: URL, format: PropertyListSerialization.PropertyListFormat = .xml) throws {
    let data = try PropertyListSerialization.data(fromPropertyList: value, format: format, options: 0)
    try data.write(to: url)
}

let changelog = rootURL.appendingPathComponent("AppCanEngine/Changelog.plist")
try writePlist(["4.6.47": ["旧版本"], "4.7.48": ["新版本", "说明"]], to: changelog)
let resolved = try EngineInfo.resolveVersion(versionString: "", summary: "")
check(resolved.version.string == "4.7.48", "默认取Changelog最高版本")
check(resolved.summary == "新版本;说明", "保留说明拼接语义")
let override = try EngineInfo.resolveVersion(versionString: "4.7.49", summary: "覆盖")
check(override.version.string == "4.7.49" && override.summary == "覆盖", "显式覆盖优先")
let fallback = try EngineInfo.resolveVersion(versionString: "4.7.49", summary: nil)
check(fallback.version == resolved.version, "缺少summary时保留旧回退语义")
for invalid in ["", "4", "4.7", "4.7.48.1", "4.a.48", "4.-7.48", "4.7.48beta", " 4.7.48", "４.7.48", "4.7.999999999999999999999999999999"] {
    rejects(invalid) { _ = try Version.from(string: invalid) }
}
rejects("无效显式覆盖") { _ = try EngineInfo.resolveVersion(versionString: "4.x.48", summary: "") }
try writePlist([String: [String]](), to: changelog)
rejects("空Changelog") { _ = try EngineInfo.resolveVersion(versionString: nil, summary: nil) }
try writePlist(["4.7.48": ["正常"], "bad": ["无效"]], to: changelog)
rejects("无效Changelog版本键") { _ = try EngineInfo.resolveVersion(versionString: nil, summary: nil) }
try writePlist(["4.7.48": "不是数组"], to: changelog)
rejects("无效Changelog结构") { _ = try EngineInfo.resolveVersion(versionString: nil, summary: nil) }
try fm.removeItem(at: changelog)
let noChangelog = try EngineInfo.resolveVersion(versionString: "4.7.49", summary: "")
check(noChangelog.version == override.version, "显式覆盖不额外读取Changelog")
rejects("Changelog缺失") { _ = try EngineInfo.resolveVersion(versionString: nil, summary: nil) }

let original: [String: Any] = ["CFBundleShortVersionString": "4.6.45", "CFBundleVersion": "4.6.45", "CFBundleIdentifier": "com.test.engine", "Other": ["Enabled": true, "Array": [1, 2, 3]]]
for (name, format) in [("xml", PropertyListSerialization.PropertyListFormat.xml), ("binary", .binary)] {
    let url = rootURL.appendingPathComponent("\(name).plist")
    try writePlist(original, to: url, format: format)
    try resolved.version.synchronizeInfoPlist(at: url)
    var actualFormat = PropertyListSerialization.PropertyListFormat.xml
    let value = try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: &actualFormat) as! [String: Any]
    var expected = original
    expected["CFBundleVersion"] = "4.7.48"
    expected["CFBundleShortVersionString"] = "4.7.48"
    check((value as NSDictionary).isEqual(expected as NSDictionary), "只改两个字段")
    check(actualFormat == format, "保留plist格式")
    let before = try Data(contentsOf: url)
    let modified = try fm.attributesOfItem(atPath: url.path)[.modificationDate] as! Date
    try resolved.version.synchronizeInfoPlist(at: url)
    let after = try Data(contentsOf: url)
    let unchanged = try fm.attributesOfItem(atPath: url.path)[.modificationDate] as! Date
    check(before == after && modified == unchanged, "重复同步不重写文件")
    try resolved.version.verifyInfoPlist(at: url)
    rejects("framework版本不符") { try override.version.verifyInfoPlist(at: url) }
}
let invalidPlist = rootURL.appendingPathComponent("invalid.plist")
try writePlist(["CFBundleVersion": "4.6.45"], to: invalidPlist)
rejects("缺版本键") { try resolved.version.synchronizeInfoPlist(at: invalidPlist) }
try Data("not a plist".utf8).write(to: invalidPlist)
rejects("损坏plist") { try resolved.version.synchronizeInfoPlist(at: invalidPlist) }
rejects("plist不存在") { try resolved.version.synchronizeInfoPlist(at: rootURL.appendingPathComponent("missing.plist")) }
let locked = rootURL.appendingPathComponent("locked")
try fm.createDirectory(at: locked, withIntermediateDirectories: true)
let lockedPlist = locked.appendingPathComponent("Info.plist")
try writePlist(original, to: lockedPlist)
try fm.setAttributes([.posixPermissions: 0o555], ofItemAtPath: locked.path)
rejects("原子写入失败") { try resolved.version.synchronizeInfoPlist(at: lockedPlist) }
try fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: locked.path)

// 独立测试进程使用自己的偏好域，不在正式出包器bundle中运行此测试入口。
precondition(Bundle.main.bundleIdentifier == nil && ProcessInfo.processInfo.processName == "VersioningTests")
let defaults = UserDefaults.standard
let formatter = DateFormatter()
formatter.dateFormat = "yyMMdd"
defaults.set(formatter.string(from: Date()), forKey: "kLastBuildDate")
defaults.set(40, forKey: "kBuildNumber")
let info = EngineInfo(version: resolved.version, summary: resolved.summary, suffix: "test")
check(info.buildNumber == 41 && defaults.integer(forKey: "kBuildNumber") == 41, "一次创建只增加一次流水号")
try resolved.version.synchronizeInfoPlist(at: rootURL.appendingPathComponent("xml.plist"))
check(defaults.integer(forKey: "kBuildNumber") == 41, "重复同步不增加流水号")
check(info.package == "iOS_Engine_4.7.48_\(info.date)_41_test", "包名版本、日期、流水与suffix保持格式")
check(info.XMLInfo().contains("<version>sdksuit_4.7_\(info.date)_41_test</version>"), "XML保持sdksuit约定")
check(info.XMLInfo().contains("<package>\(info.package)</package>"), "XML与包名共用版本")
print("PASS: \(assertions) assertions")
