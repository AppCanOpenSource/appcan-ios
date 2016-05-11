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
#import "EUExBase.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "EUExBaseDefine.h"
#import "ACEUtils.h"
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
#define kViewTagExit 100
#define kViewTagLocalNotification 200

#define ACE_USERAGENT @"AppCanUserAgent"


@interface WidgetOneDelegate()<RESideMenuDelegate>

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

/*




NSString *AppCanJS = nil;



-(void)readAppCanJS {
    
    NSString * baseJS = nil;
    
    if (_useRC4EncryptWithLocalstorage) {
        
        baseJS = [NSString stringWithFormat:@"%@\n%@",[BUtility getBaseJSKey],[BUtility getRC4LocalStoreJSKey]];
        
    } else {
        
        baseJS = [BUtility getBaseJSKey];
        
    }
    
    pluginObj = [[ACEPluginParser alloc] init] ;
    NSString *pluginJS = [pluginObj pluginBaseJS];
    
	if (pluginJS && [pluginJS length] > 0) {
        
		AppCanJS = [[NSString alloc] initWithFormat:@"%@\n%@",baseJS,pluginJS];
        
	} else {
        
		AppCanJS = [[NSString alloc] initWithFormat:@"%@\n",baseJS];
        
	}
    
}
*/
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
            if (payObj) {
                
                [payObj performSelector:@selector(parseURL:application:) withObject:url withObject:application];
                
            }
            
        }
        
    }
    
}
- (BOOL)isSingleTask {
    
	struct utsname name;
	uname(&name);
    
	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
    
	if (version < 4.0 || strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0) {
        
		return YES;
        
	} else {
        
		return NO;
        
	}
    
}



- (id)init{
    
    self = [super init];
    
    if (self != nil) {
        
		// set cookie storage:
		NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
		//[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyOnlyFromMainDocumentDomain];
		//[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyNever];
		[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
		//NSLog(@"cookie accept policy is %d", [cookieStorage cookieAcceptPolicy]);
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCookiesChange:) name:NSHTTPCookieManagerCookiesChangedNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedCookiesPolicyChange:) name:NSHTTPCookieManagerAcceptPolicyChangedNotification object:nil];
		// set cache storage:
		/*NSURLCache *cacheStorage = [[NSURLCache alloc] initWithMemoryCapacity:512000
         diskCapacity:100000000
         diskPath:@"zd111"];*/
		//[NSURLCache setSharedURLCache:cacheStorage];
        //		NSURLCache *cacheStorage = [NSURLCache sharedURLCache];
        //		NSLog(@"cache disk size: %d", [cacheStorage diskCapacity]);
        //		NSLog(@"cache disk used size: %d", [cacheStorage currentDiskUsage]);
        //		NSLog(@"cache memory size: %d", [cacheStorage memoryCapacity]);
        //		NSLog(@"cache memory used size: %d", [cacheStorage currentMemoryUsage]);
		//[cacheStorage release];
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

- (void)stopAllNetService {
    
	if (!meBrwCtrler) {
        
		return;
        
	}
	if (!meBrwCtrler.meBrw) {
        
		[meBrwCtrler.meBrw stopAllNetService];
        
	}
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL success;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dyFiles"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success)  {
        //
    } else {
        
        NSString  *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dyFiles"];
        
        success = [BUtility copyMissingFile:defaultDBPath toPath:documentsDirectory];
        if (!success) {
            //
        }
        
    }
    
    [ACEDes enable];
    [BUtility setAppCanDocument];
    _globalPluginDict = [[NSMutableDictionary alloc] init];
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
         NSLog(@"appcan--widgetOneDelegate.m--didFinishLaunchingWithOptions--dict == %@",dict);
        
        if (dict) {
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"allPushData"];
            [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"appStateOfGetPushData"];

        }
        
        if (userData != nil) {
            
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
            
        }
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
	//应用从未启动到启动，获取本地通知信息
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey] ) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
    }
    
    
    
    Class analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    
    if (analysisClass) {
        
        id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ((void(*)(id, SEL,BOOL))objc_msgSend)(analysisObject, @selector(setErrorReport:), YES);
#pragma clang diagnostic pop
    }else{
        
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        
        if (analysisClass) {
            id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            ((void(*)(id, SEL,BOOL))objc_msgSend)(analysisObject, @selector(setErrorReport:), YES);
#pragma clang diagnostic pop
            
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
        if (ACE_iOSVersion >= 8.0)  {
            
#ifdef __IPHONE_8_0
            
            UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
            //注册推送
            [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
#endif
            
        } else {
            
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
            
        }
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
	//支付宝支付－－》4.0以前为单任务
	if ([self isSingleTask]) {
        
		NSURL * url = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
		
		if (nil != url) {
            
			[self parseURL:url application:application];
            
		}
        
	}
    
    [self invokeAppDelegateMethod:application didFinishLaunchingWithOptions:launchOptions];


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
    
    [self invokeAppDelegateMethod:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
}
// 注册APNs错误

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    [self invokeAppDelegateMethod:app didFailToRegisterForRemoteNotificationsWithError:err];
}
// 接收推送通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    NSUserDefaults *appStateUD = [NSUserDefaults standardUserDefaults];
    
    NSString *userData = [userInfo objectForKey:@"userInfo"];
    if (userInfo) {
        
        [appStateUD setObject:userInfo forKey:@"allPushData"];
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
    
    [self invokeAppDelegateMethod:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    {
        NSLog(@"appcan--widgetOneDelegate.m--didReceiveRemoteNotification--userInfo == %@",userInfo);
        NSString *userinfoJson=[userInfo JSONFragment];
        NSString *Json=[NSString stringWithFormat:@"uexWidget.onRemoteNotification(\'%@\');",userinfoJson];
        [[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:Json];
        
    }
    
    NSString *userData = [userInfo objectForKey:@"userInfo"];
    if (userInfo) {
        [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"allPushData"];
    }
    if (userData != nil || userInfo) {
        
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
        EBrowserWindowContainer * aboveWindowContainer = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
        
        if (aboveWindowContainer) {
            
            [aboveWindowContainer pushNotify];
            
        }
        
        //		if (meBrwCtrler) {
        //			if (meBrwCtrler.meBrwMainFrm) {
        //				if (meBrwCtrler.meBrwMainFrm.meBrwWgtContainer) {
        //					if ([meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer]) {
        //						[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] pushNotify];
        //					}
        //				}
        //			}
        //		}
        
    }
    
    [self invokeAppDelegateMethod:application didReceiveRemoteNotification:userInfo];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
   /*
	UIApplicationState state = [application applicationState];
    
	if (state == UIApplicationStateActive) {
        
        //		NSString *notID = [notification.userInfo objectForKey:@"notificationId"];
		NSString * msg = [notification.userInfo objectForKey:@"msg"];
        //		NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\', \'%@\')", notID, msg];
        //		EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
        //		if (brwView) {
        //			[brwView  stringByEvaluatingJavaScriptFromString:jsStr];
        //		}
		application.applicationIconBadgeNumber = 0;
		UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:ACELocalized(@"提示") message:msg delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
		alertView.tag = kViewTagLocalNotification;
		[alertView show];
		[alertView release];
        
	} else {
        
		NSString * notID = [notification.userInfo objectForKey:@"notificationId"];
		NSString * jsStr = [NSString stringWithFormat:@"uexLocalNotification.onActive(\'%@\')", notID];
		EBrowserView *brwView = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer].meRootBrwWnd.meBrwView;
		if (brwView) {
            
			[brwView  stringByEvaluatingJavaScriptFromString:jsStr];
            
		}
		application.applicationIconBadgeNumber = 0;
        
	}
    */
    [self invokeAppDelegateMethod:application didReceiveLocalNotification:notification];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
	//支付完成后返回当前应用shi调用
	[self parseURL:url application:application];
    
    [self invokeAppDelegateMethod:application handleOpenURL:url];
    
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
    
    [self invokeAppDelegateMethod:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
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
    
    [self invokeAppDelegateMethodApplicationWillResignActive:application];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    //data analysis
    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

        ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeActive));
#pragma clang diagnostic pop
        //objc_msgSend(analysisObject, @selector(setAppBecomeActive),nil);
    }else{
        
    analysisClass = NSClassFromString(@"AppCanAnalysis");
        
        if (analysisClass) {
            
            id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            
            ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeActive));
#pragma clang diagnostic pop
            //objc_msgSend(analysisObject, @selector(setAppBecomeActive),nil);
        }
    
    }
    
    [self performSelector:@selector(onResume) withObject:self afterDelay:1.0];
    
    [self invokeAppDelegateMethodApplicationDidBecomeActive:application];
    
    /*
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [EBrowserWindow postWindowSequenceChange];
    });
     */
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
    
	[self stopAllNetService];
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
            //[BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1];
            
        }
        
    }
    
    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    if (analysisClass) {//类不存在直接返回
        
        id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
#pragma clang diagnostic pop
        
        //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
        
    }else{
        
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        
        if (analysisClass) {
            
            id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
#pragma clang diagnostic pop
            
            //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
            
        }
        
    }
    
    [self invokeAppDelegateMethodApplicationDidEnterBackground:application];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onEnterForeground){uexWidget.onEnterForeground();}"];
    
    [self invokeAppDelegateMethodApplicationWillEnterForeground:application];
	//[self startAllNetService];
    int type = [[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
    NSString * goViewName =[[[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
    //[BUtility setAppCanViewBackground:type name:viewName closeReason:2];
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
    
    [self invokeAppDelegateMethodApplicationWillTerminate:application];
    
    //data analysis
    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
    
    if (analysisClass) {//类不存在直接返回
        
        id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
        //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
#pragma clang diagnostic pop
    }else{
    
        analysisClass = NSClassFromString(@"AppCanAnalysis");
        
        if (analysisClass) {
            id analysisObject = class_createInstance(analysisClass,0);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            ((void(*)(id, SEL))objc_msgSend)(analysisObject, @selector(setAppBecomeBackground));
            //objc_msgSend(analysisObject, @selector(setAppBecomeBackground),nil);
#pragma clang diagnostic pop

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
    // empty the tmp directory
    //    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    //    NSError* err = nil;
    //
    //    // clear contents of NSTemporaryDirectory
    //    NSString* tempDirectoryPath = NSTemporaryDirectory();
    //    NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
    //    NSString* fileName = nil;
    //    BOOL result;
    //
    //    while ((fileName = [directoryEnumerator nextObject])) {
    //        NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
    //        result = [fileMgr removeItemAtPath:filePath error:&err];
    //        if (!result && err) {
    //            ACENSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
    //        }
    //    }
    //    [fileMgr release];
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
    
    [self invokeAppDelegateMethodApplicationDidReceiveMemoryWarning:application];
    
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{

    [self invokeAppDelegateMethodApplication:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];

}



-(void)invokeAppDelegateMethodApplication:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:performActionForShortcutItem:completionHandler:));
        
        if (delegateMethod) {

            [acecls application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
            
        }
    }
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    [self invokeAppDelegateMethodApplication:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
}

-(void)invokeAppDelegateMethodApplication:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:handleEventsForBackgroundURLSession:completionHandler:));
        
        if (delegateMethod) {
            [acecls application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
            
        }
    }
}


#pragma mark - root page finish loading invokation

-(void)rootPageDidFinishLoading{
    [EBrowserWindow postWindowSequenceChange];
    [self invokeRootPageDidFinishLoading];
    
}
- (void)invokeRootPageDidFinishLoading
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(rootPageDidFinishLoading));
        
        if (delegateMethod) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
            [acecls rootPageDidFinishLoading];
#pragma clang diagnostic pop
    
        }
    }
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
    [_globalPluginDict release];
	[super dealloc];
}

- (void)invokeAppDelegateMethod:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:didFinishLaunchingWithOptions:));
        
        if (delegateMethod) {
            
            
            [acecls application:application didFinishLaunchingWithOptions:launchOptions];
            
        }
    }
}

- (void)invokeAppDelegateMethod:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:));
        
        if (delegateMethod) {
            
            
            [acecls application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
            
        }
    }
}

- (void)invokeAppDelegateMethod:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)er
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:didFailToRegisterForRemoteNotificationsWithError:));
        
        if (delegateMethod) {
            
            
            [acecls application:app didFailToRegisterForRemoteNotificationsWithError:er];
            
        }
    }
}

- (void)invokeAppDelegateMethod:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString * className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:));
        
        if (delegateMethod) {
            
            [acecls application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
            
        }
        
    }
    
}

- (void)invokeAppDelegateMethod:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:didReceiveRemoteNotification:));
        
        if (delegateMethod) {
            
            
            [acecls application:application didReceiveRemoteNotification:userInfo];
            
        }
    }
}

- (void)invokeAppDelegateMethod:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:didReceiveLocalNotification:));
        
        if (delegateMethod) {
            
            
            [acecls application:application didReceiveLocalNotification:notification];
            
        }
    }
}

- (BOOL)invokeAppDelegateMethod:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:handleOpenURL:));
        
        if (delegateMethod) {
            
            
            [acecls application:application handleOpenURL:url];
            
        }
    }
    
    return YES;
}

-(BOOL)invokeAppDelegateMethod:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(application:openURL:sourceApplication:annotation:));
        
        if (delegateMethod) {
            
            
            [acecls application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
            
        }
    }
    
    return YES;
}
- (void)invokeAppDelegateMethodApplicationWillResignActive:(UIApplication *)application
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(applicationWillResignActive:));
        
        if (delegateMethod) {
            
            
            [acecls applicationWillResignActive:application];
            
        }
    }
}

- (void)invokeAppDelegateMethodApplicationDidBecomeActive:(UIApplication *)application
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(applicationDidBecomeActive:));
        
        if (delegateMethod) {
            
            
            [acecls applicationDidBecomeActive:application];
            
        }
    }
}

- (void)invokeAppDelegateMethodApplicationDidEnterBackground:(UIApplication *)application
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(applicationDidEnterBackground:));
        
        if (delegateMethod) {
            
            
            [acecls applicationDidEnterBackground:application];
            
        }
    }
}

- (void)invokeAppDelegateMethodApplicationWillEnterForeground:(UIApplication *)application
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(applicationWillEnterForeground:));
        
        if (delegateMethod) {
            
            
            [acecls applicationWillEnterForeground:application];
            
        }
    }
}

- (void)invokeAppDelegateMethodApplicationWillTerminate:(UIApplication *)application
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(applicationWillTerminate:));
        
        if (delegateMethod) {
            
            
            [acecls applicationWillTerminate:application];
            
        }
    }
}

- (void)invokeAppDelegateMethodApplicationDidReceiveMemoryWarning:(UIApplication *)application
{
    for (NSInteger i = 0; i < [pluginObj.classNameArray count]; i++) {
        
        NSString *className = [pluginObj.classNameArray objectAtIndex:i];
        
        NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        
        Class acecls = NSClassFromString(fullClassName);
        
        Method delegateMethod = class_getClassMethod(acecls, @selector(applicationDidReceiveMemoryWarning:));
        
        if (delegateMethod) {
            
            
            [acecls applicationDidReceiveMemoryWarning:application];
            
        }
    }
}
@end
