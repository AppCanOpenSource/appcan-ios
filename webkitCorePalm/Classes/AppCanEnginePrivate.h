//
//  AppCanEnginePrivate.h
//  AppCanEngine
//
//  Created by CeriNo on 2017/1/10.
//
//

#ifndef AppCanEnginePrivate_h
#define AppCanEnginePrivate_h
#import "AppCanEngine.h"
@class EBrowserController;


@interface AppCanEngine()
@property (nonatomic,readonly,class)id<AppCanEngineConfiguration> configuration;
@property (nonatomic,readonly,class)EBrowserController *rootWebViewController;


+ (void)rootPageDidFinishLoading;
@end


#endif /* AppCanEnginePrivate_h */
