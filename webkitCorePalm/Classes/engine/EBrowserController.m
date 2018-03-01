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
#import "WidgetOneDelegate.h"

#import "NSString+SBJSON.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ACEInterfaceOrientation.h"

#import <AppCanKit/ACInvoker.h>
#import "ACEConfigXML.h"
#import "ACEWidgetUpdateUtility.h"

#import "DataAnalysisInfo.h"
#define KAlertWithUpdateTag 1000



@interface EBrowserController()
@property (nonatomic,strong) NSMutableArray *mamList;

@property (nonatomic,strong) id updateObj;
@property (nonatomic,assign)BOOL startImageClosed;
@property (nonatomic,assign)BOOL webViewCloseEventHandled;
@property (nonatomic,assign)BOOL webViewCloseEventDisabled;
@property (nonatomic,assign)BOOL appCloseEventHandled;
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

	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"componentStatusUpdate" object:nil];
}



- (instancetype)initWithwidget:(WWidget *)widget{
    self = [super init];
    if (self) {
        _widget = widget;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHideEnterStatus:) name:@"componentStatusUpdate" object:nil];
        _mFlag = 0;
        _mamList = [[NSMutableArray alloc] initWithCapacity:1];
        _meBrwMainFrm = [[EBrowserMainFrame alloc]initWithFrame:[BUtility getApplicationInitFrame] BrwCtrler:self];
        _meBrw = [[EBrowser alloc] init];
        _meBrw.meBrwCtrler = self;
        _meBrwMainFrm.meBrwWgtContainer = [[EBrowserWidgetContainer alloc] initWithFrame:_meBrwMainFrm.bounds browserController:self widget:widget];
        [_meBrwMainFrm insertSubview:_meBrwMainFrm.meBrwWgtContainer atIndex:0];
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




#pragma mark - UPdateWgtHtml

- (void)doUpdateWgt {
    
    BOOL isNeedCopy = ACEWidgetUpdateUtility.isWidgetCopyNeeded;
    BOOL isCopyFinish = ACEWidgetUpdateUtility.isWidgetCopyFinished;
    
    /* 
     * 1.IDE 2.document存在widget
     * 保证IDE首次启动读取document下的widget包.
     */
    
    BOOL appCanDevMode = [BUtility getAppCanDevMode];

    
    
    if (appCanDevMode && [ACEConfigXML isWidgetConfigXMLAvailable]) {
        ACEWidgetUpdateUtility.isWidgetCopyFinished = YES;
        isCopyFinish = YES;
        isNeedCopy = NO;
    }
    if (isNeedCopy || !isCopyFinish) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = nil;
            BOOL isCopyFinish = [ACEWidgetUpdateUtility copyMainWidgetToDocumentWithError:&error];
            ACEWidgetUpdateUtility.isWidgetCopyFinished = isCopyFinish;
            if (!isCopyFinish) {
                ACLogError(@"copy widget to documents failed: %@",error.localizedDescription);
                return;
            }
            [ACEConfigXML updateWidgetConfigXML];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AppCanWgtCopyFinishedNotification" object:nil];
            });
        });
        
    }else{
        if ([ACEWidgetUpdateUtility isMainWidgetNeedPatchUpdate]) {
            ACEWidgetUpdateResult result = [ACEWidgetUpdateUtility installMainWidgetPatch];
            if (result == ACEWidgetUpdateResultSuccess) {
                self.widget = self.mwWgtMgr.mainWidget;
            }
            
        }
    }
    
    
    
    
}




static BOOL userCustomLoadingImageEnabled = NO;



- (void)presentStartImage{
    
    if (![[UIApplication sharedApplication].delegate isKindOfClass:[WidgetOneDelegate class]]) {
        return;
    }
    
    
    self.startImageClosed = NO;
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
            userCustomLoadingImagePath = [[WWidgetMgr sharedManager].mainWidget.absResourcePath stringByAppendingPathComponent:userCustomLoadingImagePath];
        }
        if ([userCustomLoadingImagePath hasPrefix:F_APP_PATH]) {
            userCustomLoadingImagePath = [userCustomLoadingImagePath substringFromIndex:F_APP_PATH.length];
            userCustomLoadingImagePath = [[WWidgetMgr sharedManager].mainWidget.absWidgetPath stringByAppendingPathComponent:userCustomLoadingImagePath];
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
        
        //JAYTAG-自定义启动图，用户传入的图片比较少，分辨率不全，需要进行缩放和截取，不拉伸。
        //if (iPhoneX) {
        self.mStartView.clipsToBounds = YES;
        self.mStartView.contentMode =  UIViewContentModeScaleAspectFill;
        //}
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
            } else if (iPhoneX) {
                launchImageName = [NSString stringWithFormat:@"%@-800-Portrait-812h@3x", launchImagePrefixFile];
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



    if (self.startImageClosed) {
        return;
    }
    switch (event) {
        case ACELoadingImageCloseEventWebViewFinishLoading: {
            if (self.webViewCloseEventHandled) {
                break;
            }
            self.webViewCloseEventHandled = YES;
            if (!userCustomLoadingImageEnabled){
                [self closeLoadingImage];
                self.startImageClosed = YES;
            }
            
            break;
        }
        case ACELoadingImageCloseEventCustomLoadingTimeout: {
            if (!userCustomLoadingImageEnabled) {
                break;
            }
            userCustomLoadingImageEnabled = NO;
            if ((self.webViewCloseEventDisabled && self.appCloseEventHandled)  || (!self.webViewCloseEventDisabled && self.webViewCloseEventHandled)) {
                [self closeLoadingImage];
                self.startImageClosed = YES;
            }
            break;
        }
        case ACELoadingImageCloseEventAppLoadingTimeout: {
            self.webViewCloseEventDisabled = YES;
            self.appCloseEventHandled = YES;
            if (!userCustomLoadingImageEnabled) {
                [self closeLoadingImage];
                self.startImageClosed = YES;
            }
            break;
        }
    }
}

- (void)closeLoadingImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.meBrwMainFrm.hidden = NO;
        
        static NSString *const kACELaunchImageFadingDurationInfoPlistKey = @"ACELaunchImageFading";
        NSTimeInterval duration = numberArg([[NSBundle mainBundle] infoDictionary][kACELaunchImageFadingDurationInfoPlistKey]).doubleValue / 1000;
        
        void (^removal)() = ^{
            [self.mStartView removeFromSuperview];
            self.mStartView = nil;
        };
        
        
        if ( duration > 0) {
            [UIView animateWithDuration:duration animations:^{
                self.mStartView.alpha = 0;
            } completion:^(BOOL finished) {
                removal();
            }];
        }else{
            removal();
        }
        
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

-(void)setExtraInfo:(NSDictionary *)extraDic toEBrowserView:(EBrowserView *)inBrwView{
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

#pragma mark - doUpdateWgt进入线程操作
- (void)doUpdateWgtBlockFinish:(void(^)(BOOL isFinished))handle
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isFinished = NO;
        [self doUpdateWgt];
        isFinished = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            handle(isFinished);
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.meBrwMainFrm];
    
    if (self.isAppCanRootViewController) {
        
        [self presentStartImage];
        
        if (AppCanEngine.configuration.useUpdateWgtHtmlControl) {
            [self doUpdateWgtBlockFinish:^(BOOL isFinished) {
                [self workAfterDoUpdateWgtBlock];
            }];
        } else {
            [self workAfterDoUpdateWgtBlock];
        }
    }
}

#pragma mark - viewDidLoad中的doUpdateWgtBlockFinish执行完之后进行的操作
- (void)workAfterDoUpdateWgtBlock
{
    [self.meBrw start:self.widget];
    
    NSDictionary * extraDic = [BUtility getMainWidgetConfigWindowBackground];
    [self setExtraInfo:extraDic toEBrowserView:self.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView];
    
    if (self.isAppCanRootViewController) {
        if ([BUtility getAppCanDevMode]) {
            [ACEAnalysisObject() ac_invoke:@"setErrorReport:" arguments:ACArgsPack(@(YES))];
        }
        NSString * inKey = [BUtility appKey];
        if (AppCanEngine.configuration.userStartReport) {
            Class analysisClass = NSClassFromString(@"EUExDataAnalysis");
            if (analysisClass) {
                NSMutableArray * array = [NSMutableArray arrayWithObjects:inKey,self.mwWgtMgr,self,nil];
                id analysisObject = [[analysisClass alloc] init];
                [analysisObject ac_invoke:@"startEveryReport:" arguments:ACArgsPack(array)];
                
            }
        }
        if (AppCanEngine.configuration.userStartReport) {
            static id emmDataAnalysisObj = nil;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                Class analysisClass = NSClassFromString(@"UexEMMDataAnalysis");
                if (analysisClass) {
                    emmDataAnalysisObj = [[analysisClass alloc] init];
                }
            });
            NSMutableArray * array = [NSMutableArray arrayWithObjects:inKey,self.mwWgtMgr,self,nil];
            [emmDataAnalysisObj ac_invoke:@"startEveryReport:" arguments:ACArgsPack(array)];
            
        }
        if ((AppCanEngine.configuration.useUpdateControl || AppCanEngine.configuration.useUpdateWgtHtmlControl) && ![BUtility isSimulator]) {//添加升级
            NSMutableArray * dataArray = [NSMutableArray arrayWithObjects:self.mwWgtMgr.mainWidget.appId,inKey,self.mwWgtMgr.mainWidget.ver,@"",nil];////0:appid 1:appKey2:currentVer 3:更新地址  url
            Class  updateClass = NSClassFromString(@"EUExUpdate");
            if (!updateClass) {
                return;
            }
            self.updateObj = [[updateClass alloc] init];
            [self.updateObj ac_invoke:@"doUpdate:" arguments:ACArgsPack(dataArray)];
        }
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

        [[self aboveWindow].meBrwView callbackWithFunctionKeyPath:@"uexDevice.onOrientationChange" arguments:ACArgsPack(@(nowOrientation))];


	}
}


- (EBrowserWindow *)rootWindow{
    return self.rootWindowContainer.meRootBrwWnd;
}
- (EBrowserWindow *)aboveWindow{
    return self.brwWidgetContainer.aboveWindowContainer.aboveWindow;
}
- (EBrowserWindowContainer *)rootWindowContainer{
    return self.brwWidgetContainer.meRootBrwWndContainer;
}
- (EBrowserView *)rootView{
    return self.rootWindow.meBrwView;
}

@end
