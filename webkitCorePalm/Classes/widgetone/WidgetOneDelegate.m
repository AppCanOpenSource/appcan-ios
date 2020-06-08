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
#import "WidgetOneDelegate.h"
#import "WidgetOneDelegatePrivate.h"
#import "EBrowserController.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowser.h"

#import "WWidgetMgr.h"
#import "BUtility.h"
#import <sys/utsname.h>
#import "WWidget.h"
#import "FileEncrypt.h"
//#import "PluginParser.h"
#import "JSON.h"

#import <objc/runtime.h>
#import <objc/message.h>


#import "ACEUINavigationController.h"
#import "ACEDrawerViewController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "ACEWebViewController.h"
#import "ACEDes.h"
#import "RESideMenu.h"
#import "DataAnalysisInfo.h"
#import "EUtility.h"
#import "ACEPluginParser.h"
#import "ACEJSCHandler.h"
#import "ACEBrowserView.h"

#import <AppCanKit/ACInvoker.h>
#import <AppCanKit/ACEXTScope.h>
#import "ACEConfigXML.h"
#import <UserNotifications/UserNotifications.h>
#import "AppCanEngine.h"
#import "ACEWidgetUpdateUtility.h"

#define ACE_USERAGENT @"AppCanUserAgent"


@interface WidgetOneDelegate()<RESideMenuDelegate,UNUserNotificationCenterDelegate>

@end




@implementation WidgetOneDelegate

@synthesize window = _window;


- (NSString *)originWidgetPath{
    return @"widget";
}

- (NSString *)documentWidgetPath{
    return ACEWidgetUpdateUtility.currentWidgetPath;
}



- (void)initializeDefaultSettings{
    // set cookie storage:
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    self.userStartReport = YES;
    self.useOpenControl = YES;
    self.usePushControl = YES;
    self.useUpdateControl = YES;
    self.useOnlineArgsControl = YES;
    self.useDataStatisticsControl = YES;
    self.useAuthorsizeIDControl = YES;
    //startreport
    self.useStartReportURL = @"http://115.29.138.150/appIn/";
    //数据统计
    self.useAnalysisDataURL = @"http://115.29.138.150/appIn/";
    //bind push
    self.useBindUserPushURL = @"https://push.appcan.cn/push/";
    //mam
    self.useAppCanMAMURL = @"";
    self.useAppCanUpdateURL = @"";
    //jaibroken
    self.useCloseAppWithJaibroken = NO;
    //rc4 加密 js
    self.useRC4EncryptWithLocalstorage = YES;
    //网页增量升级
    self.useUpdateWgtHtmlControl = YES;
    //https密钥
    self.useCertificatePassWord = @"pwd";
    //擦除信息
    self.useEraseAppDataControl = YES;
    //https 密钥控制
    self.useCertificateControl = YES;
    //应用内是否显示状态条
    self.useIsHiddenStatusBarControl = NO;
    //MDM
    self.useAppCanMDMURL=@"";
    self.useAppCanMDMURLControl=NO;
    //本地签名校验开关
    self.signVerifyControl = NO;
    
    //EMM单租户场景下默认的租户ID
    self.useAppCanEMMTenantID = @"";
    //uexAppstroeMgr所需的host
    self.useAppCanAppStoreHost = @"";
    //引擎中MBaaS读取的host
    self.useAppCanMBaaSHost = @"";
    //uexIM插件XMPP通道使用的host
    self.useAppCanIMXMPPHost = @"";
    //uexIM插件HTTP通道使用的host
    self.useAppCanIMHTTPHost = @"";
    //uexTaskSubmit登陆所需host
    self.useAppCanTaskSubmitSSOHost = @"";
    //uexTaskSubmit提交任务所需host
    self.useAppCanTaskSubmitHost = @"";
    //是否校验证书
    self.validatesSecureCertificate = NO;
    
    [self setAppCanUserAgent];
}

- (instancetype)initWithDevMode{
    self = [super init];
    
    if (self != nil) {
        [self initializeDefaultSettings];
        self.useInAppCanIDE = YES;
    }
    
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self != nil) {
        [self initializeDefaultSettings];
        @weakify(self);
        [[NSNotificationCenter defaultCenter]addObserverForName:AppCanEngineRestartNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                [self setupRootViewController];
            });
        }];
    }
    return self;
    
}

-(void)setAppCanUserAgent {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    __block NSString *_userAgent = nil;
    _userAgent = [ud objectForKey:ACE_USERAGENT];
    
    if(_userAgent == nil) {
        __block WKWebView * tempConfigWKWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
        [tempConfigWKWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError * error) {
            if (tempConfigWKWebView != nil && error == nil) {
                NSString * originalUserAgent = result;
                ACLogDebug(@"AppCan===>OriginalUserAgent===>%@", originalUserAgent);
                NSString * acEngineUA= [NSString stringWithFormat:@"AppCan/%@ (WKWebView) ", @"4.5"];
                _userAgent = [NSString stringWithFormat:@"%@ %@", originalUserAgent, acEngineUA];
                [ud setObject:_userAgent forKey:ACE_USERAGENT];
                NSDictionary * dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:_userAgent, @"UserAgent", nil];
                [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
                // 将修改后的UA设置为自定义UA
                tempConfigWKWebView.customUserAgent = _userAgent;
                ACLogDebug(@"AppCan===>FinalCustomUserAgent===>%@", _userAgent);
            }else{
                ACLogError(@"AppCan===>Fail to get origin UserAgent, error: %@", error);
            }
        }];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    


    [AppCanEngine initializeWithConfiguration:self];
    //应用从未启动到启动，获取本地通知信息
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] ) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    
    

    [ACEAnalysisObject() ac_invoke:@"setErrorReport:" arguments:ACArgsPack(@(YES))];
    
    


    self.mwWgtMgr = [WWidgetMgr sharedManager];
    //[self readAppCanJS];
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self setupRootViewController];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (ACSystemVersion() >= 10) {
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    }
    return [AppCanEngine application:application didFinishLaunchingWithOptions:launchOptions];
    
}

- (void)setupRootViewController{
    _drawerController = [[ACEDrawerViewController alloc] initWithCenterViewController:AppCanEngine.mainWidgetController
                                                             leftDrawerViewController:nil
                                                            rightDrawerViewController:nil];
    
    _drawerController.mainContentController = AppCanEngine.mainWidgetController;
    
    
    [_drawerController setMaximumRightDrawerWidth:200.0];
    [_drawerController setMaximumLeftDrawerWidth:200.0];
    [_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    [_drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         if(block){
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    self.window.rootViewController = _drawerController;
    [self.window makeKeyAndVisible];

}





- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * devStr = [deviceToken description];
    NSString * firstStr = [devStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    if (firstStr) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:firstStr forKey:@"deviceToken"];
        [userDefault setValue:deviceToken forKey:@"device_Token"];
    }
    
    [AppCanEngine application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];

}
// 注册APNs错误

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    [AppCanEngine application:app didFailToRegisterForRemoteNotificationsWithError:err];

}
// 接收推送通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

    [AppCanEngine application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];

}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [AppCanEngine application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {

    [AppCanEngine application:application didReceiveLocalNotification:notification];

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [AppCanEngine application:application handleOpenURL:url];
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [AppCanEngine application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    [AppCanEngine applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //data analysis

    [ACEAnalysisObject() ac_invoke:@"setAppBecomeActive" arguments:nil];
    
    [AppCanEngine applicationDidBecomeActive:application];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    

    id number = [[NSUserDefaults standardUserDefaults] objectForKey:F_UD_BadgeNumber];
    if (number) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = [number intValue];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:F_UD_BadgeNumber];
        
    }
    
    [AppCanEngine.rootWebViewController.meBrw stopAllNetService];
    //data analysis
    int type = [[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * viewName =[[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:2 appInfo:appInfo];
    
    if ([[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        for (EBrowserView * ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
        }
        
    }
    

    [ACEAnalysisObject() ac_invoke:@"setAppBecomeBackground"];

    

    [AppCanEngine applicationDidEnterBackground:application];

    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    [AppCanEngine applicationWillEnterForeground:application];

    int type = [[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * goViewName =[[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    if (!goViewName || [goViewName isKindOfClass:[NSNull class]]) {
        return;
        
    }
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
    [BUtility setAppCanViewActive:type opener:@"application://" name:goViewName openReason:0 mainWin:0 appInfo:appInfo];
    if ([[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        NSArray * popViewArray = [[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        for (EBrowserView * ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString * viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
        }
        
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

    [AppCanEngine applicationWillTerminate:application];

    
    

    [ACEAnalysisObject() ac_invoke:@"setAppBecomeBackground"];
    
    
    int type = [[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * viewName =[[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:2 appInfo:appInfo];
    
    if ([[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        
        for (EBrowserView *ePopView in popViewArray) {
            
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            
        }
        
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    [[[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onTerminate();"];
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    

    

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    
    NSURLCredentialStorage * credentialsStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary * allCredentials = [credentialsStorage allCredentials];
    
    for (NSURLProtectionSpace * protectionSpace in allCredentials) {
        NSDictionary * credentials = [credentialsStorage credentialsForProtectionSpace:protectionSpace];
        for (NSString * credentialKey in credentials) {
            [credentialsStorage removeCredential:[credentials objectForKey:credentialKey] forProtectionSpace:protectionSpace];
        }
    }

    [AppCanEngine applicationDidReceiveMemoryWarning:application];

}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{


    [AppCanEngine application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];

}





- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{

    [AppCanEngine application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];

    
}



- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler{
    return [AppCanEngine application:application continueUserActivity:userActivity restorationHandler:restorationHandler];

}




- (void)dealloc {

    _mwWgtMgr = nil;
    self.useAppCanMAMURL = nil;
    self.useAppCanMCMURL=nil;
    self.useAppCanMDMURL=nil;
    self.useAnalysisDataURL = nil;
    self.useBindUserPushURL = nil;
    self.useStartReportURL = nil;
    self.useAppCanMAMURL = nil;
    self.useCertificatePassWord = nil;
    self.useAppCanUpdateURL = nil;
    //4.0
    self.useAppCanEMMTenantID = nil;
    self.useAppCanAppStoreHost = nil;
    self.useAppCanMBaaSHost = nil;
    self.useAppCanIMXMPPHost = nil;
    self.useAppCanIMHTTPHost = nil;
    self.useAppCanTaskSubmitSSOHost = nil;
    self.useAppCanTaskSubmitHost = nil;
}






#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    [AppCanEngine userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];

}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{

    [AppCanEngine userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];

}

@end
