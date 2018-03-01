//
//  ACEMPWindowOptions.h
//  DropdownMenu
//
//  Created by Jay on 2018/1/25.
//  Copyright © 2018年 iOS开发者公会. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EUExWidget.h"

@interface ACEMPWindowOptions : NSObject

@property (nonatomic, copy) NSString *windowTitle;
@property (nonatomic, assign) BOOL isBottomBarShow;
@property (nonatomic, copy) NSString *titleBarBgColor;
@property (nonatomic, copy) NSString *titleLeftIcon;
@property (nonatomic, copy) NSString *titleRightIcon;
@property (nonatomic, retain) NSArray *menuList;

@property (nonatomic, assign) int flag;
@property (nonatomic, strong) NSDictionary *extras;
@property (nonatomic, assign) int windowStyle;

@property (nonatomic,weak) EUExWidget *uexWidget;

@end
