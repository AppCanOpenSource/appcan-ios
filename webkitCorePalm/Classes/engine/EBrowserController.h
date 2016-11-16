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

@class EBrowserMainFrame;
@class EBrowserWidgetContainer;
@class EBrowser;
@class WWidgetMgr;
@class WWidget;
@class BallView;
@class WWidgetUpdate;
@class ACEUINavigationController;


#define F_EBRW_CTRL_FLAG_FORBID_ROTATE		0x1
#define F_NEED_REPORT_APP_START             0x2






APPCAN_EXPORT NSString *const kACECustomLoadingImagePathKey;
APPCAN_EXPORT NSString *const kACECustomLoadingImageTimeKey;

typedef NS_ENUM(NSInteger,ACELoadingImageCloseEvent){
    ACELoadingImageCloseEventWebViewFinishLoading,//网页加载完成的事件(用户手动closeLoading或者网页加载完成后0.5s)
    ACELoadingImageCloseEventCustomLoadingTimeout,//自定义启动图timer时间到的事件
    ACELoadingImageCloseEventAppLoadingTimeout//默认的APP加载时间到的事件(3s)
};

@interface EBrowserController : ACEBaseViewController <UIAccelerometerDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) UIImageView *mStartView;
@property (nonatomic, strong) EBrowserMainFrame *meBrwMainFrm;
@property (nonatomic, strong) EBrowser *meBrw;
@property (nonatomic, strong) WWidgetMgr *mwWgtMgr;
@property (nonatomic, assign) BOOL ballHasShow;
@property (nonatomic, assign) int mFlag;
@property (nonatomic, strong) BallView *ballView;


@property (nonatomic, weak) ACEUINavigationController *aceNaviController;



- (EBrowserWidgetContainer*)brwWidgetContainer;


- (void)handleLoadingImageCloseEvent:(ACELoadingImageCloseEvent)event;

@end

