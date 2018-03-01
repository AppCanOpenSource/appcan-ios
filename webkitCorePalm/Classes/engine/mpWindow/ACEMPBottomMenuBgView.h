//
//  ACEMPBottomMenuBgView.h
//  DropdownMenu
//
//  Created by Jay on 2018/1/24.
//  Copyright © 2018年 iOS开发者公会. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEDropdownMenu.h"
#import "ACEMPWindowOptions.h"
#import "EBrowserView.h"

@interface ACEMPBottomMenuBgView : UIView

@property (nonatomic, strong) UIButton *keyboardBtn;

@property (nonatomic, weak) EBrowserView *meBrwView;

@property (nonatomic, strong) ACEMPWindowOptions *windowOptions;
@property (nonatomic, assign) CGRect recordFrame;

- (instancetype)initWithFrame:(CGRect)frame windowOptions:(ACEMPWindowOptions *)windowOptions meBrwView:(EBrowserView *)meBrwView;

- (void)setSubViewWithWindowOptions:(ACEMPWindowOptions *)windowOptions;

- (void)aceShow:(BOOL)isAnimation;
- (void)aceHiden:(BOOL)isAnimation;

@end
