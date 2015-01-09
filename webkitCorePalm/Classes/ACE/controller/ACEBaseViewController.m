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

#import "ACEBaseViewController.h"
#import "ACEUtils.h"
#import "BUtility.h"

@interface ACEBaseViewController ()

@end

@implementation ACEBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (isSysVersionAbove7_0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSString * configOrientation = [BUtility getMainWidgetConfigInterface];
    self.wgtOrientation = [configOrientation intValue];
    
    
    // Do any additional setup after loading the view.
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
//        //        self.delegate = self;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (self.wgtOrientation)
    {
        case 1:
            return NO;
            break;
        case 2:
            //            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            //            {
            return NO;
            //            }
            break;
        case 4:
            //            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            //            {
            return NO;
            //            }
            break;
        case 5:
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            {
                return NO;
            }
            break;
        case 8:
            //            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
            //            {
            return NO;
            //            }
            break;
        case 3:
            if (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationMaskPortraitUpsideDown)
            {
                return NO;
            }
            break;
        case 9:
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationMaskPortraitUpsideDown)
            {
                return NO;
            }
            break;
        case 10:
            if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                return NO;
            }
            break;
        case 11:
            if (interfaceOrientation == UIInterfaceOrientationMaskPortraitUpsideDown)
            {
                return NO;
            }
            break;
        case 12:
            if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                return NO;
            }
            break;
        case 13:
            if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
            {
                return NO;
            }
            break;
        case 14:
            if (interfaceOrientation == UIInterfaceOrientationPortrait)
            {
                return NO;
            }
            break;
            
        default:
            return YES;
            break;
    }
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    switch (self.wgtOrientation)
    {
        case 1:
            return UIInterfaceOrientationMaskPortrait;
            break;
        case 2:
            return UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case 4:
            return UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case 5:
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case 8:
            return UIInterfaceOrientationMaskLandscapeRight;
            break;
        case 3:
            return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskPortrait;
            break;
        case 9:
            return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortrait;
            break;
        case 10:
            return UIInterfaceOrientationMaskLandscape;
            break;
        case 11:
            return UIInterfaceOrientationMaskAllButUpsideDown;
            break;
        case 12:
            return UIInterfaceOrientationMaskPortraitUpsideDown|UIInterfaceOrientationMaskLandscapeRight;
            break;
        case 13:
            return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown|UIInterfaceOrientationMaskLandscapeRight;
            break;
        case 14:
            return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case 15:
            return UIInterfaceOrientationMaskAll;
            break;
            
        default:
            return UIInterfaceOrientationMaskPortrait;
            break;
    }
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
