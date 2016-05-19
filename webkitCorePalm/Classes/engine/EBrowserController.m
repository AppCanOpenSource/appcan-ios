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
#import "ACEUtils.h"

//#import <usr/in>
#define KAlertWithUpdateTag 1000


NSString *const kACECustomLoadingImagePathKey = @"AppCanCustomLaunchImage";
NSString *const kACECustomLoadingImageTimeKey = @"AppCanCustomLaunchTime";
static NSString *const kACEDefaultLoadingImagePathKey = @"AppCanLaunchImage";

@implementation EBrowserController
@synthesize mStartView;
@synthesize meBrwMainFrm;
@synthesize meBrw;
@synthesize mwWgtMgr;
@synthesize mFlag;
@synthesize ballHasShow;
@synthesize forebidPluginsList;
@synthesize forebidWinsList;
@synthesize forebidPopWinsList;
@synthesize wgtOrientation;
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
	mwWgtMgr.wMainWgt.showMySpace = mySpaceValue;
	ACENSLog(@"showSpaceStr = %@",str);
	if ((mySpaceValue & WIDGETREPORT_SPACESTATUS_OPEN) == WIDGETREPORT_SPACESTATUS_OPEN) {
		self.meBrwMainFrm.meBrwToolBar.hidden = NO;
	}else {
		self.meBrwMainFrm.meBrwToolBar.hidden = YES;
	}
	if ((mySpaceValue & WIDGETREPORT_SPACESTATUS_EXTEN_OPEN) == WIDGETREPORT_SPACESTATUS_EXTEN_OPEN){
		//显示更多
		if (meBrwMainFrm.mAppCenter) {
			if (meBrwMainFrm.mAppCenter.sView) {
				[meBrwMainFrm.mAppCenter.sView showMoreAppBtn:YES];
			}
		}
	}else {
		//隐藏更多
		if (meBrwMainFrm.mAppCenter) {
			if (meBrwMainFrm.mAppCenter.sView) {
				[meBrwMainFrm.mAppCenter.sView showMoreAppBtn:NO];
			}
		}
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"componentStatusUpdate" object:nil];
}
- (id)init {
	if (self = [super init]) {
		meBrw = [[EBrowser alloc]init];
		meBrw.meBrwCtrler = self;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHideEnterStatus:) name:@"componentStatusUpdate" object:nil];
		mFlag = 0;
        if (!mamList) {
            mamList =[[NSMutableArray alloc] initWithCapacity:1];
        }
        mwWgtUpdate = [[WWidgetUpdate alloc] init];
	}
	return self;
}

- (void)dealloc {
	if (mStartView) {
		if (mStartView.superview) {
			[mStartView removeFromSuperview];
		}
		[mStartView release];
		mStartView = nil;
	}
	if (meBrwMainFrm) {
		if (meBrwMainFrm.superview) {
			[meBrwMainFrm removeFromSuperview];
		}
		[meBrwMainFrm release];
		meBrwMainFrm = nil;
	}
	if (meBrw) {
		[meBrw release];
		meBrw = nil;
	}
	if (mwWgtMgr) {
		[mwWgtMgr release];
		mwWgtMgr = nil;
	}
    if(mamList){
        [mamList release];
        mamList = nil;
    }
    [mwWgtUpdate release];
    mwWgtUpdate = nil;
    if (forebidPluginsList) {
        [forebidPluginsList release];
        forebidPluginsList = nil;
    }
    if (forebidWinsList) {
        [forebidWinsList release];
        forebidWinsList = nil;
    }
    if (forebidPopWinsList) {
        [forebidPopWinsList release];
        forebidPopWinsList = nil;
    }
	[super dealloc];
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
/*
 - (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
 {
 NSLog(@"motion start");
 
 }
 - (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
 [ballView setAcceleration:acceleration];
 [ballView draw];
 }
 
 -(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 NSLog(@"notion end");
 if ([BUtility getAppCanDevMode]) {
 return;
 }
 if (![self.mwWgtMgr.wMainWgt getMySpaceStatus]) {
 return;
 }
 if (ballHasShow == YES) {
 return;
 }
 if (ballView==nil) {
 ballView = [[BallView alloc] initWithFrame:self.view.bounds];
 [self.meBrwMainFrm addSubview:ballView];
 mFlag = 1;
 ballHasShow = YES;
 UIAccelerometer *acceler = [UIAccelerometer sharedAccelerometer];
 acceler.delegate = self;
 acceler.updateInterval = 1.0/60;
 }
 }
 -(void)ballEnterSector:(NSNotification *)inNotification{
 NSLog(@"ball enter");
 [ballView removeFromSuperview];
 [ballView release];
 ballView= nil;
 [[UIAccelerometer sharedAccelerometer]setDelegate:nil];
 [self.meBrwMainFrm.meBrwToolBar LoadSpace];
 
 }
 */
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
/*
- (void)hideSplashScreen:(id)sender
{
	[mSplashLock lock];
	mSplashFired = YES;
	if (meBrwMainFrm.mLoadDone) {
		[mStartView removeFromSuperview];
		mStartView = nil;
        meBrwMainFrm.hidden = NO;
	}
    self.wgtOrientation= [[BUtility getMainWidgetConfigInterface]intValue];
	[mSplashLock unlock];
    
    
}
*/
#pragma mark - UPdateWgtHtml

- (void)doUpdateWgt {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    BOOL isNeedCopy = [mwWgtMgr isNeetUpdateWgt];
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
    } else {
        //
    }
    if (isNeedCopy || !isCopyFinish) {
        isCopyFinish = NO;
        [ud setObject:@"NO" forKey:F_UD_WgtCopyFinish];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSAutoreleasePool * autoReleasePool = [[NSAutoreleasePool alloc]init];
            BOOL isCopyFinishAndSuccess = [self copyWgtToDocument];
            [autoReleasePool drain];
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
            BOOL isOK = [mwWgtUpdate unZipUpdateWgt:downWgtPath];
            if (isOK) {
                ACENSLog(@"更新成功");
                [mwWgtUpdate removeAllUD:updateWgtID];
            }else {
                ACENSLog(@"更新失败");
                UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:ACELocalized(@"文件解压失败") delegate:nil cancelButtonTitle:ACELocalized(@"确定") otherButtonTitles: nil];
                alertView.tag = KAlertWithUpdateTag;
                [alertView show];
                [alertView release];
            }
        }else {
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

- (void)loadView {
	[super loadView];
    if (!meBrw) {
        meBrw = [[EBrowser alloc]init];
        meBrw.meBrwCtrler = self;
    }
	if (F_DEVELOPMENT_USE) {
		[BUtility setAppCanDevMode:@"YES"];
	}
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
        mStartView = [[UIImageView alloc] initWithImage:customImage];
    }
    
    if (!mStartView) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if ([oritent isEqualToString:@"UIInterfaceOrientationLandscapeLeft"] || [oritent isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
                launchImageName = [NSString stringWithFormat:@"%@-700-Landscape~ipad",launchImagePrefixFile];
            } else {
                launchImageName = [NSString stringWithFormat:@"%@-700-Portrait~ipad",launchImagePrefixFile];
            }
            launchImage = [UIImage imageNamed:launchImageName];
            if (launchImage == nil) { //iPhone包在ipad显示
                launchImageName = [NSString stringWithFormat:@"%@-568h@2x",launchImagePrefixFile];
                if (ACE_iOSVersion < 7.0) {
                    launchImageName = [NSString stringWithFormat:@"%@",launchImagePrefixFile];
                }
            }
            launchImage = [UIImage imageNamed:launchImageName];
            mStartView = [[UIImageView alloc]initWithImage:launchImage];
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
            mStartView = [[UIImageView alloc] initWithImage:launchImage];
        }
    }
    

    if (ACE_iOSVersion < 7.0) {
        mStartView.frame = CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height);
    }else{
        mStartView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
	mStartView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    
	if ([BUtility getAppCanDevMode]) {
		UILabel *devMark = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,30)];
		devMark.backgroundColor =[UIColor clearColor];
		devMark.text =ACELocalized(@"测试版本仅用于开发测试");
		devMark.textColor = [UIColor redColor];
		devMark.textAlignment = NSTextAlignmentLeft;
		devMark.font = [UIFont boldSystemFontOfSize:24];
		[mStartView addSubview:devMark];
		[devMark release];
	}
	[self.view addSubview:mStartView];
    //配置是否支持增量升级
    if (theApp.useUpdateWgtHtmlControl) {
        [self doUpdateWgt];
        NSString * configOrientation = [BUtility getMainWidgetConfigInterface];
        self.wgtOrientation = [configOrientation intValue];
    }
	[mwWgtMgr loadMainWidget];
    meBrwMainFrm = [[EBrowserMainFrame alloc]initWithFrame:[BUtility getApplicationInitFrame] BrwCtrler:self];
	[self.view addSubview:meBrwMainFrm];
	meBrwMainFrm.hidden = YES;
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
	//[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(hideSplashScreen:) userInfo:nil repeats:NO];
    
    [meBrw start:mwWgtMgr.wMainWgt];
        //NSString *clientPWd =[BUtility RC4DecryptWithInput:theApp.useCertificatePassWord key:mwWgtMgr.mainWidget.appId];
    //[BUtility setClientCertificatePwd:clientPWd];
    
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
        [mStartView removeFromSuperview];
        mStartView = nil;
        [mStartView release];
        meBrwMainFrm.hidden = NO;
        self.wgtOrientation= [[BUtility getMainWidgetConfigInterface]intValue];
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
    NSDictionary * extraDic = [BUtility getMainWidgetConfigWindowBackground];
    [self setExtraInfo:extraDic toEBrowserView:self.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView];
    
    if ([BUtility getAppCanDevMode]) {
        Class  analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis");
        if (!analysisClass) {
            analysisClass = NSClassFromString(@"AppCanAnalysis");
            if (!analysisClass) {
                return;
            }
        }
        id analysisObject = class_createInstance(analysisClass,0);
        ((void(*)(id, SEL,BOOL))objc_msgSend)(analysisObject, @selector(setErrorReport:),YES);
    }
    NSString * inKey = [BUtility appKey];
    if (theApp.userStartReport) {
        Class analysisClass = NSClassFromString(@"EUExDataAnalysis");
        if (analysisClass) {
            NSMutableArray * array = [NSMutableArray arrayWithObjects:inKey,mwWgtMgr,self,nil];
            id analysisObject = class_createInstance(analysisClass,0);
            ((void(*)(id, SEL,NSArray*))objc_msgSend)(analysisObject, @selector(startEveryReport:),array);
        }
    }
    if (theApp.userStartReport) {
        Class analysisClass = NSClassFromString(@"UexEMMDataAnalysis");
        if (analysisClass) {
            NSMutableArray * array = [NSMutableArray arrayWithObjects:inKey,mwWgtMgr,self,nil];
            id analysisObject = class_createInstance(analysisClass,0);
            ((void(*)(id, SEL,NSArray*))objc_msgSend)(analysisObject, @selector(startEveryReport:),array);
        }
    }
    if (theApp.useUpdateControl || theApp.useUpdateWgtHtmlControl) {//添加升级
        NSMutableArray * dataArray = [NSMutableArray arrayWithObjects:mwWgtMgr.wMainWgt.appId,inKey,mwWgtMgr.wMainWgt.ver,@"",nil];////0:appid 1:appKey2:currentVer 3:更新地址  url
        Class  updateClass = NSClassFromString(@"EUExUpdate");
        if (!updateClass) {
            return;
        }
        id analysisObject = class_createInstance(updateClass,0);
        ((void(*)(id, SEL,NSArray*))objc_msgSend)(analysisObject, @selector(doUpdate:),dataArray);
    }
}


/*
 -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
 //    if (!meBrwMainFrm || meBrwMainFrm.isHidden) {
 //        return YES;
 //    }
 //ipad 横竖屏
 //NSLog(@"self.meBrwMainFrm.hidden=%d",self.mStartView.hidden);
 //if (self.meBrwMainFrm.hidden) {
 //    NSLog(@"self.meBrwMainFrm.hidden");
 //    return NO;
 //}
 
 EBrowserWindowContainer *aboveWndContainer = [meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
 if (aboveWndContainer) {
 EBrowserWindow *eBrwWnd = [aboveWndContainer aboveWindow];
 if (eBrwWnd && eBrwWnd.meBottomSlibingBrwView && ((eBrwWnd.meBottomSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_FORBID_ROTATE) == F_EBRW_VIEW_FLAG_FORBID_ROTATE)) {
 return NO;
 }
 if ((mFlag & F_EBRW_CTRL_FLAG_FORBID_ROTATE) == F_EBRW_CTRL_FLAG_FORBID_ROTATE) {
 return NO;
 }
 if (meBrwMainFrm.mSBWnd && (meBrwMainFrm.mSBWnd.hidden == NO)) {
 return NO;
 }
 switch (toInterfaceOrientation) {
 case UIInterfaceOrientationPortrait:
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
 return YES;
 }
 break;
 case UIInterfaceOrientationPortraitUpsideDown:
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
 return YES;
 }
 break;
 case UIInterfaceOrientationLandscapeLeft:
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
 return YES;
 }
 break;
 case UIInterfaceOrientationLandscapeRight:
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
 return YES;
 }
 break;
 default:
 break;
 }
 }
 return YES;
 }
 
 - (BOOL)shouldAutorotate {
 EBrowserWindowContainer *aboveWndContainer = [meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
 if (aboveWndContainer) {
 EBrowserWindow *eBrwWnd = [aboveWndContainer aboveWindow];
 if (eBrwWnd && eBrwWnd.meBottomSlibingBrwView && ((eBrwWnd.meBottomSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_FORBID_ROTATE) == F_EBRW_VIEW_FLAG_FORBID_ROTATE)) {
 return NO;
 }
 if ((mFlag & F_EBRW_CTRL_FLAG_FORBID_ROTATE) == F_EBRW_CTRL_FLAG_FORBID_ROTATE) {
 return NO;
 }
 if (meBrwMainFrm.mSBWnd && (meBrwMainFrm.mSBWnd.hidden == NO)) {
 return NO;
 }
 return YES;
 }
 return YES;
 }
 
 - (NSUInteger)supportedInterfaceOrientations {
 int orientation = 0;
 EBrowserWindowContainer *aboveWndContainer = [meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
 if (aboveWndContainer) {
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
 orientation |= UIInterfaceOrientationMaskPortrait;
 }
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
 orientation |= UIInterfaceOrientationMaskPortraitUpsideDown;
 }
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
 orientation |= UIInterfaceOrientationMaskLandscapeLeft;
 }
 if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
 orientation |= UIInterfaceOrientationMaskLandscapeRight;
 }
 }
 return orientation;
 }
 */
//  控制屏幕方向


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	EBrowserWindowContainer *aboveWndContainer = [meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
	if (aboveWndContainer) {
		switch (toInterfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
					[meBrwMainFrm setVerticalFrame];
				}
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
					[meBrwMainFrm setVerticalFrame];
				}
				break;
			case UIInterfaceOrientationLandscapeLeft:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
					[meBrwMainFrm setHorizontalFrame];
				}
				break;
			case UIInterfaceOrientationLandscapeRight:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
					[meBrwMainFrm setHorizontalFrame];
				}
				break;
			default:
				break;
		}
	}
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
	NSString *jsStr = nil;
	EBrowserWindowContainer *aboveWndContainer = [meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
	UIInterfaceOrientation nowOrientation = (UIInterfaceOrientation)[[UIDevice currentDevice] orientation];
	if (aboveWndContainer) {
		switch (nowOrientation) {
			case UIInterfaceOrientationPortrait:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
					jsStr = [NSString stringWithFormat:@"if(%@!=null){%@(%d);}",@"uexDevice.onOrientationChange",@"uexDevice.onOrientationChange",F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT];
				}
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
					jsStr = [NSString stringWithFormat:@"if(%@!=null){%@(%d);}",@"uexDevice.onOrientationChange",@"uexDevice.onOrientationChange",F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN];
				}
				break;
			case UIInterfaceOrientationLandscapeLeft:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
					jsStr = [NSString stringWithFormat:@"if(%@!=null){%@(%d);}",@"uexDevice.onOrientationChange",@"uexDevice.onOrientationChange",F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT];
				}
				break;
			case UIInterfaceOrientationLandscapeRight:
				if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
					jsStr = [NSString stringWithFormat:@"if(%@!=null){%@(%d);}",@"uexDevice.onOrientationChange",@"uexDevice.onOrientationChange",F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT];
				}
				break;
			default:
				break;
		}
		if ([[[meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow] isKindOfClass:[EBrowserWindow class]]) {
			[[[meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow].meBrwView stringByEvaluatingJavaScriptFromString:jsStr];
		}
	}
}

- (void)didReceiveMemoryWarning {
	//[BUtility writeLog:@"Ebrowser controller receive memory warning"];
	//ACENSLog(@"init the start view :the uesdMemory is %f,the have memory is %f",[BUtility usedMemory],[BUtility availableMemory]);
	//ACENSLog(@"warning :the uesdMemory is %f",[BUtility usedMemory]);
    [super didReceiveMemoryWarning] ;

}


@end
