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

#import "EBrowserView.h"
#import "ACEBrowserView.h"

#import "BUtility.h"
#import "CBrowserWindow.h"
#import "CBrowserMainFrame.h"
#import "WWidget.h"
#import "WWidgetMgr.h"
#import "BUtility.h"
#import "EBrowserController.h"
#import "EBrowser.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserToolBar.h"
#import "FileEncrypt.h"
#import "EBrowserWindow.h"
#import "EBrowserViewBounceView.h"
#import "WidgetOneDelegate.h"
#import "WidgetSQL.h"
#import "EUtility.h"
//#import "AppCanAnalysis.h"
#import "EBrowserHistory.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ACEUtils.h"



@implementation EBrowserView{
    float version;
    
}

@synthesize meBrwCtrler;

@synthesize mcBrwWnd;
@synthesize meBrwWnd;
@synthesize mwWgt;
@synthesize mPageInfoDict;
@synthesize mTopBounceView;
@synthesize mBottomBounceView;
@synthesize mScrollView;
@synthesize mType;
@synthesize mFlag;
@synthesize mTopBounceState;
@synthesize mBottomBounceState;
@synthesize mAdType;
@synthesize mAdDisplayTime;
@synthesize mAdIntervalTime;
@synthesize mAdFlag;
@synthesize isMuiltPopover;
@synthesize lastScrollPointY;
@synthesize nowScrollPointY;

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_meBrowserView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (void)loadWidgetWithQuery:(NSString*)inQuery
{
    if (_meBrowserView) {
        [_meBrowserView loadWidgetWithQuery:inQuery];
    }
}
- (void)loadWithData:(NSString *)inData baseUrl:(NSURL *)inBaseUrl
{
    if (_meBrowserView) {
        [_meBrowserView loadWithData:inData baseUrl:inBaseUrl];
    }
}
- (void)loadWithUrl: (NSURL*)inUrl
{
    if (_meBrowserView) {
        [_meBrowserView loadWithUrl:inUrl];
    }
}
- (void)setView
{
    if (_meBrowserView) {
        [_meBrowserView setView];
    }
}
- (NSURL*)curUrl
{
    if (_meBrowserView) {
        return [_meBrowserView curUrl];
    }
    return nil;
}
- (void)clean{
    if (_meBrowserView) {
        [_meBrowserView clean];
    }
}
- (void)cleanAllEexObjs
{
    if (_meBrowserView) {
        [_meBrowserView cleanAllEexObjs];
    }
}
- (EBrowserWidgetContainer*)brwWidgetContainer
{
    if (_meBrowserView) {
        return [_meBrowserView brwWidgetContainer];
    }
    return nil;
}


- (void)stopAllNetService
{
    if (_meBrowserView) {
        [_meBrowserView stopAllNetService];
    }
}

-(void)loadUEXScript{
    if (_meBrowserView) {
        [_meBrowserView loadUEXScript];
    }
}

-(void)notifyPageError
{
    if (_meBrowserView) {
        [_meBrowserView notifyPageError];
    }
}

-(void)notifyPageFinish
{
    if (_meBrowserView) {
        [_meBrowserView notifyPageFinish];
    }
}

-(void)notifyPageStart
{
    if (_meBrowserView) {
        [_meBrowserView notifyPageStart];
    }
}

-(void)bounceViewStartLoadWithType:(int)inType
{
    if (_meBrowserView) {
        [_meBrowserView bounceViewStartLoadWithType:inType];
    }
}

-(void)bounceViewFinishLoadWithType:(int)inType
{
    if (_meBrowserView) {
        [_meBrowserView bounceViewFinishLoadWithType:inType];
    }
}

-(void)reset{
    if (_meBrowserView) {
        [_meBrowserView reset];
    }
}

-(void)reuseWithFrame:(CGRect)frame BrwCtrler:(EBrowserController *)eInBrwCtrler Wgt:(WWidget *)inWgt BrwWnd:(EBrowserWindow *)eInBrwWnd UExObjName:(NSString *)inUExObjName Type:(int)inWndType
{
    if (self.meBrowserView)
    {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [_meBrowserView reuseWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:inWgt BrwWnd:eInBrwWnd UExObjName:inUExObjName Type:inWndType BrwView:self];
        _meBrowserView.superDelegate = self;
        
        

    }
}

-(id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController *)eInBrwCtrler Wgt:(WWidget *)inWgt BrwWnd:(EBrowserWindow *)eInBrwWnd UExObjName:(NSString *)inUExObjName Type:(int)inWndType
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        _meBrowserView = [[ACEBrowserView alloc]initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:inWgt BrwWnd:eInBrwWnd UExObjName:inUExObjName Type:inWndType BrwView:(EBrowserView *)self];
        
        _meBrowserView.superDelegate = self;
        
        [self addSubview:_meBrowserView];
        
    }
    return self;
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    if (self.meBrowserView && self.meBrowserView.JSContext) {
        return [_meBrowserView stringByEvaluatingJavaScriptFromString:script];
        //return [self.meBrowserView.JSContext evaluateScript:script];
    }
    return nil;
}
/**
 **UIWebView的方法和属性**************************************
 **/

-(UIScrollView *)scrollView
{
    return [_meBrowserView scrollView];
}

-(NSURLRequest *)request
{
    return [_meBrowserView request];
}

-(BOOL)canGoBack
{
    return [_meBrowserView canGoBack];
}

-(BOOL)canGoForward
{
    return [_meBrowserView canGoForward];
}

-(BOOL)isLoading
{
    return [_meBrowserView isLoading];
}

//@property (nonatomic) BOOL scalesPageToFit;

-(BOOL)scalesPageToFit
{
    return [_meBrowserView scalesPageToFit];
}

-(void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    [_meBrowserView setScalesPageToFit:scalesPageToFit];
}


//@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
-(UIDataDetectorTypes)dataDetectorTypes
{
    return [_meBrowserView dataDetectorTypes];
}

-(void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes
{
    [_meBrowserView setDataDetectorTypes:dataDetectorTypes];
}

//@property (nonatomic) BOOL allowsInlineMediaPlayback;
-(BOOL)allowsInlineMediaPlayback
{
    return [_meBrowserView allowsInlineMediaPlayback];
}

-(void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback
{
    [_meBrowserView setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
}
//@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
-(BOOL)mediaPlaybackRequiresUserAction
{
    return [_meBrowserView mediaPlaybackRequiresUserAction];
}

-(void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction
{
    [_meBrowserView setMediaPlaybackRequiresUserAction:mediaPlaybackRequiresUserAction];
}
//@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay;
-(BOOL)mediaPlaybackAllowsAirPlay
{
    return [_meBrowserView mediaPlaybackAllowsAirPlay];
}

-(void)setMediaPlaybackAllowsAirPlay:(BOOL)mediaPlaybackAllowsAirPlay
{
    [_meBrowserView setMediaPlaybackAllowsAirPlay:mediaPlaybackAllowsAirPlay];
}
//***********************************************************

- (void)loadRequest:(NSURLRequest *)request
{
    if (_meBrowserView) {
        [_meBrowserView loadRequest:request];
    }
}
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if (_meBrowserView) {
        [_meBrowserView loadHTMLString:string baseURL:baseURL];
    }
}
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    if (_meBrowserView) {
        [_meBrowserView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    }
}

- (void)reload{
    if (_meBrowserView) {
        [_meBrowserView reload];
    }
}
- (void)stopLoading{
    if (_meBrowserView) {
        [_meBrowserView stopLoading];
    }
}

- (void)goBack
{
    if (_meBrowserView) {
        [_meBrowserView goBack];
    }
}

- (void)goForward
{
    if (_meBrowserView) {
        [_meBrowserView goForward];
    }
}






//@property (nonatomic,assign) EBrowserController *meBrwCtrler;
-(EBrowserController *)meBrwCtrler
{
    return [_meBrowserView meBrwCtrler];
}

-(void)setMeBrwCtrler:(EBrowserController *)inmeBrwCtrler
{
    [_meBrowserView setMeBrwCtrler:inmeBrwCtrler];
}
//@property (nonatomic,assign) CBrowserWindow *mcBrwWnd;
-(CBrowserWindow *)mcBrwWnd
{
    return [_meBrowserView mcBrwWnd];
}

-(void)setMcBrwWnd:(CBrowserWindow *)inmcBrwWnd
{
    [_meBrowserView setMcBrwWnd:inmcBrwWnd];
}
//@property (nonatomic,assign) EBrowserWindow *meBrwWnd;
-(EBrowserWindow *)meBrwWnd
{
    return [_meBrowserView meBrwWnd];
}

-(void)setMeBrwWnd:(EBrowserWindow *)inmeBrwWnd
{
    [_meBrowserView setMeBrwWnd:inmeBrwWnd];
}
//@property (nonatomic,assign) WWidget *mwWgt;
-(WWidget *)mwWgt
{
    return [_meBrowserView mwWgt];
}

-(void)setMwWgt:(WWidget *)inmwWgt
{
    [_meBrowserView setMwWgt:inmwWgt];
}
//@property (nonatomic,copy) NSString *muexObjName;
-(NSString *)muexObjName
{
    return [_meBrowserView muexObjName];
}

-(void)setMuexObjName:(NSString *)inmuexObjName
{
    [_meBrowserView setMuexObjName:inmuexObjName];
}

//@property (nonatomic,assign) NSMutableDictionary *mPageInfoDict;
-(NSMutableDictionary *)mPageInfoDict
{
    return [_meBrowserView mPageInfoDict];
}

-(void)setMPageInfoDict:(NSMutableDictionary *)inmPageInfoDict
{
    [_meBrowserView setMPageInfoDict:inmPageInfoDict];
}
//@property (nonatomic,assign) EBrowserViewBounceView *mTopBounceView;
-(EBrowserViewBounceView *)mTopBounceView
{
    return [_meBrowserView mTopBounceView];
}

-(void)setMTopBounceView:(EBrowserViewBounceView *)inmTopBounceView
{
    [_meBrowserView setMTopBounceView:inmTopBounceView];
}
//@property (nonatomic,assign) EBrowserViewBounceView *mBottomBounceView;
-(EBrowserViewBounceView *)mBottomBounceView
{
    return [_meBrowserView mBottomBounceView];
}

-(void)setMBottomBounceView:(EBrowserViewBounceView *)inmBottomBounceView
{
    [_meBrowserView setMBottomBounceView:inmBottomBounceView];
}
//@property (nonatomic,assign) UIScrollView *mScrollView;
-(UIScrollView *)mScrollView
{
    return [_meBrowserView mScrollView];
}

-(void)setMScrollView:(UIScrollView *)inmScrollView
{
    [_meBrowserView setMScrollView:inmScrollView];
}
//@property (nonatomic) float lastScrollPointY;
-(float)lastScrollPointY
{
    return [_meBrowserView lastScrollPointY];
}

-(void)setLastScrollPointY:(float)inlastScrollPointY
{
    [_meBrowserView setLastScrollPointY:inlastScrollPointY];
}
//@property (nonatomic) float nowScrollPointY;
-(float)nowScrollPointY
{
    return [_meBrowserView nowScrollPointY];
}

-(void)setNowScrollPointY:(float)innowScrollPointY
{
    [_meBrowserView setNowScrollPointY:innowScrollPointY];
}
//@property (nonatomic,assign) float bottom;
-(float)bottom
{
    return [_meBrowserView bottom];
}

-(void)setBottom:(float)bottom
{
    [_meBrowserView setBottom:bottom];
}

//@property int mType;
-(int)mType
{
    return [_meBrowserView mType];
}

-(void)setMType:(int)inmType
{
    [_meBrowserView setMType:inmType];
}
//@property int mFlag;
-(int)mFlag
{
    return [_meBrowserView mFlag];
}

-(void)setMFlag:(int)inmFlag
{
    [_meBrowserView setMFlag:inmFlag];
}
//@property int mTopBounceState;
-(int)mTopBounceState
{
    return [_meBrowserView mTopBounceState];
}

-(void)setMTopBounceState:(int)inmTopBounceState
{
    [_meBrowserView setMTopBounceState:inmTopBounceState];
}
//@property int mBottomBounceState;
-(int)mBottomBounceState
{
    return [_meBrowserView mBottomBounceState];
}

-(void)setMBottomBounceState:(int)inmBottomBounceState
{
    [_meBrowserView setMBottomBounceState:inmBottomBounceState];
}

//@property int mAdType;
-(int)mAdType
{
    return [_meBrowserView mAdType];
}

-(void)setMAdType:(int)inmAdType
{
    [_meBrowserView setMAdType:inmAdType];
}

//@property int mAdDisplayTime;
-(int)mAdDisplayTime
{
    return [_meBrowserView mAdDisplayTime];
}

-(void)setMAdDisplayTime:(int)inmAdDisplayTime
{
    [_meBrowserView setMAdDisplayTime:inmAdDisplayTime];
}
//@property int mAdIntervalTime;
-(int)mAdIntervalTime
{
    return [_meBrowserView mAdIntervalTime];
}

-(void)setMAdIntervalTime:(int)inmAdIntervalTime
{
    [_meBrowserView setMAdIntervalTime:inmAdIntervalTime];
}
//@property int mAdFlag;
-(int)mAdFlag
{
    return [_meBrowserView mAdFlag];
}

-(void)setMAdFlag:(int)inmAdFlag
{
    [_meBrowserView setMAdFlag:inmAdFlag];
}
//@property (nonatomic,retain)NSURL *currentUrl;
-(NSURL *)currentUrl
{
    return [_meBrowserView currentUrl];
}

-(void)setCurrentUrl:(NSURL *)incurrentUrl
{
    [_meBrowserView setCurrentUrl:incurrentUrl];
}
//@property (nonatomic)BOOL isMuiltPopover;
-(BOOL)isMuiltPopover
{
    return [_meBrowserView isMuiltPopover];
}

-(void)setIsMuiltPopover:(BOOL)inisMuiltPopover
{
    [_meBrowserView setIsMuiltPopover:inisMuiltPopover];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary*info=[notification userInfo];
    double animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    CGFloat hOffset = endKeyboardRect.origin.y - self.frame.origin.y - self.bottom;
    
    //if (isSysVersionBelow7_0)
    if (ACE_iOSVersion < 7.0)
    {
        hOffset -= 20;
    }
    
    CGRect popoverRect = self.frame;
    popoverRect.size.height = hOffset;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.frame = popoverRect;
    self.meBrowserView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    float y=mScrollView.contentSize.height-mScrollView.frame.size.height;
    [mScrollView setContentOffset:CGPointMake(0, y) animated:NO];
    
    [UIView commitAnimations];
}


- (void)registerKeyboardChangeEvent
{
    NSNotificationCenter * notificationCenter =[NSNotificationCenter defaultCenter];
    
    [notificationCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark - refresh


- (void)topBounceViewRefresh {
    [self.meBrowserView topBounceViewRefresh];
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
