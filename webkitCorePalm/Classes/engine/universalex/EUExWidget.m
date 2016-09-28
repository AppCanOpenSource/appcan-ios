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

#import <CommonCrypto/CommonCrypto.h>
#import <AppCanKit/ACEXTScope.h>
#import <AppCanKit/ACInvoker.h>
#import "ONOXMLElement+ACEConfigXML.h"
#import "ACEBaseDefine.h"



#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"




@interface EUExWidget()
@property (nonatomic,readonly)EBrowserView *EBrwView;
@end

@implementation EUExWidget

#pragma mark - EBrowserView Getter

- (EBrowserView *)EBrwView{
    id brwView = [self webViewEngine];
    BOOL isEBrowserView = [brwView isKindOfClass:[EBrowserView class]];
    NSAssert(isEBrowserView,@"uexWidget only use for EBrowserView *");
    return isEBrowserView ? brwView : nil;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    if (buttonIndex == 0) {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSError* err = nil;
        // clear contents of NSTemporaryDirectory
        NSString* tempDirectoryPath = NSTemporaryDirectory();
        NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
        NSString* fileName = nil;
        BOOL result;
        
        while ((fileName = [directoryEnumerator nextObject])) {
            NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
            result = [fileMgr removeItemAtPath:filePath error:&err];
            if (!result && err) {
                ACLogDebug(@"Failed to delete: %@ (error: %@)", filePath, err);
                
            }
        }
        exit(0);
    }
}
- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        
    }
    return self;
}



- (void)dealloc{
}

- (void)reloadWidgetByAppId:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *appId) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(appId);
    EBrowserWidgetContainer * eBrwWgtContainer = self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    EBrowserWindowContainer * eBrwWndContainer = [eBrwWgtContainer.mBrwWndContainerDict objectForKey:appId];
    if (eBrwWndContainer.mBrwWndDict) {
        NSArray * brwWndArray = [eBrwWndContainer.mBrwWndDict allValues];
        for (EBrowserWindow * brwWnd in brwWndArray) {
            NSArray * brwPopViews = [brwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView * brwView in brwPopViews) {
                [brwView reload];
            }
            [brwWnd.meBrwView reload];
            [brwWnd.meTopSlibingBrwView reload];
            [brwWnd.meBottomSlibingBrwView reload];
        }
    }
}

- (void)setLogServerIp:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *logServerIp,NSNumber *isDebug) = inArguments;
    WWidget *inCurWgt = self.EBrwView.mwWgt;
    if (logServerIp) {
        inCurWgt.logServerIp = logServerIp;
    }
    if (isDebug) {
        inCurWgt.isDebug = isDebug.boolValue;
    }
    
}

- (WWidget*)getStartWgtByAppId:(NSString*)inAppId{
    WWidgetMgr *wgtMgr = self.EBrwView.meBrwCtrler.mwWgtMgr;
    WWidget * mainWgt = [wgtMgr mainWidget];
    WWidget *startWgt = nil;
    startWgt = (WWidget*)[wgtMgr wgtPluginDataByAppId:inAppId curWgt:mainWgt];
    //plugin
    if (startWgt) {
        return startWgt;
    }
    
    startWgt = [wgtMgr wgtDataByAppId:inAppId];
    
    return startWgt;
}
- (void)startWidget:(NSMutableArray *)inArguments {
    if ((self.EBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WIDGET_IN_OPENING) == F_EBRW_FLAG_WIDGET_IN_OPENING) {
        return;
    }
    
    ACArgsUnpack(NSString *inAppId,NSNumber *inAnimiId,NSString *inForRet,NSString *inOpenerInfo,NSNumber *inAnimiDuration,NSString *inAppkey) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inAppId = stringArg(info[@"appId"]);
        inAnimiId = numberArg(info[@"animId"]);
        inForRet = stringArg(info[@"funcName"]);
        inOpenerInfo = stringArg(info[@"info"]);
        inAnimiDuration = numberArg(info[@"animDuration"]);
        inAppkey = stringArg(info[@"appKey"]);
    }
    ACJSFunctionRef *cb = JSFunctionArg(inArguments.lastObject);
    
    __block NSNumber *startWidgetResult = @1;
    __block UEX_ERROR err = kUexNoError;
    @onExit{
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbStartWidget" arguments:ACArgsPack(@0,@2,startWidgetResult)];
        [cb executeWithArguments:ACArgsPack(err)];
    };
    
    UEX_PARAM_GUARD_NOT_NIL(inAppId);
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        [eBrwMainFrm invalidateAdTimers];
    }
    WWidget *wgtObj = [self getStartWgtByAppId:inAppId];
    if (!wgtObj) {//
        err = uexErrorMake(1,@"inAppId对应的widget未找到");
        return;
    }
    int animiId = inAnimiId.intValue;
    NSTimeInterval animiDuration = 0.2f;
    if (inAnimiDuration && inAnimiDuration.floatValue > 0) {
        animiDuration = inAnimiDuration.floatValue / 1000;
    }
    
    if(inAppkey){
        wgtObj.appKey = inAppkey;
    }
    int mOrientaion =self.EBrwView.mwWgt.orientation;
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

    self.EBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WIDGET_IN_OPENING;
    EBrowserWidgetContainer *eBrwWgtContainer = self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    EBrowserWindowContainer *eCurBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:inAppId];
    if (eBrwWndContainer) {
        eBrwWndContainer.mStartAnimiId = animiId;
        eBrwWndContainer.mStartAnimiDuration = animiDuration;
        eBrwWndContainer.meOpenerContainer = eCurBrwWndContainer;
        eBrwWndContainer.mOpenerForRet = inForRet;
        eBrwWndContainer.mOpenerInfo = inOpenerInfo;
        [eBrwWgtContainer bringSubviewToFront:eBrwWndContainer];
        
        if ([BAnimation isMoveIn:animiId]) {
            [BAnimation doMoveInAnimition:eBrwWndContainer animiId:animiId animiTime:animiDuration];
        }else if ([BAnimation isPush:animiId]) {
            [BAnimation doPushAnimition:eBrwWndContainer animiId:animiId animiTime:animiDuration];
        }else {
            [BAnimation SwapAnimationWithView:eBrwWgtContainer AnimiId:animiId AnimiTime:animiDuration];
        }
        
        
        [[eCurBrwWndContainer aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        
        EBrowserWindow *eAboveWnd = [eBrwWndContainer aboveWindow];
        [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
            [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
        if (eBrwWgtContainer.meRootBrwWndContainer == eBrwWndContainer) {
            self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag &= ~F_TOOLBAR_FLAG_FINISH_WIDGET;
        }
        if (self.EBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter) {
            if (self.EBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.startWgtShowLoading) {
                [self.EBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter hideLoading:WIDGET_START_SUCCESS retAppId:inAppId];
            }
        }
        self.EBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WIDGET_IN_OPENING;
    } else {
        eBrwWndContainer = [[EBrowserWindowContainer alloc] initWithFrame:CGRectMake(0, 0, eBrwWgtContainer.bounds.size.width, eBrwWgtContainer.bounds.size.height) BrwCtrler:self.EBrwView.meBrwCtrler Wgt:wgtObj];
        eBrwWndContainer.mStartAnimiId = animiId;
        eBrwWndContainer.mStartAnimiDuration = animiDuration;
        eBrwWndContainer.meOpenerContainer = eCurBrwWndContainer;
        eBrwWndContainer.mOpenerForRet = inForRet;
        eBrwWndContainer.mOpenerInfo = inOpenerInfo;
        [eBrwWgtContainer.mBrwWndContainerDict setObject:eBrwWndContainer forKey:inAppId];
        if ([inAppId isEqualToString:@"9999997"] || [inAppId isEqualToString:@"9999998"]) {
            [eBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:inOpenerInfo];
        } else {
            [eBrwWndContainer.meRootBrwWnd.meBrwView loadWidgetWithQuery:nil];
        }
    }
    startWidgetResult = @0;
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
    if (eBrwWndContainer.mwWgt.wgtType == F_WWIDGET_PLUGINWIDGET || !inAppkey || inAppkey.length == 0) {
        return;
    }
    id analysisObject = [[analysisClass alloc] init];

    [analysisObject ac_invoke:@"setAppChannel:" arguments:ACArgsPack(wgtObj.channelCode)];
    [analysisObject ac_invoke:@"setAppId:" arguments:ACArgsPack(wgtObj.appId)];
    [analysisObject ac_invoke:@"setWidgetVersion:" arguments:ACArgsPack(wgtObj.ver)];
    [analysisObject ac_invoke:@"startWithChildAppKey:" arguments:ACArgsPack(inAppkey)];
    
}

- (void)finishWidget:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(NSString *inRet,NSString *appID,NSNumber *useWgtBg) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inRet = stringArg(info[@"resultInfo"]);
        appID = stringArg(info[@"appId"]);
        useWgtBg = numberArg(info[@"finishMode"]);
    }
    BOOL isWgtBG  = useWgtBg.boolValue;
    
    NSString * mainwgtOrientation = [BUtility getMainWidgetConfigInterface];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",mainwgtOrientation] forKey:@"subwgtOrientaion"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
    int mOrientaion = [[BUtility getMainWidgetConfigInterface]intValue];
    
    int subOrientation =self.EBrwView.mwWgt.orientation;
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
    
    EBrowserWidgetContainer *eBrwWgtContainer = self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
    EBrowserWindowContainer *eBrwWndContainer = nil;
    
    if (appID) {
        eBrwWndContainer = (EBrowserWindowContainer*)[eBrwWgtContainer.mBrwWndContainerDict objectForKey:appID];
    } else {
        eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
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
            if (self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar) {
                self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = NO;
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
        WWidgetMgr *wgtMgr = self.EBrwView.meBrwCtrler.mwWgtMgr;
        WWidget *mainWgt=[wgtMgr mainWidget];
        EBrowserWidgetContainer *eBrwWgtContainer = self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer;
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
    
    
    
    for (EBrowserWindow * eBrwWnd in [eBrwWndContainer.mBrwWndDict allValues]) {
        [eBrwWnd clean];
        [self closeWindowAfterAnimation:eBrwWnd];
        if (eBrwWnd.superview) {
            [eBrwWnd removeFromSuperview];
        }
    }
    [eBrwWndContainer.mBrwWndDict removeAllObjects];
    [eBrwWndContainer removeFromSuperview];
    
    if (eBrwWndContainer != eBrwWgtContainer.meRootBrwWndContainer) {
        self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.mFlag &= ~F_TOOLBAR_FLAG_FINISH_WIDGET;
        self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = YES;
    }
    
    EBrowserWindow *eAboveWnd = [[eBrwWgtContainer aboveWindowContainer] aboveWindow];
    [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    if (self.EBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter && self.EBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter.sView.hidden == NO) {
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
        int type = brwWnd_.meBrwView.mwWgt.wgtType;
        fromViewName =[brwWnd_.meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:brwWnd_.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:fromViewName closeReason:0 appInfo:appInfo];
        if (brwWnd_.meBrwView.superview) {
            [brwWnd_.meBrwView removeFromSuperview];
        }
        brwWnd_.meBrwView = nil;
    }
    
    [brwWnd_.meTopSlibingBrwView removeFromSuperview];
    brwWnd_.meTopSlibingBrwView = nil;
    [brwWnd_.meBottomSlibingBrwView removeFromSuperview];
    brwWnd_.meBottomSlibingBrwView = nil;
    
    
    NSArray *popViewArray = [brwWnd_.mPopoverBrwViewDict allValues];
    for (EBrowserView *ePopView in popViewArray) {
        [ePopView removeFromSuperview];
        int type = ePopView.mwWgt.wgtType;
        NSString *viewName = [ePopView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
        [[self.EBrwView brwWidgetContainer] pushReuseBrwView:ePopView];
        [brwWnd_.mPopoverBrwViewDict removeAllObjects];
        brwWnd_.mPopoverBrwViewDict = nil;
    }
    
    //
    
    NSArray * mulitPopArray = [brwWnd_.mMuiltPopoverDict allValues];
    for (UIView * multiPopover in mulitPopArray){
        [multiPopover removeFromSuperview];
    }
    [brwWnd_.mMuiltPopoverDict removeAllObjects];
    brwWnd_.mMuiltPopoverDict = nil;
    
    if (self.EBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView) {
        brwWnd_.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        self.EBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView.hidden = YES;
        [self.EBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
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
            int type = ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
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



- (UEX_BOOL)removeWidget:(NSMutableArray*)inArguments {
    
    __block NSNumber *removeWidgetResult = @1;
    @onExit{
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbRemoveWidget" arguments:ACArgsPack(@0,@2,removeWidgetResult)];
    };
    ACArgsUnpack(NSString *inAppId) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inAppId,UEX_FALSE);
    
    WWidgetMgr *wgtMgr = self.EBrwView.meBrwCtrler.mwWgtMgr;
    if ([inAppId isEqualToString:self.EBrwView.mwWgt.appId]) {
        [wgtMgr removeWgtByAppId:inAppId];
        removeWidgetResult = @0;
        return UEX_TRUE;
    }
    if (self.EBrwView.mwWgt.wgtType != F_WWIDGET_SPACEWIDGET && self.EBrwView.mwWgt.wgtType != F_WWIDGET_MAINWIDGET) {
        return UEX_FALSE;
    }
    if([wgtMgr removeWgtByAppId:inAppId]){
        removeWidgetResult = @0;
        return UEX_TRUE;
    }
    return UEX_FALSE;
    
}
- (NSString *)getOpenerInfo:(NSMutableArray *)inArguments {
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    NSString *info = eBrwWndContainer.mOpenerInfo;
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbGetOpenerInfo" arguments:ACArgsPack(@0,@0,info)];
    return info;
}

- (void)setMySpaceInfoWithAnimiId:(NSString*)inAnimiId ForRet:(NSString*)inForRet OpenerInfo:(NSString*)inOpenerInfo {
    
}

- (UEX_BOOL)loadApp:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *inURL,NSString *anotherURL) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inURL,UEX_FALSE);
    
    NSURL *url = [NSURL URLWithString:inURL];
    BOOL openURL = [[UIApplication sharedApplication] openURL:url];
    if (!openURL && anotherURL) {
        url = [NSURL URLWithString:anotherURL];
        openURL = [[UIApplication sharedApplication] openURL:url];
    }
    return openURL ? UEX_TRUE : UEX_FALSE ;
}


- (void)checkMAMUpdate:(NSMutableArray *)inArguments{
    
    Class  analysisClass =  NSClassFromString(@"UexDataAnalysisAppCanAnalysis");//判断类是否存在，如果存在子widget上报
    if (!analysisClass) {
        analysisClass =  NSClassFromString(@"AppCanAnalysis");
        if (!analysisClass) {
            return;
        }
    }
    
    id analysisObject = [[analysisClass alloc] init];
    [analysisObject ac_invoke:@"startWithAppKey:" arguments:ACArgsPack([BUtility appKey])];
    
}

- (void)checkUpdate:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(ACJSFunctionRef *cb) = inArguments;
    
    void (^callback)(UEX_ERROR error,NSDictionary *data) = ^(UEX_ERROR error,NSDictionary *data){
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbCheckUpdate" arguments:ACArgsPack(@0,@1,data.ac_JSONFragment)];
        [cb executeWithArguments:ACArgsPack(error,data)];
        
    };
    WWidget *currentWidget = self.EBrwView.mwWgt;
    if (!currentWidget.ver || currentWidget.ver.length == 0 || !currentWidget.appId || currentWidget.appId == 0) {
        UEX_ERROR err = uexErrorMake(-1, @"当前widget信息缺失,不能进行更新");
        callback(err,nil);
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        WWidgetMgr *wgtMgrObj = [[WWidgetMgr alloc]init];
        NSMutableDictionary *updateDict = [wgtMgrObj wgtUpdate:currentWidget];
        
        NSInteger statusCode = [[updateDict objectForKey:@"statusCode"] integerValue];
        UEX_ERROR err = nil;
        if (statusCode == 200 && [updateDict count] > 1) {
            [dict setValue:@0 forKey:@"result"];
            [dict setValue:updateDict[@"updateFileName"] forKey:@"version"];
            [dict setValue:updateDict[@"updateFileUrl"] forKey:@"url"];
            [dict setValue:updateDict[@"fileSize"] forKey:@"size"];
            [dict setValue:updateDict[@"version"] forKey:@"version"];
        }else {
            [dict setValue:@1 forKey:@"result"];
            err = uexErrorMake(1,@"网络请求错误");
        }
        callback(err,dict);
    });
    
    
}



- (void)setPushNotifyCallback:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *funcName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(funcName);
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    if (eBrwWndContainer) {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setValue:self.EBrwView.muexObjName forKey:kUexPushNotifyBrwViewNameKey];
        [defaults setValue:funcName forKey:kUexPushNotifyCallbackFunctionNameKey];
        [defaults synchronize];
    }
}

- (NSString *)getPushInfo:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inFlag) = inArguments;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dataKey = @"pushData";
    if (inFlag.integerValue != 0) {
        dataKey = @"allPushData";
    }
    
    id pushData = [defaults objectForKey:dataKey];
    NSString *pushDataStr = nil;
    if ([pushData isKindOfClass:[NSDictionary class]]) {
        pushDataStr = [pushData ac_JSONFragment];
    }
    if ([pushData isKindOfClass:[NSString class]]) {
        pushDataStr = pushData;
    }
    if (pushDataStr) {
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbGetPushInfo" arguments:ACArgsPack(@0,@1,pushDataStr)];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self sendReportRead:pushDataStr];
        });
    }
    [defaults removeObjectForKey:dataKey];
    return pushDataStr;
}

- (void)sendReportRead:(NSString *)pushDataStr{
    @autoreleasepool {
        NSDictionary *dict = dictionaryArg(pushDataStr);
        if (!dict || [dict count] == 0) {
            return;
        }
        
        if ([dict objectForKey:@"taskId"]) {
            NSString *urlStr =[NSString stringWithFormat:@"%@4.0/count/%@",theApp.useBindUserPushURL, [dict objectForKey:@"taskId"]];
            NSURL *requestUrl = [NSURL URLWithString:urlStr];
            NSString *appid = theApp.mwWgtMgr.mainWidget.appId ?: @"";
            NSString *appkey = [BUtility appKey] ?: @"";
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] ?: @"";
            
            //住户ID tenantId
            NSString *tenantId = stringArg(dict[@"tenantId"]);
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
                    ACLogDebug(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->request.responseString is %@",request.responseString);
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    //清除push消息
                    [defaults removeObjectForKey:@"pushData"];
                    [defaults removeObjectForKey:@"allPushData"];
                    [defaults synchronize];
                } else {
                    ACLogDebug(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->request.responseStatusCode is %d--->[request error] = %@",request.responseStatusCode, [request error]);
                }
            }];
            [request setFailedBlock:^{
                @strongify(request);
                ACLogDebug(@"appcan-->Engine-->EUExWidget.m-->sendReportRead-->setFailedBlock-->error is %@",[request error]);
                
            }];
            [request startAsynchronous];
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

- (void)setPushInfo:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *uid,NSString *nickName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(uid);
    UEX_PARAM_GUARD_NOT_NIL(nickName);
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [defaults objectForKey:@"deviceToken"];
    
    if (deviceToken) {
        NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"uId",nickName,@"uNickName",deviceToken,@"deviceToken", nil];
        [NSThread detachNewThreadSelector:@selector(sendPushUserMsg:) toTarget:self withObject:(id)userDict];
    }
    
}
- (void)delPushInfo:(NSMutableArray *)inArguments {
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
        }
    }
}

- (void)sendPushUserMsg:(id)userInfo{
    @autoreleasepool {
        NSDictionary *dict = (NSDictionary*)userInfo;
        //
        //        Class analysisClass = NSClassFromString(@"AppCanAnalysis");
        //        if (analysisClass) {
        NSString *softToken = [EUtility md5SoftToken];
        NSString *appId = self.EBrwView.meBrwCtrler.mwWgtMgr.wMainWgt.appId;
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
    }
}
- (void)setPushState:(NSMutableArray*)inArguments{
    if(theApp.usePushControl == NO) {
        return;
    }
    ACArgsUnpack(NSNumber *shouldPush) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(shouldPush);
    
    [BUtility writeLog:[NSString stringWithFormat:@"-----setPushState------>>,theApp.usePushControl==%d",theApp.usePushControl]];
    
    
    if (shouldPush.boolValue) {
        UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
        //注册推送
        [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}
- (UEX_BOOL)getPushState:(NSMutableArray*)inArguments{
    BOOL pushState = NO;
    pushState = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
    NSNumber *result = pushState ? @0 : @1;
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbGetPushState" arguments:ACArgsPack(@0,@2,result)];
    return pushState ? UEX_TRUE : UEX_FALSE ;
}

- (void)setSpaceEnable:(NSMutableArray *)inArguments{
    
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (!eBrwMainFrm.meBrwToolBar) {
        EBrowserController *eInBrwCtrler = self.EBrwView.meBrwCtrler;
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
- (NSNumber *)isAppInstalled:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *appData = stringArg(info[@"appData"]);
    UEX_PARAM_GUARD_NOT_NIL(appData,@(NO));
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appData]];
    NSDictionary *resultDict = @{@"installed": isInstalled? @0 : @1};
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidget.cbIsAppInstalled" arguments:ACArgsPack(resultDict.ac_JSONFragment)];
    return isInstalled ? @0 : @1 ;
}

#pragma mark - closeLoading

- (void)closeLoading:(NSMutableArray *)inArguments{
    BOOL userCloseLoading = NO;
    ONOXMLElement *config = [ONOXMLElement ACEOriginConfigXML];
    ONOXMLElement *loadingConfig = [config firstChildWithTag:@"removeloading"];
    if (loadingConfig && [loadingConfig.stringValue isEqual:@"true"]) {
        userCloseLoading = YES;
    }
    if (userCloseLoading) {
        [self.EBrwView.meBrwCtrler handleLoadingImageCloseEvent:ACELoadingImageCloseEventWebViewFinishLoading];
    }
}

@end
