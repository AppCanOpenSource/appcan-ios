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

typedef NS_ENUM(NSInteger, ACEWebWindowType) {
    ACEWebWindowTypeNormal, //普通类型
    ACEWebWindowTypeNavigation, //具有手势导航功能
    ACEWebWindowTypePresent, //present
    ACEWebWindowTypeOther
};

@interface EBrowserWindow : UIView {

	NSString *mOAuthWndName;
	WWidget *mwWgt;
	int mOpenAnimiId;
	float mOpenAnimiDuration;
	int mFlag;
}
@property (nonatomic,weak) EBrowserController *meBrwCtrler;
@property (nonatomic,strong) EBrowserView *meTopSlibingBrwView;
@property (nonatomic,strong) EBrowserView *meBrwView;
@property (nonatomic,strong) EBrowserView *meBottomSlibingBrwView;
@property (nonatomic,strong) NSMutableArray *mPreOpenArray;
@property (nonatomic,strong) NSMutableDictionary *mPopoverBrwViewDict;
@property (nonatomic,weak) EBrowserWindow *meFrontWnd;
@property (nonatomic,weak) EBrowserWindow *meBackWnd;
@property (nonatomic,strong) EBrowserHistory *meBrwHistory;
@property (nonatomic,strong) NSString *mOAuthWndName;
@property (nonatomic,strong) WWidget *mwWgt;
@property int mOpenAnimiId;
@property float mOpenAnimiDuration;
@property int mFlag;
@property (nonatomic,retain) NSMutableDictionary *mMuiltPopoverDict;
@property (nonatomic, assign) ACEWebWindowType webWindowType;
@property (nonatomic, weak) EBrowserWindowContainer *winContainer;
@property (nonatomic, strong) NSString *windowName;
@property (nonatomic, assign) id webController;
@property (nonatomic, assign) BOOL isSliding;
@property (nonatomic,assign) BOOL enableSwipeClose;
//
@property (nonatomic,assign) BOOL usingPopAnimation;
@property (nonatomic,strong) NSDictionary *popAnimationInfo;

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
