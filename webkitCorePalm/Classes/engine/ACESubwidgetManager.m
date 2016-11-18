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
#import "ACEUINavigationController.h"
#import "EBrowser.h"

#import "WWidget.h"


@implementation ACEWidgetInfo

@end

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
    }
    return self;
}


- (BOOL)launchWidget:(WWidget *)subwidget withInfo:(ACEWidgetInfo *)info{
    if (self.isLaunchingSubwidget) {
        return NO;
    }
    self.isLaunchingSubwidget = YES;
    EBrowserController *browserController = [[EBrowserController alloc] initWithwidget:subwidget];
    browserController.widgetInfo = info;
    ACEUINavigationController *meNav = [[ACEUINavigationController alloc] initWithEBrowserController:browserController];
    meNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    browserController.aceNaviController = meNav;
    [browserController.meBrw start:nil];
    [self.subwidgetControllers addObject:meNav];
    return YES;
}

- (BOOL)finishWidget:(WWidget *)subwidget{
    
    NSInteger idx = -1;
    
    for  (NSInteger i = self.subwidgetControllers.count - 1 ; i >= 0; i--) {
        ACEUINavigationController *controller = self.subwidgetControllers[i];
        if ([controller.rootController.widget.appId isEqual:subwidget.appId]) {
            [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    [controller presentViewController:subwidgetController.aceNaviController animated:YES completion:nil];
}


@end
