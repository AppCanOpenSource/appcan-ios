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
#import "EUExManager.h"
#import "BUtility.h"
#import "CBrowserWindow.h"
#import "CBrowserMainFrame.h"
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
//#import "AppCanAnalysis.h"
#import "EBrowserHistory.h"
#import "EBrowserHistoryEntry.h"
#import <objc/runtime.h>
#import <objc/message.h>
const CGFloat refreshKeyValue = -65.0f;
const CGFloat loadingVisibleHeight = 60.0f;

@implementation ACEBrowserView{
    float version;

}

@synthesize indicatorView ;
@synthesize meBrwCtrler;
@synthesize meUExManager;
@synthesize mcBrwWnd;
@synthesize meBrwWnd;
@synthesize mwWgt;
@synthesize muexObjName;
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
@synthesize currentUrl;
@synthesize isMuiltPopover;
@synthesize lastScrollPointY;
@synthesize nowScrollPointY;

-(void)multiPopoverDelay{

    [self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
}
- (void)didShowKeyboard:(NSNotification *)notification
{
	NSString *strKeyboardStatus = [self stringByEvaluatingJavaScriptFromString:@"uexWindow.didShowKeyboard"];
	int keyboardStatus = [strKeyboardStatus intValue];
	if (keyboardStatus == 1) {
		NSDictionary* info = [notification userInfo];
		CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		UIInterfaceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
		UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
		if ([BUtility isValidateOrientation:deviceOrientation] == NO) {
			deviceOrientation = (UIDeviceOrientation)statusBarOrientation;
		}
		if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
			[self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y - kbSize.height, self.frame.size.width, self.frame.size.height)];
		} else if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
			[self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y - kbSize.width, self.frame.size.width, self.frame.size.height)];
		}
		mFlag |= (F_EBRW_VIEW_FLAG_SHOW_KEYBOARD | F_EBRW_VIEW_FLAG_FORBID_ROTATE);
	}
}

- (void)didHideKeyboard:(NSNotification *)notification
{
	if ((mFlag & F_EBRW_VIEW_FLAG_SHOW_KEYBOARD) == F_EBRW_VIEW_FLAG_SHOW_KEYBOARD) {
		NSDictionary* info = [notification userInfo];
		CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
		[self stringByEvaluatingJavaScriptFromString:@"uexWindow.didShowKeyboard=0"];
		UIInterfaceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
		UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
		if ([BUtility isValidateOrientation:deviceOrientation] == NO) {
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
    if (self.indicatorView) {
        self.indicatorView =nil;
    }
	ACENSLog(@"ACEBrowserView retain count is %d",[self retainCount]);
	ACENSLog(@"ACEBrowserView dealloc is %x", self);
	ACENSLog(@"meUExManager retain count is %d",[meUExManager retainCount]);
	[self unRegisterKeyboardListener:nil];
	if (meUExManager) {
		[meUExManager clean];
		[meUExManager release];
		meUExManager = NULL;
	}
	if (mcBrwWnd) {
		[mcBrwWnd release];
		mcBrwWnd = nil;
	}
	if (muexObjName) {
		[muexObjName release];
		muexObjName = nil;
	}
	if (mPageInfoDict) {
		[mPageInfoDict removeAllObjects];
		[mPageInfoDict release];
		mPageInfoDict = nil;
	}
	if (mTopBounceView) {
		if (mTopBounceView.superview) {
			[mTopBounceView removeFromSuperview];
		}
		[mTopBounceView release];
		mTopBounceView = nil;
	}
	if (mBottomBounceView) {
		if (mBottomBounceView.superview) {
			[mBottomBounceView removeFromSuperview];
		}
		[mBottomBounceView release];
		mBottomBounceView = nil;
	}
    self.currentUrl = nil;
	[super dealloc];
}







- (void)reset {
	ACENSLog(@"ACEBrowserView retain count is %d",[self retainCount]);
	ACENSLog(@"ACEBrowserView dealloc is %x", self);
	ACENSLog(@"meUExManager retain count is %d",[meUExManager retainCount]);
	[self clean];
	[self unRegisterKeyboardListener:nil];
	meBrwCtrler = NULL;
	meBrwWnd = NULL;
	mwWgt = NULL;
	mType = 0;
	mFlag = 0;
	mTopBounceState = 0;
	mBottomBounceState = 0;
	mAdType = 0;
	mAdDisplayTime = 0;
	mAdIntervalTime = 0;
	mAdFlag = 0;
	if (meUExManager) {
		[meUExManager clean];
		[meUExManager release];
		meUExManager = NULL;
	}
	if (mcBrwWnd) {
		[mcBrwWnd release];
		mcBrwWnd = nil;
	}
	if (muexObjName) {
		[muexObjName release];
		muexObjName = nil;
	}
	if (mPageInfoDict) {
		[mPageInfoDict removeAllObjects];
		[mPageInfoDict release];
		mPageInfoDict = nil;
	}
	if (mTopBounceView) {
		if (mTopBounceView.superview) {
			[mTopBounceView removeFromSuperview];
		}
		[mTopBounceView release];
		mTopBounceView = nil;
	}
	if (mBottomBounceView) {
		if (mBottomBounceView.superview) {
			[mBottomBounceView removeFromSuperview];
		}
		[mBottomBounceView release];
		mBottomBounceView = nil;
	}
}

- (void)setView {
    self.currentUrl = nil;
	self.dataDetectorTypes = UIDataDetectorTypeNone;
	self.allowsInlineMediaPlayback = NO;
	[self setDelegate:mcBrwWnd];
	[self setScalesPageToFit:NO];
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
                if (mBottomBounceView.frame.origin.y != self.mScrollView.contentSize.height)
                {
                    mBottomBounceView.frame = CGRectMake(mBottomBounceView.frame.origin.x,self.mScrollView.contentSize.height, mBottomBounceView.frame.size.width, mBottomBounceView.frame.size.height);
                 }
              
            }

        }
			break;
		default:
			break;
	}
}
#pragma mark-
#pragma mark scrollview delegate
#pragma mark-
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [super scrollViewDidScroll:scrollView];
        
    }
	
	ACENSLog(@"scrollViewDidScroll");
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH) != 0) {
		if (scrollView.dragging && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) == 0)) {
			if (mTopBounceView && mTopBounceView.hidden != YES) {
				if (scrollView.contentOffset.y > refreshKeyValue && scrollView.contentOffset.y < 0.0f) {
					[mTopBounceView setStatus:EBounceViewStatusPullToReload];
					if (mTopBounceState != EBounceViewStatusPullToReload) {
						mTopBounceState = EBounceViewStatusPullToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,0);}"];
					}
				} else if (scrollView.contentOffset.y < refreshKeyValue) {
					[mTopBounceView setStatus:EBounceViewStatusReleaseToReload];
					if (mTopBounceState != EBounceViewStatusReleaseToReload) {
						mTopBounceState = EBounceViewStatusReleaseToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,1);}"];
					}
				}
			} else {
				if (scrollView.contentOffset.y > refreshKeyValue && scrollView.contentOffset.y < 0.0f) {
					if (mTopBounceState != EBounceViewStatusPullToReload) {
						mTopBounceState = EBounceViewStatusPullToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,0);}"];
					}
				} else if (scrollView.contentOffset.y < refreshKeyValue) {
					if (mTopBounceState != EBounceViewStatusReleaseToReload) {
						mTopBounceState = EBounceViewStatusReleaseToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,1);}"];
					}
				}
			}
			
		}
	}
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH) != 0) {
		if (scrollView.dragging && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING) == 0)) {
			//ACENSLog(@"contentOffset is %f and scrollSize is %f and bounce is %f", scrollView.contentOffset.y, mScrollView.contentSize.height, mScrollView.contentSize.height-refreshKeyValue);
			if (mBottomBounceView && mBottomBounceView.hidden != YES) {
				if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y < mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					[mBottomBounceView setStatus:EBounceViewStatusPullToReload];
					if (mBottomBounceState != EBounceViewStatusPullToReload) {
						mBottomBounceState = EBounceViewStatusPullToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,0);}"];
					}
				} else if (scrollView.contentOffset.y > mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					[mBottomBounceView setStatus:EBounceViewStatusReleaseToReload];
					if (mBottomBounceState != EBounceViewStatusReleaseToReload) {
						mBottomBounceState = EBounceViewStatusReleaseToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,1);}"];
					}
				}
			} else {
				if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y < mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					if (mBottomBounceState != EBounceViewStatusPullToReload) {
						mBottomBounceState = EBounceViewStatusPullToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,0);}"];
					}
				} else if (scrollView.contentOffset.y > mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height) {
					if (mBottomBounceState != EBounceViewStatusReleaseToReload) {
						mBottomBounceState = EBounceViewStatusReleaseToReload;
						[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,1);}"];
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
    {
        self.nowScrollPointY=scrollView.contentOffset.y;
        float kDistanceYOffset = self.nowScrollPointY-self.lastScrollPointY;
        if (kDistanceYOffset>70)
        {
            //向上滑动超过70
            NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedUpward!=null){uexWindow.slipedUpward();}"];
            [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
            
            jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedUpward!=null){uexWindow.onSlipedUpward();}"];
            [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
            self.lastScrollPointY=scrollView.contentOffset.y;
        }
        else if (kDistanceYOffset<-70)
        {
            //向下滑动超过70
            NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedDownward!=null){uexWindow.slipedDownward();}"];
            [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
            
            
            jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedDownward!=null){uexWindow.onSlipedDownward();}"];
            [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
            
            self.lastScrollPointY=scrollView.contentOffset.y;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        
    }
	
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH) != 0) {
		if (scrollView.contentOffset.y <= refreshKeyValue && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING) == 0)) {
			mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_LOADING;
			mTopBounceState = EBounceViewStatusLoading;
			[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(0,2);}"];
		}
	}
	if ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH) != 0) {
		if (scrollView.contentOffset.y >= mScrollView.contentSize.height-refreshKeyValue-self.bounds.size.height && ((mFlag & F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING) == 0)) {
			mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_LOADING;
			mBottomBounceState = EBounceViewStatusLoading;
			[self stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onBounceStateChange!=null){uexWindow.onBounceStateChange(1,2);}"];
		}
	}
    //滑动回调事件
    if (scrollView.contentOffset.y<=0)
    {
        //
        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedUpEdge!=null){uexWindow.slipedUpEdge();}"];
        [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
        
        jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedUpEdge!=null){uexWindow.onSlipedUpEdge();}"];
        [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
    }
    float distence = scrollView.contentSize.height - scrollView.frame.size.height;
    if (scrollView.contentOffset.y>=distence)
    {
        //
        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.slipedDownEdge!=null){uexWindow.slipedDownEdge();}"];
        [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
        
        jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSlipedDownEdge!=null){uexWindow.onSlipedDownEdge();}"];
        [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
        
        
    }
}

-(NSURL*)curUrl{
    NSLog(@"%@==%@",self.currentUrl,[self.request URL]);
    if (self.currentUrl)
    {
        if ([self.request URL]) {
            return [self.request URL];
        } else {
            return self.currentUrl;
        }
        
    }
    else
    {
        return nil;
    }
}

- (void)loadUEXScript {
	extern NSString *AppCanJS;
	//extern NSString *AppCanPluginJS;
	//NSLog(@"engine=%@-------\n",AppCanJS);
	[self stringByEvaluatingJavaScriptFromString:AppCanJS];
    
}

- (void)reuseWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(int)inWndType  BrwView:(EBrowserView *)BrwView{
    self.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
    
    UIActivityIndicatorView * indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    [indicator setCenter:CGPointMake([BUtility getScreenWidth]/2, [BUtility getScreenHeight]/2)];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=5.0)
    {
        indicator.color = [UIColor redColor];
    }
    self.indicatorView=indicator;
    [self addSubview:self.indicatorView];
    
    self.scrollView.decelerationRate = 1.0;
    meBrwCtrler = eInBrwCtrler;
    mwWgt = inWgt;
    self.muexObjName = inUExObjName;
    mPageInfoDict = [[NSMutableDictionary alloc]initWithCapacity:F_PAGEINFO_DICT_SIZE];
    mType = inWndType;
    mFlag = 0;
    //self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    mcBrwWnd = [[CBrowserWindow alloc]init];
    meBrwWnd = eInBrwWnd;
    meUExManager = [[EUExManager alloc]initWithBrwView:BrwView BrwCtrler:meBrwCtrler];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        mScrollView = super.scrollView;
    }else {
        mScrollView = [self.subviews objectAtIndex:0];
    }
    //mScrollView = [self.subviews objectAtIndex:0];
    [self setView];
    if (inWndType == F_EBRW_VIEW_TYPE_SLIBING_BOTTOM) {
        [self registerKeyboardListener:nil];
    }
    //屏蔽长按事件;
    /*for (UIView* sv in [super subviews]){
     NSLog(@"first layer: %@", sv);
     for (UIView* s2 in [sv subviews])
     {
     NSLog(@"second layer: %@ *** %@", s2, [s2 class]);
     for (UIGestureRecognizer *recognizer in s2.gestureRecognizers) {
     if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]){
     recognizer.enabled = NO;
     }
     }
     }
     }*/
    isSwiped = NO;
    //向右轻扫事件
    UISwipeGestureRecognizer *swipeRight =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    swipeRight .direction=UISwipeGestureRecognizerDirectionRight;
    swipeRight .numberOfTouchesRequired = 1;
    swipeRight.delegate = self;
    [self addGestureRecognizer:swipeRight ];
    [swipeRight release];
    //向左轻扫事件
    UISwipeGestureRecognizer *swipeLeft =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
    swipeLeft.numberOfTouchesRequired = 1;
    swipeLeft.delegate = self;
    [self addGestureRecognizer:swipeLeft];
    [swipeLeft release];
    //屏蔽长按事件
    //    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedOncell:)];
    //    [self addGestureRecognizer:longPress];
    //    longPress.allowableMovement = 15;
    //    longPress.minimumPressDuration = 2;
    ////    longPress.numberOfTapsRequired = 1;
    //    longPress.delegate=self;
    //    [longPress release];
    //for browseHistory
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    [singleTap release];
}

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt BrwWnd:(EBrowserWindow*)eInBrwWnd UExObjName:(NSString*)inUExObjName Type:(int)inWndType  BrwView:(EBrowserView *)BrwView{
	self = [super initWithFrame:frame];
	if (self) {
        [self reuseWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:inWgt BrwWnd:eInBrwWnd UExObjName:inUExObjName Type:inWndType  BrwView:(EBrowserView *)BrwView];
    }
    self.lastScrollPointY=0;
	return self;
}
-(void)didSwipeRight:(id)sender
{
    if (!isSwiped)
    {
        UISwipeGestureRecognizer * gesture = (UISwipeGestureRecognizer*)sender;
        if (gesture.direction==UISwipeGestureRecognizerDirectionRight )
        {
            NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSwipeRight!=null){uexWindow.onSwipeRight();}"];
            ACENSLog(@"jsSuccessStr=%@",jsSuccessStr);
            [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
        }
        isSwiped=YES;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(noSwipe) userInfo:nil repeats:NO];
    }
}
-(void)noSwipe
{
    isSwiped = NO;
}
-(void)longPressedOncell:(id)sender
{
    //    if ([(UILongPressGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan)
    //    {
    //        NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.longPress!=null){uexWindow.longPress(0,1,\'长按手势\');}"];
    //        ACENSLog(@"jsSuccessStr=%@",jsSuccessStr);
    //        [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
    //    }
}
-(void)didSwipeLeft:(id)sender
{
    if (!isSwiped)
    {
        UISwipeGestureRecognizer * gesture = (UISwipeGestureRecognizer*)sender;
        if (gesture.direction==UISwipeGestureRecognizerDirectionLeft)
        {
            NSString *jsSuccessStr = [NSString stringWithFormat:@"if(uexWindow.onSwipeLeft!=null){uexWindow.onSwipeLeft();}"];
            ACENSLog(@"jsSuccessStr=%@",jsSuccessStr);
            [self stringByEvaluatingJavaScriptFromString:jsSuccessStr];
        }
        isSwiped=YES;
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(noSwipe) userInfo:nil repeats:NO];
    }
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender_{
	CGPoint point = [sender_ locationInView:self];
	int viewCount = (int)[self.meBrwWnd.subviews count];
	UIView *topView = [self.meBrwWnd.subviews objectAtIndex:viewCount-1];
    if ([topView respondsToSelector:@selector(resetInputPosition:)]) {
        [topView performSelector:@selector(resetInputPosition:) withObject:[NSValue valueWithCGPoint:point]];
    }
}
- (void)notifyPageStart {
	mFlag &= ~F_EBRW_VIEW_FLAG_LOAD_FINISHED;
	[meUExManager notifyDocChange];
	switch (mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
		case F_EBRW_VIEW_TYPE_SLIBING_TOP:
		case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
		case F_EBRW_VIEW_TYPE_POPOVER:
		case F_EBRW_VIEW_TYPE_AD:
			break;
		default:
			return;
			break;
	}
	[meBrwCtrler.meBrw notifyLoadPageStartOfBrwView:self.superDelegate];
}

- (void)notifyPageFinish {
    
    UIScrollView * subScrollView = NULL;
	NSString * initStr = NULL;
    
    ACENSLog(@"Broad in notifyPageFinish");
	mFlag |= F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
	mFlag |= F_EBRW_VIEW_FLAG_LOAD_FINISHED;
    version =[[[UIDevice currentDevice]systemVersion]floatValue];
    
    int iOS7Style = 0;
    
    
    if (isSysVersionAbove7_0) {
        
        NSNumber *statusBarStyleIOS7 = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"StatusBarStyleIOS7"];
        
        if ([statusBarStyleIOS7 boolValue] == YES) {
            
            iOS7Style = 1;
        }
    } 
    
    BOOL isStatusBarHidden = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIStatusBarHidden"] boolValue];
    
    switch (mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
			ACENSLog(@"Main notifyPageFinish onload url is %@", [self.request URL]);
			[self loadUEXScript];
            
			initStr = [[NSString alloc] initWithFormat:@"uexGameEngine.screenWidth = %f;uexGameEngine.screenHeight = %f;uexWidgetOne.platformVersion = \'%@\';uexWidgetOne.isFullScreen = %d;uexWidgetOne.iOS7Style = %d;", self.frame.size.width, self.frame.size.height,[[UIDevice currentDevice] systemVersion],isStatusBarHidden,iOS7Style];
            [self stringByEvaluatingJavaScriptFromString:initStr];
            [initStr release];
            
            
            if ((self == self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView.meBrowserView) && ((self.meBrwCtrler.mFlag & F_NEED_REPORT_APP_START) != F_NEED_REPORT_APP_START)) {
                [self stringByEvaluatingJavaScriptFromString:@"window.uexStart();"];
                meBrwCtrler.mFlag |= F_NEED_REPORT_APP_START;
            }
			[self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
			if ((meBrwWnd.mFlag & F_EBRW_WND_FLAG_HAS_PREOPEN) != 0) {
				return;
			}
			break;
		case  F_EBRW_VIEW_TYPE_SLIBING_TOP:
			[self loadUEXScript];
			initStr = [[NSString alloc] initWithFormat:@"uexWidgetOne.platformVersion = \'%@\';uexWidgetOne.isFullScreen = %d;uexWidgetOne.iOS7Style = %d;", [[UIDevice currentDevice] systemVersion],isStatusBarHidden,iOS7Style];
			[self stringByEvaluatingJavaScriptFromString:initStr];
			[initStr release];
            
			subScrollView = (UIScrollView*)[self.subviews objectAtIndex:0];
			if ((self.mFlag & F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) == F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) {
				[self setFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, subScrollView.contentSize.height)];
			}
			[self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
			[meBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnload(1)"];
			break;
		case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
			[self loadUEXScript];
			initStr = [[NSString alloc] initWithFormat:@"uexWidgetOne.platformVersion = \'%@\';uexWidgetOne.isFullScreen = %d;uexWidgetOne.iOS7Style = %d;", [[UIDevice currentDevice] systemVersion],isStatusBarHidden,iOS7Style];
			[self stringByEvaluatingJavaScriptFromString:initStr];
			[initStr release];
            			subScrollView = (UIScrollView*)[self.subviews objectAtIndex:0];
			if ((self.mFlag & F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) == F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE) {
				[self setFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, subScrollView.contentSize.height)];
			}
			[self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
			[meBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnload(2)"];
			break;
		case F_EBRW_VIEW_TYPE_POPOVER:
			[self loadUEXScript];
			initStr = [[NSString alloc] initWithFormat:@"uexWidgetOne.platformVersion = \'%@\';uexWidgetOne.isFullScreen = %d;uexWidgetOne.iOS7Style = %d;", [[UIDevice currentDevice] systemVersion],isStatusBarHidden,iOS7Style];
			[self stringByEvaluatingJavaScriptFromString:initStr];
			[initStr release];
            
			if (self.superview != meBrwWnd) {
                if (!self.isMuiltPopover)
                {
                    [meBrwWnd addSubview:self.superDelegate];
                }
			}
			id iFontSize = [self.mPageInfoDict objectForKey:@"pFontSize"];
			if (iFontSize) {
				NSNumber *fontSize = (NSNumber*)iFontSize;
				NSString *toSetFontSize = [NSString stringWithFormat:@"document.body.style.fontSize=%dpx;", [fontSize intValue]];
				[self stringByEvaluatingJavaScriptFromString:toSetFontSize];
			}
            if(self.isMuiltPopover){
                [self performSelector:@selector(multiPopoverDelay) withObject:nil afterDelay:0.2];
            }else{
    
                
                [self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
            }
            
            //2015.5.18 新增onPopoverLoadFinishInRootWnd(name,url)接口
            initStr = [[NSString alloc] initWithFormat:@"window.onPopoverLoadFinishInRootWnd(%@, %@);",self.muexObjName,[self.currentUrl absoluteString]];
            [EUtility evaluatingJavaScriptInRootWnd:initStr];
            [initStr release];
            
            
			//[self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
            if ((mFlag & F_EBRW_VIEW_FLAG_OAUTH) == F_EBRW_VIEW_FLAG_OAUTH) {
                NSString *changedUrl = [[self curUrl] absoluteString];
                NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onOAuthInfo!=null){uexWindow.onOAuthInfo(\'%@\',\'%@\');}", self.muexObjName, changedUrl];
                [self.meBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
            }
			if (meBrwWnd.mPreOpenArray) {
				[meBrwWnd.mPreOpenArray removeObject:self.muexObjName];
			}
			if ((meBrwWnd.mFlag & F_EBRW_WND_FLAG_HAS_PREOPEN) != 0
				&& (meBrwWnd.mFlag & F_EBRW_WND_FLAG_FINISH_PREOPEN) != 0
				&& meBrwWnd.mPreOpenArray.count == 0) {
				[self.meBrwCtrler.meBrw notifyLoadPageFinishOfBrwView:self.meBrwWnd.meBrwView];
			}

            
            
			break;
		case F_EBRW_VIEW_TYPE_AD:
			[self loadUEXScript];
			initStr = [[NSString alloc] initWithFormat:@"uexWidgetOne.platformVersion = \'%@\';uexWidgetOne.isFullScreen = %d;uexWidgetOne.iOS7Style = %d;", [[UIDevice currentDevice] systemVersion],isStatusBarHidden,iOS7Style];
			[self stringByEvaluatingJavaScriptFromString:initStr];
			[initStr release];
            
			if (self.superview != meBrwCtrler.meBrwMainFrm) {
				[meBrwCtrler.meBrwMainFrm addSubview:self.superDelegate];
			}
			if ((self.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
				self.hidden = NO;
			}
			[self stringByEvaluatingJavaScriptFromString:@"window.uexOnload(0)"];
			break;
		default:
			return;
			break;
	}
    
    
	[meBrwCtrler.meBrw notifyLoadPageFinishOfBrwView:self.superDelegate];
}

- (void)notifyPageError {
	switch (mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
			[meBrwCtrler.meBrw notifyLoadPageErrorOfBrwView:self.superDelegate];
			break;
		default:
			return;
			break;
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	//ACENSLog(@"end content offset is %f,%f", scrollView.contentOffset.x, scrollView.contentOffset.y);
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
	return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	//ACENSLog(@"scroll to top");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	//ACENSLog(@"will begin dragging");
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	//ACENSLog(@"will begin decelerating");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	//ACENSLog(@"end decelerating");
}

- (void)loadWidgetWithQuery:(NSString*)inQuery {
	NSURL *url = NULL;
	if (!mwWgt) {
		return;
	}
	EBrowserWindowContainer *eBrwWndContainer = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict objectForKey:mwWgt.appId];
	if (!eBrwWndContainer) {
		return;
	}
	if (inQuery && inQuery.length != 0) {
		NSString *fullUrlStr = [[NSString stringWithFormat:@"%@?%@",mwWgt.indexUrl,inQuery] retain];
		url = [BUtility stringToUrl:fullUrlStr];
		[fullUrlStr release];
	} else {
		url = [BUtility stringToUrl:mwWgt.indexUrl];
	}
	if (mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
		FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
		NSString *data = [encryptObj decryptWithPath:url appendData:nil];
		EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
		[eBrwWndContainer.meRootBrwWnd addHisEntry:eHisEntry];
		[eBrwWndContainer.meRootBrwWnd.meBrwView loadWithData:data baseUrl:url];
		[encryptObj release];
	} else {
		[eBrwWndContainer.meRootBrwWnd.meBrwView loadWithUrl:url];
	}
	eBrwWndContainer.mFlag |= F_BRW_WND_CONTAINER_LOAD_WGT_DONE;
    //first view
    int goType = eBrwWndContainer.meRootBrwWnd.meBrwView.mwWgt.wgtType;
    NSString *goViewName =[url absoluteString];
    [BUtility setAppCanViewActive:goType opener:@"application://" name:goViewName openReason:0 mainWin:0];
}

- (EBrowserWidgetContainer*)brwWidgetContainer {
	return self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
}

- (void)clean {
	[self stopLoading];
	// Cleanup the HTML document by removing all content
	// This time, this hack free some additional memory on some websites, mainly big ones with a lot of content
	[self stringByEvaluatingJavaScriptFromString:@"uex.queue.commands = [];"];
	[self stringByEvaluatingJavaScriptFromString:@"var body=document.getElementsByTagName('body')[0];body.style.backgroundColor=(body.style.backgroundColor=='')?'white':'';"];
	[self stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];
	//[meUExManager clean];
	self.delegate = nil;
}

- (void)loadWithData:(NSString*)inData baseUrl:(NSURL*)inBaseUrl {
    self.currentUrl = inBaseUrl;
	NSString *trueData = [inData stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	ACENSLog(@"ACEBrowserView.loadWithData: escaped file data is %@", trueData);
	[self loadHTMLString:inData baseURL:inBaseUrl];
}

- (void)loadWithUrl: (NSURL*)inUrl {
    self.currentUrl = inUrl;
	ACENSLog(@"ACEBrowserView LoadWithUrl: in Url is %@", [inUrl absoluteString]);
	NSURLRequest *request = [NSURLRequest requestWithURL:inUrl];
	[self loadRequest:request];
}

- (void)cleanAllEexObjs {
    if (meUExManager) {
        [meUExManager clean];
    }
}

- (void)stopAllNetService {
	[self stopLoading];
	if (meUExManager) {
		[meUExManager stopAllNetService];
	}
}
@end
