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

#import "ACEWebViewController.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserView.h"
#import "BUtility.h"

@interface ACEWebViewController ()



@end

@implementation ACEWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNeedSwipeGestureRecognizer = YES;
    // Do any additional setup after loading the view.
    
//    _browserWindow = (EBrowserWindow *)self.view;
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    NSNumber *statusBarStyleIOS7 = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"StatusBarStyleIOS7"];
    int statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;

    if ([statusBarStyleIOS7 boolValue] == NO) {
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        rect = CGRectMake(0, statusBarHeight, self.view.frame.size.width, self.view.frame.size.height - statusBarHeight);
        self.view.backgroundColor = [UIColor blackColor];
    }

    
    _browserWindow.frame = rect;
    [self.view addSubview:_browserWindow];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    ACENSLog(@"NavWindowTest ACEWebViewController viewDidLoad browserWindow");
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

- (void)dealloc
{
//    _browserWindow = (EBrowserWindow *)self.view;
    
    if (_browserWindow != nil && [_browserWindow isKindOfClass:[EBrowserWindow class]]) {
        NSString *name = _browserWindow.windowName;
        
        EBrowserWindow *eBrwWnd = [_browserWindow.winContainer brwWndForKey:name];
        if (eBrwWnd != nil) {
            [_browserWindow.winContainer removeFromWndDict:name];
            [eBrwWnd release];
        }
        eBrwWnd = nil;
    }
    
    
    [super dealloc];
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
