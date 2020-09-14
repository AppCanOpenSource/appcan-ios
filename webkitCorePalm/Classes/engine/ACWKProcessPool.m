//
//  ACWKProcessPool.m
//  AppCanEngine
//
//  Created by ZhangYipeng on 2020/6/22.
//

#import "ACWKProcessPool.h"

@interface ACWKProcessPool()<NSCopying,NSMutableCopying>

@end

@implementation ACWKProcessPool

static ACWKProcessPool* __processPool;

+ (instancetype)sharedWKProcessPool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __processPool = [[self alloc] init];
    });
    return __processPool;
}

// 如果仅通过allocWithZone方法来控制单例的生成，在WKWebView中localStorage依然无法实时更新，原因未知。故注释后采用了init中控制。
//+ (instancetype)allocWithZone:(struct _NSZone *)zone{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        __processPool = [super allocWithZone:zone];
//    });
//    return __processPool;
//}

- (id)copyWithZone:(struct _NSZone *)zone{
    return __processPool;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return __processPool;
}


@end
