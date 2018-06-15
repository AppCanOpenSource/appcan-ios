//
//  ACEMPTopView.h
//  DropdownMenu
//
//  Created by Jay on 2018/1/29.
//  Copyright © 2018年 iOS开发者公会. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACEMPWindowOptions.h"
#import "EBrowserView.h"

@interface ACEMPTopView : UIView

@property (nonatomic, weak) EBrowserView *meBrwView;

@property (nonatomic, strong) ACEMPWindowOptions *windowOptions;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UIButton *closeBtn;

- (id)initWithFrame:(CGRect)frame WindowOptions:(ACEMPWindowOptions *)windowOption meBrwView:(EBrowserView *)meBrwView;

- (void)resetWindowOptions:(ACEMPWindowOptions *)windowOptions;

@end
