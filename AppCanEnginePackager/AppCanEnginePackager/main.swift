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
    fatalError("Invalid rootURL")
}

//MARK: - build engine
let engineBuildCommand: (String) -> Void = { command in
    let xcodebuild = XcodeBuild(path: .workspace(path: "AppCanEngine.xcworkspace"),
                                command: command,
                                configuration: "Release",
                                scheme: "AppCanEngine",
                                sdk: "iphoneos",
                                currentDirectoryPath: rootURL.path)
    xcodebuild.runSync()
}

engineBuildCommand("clean")
engineBuildCommand("build")


let info = EngineInfo(versionString: args["version"], summary: args["summary"], suffix: args["suffix"])


do{
    
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

}catch let e as NSError{
    fatalError("error: \(e.localizedDescription)")
}



