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

#import <CommonCrypto/CommonDigest.h>
#import "EUExWindow.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserController.h"
#import "EBrowser.h"
#import "BUtility.h"
#import "BUIAlertView.h"
#import "FileEncrypt.h"
#import "WWidget.h"
#import "EBrowserHistoryEntry.h"
#import "JSON.h"
#import "BAnimation.h"
#import "BToastView.h"
#import "EBrowserViewBounceView.h"
#import <QuartzCore/CALayer.h>
#import "WWidgetMgr.h"
#import "BStatusBarWindow.h"
#import "EUExBaseDefine.h"
#import "EBrowserViewAnimition.h"
#import "BAnimationTransform.h"
#import "ACEWebViewController.h"
#import "WidgetOneDelegate.h"
#import "ACEDrawerViewController.H"
#import "JSONKit.h"
#import "RESideMenu.h"
#import "UIViewController+RESideMenu.h"
#import "ACEUINavigationController.h"
#import "ACEPluginViewContainer.h"
#import "EUtility.h"
#import "DataAnalysisInfo.h"
#import "ACEBrowserView.h"

#import <AppCanKit/ACEXTScope.h>

#import "ACEMultiPopoverScrollView.h"
#import "ACEPOPAnimation.h"

#import "ACEProgressDialog.h"
#import "ACEBaseDefine.h"

#define kWindowConfirmViewTag (-9999)

#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"


#define AppRootLeftSlidingWinName  @"rootLeftSlidingWinName"
#define ApprootRightSlidingWinName @"rootRightSlidingWinName"




typedef NS_ENUM(NSInteger,ACEUexWindowSlibingType){
    ACEUexWindowSlibingTypeTop = 1,
    ACEUexWindowSlibingTypeBottom = 2,
};




//20151021 lkl 修复iOS 9 长按产生放大镜的问题
//长按事件阻碍选项
typedef NS_ENUM(NSInteger,ACEDisturbLongPressGestureStatus){
    ACEDisturbLongPressGestureNotDisturb =0,    //不阻碍长按事件
    ACEDisturbLongPressGestureDisturbNormally=1,//正常阻碍长按事件
    ACEDisturbLongPressGestureDisturbStrictly=2,//严格阻碍长按事件
};
//对于没有3DTouch功能的设备(非6s 6sP) 选择ACEDisturbLongPressGestureDisturbNormally阻止长按事件已经足够
//但对于6s/6sP 用力长按时(3D Touch longPress)仍然会触发放大镜
//设置CEDisturbLongPressGestureDisturbStrictly之后，可以阻止3D Touch longPress，但同时也会拦截网页的onclick事件，但ontouchend事件并不受影响
//所以如果需要使得6s/6sP也解决放大镜问题，设置此falg为CEDisturbLongPressGestureDisturbStrictly需要将网页内的所有onclick事件改为ontouchend，






typedef NS_OPTIONS(NSInteger, UexWindowOpenFlag){
    //普通window
    UexWindowOpenFlagNone                       = 0,
    //window将用于OAuth验证
    UexWindowOpenFlagOauth                      = 1 << 0,
    //window要加载的网页为加密的网页
    UexWindowOpenFlagObfuscation                = 1 << 1,
    //window无论是否已存在都将强行刷新页面
    UexWindowOpenFlagReload                     = 1 << 2,
    //window当中的任何url都将调用系统浏览打开
    UexWindowOpenFlagDisableCrossDomain         = 1 << 3,
    //window当中的view为不透明的
    UexWindowOpenFlagOpaque                     = 1 << 4,
    //window为隐藏的
    UexWindowOpenFlagHidden                     = 1 << 5,
    //window需要预加载popover
    UexWindowOpenFlagHasPreOpen                 = 1 << 6,
    //window支持手势缩放
    UexWindowOpenFlagEnableScale                = 1 << 7,
    //window支持侧滑关闭
    UexWindowOpenFlagEnableSwipeClose         = 1 << 10
    
};

typedef NS_ENUM(NSInteger,UexWindowOpenDataType){
    UexWindowOpenDataTypeURL = 0,
    UexWindowOpenDataTypeHTMLData,
    UexWindowOpenDataTypeURLAndHTMLData,
};





#define UEX_WINDOW_GUARD_USE_IN_WINDOW(returnValue)                             \
    if (!self.EBrwView || self.EBrwView.mType != ACEEBrowserViewTypeMain) {     \
        ACLogDebug(@"%@ must use in window",NSStringFromSelector(_cmd));        \
        return returnValue;                                                     \
    }
#define UEX_WINDOW_GUARD_USE_IN_POPOVER(returnValue)                            \
    if (!self.EBrwView || self.EBrwView.mType != ACEEBrowserViewTypePopover) {  \
        ACLogDebug(@"%@ must use in popover",NSStringFromSelector(_cmd));       \
        return returnValue;                                                     \
    }



#define UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER(returnValue)                     \
    if (self.EBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation ||   \
        self.EBrwView.meBrwWnd.webWindowType == ACEWebWindowTypePresent){       \
        ACLogDebug(@"%@ cannot use in controller",NSStringFromSelector(_cmd));  \
        return returnValue;                                                     \
    }

@interface EUExWindow()
@property (nonatomic,strong)UILongPressGestureRecognizer *longPressGestureDisturbRecognizer;
@property (nonatomic,strong)NSMutableDictionary *bounceParams;
@property (nonatomic,readonly)EBrowserView *EBrwView;

@property (nonatomic,strong)ACJSFunctionRef *confirmCB;
@property (nonatomic,strong)ACJSFunctionRef *promptCB;
@property (nonatomic,strong)ACJSFunctionRef *actionSheetCB;
@end


//默认动画时长 0.26s
static NSTimeInterval kDefaultAnimationDuration = 0.26;
static NSString *const kChannelNofitication = @"uexWindow.channelNofitication";
static NSString *const kGlobalNofitication = @"uexWindow.globalNofitication";
@implementation EScrollView



@end


@implementation EUExWindow

#pragma mark - Life Cycle

- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveGlobalNotification:) name: kGlobalNofitication object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveChannelNotification:) name:kChannelNofitication object:nil];
        self.notificationDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)clean {
    [_notificationDic removeAllObjects];
    _notificationDic = nil;
    self.mbAlertView = nil;
    self.mActionSheet = nil;
    self.mToastView = nil;
    self.mToastTimer = nil;
    self.meBrwAnimi = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self closeToast:nil];
    self.mbAlertView = nil;
    
}


- (void)dealloc{
    [self clean];
}
#pragma mark - Callback

- (void)callbackWithKeyPath:(NSString *)keyPath intData:(NSInteger)intData{
    [self.webViewEngine callbackWithFunctionKeyPath:keyPath arguments:ACArgsPack(@0,@2,@(intData))];
}
- (void)callbackWithKeyPath:(NSString *)keyPath strData:(NSString *)strData{
    [self.webViewEngine callbackWithFunctionKeyPath:keyPath arguments:ACArgsPack(@0,@0,strData)];
}

- (void)callbackWithKeyPath:(NSString *)keyPath jsonData:(NSString *)jsonData{
    [self.webViewEngine callbackWithFunctionKeyPath:keyPath arguments:ACArgsPack(@0,@1,jsonData)];
}

#pragma mark - Common Helper

static NSTimeInterval getAnimationDuration(NSNumber * durationMillSeconds){
    if (!durationMillSeconds) {
        return kDefaultAnimationDuration;
    }
    NSTimeInterval duration = durationMillSeconds.doubleValue / 1000;
    if (duration < 0) {
        duration = kDefaultAnimationDuration;
    }
    return duration;
}

- (NSURL *)parseWebviewURL:(NSString *)urlStr{
    NSString * absoluteURLString = nil;
    if ([urlStr hasPrefix:F_WGTROOT_PATH]) {
        absoluteURLString = [self.EBrwView.mwWgt.widgetPath stringByAppendingPathComponent:[urlStr substringFromIndex:[F_WGTROOT_PATH length]]];
        if (![absoluteURLString hasPrefix:@"file://"]) {
            absoluteURLString =[NSString stringWithFormat:@"file://%@", urlStr];
        }
    }else{
        absoluteURLString = [BUtility makeUrl:[self.EBrwView curUrl].absoluteString url:urlStr];
    }
    return [BUtility stringToUrl:absoluteURLString];
}


- (void)setExtraInfo:(NSDictionary *)extraDic toEBrowserView:(UIImageView *)inBrwView {
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
                    UIImage *image = [UIImage imageWithContentsOfFile:[self absPath:bgStr]];
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
}





#pragma mark - Data Analysis

- (void)reportWindowOpeningEventWithSourceWindow:(EBrowserWindow *)eCurBrwWnd newOpenedWindow:(EBrowserWindow *)eBrwWnd openedURL:(NSURL *)url{
    int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
    NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
    
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
    [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
    if (self.EBrwView.meBrwWnd.mPopoverBrwViewDict) {
        NSArray *popViewArray = [eCurBrwWnd.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
        }
    }
    int goType = eBrwWnd.meBrwView.mwWgt.wgtType;
    NSString *goViewName =[url absoluteString];
    {
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eBrwWnd.meBrwView.mwWgt];
        [BUtility setAppCanViewActive:goType opener:viewName name:goViewName openReason:0 mainWin:0 appInfo:appInfo];
    }
    if (eBrwWnd.mPopoverBrwViewDict) {
        NSArray *popViewArray = [eBrwWnd.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
        }
    }
}





#pragma mark - EBrowserView Getter

- (EBrowserView *)EBrwView{
    id brwView = [self webViewEngine];
    BOOL isEBrowserView = [brwView isKindOfClass:[EBrowserView class]];
    NSAssert(isEBrowserView,@"uexWindow only use for EBrowserView *");
    return isEBrowserView ? brwView : nil;
}

#pragma mark - Notification
#pragma mark UIDeviceOrientationDidChangeNotification

- (void)doRotate:(__unused id)notif{
    if (!self.EBrwView) {
        return;
    }
    CGRect rect;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
    float wndWidth = eBrwWnd.bounds.size.width;
    float wndHeight = eBrwWnd.bounds.size.height;
    
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (!self.mToastView || !(self.EBrwView.mwWgt.orientation & ace_interfaceOrientationFromUIDeviceOrientation(deviceOrientation))) {
        return;
    }
    
    if ([BUtility isIpad]) {
        rect = [BToastView viewRectWithPos:self.mToastView.mPos wndWidth:768 wndHeight:1004];
    } else {
        rect = [BToastView viewRectWithPos:self.mToastView.mPos wndWidth:wndWidth wndHeight:wndHeight];
    }
    [self.mToastView setFrame:rect];
    [self.mToastView setSubviewsFrame:rect];
}




#pragma mark - Open Window API

- (void)openPresentWindow:(NSMutableArray *)inArguments{
    if (self.EBrwView.hidden == YES) {
        return;
    }
    ACArgsUnpack(NSString * inWindowName,NSNumber * inDataType,NSString * inData,NSDictionary *extraInfo) = inArguments;
    if (inArguments.count > 8) {
        //for Android capability
        extraInfo = dictionaryArg(inArguments[8]) ?: extraInfo;
    }
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inWindowName = stringArg(info[@"name"]);
        inDataType = numberArg(info[@"data"]);
        inData = stringArg(info[@"data"]);
        extraInfo = dictionaryArg(info[@"extras"]);
    }
    
    
    UEX_PARAM_GUARD_NOT_NIL(inWindowName);
    UEX_PARAM_GUARD_NOT_NIL(inDataType);
    UEX_PARAM_GUARD_NOT_NIL(inData);
    
    [self openWindowControllerWithName:inWindowName
                                  data:inData
                              dataType:inDataType.integerValue
                            windowType:ACEWebWindowTypePresent
                             extraInfo:extraInfo];
}









- (void)openWindowControllerWithName:(NSString *)windowName
                                data:(NSString *)data
                            dataType:(UexWindowOpenDataType)dataType
                          windowType:(ACEWebWindowType)windowType
                           extraInfo:(NSDictionary *)extraInfo {
    
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = eCurBrwWnd.winContainer;
    EBrowserWindow *eBrwWnd =[[EBrowserWindow alloc]initWithFrame:eBrwWndContainer.bounds
                                                        BrwCtrler:self.EBrwView.meBrwCtrler
                                                              Wgt:self.EBrwView.mwWgt
                                                       UExObjName:windowName];
    
    
    [eBrwWndContainer removeFromWndDict:windowName];
    eBrwWnd.webWindowType = windowType;
    eBrwWnd.windowName = windowName;
    eBrwWnd.winContainer = eBrwWndContainer;
    [eBrwWndContainer.mBrwWndDict setObject:eBrwWnd forKey:windowName];
    eBrwWnd.hidden = NO;
    eBrwWnd.meBackWnd = eCurBrwWnd;
    eBrwWnd.meFrontWnd = nil;
    eCurBrwWnd.meFrontWnd = eBrwWnd;
    if (extraInfo) {
        [self setExtraInfo: dictionaryArg(extraInfo[@"extraInfo"]) toEBrowserView:eBrwWnd.meBrwView];
        [eBrwWnd setPopAnimationInfo: dictionaryArg(extraInfo[@"animationInfo"])];
        
    }
    self.EBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WINDOW_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
    eBrwWnd.mOpenAnimiId = 0;
    [self helpWindow:eBrwWnd loadData:data withDataType:dataType openFlag:UexWindowOpenFlagNone];
}







- (void)open:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inWindowName,NSNumber *inDataType,NSString *inData,NSNumber *inAniID,__unused id w,__unused  id h,NSNumber *inFlag,NSNumber *inAniDuration,NSDictionary *extraInfo) = inArguments;
    
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inWindowName = stringArg(info[@"name"]);
        inDataType = numberArg(info[@"dataType"]);
        inData = stringArg(info[@"data"]);
        inAniID = numberArg(info[@"animiID"]);
        inFlag = numberArg(info[@"flag"]);
        inAniDuration = numberArg(info[@"animDuration"]);
        extraInfo = dictionaryArg(info[@"extras"]);
    }
    
    UEX_PARAM_GUARD_NOT_NIL(inWindowName);
    UEX_PARAM_GUARD_NOT_NIL(inFlag);
    UEX_PARAM_GUARD_NOT_NIL(inDataType);
    UexWindowOpenFlag flag = (UexWindowOpenFlag)[inFlag integerValue];
    if (self.EBrwView.hidden == YES) {
        return;
    }
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return;
    }
    if ((self.EBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING) == F_EBRW_FLAG_WINDOW_IN_OPENING) {
        return;
    }
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        [eBrwMainFrm invalidateAdTimers];
    }
    
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypeNavigation || flag & UexWindowOpenFlagEnableSwipeClose) {
        [self openWindowControllerWithName:inWindowName
                                      data:inData
                                  dataType:inDataType.integerValue
                                windowType:ACEWebWindowTypeNavigation
                                 extraInfo:extraInfo];
        return;
    }
    EBrowserWindowContainer *eBrwWndContainer = eCurBrwWnd.winContainer;
    
    
    EBrowserWindow *eBrwWnd = [eBrwWndContainer brwWndForKey:inWindowName];
    if (eBrwWnd == eCurBrwWnd && !(flag & UexWindowOpenFlagReload)) {
        return;
    }
    if ((eBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
        return;
    }
    
    if (!eBrwWnd) {
        eBrwWnd = [[EBrowserWindow alloc]initWithFrame:CGRectMake(0, 0, eBrwWndContainer.bounds.size.width, eBrwWndContainer.bounds.size.height) BrwCtrler:self.EBrwView.meBrwCtrler Wgt:self.EBrwView.mwWgt UExObjName:inWindowName];
        [eBrwWndContainer.mBrwWndDict setObject:eBrwWnd forKey:inWindowName];
    } else {
        eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
        eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
    }
    
    [self helpConfigWindow:eBrwWnd withOpenFlag:flag];
    
    
    if (extraInfo) {
        [self setExtraInfo: dictionaryArg(extraInfo[@"extraInfo"]) toEBrowserView:eBrwWnd.meBrwView];
        [eBrwWnd setPopAnimationInfo: dictionaryArg(extraInfo[@"animationInfo"])];
    }
    
    self.EBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WINDOW_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
    
    eBrwWnd.mOpenAnimiId = [inAniID intValue];
    eBrwWnd.mOpenAnimiDuration = getAnimationDuration(inAniDuration);
    if (eBrwWnd.hidden == YES) {
        eBrwWnd.mOpenAnimiId = 0;
    }
    BOOL skipLoading = (inData.length == 0);
    if (!skipLoading) {
        skipLoading = [self helpWindow:eBrwWnd loadData:inData withDataType:(UexWindowOpenDataType)inDataType.integerValue openFlag:flag];
    }
    if (skipLoading) {
        [self helpBringWindowToFront:eBrwWnd];
    }
}

#pragma mark Open Window Helper
- (void)helpConfigWindow:(EBrowserWindow *)eBrwWnd withOpenFlag:(UexWindowOpenFlag)flag{
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    
    if (flag & UexWindowOpenFlagHidden) {
        eBrwWnd.hidden = YES;
    } else {
        eBrwWnd.hidden = NO;
        eBrwWnd.meBackWnd = eCurBrwWnd;
        eBrwWnd.meFrontWnd = nil;
        eCurBrwWnd.meFrontWnd = eBrwWnd;
    }
    if (flag & UexWindowOpenFlagOpaque) {
        eBrwWnd.meBrwView.backgroundColor = [UIColor whiteColor];
    }
    if (flag & UexWindowOpenFlagEnableScale) {
        [eBrwWnd.meBrwView setScalesPageToFit: YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled: YES];
    }
    if (flag & UexWindowOpenFlagDisableCrossDomain) {
        eBrwWnd.meBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    if (flag & UexWindowOpenFlagHasPreOpen) {
        eBrwWnd.mFlag |= F_EBRW_WND_FLAG_HAS_PREOPEN;
    }
    if (flag & UexWindowOpenFlagOauth) {
        eBrwWnd.mOAuthWndName = self.EBrwView.muexObjName;
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
}



#warning Animation 

- (void)helpBringWindowToFront:(EBrowserWindow *)eBrwWnd withAnimationId:(NSInteger)animationID animationDuration:(NSTimeInterval)animationDuration{
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = eCurBrwWnd.winContainer;
    [eBrwWndContainer bringSubviewToFront:eBrwWnd];
    
    if([ACEPOPAnimation isPopAnimation:eBrwWnd.mOpenAnimiId]){
        ACEPOPAnimateConfiguration *config=[ACEPOPAnimateConfiguration configurationWithInfo:eBrwWnd.popAnimationInfo];
        config.duration=eBrwWnd.mOpenAnimiDuration;
        [ACEPOPAnimation doAnimationInView:eBrwWnd
                                      type:(ACEPOPAnimateType)(eBrwWnd.mOpenAnimiId)
                             configuration:config
                                      flag:ACEPOPAnimateWhenWindowOpening
                                completion:^{
                                    eBrwWnd.usingPopAnimation=YES;
                                }];
    }else if ([BAnimation isMoveIn:eBrwWnd.mOpenAnimiId]) {
        [BAnimation doMoveInAnimition:eBrwWnd animiId:eBrwWnd.mOpenAnimiId animiTime:eBrwWnd.mOpenAnimiDuration];
    }else if ([BAnimation isPush:eBrwWnd.mOpenAnimiId]) {
        [BAnimation doPushAnimition:eBrwWnd animiId:eBrwWnd.mOpenAnimiId animiTime:eBrwWnd.mOpenAnimiDuration];
    }else {
        [BAnimation SwapAnimationWithView:eBrwWndContainer AnimiId:eBrwWnd.mOpenAnimiId AnimiTime:eBrwWnd.mOpenAnimiDuration];
    }
    
    [self.EBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    
    [self reportWindowOpeningEventWithSourceWindow:eCurBrwWnd newOpenedWindow:eBrwWnd openedURL:eBrwWnd.meBrwView.curUrl];
    
    if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
    }
    eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
    self.EBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
    
    [EBrowserWindow postWindowSequenceChange];
}


- (void)helpBringWindowToFront:(EBrowserWindow *)eBrwWnd{
    [self helpBringWindowToFront:eBrwWnd withAnimationId:eBrwWnd.mOpenAnimiId animationDuration:eBrwWnd.mOpenAnimiDuration];
    
}


- (BOOL)helpWindow:(EBrowserWindow *)eBrwWnd
          loadData:(NSString *)data
      withDataType:(UexWindowOpenDataType)dataType
          openFlag:(UexWindowOpenFlag)flag{
    NSURL *baseUrl = [self.EBrwView curUrl];
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = eCurBrwWnd.winContainer;
    switch (dataType) {
        case UexWindowOpenDataTypeURL: {
            NSURL *url = [self parseWebviewURL:data];
            if ([[eBrwWnd.meBrwView curUrl] isEqual:url] && !(flag & UexWindowOpenFlagReload)) {
                return NO;
            }
            if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
                EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
                [eBrwWnd addHisEntry:eHisEntry];
                FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                NSString *data = [encryptObj decryptWithPath:url appendData:nil];
                [eBrwWnd.meBrwView loadWithData:data baseUrl:url];
            } else {
                [eBrwWnd.meBrwView loadWithUrl:url];
            }
            [self reportWindowOpeningEventWithSourceWindow:eCurBrwWnd newOpenedWindow:eBrwWnd openedURL:url];
            break;
        }
        case UexWindowOpenDataTypeHTMLData: {
            [eBrwWnd.meBrwView loadWithData:data baseUrl:baseUrl];
            break;
        }
        case UexWindowOpenDataTypeURLAndHTMLData: {
            break;
        }
    }
    return YES;
}







#pragma mark - Close Window API
- (void)closeByName:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *windowName) = inArguments;
    
    NSNumber *result = ([self closeWindowByName:windowName] || [self closePopoverByName:windowName]) ? @0 : @1;
    
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.cbCloseByName" arguments:ACArgsPack(result)];
}




- (BOOL)closeWindowByName:(NSString *)name{
    
    EBrowserWindowContainer *eBrwWndContainer = self.EBrwView.meBrwWnd.winContainer;
    EBrowserWindow *brwWnd = [eBrwWndContainer.mBrwWndDict objectForKey:name];
    
    if (!brwWnd || brwWnd.webWindowType == ACEWebWindowTypeNavigation || brwWnd.webWindowType == ACEWebWindowTypePresent) {
        return NO;
    }
    [brwWnd removeFromSuperview];
    [eBrwWndContainer removeFromWndDict:name];
    return YES;
}
- (BOOL)closePopoverByName:(NSString *)name{
    EBrowserWindow *popover = [self.EBrwView.meBrwWnd.mPopoverBrwViewDict objectForKey:name];
    if (!popover) {
        return  NO;
    }
    [popover removeFromSuperview];
    [self.EBrwView.meBrwWnd removeFromPopBrwViewDict:name];
    return YES;
}


- (void)exitApp{
    NSString * title = ACELocalized(UEX_EXITAPP_ALERT_TITLE);
    NSString * message = ACELocalized(UEX_EXITAPP_ALERT_MESSAGE);
    NSString * exit = ACELocalized(UEX_EXITAPP_ALERT_EXIT);
    NSString * cancel = ACELocalized(UEX_EXITAPP_ALERT_CANCLE);
    
    UIAlertView *windowConfirmView = [[UIAlertView alloc]
                                      initWithTitle:title
                                      message:message
                                      delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:exit,cancel,nil];
    windowConfirmView.tag = kWindowConfirmViewTag;
    [windowConfirmView show];
}

- (void)closeAboveWndByName:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSString *windowName) = inArguments;
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;//调用此close方法的window
    EBrowserWindowContainer *eBrwWndContainer = eBrwWnd.winContainer;
    EBrowserWindow *brwWnd = [eBrwWndContainer.mBrwWndDict objectForKey:windowName]; //即将关闭window链中的第一个window
    
    if (!brwWnd) {
        ///退出应用
        [self exitApp];
        return;
    }
    if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        ACEWebViewController *webController = brwWnd.webController; //找到要关闭的controller
        if ([windowName isEqualToString:@"root"]) {
            //返回ROOT窗口。
            webController = eBrwWnd.webController;
            [webController.navigationController popToRootViewControllerAnimated:YES];
        } else {
            if (webController) {
                [webController.navigationController popToViewController:webController animated:NO];
                [webController.navigationController popViewControllerAnimated:YES];
            }
        }
        return;
    }
    EBrowserWindow *cBrwWnd = nil;
    if ([windowName isEqualToString:@"root"]) {
        brwWnd = brwWnd.meFrontWnd;
    }
    if (eBrwWnd != brwWnd) {
        //1.先判断brwWnd是否是eBrwWnd后面打开的兄弟
        BOOL isFrontSlibing = NO;
        cBrwWnd = eBrwWnd;
        while (cBrwWnd != nil) {
            if (cBrwWnd.meFrontWnd == brwWnd) {
                isFrontSlibing = YES;
                break;
            }
            cBrwWnd = cBrwWnd.meFrontWnd;
        }
        // 2.
        if (isFrontSlibing == NO) {
            //1.从window链中删除eBrwWnd
            eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
            eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
            //2.把eBrwWnd加入到brwWnd之前
            cBrwWnd = brwWnd.meBackWnd;
            cBrwWnd.meFrontWnd = eBrwWnd;
            eBrwWnd.meBackWnd = cBrwWnd;
            eBrwWnd.meFrontWnd = brwWnd;
            brwWnd.meBackWnd = eBrwWnd;
            //3.重置第一个关闭的window
            brwWnd = eBrwWnd;
        }
    }
    ///关闭兄弟
    while (brwWnd.meFrontWnd != nil) {
        cBrwWnd = brwWnd.meFrontWnd;
        brwWnd.meFrontWnd = cBrwWnd.meFrontWnd;
        
        if (cBrwWnd.meFrontWnd != nil) {
            cBrwWnd.meFrontWnd.meBackWnd = brwWnd;
        }
        cBrwWnd.meBackWnd=nil;
        cBrwWnd.meFrontWnd=nil;
        [self closeWindowByName:cBrwWnd.meBrwView.muexObjName];
    }
    ///关闭自己
    cBrwWnd = brwWnd.meBackWnd;
    cBrwWnd.meFrontWnd = nil;
    
    [self closeWindowByName:brwWnd.meBrwView.muexObjName];
}




- (void)close:(NSMutableArray *)inArguments{
    
    if (!self.EBrwView) {
        return;
    }
    if (!self.EBrwView.meBrwWnd) {
        return;
    }
    
    ACArgsUnpack(NSNumber *inAnimID,NSNumber *inAnimDuration) = inArguments;
    
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inAnimID = numberArg(info[@"animID"]);
        inAnimDuration = numberArg(info[@"animDuration"]);
    }
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        if (self.EBrwView.mType == ACEEBrowserViewTypePopover) {
            [self.EBrwView.meBrwWnd.mPopoverBrwViewDict removeObjectForKey:self.EBrwView.muexObjName];
            [self.EBrwView removeFromSuperview];
        } else if (self.EBrwView.mType == ACEEBrowserViewTypeMain) {
            ACEWebViewController *webController = eBrwWnd.webController;
            [webController.navigationController popViewControllerAnimated:YES];
        }
        [EBrowserWindow postWindowSequenceChange];
        return;
    }
    if (eBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        if (self.EBrwView.mType == ACEEBrowserViewTypePopover) {
            [self.EBrwView.meBrwWnd.mPopoverBrwViewDict removeObjectForKey:self.EBrwView.muexObjName];
            [self.EBrwView removeFromSuperview];
        } else if (self.EBrwView.mType == ACEEBrowserViewTypeMain) {
            ACEWebViewController *webController = eBrwWnd.webController;
            [webController dismissViewControllerAnimated:YES completion:nil];
        }
        [EBrowserWindow postWindowSequenceChange];
        return;
    }
    
    
    EBrowserWindowContainer *eBrwWndContainer = eBrwWnd.winContainer;
    
    switch (self.EBrwView.mType) {
        case ACEEBrowserViewTypeMain: {
            if (self.EBrwView == eBrwWndContainer.meRootBrwWnd.meBrwView) {
                return;
            }
            if (eBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) {
                return;
            }
            eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_CLOSING;
            eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
            eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
#warning Animation
            NSInteger animiId = inAnimID.integerValue;
            NSTimeInterval aniDuration = getAnimationDuration(inAnimDuration);
            
            if (animiId == -1) {
                if(eBrwWnd.usingPopAnimation){
                    animiId = [ACEPOPAnimation reverseAnimationId:eBrwWnd.mOpenAnimiId];
                }else{
                    animiId = [BAnimation ReverseAnimiId:eBrwWnd.mOpenAnimiId];
                }
                
            }
            
            [eBrwWndContainer removeFromWndDict:self.EBrwView.muexObjName];
            eBrwWnd.mFlag = 0;
            
            if([ACEPOPAnimation isPopAnimation:animiId]){
                NSDictionary *animateInfo=eBrwWnd.popAnimationInfo;
                if([inArguments count]>=3 && [inArguments[2] JSONValue] && [[inArguments[2] JSONValue] isKindOfClass:[NSDictionary class]]){
                    animateInfo=[inArguments[2] JSONValue];
                }
                ACEPOPAnimateConfiguration *config=[ACEPOPAnimateConfiguration configurationWithInfo:animateInfo];
                config.duration=aniDuration;
                [ACEPOPAnimation doAnimationInView:eBrwWnd
                                              type:(ACEPOPAnimateType)animiId
                                     configuration:config
                                              flag:ACEPOPAnimateWhenWindowClosing
                                        completion:^{
                                            [eBrwWnd clean];
                                            if (eBrwWnd.superview) {
                                                [eBrwWnd removeFromSuperview];
                                            }
                                            [self closeWindowAfterAnimation:eBrwWnd];
                                            
                                        }];
            }else if(animiId>=13 && animiId<=16) {
                [self moveeBrwWnd:eBrwWnd andTime:(float)aniDuration andAnimiId:(int)animiId];
            }else {
                if ([BAnimation isPush:(int)animiId]) {
                    [BAnimation doPushCloseAnimition:eBrwWnd animiId:(int)animiId animiTime:aniDuration completion:^(BOOL finished) {
                        [eBrwWnd clean];
                        if (eBrwWnd.superview) {
                            [eBrwWnd removeFromSuperview];
                        }
                        [self closeWindowAfterAnimation:eBrwWnd];
                        
                    }];
                }else {
                    [BAnimation SwapAnimationWithView:eBrwWndContainer AnimiId:(int)animiId AnimiTime:aniDuration];
                    [eBrwWnd clean];
                    if (eBrwWnd.superview) {
                        [eBrwWnd removeFromSuperview];
                    }
                    [self closeWindowAfterAnimation:eBrwWnd];
                    
                }
                
                NSArray * allLivingWindows = [eBrwWndContainer subviews];
                EBrowserWindow * presentLayerWindows = [allLivingWindows lastObject];
                [presentLayerWindows.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
            }
            
            break;
        }
            
        case ACEEBrowserViewTypePopover: {
            if (self.EBrwView.isMuiltPopover) {
                return;
            }
            [self.EBrwView.meBrwWnd.mPopoverBrwViewDict removeObjectForKey:self.EBrwView.muexObjName];
            [self.EBrwView removeFromSuperview];
            break;
        }
        case ACEEBrowserViewTypeAd: {
            self.EBrwView.meBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
            self.EBrwView.hidden = YES;
            [self.EBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
            return;
            
        }
        case ACEEBrowserViewTypeSlibingTop:
        case ACEEBrowserViewTypeSlibingBottom: {
            return;
        }
    }
    [EBrowserWindow postWindowSequenceChange];
}

- (void)closeWindowAfterAnimation:(EBrowserWindow*)brwWnd{
    NSString *fromViewName =[brwWnd.meBrwView.curUrl absoluteString];
    if (brwWnd.meBrwView) {
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:brwWnd.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:brwWnd.meBrwView.mwWgt.wgtType name:fromViewName closeReason:0 appInfo:appInfo];
        [brwWnd.meBrwView removeFromSuperview];
        brwWnd.meBrwView = nil;
    }
    if (brwWnd.meTopSlibingBrwView) {
        [brwWnd.meTopSlibingBrwView removeFromSuperview];
        brwWnd.meTopSlibingBrwView = nil;
    }
    
    if (brwWnd.meBottomSlibingBrwView) {
        [brwWnd.meBottomSlibingBrwView removeFromSuperview];
        brwWnd.meBottomSlibingBrwView = NULL;
    }
    if (brwWnd.mPopoverBrwViewDict) {
        NSArray *popViewArray = [brwWnd.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            [ePopView removeFromSuperview];
            //8.8 数据统计
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            [brwWnd.mPopoverBrwViewDict removeAllObjects];
            brwWnd.mPopoverBrwViewDict = nil;
        }
    }
    if (brwWnd.mMuiltPopoverDict){
        NSArray * mulitPopArray = [brwWnd.mMuiltPopoverDict allValues];
        for (EScrollView * multiPopover in mulitPopArray){
            [multiPopover removeFromSuperview];
        }
        [brwWnd.mMuiltPopoverDict removeAllObjects];
        brwWnd.mMuiltPopoverDict = nil;
    }
    
    if (self.EBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView) {
        brwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        self.EBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView.hidden = YES;
        [self.EBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
    }
    if ((brwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) && (brwWnd.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING)) {
        brwWnd.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
    }
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)brwWnd.superview;
    EBrowserWindow *eAboveWnd = [eBrwWndContainer aboveWindow];
    [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    
    int goType = eAboveWnd.meBrwView.mwWgt.wgtType;
    NSString *goViewName =[eAboveWnd.meBrwView.curUrl absoluteString];
    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eAboveWnd.meBrwView.mwWgt];
    if(goViewName && [goViewName length]>0){
        [BUtility setAppCanViewActive:goType opener:fromViewName name:goViewName openReason:1 mainWin:0 appInfo:appInfo];
    }
    if (eAboveWnd.mPopoverBrwViewDict) {
        NSArray *popViewArray = [eAboveWnd.mPopoverBrwViewDict allValues];
        for (EBrowserView *ePopView in popViewArray) {
            int type =ePopView.mwWgt.wgtType;
            NSString *viewName =[ePopView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
            [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
        }
    }
    
    if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
        [eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
    }
}


- (void)moveeBrwWnd:(EBrowserWindow*)temp andTime:(float)aniDuration andAnimiId:(int)animiId{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:aniDuration];
    [UIView setAnimationDelegate:self];
    //	[UIView setAnimationDidStopSelector:@selector(animationFinish:finished:context:)];
    switch(animiId)
    {
        case 13:
        {
            CGRect frame= temp.frame ;
            frame.origin.x=frame.origin.x+[BUtility getScreenWidth];
            [temp setFrame:frame];
        }
            break;
        case 14:
        {
            CGRect frame= temp.frame ;
            frame.origin.x=frame.origin.x-[BUtility getScreenWidth];
            [temp setFrame:frame];
        }
            break;
        case 15:
        {
            CGRect frame= temp.frame ;
            frame.origin.y=frame.origin.y+[BUtility getScreenHeight];
            [temp setFrame:frame];
        }
            break;
        case 16:
        {
            CGRect frame= temp.frame ;
            frame.origin.y=frame.origin.y-[BUtility getScreenHeight];
            [temp setFrame:frame];
        }
            break;
            
        default:
            break;
            
    }
    [UIView commitAnimations];
}



#pragma mark - Window Control API

- (void)forward:(NSMutableArray *)inArguments{
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
        EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
        if (eBrwWnd.canGoForward == YES) {
            [eBrwWnd goForward];
        }
    } else {
        if (self.EBrwView.canGoForward) {
            [self.EBrwView goForward];
        }
    }
}

- (void)back:(NSMutableArray *)inArguments{
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
        EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
        if (eBrwWnd.canGoBack == YES) {
            [eBrwWnd goBack];
        }
    } else {
        if (self.EBrwView.canGoBack) {
            [self.EBrwView goBack];
        }
    }
}
- (UEX_BOOL)pageForward:(NSMutableArray *)inArguments{
    
    if ([self.EBrwView canGoForward]){
        [self.webViewEngine evaluateScript:@"window.history.forward()"];
        [self callbackWithKeyPath:@"uexWindow.cbPageForward" intData:UEX_CSUCCESS];
        return UEX_TRUE;
        
    }else{
        [self callbackWithKeyPath:@"uexWindow.cbPageForward" intData:UEX_CFAILED];
        return UEX_FALSE;
    }
}
- (UEX_BOOL)pageBack:(NSMutableArray *)inArguments{
    if ([self.EBrwView canGoBack]){
        [self.webViewEngine evaluateScript:@"window.history.back()"];
        [self callbackWithKeyPath:@"uexWindow.cbPageBack" intData:UEX_CSUCCESS];
        return UEX_TRUE;
    }else{
        [self callbackWithKeyPath:@"uexWindow.cbPageBack" intData:UEX_CFAILED];
        return UEX_FALSE;
    }
}

- (void)test:(NSMutableArray *)inArguments{

}

- (void)windowBack:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    ACArgsUnpack(NSNumber *inAnimId,NSNumber *inAnimDuration) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inAnimId = numberArg(info[@"animID"]);
        inAnimDuration = numberArg(info[@"animDuration"]);
    }
    
    
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    if (!eBrwWnd.meBackWnd){
        return;
    }
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    NSInteger animiId = [inAnimId integerValue];
    NSTimeInterval animiDuration = getAnimationDuration(inAnimDuration);
    
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        [eBrwMainFrm invalidateAdTimers];
    }
    [self helpBringWindowToFront:eBrwWnd.meBackWnd withAnimationId:animiId animationDuration:animiDuration];
}


- (void)windowForward:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    ACArgsUnpack(NSNumber *inAnimID,NSNumber *inAnimDuration) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inAnimID = numberArg(info[@"animID"]);
        inAnimDuration = numberArg(info[@"animDuration"]);
    }
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (!eBrwWnd.meFrontWnd) {
        return;
    }
    NSInteger animiId = [inAnimID integerValue];
    NSTimeInterval animiDuration = getAnimationDuration(inAnimDuration);
    
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        [eBrwMainFrm invalidateAdTimers];
    }
    [self helpBringWindowToFront:eBrwWnd.meFrontWnd withAnimationId:animiId animationDuration:animiDuration];
    
}

- (void)insertWindowAboveWindow:(NSMutableArray *)inArguments{
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    ACArgsUnpack(NSString *nameA,NSString *nameB) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(nameA);
    UEX_PARAM_GUARD_NOT_NIL(nameB);
    
    EBrowserWindowContainer *eBrwWndContainer = self.EBrwView.meBrwWnd.winContainer;
    EBrowserWindow * windowA = [eBrwWndContainer brwWndForKey:nameA];
    EBrowserWindow * windowB = [eBrwWndContainer brwWndForKey:nameB];
    if (!windowA || !windowB) {
        return;
    }
    [eBrwWndContainer insertSubview:windowA aboveSubview:windowB];
    [EBrowserWindow postWindowSequenceChange];
}

- (void)insertWindowBelowWindow:(NSMutableArray *)inArguments{
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    ACArgsUnpack(NSString *nameA,NSString *nameB) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(nameA);
    UEX_PARAM_GUARD_NOT_NIL(nameB);
    
    EBrowserWindowContainer *eBrwWndContainer = self.EBrwView.meBrwWnd.winContainer;
    EBrowserWindow * windowA = [eBrwWndContainer brwWndForKey:nameA];
    EBrowserWindow * windowB = [eBrwWndContainer brwWndForKey:nameB];
    if (!windowA || !windowB) {
        return;
    }
    [eBrwWndContainer insertSubview:windowA belowSubview:windowB];
    [EBrowserWindow postWindowSequenceChange];
}


- (void)reload:(NSMutableArray *)inArguments {
    BOOL reloaded = NO;
    if (self.EBrwView.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
        FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
        NSString *data = [encryptObj decryptWithPath:self.EBrwView.curUrl appendData:nil];
        if (data) {
            [self.EBrwView loadWithData:data baseUrl:self.EBrwView.curUrl];
            reloaded = YES;
        }
    }
    if (!reloaded) {
        [self.EBrwView reload];
    }
}

- (void)loadObfuscationData:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inUrl) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inUrl);
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
    NSURL *baseUrl = [self.EBrwView curUrl];
    NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
    NSURL *url = [BUtility stringToUrl:urlStr];
    if (F_WWIDGET_OBFUSCATION == self.EBrwView.mwWgt.obfuscation) {
        FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
        NSString *data = [encryptObj decryptWithPath:url appendData:nil];
        
        EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
        [eBrwWnd addHisEntry:eHisEntry];
        [self.EBrwView loadWithData:data baseUrl:url];
    } else {
        [self.EBrwView loadWithUrl:url];
    }
}

- (void)setWindowFrame:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inX,NSNumber *inY,NSNumber *inAnimDuration) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inX = numberArg(info[@"x"]);
        inY = numberArg(info[@"y"]);
        inAnimDuration = numberArg(info[@"animDuration"]);
    }
    UEX_PARAM_GUARD_NOT_NIL(inX);
    UEX_PARAM_GUARD_NOT_NIL(inY);
    UEX_PARAM_GUARD_NOT_NIL(inAnimDuration);
    CGFloat x = inX.floatValue;
    CGFloat y = inY.floatValue;
    NSTimeInterval duration = inAnimDuration.doubleValue / 1000;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onSetWindowFrameFinish)];
    [self.EBrwView.meBrwWnd setFrame:CGRectMake(x, y, self.EBrwView.meBrwWnd.frame.size.width, self.EBrwView.meBrwWnd.frame.size.height)];
    [UIView commitAnimations];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:duration]];
}
- (void)onSetWindowFrameFinish {
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.onSetWindowFrameFinish" arguments:nil];
}





#pragma mark - Window & Popover Property API

- (void)setWindowHidden:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    ACArgsUnpack(NSString * isHidden) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(isHidden);
    
    BOOL hidden = isHidden.boolValue;
    self.EBrwView.meBrwWnd.hidden = hidden;
    [EBrowserWindow postWindowSequenceChange];
}


- (NSString *)getWindowName:(NSMutableArray *)inArguments{
    return self.EBrwView.meBrwWnd.meBrwView.muexObjName;
}

- (NSNumber *)getWidth:(NSMutableArray *)inArguments{
    return @(self.EBrwView.bounds.size.width);
}
- (NSNumber *)getHeight:(NSMutableArray *)inArguments{
    return @(self.EBrwView.bounds.size.height);
}



- (void)setIsSupportSwipeCallback:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    if(info && info[@"isSupport"]){
        self.EBrwView.meBrowserView.swipeCallbackEnabled = [info[@"isSupport"] boolValue];
    }
}

//设置窗口是否显示ScrollBar

- (void)setWindowScrollbarVisible:(NSMutableArray *)inArgument{
    ACArgsUnpack(NSString *boolStr) = inArgument;
    self.EBrwView.scrollView.showsVerticalScrollIndicator = boolStr.boolValue;
    self.EBrwView.scrollView.showsHorizontalScrollIndicator = boolStr.boolValue;
}

- (NSString *)getUrlQuery:(NSMutableArray *)inArguments {
    NSURL *curUrl = [self.EBrwView curUrl];
    NSString *queryData = [curUrl query];
    if (queryData) {
        [self callbackWithKeyPath:@"uexWindow.cbGetUrlQuery" strData:queryData];
        return queryData;
    } else {
        [self callbackWithKeyPath:@"uexWindow.cbGetUrlQuery" strData:@""];
        return @"";
    }
    
}

- (NSNumber *)getState:(NSMutableArray *)inArguments {
    if (!self.EBrwView || !self.EBrwView.meBrwWnd) {
        return @-1;
    }
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return @-1;
    }
    
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        ACEWebViewController *webController = (ACEWebViewController *)eCurBrwWnd.webController;
        
        if (webController == webController.navigationController.topViewController) {
            [self callbackWithKeyPath:F_CB_WINDOW_GET_STATE intData:0];
            return @0;
        } else {
            [self callbackWithKeyPath:F_CB_WINDOW_GET_STATE intData:1];
            return @1;
        }
    }
    EBrowserWindowContainer *eBrwWndContainer = self.EBrwView.meBrwWnd.winContainer;
    if (!eBrwWndContainer) {
        return @-1;
    }
    if ([self.EBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] == eBrwWndContainer) {
        if ([eBrwWndContainer aboveWindow] == self.EBrwView.meBrwWnd) {
            [self callbackWithKeyPath:F_CB_WINDOW_GET_STATE intData:0];
            return @0;
        }
    }
    [self callbackWithKeyPath:F_CB_WINDOW_GET_STATE intData:1];
    return @1;
}


#pragma mark - Pop-up API

- (void)alert:(NSMutableArray *)inArguments{
    
    if ((self.EBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
        return;
    }
    ACArgsUnpack(NSString *inTitle,NSString *inMessage,NSString *inButtonLabel) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inTitle = stringArg(info[@"title"]);
        inMessage = stringArg(info[@"message"]);
        inButtonLabel = stringArg(info[@"buttonLabel"]);
    }
    
    if (!inButtonLabel) {
        inButtonLabel = @"确定";
    }
    ACENSLog(@"alertWithTitle");
    self.mbAlertView = [[BUIAlertView alloc]initWithType:ACEBUIAlertViewTypeAlert];
    self.mbAlertView.mAlertView = [[UIAlertView alloc] initWithTitle:inTitle
                                                             message:inMessage
                                                            delegate:self
                                                   cancelButtonTitle:inButtonLabel
                                                   otherButtonTitles:nil];
    [self.mbAlertView.mAlertView show];
}


- (void)confirm:(NSMutableArray *)inArguments{
    
    if ((self.EBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
        return;
    }
    
    ACArgsUnpack(NSString *inTitle,NSString *inMessage,NSArray *inButtonLabels) = inArguments;
    NSString *inButtonLabelStr = inArguments.count > 2 ? stringArg(inArguments[2]) : nil;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inTitle = stringArg(info[@"title"]);
        inMessage = stringArg(info[@"message"]);
        inButtonLabels = arrayArg(info[@"buttonLabels"]);
        inButtonLabelStr = stringArg(info[@"buttonLabels"]);
    }
    if (!inButtonLabels) {
        inButtonLabels = [inButtonLabelStr componentsSeparatedByString:@","];
    }
    UEX_PARAM_GUARD_NOT_NIL(inTitle);
    UEX_PARAM_GUARD_NOT_NIL(inMessage);
    self.confirmCB = JSFunctionArg(inArguments.lastObject);
    self.mbAlertView = [[BUIAlertView alloc]initWithType:ACEBUIAlertViewTypePrompt];
    self.mbAlertView.mAlertView = [[UIAlertView alloc]
                                   initWithTitle:inTitle
                                   message:inMessage
                                   delegate:self
                                   cancelButtonTitle:nil
                                   otherButtonTitles:nil];
    NSInteger buttonCount = inButtonLabels.count;
    NSString *button = nil;
    for (int i=0; i<buttonCount; i++) {
        NSString *label = stringArg(inButtonLabels[i]);
        if (label) {
            [self.mbAlertView.mAlertView addButtonWithTitle:button];
        }
    }
    
    [self.mbAlertView.mAlertView show];
}



- (void)prompt:(NSMutableArray *)inArguments{
    if ((self.EBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
        return;
    }
    
    ACArgsUnpack(NSString *inTitle,NSString *inMessage,NSString *inDefaultValue,NSArray *inButtonLabels,NSString *placeHolder) = inArguments;
    NSString *inButtonLabelStr = inArguments.count > 3 ? stringArg(inArguments[3]) : nil;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inTitle = stringArg(info[@"title"]);
        inMessage = stringArg(info[@"message"]);
        inButtonLabels = arrayArg(info[@"buttonLabels"]);
        inButtonLabelStr = stringArg(info[@"buttonLabels"]);
    }
    if (!inButtonLabels) {
        inButtonLabels = [inButtonLabelStr componentsSeparatedByString:@","];
    }
    inTitle = inTitle?:@" ";
    
    self.promptCB = JSFunctionArg(inArguments.lastObject);
    self.mbAlertView = [[BUIAlertView alloc]initWithType:ACEBUIAlertViewTypePrompt];
    self.mbAlertView.mAlertView = [[UIAlertView alloc] initWithTitle:inTitle
                                                             message:inMessage
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                                   otherButtonTitles:nil];
    
    self.mbAlertView.mAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * temp = [self.mbAlertView.mAlertView textFieldAtIndex:0];
    temp.text = inDefaultValue;
    temp.placeholder = placeHolder;
    for (int i = 0; i < inButtonLabels.count; i++) {
        NSString *label = stringArg(inButtonLabels[i]);
        if (label) {
            [self.mbAlertView.mAlertView addButtonWithTitle:label];
        }
    }
    [self.mbAlertView.mAlertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kWindowConfirmViewTag) {
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        if (buttonIndex == 0) {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSString *tempDirectoryPath = NSTemporaryDirectory();
            NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
            NSString* fileName = nil;
            NSError *err = nil;
            while ((fileName = [directoryEnumerator nextObject])) {
                NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
                
                BOOL result = [fileMgr removeItemAtPath:filePath error:&err];
                if (!result && err) {
                    ACLogDebug(@"delete tmp file '%@' error: %@",filePath,err.localizedDescription);
                }
            }
            exit(0);
        }
        return;
    }
    
    switch (self.mbAlertView.mType) {
        case ACEBUIAlertViewTypeAlert:
            break;
        case ACEBUIAlertViewTypeConfirm:{
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [self callbackWithKeyPath:F_CB_WINDOW_CONFIRM intData:buttonIndex];
            [self.confirmCB executeWithArguments:ACArgsPack(@(buttonIndex))];
            self.confirmCB = nil;
            break;
        }
        case ACEBUIAlertViewTypePrompt: {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            UITextField * temp = [self.mbAlertView.mAlertView textFieldAtIndex:0];
            NSString *text = [temp text];
            NSMutableDictionary *retDict = [[NSMutableDictionary alloc]initWithCapacity:5];
            [retDict setObject:@(buttonIndex) forKey:@"num"];
            [retDict setValue:text forKey:@"value"];
            [self callbackWithKeyPath:F_CB_WINDOW_PROMPT jsonData:[retDict JSONFragment]];
            [self.promptCB executeWithArguments:ACArgsPack(@(buttonIndex),text)];
            self.promptCB = nil;
            break;
        }
            
    }
    
}



- (void)toast:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inType,NSNumber *inLocation,NSString *inMsg,NSNumber *inDuration) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inType = numberArg(info[@"type"]);
        inLocation = numberArg(info[@"location"]);
        inMsg = stringArg(info[@"msg"]);
        inDuration = numberArg(info[@"duration"]);
    }
    
    
    UEX_PARAM_GUARD_NOT_NIL(inType);
    UEX_PARAM_GUARD_NOT_NIL(inLocation);
    UEX_PARAM_GUARD_NOT_NIL(inMsg);
    UEX_PARAM_GUARD_NOT_NIL(inDuration);
    
    [self closeToast:nil];
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    float wndWidth = eBrwWnd.bounds.size.width;
    float wndHeight = eBrwWnd.bounds.size.height;
    
    
    
    int pos = 5;
    int temPos = [inLocation intValue];
    if (temPos >=1 && temPos<=9) {
        pos = temPos;
    }
    
    int type = [inType intValue];
    CGRect toastViewRect = [BToastView viewRectWithPos:pos wndWidth:wndWidth wndHeight:wndHeight];
    self.mToastView = [[BToastView alloc]initWithFrame:toastViewRect Type:type Pos:pos];
    self.mToastView.mTextView.text = inMsg;
    [eBrwWnd addSubview:self.mToastView];
    
    NSTimeInterval duration = [inDuration doubleValue] / 1000;
    if (duration > 0) {
        self.mToastTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(closeToast:) userInfo:nil repeats:NO];
    }
    
}

- (void)closeToast:(NSMutableArray *)inArguments {
    if (self.mToastView) {
        [self.mToastView removeFromSuperview];
        self.mToastView = nil;
        if (self.mToastTimer) {
            [self.mToastTimer invalidate];
            self.mToastTimer = nil;
        }
    }
}





- (void)actionSheet:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inTitle,NSString *inCancel,NSArray *inButtonLabels) = inArguments;
    NSString *inButtonLabelStr = inArguments.count >2 ? stringArg(inArguments[2]) : nil;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inTitle = stringArg(info[@"title"]);
        inCancel = stringArg(info[@"cancel"]);
        inButtonLabels = arrayArg(info[@"buttons"]);
        inButtonLabelStr = stringArg(info[@"buttons"]);
    }
    if (!inButtonLabels) {
        inButtonLabels = [inButtonLabelStr componentsSeparatedByString:@","];
    }
    
    self.mActionSheet=[[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (int i = 0; i < inButtonLabels.count; i++) {
        NSString *label = stringArg(inButtonLabels[i]);
        if (label) {
            [self.mActionSheet addButtonWithTitle:label];
        }
    }
    self.actionSheetCB = JSFunctionArg(inArguments.lastObject);
    self.mActionSheet.cancelButtonIndex = [self.mActionSheet addButtonWithTitle:inCancel];
    self.mActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [self.mActionSheet showInView:self.EBrwView.meBrwWnd];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self callbackWithKeyPath:F_CB_WINDOW_ACTION_SHEET intData:buttonIndex];
    [self.actionSheetCB executeWithArguments:ACArgsPack(@(buttonIndex))];
    self.actionSheetCB = nil;
    
}


#pragma mark - Sliding Window API

- (void)setSlidingWindowEnabled:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *enable) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(enable);
    
    NSInteger flag = enable.integerValue;
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    if (flag == 1) {
        if (app.leftWebController) {
            if (app.drawerController) {
                [app.drawerController setLeftDrawerViewController:app.leftWebController];
            } else {
                app.sideMenuViewController.panGestureEnabled = YES;
            }
        }
        if (app.rightWebController) {
            if (app.drawerController) {
                [app.drawerController setRightDrawerViewController:app.rightWebController];
            } else {
                app.sideMenuViewController.panGestureEnabled = YES;
            }
        }
    }
    if (flag == 0){
        if (app.drawerController) {
            [app.drawerController setLeftDrawerViewController:nil];
            [app.drawerController setRightDrawerViewController:nil];
        } else {
            app.sideMenuViewController.panGestureEnabled = NO;
        }
    }
    
}

- (NSNumber *)getSlidingWindowState:(NSMutableArray *)inArguments {
    WidgetOneDelegate * app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    NSInteger windowStatus = 1;
    if (app.drawerController) {
        switch (app.drawerController.openSide) {
            case MMDrawerSideNone:
                windowStatus = 1;
                break;
            case MMDrawerSideLeft:
                windowStatus = 0;
                break;
            case MMDrawerSideRight:
                windowStatus = 2;
                break;
        }
    } else if (app.sideMenuViewController){
        windowStatus = app.sideMenuViewController.sideStatus;
    }
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.cbSlidingWindowState" arguments:ACArgsPack(@(windowStatus))];
    return @(windowStatus);
}


- (void)toggleSlidingWindow:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSNumber *mark = numberArg(info[@"mark"]);
    UEX_PARAM_GUARD_NOT_NIL(mark);
    NSInteger markFlag = mark.integerValue;
    
    BOOL shouldReload = [info[@"reload"] boolValue];
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    
    if (markFlag == 0) {
        if (shouldReload) {
            ACEWebViewController * leftViewController = app.drawerController ? (ACEWebViewController *)app.drawerController.leftDrawerViewController : (ACEWebViewController *)app.sideMenuViewController.leftMenuViewController;
            NSArray * webViews = [leftViewController.browserWindow subviews];
            for (EBrowserView * meBrowserView in webViews) {
                if ([meBrowserView respondsToSelector:@selector(reload)]) {
                    [meBrowserView reload];
                }
            }
        }
        if (app.drawerController) {
            [app.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        } else {
            if (app.sideMenuViewController.leftMenuVisible) {
                [app.sideMenuViewController hideMenuViewController];
            } else {
                [app.sideMenuViewController presentLeftMenuViewController];
            }
        }
    }
    if (markFlag == 1)  {
        if (shouldReload) {
            ACEWebViewController * rightViewController = app.drawerController ? (ACEWebViewController *)app.drawerController.rightDrawerViewController : (ACEWebViewController *)app.sideMenuViewController.rightMenuViewController;
            NSArray * webViews = [rightViewController.browserWindow subviews];
            for (EBrowserView * meBrowserView in webViews) {
                if ([meBrowserView respondsToSelector:@selector(reload)]) {
                    [meBrowserView reload];
                }
            }
        }
        if (app.drawerController) {
            [app.drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
        } else {
            if (app.sideMenuViewController.rightMenuVisible) {
                [app.sideMenuViewController hideMenuViewController];
            } else {
                [app.sideMenuViewController presentRightMenuViewController];
            }
        }
    }
}

- (void)setSlidingWindow:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    NSDictionary *leftDict = dictionaryArg(info[@"leftSliding"]);
    NSDictionary *rightDict = dictionaryArg(info[@"rightSliding"]);
    
    NSNumber *animationId = numberArg(info[@"animationId"]);
    NSString *bgImg = stringArg(info[@"bg"]);
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    
    
    CGFloat leftWidth = 0,rightWidth = 0;
    ACEUINavigationController *meNav = nil;
    
    if (bgImg && animationId) {
        meNav = (ACEUINavigationController *)app.drawerController.centerViewController;
        app.drawerController = nil;
    }
    
    if (leftDict) {
        leftWidth = numberArg(leftDict[@"width"]).floatValue;
        if (app.leftWebController == nil) {
            ACEWebViewController *controller = [[ACEWebViewController alloc] init];
            app.leftWebController = controller;
            [self addBrowserWindowToWebController:controller url:stringArg(leftDict[@"url"]) winName:AppRootLeftSlidingWinName];
            if (leftWidth > 0) {
                [app.drawerController setMaximumLeftDrawerWidth:leftWidth];
            }
            if (app.drawerController) {
                [app.drawerController setLeftDrawerViewController:app.leftWebController];
            } else {
                app.sideMenuViewController.leftMenuViewController = app.leftWebController;
            }
        }
    }
    if (rightDict != nil) {
        rightWidth = numberArg(rightDict[@"width"]).floatValue;
        if (app.rightWebController == nil) {
            ACEWebViewController *controller = [[ACEWebViewController alloc] init];
            controller = [[ACEWebViewController alloc] init];
            app.rightWebController = controller;
            [self addBrowserWindowToWebController:controller url:stringArg(rightDict[@"url"]) winName:ApprootRightSlidingWinName];
            if (rightWidth > 0) {
                [app.drawerController setMaximumRightDrawerWidth:rightWidth];
            }
            if (app.drawerController) {
                [app.drawerController setRightDrawerViewController:app.rightWebController];
            } else {
                app.sideMenuViewController.rightMenuViewController = app.rightWebController;
            }
        }
    }
    
    if (bgImg && animationId) {
        app.sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:meNav
                                                                leftMenuViewController:app.leftWebController
                                                               rightMenuViewController:app.rightWebController];
        NSString * imgPath = [self absPath:bgImg];
        app.sideMenuViewController.backgroundImage = [UIImage imageWithContentsOfFile:imgPath];
        app.sideMenuViewController.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
        app.sideMenuViewController.contentViewShadowEnabled = NO;
        
        if (leftWidth > 0) {
            app.sideMenuViewController.leftOffsetX = leftWidth;
        }
        
        if (rightWidth > 0) {
            app.sideMenuViewController.rightOffsetX = rightWidth;
        }
        app.window.rootViewController = app.sideMenuViewController;
    }
    
}

- (void)addBrowserWindowToWebController:(ACEWebViewController *)webController url:(NSString *)inURL winName:(NSString *)winName{
    if (self.EBrwView.hidden == YES) {
        return;
    }
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = eCurBrwWnd.winContainer;
    [eBrwWndContainer removeFromWndDict:winName];
    EBrowserWindow *eBrwWnd = [[EBrowserWindow alloc]initWithFrame:CGRectMake(0, 0, eBrwWndContainer.bounds.size.width, eBrwWndContainer.bounds.size.height)
                                                         BrwCtrler:self.EBrwView.meBrwCtrler
                                                               Wgt:self.EBrwView.mwWgt
                                                        UExObjName:winName];
    eBrwWnd.webWindowType = ACEWebWindowTypeNavigation;
    eBrwWnd.windowName = winName;
    eBrwWnd.winContainer = eBrwWndContainer;
    eBrwWnd.isSliding = YES;
    webController.browserWindow = eBrwWnd;
    eBrwWnd.webController = webController;
    eBrwWnd.hidden = NO;
    eBrwWnd.meBackWnd = eCurBrwWnd;
    eCurBrwWnd.meFrontWnd = eBrwWnd;
    self.EBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WINDOW_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
    
    if (inURL.length > 0) {
        NSURL *url = [self parseWebviewURL:inURL];
        if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
            EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
            [eBrwWnd addHisEntry:eHisEntry];
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *data = [encryptObj decryptWithPath:url appendData:nil];
            [eBrwWnd.meBrwView loadWithData:data baseUrl:url];
            
        } else {
            [eBrwWnd.meBrwView loadWithUrl:url];
        }
        [self reportWindowOpeningEventWithSourceWindow:eCurBrwWnd newOpenedWindow:eBrwWnd openedURL:url];
    } else {
        [eBrwWndContainer bringSubviewToFront:eBrwWnd];
        [self.EBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        [self reportWindowOpeningEventWithSourceWindow:eCurBrwWnd newOpenedWindow:eBrwWnd openedURL:eBrwWnd.meBrwView.curUrl];
        if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
            [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
        eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
        self.EBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        
    }
}




#pragma mark 设置是否允许侧滑关闭

- (void)setSwipeCloseEnable:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        return;
    }
    BOOL canSwipeClose=YES;
    if([info objectForKey:@"enable"]){
        canSwipeClose=[[info objectForKey:@"enable"]boolValue];
    }
    self.EBrwView.meBrwWnd.enableSwipeClose=canSwipeClose;
    [self.EBrwView.meBrwWnd updateSwipeCloseEnableStatus];
}







#pragma mark - Slibing Window API


- (void)helpSlibingBrwView:(EBrowserView *)slibingView loadWithURL:(NSString *)urlStr data:(NSString *)data dataType:(UexWindowOpenDataType)dataType{
    NSURL *baseURL = [self.EBrwView curUrl];
    switch (dataType) {
        case UexWindowOpenDataTypeURL: {
            NSURL *url = [BUtility stringToUrl:[BUtility makeUrl:baseURL.absoluteString url:urlStr]];
            [slibingView loadWithUrl:url];
            break;
        }
        case UexWindowOpenDataTypeHTMLData: {
            [slibingView loadWithData:data baseUrl:baseURL];
            break;
        }
        case UexWindowOpenDataTypeURLAndHTMLData: {
            NSURL *url = [BUtility stringToUrl:[BUtility makeUrl:[baseURL absoluteString] url:urlStr]];
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *mixData = [encryptObj decryptWithPath:url appendData:data];
            [slibingView loadWithData:mixData baseUrl:url];
            break;
        }
    }
}

- (void)openSlibing:(NSMutableArray *)inArguments{
    
    BOOL useContentSize = NO;
    if (!self.EBrwView) {
        return;
    }
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    ACArgsUnpack(NSNumber *inSlibingType,NSNumber *inDataType,NSString *inUrl,NSString *inData,__unused id w,NSNumber *inHeight) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inSlibingType = numberArg(info[@"type"]);
        inDataType = numberArg(info[@"dataType"]);
        inUrl = stringArg(info[@"url"]);
        inData = stringArg(info[@"data"]);
        inHeight = numberArg(info[@"h"]);
    }
    UEX_PARAM_GUARD_NOT_NIL(inHeight);
    UEX_PARAM_GUARD_NOT_NIL(inSlibingType);
    UEX_PARAM_GUARD_NOT_NIL(inDataType);
    
    CGFloat height = [inHeight floatValue];
    if (height <= 0) {
        useContentSize = YES;
        height = 1;
    }
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    
    ACEUexWindowSlibingType slibingType = (ACEUexWindowSlibingType)[inSlibingType integerValue];
    UexWindowOpenDataType dataType = (UexWindowOpenDataType)[inDataType integerValue];
    
    if (height > eBrwWnd.bounds.size.height) {
        height = eBrwWnd.bounds.size.height;
    }
    switch (slibingType) {
        case ACEUexWindowSlibingTypeTop: {
            if (!eBrwWnd.meTopSlibingBrwView) {
                eBrwWnd.meTopSlibingBrwView = [[EBrowserView alloc] initWithFrame:CGRectMake(0, 0, eBrwWnd.bounds.size.width, height) BrwCtrler:self.EBrwView.meBrwCtrler Wgt:self.EBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:nil Type:ACEEBrowserViewTypeSlibingTop];
            }else{
                [eBrwWnd.meTopSlibingBrwView removeFromSuperview];
            }
            [eBrwWnd.meTopSlibingBrwView setFrame:CGRectMake(0, 0, eBrwWnd.bounds.size.width, height)];
            [self helpSlibingBrwView:eBrwWnd.meTopSlibingBrwView loadWithURL:inUrl data:inData dataType:dataType];
            break;
        }
        case ACEUexWindowSlibingTypeBottom: {
            if (!eBrwWnd.meBottomSlibingBrwView) {
                eBrwWnd.meBottomSlibingBrwView = [[EBrowserView alloc] initWithFrame:CGRectMake(0, eBrwWnd.bounds.size.height-height, eBrwWnd.bounds.size.width, height) BrwCtrler:self.EBrwView.meBrwCtrler Wgt:self.EBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:nil Type:ACEEBrowserViewTypeSlibingBottom];
            }else{
                [eBrwWnd.meBottomSlibingBrwView removeFromSuperview];
            }
            eBrwWnd.meBottomSlibingBrwView.frame = CGRectMake(0, eBrwWnd.bounds.size.height-height, eBrwWnd.bounds.size.width, height);
            [self helpSlibingBrwView:eBrwWnd.meBottomSlibingBrwView loadWithURL:inUrl data:inData dataType:dataType];
            eBrwWnd.meBottomSlibingBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE;
            if (useContentSize == YES) {
                eBrwWnd.meBottomSlibingBrwView.mFlag |= F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE;
            }
            break;
        }
    }
}

- (void)closeSlibing:(NSMutableArray *)inArguments {
    
    if (!self.EBrwView) {
        return;
    }
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    ACArgsUnpack(NSNumber *inSlibingType) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inSlibingType);
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    ACEUexWindowSlibingType slibingType = (ACEUexWindowSlibingType)[inSlibingType integerValue];
    switch (slibingType) {
        case ACEUexWindowSlibingTypeTop:
            if (eBrwWnd.meTopSlibingBrwView) {
                [eBrwWnd.meTopSlibingBrwView removeFromSuperview];
                eBrwWnd.meTopSlibingBrwView = nil;
            }
            break;
        case ACEUexWindowSlibingTypeBottom:
            if (eBrwWnd.meBottomSlibingBrwView) {
                [eBrwWnd.meBottomSlibingBrwView removeFromSuperview];
                eBrwWnd.meBottomSlibingBrwView = nil;
            }
            break;
    }
}

- (void)showSlibing:(NSMutableArray *)inArguments {
    if (!self.EBrwView) {
        return;
    }
    
    UEX_WINDOW_GUARD_NOT_USE_IN_CONTROLLER();
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    ACArgsUnpack(NSNumber *typeNum) = inArguments;
    if (!typeNum) {
        return;
    }
    ACEUexWindowSlibingType slibingType = (ACEUexWindowSlibingType)[typeNum integerValue];
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    switch (slibingType) {
        case ACEUexWindowSlibingTypeTop: {
            if (eBrwWnd.meTopSlibingBrwView && !eBrwWnd.meTopSlibingBrwView.superview) {
                if (eBrwWnd.meBottomSlibingBrwView) {
                    if (eBrwWnd.meBottomSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_LOAD_FINISHED) {
                        [eBrwWnd addSubview:eBrwWnd.meBottomSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(2)"];
                        [eBrwWnd addSubview:eBrwWnd.meTopSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(1)"];
                    }
                } else {
                    [eBrwWnd addSubview:eBrwWnd.meTopSlibingBrwView];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(1)"];
                }
            }
            break;
        }
        case ACEUexWindowSlibingTypeBottom:
            if (eBrwWnd.meBottomSlibingBrwView && !eBrwWnd.meBottomSlibingBrwView.superview) {
                if (eBrwWnd.meTopSlibingBrwView) {
                    if (eBrwWnd.meTopSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_LOAD_FINISHED) {
                        [eBrwWnd addSubview:eBrwWnd.meTopSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(1)"];
                        [eBrwWnd addSubview:eBrwWnd.meBottomSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(2)"];
                    }
                } else {
                    [eBrwWnd addSubview:eBrwWnd.meBottomSlibingBrwView];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(2)"];
                }
            }
            break;
    }
}

#pragma mark - Evaluate Script API


- (void)evaluateScript:(NSMutableArray *)inArguments {
    if (!self.EBrwView || !self.EBrwView.meBrwWnd) {
        return;
    }
    ACArgsUnpack(NSString *inWndName,NSNumber *inSlibingType,NSString *inScript) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inWndName = stringArg(info[@"name"]);
        inSlibingType = numberArg(info[@"type"]);
        inScript = stringArg(info[@"js"]);
    }
    
    UEX_PARAM_GUARD_NOT_NIL(inScript);
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    if (inWndName.length > 0) {
        EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
        EBrowserWindow *tmpWindow = [eBrwWndContainer brwWndForKey:inWndName];
        eBrwWnd = tmpWindow ?: eBrwWnd;
    }
    
    if (eBrwWnd == nil) {
        return;
    }
    int slibingType = [inSlibingType intValue];
    EBrowserView *brwView = nil;
    switch (slibingType) {
        case ACEUexWindowSlibingTypeTop:
            brwView = eBrwWnd.meTopSlibingBrwView;
            break;
        case ACEUexWindowSlibingTypeBottom:
            brwView = eBrwWnd.meBottomSlibingBrwView;
            break;
        default:
            brwView = eBrwWnd.meBrwView;
            break;
    }
    if(!brwView){
        return;
    }
    [brwView evaluateScript:inScript];
}


- (void)evaluatePopoverScript:(NSMutableArray *)inArguments {
    if (!self.EBrwView.meBrwWnd) {
        return;
    }
    
    ACArgsUnpack(NSString *inWndName,NSString *inPopName,NSString *inScript) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inWndName = stringArg(info[@"windowName"]);
        inPopName = stringArg(info[@"popName"]);
        inScript = stringArg(info[@"js"]);
    }
    UEX_PARAM_GUARD_NOT_NIL(inScript);
    UEX_PARAM_GUARD_NOT_NIL(inPopName);
    
    EBrowserWindow *eBrwWnd = nil;
    EBrowserView *ePopBrwView = nil;
    
    if (!inWndName || inWndName.length == 0) {
        eBrwWnd = self.EBrwView.meBrwWnd;
    }
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:self.EBrwView];
    
    if (!eBrwWnd) {
        eBrwWnd = [eBrwWndContainer brwWndForKey:inWndName];
    }
    if (eBrwWnd == nil) {
        return;
    }
    ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    if (!ePopBrwView) {
        return;
    }
    [ePopBrwView evaluateScript:inScript];
}





- (void)evaluateMultiPopoverScript:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSString *windowName,__unused NSString *multiPopoverName,NSString *inPageName,NSString * inScript) = inArguments;
    
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        windowName = stringArg(info[@"windowName"]);
        inPageName = stringArg(info[@"pageName"]);
        inScript = stringArg(info[@"js"]);
    }
    UEX_PARAM_GUARD_NOT_NIL(inPageName);
    UEX_PARAM_GUARD_NOT_NIL(inScript);
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = eBrwWnd.winContainer;
    
    if (windowName && windowName.length > 0) {
        EBrowserWindow * tempWindow = [eBrwWndContainer brwWndForKey:windowName];
        if (tempWindow) {
            eBrwWnd = tempWindow;
        }
    }
    
    EBrowserView * ePopBrwView = [eBrwWnd.mPopoverBrwViewDict objectForKey:inPageName];
    if (!ePopBrwView) {
        return;
    }
    [ePopBrwView evaluateScript:inScript];
    
    
}

#pragma mark - Bounce API


- (NSNumber *)getBounce:(NSMutableArray *)inArguments{
    BOOL bounce = [self.EBrwView.mScrollView bounces];
    [self callbackWithKeyPath:@"uexWindow.cbBounceState" intData:bounce];
    return bounce ? @1 : @0;
}

- (void)setBounce:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *flag) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(flag);
    
    NSInteger value = [flag integerValue];
    switch (value) {
        case 0:
            [self.EBrwView.mScrollView setBounces:NO];
            break;
        case 1:
            [self.EBrwView.mScrollView setBounces:YES];
            break;
        default:
            break;
    }
    
    
}

- (void)notifyBounceEvent:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inType,NSNumber *inStatus) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inType);
    UEX_PARAM_GUARD_NOT_NIL(inStatus);
    
    int type = [inType intValue];
    int value = [inStatus intValue];
    
    switch (type) {
        case EBounceViewTypeTop:
            if (value == 0) {
                self.EBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH;
            } else {
                self.EBrwView.mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH;
            }
            break;
        case EBounceViewTypeBottom:
            if (value == 0) {
                self.EBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH;
            } else {
                self.EBrwView.mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH;
            }
            break;
        default:
            break;
    }
}

- (void)setbounceParams:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(NSNumber *inType,NSDictionary *bounceParams) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inType);
    UEX_PARAM_GUARD_NOT_NIL(bounceParams);
    
    self.bounceParams = [bounceParams mutableCopy];
    [self.bounceParams setValue:inType forKey:@"type"];
    
    int type = [inType intValue];
    EBrowserViewBounceView * targetBounceView = nil;
    
    switch (type)        {
        case EBounceViewTypeTop:
            targetBounceView = self.EBrwView.mTopBounceView;
            break;
        case EBounceViewTypeBottom:
            targetBounceView = self.EBrwView.mBottomBounceView;
            break;
        default:
            break;
    }
    if (targetBounceView) {
        NSString *levelText =  stringArg(bounceParams[@"levelText"]);
        if (levelText && levelText.length > 0) {
            [targetBounceView setLevelText:levelText];
        }
    }
    
    

    NSString *imageInPath = nil;
//#warning 企业版的设置?
    if ([inArguments count] ==3){
        NSString * pjID=[inArguments objectAtIndex:2];
        if ([pjID isEqualToString:@"donghang"]){
            self.EBrwView.mBottomBounceView.projectID=pjID;
            self.EBrwView.mTopBounceView.projectID=pjID;
            [self.bounceParams setObject:pjID forKey:@"projectID"];
        }
        imageInPath = stringArg(bounceParams[@"loadingImagePath"]);
    }
    if (imageInPath) {
        imageInPath = [self absPath:imageInPath];
        [self.bounceParams setObject:imageInPath forKey:@"loadingImagePath"];
    }
    
    
    
    
    NSString * imagePath = stringArg(bounceParams[@"imagePath"]);
    if (imagePath && imagePath.length > 0) {
        imagePath = [super absPath:imagePath];
        [self.bounceParams setObject:imagePath forKey:@"imagePath"];
    }
    
    NSString *textColor =stringArg(bounceParams[@"textColor"]);
    if (textColor && textColor.length>0) {
        UIColor *color = [EUtility colorFromHTMLString:textColor];
        [self.bounceParams setObject:color forKey:@"textColor"];
    }
    
    
}

- (void)topBounceViewRefresh:(NSMutableArray *)inArguments {
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain && self.EBrwView.mType != ACEEBrowserViewTypePopover) {
        return;
    }
    [self.EBrwView topBounceViewRefresh];
    
}

- (void)showBounceView:(NSMutableArray *)inArguments {
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain && self.EBrwView.mType != ACEEBrowserViewTypePopover) {
        return;
    }
    
    ACArgsUnpack(NSNumber *inType,NSString *inColor,NSNumber *inFlag) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inType = numberArg(info[@"type"]);
        inColor = stringArg(info[@"color"]);
        inFlag = numberArg(info[@"flag"]);
    }
    
    EBounceViewType type = [inType integerValue];
    UIColor *color = [UIColor ac_ColorWithHTMLColorString:inColor] ?: RGBCOLOR(226, 231, 237);
    
    BOOL shouldShowBounceViewContent = ([inFlag intValue] & F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM);
    
    switch (type) {
        case EBounceViewTypeTop:
            if (!self.EBrwView.mTopBounceView) {
                if (shouldShowBounceViewContent) {
                    self.EBrwView.mTopBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, -self.EBrwView.bounds.size.height, self.EBrwView.bounds.size.width, self.EBrwView.bounds.size.height) andType:EBounceViewTypeTop params:self.bounceParams];
                    [self.EBrwView.mTopBounceView setStatus:EBounceViewStatusPullToReload];
                } else {
                    self.EBrwView.mTopBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, -self.EBrwView.bounds.size.height, self.EBrwView.bounds.size.width, self.EBrwView.bounds.size.height)];
                }
                
                self.EBrwView.mTopBounceView.backgroundColor = color;
                self.EBrwView.mTopBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [self.EBrwView.mScrollView addSubview:self.EBrwView.mTopBounceView];
            } else if (self.EBrwView.mTopBounceView.hidden == YES) {
                self.EBrwView.mTopBounceView.hidden = NO;
            } else if (self.EBrwView.mTopBounceView) {
                if (shouldShowBounceViewContent) {
                    [self.EBrwView.mTopBounceView resetDataWithType:EBounceViewTypeTop andParams:self.bounceParams];
                    [self.EBrwView.mTopBounceView setStatus:EBounceViewStatusPullToReload];
                }
                self.EBrwView.mTopBounceView.backgroundColor = color;
                self.EBrwView.mTopBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            }
            break;
        case EBounceViewTypeBottom:
            if (!self.EBrwView.mBottomBounceView) {
                if (shouldShowBounceViewContent) {
                    self.EBrwView.mBottomBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, self.EBrwView.mScrollView.contentSize.height, self.EBrwView.bounds.size.width, self.EBrwView.bounds.size.height) andType:EBounceViewTypeBottom params:self.bounceParams];
                    [self.EBrwView.mBottomBounceView setStatus:EBounceViewStatusPullToReload];
                } else {
                    self.EBrwView.mBottomBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, self.EBrwView.mScrollView.contentSize.height, self.EBrwView.bounds.size.width, self.EBrwView.bounds.size.height)];
                }
                self.EBrwView.mBottomBounceView.backgroundColor = color;
                self.EBrwView.mBottomBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [self.EBrwView.mScrollView addSubview:self.EBrwView.mBottomBounceView];
                if (self.EBrwView.mScrollView.contentSize.height < self.EBrwView.mScrollView.frame.size.height) {
                    self.EBrwView.mBottomBounceView.hidden = YES;
                } else {
                    self.EBrwView.mBottomBounceView.hidden = NO;
                }
                
            } else if (self.EBrwView.mBottomBounceView.hidden == YES) {
                [self.EBrwView.mBottomBounceView setFrame:CGRectMake(0, self.EBrwView.mScrollView.contentSize.height, self.EBrwView.bounds.size.width, self.EBrwView.bounds.size.height)];
                self.EBrwView.mBottomBounceView.hidden = NO;
            } else if (self.EBrwView.mBottomBounceView) {
                if (shouldShowBounceViewContent) {
                    [self.EBrwView.mBottomBounceView resetDataWithType:EBounceViewTypeBottom andParams:self.bounceParams];
                    [self.EBrwView.mBottomBounceView setStatus:EBounceViewStatusPullToReload];
                }
                self.EBrwView.mBottomBounceView.backgroundColor = color;
                self.EBrwView.mBottomBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            }
            break;
    }
}

- (void)hiddenBounceView:(NSMutableArray *)inArguments {
    
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain && self.EBrwView.mType != ACEEBrowserViewTypePopover) {
        return;
    }
    ACArgsUnpack(NSNumber *inType) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inType);
    
    EBounceViewType type = [inType integerValue];
    
    switch (type) {
        case EBounceViewTypeTop:
            if (self.EBrwView.mTopBounceView) {
                self.EBrwView.mTopBounceView.hidden = YES;
            }
            break;
        case EBounceViewTypeBottom:
            if (self.EBrwView.mBottomBounceView) {
                self.EBrwView.mBottomBounceView.hidden = YES;
            }
            break;
    }
}

- (void)resetBounceView:(NSMutableArray *)inArguments {
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain && self.EBrwView.mType != ACEEBrowserViewTypePopover) {
        return;
    }
    ACArgsUnpack(NSNumber *inType) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inType);
    EBounceViewType type = [inType integerValue];
    
    switch (type) {
        case EBounceViewTypeTop:
            [self.EBrwView bounceViewFinishLoadWithType:EBounceViewTypeTop];
            break;
        case EBounceViewTypeBottom:
            [self.EBrwView bounceViewFinishLoadWithType:EBounceViewTypeBottom];
            break;
        default:
            break;
    }
}














#pragma mark - Open Popover & MultiPopover API


- (void)openPopover:(NSMutableArray *)inArguments {
    
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType == ACEEBrowserViewTypePopover) {
        return;
    }
    
    ACArgsUnpack(NSString *inPopName,NSNumber *inDataType,NSString *inUrl,NSString *inData,NSNumber *inX,NSNumber *inY,NSNumber *inW,NSNumber *inH,NSNumber *inFontSize,NSNumber *inFlag,NSNumber *inBottom,NSDictionary *extras) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inPopName = stringArg(info[@"name"]);
        inDataType = numberArg(info[@"dataType"]);
        inUrl = stringArg(info[@"url"]);
        inData = stringArg(info[@"data"]);
        inX = numberArg(info[@"x"]);
        inY = numberArg(info[@"y"]);
        inW = numberArg(info[@"w"]);
        inH = numberArg(info[@"h"]);
        inFontSize = numberArg(info[@"fontSize"]);
        inFlag = numberArg(info[@"flag"]);
        inBottom = numberArg(info[@"bottomMargin"]);
        extras = dictionaryArg(info[@"extras"]);
    }
    NSDictionary *extraInfo = dictionaryArg(extras[@"extraInfo"]);
    
    
    UEX_PARAM_GUARD_NOT_NIL(inPopName);
    
    
    CGFloat x = inX ? inX.floatValue : 0;
    CGFloat y = inY ? inY.floatValue : 0;
    CGFloat w = inW ? inW.floatValue : self.EBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.width;
    CGFloat h = inH ? inH.floatValue : self.EBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.height;
    UEX_PARAM_GUARD(w > 0);
    UEX_PARAM_GUARD(h > 0);
    CGFloat fontSize = inFontSize.floatValue;
    CGFloat bottom = inBottom.floatValue;
    if (bottom > 0) {
        h = self.EBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.height - y - bottom;
    }
    
    [self openPopoverWithName:inPopName
                     openFlag:inFlag.integerValue
                         data:inData url:inUrl
                     dataType:inDataType.integerValue
                        frame:CGRectMake(x, y, w, h)
                     fontSize:fontSize bottom:bottom
                    extraInfo:extraInfo
               isMultiPopover:NO
                 inScrollView:nil];
    
}


- (void)openMultiPopover:(NSMutableArray *)inArguments{
    if (!self.EBrwView) {
        return;
    }
    
    ACArgsUnpack(NSDictionary *inContent,NSString *inMainPopName,NSNumber *inDataType,NSNumber *inX,NSNumber *inY,NSNumber *inW,NSNumber *inH,NSNumber *inFontSize,NSNumber *inFlag,NSNumber *popIndex,NSDictionary *extras) = inArguments;
    
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inContent = dictionaryArg(info[@"content"]);
        inDataType = numberArg(info[@"dataType"]);
        inX = numberArg(info[@"x"]);
        inY = numberArg(info[@"y"]);
        inW = numberArg(info[@"w"]);
        inH = numberArg(info[@"h"]);
        inFontSize = numberArg(info[@"fontSize"]);
        inFlag = numberArg(info[@"flag"]);
        popIndex = numberArg(info[@"indexSelected"]);
        extras = dictionaryArg(info[@"extras"]);
    }
    
    UEX_PARAM_GUARD_NOT_NIL(inContent);
    UEX_PARAM_GUARD_NOT_NIL(inMainPopName);
    
    
    NSArray * contentArray = arrayArg(inContent[@"content"]);
    UEX_PARAM_GUARD_NOT_NIL(contentArray);
    
    
    NSInteger startPageIndex = popIndex ? popIndex.integerValue : 0;
    CGFloat x = inX ? inX.floatValue : 0;
    CGFloat y = inY ? inY.floatValue : 0;
    CGFloat w = inW ? inW.floatValue : self.EBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.width;
    CGFloat h = inH ? inH.floatValue : self.EBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.height;
    UexWindowOpenFlag flag = inFlag.integerValue;
    CGFloat fontSize = inFontSize.floatValue;
    UEX_PARAM_GUARD(w > 0);
    UEX_PARAM_GUARD(h > 0);
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    NSInteger multipopCount = [contentArray count];
    EScrollView * multiPopover = [[EScrollView alloc]initWithFrame:CGRectMake(x,y,w,h)];
    multiPopover.userInteractionEnabled = YES;
    ACEMultiPopoverScrollView * scrollView = [[ACEMultiPopoverScrollView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [scrollView setPagingEnabled: YES] ;
    [scrollView setContentSize: CGSizeMake(scrollView.bounds.size.width * multipopCount, scrollView.bounds.size.height)] ;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.tag = 100000;
    if (!eBrwWnd.mMuiltPopoverDict) {
        eBrwWnd.mMuiltPopoverDict = [NSMutableDictionary dictionary];
    }
    [eBrwWnd.mMuiltPopoverDict setObject:multiPopover forKey:inMainPopName];
    multiPopover.scrollView = scrollView;
    multiPopover.mainPopName = inMainPopName;
    [multiPopover addSubview:scrollView];
    [eBrwWnd addSubview:multiPopover];
    
    if (extras) {
        NSDictionary * extraDic = [extras objectForKey:@"extraInfo"];
        [self setExtraInfo:extraDic toEBrowserView:multiPopover];
    }
    
    //打开多个pop窗口
    for (int i = 0; i < multipopCount ; i++){
        CGFloat popX = i * w;
        CGFloat popY = 0;
        NSDictionary * pageInfo = dictionaryArg(contentArray[i]);
        NSString *inPopName = stringArg(pageInfo[@"inPageName"]);
        NSString *inUrl = stringArg(pageInfo[@"inUrl"]);
        NSString *inData = stringArg(pageInfo[@"inData"]);
        NSDictionary *extraInfo = dictionaryArg(pageInfo[@"extraInfo"]);
        if (inPopName.length == 0) {
            continue;
        }
        @weakify(scrollView);
        [scrollView addLoadingBlock:^{
            @strongify(scrollView);
            [self openPopoverWithName:inPopName
                             openFlag:flag
                                 data:inData
                                  url:inUrl
                             dataType:inDataType.integerValue
                                frame:CGRectMake(popX, popY, w, h)
                             fontSize:fontSize
                               bottom:0
                            extraInfo:extraInfo
                       isMultiPopover:YES
                         inScrollView:scrollView];
            
        }];
        
    }
    [scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * startPageIndex, scrollView.contentOffset.y) animated: NO] ;
    [scrollView startLoadingPopViewAtIndex:startPageIndex];
}


- (void)openPopoverWithName:(NSString *)inPopName
                   openFlag:(UexWindowOpenFlag)flag
                       data:(NSString *)inData
                        url:(NSString *)inUrl
                   dataType:(UexWindowOpenDataType)dataType
                      frame:(CGRect)frame
                   fontSize:(CGFloat)fontSize
                     bottom:(CGFloat)bottom
                  extraInfo:(NSDictionary *)extraInfo
             isMultiPopover:(BOOL)isMultiPopover
               inScrollView:(ACEMultiPopoverScrollView *)scrollView{
    
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    BOOL isExist = YES;
    EBrowserView * ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    if (!ePopBrwView){
        ePopBrwView = [[EBrowserView alloc] initWithFrame:frame
                                                BrwCtrler:self.EBrwView.meBrwCtrler
                                                      Wgt:self.EBrwView.mwWgt
                                                   BrwWnd:eBrwWnd
                                               UExObjName:inPopName
                                                     Type:ACEEBrowserViewTypePopover];
        if (fontSize > 0){
            [ePopBrwView.mPageInfoDict setObject:@(fontSize) forKey:@"pFontSize"];
        }
        [eBrwWnd.mPopoverBrwViewDict setObject:ePopBrwView forKey:inPopName];
        [eBrwWnd.mPreOpenArray addObject:inPopName];
        isExist = NO;
    } else {
        ePopBrwView.frame = frame;
    }
    
    ePopBrwView.isMuiltPopover = isMultiPopover;
    
    if (flag & UexWindowOpenFlagOpaque){
        ePopBrwView.backgroundColor = [UIColor whiteColor];
    }
    if (flag & UexWindowOpenFlagEnableScale)    {
        [ePopBrwView setScalesPageToFit:YES];
        [ePopBrwView setMultipleTouchEnabled:YES];
    }
    ePopBrwView.mFlag = 0;
    if (flag & UexWindowOpenFlagDisableCrossDomain){
        ePopBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    if (flag & UexWindowOpenFlagOauth){
        ePopBrwView.mFlag |= F_EBRW_VIEW_FLAG_OAUTH;
    }
    [self setExtraInfo:extraInfo toEBrowserView:ePopBrwView];
    
    if (isExist && inData.length == 0) {
        [eBrwWnd bringSubviewToFront:ePopBrwView];
        return;
    }
    
    switch (dataType) {
        case UexWindowOpenDataTypeURL: {
            NSURL *url = [self parseWebviewURL:inUrl];
            NSString *urlStr = url.absoluteString;
            if (eBrwWnd.winContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION && ![urlStr hasPrefix:F_HTTP_PATH]&& ![urlStr hasPrefix:F_HTTPS_PATH]) {
                FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                NSString *data = [encryptObj decryptWithPath:url appendData:nil];
                [ePopBrwView loadWithData:data baseUrl:url];
            } else {
                [ePopBrwView loadWithUrl:url];
            }
            
            //Data Analysis
            if (isExist) {
                NSString *curUrlStr =[ePopBrwView.curUrl absoluteString];
                if (![curUrlStr isEqualToString:urlStr]) {
                    int type =ePopBrwView.mwWgt.wgtType;
                    NSString *viewName =[ePopBrwView.curUrl absoluteString];
                    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
                    [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
                    NSString *fromViewName =[eBrwWnd.meBrwView.curUrl absoluteString];
                    int goType = eBrwWnd.meBrwView.mwWgt.wgtType;
                    NSString *goViewName =[url absoluteString];
                    appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eBrwWnd.meBrwView.mwWgt];
                    [BUtility setAppCanViewActive:goType opener:fromViewName name:goViewName openReason:0 mainWin:1 appInfo:appInfo];
                }
            }else {
                NSString *viewName =[eBrwWnd.meBrwView.curUrl absoluteString];
                int goType = ePopBrwView.mwWgt.wgtType;
                NSString *goViewName =[url absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
                [BUtility setAppCanViewActive:goType opener:viewName name:goViewName openReason:0 mainWin:1 appInfo:appInfo];
            }
            
            break;
        }
        case UexWindowOpenDataTypeHTMLData: {
            [ePopBrwView loadWithData:inData baseUrl:self.EBrwView.curUrl];
            break;
        }
        case UexWindowOpenDataTypeURLAndHTMLData: {
            NSURL *url = [self parseWebviewURL:inUrl];
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *data = [encryptObj decryptWithPath:url appendData:inData];
            [ePopBrwView loadWithData:data baseUrl:url];
            break;
        }
    }
    if (bottom > 0){
        ePopBrwView.bottom = bottom;//footer的高度
        [ePopBrwView registerKeyboardChangeEvent];
    }
    if (isMultiPopover){
        [scrollView addSubview:ePopBrwView];
    }else{
        [eBrwWnd addSubview:ePopBrwView];
    }
}


#pragma mark - Close Popover & MultiPopover API


- (void)closePopover:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inPopName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inPopName);
    
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
    ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    if (ePopBrwView) {
        [eBrwWnd removeFromPopBrwViewDict:inPopName];
        [ePopBrwView removeFromSuperview];
        
        //8.8 数据统计
        int type =ePopBrwView.mwWgt.wgtType;
        NSString *viewName =[ePopBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
    }
}

- (void)closeMultiPopover:(NSMutableArray *)inArguments{
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    if (!eBrwWnd.mMuiltPopoverDict) {
        return;
    }
    
    ACArgsUnpack(NSString *inMultiPopoverName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inMultiPopoverName);
    
    EScrollView * multiPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:inMultiPopoverName];
    UIScrollView * scrolView = multiPopover.scrollView;
    for (EBrowserView * popView in [scrolView subviews]){
        NSString * inPopName = [popView respondsToSelector:@selector(muexObjName)] ? [popView muexObjName] : nil;
        if (inPopName.length > 0){
            EBrowserView *ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
            if (ePopBrwView){
                [eBrwWnd removeFromPopBrwViewDict:inPopName];
                [ePopBrwView removeFromSuperview];
                //8.8 数据统计
                int type = ePopBrwView.mwWgt.wgtType;
                NSString *viewName =[ePopBrwView.curUrl absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
                [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            }
        }
    }
    [multiPopover removeFromSuperview];
    [eBrwWnd.mMuiltPopoverDict removeObjectForKey:inMultiPopoverName];
}





#pragma mark - Popover Control API




- (void)insertPopoverAbovePopover:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_WINDOW();
    ACArgsUnpack(NSString *nameA,NSString *nameB) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(nameA);
    UEX_PARAM_GUARD_NOT_NIL(nameB);
    
    NSMutableDictionary *popoverDict = self.EBrwView.meBrwWnd.mPopoverBrwViewDict;
    if (!popoverDict) {
        return;
    }
    UIView *viewA = [popoverDict objectForKey:nameA];
    UIView *viewB = [popoverDict objectForKey:nameB];
    if (!viewA || !viewB) {
        return;
    }
    [self.EBrwView.meBrwWnd insertSubview:viewA aboveSubview:viewB];
}

- (void)insertPopoverBelowPopover:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_WINDOW();
    ACArgsUnpack(NSString *nameA,NSString *nameB) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(nameA);
    UEX_PARAM_GUARD_NOT_NIL(nameB);
    
    NSMutableDictionary *popoverDict = self.EBrwView.meBrwWnd.mPopoverBrwViewDict;
    if (!popoverDict) {
        return;
    }
    UIView *viewA = [popoverDict objectForKey:nameA];
    UIView *viewB = [popoverDict objectForKey:nameB];
    if (!viewA || !viewB) {
        return;
    }
    [self.EBrwView.meBrwWnd insertSubview:viewA belowSubview:viewB];
}

- (void)sendPopoverToBack:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_WINDOW();
    ACArgsUnpack(NSString *popName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(popName);
    UIView *popView = [self.EBrwView.meBrwWnd.mPopoverBrwViewDict objectForKey:popName];
    [self.EBrwView.meBrwWnd insertSubview:popView aboveSubview:self.EBrwView.meBrwWnd.meBrwView];
}

- (void)bringPopoverToFront:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_WINDOW();
    ACArgsUnpack(NSString *popName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(popName);
    UIView *popView = [self.EBrwView.meBrwWnd.mPopoverBrwViewDict objectForKey:popName];
    [self.EBrwView.meBrwWnd bringSubviewToFront:popView];
}

- (void)insertAbove:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_POPOVER();
    ACArgsUnpack(NSString *popName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(popName);
    UIView *popView = [self.EBrwView.meBrwWnd.mPopoverBrwViewDict objectForKey:popName];
    [self.EBrwView.meBrwWnd insertSubview:self.EBrwView aboveSubview:popView];
}

- (void)insertBelow:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_POPOVER();
    ACArgsUnpack(NSString *popName) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(popName);
    UIView *popView = [self.EBrwView.meBrwWnd.mPopoverBrwViewDict objectForKey:popName];
    [self.EBrwView.meBrwWnd insertSubview:self.EBrwView belowSubview:popView];
}

- (void)bringToFront:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_POPOVER();
    [self.EBrwView.meBrwWnd bringSubviewToFront:self.EBrwView];
}

- (void)sendToBack:(NSMutableArray *)inArguments {
    UEX_WINDOW_GUARD_USE_IN_POPOVER();
    [self.EBrwView.meBrwWnd insertSubview:self.EBrwView aboveSubview:self.EBrwView.meBrwWnd.meBrwView];
}

- (void)setPopoverFrame:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *inPopName,NSNumber *inX,NSNumber *inY,NSNumber *inW,NSNumber *inH) = inArguments;
    
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        inPopName = stringArg(info[@"name"]);
        inX = numberArg(info[@"x"]);
        inY = numberArg(info[@"y"]);
        inW = numberArg(info[@"w"]);
        inH = numberArg(info[@"h"]);
    }
    
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = self.EBrwView.meBrwWnd;
    UEX_PARAM_GUARD_NOT_NIL(inPopName)
    ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    if (!ePopBrwView) {
        return;
    }
    CGFloat x = inX ? inX.floatValue : ePopBrwView.frame.origin.x;
    CGFloat y = inY ? inY.floatValue : ePopBrwView.frame.origin.y;
    CGFloat w = inW ? inW.floatValue : ePopBrwView.frame.size.width;
    CGFloat h = inH ? inH.floatValue : ePopBrwView.frame.size.height;
    
    
    [ePopBrwView setFrame:CGRectMake(x, y, w, h)];
    if (ePopBrwView.mBottomBounceView && h != 0) {
        ePopBrwView.mBottomBounceView.frame = CGRectMake(ePopBrwView.mBottomBounceView.frame.origin.x, ePopBrwView.mScrollView.contentSize.height, w, h);
    }
}

#pragma mark - MultiPopover Control API


- (void)setMultiPopoverFrame:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *popoverName,NSNumber *inX,NSNumber *inY,NSNumber *inW,NSNumber *inH) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        popoverName = stringArg(info[@"name"]);
        inX = numberArg(info[@"x"]);
        inY = numberArg(info[@"y"]);
        inW = numberArg(info[@"w"]);
        inH = numberArg(info[@"h"]);
    }
    
    
    UEX_PARAM_GUARD_NOT_NIL(popoverName);
    UEX_PARAM_GUARD_NOT_NIL(inX);
    UEX_PARAM_GUARD_NOT_NIL(inY);
    
    CGFloat x = inX ? inX.floatValue : 0;
    CGFloat y = inY ? inY.floatValue : 0;
    CGFloat w = inW ? inW.floatValue : self.EBrwView.meBrwWnd.bounds.size.width;
    CGFloat h = inH ? inH.floatValue : self.EBrwView.meBrwWnd.bounds.size.height;
    
    
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
    EScrollView * muiltPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:popoverName];
    
    if (muiltPopover) {
        
        muiltPopover.frame = CGRectMake(x, y, w, h);
        muiltPopover.scrollView.frame = CGRectMake(0, 0, w, h);
        for(UIView *view in muiltPopover.scrollView.subviews){
            if (![view isKindOfClass:[EBrowserView class]]) {
                continue;
            }
            CGRect newFrame = view.frame;
            newFrame.size.height = h;
            newFrame.size.width = w;
            view.frame = newFrame;
        }
    }
}

- (void)setSelectedPopOverInMultiWindow:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *popName,NSNumber *indexNum) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        popName = stringArg(info[@"name"]);
        indexNum = numberArg(info[@"index"]);
    }
    
    
    UEX_PARAM_GUARD_NOT_NIL(popName);
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
    EScrollView * multiPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:popName];
    UIScrollView * scrollView = multiPopover.scrollView;
    [scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * indexNum.integerValue, scrollView.contentOffset.y) animated: NO];
}


- (void)setMultilPopoverFlippingEnbaled:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *flag) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(flag);
    BOOL multiPopoverFlippingEnbaled = ![flag boolValue];
    if(self.EBrwView.meBrwWnd.mMuiltPopoverDict){
        for (EScrollView *eScrollV in self.EBrwView.meBrwWnd.mMuiltPopoverDict.allValues) {
            if (![eScrollV isKindOfClass:[EScrollView class]]) {
                continue;
            }
            UIScrollView *scrollView = eScrollV.scrollView;
            scrollView.scrollEnabled = multiPopoverFlippingEnbaled;
        }
    };
}




#pragma mark cbOpenMultiPopover
// Scrollview Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    EScrollView *scrollV = (EScrollView *)scrollView.superview;
    CGFloat pageWidth = scrollV.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    NSInteger nearestNumber = lround(fractionalPage) ;
    NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)nearestNumber];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (scrollV.mainPopName) {
        [dict setObject:scrollV.mainPopName forKey:APP_JSON_KEY_MULTIPOPNAME];
    }
    if (indexStr) {
        [dict setObject:indexStr forKey:APP_JSON_KEY_MULTIPOPSELECTEDNUM];
    }
    NSString *info = [dict JSONFragment];
    [self callbackWithKeyPath:@"uexWindow.cbOpenMultiPopover" jsonData:info];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    EScrollView *scrollV = (EScrollView *)scrollView.superview;
    CGFloat pageWidth = scrollV.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    NSInteger nearestNumber = lround(fractionalPage) ;
    NSString *indexStr = [NSString stringWithFormat:@"%ld", (long)nearestNumber];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (scrollV.mainPopName) {
        [dict setObject:scrollV.mainPopName forKey:APP_JSON_KEY_MULTIPOPNAME];
    }
    if (indexStr) {
        [dict setObject:indexStr forKey:APP_JSON_KEY_MULTIPOPSELECTEDNUM];
    }
    NSString *info = [dict JSONFragment];
    
    [self callbackWithKeyPath:@"uexWindow.cbOpenMultiPopover" jsonData:info];
}





#pragma mark - Preopen API



- (void)preOpenStart:(NSMutableArray *)inArguments {
    if (!self.EBrwView.meBrwWnd.mPreOpenArray) {
        self.EBrwView.meBrwWnd.mPreOpenArray = [[NSMutableArray alloc]initWithCapacity:2];
    }
    [self.EBrwView.meBrwWnd.mPreOpenArray removeAllObjects];
    self.EBrwView.meBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_FINISH_PREOPEN;
}

- (void)preOpenFinish:(NSMutableArray *)inArguments {
    self.EBrwView.meBrwWnd.mFlag |= F_EBRW_WND_FLAG_FINISH_PREOPEN;
    if (self.EBrwView.meBrwWnd.mPreOpenArray.count == 0) {
        [self.EBrwView.meBrwCtrler.meBrw notifyLoadPageFinishOfBrwView:self.EBrwView];
    }
}

#pragma mark - Animation API

- (void)beginAnimition:(NSMutableArray *)inArguments {
    if (!self.meBrwAnimi) {
        self.meBrwAnimi = [[EBrowserViewAnimition alloc]init];
    } else {
        [self.meBrwAnimi clean];
    }
}

- (void)setAnimitionDelay:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *delay) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(delay)
    self.meBrwAnimi.mDelay = [delay floatValue]/1000.0f;
}

- (void)setAnimitionDuration:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *duration) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(duration);
    self.meBrwAnimi.mDuration = [duration floatValue]/1000.0f;
}

- (void)setAnimitionCurve:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *curve) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(curve);
    
    self.meBrwAnimi.mCurve = [curve intValue];
}

- (void)setAnimitionRepeatCount:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *repeatCount) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(repeatCount);
    self.meBrwAnimi.mRepeatCount = [repeatCount floatValue];
}

- (void)setAnimitionAutoReverse:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *autoReverseEnable) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(autoReverseEnable);
    self.meBrwAnimi.mAutoReverse = autoReverseEnable.boolValue;
}

- (void)makeAlpha:(NSMutableArray *)inArguments {
    NSString *alphaStr = [inArguments objectAtIndex:0];
    float alpha = [alphaStr floatValue];
    self.meBrwAnimi.mAlpha = alpha;
}

- (void)makeTranslation:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *x,NSNumber *y,NSNumber *z) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(x);
    UEX_PARAM_GUARD_NOT_NIL(y);
    UEX_PARAM_GUARD_NOT_NIL(z);
    BAnimationTransform *transfrom = [[BAnimationTransform alloc]init];
    transfrom.mTransForm3D = CATransform3DMakeTranslation(x.floatValue,y.floatValue,z.floatValue);
    [self.meBrwAnimi.mTransformArray addObject:transfrom];
    
}

- (void)makeScale:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *x,NSNumber *y,NSNumber *z) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(x);
    UEX_PARAM_GUARD_NOT_NIL(y);
    UEX_PARAM_GUARD_NOT_NIL(z);
    BAnimationTransform *transfrom = [[BAnimationTransform alloc]init];
    transfrom.mTransForm3D = CATransform3DMakeScale(x.floatValue,y.floatValue,z.floatValue);
    [self.meBrwAnimi.mTransformArray addObject:transfrom];
    
}

- (void)makeRotate:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *angle,NSNumber *x,NSNumber *y,NSNumber *z) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(angle)
    UEX_PARAM_GUARD_NOT_NIL(x);
    UEX_PARAM_GUARD_NOT_NIL(y);
    UEX_PARAM_GUARD_NOT_NIL(z);
    BAnimationTransform *transfrom = [[BAnimationTransform alloc]init];
    CGFloat radian = (angle.floatValue/180.0f) * M_PI;
    transfrom.mTransForm3D = CATransform3DMakeRotation(radian,x.floatValue,y.floatValue,z.floatValue);
    [self.meBrwAnimi.mTransformArray addObject:transfrom];
    
}

- (void)commitAnimition:(NSMutableArray *)inArguments {
    if (!self.meBrwAnimi) {
        return;
    }
    [self.meBrwAnimi doAnimition:self.EBrwView];
}


#pragma mark - Orentation & Rotate API

- (void)setAutorotateEnable:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *autoRotate) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(autoRotate);
    NSString * orientaion = [BUtility getMainWidgetConfigInterface];
    [[NSUserDefaults standardUserDefaults] setObject:orientaion forKey:@"subwgtOrientaion"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
    BOOL isAutorotate = ![autoRotate boolValue];
    theApp.drawerController.canAutorotate = isAutorotate;
}
- (void)setOrientation:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *orientation) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(orientation);
    
    int orientationNumber = [orientation intValue];
    theApp.drawerController.canRotate = YES;
    [[NSUserDefaults standardUserDefaults] setObject:orientation.stringValue forKey:@"subwgtOrientaion"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
    switch (orientationNumber){
        case 1:
        case 5:{
            [BUtility rotateToOrientation:UIInterfaceOrientationPortrait];
            break;
        }
        case 3:
        case 8:
        case 10:{
            [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
            break;
        }
        case 2:
        case 9:{
            [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeRight];
            break;
        }
        case 4:{
            [BUtility rotateToOrientation:UIInterfaceOrientationPortraitUpsideDown];
            break;
        }
        default:
            return;
            break;
    }
    
    
    theApp.drawerController.canRotate = NO;
    
    
}
#pragma mark - Loading Image API
- (void)setLoadingImagePath:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *loadingImagePath = stringArg(info[@"loadingImagePath"]);
    NSNumber *loadingImageTime = numberArg(info[@"loadingImageTime"]);
    UEX_PARAM_GUARD_NOT_NIL(loadingImagePath);
    UEX_PARAM_GUARD_NOT_NIL(loadingImageTime);
    
    NSInteger AppCanLaunchTime = [loadingImageTime integerValue];
    if (loadingImagePath.length == 0) {
        //取消自定义启动图
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kACECustomLoadingImagePathKey];
        return;
    }
    if (AppCanLaunchTime <= 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:loadingImagePath forKey:kACECustomLoadingImagePathKey];
    [[NSUserDefaults standardUserDefaults] setValue:@(AppCanLaunchTime) forKey:kACECustomLoadingImageTimeKey];
    
}




#pragma mark - Progress Dialog API
- (void)createProgressDialog:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *title,NSString *text,NSNumber *canCancel) = inArguments;
    NSDictionary *info = dictionaryArg(inArguments.firstObject);
    if (info) {
        title = stringArg(info[@"title"]);
        text = stringArg(info[@"msg"]);
        canCancel = numberArg(info[@"canCancel"]);
    }
    
    [[ACEProgressDialog sharedDialog]showWithTitle:title text:text canCancel:!canCancel.boolValue];
}


- (void)destroyProgressDialog:(NSMutableArray *)inArguments{
    [[ACEProgressDialog sharedDialog]hide];
}
#pragma mark - StatusBar API

- (void)hideStatusBar:(NSArray *)inArgument {
    theApp.drawerController.isStatusBarHidden = YES;
    if (![[[[NSBundle mainBundle]infoDictionary] objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue]) {
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
    } else {
        [theApp.drawerController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)showStatusBar:(NSArray *)inArgument {
    theApp.drawerController.isStatusBarHidden = NO;
    if (![[[[NSBundle mainBundle]infoDictionary] objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue]) {
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
    } else {
        [theApp.drawerController setNeedsStatusBarAppearanceUpdate];
    }
}

//设置状态条上字体的颜色
- (void)setStatusBarTitleColor:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *colorFlag) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(colorFlag);
    NSInteger flag = colorFlag.integerValue;
    switch (flag) {
        case 0:
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            break;
        case 1:
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            break;
        default:
            break;
    }
}
#pragma mark - StatusBar Notification API

- (void)closeStatusBarNotification {
    NSString *text = nil;
    UIInterfaceOrientation  statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (eBrwMainFrm.mNotifyArray.count > 0) {
        text = [eBrwMainFrm.mNotifyArray objectAtIndex:0];
    }
    if (eBrwMainFrm.mSBWnd) {
        if (text && (eBrwMainFrm.mSBWnd.mInitOrientation == statusBarOrientation)) {
            eBrwMainFrm.mSBWnd.hidden = NO;
            if (eBrwMainFrm.mSBWndTimer) {
                [eBrwMainFrm.mSBWndTimer invalidate];
                eBrwMainFrm.mSBWndTimer = nil;
            }
            [eBrwMainFrm.mSBWnd setNotifyText:text];
            AudioServicesPlaySystemSound(eBrwMainFrm.mSBWnd.mAlertSoundID);
            [eBrwMainFrm.mNotifyArray removeObjectAtIndex:0];
            eBrwMainFrm.mSBWndTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(closeStatusBarNotification) userInfo:nil repeats:NO];
            return;
        }
        eBrwMainFrm.mSBWnd.hidden = YES;
        if (eBrwMainFrm.mSBWndTimer) {
            [eBrwMainFrm.mSBWndTimer invalidate];
            eBrwMainFrm.mSBWndTimer = nil;
        }
    }
}

- (void)statusBarNotification:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSString *title,id msg) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(title);
    UEX_PARAM_GUARD_NOT_NIL(msg);
    
    if ([inArguments count]<2) {
        return;
    }
    
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect sbFrame = [[UIApplication sharedApplication] statusBarFrame];
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        UIApplication *app = [UIApplication sharedApplication];
        switch (app.statusBarOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                sbFrame = CGRectMake([UIScreen mainScreen].bounds.size.width - 20, 0, 20, [UIScreen mainScreen].bounds.size.height);
                break;
            case UIDeviceOrientationLandscapeRight:
                sbFrame = CGRectMake(0, 0, 20, [UIScreen mainScreen].bounds.size.height);
                break;
            case UIDeviceOrientationPortrait:
                sbFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                sbFrame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 20, [UIScreen mainScreen].bounds.size.width, 20);
                break;
            default:
                sbFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
                break;
        }
    }
    if (!eBrwMainFrm.mSBWnd) {
        eBrwMainFrm.mSBWnd = [[BStatusBarWindow alloc] initWithFrame:sbFrame andNotifyText:title];
        AudioServicesPlaySystemSound(eBrwMainFrm.mSBWnd.mAlertSoundID);
        [eBrwMainFrm.mSBWnd makeKeyAndVisible];
    } else {
        if (eBrwMainFrm.mSBWnd.mInitOrientation == statusBarOrientation) {
            if (eBrwMainFrm.mSBWnd.hidden == YES) {
                eBrwMainFrm.mSBWnd.hidden = NO;
                [eBrwMainFrm.mSBWnd setNotifyText:title];
                AudioServicesPlaySystemSound(eBrwMainFrm.mSBWnd.mAlertSoundID);
            } else {
                [eBrwMainFrm.mNotifyArray addObject:title];
                return;
            }
        } else {
            return;
        }
        
    }
    if (eBrwMainFrm.mSBWndTimer) {
        [eBrwMainFrm.mSBWndTimer invalidate];
        eBrwMainFrm.mSBWndTimer = nil;
    }
    eBrwMainFrm.mSBWndTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(closeStatusBarNotification) userInfo:nil repeats:NO];
    //添加本地通知在通知栏显示
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {        NSDate *now = [NSDate date];
        //从现在开始，1秒以后通知
        notification.fireDate=[now dateByAddingTimeInterval:1.0];
        //使用本地时区
        notification.timeZone=[NSTimeZone defaultTimeZone];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
        
        NSDictionary *msgDict = dictionaryArg(msg);
        if (msgDict) {
            [dict addEntriesFromDictionary:msgDict];
        }else{
            [dict setValue:stringArg(msg) forKey:@"userInforStr"];
        }
        [notification setUserInfo:dict];
        notification.alertBody = title;
        notification.hasAction = YES;
        //启动这个通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
}



#pragma mark - Channel Notification API


- (void)subscribeChannelNotification:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *channelId,NSString *function) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(channelId);
    UEX_PARAM_GUARD_NOT_NIL(function);
    [self.notificationDic setValue:function forKey:channelId];
}

static NSString *const kChannelNotificationChannelIdKey = @"channelId";
static NSString *const kChannelNotificationContentKey = @"content";

- (void)publishChannelNotification:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSString *channelId,id content) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(channelId);
    UEX_PARAM_GUARD_NOT_NIL(content);
    [self publishChannelNotificationWithChannelId:channelId content:content];
    
}

- (void)publishChannelNotificationForJson:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *channelId,NSDictionary *content) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(channelId);
    UEX_PARAM_GUARD_NOT_NIL(content);
    [self publishChannelNotificationWithChannelId:channelId content:content];
}

- (void)publishChannelNotificationWithChannelId:(NSString *)channelId content:(id)content{
    if (!channelId || !content) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kChannelNofitication
                                                        object:self
                                                      userInfo:@{
                                                                 kChannelNotificationChannelIdKey: channelId,
                                                                 kChannelNotificationContentKey: content
                                                                 }];
}



- (void)onReceiveChannelNotification:(NSNotification *)notif{
    
    NSDictionary * infoDic = notif.userInfo;
    NSString * channelId = [infoDic objectForKey:kChannelNotificationChannelIdKey];
    id content = [infoDic objectForKey:kChannelNotificationContentKey];
    NSString * function = [self.notificationDic objectForKey:channelId];
    if (!function || function.length == 0) {
        return;
    }
    NSString *cbFuncName = [NSString stringWithFormat:@"uexWindow.%@",function];
    [self.webViewEngine callbackWithFunctionKeyPath:cbFuncName arguments:ACArgsPack(content)];
}


- (void)postGlobalNotification:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(id content) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(content);
    [[NSNotificationCenter defaultCenter] postNotificationName:kGlobalNofitication object:self userInfo:@{kChannelNotificationContentKey: content}];
    
}

- (void)onReceiveGlobalNotification:(NSNotification *)notif{
    id content = notif.userInfo[kChannelNotificationContentKey];
    if (content) {
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.onGlobalNotification" arguments:ACArgsPack(content)];
    }
}


//*****



#pragma mark - pluginViewConrainer API



- (UEX_BOOL)createPluginViewContainer:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *identifier = stringArg(info[@"id"]);
    NSNumber *inX = numberArg(info[@"x"]);
    NSNumber *inY = numberArg(info[@"y"]);
    NSNumber *inW = numberArg(info[@"w"]);
    NSNumber *inH = numberArg(info[@"h"]);
    UEX_PARAM_GUARD_NOT_NIL(identifier,UEX_FALSE);
    UEX_PARAM_GUARD_NOT_NIL(inW,UEX_FALSE);
    UEX_PARAM_GUARD_NOT_NIL(inH,UEX_FALSE);
    CGFloat x = inX ? inX.floatValue : 0;
    CGFloat y = inY ? inY.floatValue : 0;
    CGFloat w = inW.floatValue;
    CGFloat h = inH.floatValue;
    //同步返回时,当前是在Web线程,而非主线程
    dispatch_async(dispatch_get_main_queue(), ^{
        ACEPluginViewContainer * pluginViewContainer = [[ACEPluginViewContainer alloc]initWithFrame:CGRectMake(x, y, w, h)];
        pluginViewContainer.containerIdentifier = identifier;
        pluginViewContainer.uexObj = self;
        [EUtility brwView:self.EBrwView addSubview:pluginViewContainer];
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.cbCreatePluginViewContainer" arguments:ACArgsPack(numberArg(identifier),@0,@"success")];
    });
    return UEX_TRUE;
    
}

- (UEX_BOOL)closePluginViewContainer:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *identifier = stringArg(info[@"id"]);
    UEX_PARAM_GUARD_NOT_NIL(identifier,UEX_FALSE);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView * subView in [self.EBrwView.meBrwWnd subviews]) {
            if ([subView isKindOfClass:[ACEPluginViewContainer class]]) {
                ACEPluginViewContainer * container = (ACEPluginViewContainer *)subView;
                if ([container.containerIdentifier isEqualToString:identifier]) {
                    ACLogDebug(@"关闭id为%@的容器",identifier);
                    [container removeFromSuperview];
                }
            }
        }
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.cbClosePluginViewContainer" arguments:ACArgsPack(numberArg(identifier),@0,@"success")];
    });
    return UEX_TRUE;
}

- (UEX_BOOL)setPageInContainer:(NSMutableArray *)inArguments {
    
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    NSString *identifier = stringArg(info[@"id"]);
    NSNumber *index = numberArg(info[@"index"]);
    UEX_PARAM_GUARD_NOT_NIL(identifier,UEX_FALSE);
    UEX_PARAM_GUARD_NOT_NIL(index,UEX_FALSE);
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView * subView in [self.EBrwView.meBrwWnd subviews]) {
            if ([subView isKindOfClass:[ACEPluginViewContainer class]]) {
                ACEPluginViewContainer * container = (ACEPluginViewContainer *)subView;
                if ([container.containerIdentifier isEqualToString:identifier]) {
                    [container setContentOffset: CGPointMake(container.bounds.size.width * index.integerValue, container.contentOffset.y) animated: YES];
                }
            }
        }
    });
    return UEX_TRUE;
    
    
}

#pragma mark - Local Data API
static NSString *const kUexWindowValueDictKey = @"uexWindow.valueDict";

- (void)putLocalData:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *key,NSObject *content) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(key);
    UEX_PARAM_GUARD_NOT_NIL(content);
    
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [[df valueForKey:kUexWindowValueDictKey] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setValue:content forKey:key];
    [df setValue:dict forKey:kUexWindowValueDictKey];
    [df synchronize];
}

- (NSObject *)getLocalData:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSString *key) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(key,nil);
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:kUexWindowValueDictKey];
    return dict[key];
    
}




#pragma mark - Share API

- (void)share:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSDictionary *info) = inArguments;
    
    __block NSMutableArray *shareItems = [NSMutableArray array];
    
    NSString *text = stringArg(info[@"text"]);
    if (text) {
        [shareItems addObject:text];
    }
    
    NSArray *imgPaths = arrayArg(info[@"imgPaths"]);
    if (imgPaths) {
        [imgPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = [self absPath:obj];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                [shareItems addObject:image];
            }
        }];
    }else{
        NSString *path = stringArg(info[@"imgPath"]);
        UIImage *image = [UIImage imageWithContentsOfFile:[self absPath:path]];
        if (image) {
            [shareItems addObject:image];
        }
    }
    
    UIActivityViewController * shareVC = [[UIActivityViewController alloc]initWithActivityItems:shareItems applicationActivities:nil];
    [[self.webViewEngine viewController] presentViewController:shareVC animated:YES completion:nil];
    
}

#pragma mark - Ad API


- (void)openAd:(NSMutableArray *)inArguments {
    
    ACArgsUnpack(NSNumber *inType,NSNumber *inDisplayTime,NSNumber *inInterval,NSNumber *inFlag) = inArguments;
    
    
    
    int type = F_EBRW_MAINFRM_AD_TYPE_TOP;
    UexWindowOpenFlag flag = [inFlag integerValue];
    CGRect ADFrame;
    if (!self.EBrwView) {
        return;
    }
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    if (self.EBrwView.meBrwCtrler.mwWgtMgr.wMainWgt.openAdStatus != 1) {
        return;
    }
    self.EBrwView.mFlag |= F_EBRW_VIEW_FLAG_HAS_AD;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)self.EBrwView.meBrwWnd;
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    
    type = [inType intValue];
    self.EBrwView.mAdType = type;
    
    
    self.EBrwView.mAdDisplayTime = [inDisplayTime intValue];
    eBrwMainFrm.mAdDisplayTime = [inDisplayTime intValue];
    
    
    self.EBrwView.mAdIntervalTime = [inInterval intValue];
    eBrwMainFrm.mAdIntervalTime = [inInterval intValue];
    
    
    
    self.EBrwView.mAdFlag = flag;
    
    switch (type) {
        case F_EBRW_MAINFRM_AD_TYPE_TOP:
            if ([BUtility isIpad]) {
                ADFrame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PAD);
            } else {
                ADFrame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PHONE);
            }
            break;
        case F_EBRW_MAINFRM_AD_TYPE_MIDDLE:
            if ([BUtility isIpad]) {
                ADFrame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, eBrwWnd.bounds.size.height) ;
            } else {
                ADFrame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, eBrwWnd.bounds.size.height);
            }
            break;
        case F_EBRW_MAINFRM_AD_TYPE_BOTTOM:
            if ([BUtility isIpad]) {
                ADFrame = CGRectMake(0, (eBrwWnd.bounds.size.height-F_EBRW_MAINFRM_AD_HEIGHT_PAD), eBrwWnd.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PAD) ;
            } else {
                ADFrame = CGRectMake(0, (eBrwWnd.bounds.size.height-F_EBRW_MAINFRM_AD_HEIGHT_PHONE), eBrwWnd.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PHONE);
            }
            break;
        default:
            type = 0;
            if ([BUtility isIpad]) {
                ADFrame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PAD);
            } else {
                ADFrame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, F_EBRW_MAINFRM_AD_HEIGHT_PHONE);
            }
            break;
    }
    if (!eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView = [[EBrowserView alloc] initWithFrame:ADFrame BrwCtrler:self.EBrwView.meBrwCtrler Wgt:self.EBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:@"" Type:ACEEBrowserViewTypeAd];
        eBrwMainFrm.mAdType = type;
    } else {
        eBrwMainFrm.meAdBrwView.hidden = NO;
        eBrwMainFrm.meAdBrwView.meBrwWnd = eBrwWnd;
        if (eBrwMainFrm.mAdType != type) {
            eBrwMainFrm.mAdType = type;
            [eBrwMainFrm.meAdBrwView setFrame:ADFrame];
            eBrwMainFrm.meAdBrwView.hidden = YES;
        }
        if (eBrwMainFrm.meAdBrwView.hidden == NO) {
            if (eBrwMainFrm.mAdDisplayTimer) {
                if ([eBrwMainFrm.mAdDisplayTimer isValid]) {
                    [eBrwMainFrm.mAdDisplayTimer invalidate];
                }
                eBrwMainFrm.mAdDisplayTimer = NULL;
            }
        } else {
            if (eBrwMainFrm.mAdIntervalTimer) {
                if ([eBrwMainFrm.mAdIntervalTimer isValid]) {
                    [eBrwMainFrm.mAdIntervalTimer invalidate];
                }
                eBrwMainFrm.mAdIntervalTimer = NULL;
            }
        }
    }
    if (flag & UexWindowOpenFlagOpaque){
        eBrwMainFrm.meAdBrwView.backgroundColor = [UIColor whiteColor];
    }
    eBrwMainFrm.meAdBrwView.mFlag = 0;
    if (flag & UexWindowOpenFlagDisableCrossDomain) {
        eBrwMainFrm.meAdBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    int reportAdType = 0;
    //NSString *adURL = @"http://app.tx100.com/adver/index.html";
    NSString *adURL =  @"http://wgb.tx100.com/mobile/adver.wg";
    switch (eBrwMainFrm.mAdType) {
        case F_EBRW_MAINFRM_AD_TYPE_TOP:
            reportAdType = 0;
            break;
        case F_EBRW_MAINFRM_AD_TYPE_MIDDLE:
            //adURL = @"http://app.tx100.com/adver/adver_big.html";
            reportAdType = 1;
            break;
        case F_EBRW_MAINFRM_AD_TYPE_BOTTOM:
            reportAdType = 0;
            break;
        default:
            break;
    }
    NSString *keyStr = [self.EBrwView.mwWgt.appId stringByAppendingString:@"BD7463CD-D608-BEB4-C633-EF3574213060"];
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, [keyData bytes],(CC_LONG)[keyData length]);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *md5Str = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        digest[0], digest[1], digest[2], digest[3],
                        digest[4], digest[5], digest[6], digest[7],
                        digest[8], digest[9], digest[10], digest[11],
                        digest[12], digest[13], digest[14], digest[15]];
    NSString *md5Key = [md5Str lowercaseString];
    NSString *adURLQuery = NULL;
    if ([BUtility isIpad]) {
        adURLQuery = [NSString stringWithFormat:@"?appid=%@&pt=%d&dw=%d&dh=%d&md5=%@&type=%d", self.EBrwView.mwWgt.appId,0,768,1024,md5Key,reportAdType];
    } else {
        adURLQuery = [NSString stringWithFormat:@"?appid=%@&pt=%d&dw=%d&dh=%d&md5=%@&type=%d", self.EBrwView.mwWgt.appId,0,320,460,md5Key,reportAdType];
    }
    adURL = [adURL stringByAppendingString:adURLQuery];
    ACENSLog(@"adURL is %@", adURL);
    //adURL.length != 0
    if (adURL && adURL.length > 0) {
        
        NSURL *url = [BUtility stringToUrl:adURL];
        [eBrwMainFrm.meAdBrwView loadWithUrl:url];
    } else {
        [eBrwMainFrm bringSubviewToFront:eBrwMainFrm.meAdBrwView];
        eBrwMainFrm.meAdBrwView.hidden = NO;
    }
    if (eBrwMainFrm.mAdDisplayTime > 0) {
        eBrwMainFrm.mAdDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:eBrwMainFrm.mAdDisplayTime target:eBrwMainFrm selector:@selector(displayDone) userInfo:nil repeats:NO];
    }
}



- (void)closeAD:(NSMutableArray *)inArguments {
    if (self.EBrwView.mType != ACEEBrowserViewTypeMain) {
        return;
    }
    EBrowserMainFrame *eBrwMainFrm = self.EBrwView.meBrwCtrler.meBrwMainFrm;
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        self.EBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        [self.EBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
    }
}




#pragma mark - Other API

- (void)setSwipeRate:(NSMutableArray *)inArguments{
    //配合android添加空函数
}




- (void)setRightSwipeEnable:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSNumber *flagNum) = inArguments;
    BOOL isNeedSwipeGestureRecognizer = flagNum ? flagNum.boolValue :  YES;
    EBrowserWindow *eCurBrwWnd = self.EBrwView.meBrwWnd;
    if (eCurBrwWnd.webController){
        ACEWebViewController * webViewController = eCurBrwWnd.webController;
        webViewController.isNeedSwipeGestureRecognizer = isNeedSwipeGestureRecognizer;
    }
    
}




//2015-10-21 by lkl 解决iOS9上长按出现放大镜的问题
- (void)disturbLongPressGesture:(NSMutableArray *)inArguments{
    
    ACArgsUnpack(NSNumber *flagNum) = inArguments;
    if (ACSystemVersion() < 9.0 || !flagNum) {
        return;
    }
    ACEDisturbLongPressGestureStatus status =(ACEDisturbLongPressGestureStatus)[flagNum integerValue];
    NSArray *views =[self.EBrwView.meBrowserView subviews];
    if([views count] == 0){
        return;
    }
    if(self.longPressGestureDisturbRecognizer && status==ACEDisturbLongPressGestureNotDisturb){
        //取消干扰长按手势
        for (int i=0; i<views.count; i++) {
            UIView *webViewScrollView = views[i];
            if ([webViewScrollView isKindOfClass:[UIScrollView class]]) {
                NSArray *webViewScrollViewSubViews = webViewScrollView.subviews;
                UIView *browser = webViewScrollViewSubViews[0];
                [browser removeGestureRecognizer:self.longPressGestureDisturbRecognizer];
                break;
            }
        }
        return;
    }
    //添加长按手势干扰
    if(!self.longPressGestureDisturbRecognizer){
        self.longPressGestureDisturbRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(disturbLongPressGestureHandler:)];
        self.longPressGestureDisturbRecognizer.allowableMovement = 100.0f;
        self.longPressGestureDisturbRecognizer.cancelsTouchesInView = NO;
    }
    
    if(status == ACEDisturbLongPressGestureDisturbNormally){
        self.longPressGestureDisturbRecognizer.minimumPressDuration = 0.45f;
    }
    if(status ==ACEDisturbLongPressGestureDisturbStrictly){
        self.longPressGestureDisturbRecognizer.minimumPressDuration = 0.04f;
    }
    
    for (int i=0; i<views.count; i++) {
        UIView *webViewScrollView = views[i];
        if ([webViewScrollView isKindOfClass:[UIScrollView class]]) {
            NSArray *webViewScrollViewSubViews = webViewScrollView.subviews;
            UIView *browser = webViewScrollViewSubViews[0];
            [browser addGestureRecognizer:self.longPressGestureDisturbRecognizer];
            break;
            
        }
    }
}
- (void)disturbLongPressGestureHandler:(UILongPressGestureRecognizer*)sender{
    if([sender isEqual:self.longPressGestureDisturbRecognizer]){
        if(sender.state == UIGestureRecognizerStateBegan){
            //NSLog(@"disturbLongPressGesture");
        }
    }
}
#pragma mark - Log API

- (void)log:(NSMutableArray *)inArguments{
    for (id obj in inArguments) {
        ACLogInfo(@"%@",obj);
    }
    
}





@end
