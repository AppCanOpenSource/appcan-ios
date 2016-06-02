/**
 *
 *	@file   	: AppCanObjectProtocol.h  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/31.
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
 
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class JSValue;
@protocol AppCanWidgetObject <NSObject>

@property (nonatomic,strong,readonly) NSString *widgetOneId;
@property (nonatomic,strong,readonly) NSString *widgetId;
@property (nonatomic,strong,readonly) NSString *appId;
@property (nonatomic,strong,readonly) NSString *appKey;
@property (nonatomic,strong,readonly) NSString *widgetName;
@property (nonatomic,strong,readonly) NSString *ver;
@property (nonatomic,strong,readonly) NSString *iconPath;
@property (nonatomic,strong,readonly) NSString *widgetPath;
@property (nonatomic,strong,readonly) NSString *indexUrl;
@property (nonatomic,strong,readonly) NSString *logServerIp;

- (NSString *)absWidgetPath;
- (NSString *)absResourcePath;

@end


@protocol AppCanWebViewEngineObject <NSObject>
/**
 *  网页View,添加到此view上的subView会固定在屏幕上,不会跟随网页滑动
 */
@property (nonatomic,strong,readonly) __kindof UIView           *webView;
/**
 *  网页中的ScrollView,添加到此view上的subView会跟随网页滑动
 */
@property (nonatomic,strong,readonly) __kindof UIScrollView     *webScrollView;
/**
 *  当前网页所在的viewController
 */
@property (nonatomic,weak,readonly  ) __kindof UIViewController *viewController;
/**
 *  AppCanWidget对象,里面包含了网页所在的widget信息
 */
@property (nonatomic,weak,readonly  ) id<AppCanWidgetObject>    widget;
/**
 *  当前网页的URL
 */
@property (nonatomic,strong,readonly) NSURL                     *currentURL;



/**
 *  在网页中执行一段JS脚本
 *
 *  @param jsScript 要执行的JS脚本
 */
- (void)evaluateScript:(NSString *)jsScript;




/**
 *  执行网页中的回调函数
 *
 *  @param JSKeyPath  函数名
 *  @param arguments  回调的参数
 *  @param completion JS端的函数执行完毕时,会触发此block.此block有一个JSValue类型的参数，是JS端函数的返回值.当且仅当函数调用失败时,此block参数returnValue为nil.
 *  @discussion 对于无返回值的JS函数,returnValue为一个代表<undefined>的JSValue,而不是nil
 *
 */
- (void)callbackWithFunctionKeyPath:(NSString *)JSKeyPath arguments:(nullable NSArray *)arguments completion:(nullable void (^)(JSValue *returnValue))completion;

/**
 *  执行网页中的回调函数,参数同上
 *  @note 不需要返回值时,可使用本方法
 */
- (void)callbackWithFunctionKeyPath:(NSString *)JSKeyPath arguments:(nullable NSArray *)arguments;


@end

/**
 *  在插件类中实现下列方法,就可以收到相应的系统事件
 */
@protocol AppCanApplicationEventObserver <NSObject>

@optional

+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;
+ (void)applicationDidBecomeActive:(UIApplication *)application;
+ (void)applicationWillResignActive:(UIApplication *)application;
+ (void)applicationDidEnterBackground:(UIApplication *)application;
+ (void)applicationWillEnterForeground:(UIApplication *)application;

+ (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation;

+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
+ (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

+ (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler;

+ (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler;

//应用root网页加载完成时,会执行此方法
+ (void)rootPageDidFinishLoading;

@end
NS_ASSUME_NONNULL_END
