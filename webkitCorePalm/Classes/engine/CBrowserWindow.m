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


#import "EUExAction.h"
#import "WidgetOneDelegate.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "ACEBrowserView.h"
#import "ONOXMLElement+ACEConfigXML.h"

extern NSString * webappShowAactivety;

const float AppCanInitialProgressValue = 0.1f;
const float AppCanInteractiveProgressValue = 0.5f;
const float AppCanFinalProgressValue = 0.9f;

@interface CBrowserWindow ()

@property (nonatomic, assign) NSUInteger loadingCount;
@property (nonatomic, assign) NSUInteger maxLoadCount;
@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, strong) NSURL * currentURL;
@property (nonatomic, assign) float progress;
//@property (nonatomic, retain) NSMutableArray * historyURLs;

@end

@implementation CBrowserWindow

- (instancetype)init {
    if (self = [super init]) {
        _loadingCount = 0;
        _maxLoadCount = 0;
        _interactive = NO;
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
        [self webViewDidStartLoadOption:webView];
	}
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    if (!theApp.isFirstPageDidLoad) {

        if (theApp.launchedByRemoteNotification) {
            ACEBrowserView *eBrwView = (ACEBrowserView *)webView;
            EBrowserWindowContainer * aboveWindowContainer = [eBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
            [aboveWindowContainer pushNotify];
        }
        [theApp rootPageDidFinishLoading];
        theApp.isFirstPageDidLoad = YES;
    }
	if (webView != NULL) {
		ACEBrowserView * eBrwView = (ACEBrowserView *)webView;
        NSString * url =[NSString stringWithFormat:@"%@",[webView.request URL]];
        if ([webappShowAactivety isEqualToString:@"yes"] && [url hasPrefix:@"http"] ){
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
        [self webViewDidFinishLoadOption:webView];
        
	}
	//[BUtility cookieDebugForBroad];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if (webView != NULL) {
		ACENSLog(@"didFailLoadWithError url is %@", [webView.request URL]);
		ACENSLog(@"page loaded failed! Error - %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
		[((ACEBrowserView *)webView) notifyPageError];
        [((ACEBrowserView *)webView) continueMultiPopoverLoading];
        NSURLRequest *request = webView.request;
        
        BOOL isFrame = ![[[request URL] absoluteString] isEqualToString:[[request mainDocumentURL] absoluteString]];
        if (!isFrame) {
            NSString *errorPath = [self errorHTMLPath];
            NSURL *errorURL = [BUtility stringToUrl:errorPath];
            if(![webView.request.URL.path isEqual:errorPath]){
                [((ACEBrowserView *)webView) loadWithUrl:errorURL];
            }
        }
        

        
        [self webView:webView didFailLoadWithErrorOption:error];
        
	}
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
                    
                    [self completeProgress];
                    
					return NO;
				}
			}
		}
		BOOL isFrame = ![[[request URL] absoluteString] isEqualToString:[[request mainDocumentURL] absoluteString]];
		if (!isFrame) {
			//[self flushCommandQueue:eBrwView];
            void (^showErrorPage)(void) = ^{
                NSString *errorPath = [self errorHTMLPath];
                NSURL *errorURL = [BUtility stringToUrl:errorPath];
                [eBrwView loadWithUrl:errorURL];
                [self completeProgress];
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
			if (eBrwView.mType == F_EBRW_VIEW_TYPE_MAIN) {
				//[eBrwView stringByEvaluatingJavaScriptFromString:@"uex.queue.commands = [];"];
                



				WWidget *wWgt = eBrwView.meBrwCtrler.mwWgtMgr.wMainWgt;
				//EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwView.meBrwWnd.superview;
                
                EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eBrwView.superDelegate];
                
                
				if (eBrwWndContainer) {
					wWgt = eBrwWndContainer.mwWgt;
				}
				if (wWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
					if (eBrwView.mType == F_EBRW_VIEW_TYPE_MAIN) {
						EBrowserWindow *eBrwWnd = (EBrowserWindow*)eBrwView.meBrwWnd;
						EBrowserHistoryEntry *eHisEntry = [eBrwWnd curHisEntry];
						ACENSLog(@"his: %@", [eHisEntry.mUrl absoluteString]);
						ACENSLog(@"req: %@", [requestURL absoluteString]);
						if (![eHisEntry.mUrl isEqual:requestURL]) {
							eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:requestURL obfValue:NO];
							[eBrwWnd addHisEntry:eHisEntry];
						}
					}
				}
			}
		}
        //URL
		/*ACENSLog(@"URL: %@", [request URL]);
		// NSURLRequest:
		//allHTTPHeaderFields
		ACENSLog(@"allHTTPHeaderFields: %@", [request allHTTPHeaderFields]);
		//cachePolicy
		ACENSLog(@"catch policy is %d", [request cachePolicy]);
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie* cookie in [cookieStorage cookies]) {
            ACENSLog(@"cookie name is %d", cookie.name);
            ACENSLog(@"cookie domain is %@", cookie.domain);
            ACENSLog(@"cookie path is %d", cookie.path);
            ACENSLog(@"cookie portList is %@", cookie.portList);
            ACENSLog(@"cookie value is %@", cookie.value);
            ACENSLog(@"cookie expiresDate is %@", cookie.expiresDate);
            ACENSLog(@"cookie comment is %@", cookie.comment);
            ACENSLog(@"cookie commentURL is %@", cookie.commentURL);
            ACENSLog(@"cookie version is %d", cookie.version);
            ACENSLog(@"cookie isHTTPOnly is %d", cookie.isHTTPOnly);
            ACENSLog(@"cookie isSecure is %d", cookie.isSecure);
            ACENSLog(@"cookie isSessionOnly is %d", cookie.isSessionOnly);
            ACENSLog(@"cookie properties is %@", cookie.properties);
            ACENSLog(@"##################################################");
        }
        ACENSLog(@"cookie for http header is %@", [NSHTTPCookie requestHeaderFieldsWithCookies:[cookieStorage cookies]]);
		//HTTPBody
		ACENSLog(@"HTTPBody: %@", [request HTTPBody]);
		//HTTPBodyStream
		ACENSLog(@"HTTPBodyStream: %@", [request HTTPBodyStream]);
		//HTTPMethod
		ACENSLog(@"HTTPMethod: %@", [request HTTPMethod]);
		//HTTPShouldHandleCookies
		ACENSLog(@"HTTPShouldHandleCookies: %d", [request HTTPShouldHandleCookies]);
		//HTTPShouldUsePipelining
		ACENSLog(@"HTTPShouldUsePipelining: %d", [request HTTPShouldUsePipelining]);
		//mainDocumentURL
		ACENSLog(@"mainDocumentURL: %@", [request mainDocumentURL]);
		//networkServiceType
		ACENSLog(@"networkServiceType: %d", [request networkServiceType]);
		//timeoutInterval
		ACENSLog(@"timeoutInterval: %f", [request timeoutInterval]);*/
	}
    
    [self webView:webView shouldStartLoadWithRequestOption:request navigationType:navigationType];
	
	return YES;
}

-(void)alertForbidView:(NSString*)uexPluginName{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:ACELocalized(@"提示") message:[NSString stringWithFormat:@"%@%@",uexPluginName,ACELocalized(@"对象被禁止使用，请联系管理员")] delegate:nil cancelButtonTitle:nil otherButtonTitles:ACELocalized(@"确定"), nil];
    [alertView show];
}

- (void)dealloc {
    
//    if (_historyURLs) {
//        [_historyURLs removeAllObjects];
//        [_historyURLs release];
//        _historyURLs = nil;
//    }
    
}

#pragma mark - progressMethod

- (void)webViewDidStartLoadOption:(UIWebView *)webView {
    self.loadingCount++;
    self.maxLoadCount = MAX(self.maxLoadCount, self.loadingCount);
    [self startProgress];
    
}

- (void)webViewDidFinishLoadOption:(UIWebView *)webView {
    self.loadingCount--;
    [self incrementProgress];
    
    NSString * readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = YES;
        //                NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        //                [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = self.currentURL && [self.currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithErrorOption:(NSError *)error {
    self.loadingCount--;
    [self incrementProgress];
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        self.interactive = YES;
        //                NSString *waitForCompleteJS = [NSString stringWithFormat:@"window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '%@://%@%@'; document.body.appendChild(iframe);  }, false);", webView.request.mainDocumentURL.scheme, webView.request.mainDocumentURL.host, completeRPCURLPath];
        //                [webView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = self.currentURL && [self.currentURL isEqual:webView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if ((complete && isNotRedirect) || error) {
        [self completeProgress];
    }
    
}

- (void)webView:(UIWebView*)webView shouldStartLoadWithRequestOption:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL isFragmentJump = NO;
    
    if (request.URL.fragment) {
        
        NSString * nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
        
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (!isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        
        self.currentURL = request.URL;
        
//        [_historyURLs addObject:request.URL];
        
        [self resetProgress];
        
    }
    
}


- (void)startProgress {
    
    if (_progress < AppCanInitialProgressValue) {
        
        [self setProgress:AppCanInitialProgressValue];
        
    }
    
}

- (void)incrementProgress {
    
    float progress = self.progress;
    float maxProgress = self.interactive ? AppCanFinalProgressValue : AppCanInteractiveProgressValue;
    float remainPercent = (float)self.loadingCount / (float)self.maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
    
}

- (void)completeProgress {
    
    [self setProgress:1.0];
    
}

- (void)setProgress:(float)progress {
    
    if (progress > _progress || progress == 0) {
        _progress = progress;
        //NSLog(@"AppCan==setProgress==%f",progress);
        NSString * onProgressChangeJS = [NSString stringWithFormat:@"if(window.onProgressChanged){window.onProgressChanged(%lu)}",(unsigned long)(progress * 100)];
        [self stringByEvaluatingJavaScriptFromString:onProgressChangeJS];
        
    }
}

- (void)resetProgress {
    self.maxLoadCount = 0;
    self.loadingCount = 0;
    self.interactive = NO;
    [self setProgress:0.0];
    
}

#pragma mark - error page path

- (NSString *)errorHTMLPath{
    static NSString *errorHTMLPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorHTMLPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"error/error.html"];
        ONOXMLElement *configXML = [ONOXMLElement ACEOriginConfigXML];
        ONOXMLElement *errorXML = [configXML firstChildWithTag:@"error"];
        if (errorXML && errorXML[@"src"]) {
            errorHTMLPath = [NSString pathWithComponents:@[[NSBundle mainBundle].resourcePath,@"widget",errorXML[@"src"]]];
        }
    });
    return errorHTMLPath;
}

@end
