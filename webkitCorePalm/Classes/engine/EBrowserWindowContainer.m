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

#import "EBrowserController.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowserMainFrame.h"
#import "EBrowser.h"
#import "BUtility.h"
#import "WWidget.h"
#import "ACEWebViewController.h"
#import "WidgetOneDelegate.h"
#import "ACEUINavigationController.h"
#import "ACEDrawerViewController.h"
#import "UIViewController+RESideMenu.h"
#import "RESideMenu.h"
#import "ACEPOPAnimation.h"
#import "EUtility.h"
#import "ACEAnimation.h"


@implementation EBrowserWindowContainer

@synthesize meBrwCtrler;
@synthesize meRootBrwWnd;
@synthesize mBrwWndDict;

@synthesize meOpenerContainer;
@synthesize mOpenerForRet;

@synthesize mStartAnimiId;
@synthesize mStartAnimiDuration;
@synthesize mFlag;

- (void)dealloc {

	if (mOpenerForRet) {
		mOpenerForRet = NULL;
	}
	if (meRootBrwWnd) {
		if (meRootBrwWnd.superview) {
			[meRootBrwWnd removeFromSuperview];
		}
		meRootBrwWnd = NULL;
	}
	if (mBrwWndDict) {
		NSArray *brwWndArray = [mBrwWndDict allValues];
		for (EBrowserWindow *brwWnd in brwWndArray) {
			if (brwWnd.superview) {
				[brwWnd removeFromSuperview];
			}
		}
		[mBrwWndDict removeAllObjects];
		mBrwWndDict = NULL;
	}
}

- (WWidget *)mwWgt{
    return self.meBrwCtrler.widget;
}

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt {
    self = [super initWithFrame:frame];
    if (self) {
		//self.backgroundColor = [UIColor blackColor];
		mBrwWndDict = [[NSMutableDictionary alloc]initWithCapacity:F_BRW_WND_CONTAINER_BRW_WND_DICT_SIZE];
		mStartAnimiId = 0;
		mStartAnimiDuration = 0.2f;
		meBrwCtrler = eInBrwCtrler;

		meOpenerContainer = nil;
		mOpenerForRet = nil;

		mFlag = 0;
		meRootBrwWnd = [[EBrowserWindow alloc] initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:meBrwCtrler.widget UExObjName:F_BRW_WND_ROOT_NAME];
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

- (void)addViewToACEWebViewController:(EBrowserWindow *)view{
    
    ACEWebViewController *webController = [[ACEWebViewController alloc] init];
    
//    testController.view = view;
    webController.browserWindow = view;
    view.webController = webController;
    if (view.webWindowType == ACEWebWindowTypeNavigation) {
        [meBrwCtrler.aceNaviController pushViewController:webController animated:YES];
         [EBrowserWindow postWindowSequenceChange];
    } else if (view.webWindowType == ACEWebWindowTypePresent) {
        [meBrwCtrler.aceNaviController presentViewController:webController animated:YES completion:^{
             [EBrowserWindow postWindowSequenceChange];
        }];
    }
    
    
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {

	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
    if (eSuperBrwWnd.webWindowType == ACEWebWindowTypeNavigation || eSuperBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        if (eSuperBrwWnd.isSliding || eSuperBrwWnd.webController) {
            return;
        }
        [self addViewToACEWebViewController:eSuperBrwWnd];
        [eSuperBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        if (eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) {
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
        
        [ACEAnimations addOpeningAnimationWithID:eSuperBrwWnd.openAnimationID
                                        fromView:self
                                          toView:eSuperBrwWnd
                                        duration:eSuperBrwWnd.openAnimationDuration
                                   configuration:eSuperBrwWnd.openAnimationConfig
                               completionHandler:nil];

        [eCurBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
		[eSuperBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];

		if (eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) {
			eSuperBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
			eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
		}
	}
    [EBrowserWindow postWindowSequenceChange];
	[eSuperBrwWnd notifyLoadPageFinishOfBrwView:eInBrwView];
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
	if ((eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
		eSuperBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
		eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
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



- (EBrowserWindow*)aboveWindow {
    EBrowserWindow *aBrowserWin = nil;

    ACEUINavigationController *navController = self.meBrwCtrler.aceNaviController;

    
    
    if ([navController.viewControllers count] > 1) {
        ACEWebViewController *webController = (ACEWebViewController *)navController.topViewController;
        if (webController != nil && [webController isKindOfClass:[ACEWebViewController class]]) {
            aBrowserWin = webController.browserWindow;
        }
    } else {
        NSUInteger subViewCount = self.subviews.count;
        NSInteger i = subViewCount-1;
        while (i >= 0) {
            UIView *aboveView = [self.subviews objectAtIndex:i];
            if ([aboveView isKindOfClass:[EBrowserWindow class]] && !aboveView.hidden) {
                return (EBrowserWindow*)aboveView;
            }
            i--;
        }
    }
    return aBrowserWin;
}




- (void)clean {
	NSArray *wndArray = [NSArray arrayWithArray:self.subviews];
	EBrowserWindow *temWnd = nil;
	NSUInteger count = wndArray.count;
	for (int i=0; i<count; i++) {
		temWnd = (EBrowserWindow*)[wndArray objectAtIndex:i];
		if (temWnd != meRootBrwWnd) {
			[temWnd removeFromSuperview];
		}
	}
}


+ (EBrowserWindowContainer *)getBrowserWindowContaier:(EBrowserView *)browserView{
    return browserView.meBrwWnd.winContainer;
}
@end
