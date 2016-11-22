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

#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "BUtility.h"
#import "EBrowserController.h"
#import "WWidget.h"
#import "EBrowserHistory.h"
#import "FileEncrypt.h"
#import "EBrowserHistoryEntry.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EUExWindow.h"
#import "ACEUINavigationController.h"
#import "WidgetOneDelegate.h"
#import "ACEDrawerViewController.h"
#import "RESideMenu.h"

#import "ACEJSCBaseJS.h"
#import "ACEBrowserView.h"
#import "ACEMultiPopoverScrollView.h"

#import "ACESubwidgetManager.h"
#import <AppCanKit/ACGCDThrottle.h>


@interface EBrowserWindow()
@property(nonatomic,assign)BOOL isTopWindow;
@end

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
    [meTopSlibingBrwView removeFromSuperview];
    meTopSlibingBrwView = nil;
    [meBrwView removeFromSuperview];
    meBrwView = nil;
    [meBottomSlibingBrwView removeFromSuperview];
    meBottomSlibingBrwView =nil;
    [mPreOpenArray removeAllObjects];
    mPreOpenArray = nil;
    
    NSArray *popViewArray = [mPopoverBrwViewDict allValues];
    for (EBrowserView *popView in popViewArray) {
        [popView removeFromSuperview];
    }
    [mPopoverBrwViewDict removeAllObjects];
    mPopoverBrwViewDict = nil;
    
    NSArray * mulitPopArray = [mMuiltPopoverDict allValues];
    for (UIScrollView * popView in mulitPopArray){
        [popView removeFromSuperview];
    }
    [mMuiltPopoverDict removeAllObjects];
    mMuiltPopoverDict = nil;
    

    if (meFrontWnd && [meFrontWnd isKindOfClass:[EBrowserWindow class]]) {
        if ([meFrontWnd respondsToSelector:@selector(setMeBackWnd:)]) {
            [meFrontWnd setMeBackWnd:nil];
        }
    }
    
    if (meBackWnd && [meBackWnd isKindOfClass:[EBrowserWindow class]]) {
        if ([meBackWnd respondsToSelector:@selector(setMeFrontWnd:)]) {
            [meBackWnd setMeFrontWnd:nil];
        }
    }
    
    meBrwHistory = nil;
    mOAuthWndName = nil;
    [self deregisterWindowSequenceChange];
    self.popAnimationInfo = nil;

}


- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt UExObjName:(NSString*)inUExObjName {
    self = [super initWithFrame:frame];
    if (self) {

		self.backgroundColor = [UIColor clearColor];
		self.opaque = YES;
		meBrwCtrler = eInBrwCtrler;
		mwWgt = inWgt;

        meBrwView = [[EBrowserView alloc]initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:ACEEBrowserViewTypeMain];
		
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
        self.windowName = inUExObjName;
    }
    self.isTopWindow = NO;
    self.enableSwipeClose = YES;
    [self registerWindowSequenceChange];
    return self;
}

- (void)layoutSubviews {

	//[self setFrame:self.superview.bounds];
	if (meTopSlibingBrwView) {
		[meTopSlibingBrwView setFrame:CGRectMake(0, 0, self.bounds.size.width, meTopSlibingBrwView.bounds.size.height)];
	} 
	if (meBottomSlibingBrwView) {
		[meBottomSlibingBrwView setFrame:CGRectMake(0, self.bounds.size.height-meBottomSlibingBrwView.bounds.size.height, self.bounds.size.width, meBottomSlibingBrwView.bounds.size.height)];
	}
	[meBrwView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];

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
        
        if ([view isKindOfClass:[EScrollView class]] ) {
            
            EScrollView * eScrollView = (EScrollView *)view;
            UIScrollView * scrollView = eScrollView.scrollView;
            
            int index = scrollView.contentOffset.x/scrollView.frame.size.width;
            
            NSMutableArray * eBrowserViews = [NSMutableArray array];
            for (UIView * subView in scrollView.subviews) {
                if ([subView isKindOfClass:[EBrowserView class]]) {
                    [eBrowserViews addObject:subView];
                }
            }
            
            EBrowserView * retView = nil;
            
            if ([eBrowserViews count] > index) {
                retView = [eBrowserViews objectAtIndex:index];
            }
            if ([retView isKindOfClass:[EBrowserView class]]) {
                return (EBrowserView *)retView;

            }
            
        }
        
    }
    return self.meBrwView;
    
}


- (EBrowserWindowContainer *)winContainer{
    if (!_winContainer) {
        if ([self.superview isKindOfClass:[EBrowserWindowContainer class]]) {
            _winContainer = (EBrowserWindowContainer*)self.superview;
        }
    }
    return _winContainer;
}



#pragma mark - onWindowAppear & onWindowDisappear
//20150703 by lkl

NSString *const cDidWindowSequenceChange=@"uexWindowSequenceHasChanged";

-(void)registerWindowSequenceChange{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wndSeqChange) name:cDidWindowSequenceChange object:nil];
}
-(void)deregisterWindowSequenceChange{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:cDidWindowSequenceChange object:nil];
}



-(void)wndSeqChange{
    EBrowserController *topController = [ACESubwidgetManager defaultManager].topWidgetController ?: theApp.meBrwCtrler;

    
    EBrowserWindow *topWindow = topController.aboveWindow;
    if (self.isTopWindow && self != topWindow) {
        ACLogDebug(@"%@ is no longer top window",self.windowName);
        self.isTopWindow = NO;
        [self.meBrwView callbackWithFunctionKeyPath:@"uexWindow.onWindowDisappear" arguments:nil];
        return;
    }
    if (!self.isTopWindow && self == topWindow) {
        ACLogDebug(@"%@ becomes top window",self.windowName);
        
        
        self.isTopWindow = YES;
        [self updateSwipeCloseEnableStatus];
        [self.meBrwView callbackWithFunctionKeyPath:@"uexWindow.onWindowAppear" arguments:nil];
        return;
    }

    
}

+(void)postWindowSequenceChange{
    ac_dispatch_throttle(0.15, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:cDidWindowSequenceChange object:nil];
    });
}

#pragma mark - Update Swipe Close Status
-(void)updateSwipeCloseEnableStatus{
    self.meBrwCtrler.aceNaviController.canDragBack = self.enableSwipeClose;
}

@end
