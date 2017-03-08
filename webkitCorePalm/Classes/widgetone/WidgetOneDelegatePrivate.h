/*
 *  Copyright (C) 2017 The AppCan Open Source Project.
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



#import "WidgetOneDelegate.h"







@class EBrowserController;
@class EBrowser;
@class WWidgetMgr;
@class ACEWebViewController;
@class ACEDrawerViewController;
@class RESideMenu;
@class ACEPluginParser;


#define theApp ((WidgetOneDelegate *)[[UIApplication sharedApplication] delegate])







@interface WidgetOneDelegate ()<UIApplicationDelegate,AppCanEngineConfiguration>
@property (nonatomic, readonly) NSString *documentWidgetPath;
@property (nonatomic, strong) WWidgetMgr *mwWgtMgr;
@property (nonatomic, strong) ACEWebViewController *leftWebController;
@property (nonatomic, strong) ACEWebViewController *rightWebController;
@property (nonatomic, strong) ACEDrawerViewController *drawerController;
@property (nonatomic, strong) RESideMenu *sideMenuViewController;
@property (nonatomic, assign) NSInteger enctryptcj;




- (instancetype)initWithDevMode;
@end
