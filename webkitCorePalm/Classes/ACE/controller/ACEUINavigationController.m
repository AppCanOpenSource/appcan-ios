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

@interface ACEUINavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@end

@implementation ACEUINavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.navigationBar &&  [self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
//        [self.navigationBar setBackgroundImage:[UIImage imageNamed:UM_IMAGE_PATH_NAVBAR] forBarMetrics:UIBarMetricsDefault];
        
    }
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height)];
//    
//    view.backgroundColor = [UIColor purpleColor];
//    
//    [self.navigationBar addSubview:view];
//    
//    [view release];
    
    
    
//    if (isSysVersionAbove7_0) {
//        self.navigationBar.barTintColor = [UIColor purpleColor];
//    } else {
//        self.navigationBar.tintColor = [UIColor purpleColor];
//        [self.navigationBar setTranslucent: YES];
//    }
    
    
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.interactivePopGestureRecognizer.delegate = self;
////        self.delegate = self;
//    }
    
    
}

// Hijack the push method to disable the gesture

//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//        self.interactivePopGestureRecognizer.enabled = NO;
//    
//    [super pushViewController:viewController animated:animated];
//}
//
//#pragma mark UINavigationControllerDelegate
//
//- (void)navigationController:(UINavigationController *)navigationController
//       didShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animate
//{
//    // Enable the gesture again once the new controller is shown
//    
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//        self.interactivePopGestureRecognizer.enabled = YES;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
