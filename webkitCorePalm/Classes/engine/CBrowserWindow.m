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

#import "CBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowserWindow.h"
#import "EBrowserController.h"
#import "BUtility.h"
#import "WWidget.h"
#import "FileEncrypt.h"
#import "EBrowserHistoryEntry.h"
#import "WWidgetMgr.h"
#import "EBrowserWindowContainer.h"



#import "WidgetOneDelegate.h"
#import "EBrowserMainFrame.h"
#import "ACEBrowserView.h"
#import "ACEConfigXML.h"

extern NSString * webappShowAactivety;

const float AppCanInitialProgressValue = 0.1f;
const float AppCanInteractiveProgressValue = 0.5f;
const float AppCanFinalProgressValue = 0.9f;

@interface CBrowserWindow ()
@property (nonatomic, strong) NSURL * currentURL;
@end

@implementation CBrowserWindow

- (instancetype)init {
    if (self = [super init]) {

        //        _historyURLs = [[NSMutableArray alloc]init];
    }
    return self;
    
}

- (void)flushCommandQueue: (EBrowserView*)eInBrwView {
    
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != NULL) {
        ACEBrowserView *eBrwView = (ACEBrowserView *)webView;
        ACENSLog(@"webViewDidStartLoad url is %@", [webView.request URL]);
        NSString * url =[NSString stringWithFormat:@"%@",[webView.request URL]];
        if ([webappShowAactivety isEqualToString:@"yes"] && [url hasPrefix:@"http"] ){
            [eBrwView.indicatorView startAnimating];
        }
        [eBrwView notifyPageStart];
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    ACEBrowserView * eBrwView = (ACEBrowserView *)webView;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACEMP_TransitionView_Close_Notify object:eBrwView.superDelegate];
    
    eBrwView.retryCount = 0;
    NSString * urlString = [webView.request URL].absoluteString;
    if ([webappShowAactivety isEqualToString:@"yes"] && [urlString hasPrefix:@"http"] ){
        [eBrwView.indicatorView stopAnimating];
    }
    
    WWidget *inCurWgt = eBrwView.mwWgt;
    BOOL isDebug = inCurWgt.isDebug;
    if (isDebug) {
        NSString * logserveripStr = inCurWgt.logServerIp;
        NSString * srcString = [NSString stringWithFormat:@"http://%@:30060/target/target-script-min.js#anonymous",logserveripStr];
        NSString * script =  [NSString stringWithFormat:@"var x = document.createElement(\"SCRIPT\");x.setAttribute('src','%@');document.body.appendChild(x);",srcString];
        [eBrwView stringByEvaluatingJavaScriptFromString:script];
    }
    [eBrwView notifyPageFinish];
    [eBrwView continueMultiPopoverLoading];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AppCanEngine rootPageDidFinishLoading];
    });
    

}

static NSUInteger kMaxErrorRetryCount = 5;


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    ACEBrowserView *aceWebView = (ACEBrowserView *)webView;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ACEMP_TransitionView_Close_Notify object:aceWebView.superDelegate];
    
    [aceWebView notifyPageError];
    [aceWebView continueMultiPopoverLoading];
    
}

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != NULL) {
        ACEBrowserView *eBrwView = ((ACEBrowserView *)webView);
        NSURL *requestURL = [request URL];
        if (((eBrwView.mFlag & F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED) == F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED) && (eBrwView.mFlag & F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN) == F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN) {
            NSURL *oldURL = [eBrwView curUrl];
            if (oldURL) {
                if (![[requestURL host] isEqualToString:[oldURL host]]) {
                    [[UIApplication sharedApplication] openURL:requestURL];
                    return NO;
                }
            }
        }
        BOOL isFrame = ![[[request URL] absoluteString] isEqualToString:[[request mainDocumentURL] absoluteString]];
        if (!isFrame) {
            //[self flushCommandQueue:eBrwView];
            void (^showErrorPage)(void) = ^{
                if (eBrwView.retryCount < kMaxErrorRetryCount) {
                    eBrwView.retryCount++;
                    NSString *errorPath = [self errorHTMLPath];
                    NSURL *errorURL = [BUtility stringToUrl:errorPath];
                    [eBrwView loadWithUrl:errorURL];
                }
            };
            if ([requestURL isFileURL] && ![[NSFileManager defaultManager]fileExistsAtPath:requestURL.path]) {
                showErrorPage();
                return NO;
            }
            if ([[requestURL scheme].lowercaseString isEqualToString: @"http"] || [[requestURL scheme].lowercaseString isEqualToString: @"https"]) {
                if (![BUtility isConnected]) {
                    showErrorPage();
                    return NO;
                }
            }
            if (eBrwView.mType == ACEEBrowserViewTypeMain) {
                WWidget *wWgt = eBrwView.meBrwCtrler.mwWgtMgr.mainWidget;
                EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eBrwView.superDelegate];
                if (eBrwWndContainer) {
                    wWgt = eBrwWndContainer.mwWgt;
                }
                if (wWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
                    EBrowserWindow *eBrwWnd = (EBrowserWindow*)eBrwView.meBrwWnd;
                    EBrowserHistoryEntry *eHisEntry = [eBrwWnd curHisEntry];
                    if (![eHisEntry.mUrl isEqual:requestURL]) {
                        eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:requestURL obfValue:NO];
                        [eBrwWnd addHisEntry:eHisEntry];
                    }
                }
            }
        }
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString * nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
        
    }
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (!isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        
        self.currentURL = request.URL;
    }
    
    return YES;
}










#pragma mark - error page path

- (NSString *)errorHTMLPath{
    static NSString *errorHTMLPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorHTMLPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"error/error.html"];
        ONOXMLElement *configXML = [ACEConfigXML ACEOriginConfigXML];
        ONOXMLElement *errorXML = [configXML firstChildWithTag:@"error"];
        if (errorXML && errorXML[@"src"]) {
            errorHTMLPath = [NSString pathWithComponents:@[[NSBundle mainBundle].resourcePath,[AppCanEngine.configuration originWidgetPath],errorXML[@"src"]]];
        }
    });
    return errorHTMLPath;
}

@end
