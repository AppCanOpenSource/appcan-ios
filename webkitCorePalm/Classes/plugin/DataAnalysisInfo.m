//
//  DataAnalysisInfo.m
//  AppCanEngine
//
//  Created by cuiguoshuai on 15/9/24.
//
//

#import "DataAnalysisInfo.h"


id ACEAnalysisObject(){
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class analysisClass = NSClassFromString(@"UexDataAnalysisAppCanAnalysis") ?: NSClassFromString(@"AppCanAnalysis");
        if (!analysisClass) {
            return;
        }
        obj = [[analysisClass alloc] init];
    });
    return obj;
}

/**
 用于子应用启动时传递事件给uexEMM插件的对象

 */
id ACEEMMObject(){
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class emmClass = NSClassFromString(@"UexEMMAppCanAnalysis");
        if (!emmClass) {
            return;
        }
        obj = [[emmClass alloc] init];
    });
    return obj;
}

@implementation DataAnalysisInfo
+ (NSDictionary *)getAppInfoWithCurWgt:(WWidget *)curWgt{

    NSString * appId = curWgt.appId?curWgt.appId:@"";
    NSString * appVersion = curWgt.ver?curWgt.ver:@"";
    NSString * appChannel = curWgt.channelCode?curWgt.channelCode:@"";
    
    NSDictionary * appInfo = [NSDictionary dictionaryWithObjectsAndKeys:appId,@"appId",appVersion,@"appVersion",appChannel,@"appChannel", nil];
    
    return appInfo;
}
@end
