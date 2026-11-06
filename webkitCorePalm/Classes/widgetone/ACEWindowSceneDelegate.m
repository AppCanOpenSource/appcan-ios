#import "ACEWindowSceneDelegate.h"
#import "WidgetOneDelegatePrivate.h"
#import <UserNotifications/UserNotifications.h>

@implementation ACEWindowSceneDelegate

- (WidgetOneDelegate *)engineDelegate {
    id delegate = UIApplication.sharedApplication.delegate;
    return [delegate isKindOfClass:WidgetOneDelegate.class] ? delegate : nil;
}

- (BOOL)ownsScene:(UIScene *)scene {
    return self.window && self.window.windowScene == scene &&
           self.engineDelegate.window == self.window;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:UIWindowScene.class] ||
        ![session.role isEqualToString:UIWindowSceneSessionRoleApplication]) return;

    WidgetOneDelegate *delegate = self.engineDelegate;
    self.window = [delegate ace_connectWindowScene:(UIWindowScene *)scene];
    if (!self.window) return;

    // 冷启动原因从connectionOptions读取；不伪造第二次didFinishLaunching。
    [self scene:scene openURLContexts:connectionOptions.URLContexts];
    for (NSUserActivity *activity in connectionOptions.userActivities) {
        [self scene:scene continueUserActivity:activity];
    }
    if (connectionOptions.shortcutItem) {
        [self windowScene:(UIWindowScene *)scene
             performActionForShortcutItem:connectionOptions.shortcutItem
                       completionHandler:^(BOOL succeeded) {}];
    }
    if (connectionOptions.notificationResponse) {
        [delegate userNotificationCenter:UNUserNotificationCenter.currentNotificationCenter
          didReceiveNotificationResponse:connectionOptions.notificationResponse
                   withCompletionHandler:^{}];
    }
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    if (![self ownsScene:scene]) return;
    // 断开不等于进程终止；保留引擎与根容器，下一次连接继续挂载。
    [self.engineDelegate ace_disconnectWindow:self.window];
    self.window = nil;
}

- (void)sceneWillEnterForeground:(UIScene *)scene {
    // 仅检查Scene归属；按系统回调直接转发，不过滤首次、重复事件或调整顺序。
    if (![self ownsScene:scene]) return;
    [self.engineDelegate applicationWillEnterForeground:UIApplication.sharedApplication];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (![self ownsScene:scene]) return;
    [self.engineDelegate applicationDidBecomeActive:UIApplication.sharedApplication];
}

- (void)sceneWillResignActive:(UIScene *)scene {
    if (![self ownsScene:scene]) return;
    [self.engineDelegate applicationWillResignActive:UIApplication.sharedApplication];
}

- (void)sceneDidEnterBackground:(UIScene *)scene {
    if (![self ownsScene:scene]) return;
    [self.engineDelegate applicationDidEnterBackground:UIApplication.sharedApplication];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    if (![self ownsScene:scene]) return;
    id<UIApplicationDelegate> delegate = self.engineDelegate;
    for (UIOpenURLContext *context in URLContexts) {
        // 直接复用宿主原URL入口，保留客户override/super及原插件分发链。
        [delegate application:UIApplication.sharedApplication openURL:context.URL
            sourceApplication:context.options.sourceApplication
                   annotation:context.options.annotation];
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {
    if (![self ownsScene:scene]) return;
    id<UIApplicationDelegate> delegate = self.engineDelegate;
    [delegate application:UIApplication.sharedApplication continueUserActivity:userActivity
       restorationHandler:^(NSArray *restorableObjects) {
        // Scene没有旧restorationHandler参数，按恢复协议将活动交给插件提供的对象。
        dispatch_block_t restore = ^{
            for (id object in restorableObjects) {
                if ([object conformsToProtocol:@protocol(UIUserActivityRestoring)]) {
                    [object restoreUserActivityState:userActivity];
                }
            }
        };
        if (NSThread.isMainThread) restore();
        else dispatch_async(dispatch_get_main_queue(), restore);
    }];
}

- (void)windowScene:(UIWindowScene *)windowScene
        performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
                  completionHandler:(void (^)(BOOL))completionHandler {
    if (![self ownsScene:windowScene]) {
        completionHandler(NO);
        return;
    }
    id<UIApplicationDelegate> delegate = self.engineDelegate;
    [delegate application:UIApplication.sharedApplication performActionForShortcutItem:shortcutItem
        completionHandler:completionHandler];
}

@end
