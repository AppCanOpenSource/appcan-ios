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
#import "ACEConfigXML.h"


@interface EBrowserMainFrame()

@end


@implementation EBrowserMainFrame



- (instancetype)initWithFrame: (CGRect)frame BrwCtrler: (EBrowserController*)eInBrwCtrler {
    if (self = [super initWithFrame:frame]) {
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_meBrwCtrler = eInBrwCtrler;
		_meBrwWgtContainer = [[EBrowserWidgetContainer alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) BrwCtrler:eInBrwCtrler];
		[self addSubview:self.meBrwWgtContainer];

        if ([BUtility getAppCanDevMode] || [self.meBrwCtrler.mwWgtMgr.wMainWgt getMySpaceStatus]) {
            self.meBrwToolBar =[[EBrowserToolBar alloc] initWithFrame:CGRectMake(BOTTOM_LOCATION_VERTICAL_X,BOTTOM_LOCATION_VERTICAL_Y, BOTTOM_VIEW_WIDTH,BOTTOM_VIEW_HEIGHT) BrwCtrler:eInBrwCtrler];
            [self addSubview:self.meBrwToolBar];
        }
        
		_mNotifyArray = [NSMutableArray array];
	}

	return self;
}

- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.meBrwWgtContainer removeFromSuperview];
    self.meBrwWgtContainer = nil;

    [self.meBrwToolBar removeFromSuperview];
    self.meBrwToolBar = nil;
    self.mAppCenter = nil;
    self.mSBWnd = nil;
	
    [self.mSBWndTimer invalidate];
    self.mSBWndTimer = nil;
}



- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {

    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	switch (eInBrwView.mType) {
		case ACEEBrowserViewTypeMain:
            [self notifyLoadingImageShouldClose];
			if (eInBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) {
				eInBrwView.meBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
				eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
				ACENSLog(@"reset wnd opening flag");
				[self.meBrwWgtContainer notifyLoadPageFinishOfBrwView:eInBrwView];
			} else if ((eInBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) == F_EBRW_FLAG_WIDGET_IN_OPENING) {
				[self.meBrwWgtContainer notifyLoadPageFinishOfBrwView:eInBrwView];
			} else if (eInBrwView.meBrwWnd.mOAuthWndName) {
				[self.meBrwWgtContainer notifyLoadPageFinishOfBrwView:eInBrwView];
			}
			break;
		default:
			break;
	}
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	switch (eInBrwView.mType) {
		case ACEEBrowserViewTypeMain:
            [self notifyLoadingImageShouldClose];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			[self.meBrwWgtContainer notifyLoadPageErrorOfBrwView:eInBrwView];
			break;
		default:
			break;
	}
}

- (void)notifyLoadingImageShouldClose{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL userCloseLoading = NO;
        ONOXMLElement *config = [ACEConfigXML ACEOriginConfigXML];
        ONOXMLElement *loadingConfig = [config firstChildWithTag:@"removeloading"];
        if (loadingConfig && [loadingConfig.stringValue isEqual:@"true"]) {
            userCloseLoading = YES;
        }
        if (!userCloseLoading) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self.meBrwCtrler handleLoadingImageCloseEvent:ACELoadingImageCloseEventWebViewFinishLoading];
            });
        }
    });
}


- (void)setVerticalFrame{
	if (self.meBrwToolBar) {
		if(isPad){
			[self.meBrwToolBar setFrame:CGRectMake(768-66,BOTTOM_IPAD_LOCATION_VERTICAL_Y, 66,BOTTOM_IPAD_VIEW_HEIGHT)];
		}else{
			[self.meBrwToolBar setFrame:CGRectMake(320-33,BOTTOM_LOCATION_VERTICAL_Y, 33,BOTTOM_VIEW_HEIGHT)];
		}
	}
}

- (void)setHorizontalFrame{
	if (self.meBrwToolBar) {
		if(isPad){
			[self.meBrwToolBar setFrame:CGRectMake(1024-66,BOTTOM_IPAD_LOCATION_HORIZONTAL_Y,66,BOTTOM_IPAD_VIEW_HEIGHT)];
		}else{
			[self.meBrwToolBar setFrame:CGRectMake(480-33,BOTTOM_LOCATION_HORIZONTAL_Y,33,BOTTOM_VIEW_HEIGHT)];
		}
	}
}

@end
