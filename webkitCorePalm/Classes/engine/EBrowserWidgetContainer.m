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

#import "EBrowserWidgetContainer.h"

#import "EBrowserController.h"
#import "EBrowserToolBar.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserMainFrame.h"
#import	"EBrowserWindow.h"
#import "EBrowserView.h"
#import "BUtility.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "EBrowser.h"
#import "ACEUINavigationController.h"
#import "ACESubwidgetManager.h"
#import <AppCanKit/ACEXTScope.h>



@implementation EBrowserWidgetContainer

@synthesize meBrwCtrler;
@synthesize meRootBrwWndContainer;


@synthesize mWWigets;

- (id)initWithFrame:(CGRect)frame browserController:(EBrowserController *)eInBrwCtrler widget:(WWidget *)widget {
    self = [super initWithFrame:frame];
    if (self) {
		//self.backgroundColor = [UIColor blackColor];

        NSMutableDictionary *tempmWWigets = [[NSMutableDictionary alloc]initWithCapacity:1];
        self.mWWigets = tempmWWigets;

        
		meBrwCtrler = eInBrwCtrler;
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		meRootBrwWndContainer = [[EBrowserWindowContainer alloc] initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:widget];
		[self addSubview:meRootBrwWndContainer];
	}
    return self;
}

- (void)dealloc {
    meRootBrwWndContainer = nil;
    self.mWWigets = nil;
}





- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
    EBrowserWindowContainer *eSuperBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eInBrwView];
	[eSuperBrwWndContainer notifyLoadPageStartOfBrwView:eInBrwView];
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {
    
    
    
    ACLogVerbose(@"window '%@' opened;",eInBrwView.meBrwWnd.meBrwView.muexObjName);
    
    
    

    
    if (eInBrwView.meBrwCtrler.aceNaviController.presentingViewController.presentedViewController == eInBrwView.meBrwCtrler.aceNaviController || eInBrwView.meBrwCtrler.isAppCanRootViewController) {
        EBrowserWindowContainer *eSuperBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eInBrwView];
        [eSuperBrwWndContainer notifyLoadPageFinishOfBrwView:eInBrwView];
    }else{
        [[ACESubwidgetManager defaultManager]notifySubwidgetControllerLoadingCompleted:eInBrwView.meBrwCtrler];
    }
    
    

}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
//	EBrowserWindowContainer *eSuperBrwWndContainer = (EBrowserWindowContainer*)eSuperBrwWnd.superview;
    
    EBrowserWindowContainer *eSuperBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eInBrwView];
    

    
	if (eSuperBrwWndContainer) {
		[eSuperBrwWndContainer notifyLoadPageErrorOfBrwView:eInBrwView];
	} else {
		if ((eSuperBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
			eSuperBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
			eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
		}
	}

}

- (EBrowserWindowContainer*)aboveWindowContainer {
	return (EBrowserWindowContainer*)[self.subviews objectAtIndex:self.subviews.count-1];
}


@end
