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
#import "ACEAnimation.h"

#import "ACEMPBottomMenuBgView.h"
#import "ACEMPTopView.h"


@class EBrowser;
@class EBrowserController;
@class EBrowserView;
@class WWidget;
@class EBrowserHistory;
@class EBrowserHistoryEntry;
@class EBrowserWindowContainer;
@class ACEWebViewController;

#define F_POPOVER_BRW_VIEW_DICT_SIZE	1
#define F_EBRW_WND_FLAG_IN_CLOSING		0x1
#define F_EBRW_WND_FLAG_IN_OPENING		0x2
#define F_EBRW_WND_FLAG_HAS_PREOPEN		0x4
#define F_EBRW_WND_FLAG_FINISH_PREOPEN	0x8

#define NavHeightIPhoneX 88.0
#define TabHeightIPhoneX 78.0
#define NavHeightNormal 64.0
#define TabHeightNormal 44.0

typedef NS_ENUM(NSInteger, ACEWebWindowType) {
    ACEWebWindowTypeNormal, //普通类型
    ACEWebWindowTypeNavigation, //具有手势导航功能
    ACEWebWindowTypePresent, //present
};


@interface EBrowserWindow : UIView 
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
@property (nonatomic,readonly) WWidget *mwWgt;

@property (nonatomic,assign) int mFlag;
@property (nonatomic,retain) NSMutableDictionary *mMuiltPopoverDict;
@property (nonatomic,assign) ACEWebWindowType webWindowType;
@property (nonatomic,weak) EBrowserWindowContainer *winContainer;
@property (nonatomic,strong) NSString *windowName;
@property (nonatomic,weak) ACEWebViewController *webController;
@property (nonatomic,assign) BOOL isSliding;
@property (nonatomic,assign) BOOL enableSwipeClose;

@property (nonatomic,assign)ACEAnimationID openAnimationID;
@property (nonatomic,assign)NSTimeInterval openAnimationDuration;
@property (nonatomic,strong)NSDictionary *openAnimationConfig;

@property (nonatomic,strong) ACEMPWindowOptions *windowOptions;
@property (nonatomic,strong) ACEMPTopView *acempTopView;
@property (nonatomic,strong) ACEMPBottomMenuBgView *acempBottomBgView;

//为uexWindow.openWithOptions方法新增加的实例化方法
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt UExObjName:(NSString*)inUExObjName windowOptions:(ACEMPWindowOptions *)windowOptions;

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
- (void)clean;
- (EBrowserView *)theFrontView;


+ (void)postWindowSequenceChange;


//修改公众号窗口内容
- (void)setMPWindowOptions:(ACEMPWindowOptions *)windowOptions;


@end

