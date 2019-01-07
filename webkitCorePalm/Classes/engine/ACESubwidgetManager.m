/**
 *
 *	@file   	: ACESubwidgetManager.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/18
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


#import "ACESubwidgetManager.h"
#import "EBrowserController.h"
#import "EBrowserWindowContainer.h"
#import "ACEUINavigationController.h"
#import "EBrowser.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "WWidget.h"
#import "ACEViewControllerAnimator.h"
#import "AppCanEnginePrivate.h"




@interface ACESubwidgetManager()
@property (nonatomic,strong)NSMutableArray<ACEUINavigationController *> *subwidgetControllers;
@property (nonatomic,assign)BOOL isLaunchingSubwidget;
@end


@implementation ACESubwidgetManager

+ (instancetype)defaultManager{
    static ACESubwidgetManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _subwidgetControllers = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter]addObserverForName:AppCanEngineRestartNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.isLaunchingSubwidget = NO;
            [self.subwidgetControllers removeAllObjects];
        }];
    }
    return self;
}

- (BOOL)islaunchWidget:(WWidget *)subwidget{
    return self.isLaunchingSubwidget;
}


- (BOOL)launchWidget:(WWidget *)subwidget{
    if (self.isLaunchingSubwidget) {
        return NO;
    }
    self.isLaunchingSubwidget = YES;
    EBrowserController *browserController = [[EBrowserController alloc] initWithwidget:subwidget];

    ACEUINavigationController *meNav = [[ACEUINavigationController alloc] initWithEBrowserController:browserController];
    browserController.aceNaviController = meNav;
    browserController.view.backgroundColor = [UIColor clearColor];//触发loadView
    
    [browserController.meBrw start:nil];
    
    [self.subwidgetControllers addObject:meNav];
    return YES;
}

- (EBrowserController *)topWidgetController{
    return self.subwidgetControllers.lastObject.rootController;
}

- (WWidget *)launchedWidgetWithID:(NSString *)appID{
    for (ACEUINavigationController *navi in self.subwidgetControllers) {
        if ([navi.rootController.widget.appId isEqual:appID]) {
            return navi.rootController.widget;
        }
    }
    return nil;
}

- (void)reloadWidgetByID:(NSString *)appID{
    for (ACEUINavigationController *navi in self.subwidgetControllers) {
        if ([navi.rootController.widget.appId isEqual:appID]) {
            for (EBrowserWindow *window in navi.rootController.rootWindowContainer.mBrwWndDict.allValues) {
                for (EBrowserView *popover in window.mPopoverBrwViewDict.allValues) {
                    [popover reload];
                }
                [window.meBrwView reload];
                [window.meTopSlibingBrwView reload];
                [window.meBottomSlibingBrwView reload];
            }
            return;
        }
    }
}


- (BOOL)finishWidget:(WWidget *)subwidget withCallbackResult:(NSString *)result{
    
    NSInteger idx = -1;

    ACEUINavigationController *widgetController = nil;
    for  (NSInteger i = self.subwidgetControllers.count - 1 ; i >= 0; i--) {
        ACEUINavigationController *controller = self.subwidgetControllers[i];
        if ([controller.rootController.widget.appId isEqual:subwidget.appId]) {

            widgetController = controller;
            idx = i;
            break;
        }
    }
    
    if (idx < 0) {
        return NO;
    }
    while (self.subwidgetControllers.count > idx) {
        [self.subwidgetControllers removeLastObject];
    }
    NSString *callbackFunc = widgetController.rootController.widget.closeCallbackName;
    if (callbackFunc) {
        [self.subwidgetControllers.lastObject.rootController.aboveWindow.meBrwView callbackWithFunctionKeyPath:callbackFunc arguments:ACArgsPack(result)];
    }

    
    [widgetController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [EBrowserWindow postWindowSequenceChange];
    }];
    return YES;

}



- (void)notifySubwidgetControllerLoadingCompleted:(EBrowserController *)subwidgetController{
    if (self.subwidgetControllers.lastObject.childViewControllers.firstObject != subwidgetController) {
        return;
    }
    self.isLaunchingSubwidget = NO;
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    [controller presentViewController:subwidgetController.aceNaviController animated:YES completion:^{
         [EBrowserWindow postWindowSequenceChange];
    }];
}




@end
