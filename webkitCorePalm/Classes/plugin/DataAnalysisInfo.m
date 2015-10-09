//
//  DataAnalysisInfo.m
//  AppCanEngine
//
//  Created by cuiguoshuai on 15/9/24.
//
//

#import "DataAnalysisInfo.h"

@implementation DataAnalysisInfo
+ (NSDictionary *)getAppInfoWithCurWgt:(WWidget *)curWgt{

    NSString * appId = curWgt.appId?curWgt.appId:@"";
    NSString * appVersion = curWgt.ver?curWgt.ver:@"";
    NSString * appChannel = curWgt.channelCode?curWgt.channelCode:@"";
    
    NSDictionary * appInfo = [NSDictionary dictionaryWithObjectsAndKeys:appId,@"appId",appVersion,@"appVersion",appChannel,@"appChannel", nil];
    
    return appInfo;
}
@end
