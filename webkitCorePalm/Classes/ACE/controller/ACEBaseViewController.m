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

@interface ACEBaseViewController ()

@end

@implementation ACEBaseViewController


- (void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _canAutorotate = YES;
    _canRotate = NO;
    
    NSDictionary * infoDict = [[NSBundle mainBundle]infoDictionary];
    _isStatusBarHidden = [[infoDict objectForKey:@"UIStatusBarHidden"] boolValue];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString * configOrientation = [BUtility getMainWidgetConfigInterface];
    self.wgtOrientation = [configOrientation intValue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheOrientation:) name:@"changeTheOrientation" object:nil];

}



- (void)changeTheOrientation:(id)object{
    NSString * subwgtOrientation = [[NSUserDefaults standardUserDefaults] objectForKey:@"subwgtOrientaion"];
    if (subwgtOrientation) {
        self.wgtOrientation = [subwgtOrientation intValue];
    }
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    UIInterfaceOrientationMask mask = [self supportedInterfaceOrientations];
    return mask & (1 << interfaceOrientation);
}

- (BOOL)shouldAutorotate {
    if (_canRotate) {
        _canRotate = NO;
        return YES;
    }
    return _canAutorotate;
    
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    UIInterfaceOrientationMask mask = 0;
    if (self.wgtOrientation & 1) {
        mask |= UIInterfaceOrientationMaskPortrait;
    }
    if (self.wgtOrientation & 2) {
        mask |= UIInterfaceOrientationMaskLandscapeRight;
    }
    if (self.wgtOrientation & 4) {
        mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    if (self.wgtOrientation & 8) {
        mask |= UIInterfaceOrientationMaskLandscapeLeft;
    }
    if (mask == 0) {
        mask = UIInterfaceOrientationMaskAll;
    }
    return mask;
    
}

- (BOOL)prefersStatusBarHidden {
    
    return self.isStatusBarHidden;
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.ACEStatusBarStyle;
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
