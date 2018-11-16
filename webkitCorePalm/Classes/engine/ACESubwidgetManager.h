/**
 *
 *	@file   	: ACESubwidgetManager.h  in AppCanEngine
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


#import <Foundation/Foundation.h>


@class WWidget;
@class EBrowserController;






@interface ACESubwidgetManager: NSObject
@property (nonatomic,readonly)EBrowserController *topWidgetController;

+ (instancetype)defaultManager;



- (BOOL)launchWidget:(WWidget *)subwidget;

- (BOOL)islaunchWidget:(WWidget *)subwidget;

- (BOOL)finishWidget:(WWidget *)subwidget withCallbackResult:(NSString *)result;

- (WWidget *)launchedWidgetWithID:(NSString *)appID;
- (void)reloadWidgetByID:(NSString *)appID;

- (void)notifySubwidgetControllerLoadingCompleted:(EBrowserController *)subwidgetController;



@end
