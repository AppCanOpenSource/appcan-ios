/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "CBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowserWindow.h"
#import "EBrowserController.h"
#import "BUtility.h"
#import "WWidget.h"
//#import "FileEncrypt.h"
#import <ACEDes/FileEncrypt.h>
#import "EBrowserHistoryEntry.h"
#import "WWidgetMgr.h"
#import "EBrowserWindowContainer.h"
#import "EUExWindow.h"
#import "EUExManager.h"
#import "EUExAction.h"
#import "WidgetOneDelegate.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"

extern NSString * webappShowAactivety;
@implementation CBrowserWindow

- (void)flushCommandQueue: (EBrowserView*)eInBrwView {
	/*NSString *curCmdCount = [eInBrwView stringByEvaluatingJavaScriptFromString:@"uex.queue.commands.length;"];
	NSString *cmd = nil;
	NSURL *cmdUrl = nil;
	NSArray *cmdAction = nil;
	int cmdCount = [curCmdCount intValue];
	
	for (int i=0 ;i<cmdCount; i++) {
		cmd = [eInBrwView stringByEvaluatingJavaScriptFromString:@"uex.queue.commands.shift()[0];"];
		cmdUrl = [NSURL URLWithString:cmd];
		if ([[cmdUrl scheme] isEqualToString: @"uex"]) {
			cmdAction = [BUtility convertToArray:cmdUrl];
			if([cmdAction count] >= 3){
				[eInBrwView.meUExManager doAction:cmdAction];
			}
		}
	}*/
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
	if (webView != NULL) {
		EBrowserView *eBrwView = (EBrowserView*)webView;
		ACENSLog(@"webViewDidStartLoad url is %@", [webView.request URL]);
        NSString * url =[NSString stringWithFormat:@"%@",[webView.request URL]];
        if ([webappShowAactivety isEqualToString:@"yes"] && [url hasPrefix:@"http"] )
        {
            [eBrwView.indicatorView startAnimating];
        }
        

		[eBrwView notifyPageStart];
	}
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
	//[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    if (!theApp.isFirstPageDidLoad) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        id pushStr = [defaults objectForKey:@"pushData"];
        if (pushStr) {
            EBrowserView *eBrwView = (EBrowserView*)webView;
            EBrowserWindowContainer * aboveWindowContainer = [eBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
            [aboveWindowContainer pushNotify];
        }
        theApp.isFirstPageDidLoad = YES;
    }
	if (webView != NULL) {
		EBrowserView *eBrwView = (EBrowserView*)webView;
        NSString * url =[NSString stringWithFormat:@"%@",[webView.request URL]];
        if ([webappShowAactivety isEqualToString:@"yes"] && [url hasPrefix:@"http"] )
        {
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
	}
	//[BUtility cookieDebugForBroad];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	if (webView != NULL) {
		ACENSLog(@"didFailLoadWithError url is %@", [webView.request URL]);
		ACENSLog(@"page loaded failed! Error - %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
		[((EBrowserView*)webView) notifyPageError];
	}
}

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	if (webView != NULL) {
		EBrowserView *eBrwView = ((EBrowserView*)webView);
		NSURL *requestURL = [request URL];
        //NSLog(@"ebrowserView is %@", eBrwView);
//		NSLog(@"~~~~~~~~~~~~~~~need load url is %@", requestURL);
//		NSLog(@"~~~~~~~~~~~~~~~main document url is %@", [request mainDocumentURL]);
		if(UIWebViewNavigationTypeOther == navigationType) {
			//ACENSLog(@"CBrowserWindow.shouldStartLoadWithRequest: req url is %@", [requestURL absoluteString]);
			if ([[requestURL scheme] isEqualToString: @"uex"]) {
				EUExAction *action = [BUtility convertToAction:requestURL];
				[eBrwView stringByEvaluatingJavaScriptFromString:@"uex.queue.commands.shift();"];
                //
               
                if (eBrwView.meBrwCtrler.forebidPluginsList && [eBrwView.meBrwCtrler.forebidPluginsList count]>0) {
                    NSString *uexObj = action.mClassName;
                    NSArray *forbidList = eBrwView.meBrwCtrler.forebidPluginsList;
                    for (NSDictionary *pluginDict in forbidList) {
                        NSString *pluginName =[pluginDict objectForKey:@"name"];
                        if ([uexObj isEqualToString:pluginName]) {
                            [self performSelectorOnMainThread:@selector(alertForbidView:) withObject:uexObj waitUntilDone:NO];
                        }else{
                            [eBrwView.meUExManager doAction:action];
                        }
                    }
                }else{
                     [eBrwView.meUExManager doAction:action];
                }
				return NO;
			} 
		}
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
			if (eBrwView.mType == F_EBRW_VIEW_TYPE_MAIN) {
				[eBrwView stringByEvaluatingJavaScriptFromString:@"uex.queue.commands = [];"];
				if ([[requestURL scheme] isEqualToString: @"http"]) {
					if (![BUtility isConnected]) {
						NSString *errorPath = [BUtility getResPath:@"error/error.html"];
						NSURL *errorURL = [BUtility stringToUrl:errorPath];
						[eBrwView loadWithUrl:errorURL];
						return NO;
					}
				}
				WWidget *wWgt = eBrwView.meBrwCtrler.mwWgtMgr.wMainWgt;
				//EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwView.meBrwWnd.superview;
                
                EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eBrwView];
                
                
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
							//YFMOD
							[eHisEntry release];
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
	
	return YES;
}

-(void)alertForbidView:(NSString*)uexPluginName{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@对象被禁止使用，请联系管理员。",uexPluginName] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
    [alertView release];
}

- (void)dealloc {
    [super dealloc];
}
@end
