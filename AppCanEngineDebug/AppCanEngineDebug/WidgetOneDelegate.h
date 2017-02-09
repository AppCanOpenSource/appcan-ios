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


#import <UIKit/UIKit.h>
@class EBrowserController;
@class EBrowser;
@class WWidgetMgr;
//@class PluginParser;
@class ACEWebViewController;
@class ACEDrawerViewController;
@class RESideMenu;
@class ACEPluginParser;
@interface WidgetOneDelegate: NSObject <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
//@property (nonatomic, strong) EBrowserController *meBrwCtrler;
@property (nonatomic, strong) WWidgetMgr *mwWgtMgr;
@property (nonatomic, assign) BOOL userStartReport;
@property (nonatomic, assign) BOOL useEmmControl;
@property (nonatomic, assign) BOOL useOpenControl;
@property (nonatomic, assign) BOOL useUpdateControl;
@property (nonatomic, assign) BOOL useOnlineArgsControl;
@property (nonatomic, assign) BOOL usePushControl;
@property (nonatomic, assign) BOOL useDataStatisticsControl;
@property (nonatomic, assign) BOOL useAuthorsizeIDControl;
@property (nonatomic, assign) BOOL useCloseAppWithJaibroken;
@property (nonatomic, assign) BOOL useRC4EncryptWithLocalstorage;
@property (nonatomic, assign) BOOL useUpdateWgtHtmlControl;
@property (nonatomic, assign) BOOL signVerifyControl;
@property (nonatomic, assign) BOOL useCertificateControl;
@property (nonatomic, assign) BOOL useIsHiddenStatusBarControl;
@property (nonatomic, assign, readonly) BOOL useEraseAppDataControl;
@property (nonatomic, strong) NSString *useStartReportURL;
@property (nonatomic, strong) NSString *useAnalysisDataURL;
@property (nonatomic, strong) NSString *useBindUserPushURL;
@property (nonatomic, strong) NSString *useAppCanMAMURL;
@property (nonatomic, strong) NSString *useAppCanMCMURL;
@property (nonatomic, strong) NSString *useAppCanMDMURL;
@property (nonatomic, strong) NSString *useCertificatePassWord;
@property (nonatomic, strong) NSString *useAppCanUpdateURL;
@property (nonatomic, assign) BOOL useAppCanMDMURLControl;
@property (nonatomic, retain) NSMutableDictionary *thirdInfoDict;


@property (nonatomic, strong) ACEWebViewController *leftWebController;
@property (nonatomic, strong) ACEWebViewController *rightWebController;
@property (nonatomic, strong) ACEDrawerViewController *drawerController;
@property (nonatomic, strong) RESideMenu *sideMenuViewController;
@property (nonatomic, assign) NSInteger enctryptcj;


//4.0
@property (nonatomic, strong) NSString * useAppCanEMMTenantID;//EMM单租户场景下默认的租户ID
@property (nonatomic, strong) NSString * useAppCanAppStoreHost;//uexAppstroeMgr所需的host
@property (nonatomic, strong) NSString * useAppCanMBaaSHost;//引擎中MBaaS读取的host
@property (nonatomic, strong) NSString * useAppCanIMXMPPHost;//uexIM插件XMPP通道使用的host
@property (nonatomic, strong) NSString * useAppCanIMHTTPHost;//uexIM插件HTTP通道使用的host
@property (nonatomic, strong) NSString * useAppCanTaskSubmitSSOHost;//uexTaskSubmit登陆所需host
@property (nonatomic, strong) NSString * useAppCanTaskSubmitHost;//uexTaskSubmit提交任务所需host
@property (nonatomic, assign) BOOL validatesSecureCertificate;//是否校验证书


@property (nonatomic, assign, readonly) BOOL useInAppCanIDE;

- (instancetype)initWithDevMode;



@end

#define theApp ((WidgetOneDelegate *)[[UIApplication sharedApplication] delegate])

