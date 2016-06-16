//
//  AppCanKit.h
//  AppCanKit
//
//  Created by CeriNo on 16/5/25.
//  Copyright © 2016年 AppCan. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AppCanKit.
FOUNDATION_EXPORT double AppCanKitVersionNumber;

//! Project version string for AppCanKit.
FOUNDATION_EXPORT const unsigned char AppCanKitVersionString[];





/**
 *  对于AppCanKit中提供的带ac_前缀的C方法,默认会提供一个不带前缀的便捷实现
 *  如果您需要禁止这些便捷实现,按如下方法在引入本框架前定义宏APPCAN_DISABLE_SHORT_SYNTAX即可,
 
 #define APPCAN_DISABLE_SHORT_SYNTAX
 #import <AppCanKit/AppCanKit.h>
 
 *
 *  此宏用于解决便捷方法可能会发生命名冲突的问题,如果您的工程没有发生命名冲突,无需定义此宏
 */


#import <AppCanKit/ACMetaMacros.h>
#import <AppCanKit/ACNil.h>
#import <AppCanKit/ACJSFunctionRef.h>
#import <AppCanKit/ACJSON.h>
#import <AppCanKit/ACArguments.h>
#import <AppCanKit/UIColor+ACHTMLColor.h>
#import <AppCanKit/ACAvailability.h>
#import <AppCanKit/EUExBase.h>
#import <AppCanKit/ACPluginBundle.h>
#import <AppCanKit/ACLog.h>