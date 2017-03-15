//
//  AppCanEnginePrivate.h
//  AppCanEngine
//
//  Created by CeriNo on 2017/1/10.
//
//

#ifndef AppCanEnginePrivate_h
#define AppCanEnginePrivate_h
#import <AppCanEngine/AppCanEngine.h>

@class EBrowserController;



APPCAN_EXPORT NSNotificationName const AppCanEngineRestartNotification;



@protocol WidgetOneProperties <NSObject>

@property (nonatomic, readonly) NSString *documentWidgetPath;

@property (nonatomic, assign) BOOL userStartReport;
@property (nonatomic, assign) BOOL useEmmControl;
@property (nonatomic, assign) BOOL useOpenControl;
@property (nonatomic, assign) BOOL useUpdateControl;
@property (nonatomic, assign) BOOL useOnlineArgsControl;
@property (nonatomic, assign) BOOL usePushControl;
@property (nonatomic, assign) BOOL useDataStatisticsControl;
@property (nonatomic, assign) BOOL useAuthorsizeIDControl;
@property (nonatomic, assign) BOOL useCloseAppWithJaibroken;
@property (nonatomic, assign) BOOL useRC4EncryptWithLocalstorage;
@property (nonatomic, assign) BOOL useUpdateWgtHtmlControl;
@property (nonatomic, assign) BOOL signVerifyControl;
@property (nonatomic, assign) BOOL useCertificateControl;
@property (nonatomic, assign) BOOL useIsHiddenStatusBarControl;
@property (nonatomic, assign) BOOL useEraseAppDataControl;
@property (nonatomic, strong) NSString *useStartReportURL;
@property (nonatomic, strong) NSString *useAnalysisDataURL;
@property (nonatomic, strong) NSString *useBindUserPushURL;
@property (nonatomic, strong) NSString *useAppCanMAMURL;
@property (nonatomic, strong) NSString *useAppCanMCMURL;
@property (nonatomic, strong) NSString *useAppCanMDMURL;
@property (nonatomic, strong) NSString *useCertificatePassWord;
@property (nonatomic, strong) NSString *useAppCanUpdateURL;
@property (nonatomic, assign) BOOL useAppCanMDMURLControl;
@property (nonatomic, assign) BOOL useInAppCanIDE;
//4.0
@property (nonatomic, strong) NSString *useAppCanEMMTenantID;//EMM单租户场景下默认的租户ID
@property (nonatomic, strong) NSString *useAppCanAppStoreHost;//uexAppstroeMgr所需的host
@property (nonatomic, strong) NSString *useAppCanMBaaSHost;//引擎中MBaaS读取的host
@property (nonatomic, strong) NSString *useAppCanIMXMPPHost;//uexIM插件XMPP通道使用的host
@property (nonatomic, strong) NSString *useAppCanIMHTTPHost;//uexIM插件HTTP通道使用的host
@property (nonatomic, strong) NSString *useAppCanTaskSubmitSSOHost;//uexTaskSubmit登陆所需host
@property (nonatomic, strong) NSString *useAppCanTaskSubmitHost;//uexTaskSubmit提交任务所需host
@property (nonatomic, assign) BOOL validatesSecureCertificate;//是否校验证书
@end

@interface AppCanEngine()
@property (nonatomic,readonly,class)id<AppCanEngineConfiguration,WidgetOneProperties> configuration;
@property (nonatomic,readonly,class)EBrowserController *rootWebViewController;


+ (void)rootPageDidFinishLoading;
+ (void)restart;
@end


#endif /* AppCanEnginePrivate_h */
