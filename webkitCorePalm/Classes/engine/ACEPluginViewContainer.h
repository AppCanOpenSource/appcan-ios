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

@property (nonatomic, strong) NSString * containerIdentifier;
@property (nonatomic, assign) NSInteger maxIndex;
@property (nonatomic, weak) EUExWindow * uexObj;
@property (nonatomic, assign) NSInteger lastIndex;

@end
