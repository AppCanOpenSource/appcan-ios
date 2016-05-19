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

#import "ACEBaseViewController.h"
#import "ACEUtils.h"
@class EBrowserMainFrame;
@class EBrowserWidgetContainer;
@class EBrowser;
@class WWidgetMgr;
@class WWidget;
@class BallView;
@class WWidgetUpdate;
#define F_STARTIMG_WIDTH_HEIGHT  480

#define F_EBRW_CTRL_FLAG_FORBID_ROTATE		0x1
#define F_NEED_REPORT_APP_START             0x2
#define F_EBRW_CTRL_FLAG_AUTH_SUCCESSED     0x4


#define F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT				1
#define F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT			2
#define F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN	4
#define F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT		8
//4.8
#define F_ForbidPlugins    @"AppCanPluginsKey"
#define F_ForbidWindows    @"AppCanWindowsKey"
#define F_AuthType         @"AppCanAuthType"

ACE_EXTERN NSString *const kACECustomLoadingImagePathKey;
ACE_EXTERN NSString *const kACECustomLoadingImageTimeKey;

typedef NS_ENUM(NSInteger,ACELoadingImageCloseEvent){
    ACELoadingImageCloseEventWebViewFinishLoading,//网页加载完成的事件(用户手动closeLoading或者网页加载完成后0.5s)
    ACELoadingImageCloseEventCustomLoadingTimeout,//自定义启动图timer时间到的事件
    ACELoadingImageCloseEventAppLoadingTimeout//默认的APP加载时间到的事件(3s)
};

@interface EBrowserController : ACEBaseViewController <UIAccelerometerDelegate,UIAlertViewDelegate>{
	UIImageView *mStartView;
	EBrowser *meBrw;
	EBrowserMainFrame *meBrwMainFrm;
	WWidgetMgr *mwWgtMgr;
	NSLock *mSplashLock;
	BallView *ballView;
	int mFlag;
	BOOL ballHasShow; 
    NSMutableArray *mamList;
    WWidgetUpdate *mwWgtUpdate;
    //
    int wgtOrientation;
}
@property (nonatomic, retain) UIImageView *mStartView;
@property (nonatomic, retain) EBrowserMainFrame *meBrwMainFrm;
@property (nonatomic, retain) EBrowser *meBrw;
@property (nonatomic, retain) WWidgetMgr *mwWgtMgr;
@property (nonatomic, assign) BOOL ballHasShow;
@property (nonatomic, assign) int mFlag;
@property (nonatomic,retain)NSMutableArray *forebidPluginsList;
@property (nonatomic,retain)NSMutableArray *forebidWinsList;
@property (nonatomic,retain)NSMutableArray *forebidPopWinsList;
@property(nonatomic,assign)int wgtOrientation;
- (EBrowserWidgetContainer*)brwWidgetContainer;


- (void)handleLoadingImageCloseEvent:(ACELoadingImageCloseEvent)event;

@end

