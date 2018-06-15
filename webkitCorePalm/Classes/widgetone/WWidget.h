/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Foundation/Foundation.h>
#import "ACEAnimation.h"
#import "ACEMPWindowOptions.h"


#define ACEMP_TransitionView_Close_Notify @"ACEMP_TransitionView_Close_Notify"


#define F_WWIDGET_NO_OBFUSCATION	0
#define F_WWIDGET_OBFUSCATION		1

#define F_WWIDGET_NO_ENCRYPTCJ      0
#define F_WWIDGET_ENCRYPTCJ         1

#define F_WWIDGET_SPACEWIDGET		0
#define F_WWIDGET_MAINWIDGET		1
#define F_WWIDGET_OTHERSWIDGET		2
#define F_WWIDGET_TMPWIDGET			3
#define F_WWIDGET_PLUGINWIDGET		4

//3.30
#define WIDGETREPORT_SPACESTATUS_OPEN				0x1
#define WIDGETREPORT_SPACESTATUS_EXTEN_OPEN			0X2











@interface WWidget : NSObject<AppCanWidgetObject>

// 数据库中的主键id
@property (nonatomic,assign) int wId;
// 是否加密
@property (nonatomic,assign) int obfuscation;
//哪一类widget
@property (nonatomic,assign) int wgtType;
@property (nonatomic,assign) int showMySpace;
@property (nonatomic,assign) int orientation;
@property (nonatomic,assign) int openAdStatus;
@property (nonatomic,assign) int preload;


//子应用启动图相关
//子应用图标
@property (nonatomic,strong) NSString *appIcon;
//打开子应用时是否使用启动图
@property (nonatomic,assign) BOOL appLoadingStatus;


// 手机端WidgetOne系统的唯一标识
@property (nonatomic,strong) NSString *widgetOneId;
// 应用软件唯一的标识，对于不同的手机或者同一手机上的不同应用，该值唯一
@property (nonatomic,strong) NSString *widgetId;
// 应用程序标识
@property (nonatomic,strong) NSString *appId;
@property (nonatomic,strong) NSString *appKey;
// widget 名称
@property (nonatomic,strong) NSString *widgetName;
// Widget版本号
@property (nonatomic,strong) NSString *ver;
// 渠道号
@property (nonatomic,strong) NSString *channelCode;
// 手机IMEI号码
@property (nonatomic,strong) NSString *imei;
// 上传参数校验码
@property (nonatomic,strong) NSString *md5Code;
// widget 的Icon 路径
@property (nonatomic,strong) NSString *iconPath;
// widget 在sdcard的路径
@property (nonatomic,strong) NSString *widgetPath;
// widget首页 路径
@property (nonatomic,strong) NSString *indexUrl;
@property (nonatomic,strong) NSString *logServerIp;
@property (nonatomic,strong) NSString *updateUrl;
@property (nonatomic,strong) NSString *desc;
@property (nonatomic,strong) NSString *email;
@property (nonatomic,strong) NSString *author;
@property (nonatomic,strong) NSString *license;
@property (nonatomic,assign) BOOL isDebug;
@property (nonatomic,assign) NSInteger enctryptcj;


@property (nonatomic,strong) NSString *openMessage;
@property (nonatomic,strong) NSString *closeCallbackName;
@property (nonatomic,assign) ACEAnimationID openAnimation;
@property (nonatomic,assign) NSTimeInterval openAnimationDuration;
@property (nonatomic,strong) NSDictionary *openAnimationConfig;
@property (nonatomic,assign) ACEAnimationID closeAnimation;
@property (nonatomic,assign) NSTimeInterval closeAnimationDuration;
@property (nonatomic,strong) NSDictionary *closeAnimationConfig;

@property (nonatomic,strong) ACEMPWindowOptions *indexWindowOptions;
@property (nonatomic,assign) BOOL isFirstStartWithConfig;

//公众号新增参数
//子widget应用中页面无法加载时的错误页面路径，默认为主应用的。
@property (nonatomic,strong) NSString *errorPath;

-(BOOL)getMySpaceStatus;
-(BOOL)getMoreWgtsStatus;


@end
