/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "WidgetOnePseudoDelegate.h"
@implementation WidgetOnePseudoDelegate

- (id) init
{	
	if (self = [super init]) {
		self.userStartReport = YES;
		self.useOpenControl = YES;
		self.usePushControl = NO;
		self.useUpdateControl = NO;
		self.useOnlineArgsControl = YES;
		self.useDataStatisticsControl = NO;
        self.useAuthorsizeIDControl = YES;
        self.useCloseAppWithJaibroken = NO;
        self.useRC4EncryptWithLocalstorage = YES;
        self.useUpdateWgtHtmlControl = NO;
        self.useStartReportURL = @"http://115.29.138.150/appIn/";
        self.useAnalysisDataURL = @"http://115.29.138.150/appIn/";
        self.useBindUserPushURL = @"http://192.168.1.140:8080/push/";
        self.useAppCanMAMURL = @"http://115.29.138.150/appIn/";
        self.useAppCanMDMURL = @"http://115.29.138.150";
        self.useAppCanMDMURLControl = NO;
        self.useCertificatePassWord = @"123456";
        self.useCertificateControl = NO;
        self.useIsHiddenStatusBarControl = NO;
	}
	return self;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url 
{
    return [super application:application handleOpenURL:url];
}
- (void)applicationWillResignActive:(UIApplication *)application {
	[super applicationWillResignActive:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[super applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[super application:app didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
	
}
// 注册APNs错误

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
	[super application:app didFailToRegisterForRemoteNotificationsWithError:err];
	
}
// 接收推送通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	[super application:application didReceiveRemoteNotification:userInfo];
}

- (void)dealloc
{
	[super dealloc];
}
//-(void)terminateWithException:(NSException*)e{
//    [super terminateWithException:e];
//}
@end
