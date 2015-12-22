#!/bin/bash

#  buildEngineForPluginDevelopment.sh
#  生成一个模拟器和真机通用的引擎静态库
#  AppCanEngine
#
#  Created by CeriNo on 15/12/10.
#




#新建一个临时文件夹
rm -rf ./temp
mkdir ./temp

#clean工程
xcodebuild -project AppCanEngine.xcodeproj -scheme AppCanEngine clean

#build真机用的.a并拷贝到临时文件夹中
xcodebuild -configuration Release -project AppCanEngine.xcodeproj -sdk iphonesimulator -arch x86_64 -arch i386 -scheme AppCanEngine
cp -rf ../AppCanPlugin/AppCanPlugin/engine/libAppCanEngine.a ./temp/libAppCanEngine_Simulator.a

#clean工程
xcodebuild -project AppCanEngine.xcodeproj -scheme AppCanEngine clean

#build真机用的.a并拷贝到临时文件夹中
xcodebuild -configuration Release -project AppCanEngine.xcodeproj -sdk iphoneos -scheme AppCanEngine
cp -rf ../AppCanPlugin/AppCanPlugin/engine/libAppCanEngine.a ./temp/libAppCanEngine_Device.a


#合并.a
lipo -info ./temp/libAppCanEngine_Simulator.a
lipo -info ./temp/libAppCanEngine_Device.a
lipo -create ./temp/libAppCanEngine_Simulator.a ./temp/libAppCanEngine_Device.a -output libAppCanEngine.a
lipo -info libAppCanEngine.a

#删除临时文件夹
rm -rf ./temp
open ./