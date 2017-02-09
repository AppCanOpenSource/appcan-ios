//
//  XcodeBuild.swift
//  AppCanEnginePackager
//
//  Created by CeriNo on 2017/2/9.
//  Copyright © 2017年 AppCan. All rights reserved.
//

import Foundation

struct XcodeBuild{
    enum ProjectPath{
        case workspace(path: String)
        case project(path: String)
    }
    let path: ProjectPath
    let command: String
    var configuration: String?
    var scheme: String?
    var sdk: String?
    var currentDirectoryPath: String?
    func runSync(){
        let shell = Process()
        shell.launchPath = "/usr/bin/xcrun"
        if let currentDirectoryPath = currentDirectoryPath{
            shell.currentDirectoryPath = currentDirectoryPath
        }
        var args = ["xcodebuild"]
        switch path {
        case .workspace(let path):
            args += ["-workspace",path]
        case .project(let path):
            args += ["-project",path]
        }
        if let configuration = configuration{
            args += ["-configuration",configuration]
        }
        if let scheme = scheme{
            args += ["-scheme",scheme]
        }
        if let sdk = sdk{
            args += ["-sdk",sdk]
        }
        args += [command]
        shell.arguments = args
        shell.launch()
        shell.waitUntilExit()
    }
    
}



