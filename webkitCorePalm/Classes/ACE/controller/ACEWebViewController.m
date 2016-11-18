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
#import <AppCanKit/AppCanKit.h>
@interface ACEWebViewController ()



@end

@implementation ACEWebViewController



- (void)viewDidLoad {
    [super viewDidLoad];


    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _browserWindow.frame = rect;
    [self.view addSubview:_browserWindow];
    self.view.backgroundColor = [UIColor clearColor];
}



- (void)dealloc{
    [_browserWindow.winContainer removeFromWndDict:_browserWindow.windowName];
}


@end
