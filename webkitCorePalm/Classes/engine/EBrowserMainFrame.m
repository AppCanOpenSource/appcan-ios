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

#import "EBrowserMainFrame.h"
#import "EBrowserToolBar.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserView.h"
#import "EBrowserWindow.h"
#import "EBrowser.h"
#import "EBrowserController.h"
#import "BUtility.h"
#import "WWidget.h"
#import "WWidgetMgr.h"
#import "WidgetOneDelegate.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ONOXMLElement+ACEConfigXML.h"

@implementation EBrowserMainFrame
@synthesize meBrwCtrler;
@synthesize meBrwWgtContainer;
@synthesize meBrwToolBar;
@synthesize mAppCenter;

@synthesize meAdBrwView;
@synthesize mAdDisplayTimer;
@synthesize mAdIntervalTimer;
@synthesize mAdDisplayTime;
@synthesize mAdIntervalTime;
@synthesize mAdType;
@synthesize mSBWnd;
@synthesize mSBWndTimer;
@synthesize mNotifyArray;

-(void)updateAdStatus:(NSNotification*)inNsNotfication{
	ACENSLog(@"adStatus");
	NSDictionary *dict = [inNsNotfication userInfo];
	NSString *openAdStatus = [dict objectForKey:@"openAdStatus"];
	if (openAdStatus) {
		ACENSLog(@"openAdStatusd=%@",openAdStatus);
		meBrwCtrler.mwWgtMgr.wMainWgt.openAdStatus =[openAdStatus intValue];
	}
	
}
- (id)initWithFrame: (CGRect)frame BrwCtrler: (EBrowserController*)eInBrwCtrler {
    if (self = [super initWithFrame:frame]) {
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		meBrwCtrler = eInBrwCtrler;
		meBrwWgtContainer = [[EBrowserWidgetContainer alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) BrwCtrler:eInBrwCtrler];
		[self addSubview:meBrwWgtContainer];
		if (![BUtility getAppCanDevMode]) {
			if ([meBrwCtrler.mwWgtMgr.wMainWgt getMySpaceStatus]) {
				meBrwToolBar =[[EBrowserToolBar alloc] initWithFrame:CGRectMake(BOTTOM_LOCATION_VERTICAL_X,BOTTOM_LOCATION_VERTICAL_Y, BOTTOM_VIEW_WIDTH,BOTTOM_VIEW_HEIGHT) BrwCtrler:eInBrwCtrler];
				[self addSubview:meBrwToolBar];
			} else {
				meBrwToolBar = nil;
			}
		} else {
			meBrwToolBar =[[EBrowserToolBar alloc] initWithFrame:CGRectMake(BOTTOM_LOCATION_VERTICAL_X,BOTTOM_LOCATION_VERTICAL_Y, BOTTOM_VIEW_WIDTH,BOTTOM_VIEW_HEIGHT) BrwCtrler:eInBrwCtrler];
			[self addSubview:meBrwToolBar];
		}

		mNotifyArray = [[NSMutableArray alloc] initWithCapacity:1];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAdStatus:) name:@"adStatusUpdate" object:nil];
	}
	ACENSLog(@"EBrowserMainFrame alloc is %x", self);
	return self;
}

- (void)dealloc {
	ACENSLog(@"EBrowserMainFrame retain count is %d",[self retainCount]);
	ACENSLog(@"EBrowserMainFrame dealloc is %x", self);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"adStatusUpdate" object:NULL];
	if (meBrwWgtContainer) {
		if (meBrwWgtContainer.superview) {
			[meBrwWgtContainer removeFromSuperview];
		}
		[meBrwWgtContainer release];
		meBrwWgtContainer = nil;
	}
	if (meBrwToolBar) {
		if (meBrwToolBar.superview) {
			[meBrwToolBar removeFromSuperview];
		}
		[meBrwToolBar release];
		meBrwToolBar = nil;
	}
	if (meAdBrwView) {
		if (meAdBrwView.superview) {
			[meAdBrwView removeFromSuperview];
		}
		[meAdBrwView release];
		meAdBrwView = nil;
	}
	if (mAppCenter) {
		[mAppCenter release];
		mAppCenter = nil;
	}
	if (mSBWnd) {
		[mSBWnd release];
		mSBWnd = nil;
	}
	if (mSBWndTimer) {
		[mSBWndTimer release];
		mSBWndTimer = nil;
	}
	if (mNotifyArray) {
		[mNotifyArray release];
		mNotifyArray = nil;
	}
	[super dealloc];
}

- (void)invalidateAdTimers {
	if (mAdDisplayTimer && [mAdDisplayTimer isValid]) {
		[mAdDisplayTimer invalidate];
		mAdDisplayTimer = NULL;
		mAdDisplayTime = 0;
	}
	if (mAdIntervalTimer && [mAdIntervalTimer isValid]) {
		[mAdIntervalTimer invalidate];
		mAdIntervalTimer = NULL;
		mAdIntervalTimer = 0;
	}
}

- (void)intervalDone {
	mAdIntervalTimer = NULL;
	//if (meAdBrwView) {
	if (meAdBrwView && (meBrwCtrler.mwWgtMgr.wMainWgt.openAdStatus == 1)) {
		meAdBrwView.hidden = NO;
		mAdDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:mAdDisplayTime target:self selector:@selector(displayDone) userInfo:nil repeats:NO];
	}
}

- (void)displayDone {
	mAdDisplayTimer = NULL;
	if (meAdBrwView) {
		meAdBrwView.hidden = YES;
		mAdIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:mAdIntervalTime target:self selector:@selector(intervalDone) userInfo:nil repeats:NO];
	}
}

- (void)layoutSubviews {
	ACENSLog(@"EBrowserMainFrame layoutSubviews!");
	ACENSLog(@"wnd rect is:%f,%f,%f,%f", self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
	if (meAdBrwView) {
		CGRect ADFrame;
		switch (mAdType) {
			case F_EBRW_MAINFRM_AD_TYPE_TOP:
				if ([BUtility isIpad]) {
					ADFrame = CGRectMake(0, 0, self.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PAD);
				} else {
					ADFrame = CGRectMake(0, 0, self.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PHONE);
				}
				break;
			case F_EBRW_MAINFRM_AD_TYPE_MIDDLE:
				if ([BUtility isIpad]) {
					ADFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) ;
				} else {
					ADFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
				}
				break;
			case F_EBRW_MAINFRM_AD_TYPE_BOTTOM:
				if ([BUtility isIpad]) {
					ADFrame = CGRectMake(0, (self.bounds.size.height-F_EBRW_MAINFRM_AD_HEIGHT_PAD), self.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PAD) ;
				} else {
					ADFrame = CGRectMake(0, (self.bounds.size.height-F_EBRW_MAINFRM_AD_HEIGHT_PHONE), self.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PHONE);
				}
				break;
			default:
				break;
		}
		[meAdBrwView setFrame:ADFrame];
	}
}

- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case F_EBRW_VIEW_TYPE_SLIBING_TOP:
		case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
		case F_EBRW_VIEW_TYPE_POPOVER:
		case F_EBRW_VIEW_TYPE_AD:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			break;
		case F_EBRW_VIEW_TYPE_MAIN:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			//[meBrwWgtContainer notifyLoadPageStartOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {
	ACENSLog(@"EBrowserMainFrame notifyLoadPageFinishOfBrwView");
	switch (eInBrwView.mType) {
		case F_EBRW_VIEW_TYPE_SLIBING_TOP:
		case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
		case F_EBRW_VIEW_TYPE_POPOVER:
		case F_EBRW_VIEW_TYPE_AD:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			break;
		case F_EBRW_VIEW_TYPE_MAIN:
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            /*
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                
                if (meBrwCtrler.mStartView) {
                    self.hidden = NO;
                    [meBrwCtrler.mStartView removeFromSuperview];
                    meBrwCtrler.mStartView = nil;
                    
                }
                
            });
            */
            
            [self notifyLoadingImageShouldClose];
			
			if ((eInBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
				eInBrwView.meBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
				eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
				ACENSLog(@"reset wnd opening flag");
				[meBrwWgtContainer notifyLoadPageFinishOfBrwView:eInBrwView];
			} else if ((eInBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) == F_EBRW_FLAG_WIDGET_IN_OPENING) {
				[meBrwWgtContainer notifyLoadPageFinishOfBrwView:eInBrwView];
			} else if (eInBrwView.meBrwWnd.mOAuthWndName) {
				[meBrwWgtContainer notifyLoadPageFinishOfBrwView:eInBrwView];
			}
			break;
		default:
			break;
	}
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
            [self notifyLoadingImageShouldClose];
//			if (meBrwCtrler.mStartView && meBrwCtrler.mSplashFired) {
//                /*[[UIApplication sharedApplication] setStatusBarHidden:theApp.useIsHiddenStatusBarControl];
//                if (!theApp.useIsHiddenStatusBarControl) {
//                     meBrwCtrler.view.frame =  CGRectMake(0, 20, [BUtility getScreenWidth], [BUtility getScreenHeight]);
//                }
//                
//                sleep(1);*/
//                
//                [meBrwCtrler.mStartView removeFromSuperview];
//				meBrwCtrler.mStartView = nil;
//                self.hidden = NO;
//			}

			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[meBrwWgtContainer notifyLoadPageErrorOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}

- (void)notifyLoadingImageShouldClose{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL userCloseLoading = NO;
        ONOXMLElement *config = [ONOXMLElement ACEOriginConfigXML];
        ONOXMLElement *loadingConfig = [config firstChildWithTag:@"removeloading"];
        if (loadingConfig && [loadingConfig.stringValue isEqual:@"true"]) {
            userCloseLoading = YES;
        }
        if (!userCloseLoading) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [meBrwCtrler handleLoadingImageCloseEvent:ACELoadingImageCloseEventWebViewFinishLoading];
            });
        }
    });
}


- (void)setVerticalFrame{
	if (meBrwToolBar) {
		if(isPad){
			[meBrwToolBar setFrame:CGRectMake(768-66,BOTTOM_IPAD_LOCATION_VERTICAL_Y, 66,BOTTOM_IPAD_VIEW_HEIGHT)];
		}else{
			[meBrwToolBar setFrame:CGRectMake(320-33,BOTTOM_LOCATION_VERTICAL_Y, 33,BOTTOM_VIEW_HEIGHT)];
		}
	}
}

- (void)setHorizontalFrame{
	if (meBrwToolBar) {
		if(isPad){
			[meBrwToolBar setFrame:CGRectMake(1024-66,BOTTOM_IPAD_LOCATION_HORIZONTAL_Y,66,BOTTOM_IPAD_VIEW_HEIGHT)];
		}else{
			[meBrwToolBar setFrame:CGRectMake(480-33,BOTTOM_LOCATION_HORIZONTAL_Y,33,BOTTOM_VIEW_HEIGHT)];
		}
	}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex==0) {
        [BUtility exitWithClearData];
    }else{
    }
}
@end
