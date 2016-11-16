#!/bin/bash

#  buildEngineForPluginDevelopment.sh
#  生成一个模拟器和真机通用的引擎库
#  AppCanEngine
#
#  Created by CeriNo on 15/12/10.
#



#清除可能存在的缓存文件
rm -rf ./temp
mkdir ./temp
rm -rf ./build
mkdir ./build
rm -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKit.framework
rm -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKitSwift.framework
rm -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanEngine.framework

#clean工程
xcodebuild -configuration Release -workspace AppCanEngine.xcworkspace -scheme AppCanEngine-framework clean

#编译模拟器架构
xcodebuild -configuration Release -workspace AppCanEngine.xcworkspace -sdk iphonesimulator -arch x86_64 -arch i386 -scheme AppCanEngine-framework
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanEngine.framework/AppCanEngine ./temp/AppCanEngine_Simulator
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKit.framework/AppCanKit ./temp/AppCanKit_Simulator
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKitSwift.framework/AppCanKitSwift ./temp/AppCanKitSwift_Simulator
#clean工程
xcodebuild -configuration Release -workspace AppCanEngine.xcworkspace -scheme AppCanEngine-framework clean

#编译真机架构
xcodebuild -configuration Release -workspace AppCanEngine.xcworkspace -sdk iphoneos -scheme AppCanEngine-framework
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanEngine.framework/AppCanEngine ./temp/AppCanEngine_Device
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKit.framework/AppCanKit ./temp/AppCanKit_Device
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKitSwift.framework/AppCanKitSwift ./temp/AppCanKitSwift_Device

#合并Engine
rm -rf ./AppCanEngine.framework
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanEngine.framework ./build/
lipo -create ./temp/AppCanEngine_Simulator ./temp/AppCanEngine_Device -output ./build/AppCanEngine.framework/AppCanEngine

#合并AppCanKit
rm -rf ./AppCanKit.framework
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKit.framework ./build/
lipo -create ./temp/AppCanKit_Device ./temp/AppCanKit_Simulator -output ./build/AppCanKit.framework/AppCanKit
rm -rf ./AppCanKitSwift.framework
cp -rf ../AppCanPlugin/AppCanPlugin/engine/AppCanKitSwift.framework ./build/
lipo -create ./temp/AppCanKitSwift_Device ./temp/AppCanKitSwift_Simulator -output ./build/AppCanKitSwift.framework/AppCanKitSwift



#删除临时文件夹
rm -rf ./temp

open ./build/
