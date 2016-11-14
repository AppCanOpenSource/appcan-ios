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



-(void)start:(WWidget*)inWWgt {
	[self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:NULL];
}

- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
    [self.meBrwCtrler.meBrwMainFrm notifyLoadPageStartOfBrwView:eInBrwView];
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {
    [self.meBrwCtrler.meBrwMainFrm notifyLoadPageFinishOfBrwView:eInBrwView];
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case ACEEBrowserViewTypeMain:
			[self.meBrwCtrler.meBrwMainFrm notifyLoadPageErrorOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}


- (void)stopAllNetService {
    [self.meBrwCtrler.meBrwMainFrm.meAdBrwView stopAllNetService];
    NSArray *brwWndContainerArray = [self.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict allValues];
    for (EBrowserWindowContainer *brwWndContainer in brwWndContainerArray) {
        NSArray *brwWndArray = [brwWndContainer.mBrwWndDict allValues];
        for (EBrowserWindow* brwWnd in brwWndArray) {
            [brwWnd.meBrwView stopAllNetService];
            [brwWnd.meTopSlibingBrwView stopAllNetService];
            [brwWnd.meBottomSlibingBrwView stopAllNetService];
            for (EBrowserView *brwView in [brwWnd.mPopoverBrwViewDict allValues]) {
                [brwView stopAllNetService];
            }
        }
    }
}


@end

