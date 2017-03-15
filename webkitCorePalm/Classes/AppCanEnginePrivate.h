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





@interface AppCanEngine()

@property (nonatomic,readonly,class)EBrowserController *rootWebViewController;


+ (void)rootPageDidFinishLoading;
+ (void)restart;
@end


#endif /* AppCanEnginePrivate_h */
