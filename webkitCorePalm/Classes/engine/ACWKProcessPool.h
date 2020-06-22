//
//  ACWKProcessPool.h
//  AppCanEngine
//  WKProcessPool的单例，用于使所有的WKWebView实例共享同一个localStorage等
//
//  Created by ZhangYipeng on 2020/6/22.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACWKProcessPool : WKProcessPool

/**
 获取WKProcessPool的单例
 */
+ (instancetype)sharedWKProcessPool;

@end

NS_ASSUME_NONNULL_END
