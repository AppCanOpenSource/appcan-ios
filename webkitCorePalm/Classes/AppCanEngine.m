/**
 *
 *	@file   	: AppCanEngine.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2017/1/10
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
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


#import "AppCanEngine.h"
#import "ACEPluginParser.h"
#import "BUtility.h"
#import "ACEDes.h"
#import "ACEConfigXML.h"
#import <AppCanKit/AppCanKit.h>
#import <objc/message.h>
#import "EBrowserController.h"
#import "ACEUINavigationController.h"

@interface ACEDefaultConfiguration : NSObject<AppCanEngineConfiguration>
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
@property (nonatomic, assign) BOOL useInAppCanIDE;


@property (nonatomic,strong) NSString *originWidgetPath;
@property (nonatomic,strong) NSString *documentWidgetPath;
@end

@implementation ACEDefaultConfiguration

- (instancetype)init{
    self = [super init];
    if (self) {
        _useStartReportURL = @"";
        _useAnalysisDataURL = @"";
        _useAppCanMAMURL = @"";
        _useAppCanMCMURL = @"";
        _useAppCanMDMURL = @"";
        _useAppCanEMMTenantID = @"";
        _useAppCanAppStoreHost = @"";
        _useAppCanMBaaSHost = @"";
        _useAppCanIMXMPPHost = @"";
        _useAppCanIMHTTPHost = @"";
        _useAppCanTaskSubmitSSOHost = @"";
        _useAppCanTaskSubmitHost = @"";
        _originWidgetPath = @"widget";
        _documentWidgetPath = @"widget";
    }
    return self;
}

@end

static id<AppCanEngineConfiguration> _globalConfiguration;
static EBrowserController *_rootController;
static ACEUINavigationController *_mainWidgetController;



@implementation AppCanEngine


+ (void)initializeWithConfiguration:(id<AppCanEngineConfiguration>)configuration{
    _globalConfiguration = configuration;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dyFiles"];
    
    if (![fileManager fileExistsAtPath:writableDBPath])  {
        NSString  *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dyFiles"];
        [BUtility copyMissingFile:defaultDBPath toPath:documentsDirectory];
    }
    //设置Debug日志
    ONOXMLElement *debug = [[ACEConfigXML ACEWidgetConfigXML] firstChildWithTag:@"debug"];
    NSString *debugEnable = debug[@"enable"];
    NSString *debugVerbose = debug[@"verbose"];
    if (debugEnable.boolValue) {
        if (debugVerbose.boolValue) {
            ACLogSetGlobalLogMode(ACLogModeVerbose);
        }else{
            ACLogSetGlobalLogMode(ACLogModeDebug);
        }
    }
    
    _rootController = [[EBrowserController alloc] initWithMainWidget];
    _rootController.isAppCanRootViewController = YES;
    _mainWidgetController = [[ACEUINavigationController alloc] initWithEBrowserController:_rootController];
    _rootController.aceNaviController = _mainWidgetController;
    
}

+ (EBrowserController *)rootWebViewController{
    return _rootController;
}
+ (__kindof UINavigationController *)mainWidgetController{
    return _mainWidgetController;
}
+ (void)enumeratePluginClassesResponsingToSelector:(SEL)selector withBlock:(void (^)(Class pluginClass, BOOL *stop))block{
    if (!block) {
        return;
    }
    BOOL stop = NO;
    NSArray *allPLugins = [ACEPluginParser sharedParser].classNameArray;
    for (NSInteger i = 0; i < [allPLugins count]; i++) {
        NSString *className = allPLugins[i];
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



+ (id<AppCanEngineConfiguration>)configuration{
    static id<AppCanEngineConfiguration> dafaultConfiguration = nil;
    if (!_globalConfiguration) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dafaultConfiguration = [[ACEDefaultConfiguration alloc] init];
        });
        return dafaultConfiguration;
    }
    return _globalConfiguration;
}

#pragma mark - UIAlertViewDelgate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [BUtility exitWithClearData];
    
    
}

#pragma mark - Application Delegate Event
+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    

    if(self.configuration.useInAppCanIDE){
        [BUtility setAppCanDevMode:@"YES"];
    }
    [ACEDes enable];
    
    if (self.configuration.useCloseAppWithJaibroken && [BUtility isJailbroken]) {
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:ACELocalized(@"提示") message:ACELocalized(@"本应用仅适用未越狱机，即将关闭。") delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    

   
    if(self.configuration.usePushControl) {
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        //注册推送
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }

    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didFinishLaunchingWithOptions:launchOptions];
    }];
    return YES;
    
}


+ (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
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

+ (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:app didFailToRegisterForRemoteNotificationsWithError:err];
    }];
}
// 接收推送通知

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }];
    
}



+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didReceiveRemoteNotification:userInfo];
    }];
    
}

+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application didReceiveLocalNotification:notification];
    }];
}

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (!url) return NO;
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application handleOpenURL:url];
    }];
    return YES;
    
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if (!url) return NO;
    

    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }];
    return YES;
}



+ (void)applicationWillResignActive:(UIApplication *)application {

    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillResignActive:application];
    }];
    
    
}

+ (void)applicationDidBecomeActive:(UIApplication *)application {
//    
//    //data analysis
//    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis")?:NSClassFromString(@"AppCanAnalysis");
//    if (analysisClass) {
//        id analysisObject = [[analysisClass alloc] init];
//        [analysisObject ac_invoke:@"setAppBecomeActive" arguments:nil];
//    }
//    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidBecomeActive:application];
    }];
    
    
    
}


+ (void)applicationDidEnterBackground:(UIApplication *)application {
    
//    
//    id number = [[NSUserDefaults standardUserDefaults] objectForKey:F_UD_BadgeNumber];
//    if (number) {
//        
//        [UIApplication sharedApplication].applicationIconBadgeNumber = [number intValue];
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:F_UD_BadgeNumber];
//        
//    }
//    
//    [self.meBrwCtrler.meBrw stopAllNetService];
//    //data analysis
//    int type = [[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
//    NSString * viewName =[[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
//    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
//    [BUtility setAppCanViewBackground:type name:viewName closeReason:2 appInfo:appInfo];
//    
//    if ([[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
//        
//        NSArray * popViewArray = [[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
//        for (EBrowserView * ePopView in popViewArray) {
//            int type =ePopView.mwWgt.wgtType;
//            NSString *viewName =[ePopView.curUrl absoluteString];
//            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
//            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
//        }
//        
//    }
//    
//    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis")?:NSClassFromString(@"AppCanAnalysis");
//    if (analysisClass) {//类不存在直接返回
//        id analysisObject = [[analysisClass alloc] init];
//        [analysisObject ac_invoke:@"setAppBecomeBackground"];
//    }
//    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidEnterBackground:application];
    }];
    
    
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillEnterForeground:application];
    }];
    
//    int type = [[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
//    NSString * goViewName =[[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
//    if (!goViewName || [goViewName isKindOfClass:[NSNull class]]) {
//        return;
//        
//    }
//    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
//    [BUtility setAppCanViewActive:type opener:@"application://" name:goViewName openReason:0 mainWin:0 appInfo:appInfo];
//    if ([[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
//        NSArray * popViewArray = [[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
//        for (EBrowserView * ePopView in popViewArray) {
//            int type =ePopView.mwWgt.wgtType;
//            NSString * viewName =[ePopView.curUrl absoluteString];
//            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
//            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
//        }
//        
//    }
    
}

+ (void)applicationWillTerminate:(UIApplication *)application {
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillTerminate:application];
    }];
    
//    
//    //data analysis
//    Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis") ?: NSClassFromString(@"AppCanAnalysis");
//    if (analysisClass) {//类不存在直接返回
//        id analysisObject = [[analysisClass alloc] init];
//        [analysisObject ac_invoke:@"setAppBecomeBackground"];
//    }
//    
//    int type = [[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt.wgtType;
//    NSString * viewName =[[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.curUrl absoluteString];
//    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView.mwWgt];
//    [BUtility setAppCanViewBackground:type name:viewName closeReason:2 appInfo:appInfo];
//    
//    if ([[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict) {
//        
//        NSArray * popViewArray = [[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].mPopoverBrwViewDict allValues];
//        
//        for (EBrowserView *ePopView in popViewArray) {
//            
//            int type =ePopView.mwWgt.wgtType;
//            NSString *viewName =[ePopView.curUrl absoluteString];
//            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
//            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
//            
//        }
//        
//    }
//    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = -1;
//    [[[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"uexWidget.onTerminate();"];
    
}

+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidReceiveMemoryWarning:application];
    }];
}

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application performActionForShortcutItem:shortcutItem completionHandler:completionHandler];
    }];
}

+ (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass application:application handleEventsForBackgroundURLSession:identifier completionHandler:completionHandler];
    }];
    
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler{
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



#pragma mark - UNNotificationCenter Delegate Event


+ (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(NSUInteger))completionHandler{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass userNotificationCenter:center willPresentNotification:notification withCompletionHandler:completionHandler];
    }];
}
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    }];
}

#pragma mark - rootPageDidFinishLoading
+ (void)rootPageDidFinishLoading{
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass,BOOL *stop) {
        [pluginClass rootPageDidFinishLoading];
    }];
}



@end
