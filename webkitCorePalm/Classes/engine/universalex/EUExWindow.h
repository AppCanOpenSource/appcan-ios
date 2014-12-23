/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <Foundation/Foundation.h>
#import "EUExBase.h"
@class BToastView;

@class EBrowserMainFrame;
@class EBrowserWindowContainer;
@class BUIAlertView;
@class BStatusBarWindow;
@class EBrowserViewAnimition;

#define F_EUEXWINDOW_TYPE_NORMAL			0
#define F_EUEXWINDOW_TYPE_POPUP				1
#define F_EUEXWINDOW_TYPE_SLIBING_TOP		2
#define F_EUEXWINDOW_TYPE_SLIBING_BOTTOM	3

#define F_EUEXWINDOW_SRC_TYPE_URL			0
#define F_EUEXWINDOW_SRC_TYPE_DATA			1
#define F_EUEXWINDOW_SRC_TYPE_URL_AND_DATA	2

#define F_EUEXWINDOW_SIZE_FULL_PARENT		-1
#define F_EUEXWINDOW_SIZE_FULL_SCREEN		-2

//#define F_EUEXWINDOW_AD_Y_POS_TOP_PHONE_P		0
//#define F_EUEXWINDOW_AD_Y_POS_MIDDLE_PHONE_P	200
//#define F_EUEXWINDOW_AD_Y_POS_BOTTOM_PHONE_P	395
//
//#define F_EUEXWINDOW_AD_Y_POS_TOP_PHONE_L		0
//#define F_EUEXWINDOW_AD_Y_POS_MIDDLE_PHONE_L	120
//#define F_EUEXWINDOW_AD_Y_POS_BOTTOM_PHONE_L	235
//
//#define F_EUEXWINDOW_AD_Y_POS_TOP_PAD_P			0
//#define F_EUEXWINDOW_AD_Y_POS_MIDDLE_PAD_P		341
//#define F_EUEXWINDOW_AD_Y_POS_BOTTOM_PAD_P		673
//
//#define F_EUEXWINDOW_AD_Y_POS_TOP_PAD_L			0
//#define F_EUEXWINDOW_AD_Y_POS_MIDDLE_PAD_L		480
//#define F_EUEXWINDOW_AD_Y_POS_BOTTOM_PAD_L		939


#define F_EUEXWINDOW_OPEN_FLAG_OAUTH				0x1
#define F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION			0x2
#define F_EUEXWINDOW_OPEN_FLAG_RELOAD				0x4
#define F_EUEXWINDOW_OPEN_FLAG_DISABLE_CROSSDOMAIN  0x8
#define F_EUEXWINDOW_OPEN_FLAG_OPAQUE				0x10
#define F_EUEXWINDOW_OPEN_FLAG_HIDDEN				0x20
#define F_EUEXWINDOW_OPEN_FLAG_HAS_PREOPEN			0x40
#define F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE         0x80
#define F_EUExWINDOW_OPEN_FLAG_NAV_TYPE             0x400

#define F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM     0x1

#define F_CB_WINDOW_CONFIRM					@"uexWindow.cbConfirm"
#define F_CB_WINDOW_PROMPT					@"uexWindow.cbPrompt"
#define F_CB_WINDOW_ACTION_SHEET			@"uexWindow.cbActionSheet"
#define F_CB_WINDOW_GET_STATE				@"uexWindow.cbGetState"

@interface EUExWindow : EUExBase<UIActionSheetDelegate,UIScrollViewDelegate>{
	UIActionSheet *mActionSheet;
	BUIAlertView *mbAlertView;
	BToastView *mToastView;
	NSTimer *mToastTimer;
	EBrowserViewAnimition *meBrwAnimi;
    NSMutableDictionary *bounceParams;
}

@property(nonatomic,retain)UIActionSheet *mActionSheet;
@property(nonatomic,retain)BUIAlertView *mbAlertView;
@property(nonatomic,retain)BToastView *mToastView;
@property(nonatomic,retain)NSTimer *mToastTimer;
@property(nonatomic,assign)EBrowserViewAnimition *meBrwAnimi;
@property(nonatomic,retain)NSMutableDictionary *notificationDic;

- (void)closeSlibing:(NSMutableArray *)inArguments;
@end
