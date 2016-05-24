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
#import "BAnimation.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "EBrowser.h"

#define F_BRW_WGT_CONTAINER_DICT_SIZE			5
#define F_BRW_WGT_CONTAINER_REUSE_VIEW_SIZE		10

@implementation EBrowserWidgetContainer

@synthesize meBrwCtrler;
@synthesize meRootBrwWndContainer;
@synthesize mBrwWndContainerDict;
@synthesize mReUseBrwViewArray;
@synthesize mWWigets;

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler {
    self = [super initWithFrame:frame];
    if (self) {
		//self.backgroundColor = [UIColor blackColor];
		mBrwWndContainerDict = [[NSMutableDictionary alloc]initWithCapacity:F_BRW_WGT_CONTAINER_DICT_SIZE];
        NSMutableDictionary *tempmWWigets = [[NSMutableDictionary alloc]initWithCapacity:1];
        self.mWWigets = tempmWWigets;

        
		meBrwCtrler = eInBrwCtrler;
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		meRootBrwWndContainer = [[EBrowserWindowContainer alloc] initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:meBrwCtrler.mwWgtMgr.wMainWgt];
		[mBrwWndContainerDict setObject:meRootBrwWndContainer forKey:meBrwCtrler.mwWgtMgr.wMainWgt.appId];
		mReUseBrwViewArray = [[NSMutableArray alloc] initWithCapacity:F_BRW_WGT_CONTAINER_REUSE_VIEW_SIZE];
		[self addSubview:meRootBrwWndContainer];
	}
	ACENSLog(@"EBrowserWidgetContainer alloc is %x", self);
    return self;
}

- (void)dealloc {

	ACENSLog(@"EBrowserWidgetContainer dealloc is %x", self);
	if (meRootBrwWndContainer) {

		meRootBrwWndContainer = nil;
	}
    if (mWWigets) {
        self.mWWigets=nil;
    }
	if (mBrwWndContainerDict) {
		NSArray *brwWndContainerArray = [mBrwWndContainerDict allValues];
		for (EBrowserWindowContainer *wndContainer in brwWndContainerArray){
			if (wndContainer.superview) {
				[wndContainer removeFromSuperview];
			}

		}
		[mBrwWndContainerDict removeAllObjects];

		mBrwWndContainerDict = nil;
	}
	if (mReUseBrwViewArray) {
		for (EBrowserView* eBrwView in mReUseBrwViewArray) {
			if (eBrwView.superview) {
				[eBrwView removeFromSuperview];
			}

		}
		[mReUseBrwViewArray removeAllObjects];

		mReUseBrwViewArray = NULL;
	}

}

- (void)removeAllUnActiveBrwWndContainer {
    if (mBrwWndContainerDict) {
        NSArray *brwWndContainerArray = [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict allValues];
        for (EBrowserWindowContainer *brwWndContainer in brwWndContainerArray) {
            if (brwWndContainer == meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer) {
                [brwWndContainer removeAllUnActiveBrwWnd];
                continue;
            }
            if (brwWndContainer == [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer]) {
                [brwWndContainer removeAllUnActiveBrwWnd];
                continue;
            }
            if (brwWndContainer.superview) {
                [brwWndContainer removeFromSuperview];
                [meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.mBrwWndContainerDict removeObjectForKey:brwWndContainer.mwWgt.appId];

            }
        }
    }
}

- (EBrowserView*)popReuseBrwView {
    [mReUseBrwViewArray removeAllObjects];
    return nil;
    /*
	if (mReUseBrwViewArray.count == 0) {
		return nil;
	}
	EBrowserView *eBrwView = [[mReUseBrwViewArray objectAtIndex:0] retain];
	[mReUseBrwViewArray removeObject:eBrwView];
	return eBrwView;
     */
}

- (void)pushReuseBrwView:(EBrowserView*)inBrwView {
    
//    if (inBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
//        
//        return;
//    }
//
    /*
	[inBrwView reset];
	if (mReUseBrwViewArray.count >= F_BRW_WGT_CONTAINER_REUSE_VIEW_SIZE) {
		return;
	}
     [mReUseBrwViewArray addObject:inBrwView];
     */
	
    
}

- (void)layoutSubviews {
	ACENSLog(@"EBrowserWidgetContainer layoutSubviews!");
	ACENSLog(@"wnd rect is:%f,%f,%f,%f", self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
}

- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
//	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
//    EBrowserWindowContainer *eSuperBrwWndContainer = (EBrowserWindowContainer*)eSuperBrwWnd.superview;
    
    EBrowserWindowContainer *eSuperBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eInBrwView];
    

    
    
	
	[eSuperBrwWndContainer notifyLoadPageStartOfBrwView:eInBrwView];
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {
	EBrowserWindow *eSuperBrwWnd = (EBrowserWindow*)(eInBrwView.meBrwWnd);
    
    EBrowserWindowContainer *eSuperBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:eInBrwView];

    
    if (eSuperBrwWnd.webWindowType == ACEWebWindowTypeNavigation || eSuperBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        
        [eSuperBrwWndContainer notifyLoadPageFinishOfBrwView:eInBrwView];
        
        return;
        
    }
    
    
//	EBrowserWindowContainer *eSuperBrwWndContainer = (EBrowserWindowContainer*)eSuperBrwWnd.superview;
	EBrowserWindowContainer *eCurBrwWndContainer = [self.subviews objectAtIndex:self.subviews.count-1];
    
    if (!eSuperBrwWndContainer) {
        for (EBrowserWindowContainer * brwWndContainer in self.subviews) {
            if ([[brwWndContainer.mBrwWndDict allValues] containsObject:eSuperBrwWnd]) {
                eSuperBrwWndContainer = brwWndContainer;
                break;
            }
        }
    }
    
    
	if (!eSuperBrwWndContainer) {
		eSuperBrwWndContainer = eCurBrwWndContainer;
	}
    
	if (eSuperBrwWndContainer != eCurBrwWndContainer) {
		if (eSuperBrwWndContainer.superview != self) {
			[eSuperBrwWndContainer setBounds:self.bounds];
			[self addSubview:eSuperBrwWndContainer];
			if (eSuperBrwWndContainer.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
				if (meBrwCtrler.meBrwMainFrm.meBrwToolBar) {
					if (![BUtility getAppCanDevMode]) {
						if (meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden == NO) {
							meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = YES;
						}
					}
				}
			}
		} else {
			[self bringSubviewToFront:eSuperBrwWndContainer];
            
            if (!eSuperBrwWnd.superview) {
                [eSuperBrwWndContainer addSubview:eSuperBrwWnd];
            }
            
			if (eSuperBrwWndContainer.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
				if (meBrwCtrler.meBrwMainFrm.meBrwToolBar) {
					if (![BUtility getAppCanDevMode]) {
						if (meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden == NO) {
							meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = YES;
						}
					}
				}
			}
		}
		if ([BAnimation isMoveIn:eSuperBrwWndContainer.mStartAnimiId]) {
            [BAnimation doMoveInAnimition:eSuperBrwWndContainer animiId:eSuperBrwWndContainer.mStartAnimiId animiTime:eSuperBrwWndContainer.mStartAnimiDuration];
        } else {
            [BAnimation SwapAnimationWithView:self AnimiId:eSuperBrwWndContainer.mStartAnimiId AnimiTime:eSuperBrwWndContainer.mStartAnimiDuration];
        }
		
		if (eCurBrwWndContainer) {
			[[eCurBrwWndContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
		}
		[eInBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
		if (eSuperBrwWndContainer != self.meRootBrwWndContainer) {
			self.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag |= F_TOOLBAR_FLAG_FINISH_WIDGET;
			self.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = NO;
		}
		if (self.meBrwCtrler.meBrwMainFrm.mAppCenter) {
			if (self.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
				[self.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_SUCCESS retAppId:eSuperBrwWndContainer.mwWgt.appId];
			}
		}
		eInBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WIDGET_IN_OPENING;
	} else {
		[eSuperBrwWndContainer notifyLoadPageFinishOfBrwView:eInBrwView];
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
