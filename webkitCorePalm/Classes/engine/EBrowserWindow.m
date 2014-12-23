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

#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "BUtility.h"
#import "EBrowserController.h"
#import "WWidget.h"
#import "EBrowserHistory.h"
//#import "FileEncrypt.h"
#import <ACEDes/FileEncrypt.h>
#import "EBrowserHistoryEntry.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EUExWindow.h"


@implementation EBrowserWindow

@synthesize meBrwCtrler;
@synthesize meTopSlibingBrwView;
@synthesize meBrwView;
@synthesize meBottomSlibingBrwView;
@synthesize mPreOpenArray;
@synthesize mPopoverBrwViewDict;
@synthesize meFrontWnd;
@synthesize meBackWnd;
@synthesize meBrwHistory;
@synthesize mOAuthWndName;
@synthesize mwWgt;
@synthesize mOpenAnimiId;
@synthesize mOpenAnimiDuration;
@synthesize mFlag;
@synthesize mMuiltPopoverDict;

- (void)dealloc {
	ACENSLog(@"EBrowserWindow retain count is %d",[self retainCount]);
	ACENSLog(@"EBrowserWindow dealloc is %x", self);
	if (meTopSlibingBrwView) {
		ACENSLog(@"meTopSlibingBrwView retain count is %d",[meTopSlibingBrwView retainCount]);
		if (meTopSlibingBrwView.superview) {
			[meTopSlibingBrwView removeFromSuperview];
		}
		[[meBrwCtrler brwWidgetContainer] pushReuseBrwView:meTopSlibingBrwView];
		[meTopSlibingBrwView release];
		meTopSlibingBrwView = nil;
	}
	if (meBrwView) {
		ACENSLog(@"meBrwView retain count is %d",[meBrwView retainCount]);
		if (meBrwView.superview) {
			[meBrwView removeFromSuperview];
		}
		[[meBrwCtrler brwWidgetContainer] pushReuseBrwView:meBrwView];
		[meBrwView release];
		meBrwView = nil;
	}
	if (meBottomSlibingBrwView) {
		ACENSLog(@"meBottomSlibingBrwView retain count is %d",[meBottomSlibingBrwView retainCount]);
		if (meBottomSlibingBrwView.superview) {
			[meBottomSlibingBrwView removeFromSuperview];
		}
		[[meBrwCtrler brwWidgetContainer] pushReuseBrwView:meBottomSlibingBrwView];
		[meBottomSlibingBrwView release];
		meBottomSlibingBrwView =nil;
	}
	if (mPreOpenArray) {
		[mPreOpenArray removeAllObjects];
		[mPreOpenArray release];
		mPreOpenArray = nil;
	}
	if (mPopoverBrwViewDict) {
		NSArray *popViewArray = [mPopoverBrwViewDict allValues];
		for (EBrowserView *popView in popViewArray) {
			if (popView.superview) {
				[popView removeFromSuperview];
			}
			[[meBrwCtrler brwWidgetContainer] pushReuseBrwView:popView];
			[popView release];
		}
		[mPopoverBrwViewDict removeAllObjects];
		[mPopoverBrwViewDict release];
		mPopoverBrwViewDict = nil;
	}
    //
    if (mMuiltPopoverDict)
    {
        NSArray * mulitPopArray = [mMuiltPopoverDict allValues];
        for (UIScrollView * popView in mulitPopArray)
        {
            if (popView.subviews) {
                [popView removeFromSuperview];
            }
        }
        [mMuiltPopoverDict removeAllObjects];
        //        [mMuiltPopoverDict release];
        mMuiltPopoverDict = nil;
    }
    ////
	if (meFrontWnd) {
		meFrontWnd.meBackWnd = NULL;
	}
	if (meBackWnd) {
		meBackWnd.meFrontWnd = NULL;
	}
    //
	if (meBrwHistory) {
		[meBrwHistory release];
		meBrwHistory = nil;
	}
	[mOAuthWndName release];
	mOAuthWndName = nil;
    [_windowName release];
	[super dealloc];
}

- (void)cleanAllBrwViews {
	if (meTopSlibingBrwView) {
        [meTopSlibingBrwView cleanAllEexObjs];
	}
	if (meBrwView) {
         [meBrwView cleanAllEexObjs];
	}
	if (meBottomSlibingBrwView) {
        [meBottomSlibingBrwView cleanAllEexObjs];
	}
	if (mPopoverBrwViewDict) {
		NSArray *popViewArray = [mPopoverBrwViewDict allValues];
		for (EBrowserView *popView in popViewArray) {
            [popView cleanAllEexObjs];
		}
	}
}

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt UExObjName:(NSString*)inUExObjName {
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor whiteColor];
		self.opaque = YES;
		meBrwCtrler = eInBrwCtrler;
		mwWgt = inWgt;
		mOAuthWndName = nil;
		meBrwView = [[meBrwCtrler brwWidgetContainer] popReuseBrwView];
		if (meBrwView) {
			[meBrwView reuseWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:F_EBRW_VIEW_TYPE_MAIN];
		} else {
			meBrwView = [[EBrowserView alloc]initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:F_EBRW_VIEW_TYPE_MAIN];
		}
		ACENSLog(@"meBrwView retainCount is %d", meBrwView);
		[self addSubview:meBrwView];
		mPopoverBrwViewDict = [[NSMutableDictionary alloc]initWithCapacity:F_POPOVER_BRW_VIEW_DICT_SIZE];
		mMuiltPopoverDict = [[NSMutableDictionary alloc]initWithCapacity:F_POPOVER_BRW_VIEW_DICT_SIZE];
		//self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		meFrontWnd = nil;
		meBackWnd = nil;
		if (mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
			meBrwHistory = [[EBrowserHistory alloc]init];
		}
		mOpenAnimiId = 0;
    }
	ACENSLog(@"EBrowserWindow alloc is %x", self);
    return self;
}

- (void)layoutSubviews {
	ACENSLog(@"EBrowserWindow layoutSubviews!");
	ACENSLog(@"wnd name is %@", self.meBrwView.muexObjName);
	ACENSLog(@"wnd rect is:%f,%f,%f,%f", self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height);
	//[self setFrame:self.superview.bounds];
	if (meTopSlibingBrwView) {
		ACENSLog(@"top is not null");
		[meTopSlibingBrwView setFrame:CGRectMake(0, 0, self.bounds.size.width, meTopSlibingBrwView.bounds.size.height)];
	} 
	if (meBottomSlibingBrwView) {
		ACENSLog(@"bottom is not null");
		[meBottomSlibingBrwView setFrame:CGRectMake(0, self.bounds.size.height-meBottomSlibingBrwView.bounds.size.height, self.bounds.size.width, meBottomSlibingBrwView.bounds.size.height)];
	}
	[meBrwView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
	if (meTopSlibingBrwView) {
		ACENSLog(@"top rect is:%f,%f,%f,%f", meTopSlibingBrwView.frame.origin.x, meTopSlibingBrwView.frame.origin.y, meTopSlibingBrwView.bounds.size.width, meTopSlibingBrwView.bounds.size.height);
	}
	if (meBottomSlibingBrwView) {
		ACENSLog(@"bottom rect is:%f,%f,%f,%f", meBottomSlibingBrwView.frame.origin.x, meBottomSlibingBrwView.frame.origin.y, meBottomSlibingBrwView.bounds.size.width, meBottomSlibingBrwView.bounds.size.height);
	}
	ACENSLog(@"view rect is:%f,%f,%f,%f", meBrwView.frame.origin.x, meBrwView.frame.origin.y, meBrwView.bounds.size.width, meBrwView.bounds.size.height);
}

- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView {
}

- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView {
	if (mOAuthWndName) {
		EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)self.superview;
		EBrowserWindow *eBrwWnd = [eBrwWndContainer brwWndForKey:mOAuthWndName];
		if (eBrwWnd) {
			NSString *changedUrl = [[meBrwView curUrl] absoluteString];
			//ACENSLog(@"%@",changedUrl);
			NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onOAuthInfo!=null){uexWindow.onOAuthInfo(\'%@\',\'%@\');}", meBrwView.muexObjName, changedUrl];
			//ACENSLog(@"toBeExeJS: %@", toBeExeJs);
			[eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
		}
	}
}

- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView {
	if (mOAuthWndName) {
		EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)self.superview;
		EBrowserWindow *eBrwWnd = [eBrwWndContainer brwWndForKey:mOAuthWndName];
		if (eBrwWnd) {
			NSString *changedUrl = [[eBrwWnd.meBrwView curUrl] absoluteString];
			ACENSLog(@"%@",changedUrl);
			NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onOAuthInfo!=null){uexWindow.onOAuthInfo(\'%@\',\'%@\');}", meBrwView.muexObjName, changedUrl];
			[eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
		}
	}
}

- (BOOL)canGoBack {
	return [meBrwHistory canGoBack];
}

- (BOOL)canGoForward {
	return [meBrwHistory canGoForward];
}

- (void)goBack {
	EBrowserHistoryEntry *eHisEntry = [meBrwHistory hisEntryByStep:F_EBRW_HISTORY_STEP_BACK];
	if (eHisEntry) {
		[meBrwHistory goBack];
		if (eHisEntry.mIsObf == YES) {
			FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
			ACENSLog(@"+++Broad+++: EBrowserWindow.goback: url is %@", eHisEntry.mUrl);
			NSString *data = [encryptObj decryptWithPath:eHisEntry.mUrl appendData:nil];
			[encryptObj release];
			[meBrwView loadWithData:data baseUrl:eHisEntry.mUrl];
		} else {
			[meBrwView loadWithUrl:eHisEntry.mUrl];
		}
	}
}

- (void)goForward {
	EBrowserHistoryEntry *eHisEntry = [meBrwHistory hisEntryByStep:F_EBRW_HISTORY_STEP_FORWARD];
	if (eHisEntry) {
		[meBrwHistory goForward];
		if (eHisEntry.mIsObf == YES) {
			FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
			NSString *data = [encryptObj decryptWithPath:eHisEntry.mUrl appendData:nil];
			[encryptObj release];
			[meBrwView loadWithData:data baseUrl:eHisEntry.mUrl];
		} else {
			[meBrwView loadWithUrl:eHisEntry.mUrl];
		}
	}
}

- (void)addHisEntry:(EBrowserHistoryEntry*)eInHisEntry {
	[meBrwHistory addHisEntry:eInHisEntry];
}

- (EBrowserHistoryEntry*)curHisEntry {
	return [meBrwHistory hisEntryByStep:F_EBRW_HISTORY_STEP_CUR];
}

- (EBrowserView*)popBrwViewForKey:(id)inKey {
	id obj = [mPopoverBrwViewDict objectForKey:inKey];
	if (obj != nil) {
		return (EBrowserView*)obj;
	}
	return nil;
}

- (void)removeFromPopBrwViewDict:(id)inKey {
	if (inKey != nil) {
		[mPopoverBrwViewDict removeObjectForKey:inKey];
	}
}

- (void)clean {
	[meBrwHistory clean];
}

-(EBrowserView *)theFrontView
{
    UIView * view = nil;
    NSArray * subviewsOfWindow = [self subviews];
    if ([subviewsOfWindow count] == 1) {
        view = [subviewsOfWindow objectAtIndex:0];
        if ([view isKindOfClass:[EBrowserView class]]) {
            return (EBrowserView *)view;
        }else{
            return self.meBrwView;
        }
    }
    
    for (int i = 1; i < [subviewsOfWindow count]; i++) {
        view = [subviewsOfWindow objectAtIndex:[subviewsOfWindow count] - i];
        if ([view isKindOfClass:[EBrowserView class]] ) {
            return (EBrowserView *)view;
        }
    }
    return self.meBrwView;
    
}

@end
