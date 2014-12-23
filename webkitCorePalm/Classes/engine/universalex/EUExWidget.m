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

#import "EUExWidget.h"
#import "WWidgetMgr.h"
#import "EBrowserView.h"
#import "EBrowserController.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserToolBar.h"
#import "EBrowser.h"
#import "WWidget.h"
#import "BAnimition.h"
#import "BUtility.h"
#import "JSON.h"
#import "EUExBaseDefine.h"
#import "ASIFormDataRequest.h"
#import "WidgetOneDelegate.h"
#import <Security/Security.h>
#import "BAnimition.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "JSONKit.h"
#import "EUtility.h"
#import "ACEUtils.h"

@implementation EUExWidget

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	if (buttonIndex == 0) {
		NSFileManager* fileMgr = [[NSFileManager alloc] init];
		NSError* err = nil;    
		
		// clear contents of NSTemporaryDirectory 
		NSString* tempDirectoryPath = NSTemporaryDirectory();
		NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];    
		NSString* fileName = nil;
		BOOL result;
		
		while ((fileName = [directoryEnumerator nextObject])) {
			NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
			ACENSLog(@"+++++Broad+++++: %@",filePath);
			result = [fileMgr removeItemAtPath:filePath error:&err];
			if (!result && err) {
				ACENSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
			}
		}    
		[fileMgr release];
		exit(0);
	}
}

-(id)initWithBrwView:(EBrowserView *) eInBrwView {	
	if (self = [super initWithBrwView:eInBrwView]) {
	}
	return self;
}

-(void)dealloc{
	[super dealloc];
}



-(void)setLogServerIp:(NSMutableArray *)inArguments {
    
    NSString * logServerIp = nil;
    NSString * isDebug = nil;
    
    if ([inArguments isKindOfClass:[NSMutableArray class]] && [inArguments count] == 2) {
        logServerIp = [inArguments objectAtIndex:0];
        isDebug = [inArguments objectAtIndex:1];
    }else {
        return;
    }
    
    WWidget *inCurWgt = meBrwView.mwWgt;
    inCurWgt.logServerIp = logServerIp;
    
    if ([isDebug isEqualToString:@"1"]) {
        inCurWgt.isDebug = YES;
    }else{
        inCurWgt.isDebug = NO;
    }
}

-(WWidget*)getStartWgtByAppId:(NSString*)inAppId{
//	WWidget *inCurWgt = meBrwView.mwWgt;
	WWidgetMgr *wgtMgr = meBrwView.meBrwCtrler.mwWgtMgr;
    WWidget * mainWgt = [wgtMgr mainWidget];
	WWidget *startWgt = nil;
	startWgt = (WWidget*)[wgtMgr wgtPluginDataByAppId:inAppId curWgt:mainWgt];
	//plugin
	if (startWgt) {
		return startWgt;
	}
//	int wgtType = meBrwView.mwWgt.wgtType;
	//开发版
	if ([BUtility getAppCanDevMode]) {
		startWgt = (WWidget*)[wgtMgr wgtDataByAppId:inAppId];
		return startWgt;
	}
	//main widget
//	if (wgtType ==F_WWIDGET_MAINWIDGET) {			
		startWgt = (WWidget*)[wgtMgr wgtDataByAppId:inAppId];
//		return startWgt;
//	}
	//my space
	/*if (wgtType ==F_WWIDGET_SPACEWIDGET) {
		startWgt = (WWidget*)[wgtMgr wgtDataByAppId:inAppId];
		return startWgt;
	}*/
	return startWgt;
}
-(void)startWidget:(NSMutableArray *)inArguments {
	ACENSLog(@"[EUExWidget startWidget]");
	NSString *inAppId = [inArguments objectAtIndex:0];
	NSString *inAnimiId = [inArguments objectAtIndex:1];
	NSString *inForRet = [inArguments objectAtIndex:2];
	NSString *inOpenerInfo = [inArguments objectAtIndex:3];
	NSString *inAnimiDuration = NULL;
	NSString *inAppkey = nil;
	if ([inArguments count] >= 5) {
		inAnimiDuration = [inArguments objectAtIndex:4];
	}
	if ([inArguments count] >= 6) {
		inAppkey = [inArguments objectAtIndex:5];
	}
	if ((meBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) == F_EBRW_FLAG_WIDGET_IN_OPENING) {
		return;
	}
	EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
	if (eBrwMainFrm.meAdBrwView) {
		eBrwMainFrm.meAdBrwView.hidden = YES;
		[eBrwMainFrm invalidateAdTimers];
	}
	int animiId = 0;
	float animiDuration = 0.2f;
	if (!inAppId || inAppId.length == 0 || !inAnimiId || !inForRet || !inOpenerInfo) {
		[self jsSuccessWithName:@"uexWidget.cbStartWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
		return;
	}
	if (inAnimiId.length != 0) {
		animiId = [inAnimiId intValue];
	}
	if (inAnimiDuration && inAnimiDuration.length != 0) {
		animiDuration = [inAnimiDuration floatValue]/1000.0f;
	}
	WWidget *wgtObj = [self getStartWgtByAppId:inAppId];
    if (!wgtObj) {//
        [self jsSuccessWithName:@"uexWidget.cbStartWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
		return;
    }
    //
    int mOrientaion =meBrwView.mwWgt.orientation;
    int subOrientation = wgtObj.orientation;
    if (subOrientation==mOrientaion)
    {;}
    else if (subOrientation==2 || subOrientation==3 || subOrientation==10 || subOrientation==6 || subOrientation==7 || subOrientation==14 || subOrientation==16)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",subOrientation] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
        {
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeLeft];
        }
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",subOrientation] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
        {
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeRight];
        }
    }
	//ACENSLog(@"wgtObj retaincount=%d",[wgtObj retainCount]);
	if(wgtObj){
		meBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WIDGET_IN_OPENING;
		EBrowserWidgetContainer *eBrwWgtContainer = meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
//		EBrowserWindowContainer *eCurBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
        
        EBrowserWindowContainer *eCurBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
        
		EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:inAppId];
		if (eBrwWndContainer) {
			eBrwWndContainer.mStartAnimiId = animiId;
			eBrwWndContainer.mStartAnimiDuration = animiDuration;
			eBrwWndContainer.meOpenerContainer = eCurBrwWndContainer;
			if (inForRet) {
				eBrwWndContainer.mOpenerForRet = inForRet;
			}
			if (inOpenerInfo) {
				eBrwWndContainer.mOpenerInfo = inOpenerInfo;
			}
			[eBrwWgtContainer bringSubviewToFront:eBrwWndContainer];
            
            if ([BAnimition isMoveIn:animiId]) {
                [BAnimition doMoveInAnimition:eBrwWndContainer animiId:animiId animiTime:animiDuration];
            }else if ([BAnimition isPush:animiId]) {
                [BAnimition doPushAnimition:eBrwWndContainer animiId:animiId animiTime:animiDuration];
            }else {
                [BAnimition SwapAnimationWithView:eBrwWgtContainer AnimiId:animiId AnimiTime:animiDuration];
            }
			
			if (eCurBrwWndContainer) {
				[[eCurBrwWndContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
			}
			EBrowserWindow *eAboveWnd = [eBrwWndContainer aboveWindow];
			[eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
			if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
				NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
				[eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
			}
			if (eBrwWgtContainer.meRootBrwWndContainer == eBrwWndContainer) {
				meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag &= ~F_TOOLBAR_FLAG_FINISH_WIDGET;
			}
			if (meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter) {
				if (meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
					[meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_SUCCESS retAppId:inAppId];
				}
			}
			meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WIDGET_IN_OPENING;
		} else {
			eBrwWndContainer = [[EBrowserWindowContainer alloc] initWithFrame:CGRectMake(0, 0, eBrwWgtContainer.bounds.size.width, eBrwWgtContainer.bounds.size.height) BrwCtrler:meBrwView.meBrwCtrler Wgt:wgtObj];
			eBrwWndContainer.mStartAnimiId = animiId;
			eBrwWndContainer.mStartAnimiDuration = animiDuration;
			eBrwWndContainer.meOpenerContainer = eCurBrwWndContainer;
			if (inForRet) {
				eBrwWndContainer.mOpenerForRet = inForRet;
			}
			if (inOpenerInfo) {
				eBrwWndContainer.mOpenerInfo = inOpenerInfo;
			}
			[eBrwWgtContainer.mBrwWndContainerDict setObject:eBrwWndContainer forKey:inAppId];
			if ([inAppId isEqualToString:@"9999997"] || [inAppId isEqualToString:@"9999998"]) {
				[eBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:inOpenerInfo];
			} else {
				[eBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:NULL];
			}
            //[eBrwWndContainer release];// cui 20130603
		}
		[self jsSuccessWithName:@"uexWidget.cbStartWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:0];
        //子widget启动上报代码
        //    NSString *inKey=[BUtility appKey];
        Class  analysisClass =  NSClassFromString(@"AppCanAnalysis");//判断类是否存在，如果存在子widget上报
        if (analysisClass) {
            
            //            AppCanAnalysis *acAna = [AppCanAnalysis ACInstance];
            //            [acAna setAppChannel:wgtObj.channelCode]; //mwWgtMgr.mainWidget.channelCode:widget的渠道号，	            子widget添加子widget的渠道号
            //            [acAna setAppId:wgtObj.appId];//mwWgtMgr.mainWidget.appId   子widget添加子widget的appId
            //            [acAna setAppVersion:wgtObj.ver];//mwWgtMgr.mainWidget.ver   字widget的版本号
            //            if (inAppkey)
            //            {
            //                [acAna startWithChildAppKey:inAppkey];   //inKey  目前为主widget的AppKey，子widget没有
            //            }
            id analysisObject = class_createInstance(analysisClass,0);
            objc_msgSend(analysisObject, @selector(setAppChannel:),wgtObj.channelCode);//mwWgtMgr.mainWidget.channelCode:widget的渠道号，	            子widget添加子widget的渠道号
            objc_msgSend(analysisObject, @selector(setAppId:),wgtObj.appId);//mwWgtMgr.mainWidget.appId   子widget添加子widget的
            objc_msgSend(analysisObject, @selector(setAppVersion:),wgtObj.ver);//mwWgtMgr.mainWidget.ver   字widget的版本号
            objc_msgSend(analysisObject, @selector(startWithChildAppKey:),inAppkey); //inKey  目前为主widget的AppKey，子widget没有
        }
	}else {
		if (meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter) {
			if (meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
				[meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_NOT_EXIST retAppId:inAppId];
			}
		}
		[self jsSuccessWithName:@"uexWidget.cbStartWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:2];
	}
}

-(void)finishWidget:(NSMutableArray *)inArguments {
	ACENSLog(@"[EUExWidget finishWidget]");
	NSString *inRet = [inArguments objectAtIndex:0];
    NSString *appID = nil;
    //********************************************
    if ([inArguments count]>1&&[[inArguments objectAtIndex:1] length]>0)
    {
        appID = [inArguments objectAtIndex:1];
    }
    BOOL isWgtBG=NO;
    if ([inArguments count]>2&&[[inArguments objectAtIndex:2] length]>0)
    {
        isWgtBG = [[inArguments objectAtIndex:2] boolValue];
    }//*******************************************
    //
    NSString * mainwgtOrientation = [BUtility getMainWidgetConfigInterface];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",mainwgtOrientation] forKey:@"subwgtOrientaion"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
    int mOrientaion = [[BUtility getMainWidgetConfigInterface]intValue];
    int subOrientation =meBrwView.mwWgt.orientation;
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    if (subOrientation==mOrientaion)
    {;}
    else if (mOrientaion==1 || mOrientaion==5 || mOrientaion==3 || mOrientaion==9 || mOrientaion==11)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",mOrientaion] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
        {
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationPortrait];
        }
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",mOrientaion] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
        {
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeLeft];
        }
    }
    
    
    if (isWgtBG) {
        WWidgetMgr *wgtMgr = meBrwView.meBrwCtrler.mwWgtMgr;
        WWidget *mainWgt=[wgtMgr mainWidget];
        EBrowserWidgetContainer *eBrwWgtContainer = meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:mainWgt.appId];
        [eBrwWgtContainer bringSubviewToFront:eBrwWndContainer];
        return;
    }
   


	EBrowserWidgetContainer *eBrwWgtContainer = meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
	EBrowserWindowContainer *eBrwWndContainer = nil;
    if (appID)
    {
        eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:appID];
    }else
    {
//        eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
        eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    }
	if (eBrwWndContainer.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {
        NSString * title = NSLocalizedString(@"exitAlertTitle", nil);
        NSString * message = NSLocalizedString(@"exitAlertMessage", nil);
        NSString * exit = NSLocalizedString(@"exitAlertExitBtn", nil);
        NSString * cancel = NSLocalizedString(@"exitAlertCancelBtn", nil);
        
		UIAlertView *widgetOneConfirmView = [[UIAlertView alloc]
											 initWithTitle:title
											 message:message
											 delegate:self
											 cancelButtonTitle:nil
											 otherButtonTitles:exit,cancel,nil];
		[widgetOneConfirmView show];
		//
		[widgetOneConfirmView release];
		return;
	}
	if (inRet && inRet.length != 0) {
		if (eBrwWndContainer.mOpenerForRet) {
			NSString *jsStr = [NSString stringWithFormat:@"if(%@!=null){%@('%@');}",eBrwWndContainer.mOpenerForRet,eBrwWndContainer.mOpenerForRet,inRet];
			[[eBrwWndContainer.meOpenerContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
		}
	}
    if (appID)
    {
        [eBrwWgtContainer.mBrwWndContainerDict removeObjectForKey:appID];
    }
    else
    {
        [eBrwWgtContainer.mBrwWndContainerDict removeObjectForKey:eBrwWndContainer.mwWgt.appId];
    }
	if (![BUtility getAppCanDevMode]) {
		if (eBrwWndContainer.meOpenerContainer.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {
			if (meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar) {
				meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = NO;
			}
		}
	}
    int animiId = [BAnimition ReverseAnimiId:eBrwWndContainer.mStartAnimiId];
    float duration = eBrwWndContainer.mStartAnimiDuration;
    if ([BAnimition isPush:animiId]) {
        [BAnimition doPushAnimition:eBrwWndContainer animiId:animiId animiTime:duration];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
    }else {
        [BAnimition SwapAnimationWithView:eBrwWgtContainer AnimiId:animiId AnimiTime:duration];
    }
	[eBrwWndContainer removeFromSuperview];
	if (eBrwWndContainer != eBrwWgtContainer.meRootBrwWndContainer) {
		meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag &= ~F_TOOLBAR_FLAG_FINISH_WIDGET;
		meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = YES;
	}
	EBrowserWindow *eAboveWnd = [[eBrwWgtContainer aboveWindowContainer] aboveWindow];
	[eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
	if (meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter && meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.sView.hidden == NO) {
		return;
	}
	if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
		NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
		[eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
	}
}

-(void)removeWidget:(NSMutableArray*)inArguments {
    NSString *inAppId = [inArguments objectAtIndex:0];
	ACENSLog(@"[EUExWidget removeWidget]");
	if (!inAppId) {
		[self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
	}
	WWidgetMgr *wgtMgr = meBrwView.meBrwCtrler.mwWgtMgr;
	if ([inAppId isEqualToString:meBrwView.mwWgt.appId] == YES) {
		[wgtMgr removeWgtByAppId:inAppId];
		[self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
		return;
	}
	if (meBrwView.mwWgt.wgtType != F_WWIDGET_SPACEWIDGET && meBrwView.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
		[self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
		return;
	}
	int removeRet = [wgtMgr removeWgtByAppId:inAppId];
	if (F_WIDGET_REMOVE_SUCCESS == removeRet) {
		[self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
	} else {
		[self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
	}
}
- (void)getOpenerInfo:(NSMutableArray *)inArguments {
//	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
	if (eBrwWndContainer.mOpenerInfo) {
		ACENSLog(@"%@",eBrwWndContainer.mOpenerInfo);
		[self jsSuccessWithName:@"uexWidget.cbGetOpenerInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:eBrwWndContainer.mOpenerInfo];
	}
}

- (void)setMySpaceInfoWithAnimiId:(NSString*)inAnimiId ForRet:(NSString*)inForRet OpenerInfo:(NSString*)inOpenerInfo {
	ACENSLog(@"[EUExWidget setMySpaceInfo]");
	/*if (!inAnimiId || !inForRet || !inOpenerInfo) {
		return;
	}
	EBrowserWidgetContainer *eBrwWgtContainer = meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
	if (eBrwWndContainer.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
		return;
	}
	EBrowserWindowContainer *eMySpaceContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:meBrwView.meBrwCtrler.mwWgtMgr.wSpaceWgt.appId];
	if (!eMySpaceContainer) {
		eMySpaceContainer = [[EBrowserWindowContainer alloc]initWithFrame:CGRectMake(0, 0, eBrwWgtContainer.bounds.size.width, eBrwWgtContainer.bounds.size.height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.meBrwCtrler.mwWgtMgr.wSpaceWgt];
		[eBrwWgtContainer.mBrwWndContainerDict setObject:eMySpaceContainer forKey:meBrwView.meBrwCtrler.mwWgtMgr.wSpaceWgt.appId];
	}
	if (inAnimiId.length != 0) {
		eMySpaceContainer.mStartAnimiId = [inAnimiId intValue];
	}
	if (inForRet.length != 0) {
		eMySpaceContainer.mOpenerForRet = inForRet;
	}
	eMySpaceContainer.mOpenerInfo = inOpenerInfo;*/

}

- (void)loadApp:(NSMutableArray *)inArguments {
	NSString *inAction = [inArguments objectAtIndex:0];
	//NSString *inSiftInfo = [inArguments objectAtIndex:1];
	NSString *inData = [inArguments objectAtIndex:2];
	ACENSLog(@"[EUExWidget loadApp],%@",inAction);
	if ([inAction isEqualToString:@""]||inAction==nil) {
		if ([inData hasPrefix:@"http://"]) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:inData]];
		}else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:inData]];
			[self jsFailedWithOpId:0 errorCode:1220501 errorDes:UEX_ERROR_DESCRIBE_ARGS];
		}

	}else {
		NSURL *url = [NSURL URLWithString:inAction];
		 if ([[UIApplication sharedApplication] canOpenURL:url]) {
			 ACENSLog(@"url = %@",url);
			[[UIApplication sharedApplication] openURL:url];
		 }
	}
}

-(void)checkUpdate:(NSMutableArray *)inArguments {
	if (meBrwView.mwWgt.ver && meBrwView.mwWgt.appId) {
		[NSThread detachNewThreadSelector:@selector(checkUpdateWgt:) toTarget:self withObject:(id)meBrwView.mwWgt];
	}else {
		NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UEX_JVParametersError] forKey:UEX_JKRESULT];
		[self jsSuccessWithName:@"uexWidget.cbCheckUpdate" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[tmpDict JSONFragment]];
		//[self jsFailedWithOpId:0 errorCode:0 errorDes:@"check update error"];
	}
}
-(void)checkMAMUpdate:(NSMutableArray *)inArguments{
    Class analysisClass =  NSClassFromString(@"AppCanAnalysis");//判断类是否存在，如果存在子widget上报
    if (analysisClass) {
        NSString *inKey=[BUtility appKey];
//        [[AppCanAnalysis ACInstance] startWithAppKey:inKey];
        id analysisObject = class_createInstance(analysisClass,0);
        objc_msgSend(analysisObject, @selector(startWithAppKey:),inKey);//
    }
}
-(void)checkUpdateWgt:(id)userInfo{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	WWidget *wgtObj =(WWidget*)userInfo;
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
	WWidgetMgr *wgtMgrObj = [[WWidgetMgr alloc]init];
	NSMutableDictionary *updateDict = [wgtMgrObj wgtUpdate:wgtObj];
	//
	[wgtMgrObj release];
	int statusCode = [[updateDict objectForKey:@"statusCode"] intValue];
	if(statusCode ==200 &&[updateDict count]==1) {
		[dict setObject:[NSNumber numberWithInt:UEX_JVNoUpdate] forKey:UEX_JKRESULT];
	}else if (statusCode ==200 && [updateDict count]>1) {
		[dict setObject:[NSNumber numberWithInt:UEX_JVUpdate] forKey:UEX_JKRESULT];
		if ([updateDict objectForKey:@"updateFileName"]) {
			[dict setObject:[updateDict objectForKey:@"updateFileName"] forKey:UEX_JKNAME];
		}
		if ([updateDict objectForKey:@"updateFileUrl"]) {
			[dict setObject:[updateDict objectForKey:@"updateFileUrl"] forKey:UEX_JKURL];
		}
		if ([updateDict objectForKey:@"fileSize"]) {
			[dict setObject:[updateDict objectForKey:@"fileSize"] forKey:UEX_JKSIZE];
		}
		if ([updateDict objectForKey:@"version"]) {
			[dict setObject:[updateDict objectForKey:@"version"] forKey:UEX_JKVERSION];
		}
	}else {
		[dict setObject:[NSNumber numberWithInt:UEX_JVError] forKey:UEX_JKRESULT];

	}
	NSString *jsonStr = [dict JSONFragment];
	//[dict release];
	[self performSelectorOnMainThread:@selector(updateCallBack:) withObject:(id)jsonStr waitUntilDone:NO];
	[pool release];
	//[NSThread exit];
}

-(void)updateCallBack:(id)userInfo{
	NSString *jsonStr = (NSString*)userInfo;
	ACENSLog(@"jsonstr=%@",jsonStr);
	[self jsSuccessWithName:@"uexWidget.cbCheckUpdate" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
	//NSMutableDictionary *dict =(NSMutableDictionary*)userInfo;
	//[meBrwView.meUExManager processCallbackResult:dict];
}

-(void)setPushNotifyCallback:(NSMutableArray *)inArguments {
//	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
	if (eBrwWndContainer) {
		eBrwWndContainer.mPushNotifyBrwViewName = meBrwView.muexObjName;
		eBrwWndContainer.mPushNotifyCallback = [inArguments objectAtIndex:0];
	}
}

-(void)getPushInfo:(NSMutableArray *)inArguments {
	//NSLog(@"getPushInfo");
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id pushStr = [defaults objectForKey:@"pushData"];
    if ([pushStr isKindOfClass:[NSDictionary class]]) {
        ACENSLog(@"pushstr is NSDictionary");
        NSString *str = [pushStr JSONFragment];
        [self jsSuccessWithName:@"uexWidget.cbGetPushInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:str];
        [defaults removeObjectForKey:@"pushData"];
        if (str== nil
            || [str isEqualToString:@"(null)"]) {
            return;
        }
    }else  {
        ACENSLog(@"pushstr is NSString");
        NSString *str =[NSString stringWithFormat:@"%@",pushStr];
        [self jsSuccessWithName:@"uexWidget.cbGetPushInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:str];
        [defaults removeObjectForKey:@"pushData"];
        if (str== nil
            || [str isEqualToString:@"(null)"]) {
            return;
        }
    }
    ACENSLog(@"pushstr = %@",pushStr);
    if (pushStr) {
        ACENSLog(@"invoke sendReportRead");
        [NSThread detachNewThreadSelector:@selector(sendReportRead:) toTarget:self withObject:(id)pushStr];
    }
    ACENSLog(@"getPushInfo end");
}
-(void)sendReportRead:(id)userInfo
{
    ACENSLog(@"sendReportRead start");
    @autoreleasepool {
        NSDictionary *dict = (NSDictionary*)[userInfo objectFromJSONString];
        
        if (dict == nil
            || [dict count] == 0) {
            return;
        }
        Class analysisClass = NSClassFromString(@"AppCanAnalysis");
        if (analysisClass) {
            NSString *softToken = [EUtility md5SoftToken];
            //线程处理
            NSString *urlStr =[NSString stringWithFormat:@"%@/report",theApp.useBindUserPushURL];
            NSURL *requestUrl = [NSURL URLWithString:urlStr];
            ACENSLog(@"sendReportRead =%@",requestUrl);


            NSMutableDictionary * postData = [NSMutableDictionary dictionaryWithCapacity:4];
            NSString *msgId = [dict objectForKey:@"msgId"];
            if (msgId == nil
                || msgId.length == 0) {
                return;
            }
            ACENSLog(@"sendReportRead after requestUrl=%@",requestUrl);
            [postData setObject:[dict objectForKey:@"msgId"] forKey:@"msgId"];
            [postData setObject:softToken forKey:@"softtoken"];
            [postData setObject:@"open" forKey:@"eventType"];
            NSDate *datenow = [NSDate date];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            SecCertificateRef certChain=NULL;
            NSData *PKCS12Data = [NSData dataWithContentsOfFile:[BUtility clientCertficatePath]];
            [BUtility extractIdentity:theApp.useCertificatePassWord andIdentity:&identity andTrust:&trust  andCertChain:&certChain fromPKCS12Data:PKCS12Data];
            
             ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
            [request setRequestMethod:@"POST"];
            [request setPostValue:[dict objectForKey:@"msgId"] forKey:@"msgId"];
            [request setPostValue:softToken forKey:@"softToken"];
            [request setPostValue:@"open" forKey:@"eventType"];
            [request setPostValue:timeSp forKey:@"occuredAt"];
            if (theApp.useCertificateControl) {
                [request setValidatesSecureCertificate:YES];
                [request setClientCertificateIdentity:identity];
            }else{
                [request setValidatesSecureCertificate:NO];
            }
            [request setTimeOutSeconds:60];
            [request startSynchronous];
            int status = request.responseStatusCode;
            if (status == 200) {
                NSError *error = request.error;
                if (!error) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //清除push消息
                    [defaults removeObjectForKey:@"pushData"];
                }
            }
            [request release];
        }
    }
}
-(void)setPushInfo:(NSMutableArray *)inArguments {
    NSString *uId = [inArguments objectAtIndex:0];
    NSString *uNickName =[inArguments objectAtIndex:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults objectForKey:@"deviceToken"];
    ACENSLog(@"uid=%@, unickName=%@,deviceToken=%@",uId,uNickName,deviceToken);
    if (deviceToken && ![deviceToken isEqualToString:@"(null)"]) {
        NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:uId,@"uId",uNickName,@"uNickName",deviceToken,@"deviceToken", nil];
        [NSThread detachNewThreadSelector:@selector(sendPushUserMsg:) toTarget:self withObject:(id)userDict];
    }
 
}
-(void)delPushInfo:(NSMutableArray *)inArguments {
    @autoreleasepool {
        NSString *softToken = [EUtility md5SoftToken];
        NSString *urlStr = [NSString stringWithFormat:@"%@msg/%@/unBindUser",theApp.useBindUserPushURL,softToken];
        SecIdentityRef identity = NULL;
        SecTrustRef trust = NULL;
        SecCertificateRef certChain=NULL;
        NSData *PKCS12Data = [NSData dataWithContentsOfFile:[BUtility clientCertficatePath]];
        [BUtility extractIdentity:theApp.useCertificatePassWord andIdentity:&identity andTrust:&trust  andCertChain:&certChain fromPKCS12Data:PKCS12Data];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
        if (theApp.useCertificateControl) {
            [request setValidatesSecureCertificate:YES];
            [request setClientCertificateIdentity:identity];
        }else{
            [request setValidatesSecureCertificate:NO];
        }
        [request setTimeOutSeconds:60];
        [request setRequestMethod:@"POST"];
        [request startSynchronous];
        
        NSString *responseStr = [request responseString];
        [EUtility writeLog:[NSString stringWithFormat:@"responseStr------>>%@",responseStr]];
        if (200 == request.responseStatusCode) {
            NSString *responseStr = [request responseString];
            [EUtility writeLog:[NSString stringWithFormat:@"responseStr------>>%@",responseStr]];
        }else{
            [EUtility writeLog:[NSString stringWithFormat:@"responseStr------>>%@",request.error]];
        }
    }
}

-(void)sendPushUserMsg:(id)userInfo{
    @autoreleasepool {
        NSDictionary *dict = (NSDictionary*)userInfo;
        //
//        Class analysisClass = NSClassFromString(@"AppCanAnalysis");
//        if (analysisClass) {
            NSString *softToken = [EUtility md5SoftToken];
            NSString *appId = meBrwView.meBrwCtrler.mwWgtMgr.wMainWgt.appId;
            NSString *urlStr = [NSString stringWithFormat:@"%@msg/%@/bindUser",theApp.useBindUserPushURL,softToken];
            ACENSLog(@"usrStr=%@",urlStr);
            
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            SecCertificateRef certChain=NULL;
            NSData *PKCS12Data = [NSData dataWithContentsOfFile:[BUtility clientCertficatePath]];
            [BUtility extractIdentity:theApp.useCertificatePassWord andIdentity:&identity andTrust:&trust  andCertChain:&certChain fromPKCS12Data:PKCS12Data];
            
            
            ASIFormDataRequest *FormatReq =[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
            [FormatReq setPostValue:[dict objectForKey:@"uId"] forKey:@"userId"];
            [FormatReq setPostValue:[dict objectForKey:@"uNickName"] forKey:@"userNick"];
            [FormatReq setPostValue:[dict objectForKey:@"deviceToken"] forKey:@"deviceToken"];
            [FormatReq setPostValue:softToken forKey:@"softToken"];
            [FormatReq setPostValue:appId forKey:@"appId"];
            [FormatReq setPostValue:[NSNumber numberWithInt:0] forKey:@"platform"];
            if (theApp.useCertificateControl) {
                [FormatReq setValidatesSecureCertificate:YES];
                [FormatReq setClientCertificateIdentity:identity];
            }else{
                [FormatReq setValidatesSecureCertificate:NO];
            }
            [FormatReq setTimeOutSeconds:60];
            [FormatReq startSynchronous];
            int status = [FormatReq responseStatusCode];
            NSString *responseStr = [FormatReq responseString];

            [FormatReq release];
//        }
    }
}
-(void)setPushState:(NSMutableArray*)inArguments{
    int isPush =[[inArguments objectAtIndex:0] intValue];
    ACENSLog(@"isPush=%d",isPush);
    if (isPush==1) {
        if (isSysVersionAbove8_0) {
#ifdef __IPHONE_8_0
            UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
            //注册推送
            [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
        }else{
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
        }
    }
    else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}
-(void)getPushState:(NSMutableArray*)inArguments{
    
    BOOL pushState = NO;
    
    if (isSysVersionAbove8_0) {
        
        pushState = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    }
    else{
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        pushState = type;
    }
    
    if (pushState == NO) {
        //0 关闭的
        [self jsSuccessWithName:@"uexWidget.cbGetPushState" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:0];
    }else{
        //1 开启的
        [self jsSuccessWithName:@"uexWidget.cbGetPushState" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
    }
    
}

-(void)setSpaceEnable:(NSMutableArray *)inArguments{
    
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    if (!eBrwMainFrm.meBrwToolBar) {
        EBrowserController *eInBrwCtrler = meBrwView.meBrwCtrler;
        EBrowserToolBar *ebrowserToolBar =[[EBrowserToolBar alloc] initWithFrame:CGRectMake(BOTTOM_LOCATION_VERTICAL_X,BOTTOM_LOCATION_VERTICAL_Y, BOTTOM_VIEW_WIDTH,BOTTOM_VIEW_HEIGHT) BrwCtrler:eInBrwCtrler];
        [eBrwMainFrm addSubview:ebrowserToolBar];
        ebrowserToolBar.flag=1;
        [ebrowserToolBar release];
    }else{
        [eBrwMainFrm addSubview:eBrwMainFrm.meBrwToolBar];
        eBrwMainFrm.meBrwToolBar.flag=1;
    }
}

@end
