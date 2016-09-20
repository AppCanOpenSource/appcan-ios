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
#import "ACESubMultiPopScrollView.h"

#import "ACEUtils.h"
#import "ACEMultiPopoverScrollView.h"
#import "ACEPOPAnimation.h"

#import "ACEProgressDialog.h"


#define kWindowConfirmViewTag (-9999)

#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"


#define AppRootLeftSlidingWinName  @"rootLeftSlidingWinName"
#define ApprootRightSlidingWinName @"rootRightSlidingWinName"
#define KUEXIS_NSString(x) ([x isKindOfClass:[NSString class]] && [x length] > 0)
#define KUEXIS_ZERO(x)\
(([x isKindOfClass:[NSString class]] && [x length] > 0 && [x floatValue] == 0)||\
([x isKindOfClass:[NSNumber class]] && [x floatValue] == 0))
#define KUEXIS_EMPTY(x)\
(!x || [x isKindOfClass:[NSNull class]] || ([x isKindOfClass:[NSString class]] && [x length] == 0))
#define iOS9 ([[[UIDevice currentDevice]systemVersion] floatValue] >= 9.0)



NSString *const kACEEvaluateScriptJavaScriptKey = @"kACEEvaluateScriptJavaScriptKey";
NSString *const kACEEvaluateScriptBrowserViewKey = @"kACEEvaluateScriptBrowserViewKey";

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

@interface EUExWindow()
@property (nonatomic,strong)UILongPressGestureRecognizer *longPressGestureDisturbRecognizer;
@property (nonatomic,strong)NSMutableDictionary *bounceParams;
@end

@implementation EScrollView



@end



@implementation EUExWindow

@synthesize mbAlertView;
@synthesize mActionSheet;
@synthesize mToastView;
@synthesize mToastTimer;
@synthesize meBrwAnimi;
@synthesize bounceParams;

- (void)dealloc{
    [_notificationDic removeAllObjects];
    _notificationDic = nil;
    mbAlertView = nil;
    mActionSheet = nil;
    mToastView = nil;
    mToastTimer = nil;
    meBrwAnimi = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




-(void)doRotate:(UIInterfaceOrientation)deviceOrientation_ {
    if (!meBrwView) {
        return;
    }
    CGRect rect;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    float wndWidth = eBrwWnd.bounds.size.width;
    float wndHeight = eBrwWnd.bounds.size.height;
    
    
    UIDevice *myDevice = [UIDevice currentDevice];
    UIDeviceOrientation deviceOrientation = [myDevice orientation];
    switch (deviceOrientation) {
        case UIInterfaceOrientationPortrait:
            if ((meBrwView.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
                if (mToastView) {
                    if ([BUtility isIpad]) {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:768 wndHeight:1004];
                    } else {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:wndWidth wndHeight:wndHeight];
                    }
                    [mToastView setFrame:rect];
                    [mToastView setSubviewsFrame:rect];
                }
            }
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            if ((meBrwView.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
                if (mToastView) {
                    if ([BUtility isIpad]) {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:768 wndHeight:1004];
                    } else {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:wndWidth wndHeight:wndHeight];
                    }
                    [mToastView setFrame:rect];
                    [mToastView setSubviewsFrame:rect];
                }
            }
            break;
        case UIInterfaceOrientationLandscapeLeft:
            if ((meBrwView.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
                if (mToastView) {
                    if ([BUtility isIpad]) {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:1024 wndHeight:748];
                    } else {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:wndWidth wndHeight:wndHeight];
                    }
                    [mToastView setFrame:rect];
                    [mToastView setSubviewsFrame:rect];
                }
            }
            break;
        case UIInterfaceOrientationLandscapeRight:
            if ((meBrwView.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
                if (mToastView) {
                    if ([BUtility isIpad]) {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:1024 wndHeight:748];
                    } else {
                        rect = [BToastView viewRectWithPos:mToastView.mPos wndWidth:wndWidth wndHeight:wndHeight];
                    }
                    [mToastView setFrame:rect];
                    [mToastView setSubviewsFrame:rect];
                }
            }
            break;
        default:
            break;
    }
}

-(id)initWithBrwView:(EBrowserView *) eInBrwView{
    if (self = [super initWithBrwView:eInBrwView]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondGlobalNotification:) name:@"GlobalNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondChannelNotification:) name:@"SubscribeChannelNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondChannelNotificationForJson:) name:@"SubscribeChannelNotificationForJson" object:nil];
        
        self.notificationDic = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void) forward:(NSMutableArray *)inArguments{
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    
    //    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
    //
    //        return;
    //    }
    //
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
        EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
        if (eBrwWnd.canGoForward == YES) {
            [eBrwWnd goForward];
        }
    } else {
        if (meBrwView.canGoForward) {
            [meBrwView goForward];
        }
    }
}

-(void) back:(NSMutableArray *)inArguments{
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    
    //    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
    //
    //        return;
    //    }
    
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
        EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
        if (eBrwWnd.canGoBack == YES) {
            [eBrwWnd goBack];
        }
    } else {
        if (meBrwView.canGoBack) {
            [meBrwView goBack];
        }
    }
}
-(void) pageForward:(NSMutableArray *)inArguments
{
    
    if ([meBrwView canGoForward])
    {
        [meBrwView stringByEvaluatingJavaScriptFromString:@"window.history.forward()"];
        [self jsSuccessWithName:@"uexWindow.cbPageForward" opId:0 dataType:1 intData:UEX_CSUCCESS];
    }else
    {
        [self jsSuccessWithName:@"uexWindow.cbPageForward" opId:0 dataType:1 intData:UEX_CFAILED];
    }
}
-(void) pageBack:(NSMutableArray *)inArguments
{
    
    if ([meBrwView canGoBack])
    {
        [meBrwView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:@"window.history.back()" waitUntilDone:NO];
        [self jsSuccessWithName:@"uexWindow.cbPageBack" opId:0 dataType:1 intData:UEX_CSUCCESS];
    }else
    {
        [self jsSuccessWithName:@"uexWindow.cbPageBack" opId:0 dataType:1 intData:UEX_CFAILED];
    }
}
-(void)alert:(NSMutableArray *)inArguments{
    NSString *inTitle = [inArguments objectAtIndex:0];
    NSString *inMessage = [inArguments objectAtIndex:1];
    NSString *inButtonLabel = [inArguments objectAtIndex:2];
    
    if ((meBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
        return;
    }
    ACENSLog(@"alertWithTitle");
    mbAlertView = [[BUIAlertView alloc]init];
    mbAlertView.mAlertView = [[UIAlertView alloc]
                              initWithTitle:inTitle
                              message:inMessage
                              delegate:self
                              cancelButtonTitle:inButtonLabel
                              otherButtonTitles:nil];
    [mbAlertView initWithType:F_BUIALERTVIEW_TYPE_ALERT];
    [mbAlertView.mAlertView show];
}

-(void)confirm:(NSMutableArray *)inArguments{
    NSString *inTitle = [inArguments objectAtIndex:0];
    NSString *inMessage = [inArguments objectAtIndex:1];
    id inButtons = [inArguments objectAtIndex:2];
    NSArray *inButtonLabels;
    if([inButtons isKindOfClass:[NSArray class]]){
        inButtonLabels = inButtons;
    }
    if ([inButtons isKindOfClass:[NSString class]]) {
        inButtonLabels = [(NSString *)inButtons componentsSeparatedByString:@","];
    }
    mbAlertView = [[BUIAlertView alloc]init];
    mbAlertView.mAlertView = [[UIAlertView alloc]
                              initWithTitle:inTitle
                              message:inMessage
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil];
    [mbAlertView initWithType:F_BUIALERTVIEW_TYPE_CONFIRM];
    NSInteger buttonCount = inButtonLabels.count;
    NSString *button = nil;
    for (int i=0; i<buttonCount; i++) {
        button = (NSString*)[inButtonLabels objectAtIndex:i];
        [mbAlertView.mAlertView addButtonWithTitle:button];
    }
    if ((meBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
        return;
    }
    [mbAlertView.mAlertView show];
}

- (void)reload:(NSMutableArray *)inArguments {
    BOOL reloaded = NO;
    if (self.meBrwView.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
        FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
        NSString *data = [encryptObj decryptWithPath:self.meBrwView.curUrl appendData:nil];
        if (data) {
            [self.meBrwView loadWithData:data baseUrl:self.meBrwView.curUrl];
            reloaded = YES;
        }
    }
    if (!reloaded) {
        [self.meBrwView reload];
    }
}

- (void)prompt:(NSMutableArray *)inArguments{
    NSString *inTitle = [inArguments objectAtIndex:0];
    if (!KUEXIS_NSString(inTitle)){
        inTitle=@" ";
    }
    NSString *inMessage = [inArguments objectAtIndex:1];
    NSString *inDefaultValue = [inArguments objectAtIndex:2];

    id inButtons = [inArguments objectAtIndex:3];
    NSArray *inButtonLabels;
    if([inButtons isKindOfClass:[NSArray class]]){
        inButtonLabels = inButtons;
    }
    if ([inButtons isKindOfClass:[NSString class]]) {
        inButtonLabels = [(NSString *)inButtons componentsSeparatedByString:@","];
    }

    
    NSString *placeHolder = inArguments.count > 4 ? inArguments[4] : @"" ;

    if ((meBrwView.meBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
        return;
    }
    mbAlertView = [[BUIAlertView alloc]init];
    mbAlertView.mAlertView = [[UIAlertView alloc]
                              initWithTitle:inTitle
                              message:inMessage
                              delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil];
    //适配ios7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
    {
        mbAlertView.mAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * temp = [mbAlertView.mAlertView textFieldAtIndex:0];
        if (KUEXIS_NSString(inDefaultValue)) {
             temp.text = inDefaultValue;
        }
        if (KUEXIS_NSString(placeHolder)) {
            temp.placeholder = placeHolder;
        }
        
    }else
    {
        mbAlertView.mTextField = [[UITextField alloc] init];
        [mbAlertView.mTextField setFrame:CGRectMake(mbAlertView.mAlertView.center.x+18,mbAlertView.mAlertView.center.y+48, 250,30)];
        mbAlertView.mTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [mbAlertView.mTextField setBorderStyle:UITextBorderStyleRoundedRect];
        [mbAlertView.mTextField setUserInteractionEnabled:YES];
        //mbAlertView.mTextField.placeholder = inDefaultValue;
        if (KUEXIS_NSString(inDefaultValue)) {
            mbAlertView.mTextField.text = inDefaultValue;
        }
        if (KUEXIS_NSString(placeHolder)) {
            mbAlertView.mTextField.placeholder = placeHolder;
        }
        [mbAlertView.mAlertView addSubview:mbAlertView.mTextField];
    }
    [mbAlertView initWithType:F_BUIALERTVIEW_TYPE_PROMPT];
    NSInteger buttonCount = inButtonLabels.count;
    NSString *button = nil;
    for (int i=0; i<buttonCount; i++) {
        button = (NSString*)[inButtonLabels objectAtIndex:i];
        [mbAlertView.mAlertView addButtonWithTitle:button];
    }
    
    [mbAlertView.mAlertView show];
}
- (void)actionSheet:(NSMutableArray *)inArguments {
    NSString *inTitle = [inArguments objectAtIndex:0];
    NSString *inCancel = [inArguments objectAtIndex:1];

    id inButtons = [inArguments objectAtIndex:2];
    NSArray *inButtonLabels;
    if([inButtons isKindOfClass:[NSArray class]]){
        inButtonLabels = inButtons;
    }
    if ([inButtons isKindOfClass:[NSString class]]) {
        inButtonLabels = [(NSString *)inButtons componentsSeparatedByString:@","];
    }
    mActionSheet=[[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *otherBtn in inButtonLabels) {
        [mActionSheet addButtonWithTitle:otherBtn];
    }
    mActionSheet.cancelButtonIndex = [mActionSheet addButtonWithTitle:inCancel];
    //**********
    //	int buttonCount = inButtonLabels.count;
    //	switch (buttonCount) {
    //		case 1:
    //			mActionSheet = [[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:inCancel destructiveButtonTitle:nil otherButtonTitles:(NSString*)[inButtonLabels objectAtIndex:0],nil];
    //			break;
    //		case 2:
    //			mActionSheet = [[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:inCancel destructiveButtonTitle:nil otherButtonTitles:(NSString*)[inButtonLabels objectAtIndex:0],(NSString*)[inButtonLabels objectAtIndex:1],nil];
    //			break;
    //		case 3:
    //			mActionSheet = [[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:inCancel destructiveButtonTitle:nil otherButtonTitles:[inButtonLabels objectAtIndex:0],[inButtonLabels objectAtIndex:1],[inButtonLabels objectAtIndex:2],nil];
    //			break;
    //		case 4:
    //			mActionSheet = [[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:inCancel destructiveButtonTitle:nil otherButtonTitles:[inButtonLabels objectAtIndex:0],[inButtonLabels objectAtIndex:1],[inButtonLabels objectAtIndex:2],[inButtonLabels objectAtIndex:3],nil];
    //			break;
    //		case 5:
    //			mActionSheet = [[UIActionSheet alloc]initWithTitle:inTitle delegate:self cancelButtonTitle:inCancel destructiveButtonTitle:nil otherButtonTitles:[inButtonLabels objectAtIndex:0],[inButtonLabels objectAtIndex:1],[inButtonLabels objectAtIndex:2],[inButtonLabels objectAtIndex:3],[inButtonLabels objectAtIndex:4],nil];
    //			break;
    //		default:
    //			break;
    //	}
    mActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [mActionSheet showInView:meBrwView.meBrwWnd];
}
-(void)alertForbidView:(NSString*)uexWinName{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:ACELocalized(@"提示") message:[NSString stringWithFormat:@"%@窗口被禁止使用，请联系管理员。",uexWinName] delegate:nil cancelButtonTitle:nil otherButtonTitles:ACELocalized(@"确定"), nil];
    [alertView show];
}


- (void)addBrowserWindowToWebController:(ACEWebViewController *)webController url:(NSString *)url winName:(NSString *)winName
{
    NSString *inUExWndName = winName;
    NSString *inDataType = 0;
    NSString *inData = url;
    
    
    if (meBrwView.hidden == YES) {
        return;
    }
    
    
    EBrowserWindow *eBrwWnd = nil;
    EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    int flag = 0;
    NSURL *baseUrl = [meBrwView curUrl];
    
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eCurBrwWnd.superview;
    
    if (eBrwWndContainer != nil && [eBrwWndContainer isKindOfClass:[EBrowserWindowContainer class]]) {
        
        eCurBrwWnd.winContainer = eBrwWndContainer;
        
    } else {
        
        eBrwWndContainer = eCurBrwWnd.winContainer;
    }
    
    
    //    if ((meBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING) == F_EBRW_FLAG_WINDOW_IN_OPENING) {
    //        return;
    //    }
    
    //inUExWndName.length != 0
    if (KUEXIS_NSString(inUExWndName)) {
        eBrwWnd = [eBrwWndContainer brwWndForKey:inUExWndName];
        if (eBrwWnd != nil) {
            [eBrwWndContainer removeFromWndDict:inUExWndName];
        }
        eBrwWnd = nil;
        
    }
    if (eBrwWnd == nil) {
        eBrwWnd = [[EBrowserWindow alloc]initWithFrame:CGRectMake(0, 0, eBrwWndContainer.bounds.size.width, eBrwWndContainer.bounds.size.height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt UExObjName:inUExWndName];
        
        eBrwWnd.webWindowType = ACEWebWindowTypeNavigation;
        eBrwWnd.windowName = inUExWndName;
        eBrwWnd.winContainer = eBrwWndContainer;
        eBrwWnd.isSliding = YES;
        
        
        webController.browserWindow = eBrwWnd;
        eBrwWnd.webController = webController;
        
        ACENSLog(@"NavWindowTest openWithController new window eBrwWnd = %@, eBrwWnd Name = %@, eBrwWnd.meBrwView = %@", eBrwWnd, inUExWndName, eBrwWnd.meBrwView);
        //inUExWndName != nil && inUExWndName.length != 0
        if (KUEXIS_NSString(inUExWndName)) {
            //[eBrwWndContainer.mBrwWndDict setObject:eBrwWnd forKey:inUExWndName];
        }
        
        
        if ((flag & F_EUEXWINDOW_OPEN_FLAG_HIDDEN) == F_EUEXWINDOW_OPEN_FLAG_HIDDEN) {
            if (eBrwWnd.hidden == NO) {
                eBrwWnd.hidden = YES;
            }
        } else {
            if (eBrwWnd.hidden == YES) {
                eBrwWnd.hidden = NO;
            }
            ////
            eBrwWnd.meBackWnd = eCurBrwWnd;
            eCurBrwWnd.meFrontWnd = eBrwWnd;
            //
        }
        
        
    }
    
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OPAQUE) == F_EUEXWINDOW_OPEN_FLAG_OPAQUE) {
        eBrwWnd.meBrwView.backgroundColor = [UIColor whiteColor];
    }
    if ((flag & F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) == F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) {
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
    meBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WINDOW_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
    
    
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_DISABLE_CROSSDOMAIN) != 0) {
        eBrwWnd.meBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_HAS_PREOPEN) != 0) {
        eBrwWnd.mFlag |= F_EBRW_WND_FLAG_HAS_PREOPEN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OAUTH) == F_EUEXWINDOW_OPEN_FLAG_OAUTH) {
        eBrwWnd.mOAuthWndName = meBrwView.muexObjName;
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
    
    if (eBrwWnd.hidden == YES) {
        eBrwWnd.mOpenAnimiId = 0;
    }
    //inData.length != 0
    if (KUEXIS_NSString(inData)) {
        int dataType = [inDataType intValue];
        if (dataType == F_EUEXWINDOW_SRC_TYPE_URL) {
            NSString *urlStr = nil;
            if ([inData hasPrefix:F_WGTROOT_PATH]) {
                NSString * urlsub = [inData substringFromIndex:10];
                NSString * finaUrl = [NSString stringWithFormat:@"/%@",urlsub];
                urlStr = [meBrwView.mwWgt.widgetPath stringByAppendingString:finaUrl];
                
                if (![urlStr hasPrefix:@"file://"]) {
                    urlStr =[NSString stringWithFormat:@"file://%@", urlStr];
                }
                
            }else
            {
                urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inData];
            }
            
            NSURL *url = [BUtility stringToUrl:urlStr];
            
            
            if ((flag & F_EUEXWINDOW_OPEN_FLAG_RELOAD) != F_EUEXWINDOW_OPEN_FLAG_RELOAD) {
                if ([[eBrwWnd.meBrwView curUrl] isEqual:url] == YES) {
                    
                    [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
                    
                    //[meBrwView stringByEvaluatingJavaScriptFromString:@"window.opening=0;"];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
                    
                    int type = meBrwView.mwWgt.wgtType;
                    NSString *viewName =[meBrwView.curUrl absoluteString];
                    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:meBrwView.mwWgt];
                    [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
                    if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
                        NSArray *popViewArray = [meBrwView.meBrwWnd.mPopoverBrwViewDict allValues];
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
                    
                    if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
                        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
                    }
                    eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
                    meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
                    
                    
                    return;
                }
            }
            if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
                EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
                [eBrwWnd addHisEntry:eHisEntry];
                //				if ((flag & F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) == F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) {
                FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                NSString *data = [encryptObj decryptWithPath:url appendData:nil];
                
                [eBrwWnd.meBrwView loadWithData:data baseUrl:url];
                //				} else {
                //					[eBrwWnd.meBrwView loadWithUrl:url];
                //				}
            } else {
                [eBrwWnd.meBrwView loadWithUrl:url];
            }
            //8.7 数据统计
            int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
            NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
            
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
            if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
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
        } else if (dataType == F_EUEXWINDOW_SRC_TYPE_DATA) {
            [eBrwWnd.meBrwView loadWithData:inData baseUrl:baseUrl];
        }
    } else {
        [eBrwWndContainer bringSubviewToFront:eBrwWnd];
        
        [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
        NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
        if (eCurBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [eCurBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            }
        }
        
        
        //[meBrwView stringByEvaluatingJavaScriptFromString:@"window.opening=0;"];
        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        
        int goType = eBrwWnd.meBrwView.mwWgt.wgtType;
        NSString *goViewName =[eBrwWnd.meBrwView.curUrl absoluteString];
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
        
        if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
            [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
        eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
        meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        
    }
}


- (void)setPopoverVisibility:(NSMutableArray *)inArguments
{
    if (inArguments.count != 2) {
        return;
    }
    
    NSString *inName = [inArguments objectAtIndex:0];
    NSString *value = [inArguments objectAtIndex:1];
    NSInteger iV = [value integerValue];
    
    if (!inName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    UIView *view = [popoverDict objectForKey:inName];
    
    if (view == nil) {
        
        NSMutableDictionary *multipopoverDict = meBrwView.meBrwWnd.mMuiltPopoverDict;
        EScrollView * muiltPopover = [multipopoverDict objectForKey:inName];
        
        if(!muiltPopover) {
            return;
        }
        
        view = muiltPopover;
        
    }
    
    if (iV == 0) { //隐藏
        
        view.hidden = YES;
        
    } else if (iV == 1) { //显示
        
        view.hidden = NO;
    }
    
}

- (void)setSlidingWindowEnabled:(NSMutableArray *)inArguments
{
    
    if (inArguments.count == 0) {
        return;
    }
    
    NSString *value = [inArguments objectAtIndex:0];
    NSInteger iV = [value integerValue];
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    if (iV == 1) {
        
        if (app.leftWebController != nil) {
            
            if (app.drawerController) {
                [app.drawerController setLeftDrawerViewController:app.leftWebController];
            } else {
                //                app.sideMenuViewController.leftMenuViewController = app.leftWebController;
                app.sideMenuViewController.panGestureEnabled = YES;
            }
            
            
        }
        
        if (app.rightWebController  != nil) {
            
            if (app.drawerController) {
                [app.drawerController setRightDrawerViewController:app.rightWebController];
            } else {
                //                app.sideMenuViewController.rightMenuViewController = app.rightWebController;
                app.sideMenuViewController.panGestureEnabled = YES;
            }
            
        }
        
    } else if (iV == 0) {
        
        if (app.drawerController) {
            [app.drawerController setLeftDrawerViewController:nil];
            [app.drawerController setRightDrawerViewController:nil];
        } else {
            
            app.sideMenuViewController.panGestureEnabled = NO;
            //            app.sideMenuViewController.leftMenuViewController = nil;
            //            app.sideMenuViewController.rightMenuViewController = nil;
        }
        
        
    }
    
}

- (void)getSlidingWindowState:(NSMutableArray *)inArguments {
    
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
                
            default:
                break;
                
        }
        
        
        
    } else if (app.sideMenuViewController){
        
        switch (app.sideMenuViewController.sideStatus) {
            case RESideLeft:
                windowStatus = RESideLeft;
                break;
            case RESideNone:
                windowStatus = RESideNone;
                break;
            case RESideRight:
                windowStatus = RESideRight;
                break;
                
            default:
                break;
        }
        
        
    }
    
    NSString * cbStr = [NSString stringWithFormat:@"if(uexWindow.cbSlidingWindowState!=null){uexWindow.cbSlidingWindowState(%ld);}",(long)windowStatus];
    
    [meBrwView stringByEvaluatingJavaScriptFromString:cbStr];
    
    
    
}


- (void)toggleSlidingWindow:(NSMutableArray *)inArguments
{
    if (inArguments.count == 0) {
        return;
    }
    
    NSDictionary * jsonDic = [[inArguments objectAtIndex:0] JSONValue];
    NSInteger isLeft = [[jsonDic objectForKey:@"mark"] integerValue];
    BOOL isReload = NO;
    if ([jsonDic objectForKey:@"reload"]) {
        isReload = [[jsonDic objectForKey:@"reload"] boolValue];
    }
    
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    
    if (isLeft == 0) {
        
        if (isReload) {
            
            
            ACEWebViewController * leftViewController = nil;
            
            if (app.drawerController) {
                leftViewController = (ACEWebViewController *)app.drawerController.leftDrawerViewController;
            } else {
                leftViewController = (ACEWebViewController *)app.sideMenuViewController.leftMenuViewController;
            }
            
            NSArray * webViews = [leftViewController.browserWindow subviews];
            
            for (EBrowserView * meBrowserView in webViews) {
                
                if ([meBrowserView respondsToSelector:@selector(reload)]) {
                    
                    [meBrowserView reload];
                    
                }
                
            }
            
        }
        
        
        if (app.drawerController) {
            [app.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:^(BOOL finished) {
                
            }];
        } else {
            
            if (app.sideMenuViewController.leftMenuVisible) {
                [app.sideMenuViewController hideMenuViewController];
            } else {
                [app.sideMenuViewController presentLeftMenuViewController];
            }
            
        }
        
        
        
    } else if (isLeft == 1)  {
        
        if (isReload) {
            
            ACEWebViewController * rightViewController = nil;
            
            if (app.drawerController) {
                rightViewController = (ACEWebViewController *)app.drawerController.rightDrawerViewController;
            } else {
                rightViewController = (ACEWebViewController *)app.sideMenuViewController.rightMenuViewController;
            }
            
            
            
            NSArray * webViews = [rightViewController.browserWindow subviews];
            
            for (EBrowserView * meBrowserView in webViews) {
                
                if ([meBrowserView respondsToSelector:@selector(reload)]) {
                    
                    [meBrowserView reload];
                    
                }
                
            }
            
        }
        
        if (app.drawerController) {
            [app.drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:^(BOOL finished) {
                
            }];
        } else {
            if (app.sideMenuViewController.rightMenuVisible) {
                [app.sideMenuViewController hideMenuViewController];
            } else {
                [app.sideMenuViewController presentRightMenuViewController];
            }
        }
        
        
        
    }
    
}

- (void)setSlidingWindow:(NSMutableArray *)inArguments
{
    
    if (inArguments.count == 0) {
        return;
    }
    
    NSString *argStr = (NSString *)[inArguments objectAtIndex:0];
    NSDictionary *dict = (NSDictionary*)[argStr objectFromJSONString];
    NSDictionary *leftDict = [dict objectForKey:@"leftSliding"];
    NSDictionary *rightDict = [dict objectForKey:@"rightSliding"];
    
    NSString *animationId = [dict objectForKey:@"animationId"];
    NSString *bgImg = [dict objectForKey:@"bg"];
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    ACEWebViewController *controller = nil;
    
    NSString *url = nil;
    NSNumber *numW = nil;
    NSInteger width = 0;
    
    ACEUINavigationController *meNav = nil;
    
    if (bgImg != nil
        && animationId != nil) {
        
        meNav = (ACEUINavigationController *)app.drawerController.centerViewController;
        
        app.drawerController = nil;
    }
    
    if (leftDict != nil) {
        
        url = [leftDict objectForKey:@"url"];
        numW = [leftDict objectForKey:@"width"];
        width = [numW integerValue];
        
        if (app.leftWebController == nil) {
            
            
            controller = [[ACEWebViewController alloc] init];
            
            app.leftWebController = controller;
            
            [self addBrowserWindowToWebController:controller url:url winName:AppRootLeftSlidingWinName];
            
            
            if (width > 0) {
                [app.drawerController setMaximumLeftDrawerWidth:width];
            }
            
            if (app.drawerController) {
                [app.drawerController setLeftDrawerViewController:app.leftWebController];
            } else {
                app.sideMenuViewController.leftMenuViewController = app.leftWebController;
            }
            
        }
        
    }
    
    if (rightDict != nil) {
        if (app.rightWebController == nil) {
            
            url = [rightDict objectForKey:@"url"];
            numW = [rightDict objectForKey:@"width"];
            width = [numW integerValue];
            
            controller = [[ACEWebViewController alloc] init];
            
            app.rightWebController = controller;
            
            [self addBrowserWindowToWebController:controller url:url winName:ApprootRightSlidingWinName];
            
            if (width > 0) {
                [app.drawerController setMaximumRightDrawerWidth:width];
            }
            
            if (app.drawerController) {
                [app.drawerController setRightDrawerViewController:app.rightWebController];
            } else {
                app.sideMenuViewController.rightMenuViewController = app.rightWebController;
            }
            
            
            
        }
    }
    
    
    if (bgImg != nil
        && animationId != nil) {
        
        app.sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:meNav
                                                                leftMenuViewController:app.leftWebController
                                                               rightMenuViewController:app.rightWebController];
        //        app.sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
        
        NSString * imgPath = [self absPath:bgImg];
        app.sideMenuViewController.backgroundImage = [UIImage imageWithContentsOfFile:imgPath];
        app.sideMenuViewController.menuPreferredStatusBarStyle = 1; // UIStatusBarStyleLightContent
        //     app.sideMenuViewController.delegate = self;
        //        app.sideMenuViewController.contentViewShadowColor = [UIColor redColor];
        //        app.sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
        //        app.sideMenuViewController.contentViewShadowOpacity = 0.6;
        //        app.sideMenuViewController.contentViewShadowRadius = 12;
        app.sideMenuViewController.contentViewShadowEnabled = NO;
        
        
        if (leftDict != nil) {
            
            if (width > 0) {
                app.sideMenuViewController.leftOffsetX = width;
            }
        }
        
        if (rightDict != nil) {
            
            if (width > 0) {
                app.sideMenuViewController.rightOffsetX = width;
            }
            
        }
        
        
        app.window.rootViewController = app.sideMenuViewController;
    }
    
    
    
    
    
}

-(void)setRightSwipeEnable:(NSMutableArray *)inArguments
{
    BOOL isNeedSwipeGestureRecognizer = YES;
    
    if ([inArguments count] > 0) {
        isNeedSwipeGestureRecognizer = [[inArguments objectAtIndex:0] boolValue];
    }
    
    EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    if (eCurBrwWnd.webController)
    {
        ACEWebViewController * webViewController = eCurBrwWnd.webController;
        webViewController.isNeedSwipeGestureRecognizer = isNeedSwipeGestureRecognizer;
    }
    
}

- (void)openPresentWindow:(NSMutableArray *)inArguments
{
    NSString * inUExWndName = [inArguments objectAtIndex:0];
    NSString * inDataType = [inArguments objectAtIndex:1];
    NSString * inData = [inArguments objectAtIndex:2];
    NSString * extraInfo = @"";
    if (inArguments.count > 8) {
        extraInfo = inArguments[8];
    }else if (inArguments.count > 3 && [inArguments[3] JSONValue]) {
        extraInfo = inArguments[3];
    }
    

    ACEWebWindowType type = ACEWebWindowTypePresent;
    
    //window 4.8
    
    NSArray *forbidWindow = meBrwView.meBrwCtrler.forebidWinsList;
    if (forbidWindow && [forbidWindow count]>0) {
        for (NSString *fWindowName in forbidWindow) {
            if ([fWindowName isEqualToString:inUExWndName]) {
                NSString *forbidStr = [NSString stringWithFormat:@"if(uexWidgetOne.cbError!=null){uexWidgetOne.cbError(%d,%d,\'%@\');}",0,10,inUExWndName];
                [meBrwView stringByEvaluatingJavaScriptFromString:forbidStr];
                //[self performSelectorOnMainThread:@selector(alertForbidView:) withObject:fWindowName waitUntilDone:NO];
                //[self alertForbidView:fWindowName];
                return;
            }
        }
    }
    
    if (meBrwView.hidden == YES) {
        return;
    }
    
    
    ACENSLog(@"PresentWindowTest open opener meBrwView = %@, meBrwView Name = %@", meBrwView, meBrwView.muexObjName);
    
    [self openWithController:(NSMutableArray *)@[inUExWndName, inDataType, inData, extraInfo, [NSNumber numberWithInteger:type]]];
}


- (void)openWithController:(NSMutableArray *)inArguments
{
    if (inArguments.count < 3) {
        return;
    }
    
    NSString *inUExWndName = [inArguments objectAtIndex:0];
    NSString *inDataType = [inArguments objectAtIndex:1];
    NSString *inData = [inArguments objectAtIndex:2];
    NSString *extraInfo = [inArguments objectAtIndex:3];
    
    ACEWebWindowType type = ACEWebWindowTypeNavigation;
    if ([inArguments count] > 4) {
        type = [[inArguments objectAtIndex:4] integerValue];
    }
    
    
    if (meBrwView.hidden == YES) {
        return;
    }
    EBrowserWindow *eBrwWnd = nil;
    EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    
    ACENSLog(@"NavWindowTest openWithController opener meBrwView = %@, meBrwView Name = %@", meBrwView, meBrwView.muexObjName);
    
    int flag = 0;
    NSURL *baseUrl = [meBrwView curUrl];
    
    //    EBrowserWindowContainer *eBrwWndContainer = nil;
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eCurBrwWnd.superview;
    
    if (eBrwWndContainer != nil && [eBrwWndContainer isKindOfClass:[EBrowserWindowContainer class]]) {
        //         eBrwWndContainer = (EBrowserWindowContainer*)eCurBrwWnd.superview;
        
        eCurBrwWnd.winContainer = eBrwWndContainer;
        
    } else {
        
        eBrwWndContainer = eCurBrwWnd.winContainer;
    }
    
    
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    
    
    
    if ((meBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING) == F_EBRW_FLAG_WINDOW_IN_OPENING) {
        return;
    }
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        [eBrwMainFrm invalidateAdTimers];
    }
    //inUExWndName.length != 0
    if (KUEXIS_NSString(inUExWndName)) {
        eBrwWnd = [eBrwWndContainer brwWndForKey:inUExWndName];
        if (eBrwWnd != nil) {
            [eBrwWndContainer removeFromWndDict:inUExWndName];
        }
        eBrwWnd = nil;
        
    }
    if (eBrwWnd == nil) {
        eBrwWnd = [[EBrowserWindow alloc]initWithFrame:CGRectMake(0, 0, eBrwWndContainer.bounds.size.width, eBrwWndContainer.bounds.size.height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt UExObjName:inUExWndName];
        
        eBrwWnd.webWindowType = type;
        eBrwWnd.windowName = inUExWndName;
        eBrwWnd.winContainer = eBrwWndContainer;
        
        ACENSLog(@"NavWindowTest openWithController new window eBrwWnd = %@, eBrwWnd Name = %@, eBrwWnd.meBrwView = %@", eBrwWnd, inUExWndName, eBrwWnd.meBrwView);
        
        //inUExWndName != nil && inUExWndName.length != 0
        if (KUEXIS_NSString(inUExWndName)) {
            [eBrwWndContainer.mBrwWndDict setObject:eBrwWnd forKey:inUExWndName];
        }
        
        
        if ((flag & F_EUEXWINDOW_OPEN_FLAG_HIDDEN) == F_EUEXWINDOW_OPEN_FLAG_HIDDEN) {
            if (eBrwWnd.hidden == NO) {
                eBrwWnd.hidden = YES;
            }
        } else {
            if (eBrwWnd.hidden == YES) {
                eBrwWnd.hidden = NO;
            }
            ////
            eBrwWnd.meBackWnd = eCurBrwWnd;
            eCurBrwWnd.meFrontWnd = eBrwWnd;
            //
        }
        
        
    } else {
        if (eBrwWnd == eCurBrwWnd && ((flag & F_EUEXWINDOW_OPEN_FLAG_RELOAD) != F_EUEXWINDOW_OPEN_FLAG_RELOAD)) {
            
            return;
        }
        if ((eBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
            
            return;
        }
        if ((flag & F_EUEXWINDOW_OPEN_FLAG_HIDDEN) == F_EUEXWINDOW_OPEN_FLAG_HIDDEN) {
            if (eBrwWnd.hidden == NO) {
                eBrwWnd.hidden = YES;
            }
            ////
            if ([eBrwWnd.meBackWnd isKindOfClass:[EBrowserWindow class]]) {
                eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
            }
            if ([eBrwWnd.meFrontWnd isKindOfClass:[EBrowserWindow class]]) {
                eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
            }
            //
        } else {
            if (eBrwWnd.hidden == YES) {
                eBrwWnd.hidden = NO;
            }
            ////
            if ([eBrwWnd.meBackWnd isKindOfClass:[EBrowserWindow class]]) {
                
                eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
            }
            if ([eBrwWnd.meFrontWnd isKindOfClass:[EBrowserWindow class]]) {
                
                eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
            }
            eBrwWnd.meBackWnd = eCurBrwWnd;
            eBrwWnd.meFrontWnd = nil;
            eCurBrwWnd.meFrontWnd = eBrwWnd;
            //
        }
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OPAQUE) == F_EUEXWINDOW_OPEN_FLAG_OPAQUE) {
        eBrwWnd.meBrwView.backgroundColor = [UIColor whiteColor];
    }
    //[extraInfo length] > 0
    if (KUEXIS_NSString(extraInfo)) {
        NSDictionary *extras = [extraInfo JSONValue];
        if (extras && [extras isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * extraDic = [[extras objectForKey:@"extraInfo"] mutableCopy];
            if(extraDic){
                [extraDic setValue: @"true" forKey: @"opaque"];
            }
            [self setExtraInfo: extraDic toEBrowserView: eBrwWnd.meBrwView];
            NSDictionary *popAnimationInfo=[extras objectForKey:@"animationInfo"];
            [eBrwWnd setPopAnimationInfo:popAnimationInfo];
        }
    }
    
    if ((flag & F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) == F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) {
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
    meBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WINDOW_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
    
    
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_DISABLE_CROSSDOMAIN) != 0) {
        eBrwWnd.meBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_HAS_PREOPEN) != 0) {
        eBrwWnd.mFlag |= F_EBRW_WND_FLAG_HAS_PREOPEN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OAUTH) == F_EUEXWINDOW_OPEN_FLAG_OAUTH) {
        eBrwWnd.mOAuthWndName = meBrwView.muexObjName;
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
    
    if (eBrwWnd.hidden == YES) {
        eBrwWnd.mOpenAnimiId = 0;
    }
    //inData.length != 0
    if (KUEXIS_NSString(inData)) {
        int dataType = [inDataType intValue];
        if (dataType == F_EUEXWINDOW_SRC_TYPE_URL) {
            NSString *urlStr = nil;
            if ([inData hasPrefix:F_WGTROOT_PATH]) {
                NSString * urlsub = [inData substringFromIndex:10];
                NSString * finaUrl = [NSString stringWithFormat:@"/%@",urlsub];
                urlStr = [meBrwView.mwWgt.widgetPath stringByAppendingString:finaUrl];
                
                if (![urlStr hasPrefix:@"file://"]) {
                    urlStr =[NSString stringWithFormat:@"file://%@", urlStr];
                }
            }else
            {
                urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inData];
            }
            
            NSURL *url = [BUtility stringToUrl:urlStr];
            
            
            if ((flag & F_EUEXWINDOW_OPEN_FLAG_RELOAD) != F_EUEXWINDOW_OPEN_FLAG_RELOAD) {
                if ([[eBrwWnd.meBrwView curUrl] isEqual:url] == YES) {
                    
                    [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
                    
                    //[meBrwView stringByEvaluatingJavaScriptFromString:@"window.opening=0;"];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
                    
                    int type = meBrwView.mwWgt.wgtType;
                    NSString *viewName =[meBrwView.curUrl absoluteString];
                    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:meBrwView.mwWgt];
                    [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
                    if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
                        NSArray *popViewArray = [meBrwView.meBrwWnd.mPopoverBrwViewDict allValues];
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
                    
                    if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
                        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
                    }
                    eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
                    meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
                    
                    [EBrowserWindow postWindowSequenceChange];
                    return;
                }
            }
            if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
                EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
                [eBrwWnd addHisEntry:eHisEntry];
                //				if ((flag & F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) == F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) {
                FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                NSString *data = [encryptObj decryptWithPath:url appendData:nil];
                
                [eBrwWnd.meBrwView loadWithData:data baseUrl:url];
                //				} else {
                //					[eBrwWnd.meBrwView loadWithUrl:url];
                //				}
            } else {
                [eBrwWnd.meBrwView loadWithUrl:url];
            }
            //8.7 数据统计
            int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
            NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
            if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
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
        } else if (dataType == F_EUEXWINDOW_SRC_TYPE_DATA) {
            [eBrwWnd.meBrwView loadWithData:inData baseUrl:baseUrl];
        }
    } else {
        [eBrwWndContainer bringSubviewToFront:eBrwWnd];
        
        [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
        NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
        if (eCurBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [eCurBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            }
        }
        
        
        //[meBrwView stringByEvaluatingJavaScriptFromString:@"window.opening=0;"];
        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        
        int goType = eBrwWnd.meBrwView.mwWgt.wgtType;
        NSString *goViewName =[eBrwWnd.meBrwView.curUrl absoluteString];
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
        
        if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
            [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
        eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
        meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        
    }
    [EBrowserWindow postWindowSequenceChange];
}

-(BOOL)isHaveString:(NSString *)inSouceString subSting:(NSString *)inSubSting{
    NSRange range = [inSouceString rangeOfString:inSubSting];
    if (range.location!=NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}

-(void)setExtraInfo:(NSDictionary *)extraDic toEBrowserView:(UIImageView *)inBrwView {
    
    if ([extraDic objectForKey:@"opaque"]) {
        
        BOOL opaque = [[extraDic objectForKey:@"opaque"] boolValue];
        
        if (opaque) {
            
            if ([extraDic objectForKey:@"bgColor"]) {
                
                NSString * bgColorStr = [extraDic objectForKey:@"bgColor"];
                if ([self isHaveString:bgColorStr subSting:@"://"]) {
                    
                    inBrwView.backgroundColor = [UIColor clearColor];
                    NSString * imgPath = [self absPath:bgColorStr];
                    inBrwView.image = [UIImage imageWithContentsOfFile:imgPath];
                    
                } else {
                    
                    inBrwView.image = nil;
                    UIColor *color = [EUtility colorFromHTMLString:bgColorStr];
                    inBrwView.backgroundColor = color;
                    
                }
                
            }
            
        } else {
            
            inBrwView.image = nil;
            inBrwView.backgroundColor = [UIColor clearColor];
            
        }
        
    }
    
}

- (void)open:(NSMutableArray *)inArguments {
    NSString *inUExWndName = [inArguments objectAtIndex:0];
    id inDataType = [inArguments objectAtIndex:1];
    NSString *inData = [inArguments objectAtIndex:2];
    id inAniID = [inArguments objectAtIndex:3];
    //NSString *inWidth = [inArguments objectAtIndex:4];
    //NSString *inHeight = [inArguments objectAtIndex:5];
    id inFlag = [inArguments objectAtIndex:6];
    NSString *inAniDuration = NULL;
    if ([inArguments count] >= 8) {
        inAniDuration = [inArguments objectAtIndex:7];
    }
    NSString * extraInfo = @"";
    if ([inArguments count] >= 9) {
        extraInfo = [inArguments objectAtIndex:8];
    }
    
    NSInteger flag = [inFlag intValue];
    
    
    //window 4.8
    NSArray *forbidWindow = meBrwView.meBrwCtrler.forebidWinsList;
    if (forbidWindow && [forbidWindow count]>0) {
        for (NSString *fWindowName in forbidWindow) {
            if ([fWindowName isEqualToString:inUExWndName]) {
                NSString *forbidStr = [NSString stringWithFormat:@"if(uexWidgetOne.cbError!=null){uexWidgetOne.cbError(%d,%d,\'%@\');}",0,10,inUExWndName];
                [meBrwView stringByEvaluatingJavaScriptFromString:forbidStr];
                //[self performSelectorOnMainThread:@selector(alertForbidView:) withObject:fWindowName waitUntilDone:NO];
                //[self alertForbidView:fWindowName];
                return;
            }
        }
    }
    
    if (meBrwView.hidden == YES) {
        return;
    }
    EBrowserWindow *eBrwWnd = nil;
    EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    ACENSLog(@"NavWindowTest open opener meBrwView = %@, meBrwView Name = %@", meBrwView, meBrwView.muexObjName);
    
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return;
    }
    
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        [self openWithController:(NSMutableArray *)@[inUExWndName, inDataType, inData, extraInfo]];
        
        return;
        
    } else if ((flag & F_EUExWINDOW_OPEN_FLAG_NAV_TYPE) == F_EUExWINDOW_OPEN_FLAG_NAV_TYPE) {
        
        [self openWithController:(NSMutableArray *)@[inUExWndName, inDataType, inData, extraInfo]];
        
        return;
        
    }
    
    
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    
    NSURL *baseUrl = [meBrwView curUrl];
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eCurBrwWnd.superview;
    ACENSLog(@"EUExWindow openWithWndName");
    if (inUExWndName) {
        ACENSLog(@"open wnd name is %@", inUExWndName);
    }
    if ((meBrwView.meBrwCtrler.meBrw.mFlag & F_EBRW_FLAG_WINDOW_IN_OPENING) == F_EBRW_FLAG_WINDOW_IN_OPENING) {
        ACENSLog(@"return for openning reason");
        return;
    }
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        [eBrwMainFrm invalidateAdTimers];
    }
    //inUExWndName.length != 0
    if (KUEXIS_NSString(inUExWndName)) {
        eBrwWnd = [eBrwWndContainer brwWndForKey:inUExWndName];
    }
    if (eBrwWnd == nil) {
        eBrwWnd = [[EBrowserWindow alloc]initWithFrame:CGRectMake(0, 0, eBrwWndContainer.bounds.size.width, eBrwWndContainer.bounds.size.height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt UExObjName:inUExWndName];
        
        
        ACENSLog(@"NavWindowTest open  new window eBrwWnd = %@, eBrwWnd Name = %@, eBrwWnd.meBrwView = %@", eBrwWnd, inUExWndName, eBrwWnd.meBrwView);
        
        //inUExWndName != nil && inUExWndName.length != 0
        if (KUEXIS_NSString(inUExWndName)) {
            [eBrwWndContainer.mBrwWndDict setObject:eBrwWnd forKey:inUExWndName];
        }
        
        
        if ((flag & F_EUEXWINDOW_OPEN_FLAG_HIDDEN) == F_EUEXWINDOW_OPEN_FLAG_HIDDEN) {
            if (eBrwWnd.hidden == NO) {
                eBrwWnd.hidden = YES;
            }
        } else {
            if (eBrwWnd.hidden == YES) {
                eBrwWnd.hidden = NO;
            }
            ////
            eBrwWnd.meBackWnd = eCurBrwWnd;
            eCurBrwWnd.meFrontWnd = eBrwWnd;
            //
        }
        
    } else {
        
        
        ACENSLog(@"NavWindowTest open reuse new window eBrwWnd = %@, eBrwWnd Name = %@, eBrwWnd.meBrwView = %@", eBrwWnd, inUExWndName, eBrwWnd.meBrwView);
        
        if (eBrwWnd == eCurBrwWnd && ((flag & F_EUEXWINDOW_OPEN_FLAG_RELOAD) != F_EUEXWINDOW_OPEN_FLAG_RELOAD)) {
            ACENSLog(@"open wnd is the same as cur window return");
            return;
        }
        if ((eBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_OPENING) == F_EBRW_WND_FLAG_IN_OPENING) {
            ACENSLog(@"open wnd return by being opened");
            return;
        }
        if ((flag & F_EUEXWINDOW_OPEN_FLAG_HIDDEN) == F_EUEXWINDOW_OPEN_FLAG_HIDDEN) {
            if (eBrwWnd.hidden == NO) {
                eBrwWnd.hidden = YES;
            }
            ////
            if ([eBrwWnd.meBackWnd isKindOfClass:[EBrowserWindow class]]) {
                eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
            }
            if ([eBrwWnd.meFrontWnd isKindOfClass:[EBrowserWindow class]]) {
                eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
            }
            //
        } else {
            if (eBrwWnd.hidden == YES) {
                eBrwWnd.hidden = NO;
            }
            ////
            if ([eBrwWnd.meBackWnd isKindOfClass:[EBrowserWindow class]]) {
                ACENSLog(@"eBrwWnd.meBackWnd is %x", eBrwWnd.meBackWnd);
                eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
            }
            if ([eBrwWnd.meFrontWnd isKindOfClass:[EBrowserWindow class]]) {
                ACENSLog(@"eBrwWnd.meFrontWnd is %x", eBrwWnd.meFrontWnd);
                eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
            }
            eBrwWnd.meBackWnd = eCurBrwWnd;
            eBrwWnd.meFrontWnd = nil;
            eCurBrwWnd.meFrontWnd = eBrwWnd;
            //
        }
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OPAQUE) == F_EUEXWINDOW_OPEN_FLAG_OPAQUE) {
        eBrwWnd.meBrwView.backgroundColor = [UIColor whiteColor];
    }
    //[extraInfo length] > 0
    if (KUEXIS_NSString(extraInfo)) {
        
        NSDictionary * extraDic = [extraInfo JSONValue];
        [self setExtraInfo:[extraDic objectForKey:@"extraInfo"] toEBrowserView:eBrwWnd.meBrwView];
        [eBrwWnd setPopAnimationInfo:[extraDic objectForKey:@"animationInfo"]];
        
    }
    
    if ((flag & F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) == F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) {
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
    meBrwView.meBrwCtrler.meBrw.mFlag |= F_EBRW_FLAG_WINDOW_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_OPENING;
    eBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_FIRST_LOAD_FINISHED;
    ACENSLog(@"set brw opening flag");
    ACENSLog(@"set brwWnd opening flag");
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_DISABLE_CROSSDOMAIN) != 0) {
        eBrwWnd.meBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_HAS_PREOPEN) != 0) {
        eBrwWnd.mFlag |= F_EBRW_WND_FLAG_HAS_PREOPEN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OAUTH) == F_EUEXWINDOW_OPEN_FLAG_OAUTH) {
        eBrwWnd.mOAuthWndName = meBrwView.muexObjName;
        [eBrwWnd.meBrwView setScalesPageToFit:YES];
        [eBrwWnd.meBrwView setMultipleTouchEnabled:YES];
    }
    //inAniID.length != 0
    
    eBrwWnd.mOpenAnimiId = [inAniID intValue];
    
    //inAniDuration && inAniDuration.length != 0
    if ([inAniDuration integerValue] > 0) {
        eBrwWnd.mOpenAnimiDuration = [inAniDuration floatValue]/1000.0f;
    } else {
        eBrwWnd.mOpenAnimiDuration = 0.2f;
    }
    if (eBrwWnd.hidden == YES) {
        eBrwWnd.mOpenAnimiId = 0;
    }
    
    //inData.length != 0
    if (KUEXIS_NSString(inData)) {
        int dataType = [inDataType intValue];
        if (dataType == F_EUEXWINDOW_SRC_TYPE_URL) {
            NSString *urlStr = nil;
            if ([inData hasPrefix:F_WGTROOT_PATH]) {
                NSString * urlsub = [inData substringFromIndex:10];
                NSString * finaUrl = [NSString stringWithFormat:@"/%@",urlsub];
                urlStr = [meBrwView.mwWgt.widgetPath stringByAppendingString:finaUrl];
                
                if (![urlStr hasPrefix:@"file://"]) {
                    urlStr =[NSString stringWithFormat:@"file://%@", urlStr];
                }
            }else{
                urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inData];
            }
            ACENSLog(@"*******url重定向%@",urlStr);
            NSURL *url = [BUtility stringToUrl:urlStr];
            ACENSLog(@"old url: %@", [[eBrwWnd.meBrwView curUrl] absoluteString]);
            ACENSLog(@"new url: %@", [url absoluteString]);
            if ((flag & F_EUEXWINDOW_OPEN_FLAG_RELOAD) != F_EUEXWINDOW_OPEN_FLAG_RELOAD) {
                if ([[eBrwWnd.meBrwView curUrl] isEqual:url] == YES) {
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
                    [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
                    ACENSLog(@"set opening false");
                    //[meBrwView stringByEvaluatingJavaScriptFromString:@"window.opening=0;"];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
                    
                    int type = meBrwView.mwWgt.wgtType;
                    NSString *viewName =[meBrwView.curUrl absoluteString];
                    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:meBrwView.mwWgt];
                    [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
                    if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
                        NSArray *popViewArray = [meBrwView.meBrwWnd.mPopoverBrwViewDict allValues];
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
                    
                    if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
                        NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
                    }
                    eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
                    meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
                    ACENSLog(@"reset brw opening flag");
                    ACENSLog(@"reset brwWnd opening flag");
                    return;
                }
            }
            if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION) {
                EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
                [eBrwWnd addHisEntry:eHisEntry];
                //				if ((flag & F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) == F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) {
                FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                NSString *data = [encryptObj decryptWithPath:url appendData:nil];
                ACENSLog(@"data: %@", data);
                [eBrwWnd.meBrwView loadWithData:data baseUrl:url];
                //				} else {
                //					[eBrwWnd.meBrwView loadWithUrl:url];
                //				}
            } else {
                [eBrwWnd.meBrwView loadWithUrl:url];
            }
            //8.7 数据统计
            int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
            NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
            NSLog(@" eCurBrwWnd viewName=%@",viewName);
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
            [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
            if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
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
        } else if (dataType == F_EUEXWINDOW_SRC_TYPE_DATA) {
            [eBrwWnd.meBrwView loadWithData:inData baseUrl:baseUrl];
        }
    } else {
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
        [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        int type = eCurBrwWnd.meBrwView.mwWgt.wgtType;
        NSString *viewName =[eCurBrwWnd.meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eCurBrwWnd.meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
        if (eCurBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [eCurBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            }
        }
        
        ACENSLog(@"set opening false");
        //[meBrwView stringByEvaluatingJavaScriptFromString:@"window.opening=0;"];
        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        
        int goType = eBrwWnd.meBrwView.mwWgt.wgtType;
        NSString *goViewName =[eBrwWnd.meBrwView.curUrl absoluteString];
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
        
        if ((eBrwWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBrwView.mAdType, eBrwWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBrwView.mAdFlag];
            [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
        eBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_IN_OPENING;
        meBrwView.meBrwCtrler.meBrw.mFlag &= ~F_EBRW_FLAG_WINDOW_IN_OPENING;
        ACENSLog(@"reset brw opening flag");
        ACENSLog(@"reset brwWnd opening flag");
    }
    [EBrowserWindow postWindowSequenceChange];
}
- (void)closeByName:(NSMutableArray *)inArguments {
    NSString *windowName=[inArguments objectAtIndex:0];
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    EBrowserWindow *popName=[meBrwView.meBrwWnd.mPopoverBrwViewDict objectForKey:windowName];
    EBrowserWindow *wndName=[eBrwWndContainer.mBrwWndDict objectForKey:windowName];
    
    if(popName){
        [popName removeFromSuperview];
        [eBrwWnd removeFromPopBrwViewDict:windowName];
        [meBrwView  stringByEvaluatingJavaScriptFromString:@"if(uexWindow.cbCloseByName!=null){uexWindow.cbCloseByName(0);}"];
    }else if (wndName) {
        
        
        if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation || eBrwWnd.webWindowType == ACEWebWindowTypePresent) {
            
            return;
        } else {
            [wndName removeFromSuperview];
            [eBrwWndContainer removeFromWndDict: windowName];
        }
        
        
        
        [meBrwView  stringByEvaluatingJavaScriptFromString:@"if(uexWindow.cbCloseByName!=null){uexWindow.cbCloseByName(0);}"];
    }else{
        //回调
        [meBrwView  stringByEvaluatingJavaScriptFromString:@"if(uexWindow.cbCloseByName!=null){uexWindow.cbCloseByName(1);}"];
    }
}

- (void)closeWindowByName:(NSString *)name
{
    
    if (name == nil) {
        return;
    }
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    EBrowserWindow *brwWnd=[eBrwWndContainer.mBrwWndDict objectForKey:name];
    
    if (brwWnd) {
        [brwWnd removeFromSuperview];
        [eBrwWndContainer removeFromWndDict: name];
    }
}



-(void)exitApp
{
    
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
- (void)closeAboveWndByName:(NSMutableArray *)inArguments
{
    
    NSString *windowName = nil;
    
    if (inArguments.count > 0) {
        
        windowName = [inArguments objectAtIndex:0];
        
    } else {
        
        //退出应用
        [self exitApp];
        return;
    }
    //    /windowName == nil|| windowName.length == 0
    if (!KUEXIS_NSString(windowName)) {
        
        ///退出应用
        [self exitApp];
        return;
    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;//调用此close方法的window
    //    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    EBrowserWindow *brwWnd = [eBrwWndContainer.mBrwWndDict objectForKey:windowName]; //即将关闭window链中的第一个window
    
    if (brwWnd == nil) {
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
    NSString *inAnimiId = NULL;
    NSString *inAniDuration = NULL;
    
    if ([inArguments count] > 0) {
        inAnimiId = [inArguments objectAtIndex:0];
    }
    if ([inArguments count] >= 2) {
        inAniDuration = [inArguments objectAtIndex:1];
    }
    
    NSInteger animiId = 0;
    NSTimeInterval aniDuration = 0.2;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    ACENSLog(@"NavWindowTest close  meBrwView = %@, meBrwView Name = %@, meBrwView.mType = %d", meBrwView, meBrwView.muexObjName, meBrwView.mType);
    
    
    if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        
        if (meBrwView.mType == F_EBRW_VIEW_TYPE_POPOVER) {
            
            if (meBrwView.muexObjName) {
                [meBrwView.meBrwWnd.mPopoverBrwViewDict removeObjectForKey:meBrwView.muexObjName];
            }
            
            if (meBrwView.superview) {
                [meBrwView removeFromSuperview];
            }
            
            
            
        } else if (meBrwView.mType == F_EBRW_VIEW_TYPE_MAIN) {
            
            ACEWebViewController *webController = eBrwWnd.webController;
            
            [webController.navigationController popViewControllerAnimated:YES];
        }
        
        return;
    }
    
    if (eBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        
        
        if (meBrwView.mType == F_EBRW_VIEW_TYPE_POPOVER) {
            
            if (meBrwView.muexObjName) {
                [meBrwView.meBrwWnd.mPopoverBrwViewDict removeObjectForKey:meBrwView.muexObjName];
            }
            
            if (meBrwView.superview) {
                [meBrwView removeFromSuperview];
            }
            
            
        } else if (meBrwView.mType == F_EBRW_VIEW_TYPE_MAIN) {
            
            ACEWebViewController *webController = eBrwWnd.webController;
            
            [webController dismissViewControllerAnimated:YES completion:^{
                //
            }];
        }
        [EBrowserWindow postWindowSequenceChange];
        return;
    }
    
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    if (!meBrwView) {
        return;
    }
    if (!meBrwView.meBrwWnd) {
        return;
    }
    if (meBrwView.mType == F_EBRW_VIEW_TYPE_POPOVER) {
        if (meBrwView.isMuiltPopover) {
            return;
        }
        //[meBrwView clean];
        if (meBrwView.muexObjName) {
            [meBrwView.meBrwWnd.mPopoverBrwViewDict removeObjectForKey:meBrwView.muexObjName];
        }
        if (meBrwView.superview) {
            [meBrwView removeFromSuperview];
        }
        [[meBrwView brwWidgetContainer] pushReuseBrwView:meBrwView];
        return;
    } else if (meBrwView.mType == F_EBRW_VIEW_TYPE_AD) {
        
        meBrwView.meBrwWnd.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        meBrwView.hidden = YES;
        [meBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
        return;
        
    } else if (meBrwView.mType == F_EBRW_VIEW_TYPE_MAIN) {
        
        if ([eBrwWndContainer.meRootBrwWnd isKindOfClass:[EBrowserWindow class]] && meBrwView == eBrwWndContainer.meRootBrwWnd.meBrwView) {
            return;
        }
        if ((eBrwWnd.mFlag & F_EBRW_WND_FLAG_IN_CLOSING) == F_EBRW_WND_FLAG_IN_CLOSING) {
            return;
        }
        eBrwWnd.mFlag |= F_EBRW_WND_FLAG_IN_CLOSING;
        //inAnimiId && inAnimiId.length != 0
        
        animiId = [inAnimiId intValue];
        
        if (animiId == -1) {
            if(eBrwWnd.usingPopAnimation){
                animiId = [ACEPOPAnimation reverseAnimationId:eBrwWnd.mOpenAnimiId];
            }else{
                animiId = [BAnimation ReverseAnimiId:eBrwWnd.mOpenAnimiId];
            }
            
        }
        //inAniDuration && inAniDuration.length != 0
        
        aniDuration = [inAniDuration floatValue] > 0 ? [inAniDuration floatValue]/1000 : 0.2;
        
        ////
        if ([eBrwWnd.meBackWnd isKindOfClass:[EBrowserWindow class]]) {
            eBrwWnd.meBackWnd.meFrontWnd = eBrwWnd.meFrontWnd;
        }
        if ([eBrwWnd.meFrontWnd isKindOfClass:[EBrowserWindow class]]) {
            eBrwWnd.meFrontWnd.meBackWnd = eBrwWnd.meBackWnd;
        }
        //meBrwView.muexObjName && meBrwView.muexObjName.length != 0
        if (KUEXIS_NSString(meBrwView.muexObjName)) {
            ACENSLog(@"window name is %@", meBrwView.muexObjName);
            [eBrwWndContainer removeFromWndDict:meBrwView.muexObjName];
        }
        eBrwWnd.mFlag = 0;
        
        ACENSLog(@"********animiId******%d",animiId);
        ACENSLog(@"********aniDuration******%f",aniDuration);
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
            if ([BAnimation isPush:animiId]) {
                [BAnimation doPushCloseAnimition:eBrwWnd animiId:animiId animiTime:aniDuration completion:^(BOOL finished) {
                    [eBrwWnd clean];
                    if (eBrwWnd.superview) {
                        [eBrwWnd removeFromSuperview];
                    }
                    [self closeWindowAfterAnimation:eBrwWnd];
                    
                }];
            }else {
                [BAnimation SwapAnimationWithView:eBrwWndContainer AnimiId:animiId AnimiTime:aniDuration];
                [eBrwWnd clean];
                if (eBrwWnd.superview) {
                    [eBrwWnd removeFromSuperview];
                }
                [self closeWindowAfterAnimation:eBrwWnd];
                
            }
            
            //
            NSArray * allLivingWindows = [eBrwWndContainer subviews];
            if ([allLivingWindows count]>0)
            {
                EBrowserWindow * presentLayerWindows = [allLivingWindows lastObject];
                [presentLayerWindows.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
            }
        }
    }
    [EBrowserWindow postWindowSequenceChange];
}

-(void)setSwipeRate:(NSMutableArray *)inArguments
{
    //配合android添加空函数
}
- (void)removeWindowForAnimation {
    EBrowserWindow *brwWnd = meBrwView.meBrwWnd;
    [self closeWindowAfterAnimation:brwWnd];
    [brwWnd clean];
    if (brwWnd.superview) {
        [brwWnd removeFromSuperview];
    }
    
}

- (void)closeWindowAfterAnimation:(EBrowserWindow*)brwWnd_ {
    NSString *fromViewName =NULL;
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
        [[meBrwView brwWidgetContainer] pushReuseBrwView:brwWnd_.meBrwView];
        
        
        brwWnd_.meBrwView = nil;
    }
    if (brwWnd_.meTopSlibingBrwView) {
        //[eBrwWnd.meTopSlibingBrwView clean];
        if (brwWnd_.meTopSlibingBrwView.superview) {
            [brwWnd_.meTopSlibingBrwView removeFromSuperview];
        }
        [[meBrwView brwWidgetContainer] pushReuseBrwView:brwWnd_.meTopSlibingBrwView];
        
        brwWnd_.meTopSlibingBrwView = NULL;
    }
    if (brwWnd_.meBottomSlibingBrwView) {
        //[eBrwWnd.meBottomSlibingBrwView clean];
        if (brwWnd_.meBottomSlibingBrwView.superview) {
            [brwWnd_.meBottomSlibingBrwView removeFromSuperview];
        }
        [[meBrwView brwWidgetContainer] pushReuseBrwView:brwWnd_.meBottomSlibingBrwView];
        
        brwWnd_.meBottomSlibingBrwView = NULL;
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
            
            [[meBrwView brwWidgetContainer] pushReuseBrwView:ePopView];
            
            [brwWnd_.mPopoverBrwViewDict removeAllObjects];
            
            brwWnd_.mPopoverBrwViewDict = NULL;
        }
    }
    //
    if (brwWnd_.mMuiltPopoverDict)
    {
        NSArray * mulitPopArray = [brwWnd_.mMuiltPopoverDict allValues];
        for (EScrollView * multiPopover in mulitPopArray)
        {
            if (multiPopover.subviews) {
                [multiPopover removeFromSuperview];
            }
        }
        [brwWnd_.mMuiltPopoverDict removeAllObjects];
        brwWnd_.mMuiltPopoverDict = nil;
    }
    if (meBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView) {
        brwWnd_.meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        meBrwView.meBrwCtrler.meBrwMainFrm.meAdBrwView.hidden = YES;
        [meBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
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
    if(goViewName&&[goViewName length]>0){
        [BUtility setAppCanViewActive:goType opener:fromViewName name:goViewName openReason:1 mainWin:0 appInfo:appInfo];
    }
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

-(void)moveeBrwWnd:(EBrowserWindow*)temp andTime:(float)aniDuration andAnimiId:(int)animiId
{
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
//动画代理方法
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    //    EBrowserWindow *eBrwWnd = (EBrowserWindow*)context;
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    [eBrwWnd clean];
    if (eBrwWnd.superview) {
        [eBrwWnd removeFromSuperview];
    }
    [self closeWindowAfterAnimation:eBrwWnd];
    
    //
    NSArray * allLivingWindows = [eBrwWndContainer subviews];
    if ([allLivingWindows count]>0)
    {
        EBrowserWindow * presentLayerWindows = [allLivingWindows lastObject];
        [presentLayerWindows.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
    }
    //    [eBrwWnd release];
}
//-(void)animationFinish:(NSString *)animationID finished:(NSNumber *)finished  context:(void *)context
//{
//    EBrowserWindow *eBrwWnd = (EBrowserWindow*)context;
//	[eBrwWnd clean];
//    if (eBrwWnd.superview) {
//        [eBrwWnd removeFromSuperview];
//    }
//    [eBrwWnd release];
//}
- (void)openSlibing:(NSMutableArray *)inArguments{
    id inSlibingType = [inArguments objectAtIndex:0];
    id inDataType = [inArguments objectAtIndex:1];
    NSString *inUrl = [inArguments objectAtIndex:2];
    NSString *inData = [inArguments objectAtIndex:3];
    //NSString *inWidth = [inArguments objectAtIndex:4];
    NSString *inHeight = [inArguments objectAtIndex:5];
    BOOL useContentSize = NO;
    if (!meBrwView) {
        return;
    }
    
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        return;
    }
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return;
    }
    
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    //inSlibingType == nil || inSlibingType.length == 0
    
    //    if (!KUEXIS_NSString(inSlibingType)) {
    //        return;
    //    }
    if (inHeight == nil) {
        return;
    }
    //inDataType == nil || inDataType.length == 0
    //    if (!KUEXIS_NSString(inDataType)) {
    //        return;
    //    }
    int height = [inHeight intValue];
    //inHeight.length == 0
    if (height <= 0) {
        useContentSize = YES;
        height = 1;
    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    NSURL *baseUrl = [meBrwView curUrl];
    int slibingType = [inSlibingType intValue];
    int dataType = [inDataType intValue];
    
    if (height > eBrwWnd.bounds.size.height) {
        height = eBrwWnd.bounds.size.height;
    }
    switch (slibingType) {
        case F_EBRW_VIEW_TYPE_SLIBING_TOP: {
            if (eBrwWnd.meTopSlibingBrwView == nil) {
                eBrwWnd.meTopSlibingBrwView = [[meBrwView brwWidgetContainer] popReuseBrwView];
                if (eBrwWnd.meTopSlibingBrwView) {
                    [eBrwWnd.meTopSlibingBrwView reuseWithFrame:CGRectMake(0, 0, eBrwWnd.bounds.size.width, height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:nil Type:F_EBRW_VIEW_TYPE_SLIBING_TOP];
                } else {
                    eBrwWnd.meTopSlibingBrwView = [[EBrowserView alloc] initWithFrame:CGRectMake(0, 0, eBrwWnd.bounds.size.width, height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:nil Type:F_EBRW_VIEW_TYPE_SLIBING_TOP];
                    eBrwWnd.meTopSlibingBrwView.frame = CGRectMake(0, 0, eBrwWnd.bounds.size.width, height);
                }
                switch (dataType) {
                    case F_EUEXWINDOW_SRC_TYPE_URL:
                        //inUrl && inUrl.length != 0
                        if (KUEXIS_NSString(inUrl)) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            [eBrwWnd.meTopSlibingBrwView loadWithUrl:url];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_DATA:
                        //inData && inData.length != 0
                        if (KUEXIS_NSString(inData)) {
                            [eBrwWnd.meTopSlibingBrwView loadWithData:inData baseUrl:baseUrl];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_URL_AND_DATA:
                        //inUrl && inUrl.length != 0&& inData
                        if (KUEXIS_NSString(inUrl) && inData) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                            NSString *data = [encryptObj decryptWithPath:url appendData:inData];
                            
                            [eBrwWnd.meTopSlibingBrwView loadWithData:data baseUrl:url];
                        }
                        break;
                    default:
                        break;
                }
            } else {
                if (eBrwWnd.meTopSlibingBrwView.superview) {
                    [eBrwWnd.meTopSlibingBrwView removeFromSuperview];
                }
                switch (dataType) {
                    case F_EUEXWINDOW_SRC_TYPE_URL:
                        //inUrl && inUrl.length != 0
                        if (KUEXIS_NSString(inUrl)) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            [eBrwWnd.meTopSlibingBrwView loadWithUrl:url];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_DATA:
                        //inData && inData.length != 0
                        if (KUEXIS_NSString(inData)) {
                            [eBrwWnd.meTopSlibingBrwView loadWithData:inData baseUrl:baseUrl];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_URL_AND_DATA:
                        //inUrl && inUrl.length != 0 && inData
                        if (KUEXIS_NSString(inUrl)&&inData) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                            NSString *data = [encryptObj decryptWithPath:url appendData:inData];
                            
                            [eBrwWnd.meTopSlibingBrwView loadWithData:data baseUrl:url];
                        }
                        break;
                    default:
                        break;
                }
                if (eBrwWnd.meTopSlibingBrwView.bounds.size.height != height) {
                    [eBrwWnd.meTopSlibingBrwView setFrame:CGRectMake(0, 0, eBrwWnd.bounds.size.width, height)];
                }
            }
            eBrwWnd.meTopSlibingBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE;
            if (useContentSize == YES) {
                eBrwWnd.meTopSlibingBrwView.mFlag |= F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE;
            }
            break;
        }
        case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM: {
            if (eBrwWnd.meBottomSlibingBrwView == nil) {
                eBrwWnd.meBottomSlibingBrwView = [[meBrwView brwWidgetContainer] popReuseBrwView];
                if (eBrwWnd.meBottomSlibingBrwView) {
                    [eBrwWnd.meBottomSlibingBrwView reuseWithFrame:CGRectMake(0, eBrwWnd.bounds.size.height-height, eBrwWnd.bounds.size.width, height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:nil Type:F_EBRW_VIEW_TYPE_SLIBING_BOTTOM];
                } else {
                    eBrwWnd.meBottomSlibingBrwView = [[EBrowserView alloc] initWithFrame:CGRectMake(0, eBrwWnd.bounds.size.height-height, eBrwWnd.bounds.size.width, height) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:nil Type:F_EBRW_VIEW_TYPE_SLIBING_BOTTOM];
                    eBrwWnd.meBottomSlibingBrwView.frame = CGRectMake(0, eBrwWnd.bounds.size.height-height, eBrwWnd.bounds.size.width, height);
                }
                switch (dataType) {
                    case F_EUEXWINDOW_SRC_TYPE_URL:
                        if (KUEXIS_NSString(inUrl)) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            [eBrwWnd.meBottomSlibingBrwView loadWithUrl:url];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_DATA:
                        if (KUEXIS_NSString(inData)) {
                            [eBrwWnd.meBottomSlibingBrwView loadWithData:inData baseUrl:baseUrl];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_URL_AND_DATA:
                        if (KUEXIS_NSString(inUrl)&&inData) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                            NSString *data = [encryptObj decryptWithPath:url appendData:inData];
                            
                            [eBrwWnd.meBottomSlibingBrwView loadWithData:data baseUrl:url];
                        }
                        break;
                    default:
                        break;
                }
            } else {
                if (eBrwWnd.meBottomSlibingBrwView.superview) {
                    [eBrwWnd.meBottomSlibingBrwView removeFromSuperview];
                }
                switch (dataType) {
                    case F_EUEXWINDOW_SRC_TYPE_URL:
                        if (KUEXIS_NSString(inUrl)) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            [eBrwWnd.meBottomSlibingBrwView loadWithUrl:url];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_DATA:
                        if (KUEXIS_NSString(inData)) {
                            [eBrwWnd.meBottomSlibingBrwView loadWithData:inData baseUrl:baseUrl];
                        }
                        break;
                    case F_EUEXWINDOW_SRC_TYPE_URL_AND_DATA:
                        if (KUEXIS_NSString(inUrl)&& inData) {
                            NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                            NSURL *url = [BUtility stringToUrl:urlStr];
                            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                            NSString *data = [encryptObj decryptWithPath:url appendData:inData];
                            
                            [eBrwWnd.meBottomSlibingBrwView loadWithData:data baseUrl:url];
                        }
                        break;
                    default:
                        break;
                }
                if (eBrwWnd.meBottomSlibingBrwView.bounds.size.height != height) {
                    [eBrwWnd.meBottomSlibingBrwView setFrame:CGRectMake(0, eBrwWnd.bounds.size.height-height, eBrwWnd.bounds.size.width, height)];
                }
            }
            eBrwWnd.meBottomSlibingBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE;
            if (useContentSize == YES) {
                eBrwWnd.meBottomSlibingBrwView.mFlag |= F_EBRW_VIEW_FLAG_USE_CONTENT_SIZE;
            }
            break;
        }
        default:
            break;
    }
}

- (void)closeSlibing:(NSMutableArray *)inArguments {
    id inSlibingType = [inArguments objectAtIndex:0];
    if (!meBrwView) {
        return;
    }
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        return;
    }
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    //!inSlibingType || inSlibingType.length == 0
    //    if (!KUEXIS_NSString(inSlibingType)) {
    //        return;
    //    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    int slibingType = [inSlibingType intValue];
    switch (slibingType) {
        case F_EBRW_VIEW_TYPE_SLIBING_TOP:
            if (eBrwWnd.meTopSlibingBrwView) {
                
                //[eBrwWnd.meTopSlibingBrwView clean];
                if (eBrwWnd.meTopSlibingBrwView.superview) {
                    [eBrwWnd.meTopSlibingBrwView removeFromSuperview];
                }
                
                [[meBrwView brwWidgetContainer] pushReuseBrwView:eBrwWnd.meTopSlibingBrwView];
                eBrwWnd.meTopSlibingBrwView = nil;
            }
            break;
        case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
            if (eBrwWnd.meBottomSlibingBrwView) {
                
                //[eBrwWnd.meBottomSlibingBrwView clean];
                if (eBrwWnd.meBottomSlibingBrwView.superview) {
                    [eBrwWnd.meBottomSlibingBrwView removeFromSuperview];
                }
                [[meBrwView brwWidgetContainer] pushReuseBrwView:eBrwWnd.meBottomSlibingBrwView];
                
                eBrwWnd.meBottomSlibingBrwView = nil;
            }
            break;
        default:
            break;
    }
}

- (void)showSlibing:(NSMutableArray *)inArguments {
    id inSlibingType = [inArguments objectAtIndex:0];
    if (!meBrwView) {
        return;
    }
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        return;
    }
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return;
    }
    
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    //!inSlibingType || inSlibingType.length == 0
    //    if (!KUEXIS_NSString(inSlibingType)) {
    //        return;
    //    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    int slibingType = [inSlibingType intValue];
    switch (slibingType) {
        case F_EBRW_VIEW_TYPE_SLIBING_TOP: {
            //UIView *topSubView = (UIView*)[eBrwWnd.meTopSlibingBrwView.subviews objectAtIndex:eBrwWnd.meTopSlibingBrwView.subviews.count - 1];
            //ACENSLog(@"top subview height %d", topSubView.bounds.size.height);
            if (eBrwWnd.meTopSlibingBrwView && !eBrwWnd.meTopSlibingBrwView.superview) {
                if (eBrwWnd.meBottomSlibingBrwView) {
                    if ((eBrwWnd.meBottomSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_LOAD_FINISHED) == F_EBRW_VIEW_FLAG_LOAD_FINISHED) {
                        //ACENSLog(@"document height is %d",[eBrwWnd.meBottomSlibingBrwView stringByEvaluatingJavaScriptFromString:@"document.height"]);
                        //ACENSLog(@"contetn size is %d",[eBrwWnd.meBottomSlibingBrwView contentS);
                        //[eBrwWnd.meBottomSlibingBrwView sizeToFit];
                        [eBrwWnd addSubview:eBrwWnd.meBottomSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(2)"];
                        //[eBrwWnd.meTopSlibingBrwView sizeToFit];
                        [eBrwWnd addSubview:eBrwWnd.meTopSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(1)"];
                    }
                } else {
                    //[eBrwWnd.meTopSlibingBrwView sizeToFit];
                    [eBrwWnd addSubview:eBrwWnd.meTopSlibingBrwView];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(1)"];
                }
            }
            break;
        }
        case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
            if (eBrwWnd.meBottomSlibingBrwView && !eBrwWnd.meBottomSlibingBrwView.superview) {
                if (eBrwWnd.meTopSlibingBrwView) {
                    if ((eBrwWnd.meTopSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_LOAD_FINISHED) == F_EBRW_VIEW_FLAG_LOAD_FINISHED) {
                        //ACENSLog(@"document height is %f",[eBrwWnd.meBottomSlibingBrwView stringByEvaluatingJavaScriptFromString:@"document.height"]);
                        //ACENSLog(@"scroll height is %f",[eBrwWnd.meBottomSlibingBrwView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"]);
                        //[eBrwWnd.meTopSlibingBrwView sizeToFit];
                        [eBrwWnd addSubview:eBrwWnd.meTopSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(1)"];
                        //[eBrwWnd.meBottomSlibingBrwView sizeToFit];
                        [eBrwWnd addSubview:eBrwWnd.meBottomSlibingBrwView];
                        [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(2)"];
                    }
                } else {
                    //[eBrwWnd.meBottomSlibingBrwView sizeToFit];
                    [eBrwWnd addSubview:eBrwWnd.meBottomSlibingBrwView];
                    [eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"window.uexOnshow(2)"];
                }
            }
            break;
        default:
            break;
    }
}

- (void)evaluateScript:(NSMutableArray *)inArguments {
    NSString *inWndName = [inArguments objectAtIndex:0];
    NSString *inSlibingType = [inArguments objectAtIndex:1];
    NSString *inScript = [inArguments objectAtIndex:2];
    EBrowserWindow *eBrwWnd = nil;
    EBrowserView *eBrwView = nil;
    //inWndName == nil || inSlibingType == nil || inSlibingType.length == 0 || inScript == nil || inScript.length == 0
    if (inWndName == nil || !KUEXIS_NSString(inScript)) {
        return;
    }
    if (!meBrwView) {
        return;
    }
    if (!meBrwView.meBrwWnd) {
        return;
    }
    //inWndName.length == 0
    if (!KUEXIS_NSString(inWndName)) {
        eBrwView = meBrwView;
        eBrwWnd = meBrwView.meBrwWnd;
    }
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)(meBrwView.meBrwWnd.superview);
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    
    if (eBrwWnd == nil) {
        eBrwWnd = [eBrwWndContainer brwWndForKey:inWndName];
    }
    if (eBrwWnd == nil) {
        return;
    }
    int slibingType = [inSlibingType intValue];
    EBrowserView *brwView = nil;
    switch (slibingType) {
        case F_EBRW_VIEW_TYPE_MAIN:
            brwView = eBrwWnd.meBrwView;
            //[eBrwWnd.meBrwView stringByEvaluatingJavaScriptFromString:inScript];
            break;
        case F_EBRW_VIEW_TYPE_SLIBING_TOP:
            if (eBrwWnd.meTopSlibingBrwView) {
                brwView = eBrwWnd.meTopSlibingBrwView;
                //[eBrwWnd.meTopSlibingBrwView stringByEvaluatingJavaScriptFromString:inScript];
            }
            break;
        case F_EBRW_VIEW_TYPE_SLIBING_BOTTOM:
            if (eBrwWnd.meBottomSlibingBrwView ) {
                brwView = eBrwWnd.meBottomSlibingBrwView;
                //[eBrwWnd.meBottomSlibingBrwView stringByEvaluatingJavaScriptFromString:inScript];
            }
            break;
        default:
            break;
    }
    if(!brwView){
        return;
    }
    [self performSelectorOnMainThread:@selector(evaluateScriptWithInfo:) withObject:@{kACEEvaluateScriptJavaScriptKey:inScript,kACEEvaluateScriptBrowserViewKey:brwView} waitUntilDone:NO];
}

- (void)evaluateScriptWithInfo:(NSDictionary *)infoDict{
    EBrowserView *brwView = infoDict[kACEEvaluateScriptBrowserViewKey];
    NSString *JSStr = infoDict[kACEEvaluateScriptJavaScriptKey];
    if (!brwView || !JSStr) {
        return;
    }
    [brwView stringByEvaluatingJavaScriptFromString:JSStr];
}



- (void)getBounce:(NSMutableArray *)inArguments
{
    
    BOOL bounce = [meBrwView.mScrollView bounces];
    
    [self jsSuccessWithName:@"uexWindow.cbBounceState" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:bounce];
}

- (void)setBounce:(NSMutableArray *)inArguments {
    if(inArguments.count < 1){
        return;
    }

    NSInteger value = [[inArguments objectAtIndex:0] integerValue];

    if (value == 0) {
        [meBrwView.mScrollView setBounces:NO];
    } else if (value == 1) {
        [meBrwView.mScrollView setBounces:YES];
        /*
         for( UIView *innerView in [meBrwView.mScrollView subviews] ) {
         if( [innerView isKindOfClass:[UIImageView class]] ) {
         innerView.hidden = YES;
         }
         }
         */
    }
    
}

- (void)notifyBounceEvent:(NSMutableArray *)inArguments {
    NSString *inType = [inArguments objectAtIndex:0];
    NSString *inValue = [inArguments objectAtIndex:1];
    int type = [inType intValue];
    int value = [inValue intValue];
    
    switch (type) {
        case EBounceViewTypeTop:
            if (value == 0) {
                meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH;
            } else {
                meBrwView.mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_TOP_REFRESH;
            }
            break;
        case EBounceViewTypeBottom:
            if (value == 0) {
                meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH;
            } else {
                meBrwView.mFlag |= F_EBRW_VIEW_FLAG_BOUNCE_VIEW_BOTTOM_REFRESH;
            }
            break;
        default:
            break;
    }
}

- (void)setBounceParams:(NSMutableArray *)inArguments {
    
    @try {
        NSString * inJson = [inArguments objectAtIndex:1];
        bounceParams = [[NSMutableDictionary alloc] initWithDictionary:[inJson JSONValue]];
        NSString *inType = [inArguments objectAtIndex:0];
        [bounceParams setObject:inType forKey:@"type"];
        
        int type = [inType intValue];
        
        switch (type)
        {
            case EBounceViewTypeTop:
                if(meBrwView.mTopBounceView){
                    NSString *levelText = [bounceParams objectForKey:@"levelText"];
                    //levelText && levelText.length>0
                    if (KUEXIS_NSString(levelText)) {
                        [meBrwView.mTopBounceView setLevelText:levelText];
                    }
                    //                return;
                }
                break;
            case EBounceViewTypeBottom:
                if(meBrwView.mBottomBounceView){
                    NSString *levelText=[bounceParams objectForKey:@"levelText"];
                    //levelText && levelText.length>0
                    if (KUEXIS_NSString(levelText)) {
                        [meBrwView.mBottomBounceView setLevelText:levelText];
                    }
                    //                return;
                }
                break;
            default:
                break;
        }
        NSString *imageInPath = nil;
        if ([inArguments count] ==3)
        {
            NSString * pjID=[inArguments objectAtIndex:2];
            if ([pjID isEqualToString:@"donghang"])
            {
                meBrwView.mBottomBounceView.projectID=pjID;
                meBrwView.mTopBounceView.projectID=pjID;
                [bounceParams setObject:pjID forKey:@"projectID"];
            }
            imageInPath =[bounceParams objectForKey:@"loadingImagePath"];
        }
        //imageInPath
        //imageInPath && imageInPath.length>0
        if (KUEXIS_NSString(imageInPath)) {
            imageInPath = [super absPath:imageInPath];
            [bounceParams setObject:imageInPath forKey:@"loadingImagePath"];
        }
        
        NSString * imagePath = [bounceParams objectForKey:@"imagePath"];
        //imagePath
        //imagePath && imagePath.length>0
        if (KUEXIS_NSString(imagePath)) {
            imagePath = [super absPath:imagePath];
            [bounceParams setObject:imagePath forKey:@"imagePath"];
        }
        //textColor
        NSString *textColor =[bounceParams objectForKey:@"textColor"];
        //textColor && textColor.length>0
        if (KUEXIS_NSString(textColor)) {
            UIColor *color = [EUtility colorFromHTMLString:textColor];
            [bounceParams setObject:color forKey:@"textColor"];
        }
        
    }
    @catch (NSException *exception) {
        
        NSLog(@"AppCan-->EUExWindow-->setBounceParams-->%@",[exception description]);
        
    }
    @finally {
        //
    }
    
}

- (void)topBounceViewRefresh:(NSMutableArray *)inArguments {
    
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN && meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    
    [meBrwView topBounceViewRefresh];
    
}

- (void)showBounceView:(NSMutableArray *)inArguments {
    id inType = [inArguments objectAtIndex:0];
    NSString *inColor = [inArguments objectAtIndex:1];
    NSString *inFlag = [inArguments objectAtIndex:2];
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN && meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        
        return;
    }
    int type = [inType intValue];
    UIColor *color = RGBCOLOR(226, 231, 237);
    int flag = [inFlag intValue];
    //inColor && inColor.length != 0
    if (KUEXIS_NSString(inColor)) {

        color = [EUtility colorFromHTMLString:inColor]?:color;
    }
    
    
    
    switch (type) {
        case EBounceViewTypeTop:
            if (!meBrwView.mTopBounceView) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"
                if ((flag & F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) == F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) {
                    meBrwView.mTopBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, -meBrwView.bounds.size.height, meBrwView.bounds.size.width, meBrwView.bounds.size.height) andType:EBounceViewTypeTop params:bounceParams];
                    [meBrwView.mTopBounceView setStatus:EBounceViewStatusPullToReload];
                } else {
                    meBrwView.mTopBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, -meBrwView.bounds.size.height, meBrwView.bounds.size.width, meBrwView.bounds.size.height)];
                }
#pragma clang diagnostic pop
                meBrwView.mTopBounceView.backgroundColor = color;
                meBrwView.mTopBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [meBrwView.mScrollView addSubview:meBrwView.mTopBounceView];
            } else if (meBrwView.mTopBounceView.hidden == YES) {
                meBrwView.mTopBounceView.hidden = NO;
            } else if (meBrwView.mTopBounceView) {
                if ((flag & F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) == F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) {
                    [meBrwView.mTopBounceView resetDataWithType:EBounceViewTypeTop andParams:bounceParams];
                    [meBrwView.mTopBounceView setStatus:EBounceViewStatusPullToReload];
                }
                meBrwView.mTopBounceView.backgroundColor = color;
                meBrwView.mTopBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            }
            break;
        case EBounceViewTypeBottom:
            if (!meBrwView.mBottomBounceView) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"

                if ((flag & F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) == F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) {
                    meBrwView.mBottomBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, meBrwView.mScrollView.contentSize.height, meBrwView.bounds.size.width, meBrwView.bounds.size.height) andType:EBounceViewTypeBottom params:bounceParams];
                    [meBrwView.mBottomBounceView setStatus:EBounceViewStatusPullToReload];
                } else {
                    meBrwView.mBottomBounceView = [[EBrowserViewBounceView alloc] initWithFrame:CGRectMake(0, meBrwView.mScrollView.contentSize.height, meBrwView.bounds.size.width, meBrwView.bounds.size.height)];
                }
#pragma clang diagnostic pop
                //NSLog(@"bouceViewFrame:%@ scrollViewFrame:%@ contentViewSizwe:%@",[NSValue valueWithCGRect:meBrwView.mBottomBounceView.frame],[NSValue valueWithCGRect:meBrwView.mScrollView.frame],[NSValue valueWithCGSize:meBrwView.mScrollView.contentSize]);
                
                meBrwView.mBottomBounceView.backgroundColor = color;
                meBrwView.mBottomBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                [meBrwView.mScrollView addSubview:meBrwView.mBottomBounceView];
                if (meBrwView.mScrollView.contentSize.height < meBrwView.mScrollView.frame.size.height) {
                    meBrwView.mBottomBounceView.hidden = YES;
                } else {
                    meBrwView.mBottomBounceView.hidden = NO;
                }
                
            } else if (meBrwView.mBottomBounceView.hidden == YES) {
                [meBrwView.mBottomBounceView setFrame:CGRectMake(0, meBrwView.mScrollView.contentSize.height, meBrwView.bounds.size.width, meBrwView.bounds.size.height)];
                meBrwView.mBottomBounceView.hidden = NO;
            } else if (meBrwView.mBottomBounceView) {
                if ((flag & F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) == F_EUEXWINDOW_BOUNCE_FLAG_CUSTOM) {
                    [meBrwView.mBottomBounceView resetDataWithType:EBounceViewTypeBottom andParams:bounceParams];
                    [meBrwView.mBottomBounceView setStatus:EBounceViewStatusPullToReload];
                }
                meBrwView.mBottomBounceView.backgroundColor = color;
                meBrwView.mBottomBounceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            }
            break;
        default:
            break;
    }
}

- (void)hiddenBounceView:(NSMutableArray *)inArguments {
    NSString *inType = [inArguments objectAtIndex:0];
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN && meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    int type = [inType intValue];
    
    switch (type) {
        case EBounceViewTypeTop:
            if (meBrwView.mTopBounceView) {
                meBrwView.mTopBounceView.hidden = YES;
            }
            break;
        case EBounceViewTypeBottom:
            if (meBrwView.mBottomBounceView) {
                meBrwView.mBottomBounceView.hidden = YES;
            }
            break;
        default:
            break;
    }
}

- (void)resetBounceView:(NSMutableArray *)inArguments {
    NSString *inType = [inArguments objectAtIndex:0];
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN && meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    int type = [inType intValue];
    
    switch (type) {
        case EBounceViewTypeTop:
            [meBrwView bounceViewFinishLoadWithType:EBounceViewTypeTop];
            break;
        case EBounceViewTypeBottom:
            [meBrwView bounceViewFinishLoadWithType:EBounceViewTypeBottom];
            break;
        default:
            break;
    }
}

-(void)setMultiPopoverFrame:(NSMutableArray *)inArguments
{
    
    if ([inArguments count] < 5) {
        return;
    }
    
    NSString * popoverName = [inArguments objectAtIndex:0];
    float x = [[inArguments objectAtIndex:1] floatValue];
    float y = [[inArguments objectAtIndex:2] floatValue];
    float w = [[inArguments objectAtIndex:3] floatValue];
    float h = [[inArguments objectAtIndex:4] floatValue];
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    EScrollView * muiltPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:popoverName];
    NSInteger index = muiltPopover.scrollView.contentOffset.x / muiltPopover.scrollView.frame.size.width;
    
    if (muiltPopover) {
        muiltPopover.frame = CGRectMake(x, y, w, h);
        NSLog(@"muiltPopover.scrollView=%@",muiltPopover.scrollView);
        float height = 0;
        float popViewX = 0;
        float popViewY = 0;
        
        NSMutableDictionary *viewDict = [[NSMutableDictionary alloc] init];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        NSString *position = [ud valueForKey:@"addViewToCurrentMultiPop_position"];
        
        float superViewH = muiltPopover.scrollView.frame.size.height;
        
        NSLog(@"muiltPopover.scrollView.subviews-------->>>>>%@",muiltPopover.scrollView.subviews);
        
        for (UIView *view in muiltPopover.scrollView.subviews) {
            
            if([view isKindOfClass:[EBrowserView class]]){
                int index = view.frame.origin.x / view.frame.size.width;
                EBrowserView *ePopView = (EBrowserView*)view;
                popViewX = index * w;
                popViewY = ePopView.frame.origin.y;
                height = ePopView.frame.size.height;
                float dh = superViewH - height;
                ePopView.frame = CGRectMake(popViewX, popViewY, w, h - dh);
                NSLog(@"ePopView%d=%@;ePopView.scrollView=%@",index,ePopView,ePopView.scrollView);
                [viewDict setObject:view forKey:[NSString stringWithFormat:@"%lf",view.frame.origin.x]];
            }
            
            if([view isKindOfClass:[ACESubMultiPopScrollView class]]){
                
                CGRect subPopViewFrame = view.frame;
                subPopViewFrame.size.width = w;
                if ([position isEqualToString:@"1"]) {
                    subPopViewFrame.origin.y = h + 2 - subPopViewFrame.size.height;
                }
                view.frame = subPopViewFrame;
            }
        }
        
        muiltPopover.scrollView.frame = CGRectMake(0, 0, w, h);
        muiltPopover.scrollView.contentSize = CGSizeMake(viewDict.count * w, h);
        CGPoint point = muiltPopover.scrollView.contentOffset;
        point.x = w * index;
        muiltPopover.scrollView.contentOffset = point;
        
        NSLog(@"muiltPopover.scrollView=%@",muiltPopover.scrollView);
    }
    
}

-(void)evaluateMultiPopoverScript:(NSMutableArray *)inArguments
{
    
    if ([inArguments count] < 4) {
        return;
    }
    
    NSString * windowName = [inArguments objectAtIndex:0];
    NSString * multiPopoverName = [inArguments objectAtIndex:1];
    NSString * inPageName = [inArguments objectAtIndex:2];
    NSString * inScript = [inArguments objectAtIndex:3];
    
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    //[windowName length] > 0
    if (KUEXIS_NSString(windowName)) {
        EBrowserWindow * tempWindow = [eBrwWndContainer brwWndForKey:windowName];
        if (tempWindow) {
            eBrwWnd = tempWindow;
        }
    }
    
    //    UIScrollView * muiltPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:multiPopoverName];
    EBrowserView * ePopBrwView = [eBrwWnd.mPopoverBrwViewDict objectForKey:inPageName];
    if (!ePopBrwView) {
        return;
    }
    [self performSelectorOnMainThread:@selector(evaluateScriptWithInfo:) withObject:@{kACEEvaluateScriptBrowserViewKey:ePopBrwView,kACEEvaluateScriptJavaScriptKey:inScript} waitUntilDone:NO];
    //[ePopBrwView stringByEvaluatingJavaScriptFromString:inScript];
    
}

- (void)windowBack:(NSMutableArray *)inArguments {
    
    NSString *inAnimiID = nil;
    NSString *inAnimiDuration = nil;
    
    if ([inArguments count] >=1) {
        inAnimiID = [inArguments objectAtIndex:0];
    }
    
    
    if ([inArguments count] >= 2) {
        inAnimiDuration = [inArguments objectAtIndex:1];
    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        return;
    }
    
    if (eBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        
        return;
    }
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    int animiId = 0;
    float animiDuration = 0.2f;
    if (eBrwWnd.meBackWnd) {
        if (eBrwMainFrm.meAdBrwView) {
            eBrwMainFrm.meAdBrwView.hidden = YES;
            [eBrwMainFrm invalidateAdTimers];
        }
        
        animiId = [inAnimiID intValue];
        if (KUEXIS_ZERO(inAnimiDuration)){
            animiDuration = 0;
        }else{
            animiDuration = [inAnimiDuration floatValue] > 0 ? [inAnimiDuration floatValue]/1000 : 0.2;
        }
        
        
        
        
        [eBrwWndContainer bringSubviewToFront:eBrwWnd.meBackWnd];
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
        }else if ([BAnimation isMoveIn:animiId]) {
            [BAnimation doMoveInAnimition:eBrwWnd.meBackWnd animiId:animiId animiTime:animiDuration];
        }else if ([BAnimation isPush:animiId]) {
            [BAnimation doPushAnimition:eBrwWnd.meBackWnd animiId:animiId animiTime:animiDuration];
        }else {
            [BAnimation SwapAnimationWithView:eBrwWndContainer AnimiId:animiId AnimiTime:animiDuration];
        }
        [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        //8.7
        int type = meBrwView.mwWgt.wgtType;
        NSString *viewName =[meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
        if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [meBrwView.meBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            }
        }
        [eBrwWnd.meBackWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        //8.7
        int goType = eBrwWnd.meBackWnd.meBrwView.mwWgt.wgtType;
        NSString *goViewName =[eBrwWnd.meBackWnd.meBrwView.curUrl absoluteString];
        {
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eBrwWnd.meBackWnd.meBrwView.mwWgt];
            [BUtility setAppCanViewActive:goType opener:viewName name:goViewName openReason:1 mainWin:0 appInfo:appInfo];
        }
        if (eBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [eBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                //[BUtility setAppCanViewBackground:type name:closeViewName closeReason:0];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
            }
        }
        if ((eBrwWnd.meBackWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meBackWnd.meBrwView.mAdType, eBrwWnd.meBackWnd.meBrwView.mAdDisplayTime, eBrwWnd.meBackWnd.meBrwView.mAdIntervalTime, eBrwWnd.meBackWnd.meBrwView.mAdFlag];
            [eBrwWnd.meBackWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
    }
    [EBrowserWindow postWindowSequenceChange];
}

- (void)windowForward:(NSMutableArray *)inArguments {
    NSString *inAnimiID = [inArguments objectAtIndex:0];
    NSString *inAnimiDuration = NULL;
    if ([inArguments count] >= 2) {
        inAnimiDuration = [inArguments objectAtIndex:1];
    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    
    if (eBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        return;
    }
    if (eBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        
        return;
    }
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    int animiId = 0;
    float animiDuration = 0.2f;
    if (eBrwWnd.meFrontWnd) {
        if (eBrwMainFrm.meAdBrwView) {
            eBrwMainFrm.meAdBrwView.hidden = YES;
            [eBrwMainFrm invalidateAdTimers];
        }
        
        animiId = [inAnimiID intValue];
        
        //inAnimiDuration && inAnimiDuration.length != 0
        if (KUEXIS_ZERO(inAnimiDuration)){
            animiDuration = 0;
        }else{
            animiDuration = [inAnimiDuration floatValue] > 0 ? [inAnimiDuration floatValue]/1000 : 0.2;
        }
        [eBrwWndContainer bringSubviewToFront:eBrwWnd.meFrontWnd];
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
        }else if ([BAnimation isMoveIn:animiId]) {
            [BAnimation doMoveInAnimition:eBrwWnd.meFrontWnd animiId:animiId animiTime:animiDuration];
        }else if ([BAnimation isPush:animiId]) {
            [BAnimation doPushAnimition:eBrwWnd.meFrontWnd animiId:animiId animiTime:animiDuration];
        }else {
            [BAnimation SwapAnimationWithView:eBrwWndContainer AnimiId:animiId AnimiTime:animiDuration];
        }
        [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(1);}"];
        //8.7
        int type = meBrwView.mwWgt.wgtType;
        NSString *viewName =[meBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:meBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:1 appInfo:appInfo];
        if (meBrwView.meBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [meBrwView.meBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
            }
        }
        
        [eBrwWnd.meFrontWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
        
        //8.7
        int goType = eBrwWnd.meFrontWnd.meBrwView.mwWgt.wgtType;
        NSString *goViewName =[eBrwWnd.meFrontWnd.meBrwView.curUrl absoluteString];
        {
            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eBrwWnd.meFrontWnd.meBrwView.mwWgt];
            [BUtility setAppCanViewActive:goType opener:viewName name:goViewName openReason:1 mainWin:0 appInfo:appInfo];
        }
        if (eBrwWnd.mPopoverBrwViewDict) {
            NSArray *popViewArray = [eBrwWnd.mPopoverBrwViewDict allValues];
            for (EBrowserView *ePopView in popViewArray) {
                int type =ePopView.mwWgt.wgtType;
                NSString *viewName =[ePopView.curUrl absoluteString];
                //[BUtility setAppCanViewBackground:type name:closeViewName closeReason:0];
                NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopView.mwWgt];
                [BUtility setAppCanViewActive:type opener:goViewName name:viewName openReason:0 mainWin:1 appInfo:appInfo];
            }
        }
        if ((eBrwWnd.meFrontWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
            NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eBrwWnd.meFrontWnd.meBrwView.mAdType, eBrwWnd.meFrontWnd.meBrwView.mAdDisplayTime, eBrwWnd.meFrontWnd.meBrwView.mAdIntervalTime, eBrwWnd.meFrontWnd.meBrwView.mAdFlag];
            [eBrwWnd.meFrontWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
        }
    }
    [EBrowserWindow postWindowSequenceChange];
}

- (void)loadObfuscationData:(NSMutableArray *)inArguments {
    NSString *inUrl = [inArguments objectAtIndex:0];
    //!inUrl || inUrl.length == 0
    if (!KUEXIS_NSString(inUrl)) {
        return;
    }
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    NSURL *baseUrl = [meBrwView curUrl];
    NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
    NSURL *url = [BUtility stringToUrl:urlStr];
    if (F_WWIDGET_OBFUSCATION == meBrwView.mwWgt.obfuscation) {
        FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
        NSString *data = [encryptObj decryptWithPath:url appendData:nil];
        
        EBrowserHistoryEntry *eHisEntry = [[EBrowserHistoryEntry alloc]initWithUrl:url obfValue:YES];
        [eBrwWnd addHisEntry:eHisEntry];
        [meBrwView loadWithData:data baseUrl:url];
    } else {
        [meBrwView loadWithUrl:url];
    }
}

- (void)closeToast:(NSMutableArray *)inArguments {
    if (mToastView) {
        [mToastView removeFromSuperview];
        mToastView = nil;
        if (mToastTimer) {
            [mToastTimer invalidate];
            mToastTimer = nil;
        }
    }
}

- (void)closeAlert {
    if (mbAlertView) {
        
        mbAlertView = nil;
    }
}

- (id)getState:(NSMutableArray *)inArguments {
    if (!meBrwView) {
        return @-1;
    }
    if (!meBrwView.meBrwWnd) {
        return @-1;
    }
    //
    
    
    EBrowserWindow *eCurBrwWnd = meBrwView.meBrwWnd;
    
    
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        
        ACEWebViewController *webController = (ACEWebViewController *)eCurBrwWnd.webController;
        
        if (webController == webController.navigationController.topViewController) {
            [self jsSuccessWithName:F_CB_WINDOW_GET_STATE opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:0];
            return @0;
        } else {
            [self jsSuccessWithName:F_CB_WINDOW_GET_STATE opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
            return @1;
        }
        
        
        
    }
    if (eCurBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        
        
        
        
        return @-1;
    }
    
    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
    
    
    if (!eBrwWndContainer) {
        return @-1;
    }
    if ([meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] == eBrwWndContainer) {
        if ([eBrwWndContainer aboveWindow] == meBrwView.meBrwWnd) {
            [self jsSuccessWithName:F_CB_WINDOW_GET_STATE opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:0];
            return @0;
        }
    }
    [self jsSuccessWithName:F_CB_WINDOW_GET_STATE opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
    return @-1;
}

- (void)toast:(NSMutableArray *)inArguments {
    NSString *inType = [inArguments objectAtIndex:0];
    NSString *inPos = [inArguments objectAtIndex:1];
    NSString *inMsg = [inArguments objectAtIndex:2];
    NSString *inDuration = [inArguments objectAtIndex:3];
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    float wndWidth = eBrwWnd.bounds.size.width;
    float wndHeight = eBrwWnd.bounds.size.height;
    CGRect toastViewRect;
    int pos = 5;
    int type = 0;
    if (mToastView) {
        [mToastView removeFromSuperview];
        if (mToastTimer) {
            [mToastTimer invalidate];
            mToastTimer = nil;
        }
    }
    
    int temPos = [inPos intValue];
    if (temPos >=1 && temPos<=9) {
        pos = temPos;
    }
    

    type = [inType intValue];

    toastViewRect = [BToastView viewRectWithPos:pos wndWidth:wndWidth wndHeight:wndHeight];
    mToastView = [[BToastView alloc]initWithFrame:toastViewRect Type:type Pos:pos];
    mToastView.mTextView.text = inMsg;
    [eBrwWnd addSubview:mToastView];
    
    float duration = [inDuration floatValue];
    if (duration > 0) {
        float fDuration = duration / 1000;
        mToastTimer = [NSTimer scheduledTimerWithTimeInterval:fDuration target:self selector:@selector(closeToast:) userInfo:nil repeats:NO];
    }
    
}

- (void)closeStatusBarNotification {
    NSString *text = NULL;
    UIDeviceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
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
    if ([inArguments count]<2) {
        return;
    }
    NSString *text = [inArguments objectAtIndex:0];
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    UIDeviceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
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
        eBrwMainFrm.mSBWnd = [[BStatusBarWindow alloc] initWithFrame:sbFrame andNotifyText:text];
        AudioServicesPlaySystemSound(eBrwMainFrm.mSBWnd.mAlertSoundID);
        [eBrwMainFrm.mSBWnd makeKeyAndVisible];
    } else {
        if (eBrwMainFrm.mSBWnd.mInitOrientation == statusBarOrientation) {
            if (eBrwMainFrm.mSBWnd.hidden == YES) {
                eBrwMainFrm.mSBWnd.hidden = NO;
                [eBrwMainFrm.mSBWnd setNotifyText:text];
                AudioServicesPlaySystemSound(eBrwMainFrm.mSBWnd.mAlertSoundID);
            } else {
                [eBrwMainFrm.mNotifyArray addObject:text];
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
        //        NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithObjectsAndKeys:@"0",@"notificationId",nil];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:1];
        id  json = [[inArguments objectAtIndex:1] JSONFragmentValue];
        if (json&&[json isKindOfClass:[NSDictionary class]]) {
            [dict addEntriesFromDictionary:json];
        }else{
            [dict setObject:[inArguments objectAtIndex:1] forKey:@"userInforStr"];
        }
        [notification setUserInfo:(NSDictionary *)dict];
        notification.alertBody=text;
        notification.hasAction = YES;
        //启动这个通知
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
    
}

- (void)openPopover:(NSMutableArray *)inArguments {
    
    NSString *inPopName = [inArguments objectAtIndex:0];
    id inDataType = [inArguments objectAtIndex:1];
    NSString *inUrl = [inArguments objectAtIndex:2];
    NSString *inData = [inArguments objectAtIndex:3];
    id inX = [inArguments objectAtIndex:4];
    id inY = [inArguments objectAtIndex:5];
    id inW = [inArguments objectAtIndex:6];
    id inH = [inArguments objectAtIndex:7];
    id inFontSize = [inArguments objectAtIndex:8];
    id inFlag = [inArguments objectAtIndex:9];
    id inBottom = nil;
    if (inArguments.count >= 11) {
        inBottom =[inArguments objectAtIndex:10];
    }
    NSString * extraInfo = @"";
    if ([inArguments count] >= 12) {
        extraInfo = [inArguments objectAtIndex:11];
    }
    NSDictionary * extraDic = nil;
    if (KUEXIS_NSString(extraInfo)) {
        extraDic = [[extraInfo JSONValue] objectForKey:@"extraInfo"];
    }
    
    //****************************************************
    int x=0,
    y=0,
    w=meBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.width,
    h=meBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.height,
    fontSize=0,
    flag=0,
    bottom=0;
    if (!meBrwView) {
        return;
    }
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    
    NSURL *baseUrl = [meBrwView curUrl];
    //inPopName.length == 0
    if (!KUEXIS_NSString(inPopName)) {
        return;
    }
    if (meBrwView.mType == F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    //inX.length != 0
    
    x = [inX intValue];
    
    //inY.length != 0
    
    y = [inY intValue];
    
    //inW.length != 0
    if ([inW intValue] > 0) {
        w = [inW intValue];
    } else {
        w = w - x;
    }
    //inH.length != 0
    if ([inH intValue] > 0) {
        h = [inH intValue];
    } else {
        h = h - y;
    }
    //inFontSize.length != 0
    
    fontSize = [inFontSize intValue];
    
    //inFlag.length != 0
    
    flag = [inFlag intValue];
    
    //******************************************************
    //inBottom.length != 0
    
    bottom = [inBottom intValue];
    
    if (bottom > 0) {
        h = meBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.height - y - bottom;
    }
    //******************************************************
    if (w == 0 || h == 0) {
        return;
    }
    
    ACENSLog(@"NavWindowTest openPopover inPopName = %@", inPopName);
    
    [self openMuilPopwith:eBrwWnd and:ePopBrwView and:eBrwWndContainer and:inPopName and:inDataType and:inUrl and:inData and:baseUrl and:x and:y and:w and:h and:fontSize and:flag and:bottom and:nil andIsMuiltPop:NO andExtraInfo:extraDic];
}

- (void)insertPopoverAbovePopover:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    NSString *inName = [inArguments objectAtIndex:0];
    NSString *inPopoverName = [inArguments objectAtIndex:1];
    if (!inName || !inPopoverName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    if (!popoverDict) {
        return;
    }
    UIView *view = [popoverDict objectForKey:inName];
    UIView *popView = [popoverDict objectForKey:inPopoverName];
    if (!view || !popView) {
        return;
    }
    [meBrwView.meBrwWnd insertSubview:view aboveSubview:popView];
}

- (void)insertPopoverBelowPopover:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    NSString *inName = [inArguments objectAtIndex:0];
    NSString *inPopoverName = [inArguments objectAtIndex:1];
    if (!inName || !inPopoverName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    if (!popoverDict) {
        return;
    }
    UIView *view = [popoverDict objectForKey:inName];
    UIView *popView = [popoverDict objectForKey:inPopoverName];
    if (!view || !popView) {
        return;
    }
    [meBrwView.meBrwWnd insertSubview:view belowSubview:popView];
}

- (void)sendPopoverToBack:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    NSString *inName = [inArguments objectAtIndex:0];
    if (!inName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    UIView *view = [popoverDict objectForKey:inName];
    if (view != nil) {
        [meBrwView.meBrwWnd insertSubview:view aboveSubview:meBrwView.meBrwWnd.meBrwView];
        
    } else {
        
        NSMutableDictionary *multipopoverDict = meBrwView.meBrwWnd.mMuiltPopoverDict;
        EScrollView * muiltPopover = [multipopoverDict objectForKey:inName];
        
        if(!muiltPopover) {
            return;
        }
        
        [meBrwView.meBrwWnd insertSubview:muiltPopover aboveSubview:meBrwView.meBrwWnd.meBrwView];
    }
    
}

- (void)bringPopoverToFront:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    NSString *inName = [inArguments objectAtIndex:0];
    if (!inName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    UIView *view = [popoverDict objectForKey:inName];
    if (view != nil) {
        [meBrwView.meBrwWnd bringSubviewToFront:view];
    } else {
        
        NSMutableDictionary *multipopoverDict = meBrwView.meBrwWnd.mMuiltPopoverDict;
        EScrollView * muiltPopover = [multipopoverDict objectForKey:inName];
        
        if(!muiltPopover) {
            return;
        }
        
        [meBrwView.meBrwWnd bringSubviewToFront:muiltPopover];
    }
    
}

- (void)insertAbove:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    NSString *inName = [inArguments objectAtIndex:0];
    if (!inName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    UIView *view = [popoverDict objectForKey:inName];
    if (!view) {
        return;
    }
    [meBrwView.meBrwWnd insertSubview:meBrwView aboveSubview:view];
}

- (void)insertBelow:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    NSString *inName = [inArguments objectAtIndex:0];
    if (!inName) {
        return;
    }
    NSMutableDictionary *popoverDict = meBrwView.meBrwWnd.mPopoverBrwViewDict;
    UIView *view = [popoverDict objectForKey:inName];
    if (!view) {
        return;
    }
    [meBrwView.meBrwWnd insertSubview:meBrwView belowSubview:view];
}

- (void)bringToFront:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    [meBrwView.meBrwWnd bringSubviewToFront:meBrwView];
}

- (void)sendToBack:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_POPOVER) {
        return;
    }
    [meBrwView.meBrwWnd insertSubview:meBrwView aboveSubview:meBrwView.meBrwWnd.meBrwView];
}

- (void)openAd:(NSMutableArray *)inArguments {
    NSString *inType = [inArguments objectAtIndex:0];
    NSString *inDisplayTime = [inArguments objectAtIndex:1];
    NSString *inInterval = [inArguments objectAtIndex:2];
    NSString *inFlag = [inArguments objectAtIndex:3];
    int type = F_EBRW_MAINFRM_AD_TYPE_TOP,
    flag = 0;
    CGRect ADFrame;
    if (!meBrwView) {
        return;
    }
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    if (meBrwView.meBrwCtrler.mwWgtMgr.wMainWgt.openAdStatus != 1) {
        return;
    }
    meBrwView.mFlag |= F_EBRW_VIEW_FLAG_HAS_AD;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    
    type = [inType intValue];
    meBrwView.mAdType = type;
    
    
    meBrwView.mAdDisplayTime = [inDisplayTime intValue];
    eBrwMainFrm.mAdDisplayTime = [inDisplayTime intValue];
    
    
    meBrwView.mAdIntervalTime = [inInterval intValue];
    eBrwMainFrm.mAdIntervalTime = [inInterval intValue];
    
    
    flag = [inFlag intValue];
    meBrwView.mAdFlag = flag;
    
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
        eBrwMainFrm.meAdBrwView = [[EBrowserView alloc] initWithFrame:ADFrame BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:@"" Type:F_EBRW_VIEW_TYPE_AD];
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
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OPAQUE) == F_EUEXWINDOW_OPEN_FLAG_OPAQUE) {
        eBrwMainFrm.meAdBrwView.backgroundColor = [UIColor whiteColor];
    }
    eBrwMainFrm.meAdBrwView.mFlag = 0;
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_DISABLE_CROSSDOMAIN) != 0) {
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
    NSString *keyStr = [meBrwView.mwWgt.appId stringByAppendingString:@"BD7463CD-D608-BEB4-C633-EF3574213060"];
    NSData *keyData = [keyStr dataUsingEncoding:NSUTF8StringEncoding];
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, [keyData bytes],[keyData length]);
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
        adURLQuery = [NSString stringWithFormat:@"?appid=%@&pt=%d&dw=%d&dh=%d&md5=%@&type=%d", meBrwView.mwWgt.appId,0,768,1024,md5Key,reportAdType];
    } else {
        adURLQuery = [NSString stringWithFormat:@"?appid=%@&pt=%d&dw=%d&dh=%d&md5=%@&type=%d", meBrwView.mwWgt.appId,0,320,460,md5Key,reportAdType];
    }
    adURL = [adURL stringByAppendingString:adURLQuery];
    ACENSLog(@"adURL is %@", adURL);
    //adURL.length != 0
    if (KUEXIS_NSString(adURL)) {
        //NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:adURL];
        NSURL *url = [BUtility stringToUrl:adURL];
        /*NSURL *curUrl = [eBrwWnd.meAdBrwView curUrl];
         if ([curUrl isEqual:url] == YES) {
         [eBrwWnd bringSubviewToFront:eBrwWnd.meAdBrwView];
         } else {
         [eBrwWnd.meAdBrwView loadWithUrl:url];
         }*/
        [eBrwMainFrm.meAdBrwView loadWithUrl:url];
    } else {
        [eBrwMainFrm bringSubviewToFront:eBrwMainFrm.meAdBrwView];
        eBrwMainFrm.meAdBrwView.hidden = NO;
    }
    if (eBrwMainFrm.mAdDisplayTime > 0) {
        eBrwMainFrm.mAdDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:eBrwMainFrm.mAdDisplayTime target:eBrwMainFrm selector:@selector(displayDone) userInfo:nil repeats:NO];
    }
}

- (void)closePopover:(NSMutableArray *)inArguments {
    NSString *inPopName = [inArguments objectAtIndex:0];
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    //inPopName.length == 0
    if (!KUEXIS_NSString(inPopName)) {
        return;
    }
    ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    if (ePopBrwView) {
        [eBrwWnd removeFromPopBrwViewDict:inPopName];
        //[ePopBrwView clean];
        if (ePopBrwView.superview) {
            [ePopBrwView removeFromSuperview];
        }
        //8.8 数据统计
        int type =ePopBrwView.mwWgt.wgtType;
        NSString *viewName =[ePopBrwView.curUrl absoluteString];
        NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
        [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
        
        [[meBrwView brwWidgetContainer] pushReuseBrwView:ePopBrwView];
        
    }
}

- (void)closeAD:(NSMutableArray *)inArguments {
    if (meBrwView.mType != F_EBRW_VIEW_TYPE_MAIN) {
        return;
    }
    EBrowserMainFrame *eBrwMainFrm = meBrwView.meBrwCtrler.meBrwMainFrm;
    if (eBrwMainFrm.meAdBrwView) {
        eBrwMainFrm.meAdBrwView.hidden = YES;
        meBrwView.mFlag &= ~F_EBRW_VIEW_FLAG_HAS_AD;
        [meBrwView.meBrwCtrler.meBrwMainFrm invalidateAdTimers];
    }
}

- (void)notifySetWindowFrameFinish {
    if (meBrwView) {
        [meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onSetWindowFrameFinish!=null){uexWindow.onSetWindowFrameFinish();}"];
    }
}

- (void)onSetWindowFrameFinish {
    [self performSelectorOnMainThread:@selector(notifySetWindowFrameFinish) withObject:nil waitUntilDone:NO];
}

- (void)setWindowFrame:(NSMutableArray *)inArguments {
    NSString *inX = [inArguments objectAtIndex:0];
    NSString *inY = [inArguments objectAtIndex:1];
    NSString *inSecond = [inArguments objectAtIndex:2];
    float x = [inX floatValue];
    float y = [inY floatValue];
    float second = [inSecond floatValue]/1000;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:second];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(onSetWindowFrameFinish)];
    [meBrwView.meBrwWnd setFrame:CGRectMake(x, y, meBrwView.meBrwWnd.frame.size.width, meBrwView.meBrwWnd.frame.size.height)];
    [UIView commitAnimations];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:second]];
}

- (void)setWindowHidden:(NSMutableArray *)inArguments {
    NSString *inHidden = [inArguments objectAtIndex:0];
    BOOL hidden = YES;
    if ([inHidden isEqualToString:@"0"]) {
        hidden = NO;
    }
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
        return;
    }
    
    if (meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypePresent) {
        return;
    }
    
    meBrwView.meBrwWnd.hidden = hidden;
    [EBrowserWindow postWindowSequenceChange];
}

- (void)setPopoverFrame:(NSMutableArray *)inArguments {
    NSString *inPopName = [inArguments objectAtIndex:0];
    NSString *inX = [inArguments objectAtIndex:1];
    NSString *inY = [inArguments objectAtIndex:2];
    NSString *inW = [inArguments objectAtIndex:3];
    NSString *inH = [inArguments objectAtIndex:4];
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    int x,y,w,h;
    int newX,newY,newW,newH;
    BOOL needTransform = NO;
    //inPopName.length == 0
    if (!KUEXIS_NSString(inPopName)) {
        return;
    }
    ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    if (!ePopBrwView) {
        return;
    }
    x = ePopBrwView.frame.origin.x;
    y = ePopBrwView.frame.origin.y;
    w = ePopBrwView.frame.size.width;
    h = ePopBrwView.frame.size.height;
    //inX.length != 0
    if (!KUEXIS_EMPTY(inX) ) {
        newX = [inX intValue];
        if (x != newX) {
            x = newX;
            needTransform = YES;
        }
    }
    //inY.length != 0
    if (!KUEXIS_EMPTY(inY)) {
        newY = [inY intValue];
        if (y != newY) {
            y = newY;
            needTransform = YES;
        }
    }
    //inH.length != 0
    if (!KUEXIS_EMPTY(inH)) {
        newH = [inH intValue];
        if (h != newH) {
            h = newH;
            needTransform = YES;
        }
    }
    //inW.length != 0
    if (!KUEXIS_EMPTY(inW)) {
        newW = [inW intValue];
        if (w != newW) {
            w = newW;
            needTransform = YES;
        }
    }
    if (needTransform == YES) {
        [ePopBrwView setFrame:CGRectMake(x, y, w, h)];
    }
    
    x = ePopBrwView.mBottomBounceView.frame.origin.x;
    y = ePopBrwView.mScrollView.contentSize.height;
    w = ePopBrwView.bounds.size.width;
    h = ePopBrwView.bounds.size.height;
    
    if (ePopBrwView.mBottomBounceView && h != 0) {
        ePopBrwView.mBottomBounceView.frame = CGRectMake(x, y, w, h);
    }
}

- (void)evaluatePopoverScript:(NSMutableArray *)inArguments {
    NSString *inWndName = [inArguments objectAtIndex:0];
    NSString *inPopName = [inArguments objectAtIndex:1];
    NSString *inScript = [inArguments objectAtIndex:2];
    EBrowserWindow *eBrwWnd = nil;
    EBrowserView *ePopBrwView = nil;
    //inPopName.length == 0 || inScript.length == 0
    if (!KUEXIS_NSString(inPopName) || !KUEXIS_NSString(inScript)) {
        return;
    }
    if (!meBrwView) {
        return;
    }
    if (!meBrwView.meBrwWnd) {
        return;
    }
    //inWndName.length == 0
    if (!KUEXIS_NSString(inWndName)) {
        eBrwWnd = meBrwView.meBrwWnd;
    }
    //	EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)(meBrwView.meBrwWnd.superview);
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    
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
    [ePopBrwView stringByEvaluatingJavaScriptFromString:inScript];
}

- (id)getUrlQuery:(NSMutableArray *)inArguments {
    NSURL *curUrl = [meBrwView curUrl];
    NSString *queryData = [curUrl query];
    if (queryData) {
        [self jsSuccessWithName:@"uexWindow.cbGetUrlQuery" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:queryData];
        return queryData;
    } else {
        [self jsSuccessWithName:@"uexWindow.cbGetUrlQuery" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@""];
        return @"";
    }
    
}

- (void)preOpenStart:(NSMutableArray *)inArguments {
    if (!meBrwView.meBrwWnd.mPreOpenArray) {
        meBrwView.meBrwWnd.mPreOpenArray = [[NSMutableArray alloc]initWithCapacity:2];
    }
    [meBrwView.meBrwWnd.mPreOpenArray removeAllObjects];
    meBrwView.meBrwWnd.mFlag &= ~F_EBRW_WND_FLAG_FINISH_PREOPEN;
}

- (void)preOpenFinish:(NSMutableArray *)inArguments {
    meBrwView.meBrwWnd.mFlag |= F_EBRW_WND_FLAG_FINISH_PREOPEN;
    if (meBrwView.meBrwWnd.mPreOpenArray.count == 0) {
        [meBrwView.meBrwCtrler.meBrw notifyLoadPageFinishOfBrwView:meBrwView];
    }
}

- (void)beginAnimition:(NSMutableArray *)inArguments {
    ACENSLog(@"%f,%f,%f,%f",meBrwView.frame.origin.x,meBrwView.frame.origin.y,meBrwView.frame.size.width,meBrwView.frame.size.height);
    if (!meBrwAnimi) {
        meBrwAnimi = [[EBrowserViewAnimition alloc]init];
    } else {
        [meBrwAnimi clean];
    }
}

- (void)setAnimitionDelay:(NSMutableArray *)inArguments {
    NSString *inDelay = [inArguments objectAtIndex:0];
    meBrwAnimi.mDelay = [inDelay floatValue]/1000.0f;
}

- (void)setAnimitionDuration:(NSMutableArray *)inArguments {
    NSString *inDuration = [inArguments objectAtIndex:0];
    meBrwAnimi.mDuration = [inDuration floatValue]/1000.0f;
}

- (void)setAnimitionCurve:(NSMutableArray *)inArguments {
    NSString *inCurve = [inArguments objectAtIndex:0];
    meBrwAnimi.mCurve = [inCurve intValue];
}

- (void)setAnimitionRepeatCount:(NSMutableArray *)inArguments {
    NSString *inRepeatCount = [inArguments objectAtIndex:0];
    meBrwAnimi.mRepeatCount = [inRepeatCount floatValue];
}

- (void)setAnimitionAutoReverse:(NSMutableArray *)inArguments {
    NSString *inAutoReverse = [inArguments objectAtIndex:0];
    int autoReverse = [inAutoReverse intValue];
    if (autoReverse == 0) {
        meBrwAnimi.mAutoReverse = NO;
    } else {
        meBrwAnimi.mAutoReverse = YES;
    }
}

- (void)makeAlpha:(NSMutableArray *)inArguments {
    NSString *alphaStr = [inArguments objectAtIndex:0];
    float alpha = [alphaStr floatValue];
    meBrwAnimi.mAlpha = alpha;
}

- (void)makeTranslation:(NSMutableArray *)inArguments {
    float inX = [[inArguments objectAtIndex:0] floatValue];
    float inY = [[inArguments objectAtIndex:1] floatValue];
    float inZ = [[inArguments objectAtIndex:2] floatValue];
    BAnimationTransform *transfrom = [[BAnimationTransform alloc]init];
    transfrom.mTransForm3D = CATransform3DMakeTranslation(inX,inY,inZ);
    [meBrwAnimi.mTransformArray addObject:transfrom];
    
}

- (void)makeScale:(NSMutableArray *)inArguments {
    float inX = [[inArguments objectAtIndex:0] floatValue];
    float inY = [[inArguments objectAtIndex:1] floatValue];
    float inZ = [[inArguments objectAtIndex:2] floatValue];
    BAnimationTransform *transfrom = [[BAnimationTransform alloc]init];
    transfrom.mTransForm3D = CATransform3DMakeScale(inX,inY,inZ);
    [meBrwAnimi.mTransformArray addObject:transfrom];
    
}

- (void)makeRotate:(NSMutableArray *)inArguments {
    float inAngle = [[inArguments objectAtIndex:0] floatValue];
    float inX = [[inArguments objectAtIndex:1] floatValue];
    float inY = [[inArguments objectAtIndex:2] floatValue];
    float inZ = [[inArguments objectAtIndex:3] floatValue];
    BAnimationTransform *transfrom = [[BAnimationTransform alloc]init];
    inAngle = (inAngle/180.0f) * M_PI;
    transfrom.mTransForm3D = CATransform3DMakeRotation(inAngle, inX, inY, inZ);
    [meBrwAnimi.mTransformArray addObject:transfrom];
    
}

- (void)commitAnimition:(NSMutableArray *)inArguments {
    if (!meBrwAnimi) {
        return;
    }
    [meBrwAnimi doAnimition:meBrwView];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kWindowConfirmViewTag) {
        
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
            
            exit(0);
        }
        
    } else {
        
        switch (mbAlertView.mType) {
            case F_BUIALERTVIEW_TYPE_ALERT:
                break;
            case F_BUIALERTVIEW_TYPE_CONFIRM:
                [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
                [self jsSuccessWithName:F_CB_WINDOW_CONFIRM opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:buttonIndex];
                break;
            case F_BUIALERTVIEW_TYPE_PROMPT: {
                [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
                NSString *text = nil;
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
                {
                    UITextField * temp = [mbAlertView.mAlertView textFieldAtIndex:0];
                    text = [temp text];
                }else
                {
                    text = [mbAlertView.mTextField text];
                    if (!text) {
                        text = @"null";
                    }
                }
                NSMutableDictionary *retDict = [[NSMutableDictionary alloc]initWithCapacity:5];
                [retDict setObject:[NSNumber numberWithInteger:buttonIndex] forKey:@"num"];
                [retDict setObject:text forKey:@"value"];
                [self jsSuccessWithName:F_CB_WINDOW_PROMPT opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:[retDict JSONFragment]];
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    [self performSelector:@selector(actionsheetClick:) withObject:[NSNumber numberWithInteger:buttonIndex] afterDelay:0.2];
    
}
-(void)actionsheetClick:(id)sender{
    [self jsSuccessWithName:F_CB_WINDOW_ACTION_SHEET opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:[sender intValue]];
}

- (void)clean {
    
    
    //[self removeNotificationCenter];
    [self closeToast:NULL];
    [self closeAlert];
}
#pragma mark
#pragma mark 新增接口
#pragma mark
-(void)insertWindowAboveWindow:(NSArray*)inArgument
{
    if ([inArgument count]==2)
    {
        NSString * inNameA = [inArgument objectAtIndex:0];
        NSString * inNameB = [inArgument objectAtIndex:1];
        
        EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
        
        if (eCurBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
            return;
        }
        
        if (eCurBrwWnd.webWindowType == ACEWebWindowTypePresent) {
            return;
        }
        
        EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eCurBrwWnd.superview;
        EBrowserWindow * windowA = [eBrwWndContainer brwWndForKey:inNameA];
        EBrowserWindow * windowB = [eBrwWndContainer brwWndForKey:inNameB];
        
        [eBrwWndContainer insertSubview:windowA aboveSubview:windowB];
    }
    [EBrowserWindow postWindowSequenceChange];
}
-(void)insertWindowBelowWindow:(NSArray*)inArgument
{
    if ([inArgument count]==2)
    {
        NSString * inNameA = [inArgument objectAtIndex:0];
        NSString * inNameB = [inArgument objectAtIndex:1];
        EBrowserWindow *eCurBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
        
        if (eCurBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
            return;
        }
        
        if (eCurBrwWnd.webWindowType == ACEWebWindowTypePresent) {
            return;
        }
        
        EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eCurBrwWnd.superview;
        EBrowserWindow * windowA = [eBrwWndContainer brwWndForKey:inNameA];
        EBrowserWindow * windowB = [eBrwWndContainer brwWndForKey:inNameB];
        
        [eBrwWndContainer insertSubview:windowA belowSubview:windowB];
    }
    [EBrowserWindow postWindowSequenceChange];
}

#pragma mark - setAutorotateEnable

- (void)setAutorotateEnable:(NSMutableArray *)inArguments {
    
    if ([inArguments count] < 1) {
        return;
    }
    
    NSString * orientaion = [BUtility getMainWidgetConfigInterface];
    
    [[NSUserDefaults standardUserDefaults] setObject:orientaion forKey:@"subwgtOrientaion"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
    
    BOOL isAutorotate = ![[inArguments objectAtIndex:0] boolValue];
    
    theApp.drawerController.canAutorotate = isAutorotate;
    
}



#pragma mark 转屏接口
#pragma mark
-(void)setOrientation:(NSArray *)inArgument
{
    if ([inArgument count]>0)
    {
        NSString * orientaion = [inArgument objectAtIndex:0];
        int orNumb = [orientaion intValue];
        
        theApp.drawerController.canRotate = YES;
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",orNumb] forKey:@"subwgtOrientaion"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTheOrientation" object:nil];
        switch (orNumb)
        {
                
            case 1:
                //[BUtility rotateToOrientation:UIInterfaceOrientationPortrait];
                [BUtility rotateToOrientation:UIInterfaceOrientationPortrait];
                
                break;
            case 2:
                [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeRight];
                
                
                break;
                
            case 4:
                [BUtility rotateToOrientation:UIInterfaceOrientationPortraitUpsideDown];
                
                break;
                
            case 8:
                [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
                
                break;
                
            case 10:
                [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
                
                break;
                
            case 5:
                [BUtility rotateToOrientation:UIInterfaceOrientationPortrait];
                
                break;
                
            case 3:
                [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
                
                break;
                
            case 9:
                [BUtility rotateToOrientation:UIInterfaceOrientationLandscapeRight];
                
                break;
                
                
            default:
                return;
                break;
        }
        
        
        theApp.drawerController.canRotate = NO;
        
    }
}
#pragma mark - loading image
-(void)setLoadingImagePath:(NSArray *)inArgument {
    ACE_ArgsUnpack(NSDictionary *info) = inArgument;
    if (!info || !info[@"loadingImagePath"] || !info[@"loadingImageTime"]) {
        return;
    }
    NSString *imagePath = info[@"loadingImagePath"];
    NSInteger AppCanLaunchTime = [info[@"loadingImageTime"] integerValue];
    if (!imagePath || ![imagePath isKindOfClass:[NSString class]]) {
        return;
    }
    if (imagePath.length == 0) {
        //取消自定义启动图
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kACECustomLoadingImagePathKey];
        return;
    }
    if (AppCanLaunchTime <= 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setValue:imagePath forKey:kACECustomLoadingImagePathKey];
    [[NSUserDefaults standardUserDefaults] setValue:@(AppCanLaunchTime) forKey:kACECustomLoadingImageTimeKey];
    
}

#pragma mark - Progress Dialog
- (void)createProgressDialog:(NSMutableArray *)inArguments{
    if(inArguments.count < 2){
        return;
    }
    BOOL canCancel=YES;
    if(inArguments.count > 2){
        canCancel=!([inArguments[2] integerValue] == 1);
    }
    NSString *title=inArguments[0];
    NSString *text=inArguments[1];
    [[ACEProgressDialog sharedDialog]showWithTitle:title text:text canCancel:canCancel];
}


- (void)destroyProgressDialog:(NSMutableArray *)inArguments{
    [[ACEProgressDialog sharedDialog]hide];
}

#pragma mark 设置状态条上字体的颜色
#pragma mark
-(void)setStatusBarTitleColor:(NSArray *)inArgument
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        if ([inArgument count]>0)
        {
            int arg = [[inArgument objectAtIndex:0]intValue];
            if (arg==0)
            {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            }
            if (arg==1)
            {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
        }
    }
}
#pragma mark - StatusBar

- (void)hideStatusBar:(NSArray *)inArgument {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        theApp.drawerController.isStatusBarHidden = YES;
    
        if (![[[[NSBundle mainBundle]infoDictionary] objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue]) {
            
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
            
        } else {
            
            [theApp.drawerController setNeedsStatusBarAppearanceUpdate];
            
        }
    
    }
    
}

- (void)showStatusBar:(NSArray *)inArgument {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        
        theApp.drawerController.isStatusBarHidden = NO;
        
        if (![[[[NSBundle mainBundle]infoDictionary] objectForKey:@"UIViewControllerBasedStatusBarAppearance"] boolValue]) {
            
            [[UIApplication sharedApplication]setStatusBarHidden:NO];
            
        } else {
            
            [theApp.drawerController setNeedsStatusBarAppearanceUpdate];
            
        }
        
    }
    
}

#pragma mark
#pragma mark
- (void)openMultiPopover:(NSMutableArray *)inArguments
{
    //NSString * inContent = [inArguments objectAtIndex:0];
    //'{"content":[{"inPageName":"p1", "inUrl":"xx.html","inData":""},{"inPageName":"p2", "inUrl":"xx.html","inData":""},{"inPageName":"p3", "inUrl":"xx.html","inData":""},{"inPageName":"p4", "inUrl":"xx.html","inData":""},{"inPageName":"p5", "inUrl":"xx.html","inData":""},{"inPageName":"p6", "inUrl":"xx.html","inData":""},]}';
    ACE_ArgsUnpack(NSDictionary *inContent,NSString *inMainPopName,NSString *inDataType,NSNumber *inX,NSNumber *inY,NSNumber *inW,NSNumber *inH,NSNumber *inFontSize,NSString *inFlag,NSNumber *popIndex,NSDictionary *extraInfo) = inArguments;

    NSArray * pageN = [inContent objectForKey:@"content"];
    /*
    NSString * inMainPopName = [inArguments objectAtIndex:1];
    NSString * inDataType = [inArguments objectAtIndex:2];
    NSString * inX = [inArguments objectAtIndex:3];
    NSString * inY = [inArguments objectAtIndex:4];
    NSString * inW = [inArguments objectAtIndex:5];
    NSString * inH = [inArguments objectAtIndex:6];
    NSString * inFontSize = [inArguments objectAtIndex:7];;
    NSString * inFlag = [inArguments objectAtIndex:8];
    NSString * popIndex = [inArguments objectAtIndex:9];
    NSString * extraInfoAll = @"";

    if ([inArguments count] >= 11) {
        extraInfoAll = [inArguments objectAtIndex:10];
    }
     */
    int pageth = 0;
    if (popIndex) {
        pageth = [popIndex intValue];
    }
    
    int x = 0,
    y = 0,
    w = meBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.width,
    h = meBrwView.meBrwCtrler.meBrwMainFrm.bounds.size.height,
    fontSize = 0,
    flag = 0;
    if (!meBrwView) {
        return;
    }
    
    x = inX ? [inX intValue] : x;
    y = inY ? [inY intValue] : y;
    w = inW ? [inW intValue] : w;
    h = inH ? [inH intValue] : h;

    fontSize = inFontSize ? [inFontSize intValue] : 0;
    
    
    flag = [inFlag intValue];
    
    if (w == 0 || h == 0) {
        return;
    }
    
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    //    EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)eBrwWnd.superview;
    
    
    EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
    
    
    NSInteger multNum = [pageN count];
    // define the scroll view content size and enable paging
    EScrollView * multiPopover = [[EScrollView alloc]initWithFrame:CGRectMake(x,y,w,h)];
    multiPopover.userInteractionEnabled = YES;
    ACEMultiPopoverScrollView * scrollView = [[ACEMultiPopoverScrollView alloc]initWithFrame:CGRectMake(0, 0, w, h)];
    [scrollView setPagingEnabled: YES] ;
    [scrollView setContentSize: CGSizeMake(scrollView.bounds.size.width * multNum, scrollView.bounds.size.height)] ;
    scrollView.delegate=self;
    scrollView.backgroundColor=[UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.tag=100000;
    if (!eBrwWnd.mMuiltPopoverDict) {
        NSMutableDictionary * popDic = [[NSMutableDictionary alloc]initWithCapacity:1];
        eBrwWnd.mMuiltPopoverDict = popDic;
        
    }
    [eBrwWnd.mMuiltPopoverDict setObject:multiPopover forKey:inMainPopName];
    multiPopover.scrollView = scrollView;
    multiPopover.mainPopName = inMainPopName;
    [multiPopover addSubview:scrollView];
    [eBrwWnd addSubview:multiPopover];
    
    //[extraInfoAll length] > 0
    if (extraInfo) {
        //NSDictionary * extraAllDic = [extraInfoAll JSONValue];
        NSDictionary * extraDic = [extraInfo objectForKey:@"extraInfo"];
        [self setExtraInfo:extraDic toEBrowserView:multiPopover];
    }
    
    //打开多个pop窗口
    for (int i=0; i<multNum;i++)
    {
        x=i*w;
        y=0;
        NSDictionary * pageInfo = [pageN objectAtIndex:i];
        NSString *inPopName = [pageInfo objectForKey:@"inPageName"];
        NSString *inUrl = [pageInfo objectForKey:@"inUrl"];
        NSString *inData = [pageInfo objectForKey:@"inData"];
        NSDictionary *extraDic = [pageInfo objectForKey:@"extraInfo"];
        
        NSURL *baseUrl = [meBrwView curUrl];
        //inPopName.length == 0
        if (!KUEXIS_NSString(inPopName)) {
            return;
        }
        //if (meBrwView.mType == F_EBRW_VIEW_TYPE_POPOVER) {
        //    return;
        //}
        int bottom=0;
        @unsafeify(scrollView);
        [scrollView addLoadingBlock:^{
            @strongify(scrollView);
            [self openMuilPopwith:eBrwWnd and:ePopBrwView and:eBrwWndContainer and:inPopName and:inDataType and:inUrl and:inData and:baseUrl and:x and:y and:w and:h and:fontSize and:flag and:bottom and:scrollView andIsMuiltPop:YES andExtraInfo:extraDic];
        }];
        
    }
    
    
    [scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * pageth, scrollView.contentOffset.y) animated: NO] ;
    [scrollView startLoadingPopViewAtIndex:pageth];
}

#pragma mark
#pragma mark 设置窗口是否显示bar
#pragma mark
-(void)setWindowScrollbarVisible:(NSArray *)inArgument
{
    if ([inArgument count]>0 && [BUtility getSystemVersion]>=5.0)
    {
        id isShowBar = [inArgument objectAtIndex:0];
        if ([isShowBar isEqual:@"false"] || ![isShowBar boolValue])
        {
            meBrwView.scrollView.showsVerticalScrollIndicator = NO;
            meBrwView.scrollView.showsHorizontalScrollIndicator = NO;
            
        } else
        {
            meBrwView.scrollView.showsVerticalScrollIndicator = YES;
            meBrwView.scrollView.showsHorizontalScrollIndicator = YES;
        }
    }
}

-(void)openMuilPopwith:(EBrowserWindow *)eBrwWnd and:(EBrowserView *)ePopBrwView and:(EBrowserWindowContainer *)eBrwWndContainer and:(NSString*)inPopName and:(NSString *)inDataType and:(NSString*)inUrl and:(NSString*)inData and:(NSURL*)baseUrl and:(int)x and:(int)y and:(int)w and:(int)h and:(int)fontSize and:(int)flag and:(int)bottom and:(UIScrollView *)scrollView andIsMuiltPop:(BOOL)isMuitPop andExtraInfo:(NSDictionary *)extraDic
{
    int dataType = 0;
    BOOL isExist = NO;
    ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
    NSString *windowName = eBrwWnd.meBrwView.muexObjName;
    NSString *winAndPopName = [NSString stringWithFormat:@"%@:%@",windowName,inPopName];
    if (!isMuitPop)
    {//window 4.12
        NSArray *forbidWindow = meBrwView.meBrwCtrler.forebidPopWinsList;
        if (forbidWindow && [forbidWindow count]>0)
        {
            for (NSString *fWindowName in forbidWindow)
            {
                ACENSLog(@"fwindowName=%@,winAndPopName=%@",fWindowName,winAndPopName);
                if ([fWindowName isEqualToString:winAndPopName])
                {
                    NSString *forbidStr = [NSString stringWithFormat:@"if(uexWidgetOne.cbError!=null){uexWidgetOne.cbError(%d,%d,\'%@\');}",0,10,fWindowName];
                    [meBrwView stringByEvaluatingJavaScriptFromString:forbidStr];
                    //[self alertForbidView:fWindowName];
                    return;
                }
            }
        }
    }
    
    
    if (!ePopBrwView)
    {
        ePopBrwView = [[meBrwView brwWidgetContainer] popReuseBrwView];
        
        if (ePopBrwView != nil && meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypeNavigation) {
            
            
            ePopBrwView = nil;
        }
        
        if (ePopBrwView != nil && meBrwView.meBrwWnd.webWindowType == ACEWebWindowTypePresent) {
            
            
            ePopBrwView = nil;
        }
        
        if (ePopBrwView)
        {
            
            [ePopBrwView reuseWithFrame:CGRectMake(x, y, w, h) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:inPopName Type:F_EBRW_VIEW_TYPE_POPOVER];
            
            if (isMuitPop) {
                ePopBrwView.isMuiltPopover=YES;
            } else {
                ePopBrwView.isMuiltPopover = NO;
            }
            
            ACENSLog(@"NavWindowTest openPopover reuse new ePopBrwView = %@, ePopBrwView Name = %@", ePopBrwView, ePopBrwView.muexObjName);
        }else
        {
            ePopBrwView = [[EBrowserView alloc] initWithFrame:CGRectMake(x, y, w, h) BrwCtrler:meBrwView.meBrwCtrler Wgt:meBrwView.mwWgt BrwWnd:eBrwWnd UExObjName:inPopName Type:F_EBRW_VIEW_TYPE_POPOVER];
            
            ACENSLog(@"NavWindowTest openPopover new ePopBrwView = %@, ePopBrwView Name = %@", ePopBrwView, ePopBrwView.muexObjName);
            
            if (isMuitPop) {
                ePopBrwView.isMuiltPopover=YES;
            } else {
                ePopBrwView.isMuiltPopover = NO;
            }
            
            
        }
        if (fontSize != 0)
        {
            [ePopBrwView.mPageInfoDict setObject:[NSNumber numberWithInt:fontSize] forKey:@"pFontSize"];
        }
        [eBrwWnd.mPopoverBrwViewDict setObject:ePopBrwView forKey:inPopName];
        [eBrwWnd.mPreOpenArray addObject:inPopName];
    } else
    {
        isExist = YES;
        ePopBrwView.frame = CGRectMake(x, y, w, h);
        if (isMuitPop) {
            ePopBrwView.isMuiltPopover=YES;
        } else {
            ePopBrwView.isMuiltPopover = NO;
        }
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OPAQUE) == F_EUEXWINDOW_OPEN_FLAG_OPAQUE)
    {
        ePopBrwView.backgroundColor = [UIColor whiteColor];
    }
    
    [self setExtraInfo:extraDic toEBrowserView:ePopBrwView];
    
    if ((flag & F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE) == F_EUExWINDOW_OPEN_FLAG_ENABLE_SCALE)
    {
        [ePopBrwView setScalesPageToFit:YES];
        [ePopBrwView setMultipleTouchEnabled:YES];
    }
    ePopBrwView.mFlag = 0;
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_DISABLE_CROSSDOMAIN) != 0)
    {
        ePopBrwView.mFlag |= F_EBRW_VIEW_FLAG_FORBID_CROSSDOMAIN;
    }
    if ((flag & F_EUEXWINDOW_OPEN_FLAG_OAUTH) == F_EUEXWINDOW_OPEN_FLAG_OAUTH)
    {
        ePopBrwView.mFlag |= F_EBRW_VIEW_FLAG_OAUTH;
    }
    //inDataType.length != 0
    
    dataType = [inDataType intValue];
    switch (dataType)
    {
        case F_EUEXWINDOW_SRC_TYPE_URL:
            //inUrl.length != 0
            if (KUEXIS_NSString(inUrl))
            {
                NSString *urlStr = nil;
                if ([inData hasPrefix:F_WGTROOT_PATH])
                {
                    NSString * urlsub = [inUrl substringFromIndex:10];
                    NSString * finaUrl = [NSString stringWithFormat:@"/%@",urlsub];
                    urlStr = [meBrwView.mwWgt.widgetPath stringByAppendingString:finaUrl];
                    
                    if (![urlStr hasPrefix:@"file://"]) {
                        urlStr =[NSString stringWithFormat:@"file://%@", urlStr];
                    }
                }else
                {
                    urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                }
                //					NSString *urlStr = [BUtility makeUrl:[baseUrl absoluteString] url:inUrl];
                NSURL *url = [BUtility stringToUrl:urlStr];
                if (eBrwWndContainer.mwWgt.obfuscation == F_WWIDGET_OBFUSCATION && ![urlStr hasPrefix:F_HTTP_PATH]&&![urlStr hasPrefix:F_HTTPS_PATH]) {
                    //                        if ((flag & F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) == F_EUEXWINDOW_OPEN_FLAG_OBFUSCATION) {
                    FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
                    NSString *data = [encryptObj decryptWithPath:url appendData:nil];
                    ACENSLog(@"data: %@", data);
                    
                    [ePopBrwView loadWithData:data baseUrl:url];
                    //                        } else {
                    //                            [ePopBrwView loadWithUrl:url];
                    //                        }
                } else {
                    [ePopBrwView loadWithUrl:url];
                }
                //8.8 数据统计
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
                        {
                            NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:eBrwWnd.meBrwView.mwWgt];
                            [BUtility setAppCanViewActive:goType opener:fromViewName name:goViewName openReason:0 mainWin:1 appInfo:appInfo];
                        }
                        isExist =NO;
                    }
                }else {
                    //int type =eBrwWnd.meBrwView.mwWgt.wgtType;
                    NSString *viewName =[eBrwWnd.meBrwView.curUrl absoluteString];
                    int goType = ePopBrwView.mwWgt.wgtType;
                    NSString *goViewName =[url absoluteString];
                    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
                    [BUtility setAppCanViewActive:goType opener:viewName name:goViewName openReason:0 mainWin:1 appInfo:appInfo];
                }
            }
            else
            {
                [eBrwWnd bringSubviewToFront:ePopBrwView];
            }
            break;
            
        default:
            break;
    }
    
    //[eBrwWnd bringSubviewToFront:ePopBrwView];
    
    
    if (bottom>0)
    {
        ePopBrwView.bottom = bottom;//footer的高度
        
        [ePopBrwView registerKeyboardChangeEvent];
        
    }
    
    if (isMuitPop)
    {
        [scrollView addSubview:ePopBrwView];
    }else{
        [eBrwWnd addSubview:ePopBrwView];
        //ePopBrwView.backgroundColor = [UIColor redColor];
    }
}

- (void)closeMultiPopover:(NSMutableArray *)inArguments
{
    NSString *inMainPopName = [inArguments objectAtIndex:0];
    EBrowserView *ePopBrwView = nil;
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    if (eBrwWnd.mMuiltPopoverDict) {
        EScrollView * multiPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:inMainPopName];
        UIScrollView * scrolView = multiPopover.scrollView;
        NSArray * popviewAry = [scrolView subviews];
        for (EBrowserView * popVews in popviewAry)
        {
            NSString * inPopName = nil;
            if ([popVews respondsToSelector:@selector(muexObjName)])
            {
                inPopName = [popVews muexObjName];
            }else {inPopName = nil;}
            //inPopName.length != 0
            if (KUEXIS_NSString(inPopName))
            {
                ePopBrwView = [eBrwWnd popBrwViewForKey:inPopName];
                if (ePopBrwView)
                {
                    [eBrwWnd removeFromPopBrwViewDict:inPopName];
                    //[ePopBrwView clean];
                    if (ePopBrwView.superview)
                    {
                        [ePopBrwView removeFromSuperview];
                    }
                    //8.8 数据统计
                    int type =ePopBrwView.mwWgt.wgtType;
                    NSString *viewName =[ePopBrwView.curUrl absoluteString];
                    NSDictionary *appInfo = [DataAnalysisInfo getAppInfoWithCurWgt:ePopBrwView.mwWgt];
                    [BUtility setAppCanViewBackground:type name:viewName closeReason:0 appInfo:appInfo];
                    
                    [[meBrwView brwWidgetContainer] pushReuseBrwView:ePopBrwView];
                    
                }
            }
        }
        
        if (eBrwWnd.mMuiltPopoverDict)
        {
            NSArray * mulitPopArray = [eBrwWnd.mMuiltPopoverDict allValues];
            for (EScrollView * mutilPopover in mulitPopArray)
            {
                if (mutilPopover.subviews) {
                    [mutilPopover removeFromSuperview];
                }
            }
            [eBrwWnd.mMuiltPopoverDict removeAllObjects];
            //            [eBrwWnd.mMuiltPopoverDict release];
            eBrwWnd.mMuiltPopoverDict = nil;
        }
    }
}
-(void)setSelectedPopOverInMultiWindow:(NSArray *)inArgument
{
    NSString * popName = [inArgument objectAtIndex:0];
    NSString * popIndex = [inArgument objectAtIndex:1];
    int pageth = [popIndex intValue];
    EBrowserWindow *eBrwWnd = (EBrowserWindow*)meBrwView.meBrwWnd;
    EScrollView * multiPopover = [eBrwWnd.mMuiltPopoverDict objectForKey:popName];
    UIScrollView * scrollView = multiPopover.scrollView;
    // we need to scroll to the new index
    [scrollView setContentOffset: CGPointMake(scrollView.bounds.size.width * pageth, scrollView.contentOffset.y) animated: NO] ;
}

-(void)subscribeChannelNotification:(NSArray *)inArgument
{
    if ([inArgument count] < 2) {
        return;
    }
    
    NSString * channelId = [inArgument objectAtIndex:0];
    NSString * function = [inArgument objectAtIndex:1];
    
    if ([function isKindOfClass:[NSString class]] && [function length] > 0)
    {
        [self.notificationDic setObject:function forKey:channelId];
    }
    
}

-(void)publishChannelNotification:(NSArray *)inArgument
{
    if ([inArgument count] < 2) {
        return;
    }
    
    NSString * channelId = [inArgument objectAtIndex:0];
    NSString * inContent = [inArgument objectAtIndex:1];
    
    NSDictionary * dic = [[NSDictionary alloc]initWithObjectsAndKeys:channelId,@"channelId",inContent,@"inContent", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SubscribeChannelNotification"
                                                        object:self userInfo:dic];
    
}

-(void)respondChannelNotification:(NSNotification*)sender
{
    
    NSDictionary * infoDic = (NSDictionary *)sender.userInfo;
    
    NSString * channelId = [infoDic objectForKey:@"channelId"];
    NSString * inContent = [infoDic objectForKey:@"inContent"];
    
    NSString * function = [self.notificationDic objectForKey:channelId];
    
    if (!function) {
        return;
    }
    
    NSString * cbString = [NSString stringWithFormat:@"if(uexWindow.%@!=null){uexWindow.%@(\'%@\');}",function,function,inContent];
    
    [meBrwView stringByEvaluatingJavaScriptFromString:cbString];
    
}

-(void)publishChannelNotificationForJson:(NSArray *)inArgument
{
    if ([inArgument count] < 2) {
        return;
    }
    
    NSString * channelId = [inArgument objectAtIndex:0];
    
    NSString * inContent = [inArgument objectAtIndex:1];
    
    NSDictionary * dic = [[NSDictionary alloc]initWithObjectsAndKeys:channelId,@"channelId",inContent,@"inContent", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SubscribeChannelNotificationForJson"
                                                        object:self userInfo:dic];
    
}

-(void)respondChannelNotificationForJson:(NSNotification*)sender
{
    
    NSDictionary * infoDic = (NSDictionary *)sender.userInfo;
    
    NSString * channelId = [infoDic objectForKey:@"channelId"];
    NSString * inContent = [infoDic objectForKey:@"inContent"];
    
    NSString * function = [self.notificationDic objectForKey:channelId];
    
    if (!function) {
        return;
    }
    
    NSString * cbString = [NSString stringWithFormat:@"if(uexWindow.%@!=null){uexWindow.%@(%@);}",function,function,inContent];
    
    [meBrwView stringByEvaluatingJavaScriptFromString:cbString];
    
}

-(void)postGlobalNotification:(NSArray *)inArgument
{
    if ([inArgument count] < 1) {
        return;
    }
    
    NSString * inContent = [inArgument objectAtIndex:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GlobalNotification" object:inContent];
    
}

-(void)respondGlobalNotification:(NSString*)data
{
    
    NSString * cbString = [NSString stringWithFormat:@"if(uexWindow.onGlobalNotification!=null){uexWindow.onGlobalNotification(\'%@\');}",data];
    
    [meBrwView stringByEvaluatingJavaScriptFromString:cbString];
    
}

//*****

#pragma mark UIScrollView delegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
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
    [self jsSuccessWithName:@"uexWindow.cbOpenMultiPopover" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:info];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
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
    
    [self jsSuccessWithName:@"uexWindow.cbOpenMultiPopover" opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:info];
}

-(void)setMultilPopoverFlippingEnbaled:(NSMutableArray *)inArgument{
    if ([inArgument count] < 1) {
        return;
    }

    BOOL multiPopoverFlippingEnbaled = ![[inArgument objectAtIndex:0] boolValue];
    if(meBrwView.meBrwWnd.mMuiltPopoverDict){
        for (EScrollView *eScrollV in meBrwView.meBrwWnd.mMuiltPopoverDict.allValues) {
            if (![eScrollV isKindOfClass:[EScrollView class]]) {
                continue;
            }
            UIScrollView *scrollView = eScrollV.scrollView;
            scrollView.scrollEnabled = multiPopoverFlippingEnbaled;
            /*
            NSArray * popviewAry = [scrollView subviews];
            for (UIView * popVews in popviewAry){
                if([popVews isKindOfClass:[EBrowserView class]]){
                    EBrowserView *popView =(EBrowserView *)popVews;
                    ACEBrowserView *ACEBrwView=popView.meBrowserView;
                    UIScrollView *scrollView = (UIScrollView *)[[ACEBrwView subviews] objectAtIndex:0];
                    scrollView.bounces = multiPopoverFlippingEnbaled;
                    
                }
                
            }
            */
        }
    };
}

- (void)createPluginViewContainer:(NSMutableArray *)inArguments {
    
    if ([inArguments count] < 1) {
        return;
    }
    
    NSError * error = nil;
    
    NSString * jsonStr = [inArguments objectAtIndex:0];
    
    NSData * jsonData = [jsonStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonDic == nil || error != nil){
        
        return;
        
    }
    
    float x = [[jsonDic objectForKey:@"x"] floatValue];
    float y = [[jsonDic objectForKey:@"y"] floatValue];
    float w = [[jsonDic objectForKey:@"w"] floatValue];
    float h = [[jsonDic objectForKey:@"h"] floatValue];
    float opId = [[jsonDic objectForKey:@"id"] floatValue];
    NSString * identifier = [jsonDic objectForKey:@"id"];
    
    ACEPluginViewContainer * pluginViewContainer = [[ACEPluginViewContainer alloc]initWithFrame:CGRectMake(x, y, w, h)];
    
    pluginViewContainer.containerIdentifier = identifier;
    
    pluginViewContainer.uexObj = self;
    
    [EUtility brwView:meBrwView addSubview:pluginViewContainer];
    
    [self jsSuccessWithName:@"uexWindow.cbCreatePluginViewContainer" opId:opId dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@"success"];
}

- (void)closePluginViewContainer:(NSMutableArray *)inArguments {
    
    NSString * jsonStr = [inArguments objectAtIndex:0];
    NSDictionary * jsonDic = [jsonStr JSONValue];
    
    NSString * identifier = [jsonDic objectForKey:@"id"];
    
    for (UIView * subView in [meBrwView.meBrwWnd subviews]) {
        
        if ([subView isKindOfClass:[ACEPluginViewContainer class]]) {
            
            ACEPluginViewContainer * container = (ACEPluginViewContainer *)subView;
            
            if ([container.containerIdentifier isEqualToString:identifier]) {
                NSLog(@"关闭id为%@的容器",identifier);
                [container removeFromSuperview];
            }
        }
    }
    [self jsSuccessWithName:@"uexWindow.cbClosePluginViewContainer" opId:[identifier floatValue] dataType:UEX_CALLBACK_DATATYPE_TEXT strData:@"success"];
    
}

- (void)setPageInContainer:(NSMutableArray *)inArguments {
    
    NSString * jsonStr = [inArguments objectAtIndex:0];
    NSDictionary * jsonDic = [jsonStr JSONValue];
    
    NSString * identifier = [jsonDic objectForKey:@"id"];
    NSInteger index = [[jsonDic objectForKey:@"index"] integerValue];
    
    
    for (UIView * subView in [meBrwView.meBrwWnd subviews]) {
        
        if ([subView isKindOfClass:[ACEPluginViewContainer class]]) {
            
            ACEPluginViewContainer * container = (ACEPluginViewContainer *)subView;
            
            if ([container.containerIdentifier isEqualToString:identifier]) {
                
                [container setContentOffset: CGPointMake(container.bounds.size.width * index, container.contentOffset.y) animated: YES];
                
            }
        }
    }
    
    
    
}

//2015-10-21 by lkl 解决iOS9上长按出现放大镜的问题
-(void)disturbLongPressGesture:(NSMutableArray *)inArguments{
    if(0==[inArguments count]||!iOS9){
        return;
    }
    
    if(![@[@0,@1,@2] containsObject:@([inArguments[0] integerValue])]){
        return;
    }
    ACEDisturbLongPressGestureStatus status =(ACEDisturbLongPressGestureStatus)[inArguments[0] integerValue];
    NSArray *views =[self.meBrwView.meBrowserView subviews];
    if([views count]==0){
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
-(void)disturbLongPressGestureHandler:(UILongPressGestureRecognizer*)sender{
    if([sender isEqual:self.longPressGestureDisturbRecognizer]){
        if(sender.state==UIGestureRecognizerStateBegan){
            //NSLog(@"disturbLongPressGesture");
        }
    }
}


-(void)setSwipeCloseEnable:(NSMutableArray *)inArguments{
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
    meBrwView.meBrwWnd.enableSwipeClose=canSwipeClose;
    [meBrwView.meBrwWnd updateSwipeCloseEnableStatus];
}




- (id)log:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return @0;
    }
    NSLog(@"%@",inArguments[0]);
    return @1;
}


- (NSNumber *)getWidth:(NSMutableArray *)inArguments{
    return @(self.meBrwView.bounds.size.width);
}
- (NSNumber *)getHeight:(NSMutableArray *)inArguments{
    return @(self.meBrwView.bounds.size.height);
}

NSString *const kUexWindowValueDictKey = @"uexWindow.valueDict";
- (void)putLocalData:(NSMutableArray*)inArguments{
    if([inArguments count] < 2){
        return;
    }
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [[df valueForKey:kUexWindowValueDictKey] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setValue:inArguments[1] forKey:inArguments[0]];
    [df setValue:dict forKey:kUexWindowValueDictKey];
    [df synchronize];
}

- (id)getLocalData:(NSMutableArray*)inArguments{
    if([inArguments count] == 0){
        return nil;
    }
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:kUexWindowValueDictKey];
    if (!dict) {
        return nil;
    }
    return dict[inArguments[0]];
    
}

- (void)setIsSupportSwipeCallback:(NSMutableArray *)inArguments{
    ACE_ArgsUnpack(NSDictionary *info) = inArguments;
    if(info && info[@"isSupport"]){
        self.meBrwView.meBrowserView.swipeCallbackEnabled = [info[@"isSupport"] boolValue];
    }
}

- (NSString *)getWindowName:(NSMutableArray *)inArguments{
    return self.meBrwView.meBrwWnd.meBrwView.muexObjName;
}

#pragma mark - share

- (void)share:(NSMutableArray *)inArguments{
    if([inArguments count] < 1){
        return;
    }
    id info = [inArguments[0] JSONValue];
    if(!info || ![info isKindOfClass:[NSDictionary class]]){
        return;
    }
    __block NSMutableArray *shareItems = [NSMutableArray array];
    if (info[@"text"]) {
        [shareItems addObject:info[@"text"]];
    }
    if (info[@"imgPaths"] && [info[@"imgPaths"] isKindOfClass:[NSArray class]]) {
        [info[@"imgPaths"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *path = [self absPath:obj];
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                [shareItems addObject:image];
            }
        }];
    }else if(info[@"imgPath"]){
        NSString *path = [self absPath:info[@"imgPath"]];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            [shareItems addObject:image];
        }
    }
    UIActivityViewController * shareVC = [[UIActivityViewController alloc]initWithActivityItems:shareItems applicationActivities:nil];
    [EUtility brwView:self.meBrwView presentModalViewController:shareVC animated:YES];
}

@end
