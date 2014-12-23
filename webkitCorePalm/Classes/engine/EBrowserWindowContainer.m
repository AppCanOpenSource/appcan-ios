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

#import "EBrowserController.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowserMainFrame.h"
#import "EBrowser.h"
#import "BUtility.h"
#import "BAnimition.h"
//#import "AliPayInfo.h"
#import "AppCenter.h"
#import "WWidget.h"
#import "ACEWebViewController.h"

@implementation EBrowserWindowContainer

@synthesize meBrwCtrler;
@synthesize meRootBrwWnd;
@synthesize mBrwWndDict;
@synthesize mwWgt;
@synthesize meOpenerContainer;
@synthesize mOpenerForRet;
@synthesize mOpenerInfo;
@synthesize mAliPayInfo;
@synthesize mPushNotifyBrwViewName;
@synthesize mPushNotifyCallback;
@synthesize mStartAnimiId;
@synthesize mStartAnimiDuration;
@synthesize mFlag;

- (void)dealloc {
    
	if (mwWgt) {
		[mwWgt release];
		mwWgt = nil;
	}
	if (mOpenerInfo) {
		[mOpenerInfo release];
		mOpenerInfo = NULL;
	}
	if (mOpenerForRet) {
		[mOpenerForRet release];
		mOpenerForRet = NULL;
	}
	if (mAliPayInfo) {
		[mAliPayInfo release];
		mAliPayInfo = NULL;
	}
	if (mPushNotifyBrwViewName) {
		[mPushNotifyBrwViewName release];
		mPushNotifyBrwViewName = NULL;
	}
	if (mPushNotifyCallback) {
		[mPushNotifyCallback release];
		mPushNotifyCallback = NULL;
	}

	if (meRootBrwWnd) {
		if (meRootBrwWnd.superview) {
			[meRootBrwWnd removeFromSuperview];
		}
		[meRootBrwWnd release];
		meRootBrwWnd = NULL;
	}

	if (mBrwWndDict) {
		NSArray *brwWndArray = [mBrwWndDict allValues];
		for (EBrowserWindow *brwWnd in brwWndArray) {
			if (brwWnd.superview) {
				[brwWnd removeFromSuperview];
			}
//			[brwWnd release];
		}
		[mBrwWndDict removeAllObjects];
		[mBrwWndDict release];
		mBrwWndDict = NULL;
	}
    [super dealloc];
}

- (void)removeAllUnActiveBrwWnd {
    if (mBrwWndDict) {
		NSArray *brwWndArray = [mBrwWndDict allValues];
		for (EBrowserWindow *brwWnd in brwWndArray) {
            if (brwWnd == [self aboveWindow]) {
                continue;
            }
            if (brwWnd == meRootBrwWnd) {
                [brwWnd cleanAllBrwViews];
                continue;
            }
			if (brwWnd.superview) {
				[brwWnd removeFromSuperview];
			}
            [mBrwWndDict removeObjectForKey:brwWnd.meBrwView.muexObjName];
			[brwWnd release];
		}
	}
}

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt {
    self = [super initWithFrame:frame];
    if (self) {
		//self.backgroundColor = [UIColor blackColor];
		mBrwWndDict = [[NSMutableDictionary alloc]initWithCapacity:F_BRW_WND_CONTAINER_BRW_WND_DICT_SIZE];
		mStartAnimiId = 0;
		mStartAnimiDuration = 0.2f;
		meBrwCtrler = eInBrwCtrler;
		self.mwWgt = inWgt;
		meOpenerContainer = nil;
		mOpenerForRet = nil;
		mOpenerInfo = nil;
		mFlag = 0;
		meRootBrwWnd = [[EBrowserWindow alloc] initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:mwWgt UExObjName:F_BRW_WND_ROOT_NAME];
		[mBrwWndDict setObject:meRootBrwWnd forKey:F_BRW_WND_ROOT_NAME];
		[self addSubview:meRootBrwWnd];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }

    return self;
}

- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
	//EBrowserWindow *superBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
	//[superBrwWnd notifyLoadPageStartOfBrwView:eInBrwView];
}

- (void)addViewToACEWebViewController:(EBrowserWindow *)view
{
    
    ACENSLog(@"NavWindowTest addViewToACEWebViewController view= %@", view);
    
    ACEWebViewController *webController = [[ACEWebViewController alloc] init];
    
    
//    testController.view = view;
    webController.browserWindow = view;
    view.webController = webController;
    [meBrwCtrler.navigationController pushViewController:webController animated:YES];
    
    
    [webController release];
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {

	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
    
    if (eSuperBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        
        if (eSuperBrwWnd.isSliding) {
            return;
        }
        
        [self addViewToACEWebViewController:eSuperBrwWnd];
        
        ///prev window
//        if (eCurBrwWnd) {
//            [eCurBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
//        }
        [eSuperBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        
        
        if ((eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
            eSuperBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
            eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        }
        
        
        return;
    }
    
    
    
    
    
	UIView *foundView = [self.subviews objectAtIndex:self.subviews.count-1];
	if (![foundView isKindOfClass:[EBrowserWindow class]]) {
		foundView = [self.subviews objectAtIndex:self.subviews.count-2];
	}
	EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)foundView;
    
	if (eSuperBrwWnd != eCurBrwWnd) {
		if (eSuperBrwWnd.superview != self) {
			[eSuperBrwWnd setBounds:self.bounds];
			[self addSubview:eSuperBrwWnd];

		} else {
			[self bringSubviewToFront:eSuperBrwWnd];
		}
        if ([BAnimition isMoveIn:eSuperBrwWnd.mOpenAnimiId]) {
            [BAnimition doMoveInAnimition:eSuperBrwWnd animiId:eSuperBrwWnd.mOpenAnimiId animiTime:eSuperBrwWnd.mOpenAnimiDuration];
        } else {
            [BAnimition SwapAnimationWithView:self AnimiId:eSuperBrwWnd.mOpenAnimiId AnimiTime:eSuperBrwWnd.mOpenAnimiDuration];
        }
		if (eCurBrwWnd) {
			[eCurBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
		}
		[eSuperBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
		if ((eSuperBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
			NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eSuperBrwWnd.meBrwView.mAdType, eSuperBrwWnd.meBrwView.mAdDisplayTime, eSuperBrwWnd.meBrwView.mAdIntervalTime, eSuperBrwWnd.meBrwView.mAdFlag];
			[eSuperBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
		}

		if ((eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
			eSuperBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
			eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
		}


	}
	[eSuperBrwWnd notifyLoadPageFinishOfBrwView:eInBrwView];
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
	if ((eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
		eSuperBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
		eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
	}
	if (!self.superview) {
		if (self.meBrwCtrler.meBrwMainFrm.mAppCenter) {
			if (self.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
				[self.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_FAIL retAppId:eInBrwView.mwWgt.appId];
			}
		}
		[self release];
	}
	[eSuperBrwWnd notifyLoadPageErrorOfBrwView:eInBrwView];
}

- (EBrowserWindow*)brwWndForKey:(id)inKey {
	id obj = [mBrwWndDict objectForKey:inKey];
	if (obj != nil) {
		return (EBrowserWindow*)obj;
	}
	return nil;
}

- (void)removeFromWndDict:(id)inKey {
	if (inKey != nil) {
		[mBrwWndDict removeObjectForKey:inKey];
	}
}

- (BOOL)ifActiveOrNot:(UIView*)inUIView {
	if (![inUIView isKindOfClass:[EBrowserWindow class]]) {
		return NO;
	}
	if (inUIView.hidden == YES) {
		return NO;
	}
	return YES;
}

- (EBrowserWindow*)aboveWindow {
	int subViewCount = self.subviews.count;
	int i = subViewCount-1;
	while (i >= 0) {
		UIView *aboveView = [self.subviews objectAtIndex:i];
		if ([self ifActiveOrNot:aboveView]) {
			return (EBrowserWindow*)aboveView;
		}
		i--;
	}
	return NULL;
}

- (void)pushNotify {
	if (!mPushNotifyBrwViewName || !mPushNotifyCallback) {
		return;
	}
	EBrowserWindow *eBrwWnd = [self brwWndForKey:mPushNotifyBrwViewName];
	if (!eBrwWnd) {
		return;
	}
	NSString *pushNotifyStr = [NSString stringWithFormat:@"%@();",mPushNotifyCallback];
	[eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:pushNotifyStr];
}

- (void)clean {
	NSArray *wndArray = [NSArray arrayWithArray:self.subviews];
	EBrowserWindow *temWnd = nil;
	int count = wndArray.count;
	for (int i=0; i<count; i++) {
		temWnd = (EBrowserWindow*)[wndArray objectAtIndex:i];
		if (temWnd != meRootBrwWnd) {
			[temWnd removeFromSuperview];
		}
	}
}


+ (EBrowserWindowContainer *)getBrowserWindowContaier:(EBrowserView *)browserView
{
    EBrowserWindowContainer *eBrwWndContainer = nil;
    EBrowserWindow *eBrwWnd = browserView.meBrwWnd;
    
    if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        
        
        if (eBrwWnd.superview != nil && [eBrwWnd.superview isKindOfClass:[EBrowserWindowContainer class]]) {
            eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
            
            eBrwWnd.winContainer = eBrwWndContainer;
            
        } else {
            
            eBrwWndContainer = eBrwWnd.winContainer;
        }
        
        
    } else {
        eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    }
    
    return eBrwWndContainer;
}
@end
