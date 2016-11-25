//
//  AppCanWindowObject.h
//  AppCanKit
//
//  Created by CeriNo on 2016/11/3.
//  Copyright © 2016年 AppCan. All rights reserved.
//



#import <Foundation/Foundation.h>
#ifndef AppCanWindowObject_h
#define AppCanWindowObject_h


NS_ASSUME_NONNULL_BEGIN
@protocol AppCanScrollViewEventProducer <NSObject>

- (void)addScrollViewEventObserver:(id<UIScrollViewDelegate>)observer;
- (void)removeScrollViewEventObserver:(id<UIScrollViewDelegate>)observer;

@end

@protocol AppCanWindowObject <NSObject>

- (nullable __kindof UIScrollView<AppCanScrollViewEventProducer> *)multiPopoverForName:(NSString *)multiPopoverName;
- (nullable __kindof UIScrollView<AppCanScrollViewEventProducer> *)pluginViewContainerForName:(NSString *)containerName;
- (BOOL)addSubView:(UIView *)view toPluginViewContainerWithName:(NSString *)containerName atIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END

#endif /* AppCanWindowObject_h */
