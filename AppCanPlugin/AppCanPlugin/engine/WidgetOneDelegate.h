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



@class EBrowserController;
@class EBrowser;
@class WWidgetMgr;
@class PluginParser;
@class ACEWebViewController;
@class ACEDrawerViewController;
@class RESideMenu;

@interface WidgetOneDelegate: NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
	UIWindow *window;
	EBrowserController *meBrwCtrler;
	WWidgetMgr *mwWgtMgr;
	PluginParser *pluginObj;
}
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) EBrowserController *meBrwCtrler;
@property (nonatomic, assign) WWidgetMgr *mwWgtMgr;
@property (nonatomic) BOOL userStartReport;
@property (nonatomic) BOOL useEmmControl;
@property (nonatomic) BOOL useOpenControl;
@property (nonatomic) BOOL useUpdateControl;
@property (nonatomic) BOOL useOnlineArgsControl;
@property (nonatomic) BOOL usePushControl;
@property (nonatomic) BOOL useDataStatisticsControl;
@property (nonatomic) BOOL useAuthorsizeIDControl;
@property (nonatomic) BOOL useCloseAppWithJaibroken;
@property (nonatomic) BOOL useRC4EncryptWithLocalstorage;
@property (nonatomic) BOOL useUpdateWgtHtmlControl;
@property (nonatomic) BOOL signVerifyControl;
@property (nonatomic) BOOL useCertificateControl;
@property (nonatomic) BOOL useIsHiddenStatusBarControl;
@property (nonatomic,readonly) BOOL useEraseAppDataControl;
@property(nonatomic,copy)NSString *useStartReportURL;
@property(nonatomic,copy)NSString *useAnalysisDataURL;
@property(nonatomic,copy)NSString *useBindUserPushURL;
@property(nonatomic,copy)NSString *useAppCanMAMURL;
@property(nonatomic,copy)NSString *useAppCanMCMURL;
@property(nonatomic,copy)NSString *useAppCanMDMURL;
@property(nonatomic,copy)NSString *useCertificatePassWord;
@property(nonatomic,copy)NSString *useAppCanUpdateURL;
@property(nonatomic)BOOL useAppCanMDMURLControl;
@property (nonatomic, retain) NSMutableDictionary *thirdInfoDict;
@property (nonatomic, assign) BOOL isFirstPageDidLoad;

@property (nonatomic, retain) ACEWebViewController *leftWebController;
@property (nonatomic, retain) ACEWebViewController *rightWebController;
@property (nonatomic, retain) ACEDrawerViewController *drawerController;
@property (nonatomic, retain) RESideMenu *sideMenuViewController;
@property (nonatomic, assign) NSInteger enctryptcj;
@property (nonatomic, retain) NSMutableDictionary *globalPluginDict;

//4.0
@property (nonatomic, copy) NSString * useAppCanEMMTenantID;//EMM单租户场景下默认的租户ID
@property (nonatomic, copy) NSString * useAppCanAppStoreHost;//uexAppstroeMgr所需的host
@property (nonatomic, copy) NSString * useAppCanMBaaSHost;//引擎中MBaaS读取的host
@property (nonatomic, copy) NSString * useAppCanIMXMPPHost;//uexIM插件XMPP通道使用的host
@property (nonatomic, copy) NSString * useAppCanIMHTTPHost;//uexIM插件HTTP通道使用的host
@property (nonatomic, copy) NSString * useAppCanTaskSubmitSSOHost;//uexTaskSubmit登陆所需host
@property (nonatomic, copy) NSString * useAppCanTaskSubmitHost;//uexTaskSubmit提交任务所需host
@property(nonatomic) BOOL validatesSecureCertificate;//是否校验证书


//-(NSString *)getPayPublicRsaKey;
-(void)rootPageDidFinishLoading;
@end

#define theApp ((WidgetOneDelegate *)[[UIApplication sharedApplication] delegate])
