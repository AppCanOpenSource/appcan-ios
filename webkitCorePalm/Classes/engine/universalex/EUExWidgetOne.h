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

#import <Foundation/Foundation.h>
#import "EUExBase.h"

#define F_WIDGETONE_PLATFORM_IOS		0
#define F_WIDGETONE_PLATFORM_ANDROID	1

#define F_CB_WIDGETONE_GET_ID					@"uexWidgetOne.cbGetId"
#define F_CB_WIDGETONE_GET_VERSION				@"uexWidgetOne.cbGetVersion"
#define F_CB_WIDGETONE_GET_PLATFORM				@"uexWidgetOne.cbGetPlatform"
#define F_CB_WIDGETONE_GET_WIDGET_NUM				@"uexWidgetOne.cbGetWidgetNumber"
#define F_CB_WIDGETONE_GET_WIDGET_INFO			@"uexWidgetOne.cbGetWidgetInfo"
#define F_CB_WIDGETONE_CLEAN_CACHE				@"uexWidgetOne.cbCleanCache"
#define F_CB_WIDGETONE_GET_CURRENTWIDGET_INFO		@"uexWidgetOne.cbGetCurrentWidgetInfo"
#define F_CB_WIDGETONE_GET_MAINWIDGET_ID			@"uexWidgetOne.cbGetMainWidgetId"

#define F_JK_NAME				@"name"
#define F_JK_APP_ID				@"appId"
#define F_JK_WIDGET_ID			@"widgetId"
#define F_JK_ICON				@"icon"
#define F_JK_VERSION			@"version"

@interface EUExWidgetOne : EUExBase {
}
@end
