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

#import "EBrowser.h"
#import "EBrowserController.h"
#import "EBrowserWindow.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserView.h"
#import "JSON.h"
#import "WWidget.h"
#import "WWidgetMgr.h"

@implementation EBrowser


@synthesize meBrwCtrler;
@synthesize mFlag;

-(void)dealloc{
	[super dealloc];
}

static EBrowser * eBrwInstance = NULL;
+ (EBrowser*)instance {
	return eBrwInstance;
}

- (id)init {
	if (self = [super init]) {
		eBrwInstance = self;
	}
	return self;
}

-(void)start:(WWidget*)inWWgt {

	 //inWWgt.indexUrl = @"http://192.168.1.38:8080/xll/bug/widget11216/index.html";
	//inWWgt.indexUrl = @"http://192.168.1.38:8080/bug/AppCan_Case/Demo048/index.html";
	
    //inWWgt.indexUrl = @"http://192.168.1.38:8080/bug/normal1/index.html";

	[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:NULL];
}

- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
		case F_EBRW_VIEW_TYPE_SLIBING_TOP:
		case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
		case F_EBRW_VIEW_TYPE_POPOVER:
		case F_EBRW_VIEW_TYPE_AD:
			[meBrwCtrler.meBrwMainFrm notifyLoadPageStartOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
		case F_EBRW_VIEW_TYPE_SLIBING_TOP:
		case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
		case F_EBRW_VIEW_TYPE_POPOVER:
		case F_EBRW_VIEW_TYPE_AD:
			[meBrwCtrler.meBrwMainFrm notifyLoadPageFinishOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case F_EBRW_VIEW_TYPE_MAIN:
			[meBrwCtrler.meBrwMainFrm notifyLoadPageErrorOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}

- (void)removeAllNotActiveViews {
	if (!meBrwCtrler) {
		return;
	}
	if (!meBrwCtrler.meBrwMainFrm) {
		return;
	}
	if (!meBrwCtrler.meBrwMainFrm.meBrwWgtContainer) {
		return;
	}
	if (!meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict) {
		return;
	}
	if (meBrwCtrler.meBrwMainFrm.meAdBrwView) {
		[meBrwCtrler.meBrwMainFrm.meBrwWgtContainer pushReuseBrwView:meBrwCtrler.meBrwMainFrm.meAdBrwView];
        meBrwCtrler.meBrwMainFrm.meAdBrwView = nil;
	}
    if (meBrwCtrler.meBrwMainFrm.meBrwWgtContainer) {
        [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer removeAllUnActiveBrwWndContainer];
    }
}

- (void)stopAllNetService {
	if (!meBrwCtrler) {
		return;
	}
	if (!meBrwCtrler.meBrwMainFrm) {
		return;
	}
	if (!meBrwCtrler.meBrwMainFrm.meBrwWgtContainer) {
		return;
	}
	if (!meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict) {
		return;
	}
	if (meBrwCtrler.meBrwMainFrm.meAdBrwView) {
		[meBrwCtrler.meBrwMainFrm.meAdBrwView stopAllNetService];
	}
	if (meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict) {
		NSArray *brwWndContainerArray = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict allValues];
		for (EBrowserWindowContainer *brwWndContainer in brwWndContainerArray) {
			if (brwWndContainer.mBrwWndDict) {
				NSArray *brwWndArray = [brwWndContainer.mBrwWndDict allValues];
				for (EBrowserWindow* brwWnd in brwWndArray) {
					if (brwWnd.meBrwView) {
						[brwWnd.meBrwView stopAllNetService];
					}
					if (brwWnd.meTopSlibingBrwView) {
						[brwWnd.meTopSlibingBrwView stopAllNetService];
					}
					if (brwWnd.meBottomSlibingBrwView) {
						[brwWnd.meBottomSlibingBrwView stopAllNetService];
					}
					if (brwWnd.mPopoverBrwViewDict) {
						NSArray *brwPopView = [brwWnd.mPopoverBrwViewDict allValues];
						for (EBrowserView *brwView in brwPopView) {
							[brwView stopAllNetService];
						}
					}
				}
			}
		}
	}
}
@end

