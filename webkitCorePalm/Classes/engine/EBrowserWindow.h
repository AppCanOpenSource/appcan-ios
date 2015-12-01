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
#import "ACEUtils.h"


@class EBrowser;
@class EBrowserController;
@class EBrowserView;
@class WWidget;
@class EBrowserHistory;
@class EBrowserHistoryEntry;
@class EBrowserWindowContainer;

#define F_POPOVER_BRW_VIEW_DICT_SIZE	1
#define F_EBRW_WND_FLAG_IN_CLOSING		0x1
#define F_EBRW_WND_FLAG_IN_OPENING		0x2
#define F_EBRW_WND_FLAG_HAS_PREOPEN		0x4
#define F_EBRW_WND_FLAG_FINISH_PREOPEN	0x8

@interface EBrowserWindow : UIView {
	EBrowserController *meBrwCtrler;
	EBrowserView *meTopSlibingBrwView;
	EBrowserView *meBrwView;
	EBrowserView *meBottomSlibingBrwView;
	NSMutableArray *mPreOpenArray;
	NSMutableDictionary *mPopoverBrwViewDict;
	EBrowserWindow *meFrontWnd;
	EBrowserWindow *meBackWnd;
	EBrowserHistory *meBrwHistory;
	NSString *mOAuthWndName;
	WWidget *mwWgt;
	int mOpenAnimiId;
	float mOpenAnimiDuration;
	int mFlag;
}
@property (nonatomic,assign) EBrowserController *meBrwCtrler;
@property (nonatomic,assign) EBrowserView *meTopSlibingBrwView;
@property (nonatomic,assign) EBrowserView *meBrwView;
@property (nonatomic,assign) EBrowserView *meBottomSlibingBrwView;
@property (nonatomic,assign) NSMutableArray *mPreOpenArray;
@property (nonatomic,assign) NSMutableDictionary *mPopoverBrwViewDict;
@property (nonatomic,assign) EBrowserWindow *meFrontWnd;
@property (nonatomic,assign) EBrowserWindow *meBackWnd;
@property (nonatomic,assign) EBrowserHistory *meBrwHistory;
@property (nonatomic,retain) NSString *mOAuthWndName;
@property (nonatomic,assign) WWidget *mwWgt;
@property int mOpenAnimiId;
@property float mOpenAnimiDuration;
@property int mFlag;
@property (nonatomic,retain) NSMutableDictionary *mMuiltPopoverDict;
@property (nonatomic, assign) ACEWebWindowType webWindowType;
@property (nonatomic, assign) EBrowserWindowContainer *winContainer;
@property (nonatomic, retain) NSString *windowName;
@property (nonatomic, assign) id webController;
@property (nonatomic, assign) BOOL isSliding;
@property (nonatomic,assign) BOOL enableSwipeClose;
//
@property (nonatomic,assign) BOOL usingPopAnimation;
@property (nonatomic,retain) NSDictionary *popAnimationInfo;

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt UExObjName:(NSString*)inUExObjName;
- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (void)goBack;
- (void)goForward;
- (void)addHisEntry:(EBrowserHistoryEntry*)eInHisEntry;
- (EBrowserHistoryEntry*)curHisEntry;
- (EBrowserView*)popBrwViewForKey:(id)inKey;
- (void)removeFromPopBrwViewDict:(id)inKey;
- (void)cleanAllBrwViews;
- (void)clean;
-(EBrowserView *)theFrontView;


+(void)postWindowSequenceChange;
-(void)updateSwipeCloseEnableStatus;
@end
