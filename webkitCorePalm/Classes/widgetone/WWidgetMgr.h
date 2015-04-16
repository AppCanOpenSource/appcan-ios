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
@class WWidget;
@class WgtReportParser;
@class SpecConfigParser;
@class UpdateParser;
#define F_WIDGETONEVERSION					@"widgetone_version"
#define F_WIDGETONE_REGIST_URL				@"http://wgb.tx100.com/mobile/wg-reg.wg" //内网
//#define F_WIDGET_REGIST_URL				@"http://wgb.tx100.com/mobile/soft-reg.wg"//widget注册
#define F_WIDGET_UPDATA_URL				@"http://wgb.3g2win.com/mobile/soft-update.wg"//升级
//#define F_WIDGET_REPORT_URL				@"http://wgb.tx100.com/mobile/soft-startup-report.wg"//上报

#define F_WIDGET_LOGIN_URL				@"http://open.appcan.cn/oauth2/getLoginList.do"
#define F_WIDGET_MOREWIDGET_URL			@"http://open.appcan.cn/common/appcenter.html?platFormId=0&pageindex=1"

#define SQL_WGTONE_DATABASE				@"wgtOneDB"
//#define SQL_WGTONE_TABLE					@"wgtoneTab"
#define SQL_WGTS_TABLE					@"wgtTab"
//file
#define F_MAINWIDGET_NAME				@"widget"
#define F_NAME_VIDEO					@"video"
#define F_NAME_PHOTO					@"photo"
#define F_NAME_AUDIO					@"audio"
#define F_NAME_MYSPACE					@"myspace"
#define F_NAME_APPS						@"apps"
#define F_NAME_WIDGETS					@"widgets"
#define F_NAME_CONFIG					@"config.xml"

#define F_WIDGET_REMOVE_SUCCESS				0
#define F_WIDGET_REMOVE_FAILED				1

//显示我的空间 小球
#define F_WIDGET_SHOWMYSPACE				1


//我的空间映射
//#define F_WIDGET_MYSPACE					@"9999999"
//加密
//#define WIDGET_REG_KEY_1		@"hd5lg[fq,xcnza!df/cv@m"
//#define WIDGET_REG_KEY_2		@"ci8df|ape\"ew&d0(9Pdxm"
//#define WIDGET_REG_KEY_3		@"sfxnv/.*3dkei#e^d5d;fd"
//#define WIDGET_REG_KEY_4		@"ypei$dow9l|df?zx>md<eg"

@interface WWidgetMgr : NSObject {
	WWidget *wMainWgt;
	NSMutableDictionary *wgtDict;
	NSMutableArray	*wgtArr;
	UpdateParser	*wgtUpParser;
    
}
@property (nonatomic, retain) WWidget *wMainWgt;

//all
- (void)loadMainWidget;
-(NSString*)curWidgetPath:(WWidget*)inWgtObj;

//delete  deprecate 1.1.022
//widgetOne regist
//-(NSString*)WidgetOneVersion;
//-(void)wgtOneRegist;
//-(BOOL)isHaveWgtOneId;
//-(NSString*)wgtOneID;

//mainWidget
-(WWidget*)mainWidget;
-(void)initMainWidget;

//space
//-(WWidget*)spaceWidget;
//-(void)initSpaceWidget;
-(void)initLoginAndMoreWidget;

//plugin
-(WWidget*)wgtPluginDataByAppId:(NSString*)inWgtId curWgt:(WWidget*)inCurWgt;
// widget common
-(NSMutableDictionary*)wgtParameters:(NSString*)inFileName;
-(void)writeWgtToDB:(WWidget*)inWidget createTab:(BOOL)isCreateTab;
-(WWidget*)dictToWgt:(NSMutableDictionary*)inDict;
//-(void)wgtRegist:(WWidget*)inWgt;
//-(void)wgtReport:(WWidget*)inWgtObj;
-(NSMutableDictionary*)wgtUpdate:(WWidget*)inWgt;
-(BOOL)removeWgtByAppId:(NSString*)inAppId;
//widgetOne js
-(WWidget*)wgtDataByAppId:(NSString*)inAppId;

-(void)createReqFolder;
-(void)createTmpFolder;
//-(void)unZipSpace;
-(void)unZipNormal;
//md5

//-(NSString *)md5Str:(NSString *)inImei widgetOneId:(NSString*)inWidgetOneId appId:(NSString*)inAppId ver:(NSString*)inVer channelCode:(NSString*)inChannelCode;
//tmp
-(WWidget*)wgtDataByID:(int)inIndex;
-(int)widgetNumber;
//如果是配置增量升级的同时，配置升级插件引擎包，则需要判断是否拷贝，覆盖增量包;2013-1-26
-(BOOL)isNeetUpdateWgt;
@end
