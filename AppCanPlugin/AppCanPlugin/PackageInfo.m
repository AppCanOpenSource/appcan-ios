//
//  PackageInfo.m
//  AppCanPlugin
//
//  Created by Cerino on 15/7/24.
//  Copyright (c) 2015年 zywx. All rights reserved.
//

#import "PackageInfo.h"

@implementation PackageInfo
static NSString * bundleIdentifier = @"com.zywx.appcan";
+ (NSString *)getBundleIdentifier {
    
    if (!bundleIdentifier) {
        
        return @"";
        
    }
    
    return bundleIdentifier;
    
}
@end
