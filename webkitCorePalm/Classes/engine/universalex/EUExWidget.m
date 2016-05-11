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
#import "BAnimation.h"
#import "BUtility.h"
#import "JSON.h"
#import "EUExBaseDefine.h"
#import "ASIFormDataRequest.h"
#import "WidgetOneDelegate.h"
#import <Security/Security.h>
#import "BAnimation.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "JSONKit.h"
#import "EUtility.h"

#import "DataAnalysisInfo.h"
#import "ACEDrawerViewController.h"
#import "ACEEXTScope.h"
#import <CommonCrypto/CommonCrypto.h>
#import "ACEUtils.h"

#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"
#define KUEX_ISNSMutableArray(x) ([x isKindOfClass:[NSMutableArray class]] && [x count]>0)
#define KUEX_ISNSString(x) ([x isKindOfClass:[NSString class]] && (x.length>0) && ![x isEqual:@"(null)"])



#define UEX_WIDGET_STRING_VALUE(x) \
({\
NSString *result;\
id input = x;\
if ([input isKindOfClass:[NSNumber class]]) {\
    result = [(NSNumber *)input stringValue];\
}\
if ([input isKindOfClass:[NSString class]]) {\
    result = input;\
}\
if (!result) {\
    result = @"";\
}\
result;\
});


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
        exit(0);
    }
}

-(id)initWithBrwView:(EBrowserView *) eInBrwView {
    if (self = [super initWithBrwView:eInBrwView]) {
    }
    return self;
}

-(void)dealloc{
}

- (void)reloadWidgetByAppId:(NSMutableArray *)inArguments {
    
    if ([inArguments count] < 1) {
        
        return;
        
    }
    
    NSString * appId = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    
    EBrowserWidgetContainer * eBrwWgtContainer = self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    
    EBrowserWindowContainer * eBrwWndContainer = (EBrowserWindowContainer *)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:appId];
    
    
    if (eBrwWndContainer.mBrwWndDict) {
        
        NSArray * brwWndArray = [eBrwWndContainer.mBrwWndDict allValues];
        
        for (EBrowserWindow * brwWnd in brwWndArray) {
            
            if (brwWnd.mPopoverBrwViewDict) {
                
                NSArray * brwPopViews = [brwWnd.mPopoverBrwViewDict allValues];
                
                for (EBrowserView * brwView in brwPopViews) {
                    
                    [brwView reload];
                    
                }
                
            }
            
            if (brwWnd.meBrwView) {
                
                [brwWnd.meBrwView reload];
                
            }
            
            if (brwWnd.meTopSlibingBrwView) {
                
                [brwWnd.meTopSlibingBrwView reload];
                
            }
            
            if (brwWnd.meBottomSlibingBrwView) {
                
                [brwWnd.meBottomSlibingBrwView reload];
                
            }
            
        }
        
    }
    
}

-(void)setLogServerIp:(NSMutableArray *)inArguments {
    
    NSString * logServerIp = nil;
    NSString * isDebug = nil;
    
    if ([inArguments isKindOfClass:[NSArray class]] && [inArguments count] >= 2) {
        logServerIp = UEX_WIDGET_STRING_VALUE(inArguments[0]);
        isDebug = UEX_WIDGET_STRING_VALUE(inArguments[1]);
    }else {
        return;
    }
    
    WWidget *inCurWgt = self.meBrwView.mwWgt;
    inCurWgt.logServerIp = logServerIp;
    
    if ([isDebug isEqualToString:@"1"]) {
        inCurWgt.isDebug = YES;
    }else{
        inCurWgt.isDebug = NO;
    }
}

-(WWidget*)getStartWgtByAppId:(NSString*)inAppId{
    //	WWidget *inCurWgt = meBrwView.mwWgt;
    WWidgetMgr *wgtMgr = self.meBrwView.meBrwCtrler.mwWgtMgr;
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
    NSString *inAppId = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    NSString *inAnimiId = UEX_WIDGET_STRING_VALUE(inArguments[1]);
    NSString *inForRet = UEX_WIDGET_STRING_VALUE(inArguments[2]);
    NSString *inOpenerInfo = UEX_WIDGET_STRING_VALUE(inArguments[3]);
    NSString *inAnimiDuration = nil;
    NSString *inAppkey = nil;
    if ([inArguments count] >= 5) {
        inAnimiDuration = UEX_WIDGET_STRING_VALUE(inArguments[4]);
    }
    if ([inArguments count] >= 6) {
        inAppkey = UEX_WIDGET_STRING_VALUE(inArguments[5]);
    }
    if ((self.meBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) == F_EBRW_FLAG_WIDGET_IN_OPENING) {
        return;
    }
    EBrowserMainFrame *eBrwMainFrm = self.meBrwView.meBrwCtrler.meBrwMainFrm;
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
    if(inAppkey){
        wgtObj.appKey = inAppkey;
    }
    int mOrientaion =self.meBrwView.mwWgt.orientation;
    int subOrientation = wgtObj.orientation;
    
    theApp.drawerController.canRotate = YES;
    
    if (subOrientation == mOrientaion || subOrientation == 15) {
        
        //nothing
        
    } else if (subOrientation == 2 || subOrientation == 10) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",subOrientation] forKey:@"subwgtOrientaion"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeRight];

        
    } else if (subOrientation == 8) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",subOrientation] forKey:@"subwgtOrientaion"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
    } else if (subOrientation == 1 || subOrientation == 5) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",subOrientation] forKey:@"subwgtOrientaion"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationPortrait];
        
    } else if (subOrientation == 4) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",subOrientation] forKey:@"subwgtOrientaion"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    }
    
    theApp.drawerController.canRotate = NO;
    
    //ACENSLog(@"wgtObj retaincount=%d",[wgtObj retainCount]);
    if(wgtObj){
        self.meBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WIDGET_IN_OPENING;
        EBrowserWidgetContainer *eBrwWgtContainer = self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        //		EBrowserWindowContainer *eCurBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
        
        EBrowserWindowContainer *eCurBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.meBrwView];
        
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
            
            if ([BAnimation isMoveIn:animiId]) {
                [BAnimation doMoveInAnimition:eBrwWndContainer animiId:animiId animiTime:animiDuration];
            }else if ([BAnimation isPush:animiId]) {
                [BAnimation doPushAnimition:eBrwWndContainer animiId:animiId animiTime:animiDuration];
            }else {
                [BAnimation SwapAnimationWithView:eBrwWgtContainer AnimiId:animiId AnimiTime:animiDuration];
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
                self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag &= ~F_TOOLBAR_FLAG_FINISH_WIDGET;
            }
            if (self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter) {
                if (self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
                    [self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_SUCCESS retAppId:inAppId];
                }
            }
            self.meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WIDGET_IN_OPENING;
        } else {
            eBrwWndContainer = [[EBrowserWindowContainer alloc] initWithFrame:CGRectMake(0, 0, eBrwWgtContainer.bounds.size.width, eBrwWgtContainer.bounds.size.height) BrwCtrler:self.meBrwView.meBrwCtrler Wgt:wgtObj];
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
                [eBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:nil];
            }
            //[eBrwWndContainer release];// cui 20130603
        }
        [self jsSuccessWithName:@"uexWidget.cbStartWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:0];
        //子widget启动上报代码
        //    NSString *inKey=[BUtility appKey];
        Class  analysisClass =  NSClassFromString(@"UexDataAnalysisAppCanAnalysis");//判断类是否存在，如果存在子widget上报
        if (!analysisClass) {
            
            analysisClass =  NSClassFromString(@"AppCanAnalysis");
            
            if (!analysisClass) {
                
                return;
            }
        }

        
        //过滤掉无appkey的子应用上报(plugin类型)
        
        if (eBrwWndContainer.mwWgt.wgtType == F_WWIDGET_PLUGINWIDGET) return;
        
        if (!KUEX_ISNSString(inAppkey)) return;
        

        id analysisObject = [[analysisClass alloc]init];
        //id analysisObject = class_createInstance(analysisClass,0);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        ((void(*)(id, SEL,NSString*))objc_msgSend)(analysisObject, @selector(setAppChannel:),wgtObj.channelCode);
        
        ((void(*)(id, SEL,NSString*))objc_msgSend)(analysisObject, @selector(setAppId:),wgtObj.appId);
        
        ((void(*)(id, SEL,NSString*))objc_msgSend)(analysisObject, @selector(setAppVersion:),wgtObj.ver);
        
        ((void(*)(id, SEL,NSString*))objc_msgSend)(analysisObject, @selector(startWithChildAppKey:),inAppkey);//inKey  目前为主widget的AppKey，子widget没有
#pragma clang diagnostic pop
    } else {
        
        if (self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter) {
            if (self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
                [self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_NOT_EXIST retAppId:inAppId];

            }
        }
        [self jsSuccessWithName:@"uexWidget.cbStartWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:2];
    }
}

-(void)finishWidget:(NSMutableArray *)inArguments {
    
    NSString *inRet = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    NSString *appID = nil;
    
    //********************************************
    if ([inArguments count]>1&&[[inArguments objectAtIndex:1] length]>0) {
        
        appID = UEX_WIDGET_STRING_VALUE(inArguments[1]);
        
    }
    
    BOOL isWgtBG  = NO;
    
    if ([inArguments count]>2) {
        NSString * wgtBGStr = UEX_WIDGET_STRING_VALUE(inArguments[2]);
        if (wgtBGStr.length > 0) {
            isWgtBG = [[inArguments objectAtIndex:2] boolValue];
        }
    }
    //*******************************************
    
    NSString * mainwgtOrientation = [BUtility getMainWidgetConfigInterface];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",mainwgtOrientation] forKey:@"subwgtOrientaion"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
    
    int mOrientaion = [[BUtility getMainWidgetConfigInterface]intValue];
    int subOrientation =self.meBrwView.mwWgt.orientation;
    
    theApp.drawerController.canRotate = YES;
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    
    if (subOrientation == mOrientaion || mOrientaion == 15) {
        
        //nothing
        
    } else if (mOrientaion == 2 || mOrientaion == 10 ) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",mOrientaion] forKey:@"subwgtOrientaion"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeRight];
        
    } else if (mOrientaion == 8) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",mOrientaion] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeLeft];

        
    } else if (mOrientaion == 1 || mOrientaion == 5) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",mOrientaion] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationPortrait];

    } else if (mOrientaion == 4) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",mOrientaion] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        [BUtility rotateToOrientation:UIInterfaceOrientationPortraitUpsideDown];
    }
    theApp.drawerController.canRotate = NO;
    EBrowserWidgetContainer *eBrwWgtContainer = self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    EBrowserWindowContainer *eBrwWndContainer = nil;

    if (appID) {
        eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:appID];
    } else {
        //eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
        eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.meBrwView];
    }
    
    if (eBrwWndContainer.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {
        NSString * title = ACELocalized(UEX_EXITAPP_ALERT_TITLE);
        NSString * message = ACELocalized(UEX_EXITAPP_ALERT_MESSAGE);
        NSString * exit = ACELocalized(UEX_EXITAPP_ALERT_EXIT);
        NSString * cancel = ACELocalized(UEX_EXITAPP_ALERT_CANCLE);
        
        UIAlertView *widgetOneConfirmView = [[UIAlertView alloc]
                                             initWithTitle:title
                                             message:message
                                             delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:exit,cancel,nil];
        [widgetOneConfirmView show];
        return;
        
    }
    
    if (inRet && inRet.length != 0) {
        
        if (eBrwWndContainer.mOpenerForRet) {
            
            NSString *jsStr = [NSString stringWithFormat:@"if(%@!=null){%@('%@');}",eBrwWndContainer.mOpenerForRet,eBrwWndContainer.mOpenerForRet,inRet];
            
            [[eBrwWndContainer.meOpenerContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
            
        }
        
    }
    
    if (appID) {
        
        [eBrwWgtContainer.mBrwWndContainerDict removeObjectForKey:appID];
        
    } else {
        
        [eBrwWgtContainer.mBrwWndContainerDict removeObjectForKey:eBrwWndContainer.mwWgt.appId];
        
    }
    
    if (![BUtility getAppCanDevMode]) {
        
        if (eBrwWndContainer.meOpenerContainer.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {
            
            if (self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar) {
                
                self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = NO;
                
            }
            
        }
        
    }
    
    int animiId = [BAnimation ReverseAnimiId:eBrwWndContainer.mStartAnimiId];
    float duration = eBrwWndContainer.mStartAnimiDuration;
    
    if (isWgtBG) {
        
        if ([BAnimation isPush:animiId]) {
            
            [BAnimation doPushAnimition:eBrwWndContainer animiId:animiId animiTime:duration];
            
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
            
        } else {
            
            [BAnimation SwapAnimationWithView:eBrwWgtContainer AnimiId:animiId AnimiTime:duration];
            
        }
        
        WWidgetMgr *wgtMgr = self.meBrwView.meBrwCtrler.mwWgtMgr;
        
        WWidget *mainWgt=[wgtMgr mainWidget];
        
        EBrowserWidgetContainer *eBrwWgtContainer = self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
        EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:mainWgt.appId];
        
        [eBrwWgtContainer bringSubviewToFront:eBrwWndContainer];
        
        return;
        
    }
    
    if ([BAnimation isPush:animiId]) {
        
        [BAnimation doPushAnimition:eBrwWndContainer animiId:animiId animiTime:duration];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
        
    } else {
        
        [BAnimation SwapAnimationWithView:eBrwWgtContainer AnimiId:animiId AnimiTime:duration];
        
    }
    
    {
        
        for (EBrowserWindow * eBrwWnd in [eBrwWndContainer.mBrwWndDict allValues]) {
            [eBrwWnd clean];
            [self closeWindowAfterAnimation:eBrwWnd];
            if (eBrwWnd.superview) {
                [eBrwWnd removeFromSuperview];
            }
            
        }
        
        [eBrwWndContainer.mBrwWndDict removeAllObjects];
        
        [eBrwWndContainer removeFromSuperview];
    }
    
    
    
    if (eBrwWndContainer != eBrwWgtContainer.meRootBrwWndContainer) {
        
        self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag &= ~F_TOOLBAR_FLAG_FINISH_WIDGET;
        self.meBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = YES;
        
    }
    
    EBrowserWindow *eAboveWnd = [[eBrwWgtContainer aboveWindowContainer] aboveWindow];
    [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    
    if (self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter && self.meBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.sView.hidden == NO) {
        
        return;
        
    }
    if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
        
        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
        [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        
    }
    
}

- (void)closeWindowAfterAnimation:(EBrowserWindow*)brwWnd_ {
    NSString *fromViewName =nil;
    if (brwWnd_.meBrwView) {
        //[eBrwWnd.meBrwView clean];
        //8.7 data
        int type = brwWnd_.meBrwView.mwWgt.wgtType;
        fromViewName =[brwWnd_.meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:brwWnd_.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:fromViewName closeReason:0 appInfo:appInfo];
        if (brwWnd_.meBrwView.superview) {
            [brwWnd_.meBrwView removeFromSuperview];
        }
        [[self.meBrwView brwWidgetContainer] pushReuseBrwView:brwWnd_.meBrwView];
        
        brwWnd_.meBrwView = nil;
    }
    if (brwWnd_.meTopSlibingBrwView) {
        //[eBrwWnd.meTopSlibingBrwView clean];
        if (brwWnd_.meTopSlibingBrwView.superview) {
            [brwWnd_.meTopSlibingBrwView removeFromSuperview];
        }
        [[self.meBrwView brwWidgetContainer] pushReuseBrwView:brwWnd_.meTopSlibingBrwView];
        brwWnd_.meTopSlibingBrwView = nil;
    }
    if (brwWnd_.meBottomSlibingBrwView) {
        //[eBrwWnd.meBottomSlibingBrwView clean];
        if (brwWnd_.meBottomSlibingBrwView.superview) {
            [brwWnd_.meBottomSlibingBrwView removeFromSuperview];
        }
        [[self.meBrwView brwWidgetContainer] pushReuseBrwView:brwWnd_.meBottomSlibingBrwView];
        brwWnd_.meBottomSlibingBrwView = nil;
    }
    if (brwWnd_.mPopoverBrwViewDict) {
        NSArray *popViewArray = [brwWnd_.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            //[ePopView clean];
            if (ePopView.superview) {
                [ePopView removeFromSuperview];
            }
            //8.8 数据统计
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            
            [[self.meBrwView brwWidgetContainer] pushReuseBrwView:ePopView];
            [brwWnd_.mPopoverBrwViewDict removeAllObjects];
            brwWnd_.mPopoverBrwViewDict = nil;
        }
    }
    //
    if (brwWnd_.mMuiltPopoverDict)
    {
        NSArray * mulitPopArray = [brwWnd_.mMuiltPopoverDict allValues];
        for (UIView * multiPopover in mulitPopArray)
        {
            if (multiPopover.superview) {
                [multiPopover removeFromSuperview];
            }
        }
        [brwWnd_.mMuiltPopoverDict removeAllObjects];
        //        [brwWnd_.mMuiltPopoverDict release];
        brwWnd_.mMuiltPopoverDict = nil;
    }
    if (self.meBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView) {
        brwWnd_.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        self.meBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView.hidden = YES;
        [self.meBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
    }
    if ((brwWnd_.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
        if ((brwWnd_.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING) == F_EBRW_FLAG_WINDOW_IN_OPENING) {
            brwWnd_.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        }
    }
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)brwWnd_.superview;
    EBrowserWindow *eAboveWnd = [eBrwWndContainer aboveWindow];
    [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    
    int goType = eAboveWnd.meBrwView.mwWgt.wgtType;
    NSString *goViewName =[eAboveWnd.meBrwView.curUrl absoluteString];
    
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eAboveWnd.meBrwView.mwWgt];
    [BUtility setAppCanViewActive:goType opener:fromViewName name:goViewName openReason:1 mainWin:0 appInfo:appInfo];
    if (eAboveWnd.mPopoverBrwViewDict) {
        NSArray *popViewArray = [eAboveWnd.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            //[BUtility setAppCanViewBackground:type name:closeViewName closeReason:0];
            
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
        }
    }
    if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
        ACENSLog(@"openAdStr is %@",openAdStr);
        [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
    }
}



-(void)removeWidget:(NSMutableArray*)inArguments {
    NSString *inAppId = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    ACENSLog(@"[EUExWidget removeWidget]");
    if (!inAppId) {
        [self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
    }
    WWidgetMgr *wgtMgr = self.meBrwView.meBrwCtrler.mwWgtMgr;
    if ([inAppId isEqualToString:self.meBrwView.mwWgt.appId] == YES) {
        [wgtMgr removeWgtByAppId:inAppId];
        [self jsSuccessWithName:@"uexWidget.cbRemoveWidget" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
        return;
    }
    if (self.meBrwView.mwWgt.wgtType != F_WWIDGET_SPACEWIDGET && self.meBrwView.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
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
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)self.meBrwView.meBrwWnd.superview;
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.meBrwView];
    
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

- (void)loadApp:(NSMutableArray *)inArguments
{
    
    if ([inArguments count] < 1) {
        return;
    }
    
    NSString *inAction = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    NSURL *url = [NSURL URLWithString:inAction];
    BOOL openURL = [[UIApplication sharedApplication] openURL:url];
    if (!openURL && [inArguments count] > 1) {
        NSString *iTunesURL = UEX_WIDGET_STRING_VALUE(inArguments[1]);
        url = [NSURL URLWithString:iTunesURL];
        openURL = [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)checkUpdate:(NSMutableArray *)inArguments {
    if (self.meBrwView.mwWgt.ver && self.meBrwView.mwWgt.appId) {
        [NSThread detachNewThreadSelector:@selector(checkUpdateWgt:) toTarget:self withObject:(id)self.meBrwView.mwWgt];
    }else {
        NSDictionary *tmpDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UEX_JVParametersError] forKey:UEX_JKRESULT];
        [self jsSuccessWithName:@"uexWidget.cbCheckUpdate" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[tmpDict JSONFragment]];
        
    }
}
-(void)checkMAMUpdate:(NSMutableArray *)inArguments{
    
    Class  analysisClass =  NSClassFromString(@"UexDataAnalysisAppCanAnalysis");//判断类是否存在，如果存在子widget上报
    if (!analysisClass) {
        analysisClass =  NSClassFromString(@"AppCanAnalysis");
        if (!analysisClass) {
            return;
        }
    }
    NSString *inKey=[BUtility appKey];
    
    id analysisObject =  [[analysisClass alloc]init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ((void(*)(id, SEL,NSString*))objc_msgSend)(analysisObject, @selector(startWithAppKey:), inKey);
#pragma clang diagnostic pop

}
-(void)checkUpdateWgt:(id)userInfo{
    WWidget *wgtObj =(WWidget*)userInfo;
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
    WWidgetMgr *wgtMgrObj = [[WWidgetMgr alloc]init];
    NSMutableDictionary *updateDict = [wgtMgrObj wgtUpdate:wgtObj];
    //

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

    //[NSThread exit];
}

-(void)updateCallBack:(id)userInfo{
    NSString *jsonStr = (NSString*)userInfo;
    ACENSLog(@"jsonstr=%@",jsonStr);
    [self jsSuccessWithName:@"uexWidget.cbCheckUpdate" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:jsonStr];
    //NSMutableDictionary *dict =(NSMutableDictionary*)userInfo;

}

-(void)setPushNotifyCallback:(NSMutableArray *)inArguments {
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.meBrwView];
    if (eBrwWndContainer) {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setValue:self.meBrwView.muexObjName forKey:kUexPushNotifyBrwViewNameKey];
        NSString * funcName = UEX_WIDGET_STRING_VALUE(inArguments[0]);
        [defaults setValue:funcName forKey:kUexPushNotifyCallbackFunctionNameKey];
        [defaults synchronize];
    }
}

-(void)getPushInfo:(NSMutableArray *)inArguments {
    NSString *flag = @"0";
    if (KUEX_ISNSMutableArray(inArguments)) {
        flag = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"appcan--EUExWidget--getPushInfo--flag == %d",[flag intValue]);
    if ([flag intValue]!=0) {
        
        id pushStr = [defaults objectForKey:@"allPushData"];
        
        if ([pushStr isKindOfClass:[NSDictionary class]]) {
            
            NSString *str = [pushStr JSONFragment];
            NSLog(@"appcan--EUExWidget--getPushInfo--allPushStr(NSDictionary) == %@",str);
            if (KUEX_ISNSString(str)) {
                [self jsSuccessWithName:@"uexWidget.cbGetPushInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:str];
                [defaults removeObjectForKey:@"allPushData"];
            }
            if (str== nil
                || [str isEqualToString:@"(null)"]) {
                return;
            }
            
        } else {
            //ACENSLog(@"pushstr is NSString");
            NSString *str =[NSString stringWithFormat:@"%@",pushStr];
            NSLog(@"appcan--EUExWidget--getPushInfo--allPushStr(NSString) == %@",str);
            if (KUEX_ISNSString(str)) {
                [self jsSuccessWithName:@"uexWidget.cbGetPushInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:str];
                [defaults removeObjectForKey:@"allPushData"];
            }
            if (str== nil || [str isEqualToString:@"(null)"]) {
                
                return;
            }
        }
        if (pushStr) {
            [NSThread detachNewThreadSelector:@selector(sendReportRead:) toTarget:self withObject:(id)pushStr];
        }
        
    } else {
        
        id pushStr = [defaults objectForKey:@"pushData"];
        if ([pushStr isKindOfClass:[NSDictionary class]]) {
            NSString *str = [pushStr JSONFragment];
            if (KUEX_ISNSString(str)) {
                [self jsSuccessWithName:@"uexWidget.cbGetPushInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:str];
                [defaults removeObjectForKey:@"pushData"];
            }
            if (str== nil
                || [str isEqualToString:@"(null)"]) {
                return;
            }
        } else {
            NSLog(@"appcan--EUExWidget--getPushInfo--pushstr is NSString =%@",pushStr);
            NSString *str =[NSString stringWithFormat:@"%@",pushStr];
            if (KUEX_ISNSString(str)) {
                [self jsSuccessWithName:@"uexWidget.cbGetPushInfo" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:str];
                [defaults removeObjectForKey:@"pushData"];
            }
            if (str== nil || [str isEqualToString:@"(null)"]) {
                return;
            }
        }
        if (pushStr) {
            [NSThread detachNewThreadSelector:@selector(sendReportRead:) toTarget:self withObject:(id)pushStr];
        }
    }
}

- (void)sendReportRead:(id)userInfo
{
    @autoreleasepool {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
        if ([userInfo isKindOfClass:[NSDictionary class]]){
            dict = userInfo;
        } else {
            dict = [userInfo JSONValue];
        }
        
        if (dict == nil || [dict count] == 0) {
            
            return;
        }
        
        if ([dict objectForKey:@"taskId"]) {
            
            NSString *urlStr =[NSString stringWithFormat:@"%@4.0/count/%@",theApp.useBindUserPushURL, [dict objectForKey:@"taskId"]];
            NSLog(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->urlStr = %@",urlStr);
            
            NSURL *requestUrl = [NSURL URLWithString:urlStr];
            
            NSString *appid = theApp.mwWgtMgr.mainWidget.appId?theApp.mwWgtMgr.mainWidget.appId:@"";
            
            NSString *appkey = [BUtility appKey];
            
            if (!appkey) {
                
                appkey = @"";
            }
            
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
            
            if (!deviceToken) {
                
                deviceToken = @"";
            }
            //住户ID tenantId
            NSString *tenantId = nil;
            
            if ([dict objectForKey:@"tenantId"]) {
                
                tenantId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"tenantId"]];
            }
            
            NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
            
            NSString *varifyAppStr = [BUtility getVarifyAppMd5Code:appid AppKey:appkey time:time];
            
            NSMutableDictionary *headerDict = [NSMutableDictionary dictionaryWithObject:varifyAppStr forKey:@"appverify"];
            [headerDict setObject:@"application/json" forKey:@"Content-Type"];
            
            NSString *masAppId = [NSString stringWithFormat:@"%@", appid];
            
            if (tenantId && tenantId.length > 0) {
                
                masAppId = [NSString stringWithFormat:@"%@:%@",tenantId, appid];
                
            }
            [headerDict setObject:masAppId forKey:@"x-mas-app-id"];
            NSMutableDictionary *bodyDict = [NSMutableDictionary dictionaryWithCapacity:5];
            [bodyDict setObject:@"1" forKey:@"count"];
            [bodyDict setObject:deviceToken forKey:@"deviceToken"];
            
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:requestUrl];
            [request setRequestMethod:@"POST"];
            [request setRequestHeaders:headerDict];
            [request setPostBody:(NSMutableData *)[[bodyDict JSONFragment] dataUsingEncoding:NSUTF8StringEncoding]];
            
            if (theApp.useCertificateControl) {
                
                SecIdentityRef identity = NULL;
                SecTrustRef trust = NULL;
                SecCertificateRef certChain = NULL;
                NSData *PKCS12Data = [NSData dataWithContentsOfFile:[BUtility clientCertficatePath]];
                [BUtility extractIdentity:theApp.useCertificatePassWord andIdentity:&identity andTrust:&trust andCertChain:&certChain fromPKCS12Data:PKCS12Data];
                
                [request setClientCertificateIdentity:identity];
            }
            
            if (theApp.validatesSecureCertificate) {
                
                [request setValidatesSecureCertificate:YES];
                
            } else {
                
                [request setValidatesSecureCertificate:NO];
            }
            
            [request setTimeOutSeconds:60];
            @weakify(request);
            [request setCompletionBlock:^{
                @strongify(request);
                if (200 == request.responseStatusCode) {
                    
                    NSLog(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->request.responseString is %@",request.responseString);
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //清除push消息
                    [defaults removeObjectForKey:@"pushData"];
                    [defaults removeObjectForKey:@"allPushData"];
                    [defaults synchronize];
                    
                } else {
                    
                    NSLog(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->request.responseStatusCode is %d--->[request error] = %@",request.responseStatusCode, [request error]);
                    
                }
            }];
            [request setFailedBlock:^{
                 @strongify(request);
                NSLog(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->setFailedBlock-->error is %@",[request error]);
                
            }];
            
            [request startAsynchronous];
        }
        
        Class analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
        if (!analysisClass) {
            
            analysisClass = NSClassFromString(@"AppCanAnalysis");
            
            if (!analysisClass) {
                
                return;
            }
            
        }
        NSString *softToken = [EUtility md5SoftToken];
        //线程处理
        NSString *urlStr =[NSString stringWithFormat:@"%@/report",theApp.useBindUserPushURL];
        NSURL *requestUrl = [NSURL URLWithString:urlStr];
        
        NSMutableDictionary * postData = [NSMutableDictionary dictionaryWithCapacity:4];
        NSString *msgId = [dict objectForKey:@"msgId"];
        
        if (msgId == nil || msgId.length == 0) {
            
            return;
        }
        
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
            
            [request setClientCertificateIdentity:identity];
            
        }else{
            
            [request setClientCertificateIdentity:nil];
        }
        
        if (theApp.validatesSecureCertificate) {
            
            [request setValidatesSecureCertificate:YES];
            
        } else {
            
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
                [defaults removeObjectForKey:@"allPushData"];
            }
        }

        
    }
}

-(void)setPushInfo:(NSMutableArray *)inArguments {
    
    if ([inArguments count] < 2) {
        return;
    }
    
    NSString *uId = UEX_WIDGET_STRING_VALUE(inArguments[0]);
    NSString *uNickName =UEX_WIDGET_STRING_VALUE(inArguments[1]);
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
        if (200 == request.responseStatusCode) {
            NSString *responseStr = [request responseString];
            [EUtility writeLog:[NSString stringWithFormat:@"responseStr------>>%@",responseStr]];
        }else{
            
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
        NSString *appId = self.meBrwView.meBrwCtrler.mwWgtMgr.wMainWgt.appId;
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
        /*
        int status = [FormatReq responseStatusCode];
        NSString *responseStr = [FormatReq responseString];
         */
    }
}
-(void)setPushState:(NSMutableArray*)inArguments{
    int isPush =[[inArguments objectAtIndex:0] intValue];
    ACENSLog(@"isPush=%d",isPush);
    [BUtility writeLog:[NSString stringWithFormat:@"-----setPushState------>>,theApp.usePushControl==%d",theApp.usePushControl]];
    if(theApp.usePushControl == NO) {
        
        return;
    }
    
    if (isPush==1) {
        //if (isSysVersionAbove8_0) {
        if (ACE_iOSVersion >= 8.0) {
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
    
    if (ACE_iOSVersion >= 8.0) {
        
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
    
    EBrowserMainFrame *eBrwMainFrm = self.meBrwView.meBrwCtrler.meBrwMainFrm;
    if (!eBrwMainFrm.meBrwToolBar) {
        EBrowserController *eInBrwCtrler = self.meBrwView.meBrwCtrler;
        EBrowserToolBar *ebrowserToolBar =[[EBrowserToolBar alloc] initWithFrame:CGRectMake(BOTTOM_LOCATION_VERTICAL_X,BOTTOM_LOCATION_VERTICAL_Y, BOTTOM_VIEW_WIDTH,BOTTOM_VIEW_HEIGHT) BrwCtrler:eInBrwCtrler];
        [eBrwMainFrm addSubview:ebrowserToolBar];
        ebrowserToolBar.flag=1;

    }else{
        [eBrwMainFrm addSubview:eBrwMainFrm.meBrwToolBar];
        eBrwMainFrm.meBrwToolBar.flag=1;
    }
}
#pragma mark - isAppInstalled
//20150706 by lkl
-(NSNumber *)isAppInstalled:(NSMutableArray *)inArguments{
    if([inArguments count]<1){
        return @(NO);
    }
    id appData=[inArguments[0] JSONValue];
    if([appData isKindOfClass:[NSDictionary class]]&&[appData objectForKey:@"appData"]&&[[appData objectForKey:@"appData"] isKindOfClass:[NSString class]]){
        NSString *urlScheme =[appData objectForKey:@"appData"];
        BOOL isInstalled=[[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlScheme]];
        NSNumber *result = @(NO);

        if(isInstalled){
            result = @(YES);
        }
        NSDictionary *dict=[NSDictionary dictionaryWithObject:result forKey:@"installed"];
        NSString* jsStr=[NSString stringWithFormat:@"if(uexWidget.cbIsAppInstalled != null){uexWidget.cbIsAppInstalled('%@');}",[dict JSONFragment]];
        [EUtility brwView:self.meBrwView evaluateScript:jsStr];
        return result;
    }
    return @(NO);
}


@end
