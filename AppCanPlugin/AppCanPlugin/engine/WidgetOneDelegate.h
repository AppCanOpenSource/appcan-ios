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



@class EBrowserController;
@class EBrowser;
@class WWidgetMgr;
@class PluginParser;
@class ACEWebViewController;
@class ACEDrawerViewController;

@interface WidgetOneDelegate: NSObject <UIApplicationDelegate,UIAlertViewDelegate> {
	UIWindow *mWindow;
	EBrowserController *meBrwCtrler;
	WWidgetMgr *mwWgtMgr;
	PluginParser *pluginObj;
}
@property (nonatomic, retain) UIWindow *mWindow;
@property (nonatomic, assign) EBrowserController *meBrwCtrler;
@property (nonatomic, assign) WWidgetMgr *mwWgtMgr;
@property (nonatomic) BOOL userStartReport;
@property (nonatomic) BOOL useEmmControl;
@property (nonatomic) BOOL useOpenControl;
@property (nonatomic) BOOL useUpdateControl;
@property (nonatomic) BOOL useOnlineArgsControl;
@property (nonatomic) BOOL usePushControl;
@property (nonatomic) BOOL useDataStatisticsControl;
@property (nonatomic) BOOL useAuthorsizeIDControl;
@property (nonatomic) BOOL useCloseAppWithJaibroken;
@property (nonatomic) BOOL useRC4EncryptWithLocalstorage;
@property (nonatomic) BOOL useUpdateWgtHtmlControl;
@property (nonatomic) BOOL useCertificateControl;
@property (nonatomic) BOOL useIsHiddenStatusBarControl;
@property (nonatomic,readonly) BOOL useEraseAppDataControl;
@property(nonatomic,copy)NSString *useStartReportURL;
@property(nonatomic,copy)NSString *useAnalysisDataURL;
@property(nonatomic,copy)NSString *useBindUserPushURL;
@property(nonatomic,copy)NSString *useAppCanMAMURL;
@property(nonatomic,copy)NSString *useAppCanMCMURL;
@property(nonatomic,copy)NSString *useAppCanMDMURL;
@property(nonatomic,copy)NSString *useCertificatePassWord;
@property(nonatomic,copy)NSString *useAppCanUpdateURL;
@property(nonatomic)BOOL useAppCanMDMURLControl;
@property (nonatomic, retain) NSMutableDictionary *thirdInfoDict;

@property (nonatomic, retain) ACEWebViewController *leftWebController;
@property (nonatomic, retain) ACEWebViewController *rightWebController;
@property (nonatomic, retain) ACEDrawerViewController *drawerController;
@property (nonatomic, assign) NSInteger enctryptcj;
@property (nonatomic, retain) NSMutableDictionary *globalPluginDict;


//-(NSString *)getPayPublicRsaKey;

@end

#define theApp ((WidgetOneDelegate *)[[UIApplication sharedApplication] delegate])
