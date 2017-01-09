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
#import "EUExBaseDefine.h"

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
#import <AppCanKit/AppCanGlobalObjectGetter.h>
#import <AppCanKit/ACInvoker.h>
#import "ONOXMLElement+ACEConfigXML.h"
#import <UserNotifications/UserNotifications.h>


#define kViewTagExit 100
#define kViewTagLocalNotification 200

#define ACE_USERAGENT @"AppCanUserAgent"


@interface WidgetOneDelegate()<RESideMenuDelegate,AppCanGlobalObjectGetter,UNUserNotificationCenterDelegate>
@property (nonatomic,assign,readwrite)BOOL useInAppCanIDE;
@end

@implementation WidgetOneDelegate

@synthesize window;
@synthesize meBrwCtrler;
@synthesize mwWgtMgr;
@synthesize userStartReport = _userStartReport;
@synthesize useEmmControl = _useEmmControl;
@synthesize useOpenControl = _useOpenControl;
@synthesize useUpdateControl = _useUpdateControl;
@synthesize useOnlineArgsControl = _useOnlineArgsControl;
@synthesize usePushControl = _usePushControl;
@synthesize useDataStatisticsControl = _useDataStatisticsControl;
@synthesize useAuthorsizeIDControl = _useAuthorsizeIDControl;
@synthesize useAppCanMAMURL = _useAppCanMAMURL;
@synthesize useAppCanMCMURL = _useAppCanMCMURL;
@synthesize useAppCanMDMURL = _useAppCanMDMURL;
@synthesize useStartReportURL = _useStartReportURL;
@synthesize useAnalysisDataURL = _useAnalysisDataURL;
@synthesize useBindUserPushURL = _useBindUserPushURL;
@synthesize useCloseAppWithJaibroken =_useCloseAppWithJaibroken;
@synthesize useRC4EncryptWithLocalstorage =_useRC4EncryptWithLocalstorage;
@synthesize useUpdateWgtHtmlControl =_useUpdateWgtHtmlControl;
@synthesize useCertificatePassWord = _useCertificatePassWord;
@synthesize useEraseAppDataControl =_useEraseAppDataControl;
@synthesize useCertificateControl = _useCertificateControl;
@synthesize useIsHiddenStatusBarControl =_useIsHiddenStatusBarControl;
@synthesize useAppCanUpdateURL = _useAppCanUpdateURL;
@synthesize useAppCanMDMURLControl = _useAppCanMDMURLControl;
@synthesize thirdInfoDict = _thirdInfoDict;

//4.0
@synthesize useAppCanEMMTenantID = _useAppCanEMMTenantID;
@synthesize useAppCanAppStoreHost = _useAppCanAppStoreHost;
@synthesize useAppCanMBaaSHost = _useAppCanMBaaSHost;
@synthesize useAppCanIMXMPPHost = _useAppCanIMXMPPHost;
@synthesize useAppCanIMHTTPHost = _useAppCanIMHTTPHost;
@synthesize useAppCanTaskSubmitSSOHost = _useAppCanTaskSubmitSSOHost;
@synthesize useAppCanTaskSubmitHost = _useAppCanTaskSubmitHost;
@synthesize validatesSecureCertificate = _validatesSecureCertificate;



- (void)parseURL:(NSURL *)url application:(UIApplication *)application {
    
    EBrowserWindow * ebv = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow];
    EBrowserView * ebview = [ebv theFrontView];
    ACEJSCHandler *handler = ebview.meBrowserView.JSCHandler;
    
    NSMutableDictionary *objDict = handler.pluginDict;
    //get the plist file from bundle
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"CBSchemesList" ofType:@"plist"];
    
    if (plistPath) {
        NSDictionary *pDataDict = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableArray *anArray = [NSMutableArray arrayWithArray:[pDataDict objectForKey:@"UexObjName"]];
        
        for (NSString * uexNameStr in anArray) {
            if(![uexNameStr hasPrefix:@"uex"]){
                continue;
            }
            NSString *EUExName = [@"EUEx" stringByAppendingString:[uexNameStr substringFromIndex:3]];
            __kindof EUExBase * payObj = [objDict objectForKey:EUExName];
            if (payObj && [payObj respondsToSelector:@selector(parseURL:application:)]) {
                [payObj performSelector:@selector(parseURL:application:) withObject:url withObject:application];
            }
        }
    }
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
    _useEraseAppDataControl = YES;
    //https 密钥控制
    self.useCertificateControl = YES;
    //应用内是否显示状态条
    self.useIsHiddenStatusBarControl = NO;
    //MDM
    self.useAppCanMDMURL=@"";
    self.useAppCanMDMURLControl=NO;
    self.isFirstPageDidLoad = NO;
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
    }
    return self;
    
}
-(void)setAppCanUserAgent {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *_userAgent=nil;
    _userAgent =[ud objectForKey:ACE_USERAGENT];
    
    if(_userAgent == nil) {
        
        UIWebView * sampleWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString * originalUserAgent = [sampleWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        NSString * subS1 = @"AppleWebKit/";
        NSRange range1 = [originalUserAgent rangeOfString:subS1];
        
        NSUInteger location1 = range1.location;
        NSUInteger lenght1 = range1.length;
        NSString * s1 = [originalUserAgent substringToIndex:location1+lenght1];
        NSString * s2 = [originalUserAgent substringFromIndex:location1+lenght1];
        
        NSString * subS2 = @" ";
        NSRange  rang2 = [s2 rangeOfString:subS2];
        NSUInteger location2 = rang2.location;
        NSUInteger length2 = rang2.length;
        NSString * s21 = [s2 substringToIndex:location2 + length2];
        NSString * s22 = [s2 substringFromIndex:location2 + length2];
        
        NSString * subS3 = @"Mobile/";
        NSRange  rang3 = [s22 rangeOfString:subS3];
        NSUInteger location3 = rang3.location;
        NSMutableString *s32 = [[NSMutableString alloc]initWithString:s22];
        [s32 insertString:@"Version/8.0 "atIndex:location3];
        NSString * safari= [NSString stringWithFormat:@"Safari/%@Appcan/3.0",s21];
        
        _userAgent = [NSString stringWithFormat:@"%@%@%@ %@",s1,s21,s32,safari];
        [ud setObject:_userAgent forKey:ACE_USERAGENT];
    }
    NSDictionary * dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:_userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [dictionnary release];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dyFiles"];
    
    if (![fileManager fileExistsAtPath:writableDBPath])  {
        NSString  *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dyFiles"];
        [BUtility copyMissingFile:defaultDBPath toPath:documentsDirectory];
    }
    if(self.useInAppCanIDE){
        [BUtility setAppCanDevMode:@"YES"];
    }
    [ACEDes enable];
    [BUtility setAppCanDocument];
    pluginObj = [ACEPluginParser sharedParser];
    if (_useCloseAppWithJaibroken) {
        
        BOOL isjab = [BUtility isJailbroken];
        
        if (isjab) {
            
            UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:ACELocalized(@"提示") message:ACELocalized(@"本应用仅适用未越狱机，即将关闭。") delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
            alertView.tag = kViewTagExit;
            [alertView show];
            [alertView release];
            return NO;
            
        }
        
    }
    //应用从未启动到启动，获取推送信息
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] ) {
        self.launchedByRemoteNotification=YES;
        NSDictionary *dict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSString *userData = [dict objectForKey:@"userInfo"];
        ACLogDebug(@"appcan--widgetOneDelegate.m--didFinishLaunchingWithOptions--dict == %@",dict);
        NSString * pushString = [dict JSONFragment];
        
        if (pushString) {
            [[NSUserDefaults standardUserDefaults] setObject:pushString forKey:@"allPushData"];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"appStateOfGetPushData"];
            
        }
        
        if (userData != nil) {
            
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
            
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
    //设置Debug日志
    ONOXMLElement *debug = [[ONOXMLElement ACENewestConfigXML] firstChildWithTag:@"debug"];
    NSString *debugEnable = debug[@"enable"];
    NSString *debugVerbose = debug[@"verbose"];
    if (debugEnable.boolValue) {
        if (debugVerbose.boolValue) {
            ACLogSetGlobalLogMode(ACLogModeVerbose);
        }else{
            ACLogSetGlobalLogMode(ACLogModeDebug);
        }
    }
    
    //应用从未启动到启动，获取本地通知信息
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] ) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    
    
    Class analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    
    if (analysisClass) {
        
        id analysisObject = class_createInstance(analysisClass,0);
        [analysisObject ac_invoke:@"setErrorReport:" arguments:ACArgsPack(@(YES))];
        
    }else{
        
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        
        if (analysisClass) {
            id analysisObject = class_createInstance(analysisClass,0);
            [analysisObject ac_invoke:@"setErrorReport:" arguments:ACArgsPack(@(YES))];
            
        }
        
    }
    
    ACEUINavigationController *meNav = nil;
    meBrwCtrler = [[EBrowserController alloc]init];
    
    NSString *hardware = [BUtility getDeviceVer];
    
    if (![hardware hasPrefix:@"iPad"]) {
        
        //如果设置的屏幕方向包括右横屏，则启动时候先禁止有横屏，启动后再解禁
        NSString * orientation = [BUtility getMainWidgetConfigInterface];
        int or = [orientation intValue];
        
        if (or== 10 || or ==11 ||or ==12 ||or ==9 ||or ==14 ||or ==13 ||or ==8) {
            
            meBrwCtrler.wgtOrientation=2;
            
        }
        
    }
    
    meNav = [[ACEUINavigationController alloc] initWithRootViewController:meBrwCtrler];
    
    [meNav setNavigationBarHidden:YES];
    
    //[ACEUtils setNavigationBarColor:meNav color:[UIColor purpleColor]];
    
    mwWgtMgr = [[WWidgetMgr alloc]init];
    meBrwCtrler.mwWgtMgr = mwWgtMgr;
    //[self readAppCanJS];
    
    
    window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    window.autoresizesSubviews = YES;
    
    _drawerController = [[ACEDrawerViewController alloc]
                         initWithCenterViewController:meNav
                         leftDrawerViewController:nil
                         rightDrawerViewController:nil];
    
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
    
    window.rootViewController = _drawerController;
    
    [meNav release];
    
    [window makeKeyAndVisible];
    [BUtility writeLog:[NSString stringWithFormat:@"-----didFinishLaunchingWithOptions------>>theApp.usePushControl==%d",theApp.usePushControl]];
    if(theApp.usePushControl == YES) {
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        //注册推送
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    

    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didFinishLaunchingWithOptions:launchOptions];
    }];
    if (ACSystemVersion() >= 10) {
        [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    }
    return YES;
    
}


- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString * devStr = [deviceToken description];
    NSString * firstStr = [devStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    if (firstStr) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setValue:firstStr forKey:@"deviceToken"];
        [userDefault setValue:deviceToken forKey:@"device_Token"];
    }
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }];
    
}
// 注册APNs错误

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:app didFailToRegisterForRemoteNotificationsWithError:err];
    }];
}
// 接收推送通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSUserDefaults *appStateUD = [NSUserDefaults standardUserDefaults];
    NSString *userData = [userInfo objectForKey:@"userInfo"];
    NSString * pushString = [userInfo JSONFragment];
    if (pushString) {
        [appStateUD setObject:pushString forKey:@"allPushData"];
    }
    if (userData != nil || userInfo) {
        [appStateUD setObject:userData forKey:@"pushData"];
        EBrowserWindowContainer * aboveWindowContainer = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
        if (aboveWindowContainer && application.applicationState != UIApplicationStateBackground) {
            if (application.applicationState == UIApplicationStateActive) {
                [appStateUD setObject:@"2" forKey:@"appStateOfGetPushData"];
            } else {
                [appStateUD setObject:@"1" forKey:@"appStateOfGetPushData"];
            }
            [appStateUD synchronize];
            [aboveWindowContainer pushNotify];
        }
    }
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }];
    
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    

    
    NSString *userData = [userInfo objectForKey:@"userInfo"];
    NSString * pushString = [userInfo JSONFragment];
    if (pushString) {
        [[NSUserDefaults standardUserDefaults] setObject:pushString forKey:@"allPushData"];
    }
    if (userData != nil || userInfo) {
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
        EBrowserWindowContainer * aboveWindowContainer = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
        if (aboveWindowContainer) {
            [aboveWindowContainer pushNotify];
        }
    }
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didReceiveRemoteNotification:userInfo];
    }];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didReceiveLocalNotification:notification];
    }];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    //支付完成后返回当前应用shi调用
    [self parseURL:url application:application];
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application handleOpenURL:url];
    }];
    return YES;
    
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    if (url != NULL) {
        NSString * strUrl = [url resourceSpecifier];
        NSArray * paramUrlArray = [strUrl componentsSeparatedByString:@"?"];
        if (paramUrlArray != NULL && paramUrlArray.count > 1) {
            NSString * paramUrl = [paramUrlArray objectAtIndex:1];
            if (paramUrl != NULL) {
                NSArray * paramUrlArray1 = [paramUrl componentsSeparatedByString:@"&"];
                if (paramUrlArray1 != NULL && paramUrlArray1.count > 0) {
                    for (NSInteger i = 0; i < paramUrlArray1.count; i++) {
                        NSString * parmStr = [paramUrlArray1 objectAtIndex:i];
                        NSArray * parmStrArray = [parmStr componentsSeparatedByString:@"="];
                        if (paramUrlArray1 != NULL && parmStrArray.count == 2) {
                            NSString *paramKey = [parmStrArray objectAtIndex:0];
                            NSString *paramValue = [parmStrArray objectAtIndex:1];
                            if (paramValue && paramKey) {
                                if (_thirdInfoDict == nil) {
                                    _thirdInfoDict = [[NSMutableDictionary dictionary] retain];
                                }
                                [_thirdInfoDict setValue:paramValue forKey:paramKey];
                            }
                        } else if (paramUrlArray1 != NULL && parmStrArray.count == 1) {
                            NSString * paramValue = [parmStrArray objectAtIndex:0];
                            if (paramValue) {
                                [self performSelector:@selector(delayLoadByOtherAppWithParam:) withObject:paramValue afterDelay:1.0];
                            }
                        }
                    }
                    if (_thirdInfoDict.count != 0) {
                        [self performSelector:@selector(delayLoadByOtherApp) withObject:self afterDelay:1.0];
                    }
                }
            }
        }
    }
    //支付完成后返回当前应用shi调用
    [self parseURL:url application:application];
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }];
    return YES;
}

- (void)delayLoadByOtherAppWithParam:(NSString *)param {
    NSString * jsSuccessCB = [NSString stringWithFormat:@"if(uexWidget.onLoadByOtherApp){uexWidget.onLoadByOtherApp(\'%@\');}",param];
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:jsSuccessCB];
    
}

- (void)delayLoadByOtherApp {
    NSString * josnStr = [_thirdInfoDict JSONFragment];
    NSString * jsSuccessCB = [NSString stringWithFormat:@"if(uexWidget.onLoadByOtherApp){uexWidget.onLoadByOtherApp(\'%@\');}",josnStr];
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:jsSuccessCB];
    self.thirdInfoDict = nil;
    
}



- (void)applicationWillResignActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    //	[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onSuspend();"];
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onSuspend){uexWidget.onSuspend();}"];
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillResignActive:application];
    }];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //data analysis
    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        id analysisObject = class_createInstance(analysisClass,0);
        [analysisObject ac_invoke:@"setAppBecomeActive" arguments:nil];
    }else{
        
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        
        if (analysisClass) {
            
            id analysisObject = class_createInstance(analysisClass,0);
            [analysisObject ac_invoke:@"setAppBecomeActive" arguments:nil];
        }
        
    }
    
    [self performSelector:@selector(onResume) withObject:self afterDelay:1.0];
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidBecomeActive:application];
    }];
    
    
    
}


-(void)onResume{
    
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onResume){uexWidget.onResume();}"];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onEnterBackground){uexWidget.onEnterBackground();}"];
    
    id number = [[NSUserDefaults standardUserDefaults] objectForKey:F_UD_BadgeNumber];
    if (number) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = [number intValue];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:F_UD_BadgeNumber];
        
    }
    
    [meBrwCtrler.meBrw stopAllNetService];
    //data analysis
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * viewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:2 appInfo:appInfo];
    
    if ([[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        for (EBrowserView * ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
        }
        
    }
    
    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        id analysisObject = class_createInstance(analysisClass,0);
        [analysisObject ac_invoke:@"setAppBecomeBackground"];
        //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
        
    }else{
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        if (analysisClass) {
            id analysisObject = class_createInstance(analysisClass,0);
            [analysisObject ac_invoke:@"setAppBecomeBackground"];
        }
    }
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidEnterBackground:application];
    }];
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onEnterForeground){uexWidget.onEnterForeground();}"];
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillEnterForeground:application];
    }];
    
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * goViewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    if (!goViewName || [goViewName isKindOfClass:[NSNull class]]) {
        [BUtility writeLog:@"appcan crash ....."];
        return;
        
    }
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
    [BUtility setAppCanViewActive:type opener:@"application://" name:goViewName openReason:0 mainWin:0 appInfo:appInfo];
    if ([[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        NSArray * popViewArray = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        for (EBrowserView * ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString * viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
        }
        
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillTerminate:application];
    }];
    
    
    //data analysis
    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        id analysisObject = class_createInstance(analysisClass,0);
        [analysisObject ac_invoke:@"setAppBecomeBackground"];
        //((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
    }else{
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        if (analysisClass) {
            id analysisObject = class_createInstance(analysisClass,0);
            [analysisObject ac_invoke:@"setAppBecomeBackground"];
            //((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
        }
        
    }
    
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * viewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:2 appInfo:appInfo];
    
    if ([[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
        
        NSArray * popViewArray = [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
        
        for (EBrowserView *ePopView in popViewArray) {
            
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            
        }
        
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
    [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onTerminate();"];
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    [BUtility writeLog:@"wigetone application receive memory warning"];
    
    // Remove and disable all URL Cache, but doesn't seem to affect the memory
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    // Remove all credential on release, but memory used doesn't move!
    NSURLCredentialStorage * credentialsStorage = [NSURLCredentialStorage sharedCredentialStorage];
    NSDictionary * allCredentials = [credentialsStorage allCredentials];
    
    for (NSURLProtectionSpace * protectionSpace in allCredentials) {
        NSDictionary * credentials = [credentialsStorage credentialsForProtectionSpace:protectionSpace];
        for (NSString * credentialKey in credentials) {
            [credentialsStorage removeCredential:[credentials objectForKey:credentialKey] forProtectionSpace:protectionSpace];
        }
    }
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidReceiveMemoryWarning:application];
    }];
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{

    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
    }];
}





- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    }];
    
}



- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler{
    __block BOOL shouldContinue = NO;
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        BOOL ret = [pluginClass application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
        if (ret) {
            *stop = YES;
            shouldContinue = YES;
        }
    }];
    return shouldContinue;
}


#pragma mark - root page finish loading

-(void)rootPageDidFinishLoading{
    [EBrowserWindow postWindowSequenceChange];
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass,BOOL *stop) {
        [pluginClass rootPageDidFinishLoading];
    }];
}




#pragma mark - UIAlertViewDelgate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (alertView.tag == kViewTagExit) {
        [BUtility exitWithClearData];
    }
    
}
- (void)dealloc {
    if(pluginObj){
        [pluginObj release];
        pluginObj = nil;
    }
    if (window) {
        [window release];
        window = nil;
    }
    if (meBrwCtrler) {
        [meBrwCtrler release];
        meBrwCtrler = nil;
    }
    if (mwWgtMgr) {
        [mwWgtMgr release];
        mwWgtMgr = nil;
    }
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
    
    [_leftWebController release];
    [_rightWebController release];
    [_drawerController release];
    [super dealloc];
}


- (void)enumeratePluginClassesResponsingToSelector:(SEL)selector withBlock:(void (^)(Class pluginClass, BOOL *stop))block{
    if (!block) {
        return;
    }
    BOOL stop = NO;
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        NSString *fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        Class clz = NSClassFromString(fullClassName);
        Method delegateMethod = class_getClassMethod(clz, selector);
        if (!delegateMethod) {
            continue;
        }
        block(clz,&stop);
        if (stop) {
            return;
        }
    }
    
}



#pragma mark - AppCanGlobalObjectGetter

- (id<AppCanWebViewEngineObject>)getAppCanRootWebViewEngine{
    return self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView;
}

- (id<AppCanWidgetObject>)getAppCanMainWidget{
    return self.meBrwCtrler.mwWgtMgr.mainWidget;
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }];
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }];
}

@end
