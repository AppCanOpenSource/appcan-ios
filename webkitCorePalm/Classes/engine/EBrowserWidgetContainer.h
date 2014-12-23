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

#import <UIKit/UIKit.h>

@class EBrowserController;
@class EBrowserWindowContainer;
@class EBrowserView;

@interface EBrowserWidgetContainer : UIView {
	EBrowserController *meBrwCtrler;
	EBrowserWindowContainer *meRootBrwWndContainer;
	NSMutableDictionary *mBrwWndContainerDict;
	NSMutableArray *mReUseBrwViewArray;
}

@property (nonatomic, assign) EBrowserController *meBrwCtrler;
@property (nonatomic, assign) EBrowserWindowContainer *meRootBrwWndContainer;
@property (nonatomic, assign) NSMutableDictionary *mBrwWndContainerDict;
@property (nonatomic, assign) NSMutableArray *mReUseBrwViewArray;
@property (nonatomic, retain) NSMutableDictionary *mWWigets;

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler;
- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView;
- (EBrowserWindowContainer*)aboveWindowContainer;
- (EBrowserView*)popReuseBrwView;
- (void)pushReuseBrwView:(EBrowserView*)inBrwView;
- (void)removeAllUnActiveBrwWndContainer;

@end
