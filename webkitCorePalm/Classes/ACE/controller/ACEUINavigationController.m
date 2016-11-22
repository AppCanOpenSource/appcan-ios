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
#import "ACEUINavigationController.h"
#import "BUtility.h"
#import "ACEConfigXML.h"
#import "ACEBaseViewController.h"
#import "EBrowserController.h"
#import "WWidget.h"
@interface ACEUINavigationController ()

@end

@implementation ACEUINavigationController

- (EBrowserController *)rootController{
    UIViewController *controller = self.childViewControllers.firstObject;
    if ([controller isKindOfClass:[EBrowserController class]]) {
        return (EBrowserController *)controller;
    }
    return nil;
}




- (instancetype)initWithEBrowserController:(EBrowserController *)rootController{
    self = [super initWithRootViewController:rootController];
    if (self) {
        
        [self setNavigationBarHidden:YES];
        _supportedOrientation = rootController.widget.orientation;
        
        
    }
    return self;
}



- (BOOL)prefersStatusBarHidden{
    for (ACEBaseViewController *controller in self.viewControllers.reverseObjectEnumerator) {
        if (![controller isKindOfClass:[ACEBaseViewController class]]) {
            continue;
        }
        if (controller.shouldHideStatusBarNumber) {
            return controller.shouldHideStatusBarNumber.boolValue;
        }
    }
    return [super preferredStatusBarStyle];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    for (ACEBaseViewController *controller in self.viewControllers.reverseObjectEnumerator) {
        if (![controller isKindOfClass:[ACEBaseViewController class]]) {
            continue;
        }
        if (controller.statusBarStyleNumber) {
            return controller.statusBarStyleNumber.integerValue;
        }
    }
    return [super preferredStatusBarStyle];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return ace_interfaceOrientationMaskFromACEInterfaceOrientation(self.supportedOrientation);
}

- (BOOL)shouldAutorotate{
    if (self.rotateOnce) {
        self.rotateOnce = NO;
        return YES;
    }
    return self.canAutoRotate;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if (self.presentOrientationNumber) {
        return self.presentOrientationNumber.integerValue;
    }
    UIInterfaceOrientationMask mask = self.supportedInterfaceOrientations;
    if (mask & UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait;
    }
    if (mask & UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight;
    }
    if (mask & UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    }
    return UIInterfaceOrientationPortraitUpsideDown;

}

@end
