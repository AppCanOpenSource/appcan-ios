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
@synthesize mFlag;
@synthesize mMuiltPopoverDict;

- (WWidget *)mwWgt{
    return self.meBrwCtrler.widget;
}

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
}

//为uexWindow.openWithOptions方法新增加的实例化方法
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt UExObjName:(NSString*)inUExObjName windowOptions:(ACEMPWindowOptions *)windowOptions{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        meBrwCtrler = eInBrwCtrler;
        
        _windowOptions = windowOptions;
        if (_windowOptions && _windowOptions.windowStyle == 1) {
            
            self.backgroundColor = [UIColor whiteColor];
            
            frame.origin.x = 0;
            CGRect webFrame = frame;
            CGRect topFrame = frame;
            CGRect bottomFrame = frame;
            
            if (iPhoneX) {
                
                if (self.windowOptions.isBottomBarShow == YES) {
                    webFrame.size.height = frame.size.height - NavHeightIPhoneX - TabHeightIPhoneX;
                } else {
                    webFrame.size.height = frame.size.height - NavHeightIPhoneX;
                }
                webFrame.origin.y = NavHeightIPhoneX;
                
                topFrame.size.height = NavHeightIPhoneX;
                
                bottomFrame.origin.y = frame.size.height - TabHeightIPhoneX;
                bottomFrame.size.height = TabHeightIPhoneX;
            } else {
                
                if (self.windowOptions.isBottomBarShow == YES) {
                    webFrame.size.height = frame.size.height - NavHeightNormal - TabHeightNormal;
                } else {
                    webFrame.size.height = frame.size.height - NavHeightNormal;
                }
                webFrame.origin.y = NavHeightNormal;
                
                topFrame.size.height = NavHeightNormal;
                
                bottomFrame.origin.y = frame.size.height - TabHeightNormal;
                bottomFrame.size.height = TabHeightNormal;
            }
            
            meBrwView = [[EBrowserView alloc]initWithFrame:webFrame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:ACEEBrowserViewTypeMain];
            [self addSubview:meBrwView];
            
            _acempTopView = [[ACEMPTopView alloc] initWithFrame:topFrame WindowOptions:_windowOptions meBrwView:meBrwView];
            _acempBottomBgView = [[ACEMPBottomMenuBgView alloc] initWithFrame:bottomFrame windowOptions:_windowOptions meBrwView:meBrwView];
            [self addSubview:_acempTopView];
            [self addSubview:_acempBottomBgView];
            
            if (_windowOptions.isBottomBarShow == YES) {
                _acempBottomBgView.hidden = NO;
            } else {
                _acempBottomBgView.hidden = YES;
            }
        } else {
            
            meBrwView = [[EBrowserView alloc]initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:ACEEBrowserViewTypeMain];
            [self addSubview:meBrwView];
        }
        
        mPopoverBrwViewDict = [[NSMutableDictionary alloc]initWithCapacity:F_POPOVER_BRW_VIEW_DICT_SIZE];
        mMuiltPopoverDict = [[NSMutableDictionary alloc]initWithCapacity:F_POPOVER_BRW_VIEW_DICT_SIZE];
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        meFrontWnd = nil;
        meBackWnd = nil;
        if (mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
            meBrwHistory = [[EBrowserHistory alloc]init];
        }
        _openAnimationID = kACEAnimationNone;
        _windowName = inUExObjName;
    }
    self.isTopWindow = NO;
    self.enableSwipeClose = YES;
    [self registerWindowSequenceChange];
    return self;
}

//原实例化方法，uexWindow.openWithOptions不走这个
- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt UExObjName:(NSString*)inUExObjName {
    self = [super initWithFrame:frame];
    if (self) {

		self.backgroundColor = [UIColor clearColor];
		self.opaque = YES;
		meBrwCtrler = eInBrwCtrler;
        
        _windowOptions = inWgt.indexWindowOptions;
        if (inWgt.isFirstStartWithConfig == YES && _windowOptions && _windowOptions.windowStyle == 1) {
            
            inWgt.isFirstStartWithConfig = NO;
            
            self.backgroundColor = [UIColor whiteColor];
            
            frame.origin.x = 0;
            CGRect webFrame = frame;
            CGRect topFrame = frame;
            CGRect bottomFrame = frame;
            
            if (iPhoneX) {
                
                if (self.windowOptions.isBottomBarShow == YES) {
                    webFrame.size.height = frame.size.height - NavHeightIPhoneX - TabHeightIPhoneX;
                } else {
                    webFrame.size.height = frame.size.height - NavHeightIPhoneX;
                }
                webFrame.origin.y = NavHeightIPhoneX;
                
                topFrame.size.height = NavHeightIPhoneX;
                
                bottomFrame.origin.y = frame.size.height - TabHeightIPhoneX;
                bottomFrame.size.height = TabHeightIPhoneX;
            } else {
                
                if (self.windowOptions.isBottomBarShow == YES) {
                    webFrame.size.height = frame.size.height - NavHeightNormal - TabHeightNormal;
                } else {
                    webFrame.size.height = frame.size.height - NavHeightNormal;
                }
                webFrame.origin.y = NavHeightNormal;
                
                topFrame.size.height = NavHeightNormal;
                
                bottomFrame.origin.y = frame.size.height - TabHeightNormal;
                bottomFrame.size.height = TabHeightNormal;
            }
            
            meBrwView = [[EBrowserView alloc]initWithFrame:webFrame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:ACEEBrowserViewTypeMain];
            [self addSubview:meBrwView];
            
            _acempTopView = [[ACEMPTopView alloc] initWithFrame:topFrame WindowOptions:_windowOptions meBrwView:meBrwView];
            _acempBottomBgView = [[ACEMPBottomMenuBgView alloc] initWithFrame:bottomFrame windowOptions:_windowOptions meBrwView:meBrwView];
            [self addSubview:_acempTopView];
            [self addSubview:_acempBottomBgView];
            
            if (_windowOptions.isBottomBarShow == YES) {
                _acempBottomBgView.hidden = NO;
            } else {
                _acempBottomBgView.hidden = YES;
            }
        } else {
            
            meBrwView = [[EBrowserView alloc]initWithFrame:frame BrwCtrler:eInBrwCtrler Wgt:mwWgt BrwWnd:self UExObjName:inUExObjName Type:ACEEBrowserViewTypeMain];
            [self addSubview:meBrwView];
        }
		
		mPopoverBrwViewDict = [[NSMutableDictionary alloc]initWithCapacity:F_POPOVER_BRW_VIEW_DICT_SIZE];
		mMuiltPopoverDict = [[NSMutableDictionary alloc]initWithCapacity:F_POPOVER_BRW_VIEW_DICT_SIZE];
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		meFrontWnd = nil;
		meBackWnd = nil;
		if (mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
			meBrwHistory = [[EBrowserHistory alloc]init];
		}
        _openAnimationID = kACEAnimationNone;
        _windowName = inUExObjName;
        
        NSDictionary *extraInfo = _windowOptions.extras;
        if (extraInfo) {
            [self setExtraInfo: dictionaryArg(extraInfo[@"extraInfo"]) toEBrowserView:meBrwView];
            [self setOpenAnimationConfig: dictionaryArg(extraInfo[@"animationInfo"])];
        }
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
    
    if (self.windowOptions && self.windowOptions.windowStyle == 1) {
        
    } else {
        [meBrwView setFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)wndSeqChange{
    EBrowserController *topController = [ACESubwidgetManager defaultManager].topWidgetController ?: AppCanEngine.rootWebViewController;

    
    EBrowserWindow *topWindow = topController.aboveWindow;
    if (self.isTopWindow && self != topWindow) {
        self.isTopWindow = NO;
        [self.meBrwView callbackWithFunctionKeyPath:@"uexWindow.onWindowDisappear" arguments:nil];
        return;
    }
    if (!self.isTopWindow && self == topWindow) {
        self.isTopWindow = YES;
        [self.meBrwView callbackWithFunctionKeyPath:@"uexWindow.onWindowAppear" arguments:nil];
        return;
    }

    
}

+(void)postWindowSequenceChange{
    ac_dispatch_throttle(0.15, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:cDidWindowSequenceChange object:nil];
    });
}

- (void)setExtraInfo:(NSDictionary *)extraDic toEBrowserView:(EBrowserView *)inBrwView {
    if ([extraDic objectForKey:@"opaque"]) {
        BOOL opaque = [[extraDic objectForKey:@"opaque"] boolValue];
        if (opaque) {
            if ([extraDic objectForKey:@"bgColor"]) {
                NSString * bgStr = [extraDic objectForKey:@"bgColor"];
                UIColor *color = [UIColor ac_ColorWithHTMLColorString:bgStr];
                if (color) {
                    inBrwView.image = nil;
                    inBrwView.backgroundColor = color;
                }else{
                    UIImage *image = nil;
                    if (self.windowOptions.uexWidget) {
                        image = [UIImage imageWithContentsOfFile:[self.windowOptions.uexWidget absPath:bgStr]];
                    }
                    if (image) {
                        inBrwView.image = image;
                    }
                }
            }
        } else {
            inBrwView.image = nil;
            inBrwView.backgroundColor = [UIColor clearColor];
            
        }
    }
    
    NSString *exeJS = [extraDic objectForKey:@"exeJS"];
    if (exeJS) {
        [inBrwView setExeJS:exeJS];
    }
}

#pragma mark - Update Swipe Close Status

#pragma mark - 修改公众号窗口内容
- (void)setMPWindowOptions:(ACEMPWindowOptions *)windowOptions
{
    self.windowOptions = windowOptions;
    
    [self.acempBottomBgView setSubViewWithWindowOptions:self.windowOptions];
    [self.acempTopView resetWindowOptions:self.windowOptions];
    
    CGRect webFrame = meBrwView.frame;
    if (self.windowOptions.isBottomBarShow == YES) {
        
        if (iPhoneX) {
            webFrame.origin.y = NavHeightIPhoneX;
            webFrame.size.height = self.frame.size.height - NavHeightIPhoneX - TabHeightIPhoneX;
        } else {
            webFrame.origin.y = NavHeightNormal;
            webFrame.size.height = self.frame.size.height - NavHeightNormal - TabHeightNormal;
        }
    } else {
        
        if (iPhoneX) {
            webFrame.origin.y = NavHeightIPhoneX;
            webFrame.size.height = self.frame.size.height - NavHeightIPhoneX;
        } else {
            webFrame.origin.y = NavHeightNormal;
            webFrame.size.height = self.frame.size.height - NavHeightNormal;
        }
    }
    [meBrwView setFrame:webFrame];
    
    if (_windowOptions.isBottomBarShow == YES) {
        _acempBottomBgView.hidden = NO;
    } else {
        _acempBottomBgView.hidden = YES;
    }
}

@end
