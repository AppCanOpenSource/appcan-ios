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

#import "EBrowserController.h"
#import "EBrowserMainFrame.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserView.h"
#import "EBrowser.h"
#import "EUtility.h"
#import "BUtility.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "WWidgetMgr.h"
#import "WidgetSQL.h"
#import "EBrowserToolBar.h"
#import "BStatusBarWindow.h"
#import "WidgetOneDelegate.h"
#import "WWidgetUpdate.h"
#import "NSString+SBJSON.h"
#import "SFHFKeychainUtils.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ACEBaseDefine.h"

#import <AppCanKit/ACInvoker.h>
//#import <usr/in>
#define KAlertWithUpdateTag 1000



@interface EBrowserController()
@property (nonatomic,strong) NSMutableArray *mamList;
@property (nonatomic,strong) WWidgetUpdate *mwWgtUpdate;
@end





NSString *const kACECustomLoadingImagePathKey = @"AppCanCustomLaunchImage";
NSString *const kACECustomLoadingImageTimeKey = @"AppCanCustomLaunchTime";
static NSString *const kACEDefaultLoadingImagePathKey = @"AppCanLaunchImage";

@implementation EBrowserController

- (WWidgetMgr *)mwWgtMgr{
    return [WWidgetMgr sharedManager];
}


-(void)getHideEnterStatus:(NSNotification *)inNotification{
	if ([BUtility getAppCanDevMode]) {
		return;
	}
	NSDictionary *statusDict = [NSDictionary dictionaryWithDictionary:[inNotification userInfo]];
	NSString *str =[statusDict objectForKey:@"showSpaceTag"];
	if (!str) {
		return;
	}
	int mySpaceValue = [str intValue];
	self.mwWgtMgr.mainWidget.showMySpace = mySpaceValue;

	if (mySpaceValue & WIDGETREPORT_SPACESTATUS_OPEN) {
		self.meBrwMainFrm.meBrwToolBar.hidden = NO;
	}else {
		self.meBrwMainFrm.meBrwToolBar.hidden = YES;
	}
	if (mySpaceValue & WIDGETREPORT_SPACESTATUS_EXTEN_OPEN){
		//显示更多
        [self.meBrwMainFrm.mAppCenter.sView showMoreAppBtn:YES];
	}else {
		//隐藏更多
        [self.meBrwMainFrm.mAppCenter.sView showMoreAppBtn:NO];
        
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"componentStatusUpdate" object:nil];
}



- (instancetype)initWithwidget:(WWidget *)widget{
    self = [super init];
    if (self) {
        _widget = widget;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHideEnterStatus:) name:@"componentStatusUpdate" object:nil];
        _mFlag = 0;
        _mamList =[[NSMutableArray alloc] initWithCapacity:1];
        _mwWgtUpdate = [[WWidgetUpdate alloc] init];
        _meBrwMainFrm = [[EBrowserMainFrame alloc]initWithFrame:[UIScreen mainScreen].bounds BrwCtrler:self];
        _meBrw = [[EBrowser alloc] init];
        _meBrw.meBrwCtrler = self;
        _meBrwMainFrm.meBrwWgtContainer = [[EBrowserWidgetContainer alloc] initWithFrame:[UIScreen mainScreen].bounds browserController:self widget:widget];
        [_meBrwMainFrm addSubview:_meBrwMainFrm.meBrwWgtContainer];
    }
    
    return self;
    

}

- (instancetype)initWithMainWidget{
    self = [self initWithwidget:[WWidgetMgr sharedManager].mainWidget];
    if (self) {
        self.isAppCanRootViewController = YES;
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_mStartView removeFromSuperview];
    _mStartView = nil;
    [_meBrwMainFrm removeFromSuperview];
    _meBrwMainFrm = nil;
    _meBrw = nil;
    _mamList = nil;
    _mwWgtUpdate = nil;
}

- (EBrowserWidgetContainer*)brwWidgetContainer {
	return self.meBrwMainFrm.meBrwWgtContainer;
}

- (BOOL) canBecomeFirstResponder{
    return YES;
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}


- (void) doRotate:(NSNotification*)inNotification {
	ACENSLog(@"browser controler doRotate %@", inNotification);
	if (self.mStartView) {
		UIDeviceOrientation deviceOrientation = (UIDeviceOrientation)[UIDevice currentDevice].orientation;
		UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
		if ([BUtility isValidateOrientation:(UIInterfaceOrientation)deviceOrientation] == NO) {
			deviceOrientation = (UIDeviceOrientation)statusBarOrientation;
		}
		//[self.mStartView setFrame:CGRectMake(0, 0, 320, 460)];
	}
}

#pragma mark - UPdateWgtHtml

- (void)doUpdateWgt {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    BOOL isNeedCopy = [self.mwWgtMgr isNeetUpdateWgt];
    BOOL isCopyFinish = [[ud objectForKey:F_UD_WgtCopyFinish] boolValue];
    
    /* 
     * 1.IDE 2.document存在widget
     * 保证IDE首次启动读取document下的widget包.
     */
    
    BOOL appCanDevMode = [BUtility getAppCanDevMode];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *configPath=[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
    
    BOOL isExists = [fileManager fileExistsAtPath:configPath];
    if (appCanDevMode && isExists) {
        [ud setObject:@"YES" forKey:F_UD_WgtCopyFinish];
        isCopyFinish = YES;
        isNeedCopy = NO;
    }
    if (isNeedCopy || !isCopyFinish) {
        isCopyFinish = NO;
        [ud setObject:@"NO" forKey:F_UD_WgtCopyFinish];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            BOOL isCopyFinishAndSuccess = [self copyWgtToDocument];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isCopyFinishAndSuccess) {
                    [ud setObject:@"YES" forKey:F_UD_WgtCopyFinish];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppCanWgtCopyFinishedNotification" object:nil];
                }
            });
        });
    }

    //升级解压
    NSString *updateWgtID = [ud objectForKey:F_UD_UpdateWgtID];
    if (updateWgtID && isCopyFinish) {
        //初始化Documents路径
        NSArray *cacheList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *folderPath = [cacheList objectAtIndex:0];
        NSString *downWgtPath = [[NSString alloc] initWithFormat:@"%@/%@.zip",folderPath,updateWgtID];
        NSFileManager *fileMgr =[NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:downWgtPath]) {
            BOOL isOK = [self.mwWgtUpdate unZipUpdateWgt:downWgtPath];
            if (isOK) {
                ACENSLog(@"更新成功");
                [self.mwWgtUpdate removeAllUD:updateWgtID];
            }else {
                ACENSLog(@"更新失败");
                UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:ACELocalized(@"文件解压失败") delegate:nil cancelButtonTitle:ACELocalized(@"确定") otherButtonTitles: nil];
                alertView.tag = KAlertWithUpdateTag;
                [alertView show];
            }
        }
    }
}

- (BOOL)copyWgtToDocument {
    
    NSError * error;
    NSFileManager * fileMgr = [NSFileManager defaultManager];
	NSString * wgtOldPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"widget"];
    NSString * wgtNewPath = nil;
    
    if ([BUtility getSDKVersion] < 5.0) {
        wgtNewPath = [BUtility getCachePath:@"widget"];
    } else {
        wgtNewPath =[BUtility getDocumentsPath:@"widget"];
    }
    BOOL folderFlag = YES;
    
    if (![fileMgr fileExistsAtPath:wgtNewPath isDirectory:&folderFlag]) {
        BOOL result = [fileMgr createDirectoryAtPath:wgtNewPath withIntermediateDirectories:NO attributes:nil error:&error];
        [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:wgtNewPath]];
        if (!result && error) {
            return NO;
        }
    }
    
    if ([fileMgr fileExistsAtPath:wgtOldPath]) {
        NSError * error;
        NSDirectoryEnumerator * oldWgtEnumerator = [fileMgr enumeratorAtPath:wgtOldPath];
        NSString * fileName = nil;
        BOOL result;
        while ((fileName = [oldWgtEnumerator nextObject])) {
            NSString * oldFilePath = [wgtOldPath stringByAppendingPathComponent:fileName];
            NSString * newFilePath = [wgtNewPath stringByAppendingPathComponent:fileName];
            BOOL flag = YES;
            if ([fileMgr fileExistsAtPath:oldFilePath isDirectory:&flag]) {
                if (!flag) {
                    if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                        if ([fileMgr fileExistsAtPath:newFilePath]) {
                            result = [fileMgr removeItemAtPath:newFilePath error:&error];
                            if (!result && error) {
                                return NO;
                            }
                        }
                        result =  [fileMgr copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
                        if (!result && error) {
                            return NO;
                        }
                    }
                } else {
                    result = [fileMgr createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:&error];
                    if (!result && error) {
                        return NO;
                    }
                }
            }
        }
    } else {
        [BUtility exitWithClearData];
        return NO;
    }
    return YES;
}




static BOOL userCustomLoadingImageEnabled = NO;



- (void)presentStartImage{
    self.meBrwMainFrm.hidden = YES;
    NSString * oritent = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIInterfaceOrientation"] ;
    NSString * launchImagePrefixFile = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UILaunchImageFile"] ;
    NSString * launchImageName = nil;
    UIImage * launchImage = nil;
    NSUserDefaults *df = [NSUserDefaults standardUserDefaults];
    NSString *userCustomLoadingImagePath = [df objectForKey:kACECustomLoadingImagePathKey];
    
    if (userCustomLoadingImagePath && userCustomLoadingImagePath.length > 0) {
        
        if ([userCustomLoadingImagePath hasPrefix:F_RES_PATH]) {
            userCustomLoadingImagePath = [userCustomLoadingImagePath substringFromIndex:F_RES_PATH.length];
            BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
            if (theApp.useUpdateWgtHtmlControl && isCopyFinish){
                userCustomLoadingImagePath = [[BUtility getDocumentsPath:@"widget/wgtRes"] stringByAppendingPathComponent:userCustomLoadingImagePath];
            }else{
                userCustomLoadingImagePath = [NSString pathWithComponents:@[[NSBundle mainBundle].resourcePath,@"widget/wgtRes",userCustomLoadingImagePath]];
            }
        }
        if ([userCustomLoadingImagePath hasPrefix:F_APP_PATH]) {
            userCustomLoadingImagePath = [userCustomLoadingImagePath substringFromIndex:F_APP_PATH.length];
            userCustomLoadingImagePath = [[BUtility getDocumentsPath:@"widget"] stringByAppendingPathComponent:userCustomLoadingImagePath];
        }
        userCustomLoadingImageEnabled = [[NSFileManager defaultManager]fileExistsAtPath:userCustomLoadingImagePath];
    }
    UIImage *customImage = nil;
    if (userCustomLoadingImageEnabled) {
        customImage = [UIImage imageWithContentsOfFile:userCustomLoadingImagePath];
    }
    if (!customImage) {
        customImage = [UIImage imageWithContentsOfFile:[df objectForKey:kACEDefaultLoadingImagePathKey]];
    }
    if (customImage) {
        self.mStartView = [[UIImageView alloc] initWithImage:customImage];
    }
    
    if (!self.mStartView) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([oritent isEqualToString:@"UIInterfaceOrientationLandscapeLeft"] || [oritent isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
                launchImageName = [NSString stringWithFormat:@"%@-700-Landscape~ipad",launchImagePrefixFile];
            } else {
                launchImageName = [NSString stringWithFormat:@"%@-700-Portrait~ipad",launchImagePrefixFile];
            }
            launchImage = [UIImage imageNamed:launchImageName];
            if (launchImage == nil) { //iPhone包在ipad显示
                launchImageName = [NSString stringWithFormat:@"%@-568h@2x",launchImagePrefixFile];
                if (ACSystemVersion() < 7.0) {
                    launchImageName = [NSString stringWithFormat:@"%@",launchImagePrefixFile];
                }
            }
            launchImage = [UIImage imageNamed:launchImageName];
            self.mStartView = [[UIImageView alloc]initWithImage:launchImage];
        } else {
            if (iPhone5) {
                launchImageName = [NSString stringWithFormat:@"%@-568h@2x", launchImagePrefixFile];
            } else if (iPhone6) {
                launchImageName = [NSString stringWithFormat:@"%@-800-667h@2x", launchImagePrefixFile];
            } else if (iPhone6Plus) {
                launchImageName = [NSString stringWithFormat:@"%@-800-Portrait-736h@3x", launchImagePrefixFile];
            } else {
                launchImageName = [NSString stringWithFormat:@"%@", launchImagePrefixFile];
            }
            launchImage = [UIImage imageNamed:launchImageName];
            self.mStartView = [[UIImageView alloc] initWithImage:launchImage];
        }
    }
    
    
    
    self.mStartView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    self.mStartView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.mStartView.frame.size.width > self.mStartView.frame.size.height){
        //iPhone 横屏应用,特殊处理
        self.mStartView.image = [UIImage imageWithCGImage:self.mStartView.image.CGImage scale:1 orientation:UIImageOrientationLeft];
    }
    
    if ([BUtility getAppCanDevMode]) {
        UILabel *devMark = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
        devMark.backgroundColor =[UIColor clearColor];
        devMark.text =ACELocalized(@"测试版本仅用于开发测试");
        devMark.textColor = [UIColor redColor];
        devMark.textAlignment = NSTextAlignmentLeft;
        devMark.font = [UIFont boldSystemFontOfSize:24];
        [self.mStartView addSubview:devMark];
        
    }
    [self.view addSubview:self.mStartView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self handleLoadingImageCloseEvent:ACELoadingImageCloseEventAppLoadingTimeout];
    });
    
    
    if (userCustomLoadingImageEnabled) {
        NSNumber *launchTime = [[NSUserDefaults standardUserDefaults]objectForKey:kACECustomLoadingImageTimeKey];
        if (launchTime && launchTime.integerValue > 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(launchTime.integerValue * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self handleLoadingImageCloseEvent:ACELoadingImageCloseEventCustomLoadingTimeout];
            });
        }
    }
}




- (void)handleLoadingImageCloseEvent:(ACELoadingImageCloseEvent)event{
    static BOOL loadingImageClosed = NO;
    static BOOL webViewCloseEventHandled = NO;
    static BOOL webViewCloseEventDisabled = NO;
    static BOOL appCloseEventHandled = NO;

    if (loadingImageClosed) {
        return;
    }
    switch (event) {
        case ACELoadingImageCloseEventWebViewFinishLoading: {
            if (webViewCloseEventHandled) {
                break;
            }
            webViewCloseEventHandled = YES;
            if (!userCustomLoadingImageEnabled){
                [self closeLoadingImage];
                loadingImageClosed = YES;
            }
            
            break;
        }
        case ACELoadingImageCloseEventCustomLoadingTimeout: {
            if (!userCustomLoadingImageEnabled) {
                break;
            }
            userCustomLoadingImageEnabled = NO;
            if ((webViewCloseEventDisabled && appCloseEventHandled)  || (!webViewCloseEventDisabled && webViewCloseEventHandled)) {
                [self closeLoadingImage];
                loadingImageClosed = YES;
            }
            break;
        }
        case ACELoadingImageCloseEventAppLoadingTimeout: {
            webViewCloseEventDisabled = YES;
            appCloseEventHandled = YES;
            if (!userCustomLoadingImageEnabled) {
                [self closeLoadingImage];
                loadingImageClosed = YES;
            }
            break;
        }
    }
}

- (void)closeLoadingImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mStartView removeFromSuperview];
        self.mStartView = nil;
        self.meBrwMainFrm.hidden = NO;

    });

}


-(BOOL)isHaveString:(NSString *)inSouceString subSting:(NSString *)inSubSting{
    NSRange range = [inSouceString rangeOfString:inSubSting];
    if (range.location!=NSNotFound) {
        return YES;
    }else{
        return NO;
    }
}

-(void)setExtraInfo:(NSDictionary *)extraDic toEBrowserView:(UIImageView *)inBrwView{
    if ([extraDic objectForKey:@"opaque"]) {
        BOOL opaque = [[extraDic objectForKey:@"opaque"] boolValue];
        if (opaque) {
            if ([extraDic objectForKey:@"bgColor"]) {
                NSString * bgColorStr = [extraDic objectForKey:@"bgColor"];
                if ([self isHaveString:bgColorStr subSting:@"://"]) {
                    
                    inBrwView.backgroundColor = [UIColor clearColor];
                    NSString * imgPath = [BUtility getAbsPath:self.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView path:bgColorStr];
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

- (void)viewDidLoad {
	[super viewDidLoad];
    if (theApp.useUpdateWgtHtmlControl) {
        [self doUpdateWgt];
    }

    
    
    [self.view addSubview:self.meBrwMainFrm];
    if (self.isAppCanRootViewController) {
        [self presentStartImage];
        [self.meBrw start:self.mwWgtMgr.mainWidget];
    }
    

    
    NSDictionary * extraDic = [BUtility getMainWidgetConfigWindowBackground];
    [self setExtraInfo:extraDic toEBrowserView:self.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView];
    
    if ([BUtility getAppCanDevMode]) {
        Class analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis") ?: NSClassFromString(@"AppCanAnalysis");
        if (!analysisClass) {
            return;
        }
        id analysisObject = [[analysisClass alloc] init];
        [analysisObject ac_invoke:@"setErrorReport:" arguments:ACArgsPack(@(YES))];
    }
    NSString * inKey = [BUtility appKey];
    if (theApp.userStartReport) {
        Class analysisClass = NSClassFromString(@"EUExDataAnalysis");
        if (analysisClass) {
            NSMutableArray * array = [NSMutableArray arrayWithObjects:inKey,self.mwWgtMgr,self,nil];
            id analysisObject = [[analysisClass alloc] init];
            [analysisObject ac_invoke:@"startEveryReport:" arguments:ACArgsPack(array)];

        }
    }
    if (theApp.userStartReport) {
        Class analysisClass = NSClassFromString(@"UexEMMDataAnalysis");
        if (analysisClass) {
            NSMutableArray * array = [NSMutableArray arrayWithObjects:inKey,self.mwWgtMgr,self,nil];
            id analysisObject = [[analysisClass alloc] init];
            [analysisObject ac_invoke:@"startEveryReport:" arguments:ACArgsPack(array)];
        }
    }
    if (theApp.useUpdateControl || theApp.useUpdateWgtHtmlControl) {//添加升级
        NSMutableArray * dataArray = [NSMutableArray arrayWithObjects:self.mwWgtMgr.mainWidget.appId,inKey,self.mwWgtMgr.mainWidget.ver,@"",nil];////0:appid 1:appKey2:currentVer 3:更新地址  url
        Class  updateClass = NSClassFromString(@"EUExUpdate");
        if (!updateClass) {
            return;
        }
        id analysisObject = [[updateClass alloc] init];
        [analysisObject ac_invoke:@"doUpdate:" arguments:ACArgsPack(dataArray)];
    }
}



//  控制屏幕方向


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	EBrowserWindowContainer *aboveWndContainer = [self.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
	if (aboveWndContainer) {

        
        
		switch (toInterfaceOrientation) {
			case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:{
				if (aboveWndContainer.mwWgt.orientation & ace_interfaceOrientationFromUIInterfaceOrientation(toInterfaceOrientation)) {
					[self.meBrwMainFrm setVerticalFrame];
				}
				break;
            }
			case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:{
				if (aboveWndContainer.mwWgt.orientation & ace_interfaceOrientationFromUIInterfaceOrientation(toInterfaceOrientation)) {
					[self.meBrwMainFrm setHorizontalFrame];
				}
				break;
            }
			default:
				break;
		}
	}
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	EBrowserWindowContainer *aboveWndContainer = [self.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
    ACEInterfaceOrientation nowOrientation = ace_interfaceOrientationFromUIDeviceOrientation([[UIDevice currentDevice] orientation]);
    
	if (aboveWndContainer && (aboveWndContainer.mwWgt.orientation & nowOrientation)) {
        [[[self.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView callbackWithFunctionKeyPath:@"uexDevice.onOrientationChange" arguments:ACArgsPack(@(nowOrientation))];

	}
}

- (EBrowserWindow *)rootWindow{
    return self.brwWidgetContainer.meRootBrwWndContainer.meRootBrwWnd;
}

@end
