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

@interface WWidget : NSObject {
	// 数据库中的主键id
	int wId;
	// 手机端WidgetOne系统的唯一标识
	NSString *widgetOneId;
	// 应用软件唯一的标识，对于不同的手机或者同一手机上的不同应用，该值唯一
	NSString *widgetId;
	// 应用程序标识
	NSString *appId;
	// Widget版本号（String类型）
	NSString *ver;
	// 渠道号
	NSString *channelCode;
	// 手机IMEI号码
	NSString *imei;
	// 上传参数校验码
	NSString *md5Code;
	// widget 名称
	NSString *widgetName;
	// widget 的Icon 路径
	NSString *iconPath;
	// widget 在sdcard的路径
	NSString *widgetPath;
	// widget首页 路径
	NSString *indexUrl;
	// 是否加密
	int obfuscation;
	//哪一类widget
	int wgtType;
	//LOGIP
	NSString *logServerIp;
	//updateUrl
	NSString *updateUrl;
	//showMySpace
	int showMySpace;
	//description
	NSString *description;
	//email;
	NSString *email;
	//author
	NSString *author;
	//license
	NSString *license; 
	//orientation
	int orientation;
	//ad
	int openAdStatus;
	//preload
	int preload;
     NSString * appKey;
	
}
-(BOOL)getMySpaceStatus;
-(BOOL)getMoreWgtsStatus;
@property int wId;
@property int obfuscation;
@property int wgtType;
@property int showMySpace;
@property int orientation;
@property int openAdStatus;
@property int preload;
@property (nonatomic,retain)	NSString *widgetOneId;
@property (nonatomic,retain)	NSString *widgetId;
@property (nonatomic,retain)	NSString *appId;
@property (nonatomic,retain)	NSString *appKey;
@property (nonatomic,retain)	NSString *widgetName;
@property (nonatomic,retain)	NSString *ver;
@property (nonatomic,retain)	NSString *channelCode;
@property (nonatomic,retain)	NSString *imei;
@property (nonatomic,retain)	NSString *md5Code;
@property (nonatomic,retain)	NSString *iconPath;
@property (nonatomic,retain)	NSString *widgetPath;
@property (nonatomic,retain)	NSString *indexUrl;
@property (nonatomic,retain)	NSString *logServerIp;
@property (nonatomic,retain)	NSString *updateUrl;
@property (nonatomic,retain)	NSString *description;
@property (nonatomic,retain)	NSString *email;
@property (nonatomic,retain)	NSString *author;
@property (nonatomic,retain)	NSString *license;
@property (nonatomic,assign)    BOOL isDebug;
@property (nonatomic, assign) NSInteger enctryptcj;

@end
