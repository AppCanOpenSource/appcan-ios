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
#import "ACEViewControllerAnimator.h"
#import "ACEWebViewController.h"
#import "EBrowserWindow.h"



@interface ACEUINavigationFullscreenPopGestureDelegate : NSObject<UIGestureRecognizerDelegate>
@property (nonatomic, weak) ACEUINavigationController *navigationController;
@end

@implementation ACEUINavigationFullscreenPopGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (![topViewController isKindOfClass:[ACEWebViewController class]]) {
        return NO;
    }
    if (!((ACEWebViewController *)topViewController).browserWindow.enableSwipeClose) {
        return NO;
    }
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    return YES;
    
}

@end


@interface ACEUINavigationController ()<UINavigationControllerDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic,strong)UIPanGestureRecognizer *fullscreenPopGestureRecognizer;
@property (nonatomic,strong)ACEUINavigationFullscreenPopGestureDelegate *fullscreenPopGestureRecognizerDelegate;
@end

@implementation ACEUINavigationController





- (void)closeChildViewController:(UIViewController *)childController animated:(BOOL)animated{
    NSArray *controllers = self.childViewControllers;
    for (NSInteger i = controllers.count - 2; i >= 0 ; i--) {
        if (controllers[i + 1] == childController) {
            [self popToViewController:controllers[i] animated:animated];
            break;
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.fullscreenPopGestureRecognizer]) {
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.fullscreenPopGestureRecognizer];
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.fullscreenPopGestureRecognizer.delegate = self.fullscreenPopGestureRecognizerDelegate;
        [self.fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (![self.viewControllers containsObject:viewController]) {
        [super pushViewController:viewController animated:animated];
    }
}

- (instancetype)initWithEBrowserController:(EBrowserController *)rootController{
    self = [super initWithRootViewController:rootController];
    if (self) {
        [self setNavigationBarHidden:YES];
        _supportedOrientation = rootController.widget.orientation;
        _rootController = rootController;
        self.delegate = self;
        self.transitioningDelegate = self;
        _canAutoRotate = YES;
        _fullscreenPopGestureRecognizer = [[UIPanGestureRecognizer alloc]init];
        _fullscreenPopGestureRecognizer.maximumNumberOfTouches = 1;
        _fullscreenPopGestureRecognizerDelegate = [[ACEUINavigationFullscreenPopGestureDelegate alloc] init];
        _fullscreenPopGestureRecognizerDelegate.navigationController = self;
        
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
    NSNumber *UIStatusBarHidden = [NSBundle mainBundle].infoDictionary[@"UIStatusBarHidden"];
    return UIStatusBarHidden ? UIStatusBarHidden.boolValue : NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if (![BUtility useIOS7Style]) {
        return UIStatusBarStyleLightContent;
    }
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



#pragma mark - UINavigationControllerDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC{
    
    
    switch (operation) {
        case UINavigationControllerOperationPush:{
            if (![toVC isKindOfClass:[ACEWebViewController class]]) {
                return nil;
            }

            EBrowserWindow *window = [(ACEWebViewController *)toVC browserWindow];
            return [ACEViewControllerAnimator openingAnimatorWithAnimationID:window.openAnimationID duration:window.openAnimationDuration config:window.openAnimationConfig];
        }
        case UINavigationControllerOperationPop:{
            if (![fromVC isKindOfClass:[ACEWebViewController class]]) {
                return nil;
            }
            
            EBrowserWindow *window = [(ACEWebViewController *)fromVC browserWindow];
            return [ACEViewControllerAnimator closingAnimatorWithAnimationID:window.openAnimationID duration:window.openAnimationDuration config:window.openAnimationConfig];
            
        }
        default:
            return nil;
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    if (![presented isKindOfClass:[ACEUINavigationController class]]) {
        return nil;
    }
    ACEUINavigationController *navi = (ACEUINavigationController *)presented;
    WWidget *widget = navi.rootController.widget;
    return [ACEViewControllerAnimator openingAnimatorWithAnimationID:widget.openAnimation duration:widget.openAnimationDuration config:widget.openAnimationConfig];
    
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    if (![dismissed isKindOfClass:[ACEUINavigationController class]]) {
        return nil;
    }
    
    ACEUINavigationController *navi = (ACEUINavigationController *)dismissed;
    WWidget *widget = navi.rootController.widget;
    return [ACEViewControllerAnimator closingAnimatorWithAnimationID:widget.closeAnimation duration:widget.closeAnimationDuration config:widget.closeAnimationConfig];
}


//webView bug,前端调用子应用退出问题对应
- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.presentedViewController != nil) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}


                    
                    
@end
