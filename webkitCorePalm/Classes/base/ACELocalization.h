//
//  ACELocalization.h
//  AppCanEngine
//
//  Created by CeriNo on 15/9/28.
//
//

#import <Foundation/Foundation.h>

#define ACELocalized(...)   \
[ACELocalization localizedString:__VA_ARGS__,nil]





@interface ACELocalization : NSObject



+(NSString*)localizedString:(NSString *)key, ...;




@end

