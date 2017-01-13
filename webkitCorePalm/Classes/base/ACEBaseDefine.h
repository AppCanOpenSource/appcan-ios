/**
 *
 *	@file   	: ACEBaseDefine.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2017/1/11
 *
 *	@copyright 	: 2017 The AppCan Open Source Project.
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

NS_ASSUME_NONNULL_BEGIN
#pragma mark - AppCanEngineConfiguration

@protocol AppCanEngineConfiguration <NSObject>
@property (nonatomic,readonly) NSString *originWidgetPath;
@property (nonatomic,readonly) NSString *documentWidgetPath;
@property (nonatomic,readonly) BOOL userStartReport;
@property (nonatomic,readonly) BOOL useUpdateControl;
@property (nonatomic,readonly) BOOL usePushControl;
@property (nonatomic,readonly) BOOL useDataStatisticsControl;
@property (nonatomic,readonly) BOOL useCloseAppWithJaibroken;
@property (nonatomic,readonly) BOOL useRC4EncryptWithLocalstorage;
@property (nonatomic,readonly) BOOL useUpdateWgtHtmlControl;
@property (nonatomic,readonly) BOOL useCertificateControl;
@property (nonatomic,readonly) NSString *useBindUserPushURL;
@property (nonatomic,readonly) NSString *useCertificatePassWord;
@property (nonatomic,readonly) NSString *useAppCanEMMTenantID;//EMM单租户场景下默认的租户ID
@property (nonatomic,readonly) BOOL validatesSecureCertificate;//是否校验证书
@property (nonatomic,readonly) BOOL useInAppCanIDE;
@end


#pragma mark - AppCanEngine

@class UNUserNotificationCenter;
@class UNNotification;
@class UNNotificationResponse;
@protocol AppCanEngine <NSObject>

@property (nonatomic,readonly,class)__kindof UINavigationController *mainWidgetController;


+ (void)initializeWithConfiguration:(id<AppCanEngineConfiguration>)configuration;

//ApplicationDelegate方法
+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;
+ (void)applicationDidBecomeActive:(UIApplication *)application;
+ (void)applicationWillResignActive:(UIApplication *)application;
+ (void)applicationDidEnterBackground:(UIApplication *)application;
+ (void)applicationWillEnterForeground:(UIApplication *)application;
+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;
+ (void)applicationWillTerminate:(UIApplication *)application;
+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler;
+ (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;
+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler;
//UNUserNotificationCenterDelegate方法(iOS 10+)
+ (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSUInteger))completionHandler;

+ (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler;

@end







NS_ASSUME_NONNULL_END

