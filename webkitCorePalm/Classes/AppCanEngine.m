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
#import "WWidgetMgr.h"
#import "EBrowserView.h"
#import "WWidget.h"
#import "EUtility.h"



@interface ACEConfigurationProxy : NSProxy
@property (nonatomic,strong)NSObject<AppCanEngineConfiguration> *userConfiguration;
@property (nonatomic,strong)__kindof WidgetOneDelegate *defaultConfiguration;

@end
@implementation ACEConfigurationProxy

- (instancetype)initWithConfiguration:(NSObject<AppCanEngineConfiguration> *)userConfiguration{
    _userConfiguration = userConfiguration;
    return self;
}

- (__kindof WidgetOneDelegate *)defaultConfiguration{
    if(!_defaultConfiguration){
        Class pseudo = NSClassFromString(@"WidgetOnePseudoDelegate");
        if (pseudo) {
            _defaultConfiguration = (__kindof WidgetOneDelegate *)[[pseudo alloc] init];
        }else{
            _defaultConfiguration = [[WidgetOneDelegate alloc]init];
        }
    }
    return _defaultConfiguration;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [self.userConfiguration methodSignatureForSelector:selector];
    if (signature) {
        return signature;
    }else{
        return [self.defaultConfiguration methodSignatureForSelector:selector];
    }
}
- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.userConfiguration respondsToSelector:invocation.selector]) {
        return [invocation invokeWithTarget:self.userConfiguration];
    }else{
        return [invocation invokeWithTarget:self.defaultConfiguration];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [self.userConfiguration respondsToSelector:aSelector] || [self.defaultConfiguration respondsToSelector:aSelector];
}

@end




static ACEConfigurationProxy *_configProxy;
static EBrowserController *_rootController;
static ACEUINavigationController *_mainWidgetController;


NSNotificationName const AppCanEngineRestartNotification = @"AppCanEngineRestartNotification";

@implementation AppCanEngine



+ (NSString *)softToken{
    return [EUtility md5SoftToken];
}
+ (NSString *)uuid{
    return [BUtility macAddress];
}

+ (void)initializeWithConfiguration:(id<AppCanEngineConfiguration>)configuration{
    _configProxy = [[ACEConfigurationProxy alloc] initWithConfiguration:configuration];
    
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (![appDelegate isKindOfClass:[WidgetOneDelegate class]]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self injectAppDelegate];
        });
    }
    
    
    [self _initializeEngine];
    
}

+ (void)injectAppDelegate{

    Class appDelegateClass = [[UIApplication sharedApplication].delegate class];
    
    
    __block NSInvocation *ace_methodSignatureForSelector_invocation = _swizzleMethodWithBlock(appDelegateClass, @selector(methodSignatureForSelector:), ^NSMethodSignature *(id obj,SEL sel){
        NSMethodSignature *sig = [_configProxy methodSignatureForSelector:sel];
        if (sig) {
            return sig;
        }
        [ace_methodSignatureForSelector_invocation invokeWithTarget:obj];
        id ret = nil;
        [ace_methodSignatureForSelector_invocation getReturnValue:&ret];
        return ret;
    });
    
    __block NSInvocation *ace_forwardInvocation_invocation = _swizzleMethodWithBlock(appDelegateClass, @selector(forwardInvocation:), ^(id obj,NSInvocation * invocation){
        if ([_configProxy respondsToSelector:invocation.selector]) {
            [_configProxy forwardInvocation:invocation];
        }else{
            [ace_forwardInvocation_invocation invokeWithTarget:obj];
        }
    });
}


static NSInvocation* _swizzleMethodWithBlock(Class target,SEL origin,id block){
    Method originSelMethod = class_getInstanceMethod(target, origin);
    if (!originSelMethod) {
        return nil;
    }
    IMP blockIMP = imp_implementationWithBlock(block);
    NSString *blockSelectorString = [NSString stringWithFormat:@"_ace_block_%@_%p", NSStringFromSelector(origin), block];
    SEL blockSel = sel_registerName([blockSelectorString cStringUsingEncoding:NSUTF8StringEncoding]);
    
    const char* originSelMethodArgs = method_getTypeEncoding(originSelMethod);
    NSMethodSignature *originSignature = [NSMethodSignature signatureWithObjCTypes:originSelMethodArgs];
    NSInvocation *originInvocation = [NSInvocation invocationWithMethodSignature:originSignature];
    class_addMethod(target,origin,class_getMethodImplementation(target, origin),originSelMethodArgs);
    class_addMethod(target,blockSel, blockIMP, originSelMethodArgs);
    method_exchangeImplementations(class_getInstanceMethod(target, origin), class_getInstanceMethod(target, blockSel));
    return originInvocation;
}







+ (void)_initializeEngine{
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

+ (void)restart{
    if ([BUtility getAppCanDevMode]) {
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _initializeEngine];
        [[NSNotificationCenter defaultCenter] postNotificationName:AppCanEngineRestartNotification object:nil];
    });
}



+ (EBrowserController *)rootWebViewController{
    return _rootController;
}

+ (id<AppCanWidgetObject>)mainWidget{
    return _rootController.widget;
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
    return (id<AppCanEngineConfiguration>)_configProxy;
}

#pragma mark - UIAlertViewDelgate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [BUtility exitWithClearData];
    
    
}

#pragma mark - Application Delegate Event

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
  
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidBecomeActive:application];
    }];
    
    
    
}


+ (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationDidEnterBackground:application];
    }];
    
    
}

+ (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillEnterForeground:application];
    }];
    

    
}

+ (void)applicationWillTerminate:(UIApplication *)application {
    [self enumeratePluginClassesResponsingToSelector:_cmd withBlock:^(Class pluginClass, BOOL *stop) {
        [pluginClass applicationWillTerminate:application];
    }];
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


#pragma mark - AppCanGlobalObjectGetter

+ (id<AppCanWebViewEngineObject>)getAppCanRootWebViewEngine{
    return self.rootWebViewController.rootView;
}

+ (id<AppCanWidgetObject>)getAppCanMainWidget{
    return [[WWidgetMgr sharedManager] mainWidget];
}


@end
