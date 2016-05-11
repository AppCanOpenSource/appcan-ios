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

#import "BUtility.h"
#import "ACEUtils.h"
@interface ACEBaseViewController ()

@end

@implementation ACEBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _canAutorotate = YES;
    _canRotate = NO;
    
    NSDictionary * infoDict = [[NSBundle mainBundle]infoDictionary];
    
    _isStatusBarHidden = [[infoDict objectForKey:@"UIStatusBarHidden"] boolValue];
    
    //if (isSysVersionAbove7_0) {
    if (ACE_iOSVersion >= 7.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSString * configOrientation = [BUtility getMainWidgetConfigInterface];
    self.wgtOrientation = [configOrientation intValue];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheOrientation:) name:@"changeTheOrientation" object:nil];

    // Do any additional setup after loading the view.
    
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
//        //        self.delegate = self;
//    }
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeTheOrientation" object:nil];
    
}

- (void)changeTheOrientation:(NSString *) orArgument
{
    NSString * subwgtOrientation = [[NSUserDefaults standardUserDefaults] objectForKey:@"subwgtOrientaion"];
    
    if (subwgtOrientation) {
        
        self.wgtOrientation = [subwgtOrientation intValue];
        
    }
    
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

- (BOOL)shouldAutorotate {
    
    if (_canRotate) {
        
        _canRotate = NO;
        
        return YES;
        
    }
    
    return _canAutorotate;
    
}

- (NSUInteger)supportedInterfaceOrientations {
    
    switch (self.wgtOrientation) {
            
        case 1:
            
            return UIInterfaceOrientationMaskPortrait;
            break;
            
        case 2:
            
            return UIInterfaceOrientationMaskLandscapeRight;
            break;
            
        case 4:
            
            return UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
            
        case 8:
            
            return UIInterfaceOrientationMaskLandscapeLeft;
            break;
            
        case 3://3 = 1 + 2
            
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight;
            break;
            
        case 5://5 = 1 + 4
            
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
            
        case 6://6 = 2 + 4
            
            return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
            
        case 7://7 = 1 + 2 + 4
            
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationLandscapeRight|UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
            
        case 9://9 = 1 + 8
            
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft;
            break;
            
        case 10://10 = 2 + 8
            
            return UIInterfaceOrientationMaskLandscape;
            break;
            
        case 11://11 = 1 + 2 + 8
            
            return UIInterfaceOrientationMaskAllButUpsideDown;
            break;
            
        case 12://12 = 4 + 8
            
            return UIInterfaceOrientationMaskPortraitUpsideDown|UIInterfaceOrientationMaskLandscapeLeft;
            break;
            
        case 13://13 = 1 + 4 + 8
            
            return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskPortraitUpsideDown|UIInterfaceOrientationMaskLandscapeLeft;
            break;
            
        case 14://14 = 2 + 4 + 8
            
            return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
            
        case 15://15 = 1 + 2 + 4 +8
            
            return UIInterfaceOrientationMaskAll;
            break;
            
        default:
            return UIInterfaceOrientationMaskPortrait;
            break;
            
    }
    
}

- (BOOL)prefersStatusBarHidden {
    
    return _isStatusBarHidden;
    
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
