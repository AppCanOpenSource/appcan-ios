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

#import "ACEBrowserView.h"

#import "BUtility.h"

#import "WWidget.h"
#import "WWidgetMgr.h"
#import "BUtility.h"
#import "EBrowserController.h"
#import "EBrowser.h"
#import "EBrowserView.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserToolBar.h"
#import "FileEncrypt.h"
#import "EBrowserWindow.h"
#import "EBrowserHistoryEntry.h"
#import "EBrowserViewBounceView.h"
#import "WidgetOneDelegate.h"
#import "WidgetSQL.h"
#import "EUtility.h"
#import "EBrowserHistory.h"
#import "EBrowserHistoryEntry.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "DataAnalysisInfo.h"
#import "ACEDrawerViewController.h"

#import "ACEMultiPopoverScrollView.h"
#import "ACEJSCHandler.h"
#import "ACEJSCBaseJS.h"
#import "AppCanEngine.h"
#import "ACEUINavigationController.h"


const CGFloat refreshKeyValue = -65.0f;
const CGFloat loadingVisibleHeight = 60.0f;

@interface ACEBrowserView()<WKUIDelegate>

@end


@implementation ACEBrowserView{
    float version;

}

@synthesize indicatorView ;


@synthesize meBrwWnd;

@synthesize muexObjName;
@synthesize mPageInfoDict;
@synthesize mTopBounceView;
@synthesize mBottomBounceView;
@synthesize mScrollView;
@synthesize mFlag;
@synthesize mTopBounceState;
@synthesize mBottomBounceState;

@synthesize currentUrl;
@synthesize isMuiltPopover;
@synthesize lastScrollPointY;
@synthesize nowScrollPointY;


- (WWidget *)mwWgt{
    return self.meBrwCtrler.widget;
}

- (EBrowserController *)meBrwCtrler{
    return self.meBrwWnd.meBrwCtrler;
}

/// 进行JS交互的对象，实现了ACJSContext协议。
/// 目前的逻辑下，就直接返回ACEBrowserView本身了。
- (id<ACJSContext>)JSContext{
    return self;
}

- (void)initializeJSCHandler{
    if (self.JSCHandler) {
        [self.JSCHandler clean];
    }
    self.JSCHandler = [[ACEJSCHandler alloc] initWithEBrowserView:self.superDelegate];
    [self.JSCHandler initializeWithJSContext:[self JSContext]];
}

- (BOOL)isAppCanJSBridgePayload:(NSString *)jsPayloadStr {
    return [ACEJSCHandler isAppCanJSBridgePayload:jsPayloadStr];
}

/// 作为js中prompt接口的实现，默认需要有一个输入框一个按钮，点击确认按钮回传输入值
/// 当然可以添加多个按钮以及多个输入框，不过completionHandler只有一个参数，如果有多个输入框，需要将多个输入框中的值通过某种方式拼接成一个字符串回传，js接收到之后再做处理

/// 参数 prompt 为 prompt(<message>, <defaultValue>);中的<message>
/// 参数defaultText 为 prompt(<message>, <defaultValue>);中的 <defaultValue>
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    ACLogDebug(@"AppCan4.0===>runJavaScriptTextInputPanelWithPrompt:%@ andDefaultText:%@", prompt, defaultText);
    if ([self isAppCanJSBridgePayload:prompt]) {
        // AppCanWKTODO 进入AppCanJS的解析路由
        NSString *result = [self.JSCHandler executeWithAppCanJSBridgePayload:prompt];
        completionHandler(result);
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = defaultText;
        }];
        [alertController addAction:([UIAlertAction actionWithTitle:ACELocalized(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler(alertController.textFields[0].text?:@"");
        }])];
        
        [[self meBrwCtrler] presentViewController:alertController animated:YES completion:nil];
    }
}

/// 此方法作为js的alert方法接口的实现，默认弹出窗口应该只有提示信息及一个确认按钮，当然可以添加更多按钮以及其他内容，但是并不会起到什么作用
/// 点击确认按钮的相应事件需要执行completionHandler，这样js才能继续执行
/// 参数 message为  js 方法 alert(<message>) 中的<message>
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ACELocalized(@"提示") message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:ACELocalized(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [[self meBrwCtrler] presentViewController:alertController animated:YES completion:nil];
}

/// 作为js中confirm接口的实现，需要有提示信息以及两个相应事件， 确认及取消，并且在completionHandler中回传相应结果，确认返回YES， 取消返回NO
/// 参数 message为  js 方法 confirm(<message>) 中的<message>
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ACELocalized(@"提示") message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:ACELocalized(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:ACELocalized(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [[self meBrwCtrler] presentViewController:alertController animated:YES completion:nil];
}

-(void)multiPopoverDelay{
    [self evaluateJavaScript:@"window.uexOnload(0)" completionHandler:nil];
}

- (void)didShowKeyboard:(NSNotification *)notification
{
    [self ac_evaluateJavaScript:@"uexWindow.didShowKeyboard" completionHandler:^(id result, NSError * error) {
        if ([result isKindOfClass:[NSString class]]) {
            NSString *strKeyboardStatus = result;
            int keyboardStatus = [strKeyboardStatus intValue];
            if (keyboardStatus == 1) {
                NSDictionary* info = [notification userInfo];
                CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                if ([BUtility isValidateOrientation:(UIInterfaceOrientation)deviceOrientation] == NO) {
                    deviceOrientation = (UIDeviceOrientation)statusBarOrientation;
                }
                if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
                    [self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y - kbSize.height, self.frame.size.width, self.frame.size.height)];
                } else if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
                    [self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y - kbSize.width, self.frame.size.width, self.frame.size.height)];
                }
                mFlag |= (F_EBRW_VIEW_FLAG_SHOW_KEYBOARD | F_EBRW_VIEW_FLAG_FORBID_ROTATE);
            }
        }else{
            ACLogError(@"uexWindow.didShowKeyboard result error:%@", result);
        }
    }];
}

- (void)didHideKeyboard:(NSNotification *)notification
{
	if ((mFlag & F_EBRW_VIEW_FLAG_SHOW_KEYBOARD) == F_EBRW_VIEW_FLAG_SHOW_KEYBOARD) {
		NSDictionary* info = [notification userInfo];
		CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        [self ac_evaluateJavaScript:@"uexWindow.didShowKeyboard=0"];
		UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
		UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
		if ([BUtility isValidateOrientation:(UIInterfaceOrientation)deviceOrientation] == NO) {
			deviceOrientation = (UIDeviceOrientation)statusBarOrientation;
		}
		if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
			[self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y + kbSize.height, self.frame.size.width, self.frame.size.height)];
		} else if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
			[self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y + kbSize.width, self.frame.size.width, self.frame.size.height)];
		}
		mFlag &= ~F_EBRW_VIEW_FLAG_SHOW_KEYBOARD;
		mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_ROTATE;
	}
}

- (void)registerKeyboardListener:(id)sender
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
	[center addObserver:self selector:@selector(didHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unRegisterKeyboardListener:(id)sender
{
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:UIKeyboardDidShowNotification object:NULL];
	[center removeObserver:self name:UIKeyboardWillHideNotification object:NULL];
}

- (void)dealloc {
// AppCanWKTODO
    self.indicatorView = nil;
    [self.JSCHandler clean];
    self.JSCHandler = nil;
//    self.JSContext = nil;
    [self reset];
    self.currentUrl = nil;
//    self.delegate = nil;
    [self loadWithData:@"" baseUrl:nil];
    [self stopLoading];

}







- (void)reset {
	[self clean];
	[self unRegisterKeyboardListener:nil];
	meBrwWnd = nil;
	self.mType = 0;
	mFlag = 0;
	mTopBounceState = 0;
	mBottomBounceState = 0;
    muexObjName = nil;
    [mPageInfoDict removeAllObjects];
    mPageInfoDict = nil;
    [mTopBounceView removeFromSuperview];
    mTopBounceView = nil;
    [mBottomBounceView removeFromSuperview];
    mBottomBounceView = nil;
}

- (void)setView {
    self.currentUrl = nil;
    // AppCanWKTODO
//	self.dataDetectorTypes = UIDataDetectorTypeNone;
//	self.allowsInlineMediaPlayback = NO;
//	[self setDelegate:mcBrwWnd];
//	[self setScalesPageToFit:NO];
	[self setMultipleTouchEnabled:NO];
	[self setUserInteractionEnabled:YES];
	self.backgroundColor = [UIColor clearColor];
	self.opaque = NO;
	[mScrollView setBounces:NO];
	[mScrollView setShowsHorizontalScrollIndicator:YES];
	[mScrollView setShowsVerticalScrollIndicator:YES];
    for( UIView *innerView in [mScrollView subviews] ) {
        if( [innerView isKindOfClass:[UIImageView class]] ) {
            innerView.hidden = YES;
        }
    }
}

- (void)bounceViewStartLoadWithType:(int)inType {
	switch (inType) {
		case EBounceViewTypeTop:
			if (mTopBounceView) {
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.2f];
				if (mScrollView.contentOffset.y < 0) {
					[mTopBounceView setStatus:EBounceViewStatusLoading];
					mScrollView.contentInset = UIEdgeInsetsMake(loadingVisibleHeight, 0.0f, 0.0f, 0.0f);
				}
				[UIView commitAnimations];
			}
			break;
		case EBounceViewTypeBottom:
			if (mBottomBounceView) {
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.2f];
				if (mScrollView.contentOffset.y > 0) {
					[mBottomBounceView setStatus:EBounceViewStatusLoading];
					mScrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, loadingVisibleHeight, 0.0f);
				}
				[UIView commitAnimations];
			}
			break;
		default:
			break;
	}
}

- (void)bounceViewFinishLoadWithType:(int)inType {
	switch (inType) {
		case EBounceViewTypeTop:
        {
			if (mTopBounceView && mTopBounceView.hidden != YES) {
				mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING;
				[mTopBounceView setStatus:EBounceViewStatusPullToReload];
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.2f];
                [mScrollView setContentOffset:CGPointZero];
				mScrollView.contentInset = UIEdgeInsetsZero;
				[UIView commitAnimations];
			} else {
				mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING;
				mScrollView.contentInset = UIEdgeInsetsZero;
			}
            if (self.mScrollView.contentSize.height <= self.mScrollView.frame.size.height) {
                mBottomBounceView.hidden = YES;
            } else {
                mBottomBounceView.hidden = NO;
            }

		}
        break;
		case EBounceViewTypeBottom:{
			if (mBottomBounceView && mTopBounceView.hidden != YES) {
				mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING;
				[mBottomBounceView setStatus:EBounceViewStatusPullToReload];
                if (self.mScrollView.contentSize.height <= self.mScrollView.frame.size.height) {
                    mBottomBounceView.hidden = YES;
                } else {
                    mBottomBounceView.hidden = NO;
                }
                if (mBottomBounceView.frame.origin.y != self.mScrollView.contentSize.height) {
                   mBottomBounceView.frame = CGRectMake(mBottomBounceView.frame.origin.x, self.mScrollView.contentSize.height, mBottomBounceView.frame.size.width, mBottomBounceView.frame.size.height);
                }

				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.2f];
				mScrollView.contentInset = UIEdgeInsetsZero;
				[UIView commitAnimations];
			} else {
				mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING;
				mScrollView.contentInset = UIEdgeInsetsZero;
                if (self.mScrollView.contentSize.height <= self.mScrollView.frame.size.height) {
                    mBottomBounceView.hidden = YES;
                } else {
                    mBottomBounceView.hidden = NO;
                }
                if (mBottomBounceView.frame.origin.y != self.mScrollView.contentSize.height){
                    mBottomBounceView.frame = CGRectMake(mBottomBounceView.frame.origin.x,self.mScrollView.contentSize.height, mBottomBounceView.frame.size.width, mBottomBounceView.frame.size.height);
                 }
            }

        }
			break;
		default:
			break;
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        // AppCanWKTODO
//        [super scrollViewDidScroll:scrollView];
        
    }
	
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH) != 0) {
		if (((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) == 0)) {
			if (mTopBounceView && mTopBounceView.hidden != YES) {
				if (scrollView.contentOffset.y > refreshKeyValue && scrollView.contentOffset.y < 0.0f) {
					[mTopBounceView setStatus:EBounceViewStatusPullToReload];
					if (mTopBounceState != EBounceViewStatusPullToReload) {
						mTopBounceState = EBounceViewStatusPullToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,0);}"];
					}
				} else if (scrollView.contentOffset.y < refreshKeyValue) {
					[mTopBounceView setStatus:EBounceViewStatusReleaseToReload];
					if (mTopBounceState != EBounceViewStatusReleaseToReload) {
						mTopBounceState = EBounceViewStatusReleaseToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,1);}"];
					}
                } else {
                    mTopBounceState = EBounceViewStatusPullToReload;
                }
			} else {
				if (scrollView.contentOffset.y > refreshKeyValue && scrollView.contentOffset.y < 0.0f) {
					if (mTopBounceState != EBounceViewStatusPullToReload) {
						mTopBounceState = EBounceViewStatusPullToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,0);}"];
					}
				} else if (scrollView.contentOffset.y < refreshKeyValue) {
					if (mTopBounceState != EBounceViewStatusReleaseToReload) {
						mTopBounceState = EBounceViewStatusReleaseToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,1);}"];
					}
				}
			}
			
		}
	}
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH) != 0) {
		if (scrollView.dragging && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING) == 0)) {
			if (mBottomBounceView && mBottomBounceView.hidden != YES) {
				if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y < mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					[mBottomBounceView setStatus:EBounceViewStatusPullToReload];
					if (mBottomBounceState != EBounceViewStatusPullToReload) {
						mBottomBounceState = EBounceViewStatusPullToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,0);}"];
					}
				} else if (scrollView.contentOffset.y > mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					[mBottomBounceView setStatus:EBounceViewStatusReleaseToReload];
					if (mBottomBounceState != EBounceViewStatusReleaseToReload) {
						mBottomBounceState = EBounceViewStatusReleaseToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,1);}"];
					}
				}
			} else {
				if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y < mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					if (mBottomBounceState != EBounceViewStatusPullToReload) {
						mBottomBounceState = EBounceViewStatusPullToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,0);}"];
					}
				} else if (scrollView.contentOffset.y > mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					if (mBottomBounceState != EBounceViewStatusReleaseToReload) {
						mBottomBounceState = EBounceViewStatusReleaseToReload;
						[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,1);}"];
					}
				}
			}
		}
	}
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) != 0) {
		[self bounceViewStartLoadWithType:EBounceViewTypeTop];
		if (mTopBounceView && mTopBounceView.hidden != YES) {
			if (scrollView.contentOffset.y < 0) {
				scrollView.contentInset = UIEdgeInsetsMake(loadingVisibleHeight, 0, 0, 0);
			}
		}
		if (!mTopBounceView) {
			if (scrollView.contentOffset.y < 0) {
				scrollView.contentInset = UIEdgeInsetsMake(loadingVisibleHeight, 0, 0, 0);
			}
		}
	}
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING) != 0) {
		[self bounceViewStartLoadWithType:EBounceViewTypeBottom];
		if (mBottomBounceView && mBottomBounceView.hidden != YES) {
			if (scrollView.contentOffset.y > 0) {
				scrollView.contentInset = UIEdgeInsetsMake(0, 0, loadingVisibleHeight, 0);
			}
		}
		if (!mBottomBounceView) {
			if (scrollView.contentOffset.y > 0) {
				scrollView.contentInset = UIEdgeInsetsMake(0, 0, loadingVisibleHeight, 0);
			}
		}
	}
	if (mBottomBounceView) {
		if (mBottomBounceView.frame.origin.y != self.mScrollView.contentSize.height) {
			mBottomBounceView.frame = CGRectMake(mBottomBounceView.frame.origin.x, self.mScrollView.contentSize.height, mBottomBounceView.frame.size.width, mBottomBounceView.frame.size.height);
		}
	}
    
    //滑动回调事件
    self.nowScrollPointY=scrollView.contentOffset.y;
    float kDistanceYOffset = self.nowScrollPointY-self.lastScrollPointY;
    if (kDistanceYOffset>70){
        //向上滑动超过70
        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedUpward!=null){uexWindow.slipedUpward();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        
        jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedUpward!=null){uexWindow.onSlipedUpward();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        self.lastScrollPointY=scrollView.contentOffset.y;
    }
    else if (kDistanceYOffset<-70){
        //向下滑动超过70
        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedDownward!=null){uexWindow.slipedDownward();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        
        
        jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedDownward!=null){uexWindow.onSlipedDownward();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        
        self.lastScrollPointY=scrollView.contentOffset.y;
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // AppCanWKTODO
//    [super scrollViewDidEndDecelerating:scrollView];
    
    
    if (scrollView.contentOffset.y <= 0) {
        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedUpEdge!=null){uexWindow.slipedUpEdge();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedUpEdge!=null){uexWindow.onSlipedUpEdge();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        
    }
    
    float distence = scrollView.contentSize.height - scrollView.frame.size.height;
    if (scrollView.contentOffset.y >= distence) {
        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedDownEdge!=null){uexWindow.slipedDownEdge();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedDownEdge!=null){uexWindow.onSlipedDownEdge();}"];
        [self ac_evaluateJavaScript:jsSuccessStr];
        
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    [self.mScrollView setUserInteractionEnabled:YES];
    
    if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH) != 0) {
        if (scrollView.contentOffset.y <= refreshKeyValue && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) == 0)) {
            mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING;
            mTopBounceState = EBounceViewStatusLoading;
            [self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,2);}"];
        }
    }
    if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) != 0) {
        [self bounceViewStartLoadWithType:EBounceViewTypeTop];
        if (mTopBounceView && mTopBounceView.hidden != YES) {
            if (scrollView.contentOffset.y < 0) {
                scrollView.contentInset = UIEdgeInsetsMake(loadingVisibleHeight, 0, 0, 0);
            }
        }
        if (!mTopBounceView) {
            if (scrollView.contentOffset.y < 0) {
                scrollView.contentInset = UIEdgeInsetsMake(loadingVisibleHeight, 0, 0, 0);
            }
        }
    }

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        // AppCanWKTODO
//        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        
    }
	
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH) != 0) {
		if (scrollView.contentOffset.y <= refreshKeyValue && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) == 0)) {
			mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING;
			mTopBounceState = EBounceViewStatusLoading;
			[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,2);}"];
		}
	}
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH) != 0) {
		if (scrollView.contentOffset.y >= mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING) == 0)) {
			mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING;
			mBottomBounceState = EBounceViewStatusLoading;
			[self ac_evaluateJavaScript:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,2);}"];
		}
	}

}

-(NSURL*)curUrl{
    // AppCanWKTODO
//    return [self.request URL] ?: self.currentUrl;
    return self.currentUrl;
}

- (void)loadExeJS{
    if (_mExeJS) {
        [self ac_evaluateJavaScript:_mExeJS];
    }
}

- (void)loadUEXScript {
    [self initializeJSCHandler];
    
}

- (void)reuseWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(ACEEBrowserViewType)inWndType  BrwView:(EBrowserView *)BrwView{
    self.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    
    UIActivityIndicatorView * indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setCenter:CGPointMake([BUtility getScreenWidth]/2, [BUtility getScreenHeight]/2)];
    indicator.color = [UIColor redColor];

    self.indicatorView = indicator;
    [self addSubview:self.indicatorView];
    
    
    //JAYTAG --> xcode8编译会失败
    //设置webView自带的scrollView，使得view充满屏幕
    if(@available(iOS 11.0, *)){
        [self.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    
    self.scrollView.decelerationRate = 1.0;
    self.muexObjName = inUExObjName;
    mPageInfoDict = [[NSMutableDictionary alloc]initWithCapacity:F_PAGEINFO_DICT_SIZE];
    self.mType = inWndType;
    mFlag = 0;
    //self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    meBrwWnd = eInBrwWnd;



    mScrollView = super.scrollView;

    [self setView];
    if (inWndType == ACEEBrowserViewTypeSlibingBottom) {
        [self registerKeyboardListener:nil];
    }
    // AppCanWKTODO
//    self.keyboardDisplayRequiresUserAction = NO;

    isSwiped = NO;
    //向右轻扫事件
    UISwipeGestureRecognizer *swipeRight =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    swipeRight .direction=UISwipeGestureRecognizerDirectionRight;
    swipeRight .numberOfTouchesRequired = 1;
    swipeRight.delegate = self;
    [self addGestureRecognizer:swipeRight ];

    //向左轻扫事件
    UISwipeGestureRecognizer *swipeLeft =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.delegate = self;
    [self addGestureRecognizer:swipeLeft];

    //屏蔽长按事件
    //    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedOncell:)];
    //    [self addGestureRecognizer:longPress];
    //    longPress.allowableMovement = 15;
    //    longPress.minimumPressDuration = 2;
    ////    longPress.numberOfTapsRequired = 1;
    //    longPress.delegate=self;
    //    [longPress release];
    //for browseHistory
    
    //单击事件
    //UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //[self addGestureRecognizer:singleTap];
    //singleTap.delegate = self;
    
    self.navigationDelegate = BrwView;
    self.UIDelegate = self;

}

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(ACEEBrowserViewType)inWndType  BrwView:(EBrowserView *)BrwView{
    // AppCanWKTODO
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    // AppCanWKTODO 目前暂时不使用这个交互机制，而是使用prompt交互
    //    // 在window.webkit.messageHandlers中注入一个JS对象
    //    configuration.userContentController = [WKUserContentController new];
    //    [configuration.userContentController addScriptMessageHandler:handler name:@"AppCan"];
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = NO;
    preferences.javaScriptEnabled = YES;
    configuration.preferences = preferences;
    // 初始化WKWebView
    self = [super initWithFrame:frame configuration:configuration];
	if (self) {
        [self reuseWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:inWgt BrwWnd:eInBrwWnd UExObjName:inUExObjName Type:inWndType  BrwView:BrwView];
        self.lastScrollPointY = 0;
    }
    
	return self;
}
-(void)didSwipeRight:(id)sender
{
    if (!isSwiped && self.swipeCallbackEnabled)
    {
        UISwipeGestureRecognizer * gesture = (UISwipeGestureRecognizer*)sender;
        if (gesture.direction==UISwipeGestureRecognizerDirectionRight )
        {
            NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSwipeRight!=null){uexWindow.onSwipeRight();}"];
            [self ac_evaluateJavaScript:jsSuccessStr];
        }
        isSwiped=YES;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(noSwipe) userInfo:nil repeats:NO];
    }
}
-(void)noSwipe{
    isSwiped = NO;
}


-(void)didSwipeLeft:(id)sender
{
    if (!isSwiped && self.swipeCallbackEnabled)
    {
        UISwipeGestureRecognizer * gesture = (UISwipeGestureRecognizer*)sender;
        if (gesture.direction==UISwipeGestureRecognizerDirectionLeft)
        {
            NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSwipeLeft!=null){uexWindow.onSwipeLeft();}"];
            [self ac_evaluateJavaScript:jsSuccessStr];
        }
        isSwiped=YES;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(noSwipe) userInfo:nil repeats:NO];
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (![[[touch.view class] description] isEqualToString:@"UIWebBrowserView"]) {
        return NO;
    }

    return YES;
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;

}
/*
-(void)handleSingleTap:(UITapGestureRecognizer *)sender_{
    
	CGPoint point = [sender_ locationInView:self];
	int viewCount = (int)[self.meBrwWnd.subviews count];
	UIView *topView = [self.meBrwWnd.subviews objectAtIndex:viewCount-1];
    
    if ([topView respondsToSelector:@selector(resetInputPosition:)]) {
        [topView performSelector:@selector(resetInputPosition:) withObject:[NSValue valueWithCGPoint:point]];
    }
 
}
 */
- (void)notifyPageStart {
	mFlag &= ~F_EBRW_VIEW_FLAG_LOAD_FINISHED;
    
    [self loadExeJS];
    
	[self.meBrwCtrler.meBrw notifyLoadPageStartOfBrwView:self.superDelegate];


}

- (void)notifyPageFinish {
    
    UIScrollView * subScrollView = NULL;
	NSString * initStr = NULL;
    
	mFlag |= F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
	mFlag |= F_EBRW_VIEW_FLAG_LOAD_FINISHED;
    version =[[[UIDevice currentDevice]systemVersion]floatValue];
    
    int iOS7Style = 0;
    
    
    if (ACSystemVersion() >= 7.0) {
        
        NSNumber *statusBarStyleIOS7 = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"StatusBarStyleIOS7"];
        
        if ([statusBarStyleIOS7 boolValue] == YES) {
            
            iOS7Style = 1;
        }
    } 
    
    BOOL isStatusBarHidden = [[[NSBundle mainBundle].infoDictionary valueForKey:@"UIStatusBarHidden"] boolValue];
    //注入插件js
    [self loadUEXScript];
    //自定义注入js
    [self loadExeJS];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"showStatusBar"]) {
        
        isStatusBarHidden = [[[NSUserDefaults standardUserDefaults] objectForKey:@"showStatusBar"] boolValue];
    }
    
    initStr = [[NSString alloc] initWithFormat:@"uexWidgetOne.platformVersion = \'%@\';uexWidgetOne.isFullScreen = %d;uexWidgetOne.iOS7Style = %d;", [[UIDevice currentDevice] systemVersion],isStatusBarHidden,iOS7Style];
    [self ac_evaluateJavaScript:initStr];
    
    switch (self.mType) {
		case ACEEBrowserViewTypeMain:
            if ((self == self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView.meBrowserView) && ((self.meBrwCtrler.mFlag & F_NEED_REPORT_APP_START) != F_NEED_REPORT_APP_START)) {
                [self ac_evaluateJavaScript:@"if(window.uexStart){window.uexStart();}"];
                self.meBrwCtrler.mFlag |= F_NEED_REPORT_APP_START;
            }
			[self ac_evaluateJavaScript:@"window.uexOnload(0)"];
			if ((meBrwWnd.mFlag & F_EBRW_WND_FLAG_HAS_PREOPEN) != 0) {
				return;
			}
			break;
		case  ACEEBrowserViewTypeSlibingTop:
			subScrollView = (UIScrollView*)[self.subviews objectAtIndex:0];
			if ((self.mFlag & F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) == F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) {
				[self setFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, subScrollView.contentSize.height)];
			}
			[self ac_evaluateJavaScript:@"window.uexOnload(0)"];
			[meBrwWnd.meBrwView ac_evaluateJavaScript:@"window.uexOnload(1)"];
			break;
		case ACEEBrowserViewTypeSlibingBottom:
            subScrollView = (UIScrollView*)[self.subviews objectAtIndex:0];
			if ((self.mFlag & F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) == F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) {
				[self setFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, subScrollView.contentSize.height)];
			}
			[self ac_evaluateJavaScript:@"window.uexOnload(0)"];
			[meBrwWnd.meBrwView ac_evaluateJavaScript:@"window.uexOnload(2)"];
			break;
        case ACEEBrowserViewTypePopover:{
			id iFontSize = [self.mPageInfoDict objectForKey:@"pFontSize"];
			if (iFontSize) {
				NSNumber *fontSize = (NSNumber*)iFontSize;
				NSString *toSetFontSize = [NSString stringWithFormat:@"document.body.style.fontSize=%dpx;", [fontSize intValue]];
				[self ac_evaluateJavaScript:toSetFontSize];
			}
            if(self.isMuiltPopover){
                [self performSelector:@selector(multiPopoverDelay) withObject:nil afterDelay:0.2];
            }else{
                [self ac_evaluateJavaScript:@"window.uexOnload(0)"];
            }
            
            //2015.5.18 新增onPopoverLoadFinishInRootWnd(name,url)接口
            // AppCanWKTODO
//            initStr = [[NSString alloc] initWithFormat:@"if(uexWindow.onPopoverLoadFinishInRootWnd){uexWindow.onPopoverLoadFinishInRootWnd(\"%@\",\"%@\");}",self.muexObjName,[self.request.URL absoluteString]];
            initStr = [[NSString alloc] initWithFormat:@"if(uexWindow.onPopoverLoadFinishInRootWnd){uexWindow.onPopoverLoadFinishInRootWnd(\"%@\",\"%@\");}",self.muexObjName,[self currentUrl]];
            //[EUtility evaluatingJavaScriptInRootWnd:initStr];
            //修复回调页面错误问题，现在可以正确的回调给当前子应用的root页面
            [self.meBrwCtrler.rootView ac_evaluateJavaScript:initStr];
            if ((mFlag & F_EBRW_VIEW_FLAG_OAUTH) == F_EBRW_VIEW_FLAG_OAUTH) {
                NSString *changedUrl = [[self curUrl] absoluteString];
                NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onOAuthInfo!=null){uexWindow.onOAuthInfo(\'%@\',\'%@\');}", self.muexObjName, changedUrl];
                [self.meBrwWnd.meBrwView ac_evaluateJavaScript:toBeExeJs];
            }
			if (meBrwWnd.mPreOpenArray) {
				[meBrwWnd.mPreOpenArray removeObject:self.muexObjName];
			}
			if ((meBrwWnd.mFlag & F_EBRW_WND_FLAG_HAS_PREOPEN) != 0
				&& (meBrwWnd.mFlag & F_EBRW_WND_FLAG_FINISH_PREOPEN) != 0
				&& meBrwWnd.mPreOpenArray.count == 0) {
				[self.meBrwCtrler.meBrw notifyLoadPageFinishOfBrwView:self.meBrwWnd.meBrwView];
			}

            
        }
			break;

	}
    
	[self.meBrwCtrler.meBrw notifyLoadPageFinishOfBrwView:self.superDelegate];
}

- (void)notifyPageError {
	switch (self.mType) {
		case ACEEBrowserViewTypeMain:
			[self.meBrwCtrler.meBrw notifyLoadPageErrorOfBrwView:self.superDelegate];
			break;
		default:
			return;
			break;
	}
}



- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {

}



- (void)loadWidgetWithQuery:(NSString*)inQuery {
	NSURL *url = NULL;
	if (!self.mwWgt) {
		return;
	}
    EBrowserWindowContainer *eBrwWndContainer = self.meBrwCtrler.rootWindowContainer;
	if (!eBrwWndContainer) {
		return;
	}
	if (inQuery && inQuery.length != 0) {
		NSString *fullUrlStr = [NSString stringWithFormat:@"%@?%@",self.mwWgt.indexUrl,inQuery];
		url = [BUtility stringToUrl:fullUrlStr];

	} else {
		url = [BUtility stringToUrl:self.mwWgt.indexUrl];
	}
	if (self.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
		FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
		NSString *data = [encryptObj decryptWithPath:url appendData:nil];
		EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
		[eBrwWndContainer.meRootBrwWnd addHisEntry:eHisEntry];
		[eBrwWndContainer.meRootBrwWnd.meBrwView loadWithData:data baseUrl:url];

	} else {
		[eBrwWndContainer.meRootBrwWnd.meBrwView loadWithUrl:url];
	}

    //first view
    int goType = eBrwWndContainer.meRootBrwWnd.meBrwView.self.mwWgt.wgtType;
    NSString *goViewName =[url absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eBrwWndContainer.meRootBrwWnd.meBrwView.self.mwWgt];
    [BUtility setAppCanViewActive:goType opener:@"application://" name:goViewName openReason:0 mainWin:0 appInfo:appInfo];
}

- (EBrowserWidgetContainer*)brwWidgetContainer {
	return self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
}

- (void)clean {
	[self stopLoading];
	// Cleanup the HTML document by removing all content
	// This time, this hack free some additional memory on some websites, mainly big ones with a lot of content
	//[self ac_evaluateJavaScript:@"uex.queue.commands = [];"];
	//[self ac_evaluateJavaScript:@"var body=document.getElementsByTagName('body')[0];body.style.backgroundColor=(body.style.backgroundColor=='')?'white':'';"];
	//[self ac_evaluateJavaScript:@"document.open();document.close()"];
    // AppCanWKTODO
//	self.delegate = nil;
}

/// 注入JS方法封装
/// @param javaScriptString 需要注入执行的JS
- (void)ac_evaluateJavaScript:(NSString *)javaScriptString {
    [self evaluateJavaScript:javaScriptString completionHandler:nil];
}

/// 注入JS方法封装
/// @param javaScriptString 需要注入执行的JS
- (void)ac_evaluateJavaScript:(NSString *)javaScriptString completionHandler:(nullable void (^)(_Nullable id, NSError * _Nullable error))completionHandler {
    [self evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

- (void)loadWithData:(NSString*)inData baseUrl:(NSURL*)inBaseUrl {
    self.currentUrl = inBaseUrl;
	[self loadHTMLString:inData baseURL:inBaseUrl];
}

- (void)loadWithUrl: (NSURL*)inUrl {
    self.currentUrl = inUrl;
    NSString* urlString = [inUrl absoluteString];
    [self loadAllUrl:urlString];
}

/**
 加载本地或在线页面（处理AppCan引擎逻辑下的多种情况）

 @param urlString 需要加载的url
 */
- (void)loadAllUrl:(NSString *)urlString {
    NSURL *url = nil;
    if ([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"]) {
        // 在线资源
        url = [NSURL URLWithString:urlString];
        if (url) {
            [self loadRequest:[NSURLRequest requestWithURL:url]];
        }
    } else {
        // 本地资源
        NSString *documentsRootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
        NSString *mainBundleRootPath = [[NSBundle mainBundle] resourcePath];
        ACLogDebug(@"AppCan4.0===>urlString===>%@", urlString);
        // NSString *realUrlString = [urlString hasPrefix:@"file://"]?[urlString substringFromIndex:7]:urlString;
        // url = [NSURL fileURLWithPath:realUrlString];
        // note：这里之所以没有用fileUrlWithPath而是手动拼接file://再使用urlWithString方法，是为了防止将url中的特殊字符自动转义，从而导致?后面的参数失效甚至无法打开网页。
        NSString *realUrlString = [urlString hasPrefix:@"file://"]?urlString:[NSString stringWithFormat:@"file://%@", urlString];
        url = [NSURL URLWithString:realUrlString];
        // allowingReadAccessToURL这个参数是WKWebView为了读取本地资源的时候设置允许读取的资源范围
        NSString *allowingReadAccessToURL = nil;
        if (url) {
            if ([realUrlString containsString:mainBundleRootPath]) {
                // 这种情况下，加载的页面是在app内的mainBundle的资源
                allowingReadAccessToURL = mainBundleRootPath;
            } else if ([realUrlString containsString:documentsRootPath]) {
                // 这种情况下，加载的页面是已经拷贝到沙箱目录中了
                allowingReadAccessToURL = documentsRootPath;
            } else {
                // 其他情况，目前来看是不存在的
                allowingReadAccessToURL = realUrlString;
            }
            ACLogDebug(@"AppCan4.0===>allowingReadAccessToURL===>%@", allowingReadAccessToURL);
            [self loadFileURL:url allowingReadAccessToURL:[NSURL fileURLWithPath:allowingReadAccessToURL]];
        }else{
            ACLogError(@"AppCan4.0===>url error, loadFileURL cancelled!");
        }
    }
}

- (void)cleanAllEexObjs {

}

- (void)stopAllNetService {
	[self stopLoading];

}

-(void)continueMultiPopoverLoading{
    if(!self.isMuiltPopover){
        return;
    }
    EBrowserView *popView=(EBrowserView *)self.superview;
    if(popView && popView.superview && [popView.superview isKindOfClass:[ACEMultiPopoverScrollView class]]){
        ACEMultiPopoverScrollView *multiPopoverScrollView=(ACEMultiPopoverScrollView *)popView.superview;
        [multiPopoverScrollView continueLoading];
    }
}

#pragma mark - refresh

- (void)topBounceViewRefresh {
    
    if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH) != 0 && mTopBounceState != EBounceViewStatusLoading) {
        
        [self.mScrollView setUserInteractionEnabled:NO];
        [self.mScrollView setContentOffset:CGPointMake(0, refreshKeyValue) animated:YES];
        
    }
    
}

@end
