import Foundation

// 与XcodeBuild.swift一起编译；仅在指定临时目录内验证真实xcodebuild的非零退出。
let root = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
var assertions = 0
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    precondition(condition(), message)
    assertions += 1
}

for prefix in ["/Users/sample/Library/Developer/Xcode/DerivedData/AppCanEngine-identifier", "/tmp/中文 空格/OuterDerivedData"] {
    for suffix in ["/Build/Products", "/Build/Products/"] {
        let path = try XcodeBuild.packagerDerivedDataPath(buildProductsDirectory: prefix + suffix)
        check(path == prefix + "/PackagerBuild", "使用实际BUILD_DIR，去掉两级再追加同级目录")
    }
}
for invalid in ["", "relative/Build/Products", "/tmp/Products", "/tmp/Custom/Products", "/tmp/Build/Other"] {
    do {
        _ = try XcodeBuild.packagerDerivedDataPath(buildProductsDirectory: invalid)
        preconditionFailure("应当拒绝不符合约定的布局：\(invalid)")
    } catch XcodeBuildError.invalidBuildDirectory {
        assertions += 1
    }
}

let build = XcodeBuild(path: .workspace(path: "Missing.xcworkspace"), command: "build", currentDirectoryPath: root.path)
do {
    try build.runSync()
    preconditionFailure("真实xcodebuild非零退出必须上抛")
} catch XcodeBuildError.commandFailed(let command, let status) {
    check(command == "build" && status != 0, "保留失败命令及退出状态")
}
print("PASS: \(assertions) assertions")
