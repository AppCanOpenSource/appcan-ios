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

#import <UIKit/UIKit.h>
#import "AppCenter.h"
@class EBrowserController;

#define	MENU_WIDTH  320
#define MENU_HEIGTH 460*0.69

#define BOTTOM_LOCATION_VERTICAL_X  0
#define BOTTOM_LOCATION_VERTICAL_Y  480*0.79

#define BOTTOM_LOCATION_HORIZONTAL_X 480-33
#define BOTTOM_LOCATION_HORIZONTAL_Y 320*0.79

#define BOTTOM_VIEW_HEIGHT 33
#define BOTTOM_VIEW_WIDTH 33

#define BOTTOM_ITEM_WIDTH 33
#define BOTTOM_ITEM_HEIGHT 33

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//#define isPad 0


#define BOTTOM_IPAD_ITEM_WIDTH 66
#define BOTTOM_IPAD_ITEM_HEIGHT 66
//1024*768
#define BOTTOM_IPAD_LOCATION_VERTICAL_X  0
#define BOTTOM_IPAD_LOCATION_VERTICAL_Y  1024*0.69

#define BOTTOM_IPAD_LOCATION_HORIZONTAL_X 768-66
#define BOTTOM_IPAD_LOCATION_HORIZONTAL_Y 768*0.69

#define BOTTOM_IPAD_VIEW_HEIGHT 66
#define BOTTOM_IPAD_VIEW_WIDTH 66

#define F_TOOLBAR_FLAG_FINISH_WIDGET	0x1

@interface EBrowserToolBar : UIView{
	UIButton *barbtn;
	EBrowserController *eBrwCtrler;
	CGGradientRef gradient;
	BOOL screenIsPortraitTag;
	int mFlag;
}
@property(nonatomic,assign) int flag;
@property(nonatomic,retain)UIButton *barbtn;
@property(nonatomic,assign)EBrowserController *eBrwCtrler;
@property int mFlag;
//-(void)drawViewWithBrwWnd:(EBrowserWindow *)eBrwWnd_;
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler;
- (void)LoadSpace;
@end
