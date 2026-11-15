//
//  main.swift
//  AppCanEnginePackager
//
//  Created by CeriNo on 2017/2/8.
//  Copyright © 2017年 AppCan. All rights reserved.
//

import Foundation
import LzmaSDK_ObjC
import Swiftline
import Zip


var rootURL: URL


let args = Args.parsed.flags
guard let srcPath = args["src"] else{
    fatalError("Invalid Args")
}
rootURL = URL(fileURLWithPath: srcPath).deletingLastPathComponent()
guard rootURL.lastPathComponent == "appcan-ios" else{
    fatalError("Invalid rootURL, root dir must be appcan-ios")
}

let useModernBuildSystem = args["useModernBuildSystem"]!;

//MARK: - build engine
let engineBuildCommand: (String, String) throws -> Void = { command, derivedDataPath in
    let xcodebuild = XcodeBuild(path: .workspace(path: "AppCanEngine.xcworkspace"),
                                command: command,
                                configuration: "Release",
                                scheme: "AppCanEngine",
                                sdk: "iphoneos",
                                currentDirectoryPath: rootURL.path,
                                useModernBuildSystem: useModernBuildSystem,
                                derivedDataPath: derivedDataPath,
                                destination: "generic/platform=iOS")
    try xcodebuild.runSync()
}

enum FrameworkSymbolError: LocalizedError {
    case missing(String)
    case invalid(String)
    case mismatch(String, String, String)

    var errorDescription: String? {
        switch self {
        case .missing(let path): return "缺少引擎框架或dSYM：\(path)"
        case .invalid(let path): return "无法读取非空arm64 UUID：\(path)"
        case .mismatch(let name, let binary, let symbol):
            return "\(name)框架与dSYM UUID不一致：\(binary) / \(symbol)"
        }
    }
}

/// dSYM在目标的构建脚本结束后才由Xcode生成，必须等整个xcodebuild返回再取同批产物。
func arm64UUID(at url: URL) throws -> String {
    let fm = FileManager.default
    guard fm.fileExists(atPath: url.path) else { throw FrameworkSymbolError.missing(url.path) }
    let size = (try fm.attributesOfItem(atPath: url.path)[.size] as? NSNumber)?.int64Value ?? 0
    guard size > 0 else { throw FrameworkSymbolError.invalid(url.path) }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    process.arguments = ["dwarfdump", "--uuid", url.path]
    let output = Pipe()
    process.standardOutput = output
    process.standardError = Pipe()
    try process.run()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    let lines = String(data: data, encoding: .utf8)?.components(separatedBy: .newlines) ?? []
    let uuids = lines.filter { $0.contains("(arm64)") }.compactMap { line -> String? in
        guard let start = line.range(of: "UUID: "), let end = line.range(of: " (arm64)") else { return nil }
        return String(line[start.upperBound..<end.lowerBound])
    }
    guard process.terminationStatus == 0, uuids.count == 1 else {
        throw FrameworkSymbolError.invalid(url.path)
    }
    return uuids[0]
}

func synchronizeReleaseFrameworks(from products: URL, to root: URL) throws {
    let fm = FileManager.default
    let names = ["AppCanEngine", "AppCanKit", "Ono", "pop"]
    let prebuiltSymbols = root.appendingPathComponent("AppCanEnginePackager/PrebuiltSymbols", isDirectory: true)
    let symbols = root.appendingPathComponent("dSYM", isDirectory: true)

    // Ono/pop由维护者按需手动同步；它们的固定符号必须与基础工程现有二进制配对。
    // 引擎与Kit则取本次Release构建完成后的产物。
    for name in names {
        let isPrebuilt = name == "Ono" || name == "pop"
        let parent = isPrebuilt ? "uexFrameworks" : "engine"
        let framework = isPrebuilt
            ? root.appendingPathComponent("AppCanPlugin/AppCanPlugin/\(parent)/\(name).framework", isDirectory: true)
            : products.appendingPathComponent("\(name).framework", isDirectory: true)
        let symbolRoot = isPrebuilt ? prebuiltSymbols : products
        let binary = framework.appendingPathComponent(name)
        let symbol = symbolRoot.appendingPathComponent("\(name).framework.dSYM/Contents/Resources/DWARF/\(name)")
        let binaryUUID = try arm64UUID(at: binary)
        let symbolUUID = try arm64UUID(at: symbol)
        guard binaryUUID == symbolUUID else {
            throw FrameworkSymbolError.mismatch(name, binaryUUID, symbolUUID)
        }
        print("\(name) dSYM UUID: \(binaryUUID)")
    }

    // 只更新引擎与Kit；不在每次出包时覆盖基础工程的Ono/pop。
    // 输出目录每次重建，避免残留旧符号或未交付的Swift框架dSYM。
    if fm.fileExists(atPath: symbols.path) { try fm.removeItem(at: symbols) }
    try fm.createDirectory(at: symbols, withIntermediateDirectories: true, attributes: nil)
    for name in names {
        let isPrebuilt = name == "Ono" || name == "pop"
        let parent = isPrebuilt ? "uexFrameworks" : "engine"
        let destination = root.appendingPathComponent("AppCanPlugin/AppCanPlugin/\(parent)/\(name).framework", isDirectory: true)
        if !isPrebuilt {
            if fm.fileExists(atPath: destination.path) { try fm.removeItem(at: destination) }
            try fm.copyItem(at: products.appendingPathComponent("\(name).framework", isDirectory: true), to: destination)
        }
        let symbolRoot = isPrebuilt ? prebuiltSymbols : products
        try fm.copyItem(at: symbolRoot.appendingPathComponent("\(name).framework.dSYM", isDirectory: true),
                        to: symbols.appendingPathComponent("\(name).framework.dSYM", isDirectory: true))
        let binaryUUID = try arm64UUID(at: destination.appendingPathComponent(name))
        let symbolUUID = try arm64UUID(at: symbols.appendingPathComponent("\(name).framework.dSYM/Contents/Resources/DWARF/\(name)"))
        guard binaryUUID == symbolUUID else {
            throw FrameworkSymbolError.mismatch(name, binaryUUID, symbolUUID)
        }
    }
}

do{
    // Xcode脚本传入真实BUILD_DIR；独立运行构建产物时，从.app所在的配置目录向上取Products。
    let outerProducts = args["buildProductsDir"] ?? ProcessInfo.processInfo.environment["BUILD_DIR"] ??
        Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().path
    let engineDerivedDataPath = try XcodeBuild.packagerDerivedDataPath(buildProductsDirectory: outerProducts)
    print("Packager engine DerivedData: \(engineDerivedDataPath)")
    // 先确定唯一版本并更新真正的构建输入，再编译；日常仍只维护Changelog。
    let resolved = try EngineInfo.resolveVersion(versionString: args["version"], summary: args["summary"])
    let enginePlistURL = rootURL.appendingPathComponent("AppCanEngine/Info.plist")
    try resolved.version.synchronizeInfoPlist(at: enginePlistURL)
    print("Engine version synchronized before build: \(resolved.version.string)")
    fflush(stdout)

    let info = EngineInfo(version: resolved.version, summary: resolved.summary, suffix: args["suffix"])
    try engineBuildCommand("clean", engineDerivedDataPath)
    try engineBuildCommand("build", engineDerivedDataPath)

    let releaseProducts = URL(fileURLWithPath: engineDerivedDataPath)
        .appendingPathComponent("Build/Products/Release-iphoneos", isDirectory: true)
    try synchronizeReleaseFrameworks(from: releaseProducts, to: rootURL)

    // 基础工程从此位置链接引擎；版本不匹配时不得继续生成新包。
    let frameworkPlistURL = rootURL.appendingPathComponent("AppCanPlugin/AppCanPlugin/engine/AppCanEngine.framework/Info.plist")
    try info.version.verifyInfoPlist(at: frameworkPlistURL)
    
    let archiveFolderURL = rootURL.appendingPathComponent("archives")
    let tmpFolderURL = archiveFolderURL.appendingPathComponent("tmp")
    let fm = FileManager.default
    var isFolder: ObjCBool = false
//MARK: create archive folder
    if !fm.fileExists(atPath: archiveFolderURL.path, isDirectory: &isFolder) || !isFolder.boolValue{
        try fm.createDirectory(at: archiveFolderURL, withIntermediateDirectories: true, attributes: nil)
    }
//MARK: create tmp folder
    if fm.fileExists(atPath: tmpFolderURL.path){
        try fm.removeItem(at: tmpFolderURL)
    }
    try fm.createDirectory(at: tmpFolderURL, withIntermediateDirectories: true, attributes: nil)
    
//MARK: generate 7z package
    let _7zURL = tmpFolderURL.appendingPathComponent("package.7z")
    let writer = LzmaSDKObjCWriter(fileURL: _7zURL)
    guard writer.addPath(rootURL.appendingPathComponent("AppCanPlugin").path, forPath: "AppCanPlugin") else{
        fatalError("AppCanPlugin not exist")
    }
    writer.method = LzmaSDKObjCMethodLZMA2 // or LzmaSDKObjCMethodLZMA
    writer.compressionLevel = 9
    try writer.open()
    writer.write()
    let packageURL = tmpFolderURL.appendingPathComponent(info.package)
    try fm.moveItem(atPath: _7zURL.path, toPath: packageURL.path)
    
//MARK: generate engineInfo.xml
    let xml = info.XMLInfo()
    let xmlURL = tmpFolderURL.appendingPathComponent("iosEngine.xml")
    try xml.write(to: xmlURL, atomically: true, encoding: .utf8)
    
//MARK: locate Engine dSYM files
    
    let dSYMDirURL = rootURL.appendingPathComponent("dSYM", isDirectory: true)
    
//MARK: export engine archive
    let archiveURL = archiveFolderURL.appendingPathComponent("\(info.package).zip")
    if fm.fileExists(atPath: archiveURL.path){
        try fm.removeItem(at: archiveURL)
    }
    try Zip.zipFiles(paths: [packageURL,dSYMDirURL,xmlURL], zipFilePath: archiveURL, password: nil, progress: nil)
    
//MARK: clean up
    try fm.removeItem(at: tmpFolderURL)
    print("clean temp folder: \(tmpFolderURL.path)")
    print("AppCanEnginePackager's work finished with output pakcage: \(archiveURL.path)")
}catch let e as NSError{
    fputs("AppCanEnginePackager停止出包：\(e.localizedDescription)\n", stderr)
    exit(1)
}



