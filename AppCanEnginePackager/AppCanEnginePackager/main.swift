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



