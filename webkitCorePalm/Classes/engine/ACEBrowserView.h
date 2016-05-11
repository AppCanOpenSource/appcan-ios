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

#define F_EBRW_VIEW_TYPE_MAIN				0
#define F_EBRW_VIEW_TYPE_SLIBING_TOP		1
#define F_EBRW_VIEW_TYPE_SLIBING_BOTTOM		2
#define F_EBRW_VIEW_TYPE_POPOVER			3
#define F_EBRW_VIEW_TYPE_AD					4

#define F_PAGEINFO_DICT_SIZE				1

#define F_EBRW_VIEW_FLAG_LOAD_FINISHED				0x1
#define F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE			0x2
#define F_EBRW_VIEW_FLAG_SHOW_KEYBOARD				0x4
#define F_EBRW_VIEW_FLAG_FORBID_ROTATE				0x8
#define F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING	0x10
#define F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING	0x20
#define F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH	0x40
#define F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH	0x80
#define F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN			0x100
#define F_EBRW_VIEW_FLAG_HAS_AD						0x200
#define F_EBRW_VIEW_FLAG_OAUTH                      0x400
#define F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED        0x800
#define F_EBRW_VIEW_FLAG_CUSTOM_PROCESS_DATA        0x1000
 
#define WIDGETREPORT_WIDGETSTATUS_OPEN		@"001"
#define WIDGETREPORT_WIDGETSTATUS_CLOSE		@"000"

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

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

	int mType;
	int mFlag;
	int mTopBounceState;
	int mBottomBounceState;
	int mAdType;
	int mAdDisplayTime;
	int mAdIntervalTime;
	int mAdFlag;
    int mAnalysis;
    
    BOOL isSwiped;
}
@property (nonatomic,strong) UIActivityIndicatorView * indicatorView;
@property (nonatomic,weak) EBrowserController *meBrwCtrler;
@property (nonatomic,strong) CBrowserWindow *mcBrwWnd;
@property (nonatomic,weak) EBrowserWindow *meBrwWnd;
@property (nonatomic,weak) WWidget *mwWgt;
@property (nonatomic,copy) NSString *muexObjName;
@property (nonatomic,strong) NSMutableDictionary *mPageInfoDict;
@property (nonatomic,strong) EBrowserViewBounceView *mTopBounceView;
@property (nonatomic,strong) EBrowserViewBounceView *mBottomBounceView;
@property (nonatomic,weak) UIScrollView *mScrollView;
@property (nonatomic,assign) float lastScrollPointY;
@property (nonatomic,assign) float nowScrollPointY;
@property (nonatomic,assign) float bottom;

@property (nonatomic,strong)ACEJSCHandler *JSCHandler;
@property int mType;
@property int mFlag;
@property int mTopBounceState;
@property int mBottomBounceState;
@property int mAdType;
@property int mAdDisplayTime;
@property int mAdIntervalTime;
@property int mAdFlag;
@property (nonatomic,retain) NSURL * currentUrl;
@property (nonatomic) BOOL isMuiltPopover;

@property (nonatomic,assign) EBrowserView * superDelegate;
@property (nonatomic,weak,readonly)JSContext *JSContext;
@property (nonatomic,assign)BOOL swipeCallbackEnabled;


- (void)reuseWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(int)inWndType BrwView:(EBrowserView *)BrwView;
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(int)inWndType BrwView:(EBrowserView *)BrwView;
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
