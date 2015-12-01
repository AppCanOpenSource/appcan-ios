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

#import "EBrowserToolBar.h"
#import "BUtility.h"
#import "EBrowser.h"
#import "QuartzCore/CALayer.h"
#import "EBrowser.h"
#import "EBrowserWindow.h"
#import "EBrowserMainFrame.h"
#import "EBrowserController.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWidgetContainer.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "EBrowserView.h"
#import "BAnimation.h"
#import "EBrowserController.h"
#import <QuartzCore/QuartzCore.h>

#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"


@implementation EBrowserToolBar
@synthesize barbtn;
@synthesize eBrwCtrler;
@synthesize mFlag;
@synthesize flag;

- (void)dealloc {
	//yangfan MOD--->leaks
	[barbtn release];
	barbtn = nil;
	[super dealloc];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	if (buttonIndex == 0) {
		NSFileManager* fileMgr = [[NSFileManager alloc] init];
		NSError* err = nil;    
		
		//clear contents of NSTemporaryDirectory 
		NSString* tempDirectoryPath = NSTemporaryDirectory();
		ACENSLog(tempDirectoryPath);
		NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];    
		NSString* fileName = nil;
		BOOL result;
		
		while ((fileName = [directoryEnumerator nextObject])) {
			NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
			ACENSLog(filePath);
			result = [fileMgr removeItemAtPath:filePath error:&err];
			if (!result && err) {
				ACENSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
			}
		}    
		[fileMgr release];
		exit(0);
	}
}

- (void)setMenubtn  {
	[self setNeedsDisplay];
	
	if(isPad){
		[self setFrame:CGRectMake(768-66,BOTTOM_IPAD_LOCATION_VERTICAL_Y,BOTTOM_IPAD_ITEM_WIDTH,BOTTOM_IPAD_ITEM_HEIGHT)];
	}else{
		[self setFrame:CGRectMake(320-33,BOTTOM_LOCATION_VERTICAL_Y,BOTTOM_ITEM_WIDTH,BOTTOM_ITEM_HEIGHT)];
	}
	[self setUserInteractionEnabled:YES];
	UIPanGestureRecognizer *gesture = [[[UIPanGestureRecognizer alloc] 
										initWithTarget:self 
										action:@selector(btnDragged:)] autorelease];
	[self addGestureRecognizer:gesture];
	
//  初始化barbtn
	barbtn = [UIButton buttonWithType:UIButtonTypeCustom]; 
	
	if(isPad){
		[barbtn setFrame:CGRectMake(0, 0, BOTTOM_IPAD_ITEM_WIDTH, BOTTOM_IPAD_ITEM_HEIGHT)];
	}else{
	[barbtn setFrame:CGRectMake(0, 0, BOTTOM_ITEM_WIDTH, BOTTOM_ITEM_HEIGHT)];
	}
	[barbtn setBackgroundColor:[UIColor clearColor]];
	if(isPad){
		[barbtn setBackgroundImage:[UIImage imageNamed:@"img/my_space_entry_icon-72.png"] forState:UIControlStateNormal];
	}else{
		[barbtn setBackgroundImage:[UIImage imageNamed:@"img/my_space_entry_icon.png"] forState:UIControlStateNormal];
	}
	if (![BUtility getAppCanDevMode]) {
		[barbtn addTarget:self action:@selector(LoadSpace) forControlEvents:UIControlEventTouchUpInside];
	} else {
		[barbtn addTarget:self action:@selector(finishWgt) forControlEvents:UIControlEventTouchUpInside];
	}
	[self addSubview:barbtn];
}

- (void)finishWgt{
    EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    EBrowserView *eView = eBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView;
    
    if (flag==1) {
        // EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        [eView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onSpaceClick!=null){uexWidget.onSpaceClick(0,0,0);}"];
    }
    else{
        EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        EBrowserWindowContainer *eCurBrwWndContainer = [eBrwWgtContainer aboveWindowContainer];
        if (eCurBrwWndContainer.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {
            NSString * title = ACELocalized(UEX_EXITAPP_ALERT_TITLE);
            NSString * message = ACELocalized(UEX_EXITAPP_ALERT_MESSAGE);
            NSString * exit = ACELocalized(UEX_EXITAPP_ALERT_EXIT);
            NSString * cancel = ACELocalized(UEX_EXITAPP_ALERT_CANCLE);
            
            UIAlertView *widgetOneConfirmView = [[[UIAlertView alloc]
                                                 initWithTitle:title
                                                 message:message
                                                 delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:exit,cancel,nil] autorelease];
            [widgetOneConfirmView show];
            return;
        }
        [eBrwWgtContainer.mBrwWndContainerDict removeObjectForKey:eCurBrwWndContainer.mwWgt.appId];
        [eCurBrwWndContainer removeFromSuperview];
        [[[eBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    }
}
-(void)transformScreen{
	//强制转屏
	UIInterfaceOrientation cOrientation = [UIApplication sharedApplication].statusBarOrientation;
	if ((cOrientation == UIInterfaceOrientationLandscapeLeft) || (cOrientation == UIInterfaceOrientationLandscapeRight)) {
		if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
			[[UIDevice currentDevice] performSelector:@selector(setOrientation:)
										   withObject:(id)UIInterfaceOrientationPortrait];
			eBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView.meBrwCtrler.mFlag = 1;
		}
	}
}
- (void)LoadSpace{
    
    EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    EBrowserView *eView = eBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView;
    
    if (flag==1) {
        // EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        [eView stringByEvaluatingJavaScriptFromString:@"if(uexWidget.onSpaceClick!=null){uexWidget.onSpaceClick(0,0,0);}"];
    }
    else{
        //	EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        EBrowserWindowContainer *eBrwWndContainer = [eBrwWgtContainer aboveWindowContainer];
        if ((self.mFlag & F_TOOLBAR_FLAG_FINISH_WIDGET) == F_TOOLBAR_FLAG_FINISH_WIDGET) {
            if (eBrwWndContainer != eBrwWgtContainer.meRootBrwWndContainer) {
                NSString *finishWgtStr = [NSString stringWithFormat:@"uexWidget.finishWidget(\"\")"];
                [[eBrwWndContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:finishWgtStr];
                return;
            }
        }
        
        if (!eView.meBrwCtrler.meBrwMainFrm.mAppCenter) {
            AppCenter *tmpCenter = [[AppCenter alloc] init];
            eView.meBrwCtrler.meBrwMainFrm.mAppCenter = tmpCenter;
            [tmpCenter release];
        }
        if (eView.meBrwCtrler.meBrwMainFrm.mAppCenter.showTag == YES) {
            return;
        }
        [eView.meBrwCtrler.meBrwMainFrm.mAppCenter openAppCenterWithEBrwView:eView];
        UIInterfaceOrientation cOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if ((cOrientation == UIInterfaceOrientationLandscapeLeft) || (cOrientation == UIInterfaceOrientationLandscapeRight)) {
            eView.meBrwCtrler.mFlag = 0;
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(transformScreen) userInfo:nil repeats:NO];
        }else {
            eView.meBrwCtrler.mFlag = 1;
        }
        
        [BAnimation SwapAnimationWithView:eView.meBrwWnd.superview AnimiId:8 AnimiTime:2.0];
        
        [self setHidden:YES];
        /*if (!eBrwCtrler.mwWgtMgr.wSpaceWgt) {
         return;
         }
         EBrowserWidgetContainer *eBrwWgtContainer = eBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
         EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:eBrwCtrler.mwWgtMgr.wSpaceWgt.appId];
         if (eBrwWndContainer) {
         if ((eBrwWndContainer.mFlag & F_BRW_WND_CONTAINER_LOAD_WGT_DONE) == F_BRW_WND_CONTAINER_LOAD_WGT_DONE) {
         [eBrwWgtContainer bringSubviewToFront:eBrwWndContainer];
         [BAnimation SwapAnimationWithView:eBrwWgtContainer AnimiId:eBrwWndContainer.mStartAnimiId AnimiTime:0.2f];
         [[eBrwWgtContainer.meRootBrwWndContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
         [[eBrwWndContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
         } else {
         eBrwWndContainer.meOpenerContainer = eBrwWgtContainer.meRootBrwWndContainer;
         [eBrwWndContainer.meRootBrwWnd.meBrwView loadWidget];
         }
         if (self.hidden == NO) {
         self.hidden = YES;
         }
         } else {
         eBrwWndContainer = [[EBrowserWindowContainer alloc]initWithFrame:CGRectMake(0, 0, eBrwWgtContainer.bounds.size.width, eBrwWgtContainer.bounds.size.height) BrwCtrler:eBrwCtrler Wgt:eBrwCtrler.mwWgtMgr.wSpaceWgt];
         eBrwWndContainer.mStartAnimiId = eBrwWndContainer.mStartAnimiId;
         [eBrwWgtContainer.mBrwWndContainerDict setObject:eBrwWndContainer forKey:eBrwCtrler.mwWgtMgr.wSpaceWgt.appId];
         eBrwWndContainer.meOpenerContainer = eBrwWgtContainer.meRootBrwWndContainer;
         [eBrwWndContainer.meRootBrwWnd.meBrwView loadWidget];
         }*/
    }
}

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler {
	if (self = [super initWithFrame:frame]) {
		eBrwCtrler = eInBrwCtrler;
		[self setMenubtn];
	}
	return self;
}
- (void)btnDragged:(UIPanGestureRecognizer *)gesture
{
	CGPoint translation = [gesture  translationInView:self];
	// move btn
	if (self.frame.origin.x+ translation.x<0||self.frame.origin.x+ translation.x>([BUtility getScreenWidth]-barbtn.frame.size.width)) {
		return;
	}
	if (self.frame.origin.y+translation.y <0||self.frame.origin.y+translation.y>([BUtility getScreenHeight]-barbtn.frame.size.height)) {
		return;
	}
	self.center = CGPointMake(self.center.x + translation.x, 
								self.center.y + translation.y);
	
	// reset translation
	[gesture setTranslation:CGPointZero inView:self];
}
@end