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
#import "BUtility.h"

@class EBrowserWidgetContainer;
@class EBrowserToolBar;
@class EBrowserController;
@class EBrowserView;
@class AppCenter;

@class BStatusBarView;

#define F_EBRW_MAINFRM_AD_TYPE_TOP			0
#define F_EBRW_MAINFRM_AD_TYPE_MIDDLE		1
#define F_EBRW_MAINFRM_AD_TYPE_BOTTOM		2

#define F_EBRW_MAINFRM_AD_HEIGHT_PHONE		50
#define F_EBRW_MAINFRM_AD_HEIGHT_PAD		90


@interface EBrowserMainFrame : UIView

@property (nonatomic, weak)EBrowserController *meBrwCtrler;
@property (nonatomic, strong)EBrowserWidgetContainer *meBrwWgtContainer;
@property (nonatomic, strong)EBrowserToolBar *meBrwToolBar;
@property (nonatomic, strong)AppCenter *mAppCenter;




- (void)setVerticalFrame;
- (void)setHorizontalFrame;
- (instancetype)initWithFrame: (CGRect)frame BrwCtrler: (EBrowserController*)eInBrwCtrler;
- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView;

@end


