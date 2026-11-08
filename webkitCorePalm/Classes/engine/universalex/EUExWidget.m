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

#import "EUExWidget.h"
#import "WWidgetMgr.h"
#import "EBrowserView.h"
#import "EBrowserController.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserToolBar.h"
#import "EBrowser.h"
#import "WWidget.h"
#import "BUtility.h"
#import "ACEURLSession.h"
#import "WidgetOneDelegate.h"
#import <Security/Security.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "EUtility.h"

#import "DataAnalysisInfo.h"
#import "ACEDrawerViewController.h"

#import <CommonCrypto/CommonCrypto.h>
#import <AppCanKit/ACEXTScope.h>
#import <AppCanKit/ACInvoker.h>
#import "ACEConfigXML.h"
#import "ACEInterfaceOrientation.h"

#import "ACEUINavigationController.h"
#import "ACESubwidgetManager.h"

#import <UserNotifications/UserNotifications.h>

#import "ACETransitionView.h"


#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"

static NSString *const kUexPushNotifyBrwViewNameKey=@"kUexPushNotifyBrwViewNameKey";
static NSString *const kUexPushNotifyCallbackFunctionNameKey=@"kUexPushNotifyCallbackFunctionNameKey";


@interface EUExWidget()<AppCanApplicationEventObserver>
@property (nonatomic,readonly)EBrowserView *EBrwView;
//子应用启动过渡动画
@property (nonatomic,strong)ACETransitionView *ACEMPTransitionView;
@end

@implementation EUExWidget

typedef NS_ENUM(NSInteger,uexWidgetPushStatus){
    uexWidgetPushWhenAppLaunched = 0,
    uexWidgetPushWhenAppInBackground,
    uexWidgetPushWhenAppInForeground
};





#pragma marl - Application Event




+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    [self onReceivePushNotification:userInfo];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [self onReceivePushNotification:userInfo];
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    [self onReceivePushNotification:userInfo];
    
}

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(NSUInteger))completionHandler{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    [self onReceivePushNotification:userInfo];
    
    
}
+ (void)onReceivePushNotification:(NSDictionary *)userInfo{
    if (!userInfo) {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:userInfo forKey:@"allPushData"];
    [ud setObject:userInfo[@"userInfo"] forKey:@"pushData"];
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateBackground:
            return;
        case UIApplicationStateActive:
            [self pushNotifyWithState:uexWidgetPushWhenAppInForeground];
            break;
        case UIApplicationStateInactive:
            [self pushNotifyWithState:uexWidgetPushWhenAppInBackground];
            break;
    }
}


static BOOL isAppLaunchedByPush = NO;


+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //应用从未启动到启动，获取推送信息
    if (launchOptions && [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] ) {
        isAppLaunchedByPush = YES;
        NSDictionary *dict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSString *userData = [dict objectForKey:@"userInfo"];
        if (dict) {
            [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"allPushData"];
        }
        if (userData != nil) {
            [[NSUserDefaults standardUserDefaults] setObject:userData forKey:@"pushData"];
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    
    
    
    return YES;
}

+ (void)rootPageDidFinishLoading{
    if(isAppLaunchedByPush){
        [self pushNotifyWithState:uexWidgetPushWhenAppLaunched];
    }
}

+ (void)pushNotifyWithState:(uexWidgetPushStatus)state {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *pushNotifyBrwViewName = [defaults stringForKey:kUexPushNotifyBrwViewNameKey];
    NSString *pushNotifyCallbackFunctionName = [defaults stringForKey:kUexPushNotifyCallbackFunctionNameKey];
    if (!pushNotifyBrwViewName || !pushNotifyCallbackFunctionName) {
        return;
    }
    EBrowserWindow *eBrwWnd = [[AppCanEngine.rootWebViewController.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] brwWndForKey:pushNotifyBrwViewName];
    if (!eBrwWnd) {
        return;
    }
    [eBrwWnd.meBrwView callbackWithFunctionKeyPath:pushNotifyCallbackFunctionName arguments:@[@(state)]];

    
}





+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *cbString = [url query];
    for (NSURLQueryItem *item in components.queryItems){
        [params setValue:item.value forKey:item.name];
    }
    if (params.count > 0) {
        cbString = [params ac_JSONFragment];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexWidget.onLoadByOtherApp" arguments:ACArgsPack(cbString)];
    });
    
    
    return YES;
}

+ (void)applicationWillResignActive:(UIApplication *)application{
    [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexWidget.onSuspend" arguments:nil];
}

/// 推送业务的配置适配层：请求类只接收参数，不依赖引擎或插件全局对象。
+ (void)postPushURL:(NSURL *)URL headers:(NSDictionary *)headers body:(NSData *)body
validatesServerCertificate:(BOOL)validatesServerCertificate
useClientCertificate:(BOOL)useClientCertificate completion:(ACEURLSessionCompletion)completion {
    NSData *certificate = useClientCertificate ? [NSData dataWithContentsOfFile:[BUtility clientCertficatePath]] : nil;
    [ACEURLSession postURL:URL headers:headers body:body
validatesServerCertificate:validatesServerCertificate
    clientCertificateData:certificate certificatePassword:AppCanEngine.configuration.useCertificatePassWord
               completion:completion];
}

+ (void)applicationDidBecomeActive:(UIApplication *)application{
    
     [AppCanRootWebViewEngine() callbackWithFunctionKeyPath:@"uexWidget.onResume" arguments:nil];
    
    if(!AppCanEngine.configuration.usePushControl) {//推送开关没有开启
        return;
    }
    
    if ([AppCanEngine.configuration.useBindUserPushURL rangeOfString:@"gateway"].location == NSNotFound) {//URL里包含“gateway”的才是v4后台，否则没有清零逻辑。
        return;
    }
    
    NSString *urlStr =[NSString stringWithFormat:@"%@4.0/count/",AppCanEngine.configuration.useBindUserPushURL];
    NSURL *requestUrl = [NSURL URLWithString:urlStr];
    NSString *appid = [WWidgetMgr sharedManager].mainWidget.appId ?: @"";
    NSString *appkey = [BUtility appKey] ? [BUtility appKey] : @"";
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] ? [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] : @"";
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    NSString *appverify = [BUtility getVarifyAppMd5Code:appid AppKey:appkey time:time];
    NSString *softToken = [EUtility md5SoftToken];
    
    NSMutableDictionary *headerDict = [NSMutableDictionary dictionaryWithObject:appverify forKey:@"appverify"];
    [headerDict setObject:@"application/json" forKey:@"Content-Type"];
    NSString *masAppId = [NSString stringWithFormat:@"%@", appid];
    [headerDict setObject:masAppId forKey:@"x-mas-app-id"];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionaryWithCapacity:5];
    [bodyDict setObject:@"1" forKey:@"count"];
    [bodyDict setObject:deviceToken forKey:@"deviceToken"];
    [bodyDict setObject:softToken forKey:@"softToken"];
    NSString *useAppCanEMMTenantID = AppCanEngine.configuration.useAppCanEMMTenantID ?: @"";
    [bodyDict setObject:useAppCanEMMTenantID forKey:@"tenantMark"];
    [self postPushURL:requestUrl headers:headerDict
                 body:[[bodyDict ac_JSONFragment] dataUsingEncoding:NSUTF8StringEncoding]
validatesServerCertificate:YES useClientCertificate:NO
           completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        ACLogDebug(@"AppCan EUExWidget 激活计数完成，HTTP=%ld，error=%@", (long)response.statusCode, error);
    }];
    
    
   
    
}


#pragma mark - EBrowserView Getter

- (EBrowserView *)EBrwView{
    id brwView = [self webViewEngine];
    BOOL isEBrowserView = [brwView isKindOfClass:[EBrowserView class]];
    NSAssert(isEBrowserView,@"uexWidget only use for EBrowserView *");
    return isEBrowserView ? brwView : nil;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex == 0) {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSError* err = nil;
        // clear contents of NSTemporaryDirectory
        NSString* tempDirectoryPath = NSTemporaryDirectory();
        NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
        NSString* fileName = nil;
        BOOL result;
        
        while ((fileName = [directoryEnumerator nextObject])) {
            NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
            result = [fileMgr removeItemAtPath:filePath error:&err];
            if (!result && err) {
                ACLogDebug(@"Failed to delete: %@ (error: %@)", filePath, err);
                
            }
        }
        exit(0);
    }
}
- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        
    }
    return self;
}





- (void)reloadWidgetByAppId:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *appId) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(appId);
    
    [[ACESubwidgetManager defaultManager] reloadWidgetByID:appId];
    
}

- (void)setLogServerIp:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *logServerIp,NSNumber *isDebug) = inArguments;
    WWidget *inCurWgt = self.EBrwView.mwWgt;
    if (logServerIp) {
        inCurWgt.logServerIp = logServerIp;
    }
    if (isDebug) {
        inCurWgt.isDebug = isDebug.boolValue;
    }
    
}

- (WWidget*)getStartWgtByAppId:(NSString*)inAppId{
    WWidgetMgr *wgtMgr = [WWidgetMgr sharedManager];
    WWidget * mainWgt = [wgtMgr mainWidget];
    WWidget *startWgt = nil;
    startWgt = (WWidget*)[wgtMgr wgtPluginDataByAppId:inAppId curWgt:mainWgt];
    //plugin
    if (startWgt) {
        return startWgt;
    }
    
    startWgt = [wgtMgr wgtDataByAppId:inAppId];
    
    return startWgt;
}

//该类的实例化方法，暂时仅供startWidgetWithConfig使用
- (WWidget*)getNewStartWgtByAppId:(NSString*)inAppId infoDic:(NSDictionary *)infoDic{
    WWidgetMgr *wgtMgr = [WWidgetMgr sharedManager];
    WWidget * mainWgt = [wgtMgr mainWidget];
    WWidget *startWgt = nil;
    startWgt = (WWidget*)[wgtMgr wgtOptionsDataByAppId:inAppId curWgt:mainWgt infoDic:infoDic];
    
    return startWgt;
}

- (void)startWidgetWithConfig:(NSMutableArray *)inArguments {
    
    __block NSNumber *startWidgetResult = @1;
    __block UEX_ERROR err = kUexNoError;
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    @onExit{
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbStartWidgetWithConfig" arguments:ACArgsPack(@0,@2,startWidgetResult)];
        [cb executeWithArguments:ACArgsPack(err)];
    };
    
    if (self.EBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) {
        
        startWidgetResult = @2;
        err = uexErrorMake(1,@"widget正在加载");
        
        return;
    }
    
    ACArgsUnpack(NSString *inWidgetName,NSString *inAppIcon,NSString *inAppLoadingStatus,NSString *inAppId,NSNumber *inAnimiId,NSString *closeCallbackFuncName,NSString *inOpenerInfo,NSNumber *inAnimiDuration,NSString *inAppkey,NSDictionary *inIndexWindowOptionDic) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inWidgetName = stringArg(info[@"widgetName"]);
        inAppIcon = stringArg(info[@"appIcon"]);
        inAppLoadingStatus = stringArg(info[@"appLoadingStatus"]);
        inAppId = stringArg(info[@"appId"]);
        inAnimiId = numberArg(info[@"animId"]);
        closeCallbackFuncName = stringArg(info[@"cbFuncName"]);
        inOpenerInfo = stringArg(info[@"startInfo"]);
        inAnimiDuration = numberArg(info[@"animDuration"]);
        inAppkey = stringArg(info[@"appkey"]);
        inIndexWindowOptionDic = dictionaryArg(info[@"indexWindowOptions"]);
    }
    
    ACEMPWindowOptions *indexWindowOptions = nil;
    if (inIndexWindowOptionDic) {
        indexWindowOptions = [[ACEMPWindowOptions alloc] init];
        indexWindowOptions.flag = [numberArg(inIndexWindowOptionDic[@"flag"]) intValue];
        indexWindowOptions.windowStyle = [numberArg(inIndexWindowOptionDic[@"windowStyle"]) intValue];
        
        NSDictionary *optionDic = dictionaryArg(inIndexWindowOptionDic[@"windowOptions"]);
        
        if (optionDic) {
            
            indexWindowOptions.windowTitle = stringArg(optionDic[@"windowTitle"]);
            indexWindowOptions.isBottomBarShow = [stringArg(optionDic[@"isBottomBarShow"]) boolValue];
            
            indexWindowOptions.titleBarBgColor = stringArg(optionDic[@"titleBarBgColor"]);
            indexWindowOptions.titleTextColor = stringArg(optionDic[@"titleTextColor"]);
            
            if (stringArg(optionDic[@"titleLeftIcon"])) {
                indexWindowOptions.titleLeftIcon = [self absPath:stringArg(optionDic[@"titleLeftIcon"])];
            }
            if (stringArg(optionDic[@"titleRightIcon"])) {
                indexWindowOptions.titleRightIcon = [self absPath:stringArg(optionDic[@"titleRightIcon"])];
            }
            if (stringArg(optionDic[@"titleCloseIcon"])) {
                indexWindowOptions.titleCloseIcon = [self absPath:stringArg(optionDic[@"titleCloseIcon"])];
            }
            
            indexWindowOptions.menuList = arrayArg(optionDic[@"menuList"]);
        }
        
        NSDictionary *extrasDic = dictionaryArg(inIndexWindowOptionDic[@"extras"]);
        if (extrasDic) {
            indexWindowOptions.extras = extrasDic;
        }
        
        indexWindowOptions.uexWidget = self;
    }
    
    
    UEX_PARAM_GUARD_NOT_NIL(inAppId);
    
    
    WWidget *wgtObj = [self getNewStartWgtByAppId:inAppId infoDic:info];
    if (!wgtObj) {//
        err = uexErrorMake(1,@"inAppId对应的widget未找到");
        return;
    }
    
    NSTimeInterval animiDuration = 0.2f;
    if (inAnimiDuration && inAnimiDuration.floatValue > 0) {
        animiDuration = inAnimiDuration.floatValue / 1000;
    }
    
    if(inAppkey){
        wgtObj.appKey = inAppkey;
    }
    
    if (inWidgetName) {
        wgtObj.widgetName = inWidgetName;
    }
    if (inAppIcon) {
        wgtObj.appIcon = [self absPath:inAppIcon];
    }
    wgtObj.appLoadingStatus = [inAppLoadingStatus boolValue];
    
    wgtObj.closeCallbackName = closeCallbackFuncName;
    wgtObj.openMessage = inOpenerInfo;
    wgtObj.openAnimation = inAnimiId.unsignedIntegerValue;
    wgtObj.openAnimationDuration = animiDuration;
    
    wgtObj.indexWindowOptions = indexWindowOptions;
    
    wgtObj.isFirstStartWithConfig = YES;
    
    BOOL ret = [[ACESubwidgetManager defaultManager] launchWidget:wgtObj];
    
    startWidgetResult = ret ? @0 : @1;
    
    if (wgtObj.indexUrl.length > 10) {
        if (![[NSFileManager defaultManager]fileExistsAtPath:wgtObj.indexUrl]) {
            startWidgetResult = @3;
        }
    }else{
        startWidgetResult = @3;
    }
    
    if (ret && wgtObj.appLoadingStatus) {
        [self startACEMPTransitionViewWithWWidget:wgtObj];
    }
    
    
    
    //子widget启动上报代码
    //过滤掉无appkey的子应用上报(plugin类型)
    if (!inAppkey || inAppkey.length == 0) {
        return;
    }
    id analysisObject = ACEAnalysisObject();
    
    [analysisObject ac_invoke:@"setAppChannel:" arguments:ACArgsPack(wgtObj.channelCode)];
    [analysisObject ac_invoke:@"setAppId:" arguments:ACArgsPack(wgtObj.appId)];
    [analysisObject ac_invoke:@"setWidgetVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [analysisObject ac_invoke:@"setAppVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [analysisObject ac_invoke:@"startWithChildAppKey:" arguments:ACArgsPack(inAppkey)];
    
    id emmObject = ACEEMMObject();
    
    [emmObject ac_invoke:@"setAppChannel:" arguments:ACArgsPack(wgtObj.channelCode)];
    [emmObject ac_invoke:@"setAppId:" arguments:ACArgsPack(wgtObj.appId)];
    [emmObject ac_invoke:@"setWidgetVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [emmObject ac_invoke:@"startWithChildAppKey:" arguments:ACArgsPack(inAppkey)];
}

- (void)startWidget:(NSMutableArray *)inArguments {
    
    __block NSNumber *startWidgetResult = @1;
    __block UEX_ERROR err = kUexNoError;
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    @onExit{
        NSLog(@"appCanEngine ---> Classes--->engine--->universalex ---> euexWidget-->startWidget :%d",startWidgetResult);
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbStartWidget" arguments:ACArgsPack(@0,@2,startWidgetResult)];
        [cb executeWithArguments:ACArgsPack(err)];
    };
    
    if (self.EBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) {
        
        startWidgetResult = @2;
        err = uexErrorMake(1,@"widget正在加载");
        
        return;
    }
    
   
    ACArgsUnpack(NSString *inAppId,NSNumber *inAnimiId,NSString *closeCallbackFuncName,NSString *inOpenerInfo,NSNumber *inAnimiDuration,NSString *inAppkey,NSString *exeJS) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inAppId = stringArg(info[@"appId"]);
        inAnimiId = numberArg(info[@"animId"]);
        closeCallbackFuncName = stringArg(info[@"funcName"]);
        inOpenerInfo = stringArg(info[@"info"]);
        inAnimiDuration = numberArg(info[@"animDuration"]);
        inAppkey = stringArg(info[@"appKey"]);
        exeJS = stringArg(info[@"exeJS"]);
    }
    
        NSLog(@"appCanEngine ---> Classes--->engine--->universalex ---> euexWidget-->startWidget exeJS:%@",exeJS);

    UEX_PARAM_GUARD_NOT_NIL(inAppId);


    WWidget *wgtObj = [self getStartWgtByAppId:inAppId];
    if (!wgtObj) {//
        err = uexErrorMake(1,@"inAppId对应的widget未找到");
        return;
    }

    NSTimeInterval animiDuration = 0.2f;
    if (inAnimiDuration && inAnimiDuration.floatValue > 0) {
        animiDuration = inAnimiDuration.floatValue / 1000;
    }
    
    if(inAppkey){
        wgtObj.appKey = inAppkey;
    }
    wgtObj.closeCallbackName = closeCallbackFuncName;
    wgtObj.openMessage = inOpenerInfo;
    wgtObj.openAnimation = inAnimiId.unsignedIntegerValue;
    wgtObj.openAnimationDuration = animiDuration;
    
    if (exeJS) {
        wgtObj.exeJS = exeJS;
    }

    if(![[ACESubwidgetManager defaultManager] islaunchWidget:wgtObj]){
        //判断子应用根视图是否存在
        if (wgtObj.indexUrl.length > 10) {
            if ([wgtObj.indexUrl rangeOfString:@"file://"].location !=NSNotFound) {
                NSString *indexUrl = [wgtObj.indexUrl substringFromIndex:7];
                if (![[NSFileManager defaultManager]fileExistsAtPath:indexUrl]) {
                    
                    NSString *path_header = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
                    NSLog(@"engine-------->>>>>>EUExWidget---->startWidget:沙盒路径；%@--->子应用路径:%@",path_header,wgtObj.indexUrl);
                    startWidgetResult = @3;
                    return;
                }else{
                    NSLog(@"engine-------->>>>>>EUExWidget---->startWidget 文件能取到");
                }
            }
        }else{
            startWidgetResult = @3;
            return;
        }
    }
    BOOL ret = [[ACESubwidgetManager defaultManager] launchWidget:wgtObj];
    
    startWidgetResult = ret ? @0 : @1;
    
    
    
    
    
    
    //子widget启动上报代码
    //过滤掉无appkey的子应用上报(plugin类型)
    if (!inAppkey || inAppkey.length == 0) {
        return;
    }
    id analysisObject = ACEAnalysisObject();
    
    [analysisObject ac_invoke:@"setAppChannel:" arguments:ACArgsPack(wgtObj.channelCode)];
    [analysisObject ac_invoke:@"setAppId:" arguments:ACArgsPack(wgtObj.appId)];
    [analysisObject ac_invoke:@"setWidgetVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [analysisObject ac_invoke:@"setAppVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [analysisObject ac_invoke:@"startWithChildAppKey:" arguments:ACArgsPack(inAppkey)];
    
    id emmObject = ACEEMMObject();
    
    [emmObject ac_invoke:@"setAppChannel:" arguments:ACArgsPack(wgtObj.channelCode)];
    [emmObject ac_invoke:@"setAppId:" arguments:ACArgsPack(wgtObj.appId)];
    [emmObject ac_invoke:@"setWidgetVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [emmObject ac_invoke:@"startWithChildAppKey:" arguments:ACArgsPack(inAppkey)];

}

- (void)finishWidget:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(NSString *inRet,NSString *appID,NSNumber *useWgtBg,NSNumber *inAnimiId) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inRet = stringArg(info[@"resultInfo"]);
        appID = stringArg(info[@"appId"]);
        useWgtBg = numberArg(info[@"finishMode"]);
        inAnimiId = numberArg(info[@"animId"]);
    }
    
    
    
    WWidget *wgtObj = appID ? [[ACESubwidgetManager defaultManager] launchedWidgetWithID:appID] : self.EBrwView.meBrwCtrler.widget;
    wgtObj.closeAnimation = inAnimiId ? inAnimiId.unsignedIntegerValue : [ACEAnimations closeAnimationForOpenAnimation:wgtObj.openAnimation];
    wgtObj.closeAnimationDuration = 0.2;
    [[ACESubwidgetManager defaultManager]finishWidget:wgtObj withCallbackResult:inRet];
    
}

- (void)closeWindowAfterAnimation:(EBrowserWindow*)brwWnd_ {
    NSString *fromViewName =nil;
    if (brwWnd_.meBrwView) {
        int type = brwWnd_.meBrwView.mwWgt.wgtType;
        fromViewName =[brwWnd_.meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:brwWnd_.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:fromViewName closeReason:0 appInfo:appInfo];
        if (brwWnd_.meBrwView.superview) {
            [brwWnd_.meBrwView removeFromSuperview];
        }
        brwWnd_.meBrwView = nil;
    }
    
    [brwWnd_.meTopSlibingBrwView removeFromSuperview];
    brwWnd_.meTopSlibingBrwView = nil;
    [brwWnd_.meBottomSlibingBrwView removeFromSuperview];
    brwWnd_.meBottomSlibingBrwView = nil;
    
    
    NSArray *popViewArray = [brwWnd_.mPopoverBrwViewDict allValues];
    for (EBrowserView *ePopView in popViewArray) {
        [ePopView removeFromSuperview];
        int type = ePopView.mwWgt.wgtType;
        NSString *viewName = [ePopView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
        [brwWnd_.mPopoverBrwViewDict removeAllObjects];
        brwWnd_.mPopoverBrwViewDict = nil;
    }
    
    //
    
    NSArray * mulitPopArray = [brwWnd_.mMuiltPopoverDict allValues];
    for (UIView * multiPopover in mulitPopArray){
        [multiPopover removeFromSuperview];
    }
    [brwWnd_.mMuiltPopoverDict removeAllObjects];
    brwWnd_.mMuiltPopoverDict = nil;
    

    if ((brwWnd_.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
        if ((brwWnd_.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING) == F_EBRW_FLAG_WINDOW_IN_OPENING) {
            brwWnd_.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        }
    }
    EBrowserWindowContainer *eBrwWndContainer = [brwWnd_ winContainer];
    EBrowserWindow *eAboveWnd = [eBrwWndContainer aboveWindow];
    [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    int goType = eAboveWnd.meBrwView.mwWgt.wgtType;
    NSString *goViewName =[eAboveWnd.meBrwView.curUrl absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eAboveWnd.meBrwView.mwWgt];
    [BUtility setAppCanViewActive:goType opener:fromViewName name:goViewName openReason:1 mainWin:0 appInfo:appInfo];
    if (eAboveWnd.mPopoverBrwViewDict) {
        NSArray *popViewArray = [eAboveWnd.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            int type = ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
        }
    }

}



- (UEX_BOOL)removeWidget:(NSMutableArray*)inArguments {
    
    __block NSNumber *removeWidgetResult = @1;
    @onExit{
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbRemoveWidget" arguments:ACArgsPack(@0,@2,removeWidgetResult)];
    };
    ACArgsUnpack(NSString *inAppId) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inAppId,UEX_FALSE);
    
    WWidgetMgr *wgtMgr = self.EBrwView.meBrwCtrler.mwWgtMgr;
    if ([inAppId isEqualToString:self.EBrwView.mwWgt.appId]) {
        [wgtMgr removeWgtByAppId:inAppId];
        removeWidgetResult = @0;
        return UEX_TRUE;
    }
    if (self.EBrwView.mwWgt.wgtType != F_WWIDGET_SPACEWIDGET && self.EBrwView.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
        return UEX_FALSE;
    }
    if([wgtMgr removeWgtByAppId:inAppId]){
        removeWidgetResult = @0;
        return UEX_TRUE;
    }
    return UEX_FALSE;
    
}
- (NSString *)getOpenerInfo:(NSMutableArray *)inArguments {
    
    NSString *info = self.EBrwView.meBrwCtrler.widget.openMessage;
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbGetOpenerInfo" arguments:ACArgsPack(@0,@0,info)];
    return info;
}

- (void)setMySpaceInfoWithAnimiId:(NSString*)inAnimiId ForRet:(NSString*)inForRet OpenerInfo:(NSString*)inOpenerInfo {
    
}

- (UEX_BOOL)loadApp:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *inURL,NSString *anotherURL) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inURL,UEX_FALSE);
    
    NSURL *url = [NSURL URLWithString:inURL];
    if (!url || url.scheme.length == 0) {
        ACLogError(@"AppCan EUExWidget loadApp 首选URL无效，未发起打开请求");
        return UEX_FALSE;
    }
    // note: 打开URL已改为异步；返回值仅表示请求已发起，实际打开结果通过日志记录。
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
        ACLogInfo(@"AppCan EUExWidget loadApp 首选URL打开结果=%@", success ? @"成功" : @"失败");
        if (success || !anotherURL) {
            return;
        }
        // 仅在首选URL明确失败后尝试备用URL，不并行打开两个目标。
        NSURL *fallbackURL = [NSURL URLWithString:anotherURL];
        if (!fallbackURL || fallbackURL.scheme.length == 0) {
            ACLogError(@"AppCan EUExWidget loadApp 备用URL无效，未发起打开请求");
            return;
        }
        [[UIApplication sharedApplication] openURL:fallbackURL options:@{} completionHandler:^(BOOL fallbackSuccess) {
            ACLogInfo(@"AppCan EUExWidget loadApp 备用URL打开结果=%@", fallbackSuccess ? @"成功" : @"失败");
        }];
    }];
    return UEX_TRUE;
}


- (void)checkMAMUpdate:(NSMutableArray *)inArguments{
    
    [ACEAnalysisObject() ac_invoke:@"startWithAppKey:" arguments:ACArgsPack([BUtility appKey])];
    
}

- (void)checkUpdate:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(ACJSFunctionRef *cb) = inArguments;
    
    void (^callback)(UEX_ERROR error,NSDictionary *data) = ^(UEX_ERROR error,NSDictionary *data){
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbCheckUpdate" arguments:ACArgsPack(@0,@1,data.ac_JSONFragment)];
        [cb executeWithArguments:ACArgsPack(error,data)];
        
    };
    WWidget *currentWidget = self.EBrwView.mwWgt;
    if (!currentWidget.ver || currentWidget.ver.length == 0 || !currentWidget.appId || currentWidget.appId == 0) {
        UEX_ERROR err = uexErrorMake(-1, @"当前widget信息缺失,不能进行更新");
        callback(err,nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        WWidgetMgr *wgtMgrObj = [WWidgetMgr sharedManager];
        NSMutableDictionary *updateDict = [wgtMgrObj wgtUpdate:currentWidget];
        
        NSInteger statusCode = [[updateDict objectForKey:@"statusCode"] integerValue];
        UEX_ERROR err = nil;
        if (statusCode == 200 && [updateDict count] > 1) {
            [dict setValue:@0 forKey:@"result"];
            [dict setValue:updateDict[@"updateFileName"] forKey:@"version"];
            [dict setValue:updateDict[@"updateFileUrl"] forKey:@"url"];
            [dict setValue:updateDict[@"fileSize"] forKey:@"size"];
            [dict setValue:updateDict[@"version"] forKey:@"version"];
        }else {
            [dict setValue:@1 forKey:@"result"];
            err = uexErrorMake(1,@"网络请求错误");
        }
        callback(err,dict);
    });
    
    
}



- (void)setPushNotifyCallback:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *funcName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(funcName);
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    if (eBrwWndContainer) {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setValue:self.EBrwView.muexObjName forKey:kUexPushNotifyBrwViewNameKey];
        [defaults setValue:funcName forKey:kUexPushNotifyCallbackFunctionNameKey];
        [defaults synchronize];
    }
}

- (NSString *)getPushInfo:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inFlag) = inArguments;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dataKey = @"pushData";
    if (inFlag.integerValue != 0) {
        dataKey = @"allPushData";
    }
    
    id pushData = [defaults objectForKey:dataKey];
    NSString *pushDataStr = nil;
    if ([pushData isKindOfClass:[NSDictionary class]]) {
        pushDataStr = [pushData ac_JSONFragment];
    }
    if ([pushData isKindOfClass:[NSString class]]) {
        pushDataStr = pushData;
    }
    if (pushDataStr) {
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbGetPushInfo" arguments:ACArgsPack(@0,@1,pushDataStr)];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendReportRead:pushDataStr];
        });
    }
    [defaults removeObjectForKey:dataKey];
    return pushDataStr;
}




- (void)sendReportRead:(NSString *)pushDataStr{
    @autoreleasepool {
        NSDictionary *dict = dictionaryArg(pushDataStr);
        if (!dict || [dict count] == 0) {
            return;
        }
        
        if ([dict objectForKey:@"taskId"]) {
            NSString *urlStr =[NSString stringWithFormat:@"%@4.0/count/%@",AppCanEngine.configuration.useBindUserPushURL, [dict objectForKey:@"taskId"]];
            NSURL *requestUrl = [NSURL URLWithString:urlStr];
            NSString *appid = [WWidgetMgr sharedManager].mainWidget.appId ?: @"";
            NSString *appkey = [BUtility appKey] ?: @"";
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] ?: @"";
            
            //住户ID tenantId
            NSString *tenantId = stringArg(dict[@"tenantId"]);
            NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
            NSString *varifyAppStr = [BUtility getVarifyAppMd5Code:appid AppKey:appkey time:time];
            NSMutableDictionary *headerDict = [NSMutableDictionary dictionaryWithObject:varifyAppStr forKey:@"appverify"];
            [headerDict setObject:@"application/json" forKey:@"Content-Type"];
            NSString *masAppId = [NSString stringWithFormat:@"%@", appid];
            if (tenantId && tenantId.length > 0) {
                masAppId = [NSString stringWithFormat:@"%@:%@",tenantId, appid];
            }
            [headerDict setObject:masAppId forKey:@"x-mas-app-id"];
            NSMutableDictionary *bodyDict = [NSMutableDictionary dictionaryWithCapacity:5];
            [bodyDict setObject:@"1" forKey:@"count"];
            [bodyDict setObject:deviceToken forKey:@"deviceToken"];
            
            [EUExWidget postPushURL:requestUrl headers:headerDict
                              body:[[bodyDict ac_JSONFragment] dataUsingEncoding:NSUTF8StringEncoding]
        validatesServerCertificate:AppCanEngine.configuration.validatesSecureCertificate
              useClientCertificate:AppCanEngine.configuration.useCertificateControl
                        completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                // 保留旧成功条件及缓存清理；网络传输失败不执行原completion逻辑。
                if (!error && response.statusCode == 200) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults removeObjectForKey:@"pushData"];
                    [defaults removeObjectForKey:@"allPushData"];
                    [defaults synchronize];
                }
                ACLogDebug(@"AppCan EUExWidget taskId已读上报完成，HTTP=%ld，error=%@", (long)response.statusCode, error);
            }];
        }
        
        
        NSString *softToken = [EUtility md5SoftToken];
        //线程处理
        NSString *urlStr =[NSString stringWithFormat:@"%@/report",AppCanEngine.configuration.useBindUserPushURL];
        NSURL *requestUrl = [NSURL URLWithString:urlStr];
        NSString *msgId = [dict objectForKey:@"msgId"];
        if (msgId == nil || msgId.length == 0) {
            return;
        }
        
        
        NSDate *datenow = [NSDate date];
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
        
        NSDictionary *form = @{@"msgId": msgId, @"softToken": softToken,
                               @"eventType": @"open", @"occuredAt": timeSp};
        [EUExWidget postPushURL:requestUrl
                       headers:@{@"Content-Type": @"application/x-www-form-urlencoded; charset=UTF-8"}
                          body:[ACEURLSession formBodyWithParameters:form]
    validatesServerCertificate:AppCanEngine.configuration.validatesSecureCertificate
          useClientCertificate:AppCanEngine.configuration.useCertificateControl
                    completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
            // 原同步请求结束后的处理移入回调，不改变JS接口或新增JS通知。
            if (response.statusCode == 200 && !error) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults removeObjectForKey:@"pushData"];
                [defaults removeObjectForKey:@"allPushData"];
            }
            ACLogDebug(@"AppCan EUExWidget msgId已读上报完成，HTTP=%ld，error=%@", (long)response.statusCode, error);
        }];
        
        
    }
}

- (void)setPushInfo:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *uid,NSString *nickName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(uid);
    UEX_PARAM_GUARD_NOT_NIL(nickName);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults objectForKey:@"deviceToken"];
    
    if (deviceToken) {
        NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uId",nickName,@"uNickName",deviceToken,@"deviceToken", nil];
        // NSURLSession自身异步执行，不再为同步等待网络单独创建线程。
        [self sendPushUserMsg:userDict];
    }
    
}
- (void)delPushInfo:(NSMutableArray *)inArguments {
    
    if ([AppCanEngine.configuration.useBindUserPushURL rangeOfString:@"push"].location == NSNotFound &&[AppCanEngine.configuration.useBindUserPushURL rangeOfString:@"mms"].location == NSNotFound) {
        
        NSString *appId = self.EBrwView.meBrwCtrler.mwWgtMgr.mainWidget.appId;
        NSString *appkey = [BUtility appKey];
        NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
        NSString *varifyAppStr = [BUtility getVarifyAppMd5Code:appId AppKey:appkey time:time];
        NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:5];
        NSMutableDictionary *headerDict = [NSMutableDictionary dictionaryWithCapacity:5];
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithCapacity:5];
        
        //user信息
        //请求头信息
        [headerDict setObject:@"text/plain;charset=UTF-8" forKey:@"Content-Type"];
        [headerDict setObject:@"*/*" forKey:@"Accept"];
        [headerDict setObject:@"push" forKey:@"x-push-verify-key"];
        [headerDict setObject:@"push" forKey:@"x-push-verify-id"];
        [headerDict setObject:varifyAppStr forKey:@"x-mas-verify"];
        [headerDict setObject:appId forKey:@"x-mas-app-id"];
        
        //设备标识 deviceToken
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *deviceToken = [defaults objectForKey:@"deviceToken"];
        NSString *softToken = [EUtility md5SoftToken];
        //租户标识
        NSString *tenantMark = [EUtility getTenantIdentifier];
        
        if (!deviceToken || [deviceToken isEqualToString:@"(null)"]) {
            deviceToken = @"";
        }
        
        [paramDict setObject:deviceToken forKey:@"deviceToken"];
        [paramDict setObject:softToken forKey:@"softToken"];
        [paramDict setObject:userDict forKey:@"user"];
        //新增请求来源和请求类型字段，以便后端跟踪问题
        [paramDict setObject:@"iOS-Engine" forKey:@"from"];
        [paramDict setObject:@"unbind" forKey:@"requestType"];
        [paramDict setObject:tenantMark forKey:@"tenantMark"];
        //注册地址变更
        NSString *accessBindUserPushURL = [AppCanEngine.configuration.useBindUserPushURL stringByReplacingOccurrencesOfString:@"gateway" withString:@"access"];
        NSString* urlStr = [NSString stringWithFormat:@"%@4.0/installations", accessBindUserPushURL];
        
        [EUExWidget postPushURL:[NSURL URLWithString:urlStr] headers:headerDict
                          body:[[paramDict ac_JSONFragment] dataUsingEncoding:NSUTF8StringEncoding]
    validatesServerCertificate:YES useClientCertificate:NO
                    completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
            ACLogDebug(@"AppCan EUExWidget 新后台解绑完成，HTTP=%ld，error=%@", (long)response.statusCode, error);
        }];
        
        
    } else {
        @autoreleasepool {
            NSString *softToken = [EUtility md5SoftToken];
            NSString *urlStr = [NSString stringWithFormat:@"%@msg/%@/unBindUser",AppCanEngine.configuration.useBindUserPushURL,softToken];
            // 旧接口无body；保留useCertificateControl同时控制服务端校验和客户端身份的语义。
            [EUExWidget postPushURL:[NSURL URLWithString:urlStr] headers:nil body:nil
        validatesServerCertificate:AppCanEngine.configuration.useCertificateControl
              useClientCertificate:AppCanEngine.configuration.useCertificateControl
                        completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
                ACLogDebug(@"AppCan EUExWidget 旧后台解绑完成，HTTP=%ld，error=%@", (long)response.statusCode, error);
            }];
        }

    }
    
}

- (void)sendPushUserMsg:(id)userInfo{
    
    if ([AppCanEngine.configuration.useBindUserPushURL rangeOfString:@"push"].location == NSNotFound &&[AppCanEngine.configuration.useBindUserPushURL rangeOfString:@"mms"].location == NSNotFound) {
        
        NSString *softToken = [EUtility md5SoftToken];

        NSString *appId = self.EBrwView.meBrwCtrler.mwWgtMgr.mainWidget.appId;
        NSString *appkey = [BUtility appKey];
        NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
        NSString *varifyAppStr = [BUtility getVarifyAppMd5Code:appId AppKey:appkey time:time];
        
        NSDictionary *dict = (NSDictionary*)userInfo;
        
        NSString *urlStr = @"";
        
        
        NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:5];
        NSMutableDictionary *headerDict = [NSMutableDictionary dictionaryWithCapacity:5];
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithCapacity:5];
        
        //user信息
        NSString *uId = [dict objectForKey:@"uId"];
        NSString *uNickName = [dict objectForKey:@"uNickName"];
        [userDict setObject:uId forKey:@"userId"];
        [userDict setObject:uNickName forKey:@"username"];

        //请求头信息
        [headerDict setObject:@"text/plain;charset=UTF-8" forKey:@"Content-Type"];
        [headerDict setObject:@"*/*" forKey:@"Accept"];
        [headerDict setObject:@"push" forKey:@"x-push-verify-key"];
        [headerDict setObject:@"push" forKey:@"x-push-verify-id"];
        [headerDict setObject:varifyAppStr forKey:@"x-mas-verify"];
        [headerDict setObject:appId forKey:@"x-mas-app-id"];
        
        //设备名称
        //NSString *apphardware = [BUtility getDeviceVer];
        //设备版本
        //NSString *appOS = [[UIDevice currentDevice] systemVersion];
        
        //设备标识 deviceToken
        NSString *deviceToken = [dict objectForKey:@"deviceToken"];
        if (!deviceToken || [deviceToken isEqualToString:@"(null)"]) {
            deviceToken = @"";
        }
        //租户标识
        NSString *tenantMark = [EUtility getTenantIdentifier];
        
        [paramDict setObject:@"IOS" forKey:@"deviceType"];
        [paramDict setObject:deviceToken forKey:@"deviceToken"];
        [paramDict setObject:softToken forKey:@"softToken"];
        [paramDict setObject:userDict forKey:@"user"];
        [paramDict setObject:@"iOS-Engine" forKey:@"from"];
        [paramDict setObject:tenantMark forKey:@"tenantMark"];
        //新增请求来源和请求类型字段，以便后端跟踪问题
        if((uId == nil || [uId length] == 0) && (uNickName == nil || [uNickName length] == 0)){
            //未传入用户信息，认为是推送注册上报
            [paramDict setObject:@"startUp" forKey:@"requestType"];
        }else{
            [paramDict setObject:@"bindUser" forKey:@"requestType"];
        }
        //注册地址变更
        NSString *accessBindUserPushURL = [AppCanEngine.configuration.useBindUserPushURL stringByReplacingOccurrencesOfString:@"gateway" withString:@"access"];
        urlStr = [NSString stringWithFormat:@"%@4.0/installations", accessBindUserPushURL];
        
        [EUExWidget postPushURL:[NSURL URLWithString:urlStr] headers:headerDict
                          body:[[paramDict ac_JSONFragment] dataUsingEncoding:NSUTF8StringEncoding]
    validatesServerCertificate:AppCanEngine.configuration.validatesSecureCertificate
          useClientCertificate:AppCanEngine.configuration.useCertificateControl
                    completion:^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
            ACLogDebug(@"AppCan EUExWidget 新后台注册或绑定完成，HTTP=%ld，error=%@", (long)response.statusCode, error);
        }];
        
    } else {
        @autoreleasepool {
            NSDictionary *dict = (NSDictionary*)userInfo;
            NSString *softToken = [EUtility md5SoftToken];
            NSString *appId = self.EBrwView.meBrwCtrler.mwWgtMgr.mainWidget.appId;
            NSString *urlStr = [NSString stringWithFormat:@"%@msg/%@/bindUser",AppCanEngine.configuration.useBindUserPushURL,softToken];
            
            NSMutableDictionary *form = [NSMutableDictionary dictionary];
            // 保持原表单字段，platform仍以数字0传给编码器。
            [form setValue:dict[@"uId"] forKey:@"userId"];
            [form setValue:dict[@"uNickName"] forKey:@"userNick"];
            [form setValue:dict[@"deviceToken"] forKey:@"deviceToken"];
            [form setValue:softToken forKey:@"softToken"];
            [form setValue:appId forKey:@"appId"];
            form[@"platform"] = @0;
            [EUExWidget postPushURL:[NSURL URLWithString:urlStr]
                           headers:@{@"Content-Type": @"application/x-www-form-urlencoded; charset=UTF-8"}
                              body:[ACEURLSession formBodyWithParameters:form]
        validatesServerCertificate:AppCanEngine.configuration.useCertificateControl
              useClientCertificate:AppCanEngine.configuration.useCertificateControl
                        completion:nil];
        }

    }
    
}

- (void)setPushState:(NSMutableArray*)inArguments{
    if(AppCanEngine.configuration.usePushControl == NO) {
        return;
    }
    ACArgsUnpack(NSNumber *shouldPush) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(shouldPush);
    

    
    
    if (shouldPush.boolValue) {
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        //注册推送
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}
- (UEX_BOOL)getPushState:(NSMutableArray*)inArguments{
    BOOL pushState = NO;
    pushState = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    NSNumber *result = pushState ? @0 : @1;
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbGetPushState" arguments:ACArgsPack(@0,@2,result)];
    return pushState ? UEX_TRUE : UEX_FALSE ;
}

- (void)setSpaceEnable:(NSMutableArray *)inArguments{
    
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (!eBrwMainFrm.meBrwToolBar) {
        EBrowserController *eInBrwCtrler = self.EBrwView.meBrwCtrler;
        EBrowserToolBar *ebrowserToolBar =[[EBrowserToolBar alloc] initWithFrame:CGRectMake(BOTTOM_LOCATION_VERTICAL_X,BOTTOM_LOCATION_VERTICAL_Y, BOTTOM_VIEW_WIDTH,BOTTOM_VIEW_HEIGHT) BrwCtrler:eInBrwCtrler];
        [eBrwMainFrm addSubview:ebrowserToolBar];
        ebrowserToolBar.flag=1;
    }else{
        [eBrwMainFrm addSubview:eBrwMainFrm.meBrwToolBar];
        eBrwMainFrm.meBrwToolBar.flag=1;
    }
}
#pragma mark - isAppInstalled
//20150706 by lkl
- (UEX_BOOL)isAppInstalled:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *appData = stringArg(info[@"appData"]);
    UEX_PARAM_GUARD_NOT_NIL(appData,@(NO));
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appData]];
    NSDictionary *resultDict = @{@"installed": isInstalled? @0 : @1};
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbIsAppInstalled" arguments:ACArgsPack(resultDict.ac_JSONFragment)];
    return isInstalled ? UEX_TRUE : UEX_FALSE ;
}

#pragma mark - closeLoading

- (void)closeLoading:(NSMutableArray *)inArguments{
    BOOL userCloseLoading = NO;
    ONOXMLElement *config = [ACEConfigXML ACEOriginConfigXML];
    ONOXMLElement *loadingConfig = [config firstChildWithTag:@"removeloading"];
    if (loadingConfig && [loadingConfig.stringValue isEqual:@"true"]) {
        userCloseLoading = YES;
    }
    if (userCloseLoading) {
        [self.EBrwView.meBrwCtrler handleLoadingImageCloseEvent:ACELoadingImageCloseEventWebViewFinishLoading];
    }
}

#pragma mark - 子应用启动图
- (void)startACEMPTransitionViewWithWWidget:(WWidget *)wgtObj{
    
    if (!wgtObj.appLoadingStatus) {
        return;
    }
    
    [self removeACEMPTransitionView];
    
    CGRect outFrame = self.EBrwView.meBrwWnd.frame;
    outFrame.origin.y = self.EBrwView.meBrwWnd.frame.origin.y+self.EBrwView.meBrwWnd.frame.size.height;
    self.ACEMPTransitionView = [[ACETransitionView alloc] initWithFrame:outFrame WWidget:wgtObj meBrwView:self.EBrwView];
    [self.EBrwView addSubview:self.ACEMPTransitionView];
    //[self.EBrwView bringSubviewToFront:self.ACEMPTransitionView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.ACEMPTransitionView.frame = self.EBrwView.meBrwWnd.frame;
    }];
}

- (void)removeACEMPTransitionView
{
    if (self.ACEMPTransitionView) {
        [self.ACEMPTransitionView removeFromSuperview];
        self.ACEMPTransitionView = nil;
    }
}

@end
