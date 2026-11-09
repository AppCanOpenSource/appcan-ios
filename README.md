# AppCan iOS 引擎

AppCan iOS 开源引擎，为前端 Widget 和原生插件提供 WKWebView 容器、JS Bridge、窗口管理及应用生命周期等基础能力。

- 文档：http://newdocx.appcan.cn/
- QQ 交流群：173758265

本 README 介绍当前分支的开发方式及重大版本变化；具体功能迭代和问题修复见 [Changelog.plist](AppCanEngine/Changelog.plist)。

## 隐私与上架文档

从[上架填写模板](docs/app-store-submission-guide.md)开始：按填写位置复制文案，替换`【】`即可。隐私政策中的第三方SDK章节使用[SDK披露模板](docs/sdk-data-practices.md)；遇到清单报错查看[交付说明](docs/privacy-manifest-delivery.md)。

以上文档适用于4.7.49，后续按版本和实际需要更新。本阶段暂不新增引擎及基础库`PrivacyInfo.xcprivacy`，已有插件/第三方SDK清单以实际包为准。

## 当前开发基线

当前 `4.7-develop` 基于 4.6 引擎升级，面向 **Xcode 27.1、iOS/iPadOS 27**，使用 iOS SDK 27.1 构建，**最低支持 iOS 15.0**。这与使用哪个 SDK 编译是两个不同的版本要求。

引擎以 Objective-C 为主；Swift 插件通过 AppCanKit 和可选的 AppCanKitSwift 模块接入。出包器是 macOS 命令行工具，当前工程使用 Swift 5 语言模式，最低构建目标为 macOS 12。

当前已形成4.7.49阶段引擎包并交付业务测试：引擎及两套宿主的通用真机构建已有通过记录，用户已反馈iPadOS 26正常启动。完整业务回归及最终业务App送审结果仍按实际项目确认；iPhone Duo双区域适配和模拟器依赖补齐安排在后续阶段。

## 重大版本变化

### 4.7：新工具链、Scene 及依赖基线升级

- **适配 Xcode 27.1 / iOS SDK 27.1**，将引擎、两套宿主及基础源码依赖的最低 iOS 版本统一到 15.0。仍需维护 4.6 的项目，应使用对应旧基线的引擎与依赖，不能直接混用 4.7 依赖。
- **接入单 Scene 生命周期**：引擎提供 `ACEWindowSceneDelegate`，宿主需配置 `UIApplicationSceneManifest`；保持原 AppDelegate 窗口及插件事件链的衔接。当前不启用多 Scene 或业务窗口自动分屏。
- **淘汰 ASIHTTPRequest**：原推送计数、已读上报、绑定与解绑请求迁移到系统 `NSURLSession`，由引擎私有类 `ACEURLSession` 封装，统一异步执行；引擎不为此新增 AFNetworking 依赖。代码迁移及构建已完成，网络业务兼容性仍在验收中。
- **恢复 AppCanKitSwift 对当前 WK 插件桥的支持**：新增 `PluginArgument` 参数入口，复用 Objective-C 的 `ACJSFunctionRef` 异步回调能力，移除旧 Swift JavaScriptCore 参数及回调封装。新接口已通过构建和 Swift 5/6 消费端编译链接检查；使用旧 Swift 接口的插件需迁移并重新编译，真实 WK 运行与服务器按需交付仍待验收。
- **更新 macOS 出包工具链**：出包器使用 Swift 5，更新压缩库以支持 Apple Silicon 与 Intel 架构，并同步引擎版本元数据、隔离内部构建。产物仍由打包服务器与宿主工程消费；引擎 ZIP 不等同于已签名、可送审的 IPA。

### 4.6：WKWebView 基线与后续系统维护

4.6 延续 WKWebView 引擎，建立 Xcode 12 出包基线，后续持续适配系统与工具链，已有 Xcode 16.4 的适配记录。它是 4.7 的来源基线；旧客户项目需要时继续在对应维护分支上处理补丁。

### 4.5：UIWebView 迁移到 WKWebView

自 4.5.25 测试版起，将网页内核由 UIWebView 替换为 WKWebView，并配套调整 JS Bridge、插件基础库及资源处理。这是引擎架构变化；依赖旧 UIWebView 或直接引用引擎内部接口的插件，需要随对应基线适配。

## 获取源码与依赖

引擎源码依赖 AppCanKit、Ono 和 pop，作为 Git 子模块位于 `Carthage/Checkouts/`，并直接加入 workspace 编译。`Cartfile` 声明维护分支，`Cartfile.resolved` 和 Git 子模块指针记录依赖版本。

```shell
git clone --recurse-submodules https://github.com/AppCanOpenSource/appcan-ios.git
cd appcan-ios
```

获取源码后切换到所需维护分支；本页对应 `4.7-develop`，远端默认分支不代表最新适配基线。已有仓库首次补齐子模块或切换基线后，使用：

```shell
git submodule update --init --recursive
```

打开 `AppCanEngine.xcworkspace`。日常构建使用仓库固定的依赖，不需要每次执行 `carthage update`；主动升级依赖时应同时核对锁文件、子模块指针和构建结果。

## 调试与业务工程接入

### 使用仓库内调试宿主

1. 将 `AppCanEngineDebug/AppCanEngineDebug/widget/` 替换为自己的 Widget 网页包。
2. 如需插件，向 `AppCanEngineDebug` 子工程加入插件库、资源及依赖，并更新 `AppCanEngineDebug/AppCanEngineDebug/plugin.xml`。
3. 配置签名并选择真机，运行 `AppCanEngineDebug` scheme。只检查编译时可选择通用 iOS 真机目标。

### 使用打包服务器生成的基础工程

实际业务开发通常将打包服务器生成的 `AppCanPlugin.xcodeproj` 加入引擎 workspace。该工程已拼装 Widget、插件和业务配置；核对它链接及嵌入的是当前源码构建的引擎和匹配依赖后，即可联调引擎源码。仓库内的 `AppCanPlugin/` 是基础宿主模板，不能代替真实业务工程的集成验收。

4.7 宿主还需带上 Scene 配置和引擎 Scene 代理类。`WidgetOnePseudoDelegate.m` 中约定的打包开关及服务器参数位置由线上打包流程使用，调整宿主时应保留。

Swift 插件除 AppCanKit 外，还需按实际使用情况链接、嵌入 AppCanKitSwift，并包含运行所需的 Swift 库；默认基础包不代表已包含全部 Swift 插件依赖。第三方插件自己的 AFNetworking 等依赖仍由宿主按需集成。

## 生成引擎包

1. 准备与当前 Xcode 匹配的 macOS 出包依赖：Swiftline、Zip，以及工程自带的 LzmaSDK_ObjC。前两者由 `AppCanEnginePackager/Cartfile.private` 和 `Cartfile.resolved` 描述；Swiftline 使用维护 fork。Swift 二进制依赖需用匹配的工具链构建，仅拉取依赖源码不代表已经可运行出包器。
2. 在 workspace 中选择并运行 `AppCanEngineArchive` scheme，由出包器构建 Release 真机引擎并封包。出包器当前要求源码根目录名为 `appcan-ios`，首次使用时核对 scheme 的源码路径参数。
3. 产物输出到仓库根目录 `archives/`，包含引擎 ZIP、相关符号及元数据。以实际产物核对版本和依赖，再交给打包服务器消费。

新工具链使用现代构建系统；旧 README 中针对 Xcode 9/10、Swift 4 和 Legacy Build System 的处理方式不再作为当前分支的操作步骤。历史版本请查阅对应分支的文档和版本记录。
