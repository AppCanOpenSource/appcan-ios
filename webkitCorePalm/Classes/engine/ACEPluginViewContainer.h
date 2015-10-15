//
//  ACEPluginViewContainer.h
//  AppCanEngine
//
//  Created by xrg on 15/7/16.
//
//

#import <UIKit/UIKit.h>
@class EUExWindow;

@interface ACEPluginViewContainer : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, copy) NSString * containerIdentifier;

@property (nonatomic, assign) NSInteger maxIndex;

@property (nonatomic, assign) EUExWindow * uexObj;

@property (nonatomic, assign) NSInteger lastIndex;

@end
