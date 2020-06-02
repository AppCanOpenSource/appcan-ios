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
#import "EBrowserHistoryEntry.h"

#import "BUtility.h"
#import "CBrowserWindow.h"

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
#import "EBrowserHistory.h"
#import <objc/runtime.h>
#import <objc/message.h>

#import "ACEJSCInvocation.h"

#import "ACEMultiPopoverScrollView.h"
#import "ACEPluginViewContainer.h"
@interface EBrowserView ()
@property (nonatomic,assign)BOOL initialized;
@end

@implementation EBrowserView{
    float version;
    
}
/*

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
*/
- (void)dealloc{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setFrame:(CGRect)frame {
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

- (void)loadUEXScript{
    if (_meBrowserView) {
        [_meBrowserView loadUEXScript];
    }
}

- (void)notifyPageError
{
    if (_meBrowserView) {
        [_meBrowserView notifyPageError];
    }
}

- (void)notifyPageFinish
{
    if (_meBrowserView) {
        [_meBrowserView notifyPageFinish];
    }
}

- (void)notifyPageStart
{
    if (_meBrowserView) {
        [_meBrowserView notifyPageStart];
    }
}

- (void)bounceViewStartLoadWithType:(int)inType
{
    if (_meBrowserView) {
        [_meBrowserView bounceViewStartLoadWithType:inType];
    }
}

- (void)bounceViewFinishLoadWithType:(int)inType
{
    if (_meBrowserView) {
        [_meBrowserView bounceViewFinishLoadWithType:inType];
    }
}

- (void)reset{
    if (_meBrowserView) {
        [_meBrowserView reset];
    }
}

- (void)reuseWithFrame:(CGRect)frame
            BrwCtrler:(EBrowserController *)eInBrwCtrler
                  Wgt:(WWidget *)inWgt
               BrwWnd:(EBrowserWindow *)eInBrwWnd
           UExObjName:(NSString *)inUExObjName
                 Type:(ACEEBrowserViewType)inWndType{
    if (self.meBrowserView)
    {
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        [_meBrowserView reuseWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:inWgt BrwWnd:eInBrwWnd UExObjName:inUExObjName Type:inWndType BrwView:self];
        _meBrowserView.superDelegate = self;
        
        

    }
}

-(id)initWithFrame:(CGRect)frame
         BrwCtrler:(EBrowserController *)eInBrwCtrler
               Wgt:(WWidget *)inWgt
            BrwWnd:(EBrowserWindow *)eInBrwWnd
        UExObjName:(NSString *)inUExObjName
              Type:(ACEEBrowserViewType)inWndType{
    if (self = [super initWithFrame:frame]) {

        _initialized = NO;
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        frame.origin.y = 0;
        
        _meBrowserView = [[ACEBrowserView alloc] initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:inWgt BrwWnd:eInBrwWnd UExObjName:inUExObjName Type:inWndType BrwView:(EBrowserView *)self];
        
        _meBrowserView.superDelegate = self;
        
        [self addSubview:_meBrowserView];
        
        if (self.meBrwWnd.windowOptions) {
            self.autoresizesSubviews = YES;
            self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
        
        _initialized = YES;
    }
    return self;
}

- (void)ac_evaluateJavaScript:(NSString *)script
{
    if (self.meBrowserView) {
        [_meBrowserView ac_evaluateJavaScript:script];
    }
}

- (void)ac_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    if (self.meBrowserView) {
        [_meBrowserView ac_evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    [self ac_evaluateJavaScript:script];
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
    // AppCanWKTODO 暂无实现方式
    return nil;
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
//    return [_meBrowserView scalesPageToFit];
    return YES;
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
//    [_meBrowserView setScalesPageToFit:scalesPageToFit];
}


//@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
-(UIDataDetectorTypes)dataDetectorTypes
{
    // AppCanWKTODO 暂无实现方式
//    return [_meBrowserView dataDetectorTypes];
}

- (void)setDataDetectorTypes:(UIDataDetectorTypes)dataDetectorTypes
{
    // AppCanWKTODO 暂无实现方式
//    [_meBrowserView setDataDetectorTypes:dataDetectorTypes];
}

//@property (nonatomic) BOOL allowsInlineMediaPlayback;
-(BOOL)allowsInlineMediaPlayback
{
    // AppCanWKTODO 暂无实现方式
//    return [_meBrowserView allowsInlineMediaPlayback];
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback
{
    // AppCanWKTODO 暂无实现方式
//    [_meBrowserView setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
}
//@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
-(BOOL)mediaPlaybackRequiresUserAction
{
    // AppCanWKTODO 暂无实现方式
//    return [_meBrowserView mediaPlaybackRequiresUserAction];
}

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction
{
    // AppCanWKTODO 暂无实现方式
//    [_meBrowserView setMediaPlaybackRequiresUserAction:mediaPlaybackRequiresUserAction];
}
//@property (nonatomic) BOOL mediaPlaybackAllowsAirPlay;
-(BOOL)mediaPlaybackAllowsAirPlay
{
    // AppCanWKTODO 暂无实现方式
//    return [_meBrowserView mediaPlaybackAllowsAirPlay];
}

- (void)setMediaPlaybackAllowsAirPlay:(BOOL)mediaPlaybackAllowsAirPlay
{
    // AppCanWKTODO 暂无实现方式
//    [_meBrowserView setMediaPlaybackAllowsAirPlay:mediaPlaybackAllowsAirPlay];
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
        [_meBrowserView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
    }
}

- (void)reload{
    if (_meBrowserView) {
        if (_meBrowserView.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
            
            EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:_meBrowserView.currentUrl obfValue:YES];
            [_meBrowserView.meBrwWnd addHisEntry:eHisEntry];
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *data = [encryptObj decryptWithPath:_meBrowserView.currentUrl appendData:nil];
            [_meBrowserView loadWithData:data baseUrl:_meBrowserView.currentUrl];
        }else{
            [_meBrowserView reload];
        }
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





-(EBrowserController *)meBrwCtrler
{
    return [_meBrowserView meBrwCtrler];
}




-(CBrowserWindow *)mcBrwWnd
{
    return [_meBrowserView mcBrwWnd];
}

- (void)setMcBrwWnd:(CBrowserWindow *)inmcBrwWnd
{
    [_meBrowserView setMcBrwWnd:inmcBrwWnd];
}

-(EBrowserWindow *)meBrwWnd
{
    return [_meBrowserView meBrwWnd];
}

- (void)setMeBrwWnd:(EBrowserWindow *)inmeBrwWnd
{
    [_meBrowserView setMeBrwWnd:inmeBrwWnd];
}
//@property (nonatomic,assign) WWidget *mwWgt;
-(WWidget *)mwWgt
{
    return [_meBrowserView mwWgt];
}


//@property (nonatomic,copy) NSString *muexObjName;
-(NSString *)muexObjName
{
    return [_meBrowserView muexObjName];
}

- (void)setMuexObjName:(NSString *)inmuexObjName
{
    [_meBrowserView setMuexObjName:inmuexObjName];
}

//@property (nonatomic,assign) NSMutableDictionary *mPageInfoDict;
-(NSMutableDictionary *)mPageInfoDict
{
    return [_meBrowserView mPageInfoDict];
}

- (void)setMPageInfoDict:(NSMutableDictionary *)inmPageInfoDict
{
    [_meBrowserView setMPageInfoDict:inmPageInfoDict];
}
//@property (nonatomic,assign) EBrowserViewBounceView *mTopBounceView;
-(EBrowserViewBounceView *)mTopBounceView
{
    return [_meBrowserView mTopBounceView];
}

- (void)setMTopBounceView:(EBrowserViewBounceView *)inmTopBounceView
{
    [_meBrowserView setMTopBounceView:inmTopBounceView];
}
//@property (nonatomic,assign) EBrowserViewBounceView *mBottomBounceView;
-(EBrowserViewBounceView *)mBottomBounceView
{
    return [_meBrowserView mBottomBounceView];
}

- (void)setMBottomBounceView:(EBrowserViewBounceView *)inmBottomBounceView
{
    [_meBrowserView setMBottomBounceView:inmBottomBounceView];
}
//@property (nonatomic,assign) UIScrollView *mScrollView;
-(UIScrollView *)mScrollView
{
    return [_meBrowserView mScrollView];
}

- (void)setMScrollView:(UIScrollView *)inmScrollView
{
    [_meBrowserView setMScrollView:inmScrollView];
}
//@property (nonatomic) float lastScrollPointY;
-(float)lastScrollPointY
{
    return [_meBrowserView lastScrollPointY];
}

- (void)setLastScrollPointY:(float)inlastScrollPointY
{
    [_meBrowserView setLastScrollPointY:inlastScrollPointY];
}
//@property (nonatomic) float nowScrollPointY;
-(float)nowScrollPointY
{
    return [_meBrowserView nowScrollPointY];
}

- (void)setNowScrollPointY:(float)innowScrollPointY
{
    [_meBrowserView setNowScrollPointY:innowScrollPointY];
}
//@property (nonatomic,assign) float bottom;
-(float)bottom
{
    return [_meBrowserView bottom];
}

- (void)setBottom:(float)bottom
{
    [_meBrowserView setBottom:bottom];
}

//@property int mType;
-(ACEEBrowserViewType)mType
{
    return [_meBrowserView mType];
}

- (void)setMType:(ACEEBrowserViewType)inmType
{
    [_meBrowserView setMType:inmType];
}
//@property int mFlag;
-(int)mFlag
{
    return [_meBrowserView mFlag];
}

- (void)setMFlag:(int)inmFlag
{
    [_meBrowserView setMFlag:inmFlag];
}
//@property int mTopBounceState;
-(int)mTopBounceState
{
    return [_meBrowserView mTopBounceState];
}

- (void)setMTopBounceState:(int)inmTopBounceState
{
    [_meBrowserView setMTopBounceState:inmTopBounceState];
}
//@property int mBottomBounceState;
-(int)mBottomBounceState
{
    return [_meBrowserView mBottomBounceState];
}

- (void)setMBottomBounceState:(int)inmBottomBounceState
{
    [_meBrowserView setMBottomBounceState:inmBottomBounceState];
}



//@property (nonatomic,retain)NSURL *currentUrl;
-(NSURL *)currentUrl
{
    return [_meBrowserView currentUrl];
}

- (void)setCurrentUrl:(NSURL *)incurrentUrl
{
    [_meBrowserView setCurrentUrl:incurrentUrl];
}
//@property (nonatomic)BOOL isMuiltPopover;
-(BOOL)isMuiltPopover
{
    return [_meBrowserView isMuiltPopover];
}

- (void)setIsMuiltPopover:(BOOL)inisMuiltPopover
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
    if (ACSystemVersion() < 7.0)
    {
        hOffset -= 20;
    }
    
    CGRect popoverRect = self.frame;
    popoverRect.size.height = hOffset;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    self.frame = popoverRect;
    self.meBrowserView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    float y = self.mScrollView.contentSize.height - self.mScrollView.frame.size.height;
    [self.mScrollView setContentOffset:CGPointMake(0, y) animated:NO];
    
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

#pragma mark - AppCanWebViewEngineObject


- (void)addSubview:(UIView *)view{
    
    if (_initialized) {
        [self.meBrwWnd addSubview:view];
    }else{
        [super addSubview:view];
    }
}

- (__kindof UIView*)webView{
    return self;
}


- (__kindof UIScrollView *)webScrollView{
    return self.scrollView;
}

- (__kindof UIViewController *)viewController{
    return self.meBrwCtrler;
}

- (id<AppCanWidgetObject>)widget{
    return self.mwWgt;
}

- (NSURL *)currentURL{
    return self.meBrowserView.currentUrl;
}

- (void)evaluateScript:(NSString *)jsScript{
    if ([NSThread isMainThread]) {
        [self ac_evaluateJavaScript:jsScript completionHandler:nil];
    }else{
        dispatch_async(dispatch_get_main_queue(),^{
            [self ac_evaluateJavaScript:jsScript completionHandler:nil];
        });
    }
}

/// 已经弃用
- (void)callbackWithFunctionKeyPath:(NSString *)JSKeyPath arguments:(NSArray *)arguments completion:(void (^)(JSValue * ))completion DEPRECATED_MSG_ATTRIBUTE("AppCanKit: JavascriptCore 已经不再使用, 本方法过时，回调请使用 callbackWithFunctionKeyPath:arguments:withCompletionHandler: 代替"){
    [self callbackWithFunctionKeyPath:JSKeyPath arguments:arguments withCompletionHandler:nil];
}

/// 回调注入JS的主要方法
- (void)callbackWithFunctionKeyPath:(NSString *)JSKeyPath arguments:(NSArray *)arguments withCompletionHandler:(nullable void (^)(id _Nullable, NSError * _Nullable))completion{
    ACEJSCInvocation *invocation = [ACEJSCInvocation
                                    invocationWithACJSContext:_meBrowserView
                                    FunctionJs:JSKeyPath
                                    arguments:arguments
                                    completionHandler:completion];
    [invocation invokeOnMainThread];
}

- (void)callbackWithFunctionKeyPath:(NSString *)JSKeyPath arguments:(NSArray *)arguments{
    [self callbackWithFunctionKeyPath:JSKeyPath arguments:arguments withCompletionHandler:nil];
}

- (nullable __kindof UIScrollView<AppCanScrollViewEventProducer> *)multiPopoverForName:(NSString *)multiPopoverName{
    EBrowserWindow *window = self.meBrowserView.meBrwWnd;
    EScrollView * multiPopover = [window.mMuiltPopoverDict objectForKey:multiPopoverName];
    return multiPopover.scrollView;
}
- (nullable __kindof UIScrollView<AppCanScrollViewEventProducer> *)pluginViewContainerForName:(NSString *)containerName{
    EBrowserWindow *window = self.meBrowserView.meBrwWnd;
    for (UIView *subView in window.subviews) {
        if(![subView isKindOfClass:[ACEPluginViewContainer class]]){
            continue;
        }
        ACEPluginViewContainer * container = (ACEPluginViewContainer *)subView;
        if (![container.containerIdentifier isEqual:containerName]) {
            continue;
        }
        return container;
    }
    return nil;
}


- (BOOL)addSubView:(UIView *)view toPluginViewContainerWithName:(NSString *)containerName atIndex:(NSInteger)index{
    ACEPluginViewContainer *container = (ACEPluginViewContainer *)[self pluginViewContainerForName:containerName];
    if (!container || !view || index < 0) {
        return NO;
    }
    CGFloat containerWidth = container.frame.size.width;
    CGRect tmp = view.frame;
    tmp.origin.x += containerWidth * index;
    view.frame = tmp;
    [container  addSubview:view];
    if (container.maxIndex < index) {
        container.maxIndex = index;
        [container setContentSize:CGSizeMake(containerWidth * (index + 1), container.frame.size.height)];
    }
    return YES;
}

- (void)setExeJS:(NSString *)exeJS{
    _meBrowserView.mExeJS = exeJS;
}

#pragma mark - WKNavigationDelegate

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    ACLogDebug(@"AppCan4.0===>WKNavigationDelegate==>didStartProvisionalNavigation");
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    ACLogDebug(@"AppCan4.0===>WKNavigationDelegate==>didReceiveServerRedirectForProvisionalNavigation");
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    ACLogError(@"AppCan4.0===>WKNavigationDelegate==>didFailProvisionalNavigation: %@", error);
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    ACLogDebug(@"AppCan4.0===>WKNavigationDelegate==>didCommitNavigation");
    [self notifyPageStart];
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    ACLogDebug(@"AppCan4.0===>WKNavigationDelegate==>didFinishNavigation");
    [self notifyPageFinish];
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    ACLogError(@"AppCan4.0===>WKNavigationDelegate==>didFailNavigation");
    [self notifyPageError];
}

/*! @abstract Invoked when the web view needs to respond to an authentication challenge.
 @param webView The web view that received the authentication challenge.
 @param challenge The authentication challenge.
 @param completionHandler The completion handler you must invoke to respond to the challenge. The
 disposition argument is one of the constants of the enumerated type
 NSURLSessionAuthChallengeDisposition. When disposition is NSURLSessionAuthChallengeUseCredential,
 the credential argument is the credential to use, or nil to indicate continuing without a
 credential.
 @discussion If you do not implement this method, the web view will respond to the authentication challenge with the NSURLSessionAuthChallengeRejectProtectionSpace disposition.
 */
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
//
//}

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)){
    ACLogDebug(@"AppCan4.0===>WKNavigationDelegate==>webViewWebContentProcessDidTerminate");
}

@end
