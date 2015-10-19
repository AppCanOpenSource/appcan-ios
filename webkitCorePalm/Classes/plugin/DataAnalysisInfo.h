//
//  DataAnalysisInfo.h
//  AppCanEngine
//
//  Created by cuiguoshuai on 15/9/24.
//
//

#import <Foundation/Foundation.h>
#import "WWidget.h"

@interface DataAnalysisInfo : NSObject

+ (NSDictionary *)getAppInfoWithCurWgt:(WWidget *)mwWgt;

@end
