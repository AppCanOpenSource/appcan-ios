
appcan-ios
==========

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

* appcan-ios开源引擎
* 参考文档 http://newdocx.appcan.cn/
* QQ交流群：173758265




引擎工程要求Xcode 8.0+ 


**引擎工程采用[Carthage](https://github.com/Carthage/Carthage)进行依赖管理,使用前请先安装Carthage**

* 推荐采用**Homebrew**进行安装

```shell
brew install carthage
```

* 其他安装方式可参考Carthage官方文档



### 初始化

1. 从Github上下载引擎工程源码

   ```shell
   git clone https://github.com/AppCanOpenSource/appcan-ios.git
   ```

2. 进入仓库根目录,通过Carthage下载依赖

   ```shell
   cd appcan-ios
   carthage update --use-submodules --no-build
   ```


3. 打开引擎工程`AppCanEngine.xcworkspace`




### 如何进行引擎调试

1.引擎工程中,展开`AppCanEngineDebug`这个子工程,将`AppCanEngine/Supporting Files/widget`目录下的内容替换为自己的AppCan网页包

2.(可选)如要配合插件进行调试.在`AppCanEngineDebug`子工程中添加插件库及其依赖,并编辑`AppCanEngine/Supporting Files/plugin.xml`添加插件信息

3.运行`AppCanEngineDebug`这个scheme,进行调试



### 如何生成引擎包

1. 首次使用前,在终端进入`AppCanEnginePackager`文件夹,通过Carthage下载出包依赖库

   ```shell
   cd appcan-ios/AppCanEnginePackager
   carthage update --platform osx
   ```

2. 引擎工程中,选择`AppCanEngineArchive`这个scheme并运行

3. 引擎包会生成在`appcan-ios/archives`文件夹中

## Xcode版本兼容问题

1. 升级Xcode版本后，swift版本可能会有不匹配的错误导致运行出错，重新执行步骤1即可（若装有多个Xcode，要注意将Xcode的CommandLineTools版本指定为你想用的那个版本，然后再执行步骤1）
2. 由于AppCanEnginePackager工程中依赖的Github上的Zip工程有所更新，内部声明了要使用swift4.0。目前Cartfile中的配置是使用依赖库的最新版本，所以会导致在旧版Xcode（9.2以下）中可能出现编译错误，carthage update时出错。如果需要用低版本Xcode编译出包，可以修改一下AppCanEnginePackager/Cartfile.private文件，然后重新执行“如何生成引擎包”的"步骤1"。文件修改如下：
    ```
    github "swiftline/swiftline"
    github "marmelroy/Zip" ==0.7.0
    ```

