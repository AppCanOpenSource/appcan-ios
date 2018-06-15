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
#import <JavaScriptCore/JavaScriptCore.h>
#import "EBrowserView.h"
@class EBrowserController;
@class CBrowserMainFrame;
@class CBrowserWindow;
@class EBrowserWindow;
@class WWidget;
@class EBrowserViewBounceView;
@class EBrowserWidgetContainer;
@class EBrowserView;
@class EBrowserHistory;
@class EBrowserHistoryEntry;
@class ACEJSCHandler;
@interface ACEBrowserView : UIWebView <UIGestureRecognizerDelegate>{
	int mFlag;
	int mTopBounceState;
	int mBottomBounceState;
    BOOL isSwiped;
}
@property (nonatomic,strong) UIActivityIndicatorView * indicatorView;
@property (nonatomic,readonly) EBrowserController *meBrwCtrler;
@property (nonatomic,strong) CBrowserWindow *mcBrwWnd;
@property (nonatomic,weak) EBrowserWindow *meBrwWnd;
@property (nonatomic,readonly) WWidget *mwWgt;
@property (nonatomic,copy) NSString *muexObjName;
@property (nonatomic,strong) NSMutableDictionary *mPageInfoDict;
@property (nonatomic,strong) EBrowserViewBounceView *mTopBounceView;
@property (nonatomic,strong) EBrowserViewBounceView *mBottomBounceView;
@property (nonatomic,weak) UIScrollView *mScrollView;
@property (nonatomic,assign) float lastScrollPointY;
@property (nonatomic,assign) float nowScrollPointY;
@property (nonatomic,assign) float bottom;

@property (nonatomic,assign)NSUInteger retryCount;

@property (nonatomic,strong)ACEJSCHandler *JSCHandler;
@property (nonatomic,assign)ACEEBrowserViewType mType;
@property int mFlag;
@property int mTopBounceState;
@property int mBottomBounceState;
@property (nonatomic,retain) NSURL * currentUrl;
@property (nonatomic) BOOL isMuiltPopover;

@property (nonatomic,strong) NSString *mExeJS;//前端传入的希望在页面加载后注入的JS代码

@property (nonatomic,assign) EBrowserView * superDelegate;
@property (nonatomic,weak,readonly)JSContext *JSContext;
@property (nonatomic,assign)BOOL swipeCallbackEnabled;


- (void)reuseWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(ACEEBrowserViewType)inWndType BrwView:(EBrowserView *)BrwView;
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(ACEEBrowserViewType)inWndType BrwView:(EBrowserView *)BrwView;
- (void)reset;
- (void)notifyPageStart;
- (void)notifyPageFinish;
- (void)notifyPageError;
- (void)loadUEXScript;
- (void)loadWidgetWithQuery:(NSString*)inQuery;
- (void)loadWithData:(NSString *)inData baseUrl:(NSURL *)inBaseUrl;
- (void)loadWithUrl: (NSURL*)inUrl;
- (void)setView;
- (NSURL*)curUrl;
- (void)clean;
- (void)cleanAllEexObjs;
- (EBrowserWidgetContainer*)brwWidgetContainer;
- (void)bounceViewStartLoadWithType:(int)inType;
- (void)bounceViewFinishLoadWithType:(int)inType;
- (void)topBounceViewRefresh;
- (void)stopAllNetService;

-(void)continueMultiPopoverLoading;

@end
