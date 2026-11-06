//
//  XcodeBuild.swift
//  AppCanEnginePackager
//
//  Created by CeriNo on 2017/2/9.
//  Copyright © 2017年 AppCan. All rights reserved.
//

import Foundation

enum XcodeBuildError: LocalizedError {
    case invalidBuildDirectory(String)
    case commandFailed(String, Int32)

    var errorDescription: String? {
        switch self {
        case .invalidBuildDirectory(let path):
            return "无法推导出包器构建目录，预期外层目录以Build/Products结尾：\(path)"
        case .commandFailed(let command, let status):
            return "引擎xcodebuild \(command)失败，退出状态：\(status)，已停止出包"
        }
    }
}

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
    var useModernBuildSystem: String?
    var derivedDataPath: String?
    var destination: String?

    /// Xcode传入实际BUILD_DIR：去掉Products、Build，再追加同级PackagerBuild。
    /// 校验标准布局，避免自定义目录时向错误位置写入缓存；不写死用户或工程标识。
    static func packagerDerivedDataPath(buildProductsDirectory: String) throws -> String {
        let products = URL(fileURLWithPath: buildProductsDirectory, isDirectory: true).standardizedFileURL
        let build = products.deletingLastPathComponent()
        guard buildProductsDirectory.hasPrefix("/"), products.lastPathComponent == "Products", build.lastPathComponent == "Build" else {
            throw XcodeBuildError.invalidBuildDirectory(buildProductsDirectory)
        }
        return build.deletingLastPathComponent().appendingPathComponent("PackagerBuild", isDirectory: true).path
    }

    func runSync() throws {
        let shell = Process()
        shell.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        if let currentDirectoryPath = currentDirectoryPath{
            shell.currentDirectoryURL = URL(fileURLWithPath: currentDirectoryPath, isDirectory: true)
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
        if let destination = destination {
            args += ["-destination", destination]
        }
        if let derivedDataPath = derivedDataPath {
            // 外层仍在使用自己的数据库；内层clean/build只使用这一份独立缓存。
            // 显式覆盖产物和中间目录，避免继承外层脚本环境中的同名构建设置。
            let buildRoot = URL(fileURLWithPath: derivedDataPath).appendingPathComponent("Build")
            let products = buildRoot.appendingPathComponent("Products").path
            args += ["-derivedDataPath", derivedDataPath,
                     "SYMROOT=\(products)", "BUILD_ROOT=\(products)", "BUILD_DIR=\(products)",
                     "OBJROOT=\(buildRoot.appendingPathComponent("Intermediates.noindex").path)"]
        }
        // 不传入此参数则默认为true，即使用New Build System，可能存在兼容问题
        if let useModernBuildSystem = useModernBuildSystem{
            if (Bool(useModernBuildSystem) ?? true) {
                args += ["-UseModernBuildSystem=YES"]
                print("AppCanEnginePackager is using New Build System(Default).")
            } else {
                args += ["-UseModernBuildSystem=NO"]
                print("AppCanEnginePackager is using Legacy Build System.")
            }
        }
        args += [command]
        shell.arguments = args
        try shell.run()
        shell.waitUntilExit()
        guard shell.terminationReason == .exit, shell.terminationStatus == 0 else {
            throw XcodeBuildError.commandFailed(command, shell.terminationStatus)
        }
    }
    
}



