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


@class EBrowserController;
@class CBrowserMainFrame;
@class CBrowserWindow;
@class EBrowserWindow;
@class WWidget;
@class EBrowserViewBounceView;
@class EBrowserWidgetContainer;

@class EBrowserHistory;
@class EBrowserHistoryEntry;
@class ACEBrowserView;
@class JSValue;

@interface EBrowserView : UIImageView<UIGestureRecognizerDelegate>

@property (nonatomic,assign) NSString *muexObjName;




@property (nonatomic,weak) EBrowserController *meBrwCtrler;
@property (nonatomic,weak) CBrowserWindow *mcBrwWnd;
@property (nonatomic,weak) EBrowserWindow *meBrwWnd;
@property (nonatomic,weak) WWidget *mwWgt;

@property (nonatomic,weak) NSMutableDictionary *mPageInfoDict;
@property (nonatomic,weak) EBrowserViewBounceView *mTopBounceView;
@property (nonatomic,weak) EBrowserViewBounceView *mBottomBounceView;
@property (nonatomic,weak) UIScrollView *mScrollView;
@property (nonatomic,assign) float lastScrollPointY;
@property (nonatomic,assign) float nowScrollPointY;
@property (nonatomic,assign) float bottom;

@property (nonatomic,assign)int mType;
@property (nonatomic,assign)int mFlag;
@property (nonatomic,assign)int mTopBounceState;
@property (nonatomic,assign)int mBottomBounceState;
@property (nonatomic,assign)int mAdType;
@property (nonatomic,assign)int mAdDisplayTime;
@property (nonatomic,assign)int mAdIntervalTime;
@property (nonatomic,assign)int mAdFlag;
@property (nonatomic,strong)NSURL *currentUrl;
@property (nonatomic,assign)BOOL isMuiltPopover;
@property (nonatomic,assign)BOOL isSwiped;
@property (nonatomic,strong) ACEBrowserView * meBrowserView;

/**
 **UIWebView的方法和属性**************************************
 **/
@property (nonatomic, readonly, assign) UIScrollView *scrollView;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

@property (nonatomic, readonly, assign) NSURLRequest *request;

- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@property (nonatomic) BOOL scalesPageToFit;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic) BOOL allowsInlineMediaPlayback;
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay;
//********************************************************







- (void)reuseWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(int)inWndType;
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(int)inWndType;
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
- (void)keyboardWillChangeFrame:(NSNotification *)notification;
- (void)registerKeyboardChangeEvent;


@end
