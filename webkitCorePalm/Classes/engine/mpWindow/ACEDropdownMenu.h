//
//  ACEDropdownMenu.h
//
//  Version:1.0.0
//
//  Created by Jay on 15/5/4.
//  Copyright (c) 2015年 iOS开发者公会. All rights reserved.

#import <UIKit/UIKit.h>
#import "EBrowserView.h"
#import "BUtility.h"

#define SINGLE_LINE_WIDTH (1 / [UIScreen mainScreen].scale)

@class ACEDropdownMenu;




@protocol ACEDropdownMenuDelegate <NSObject>

@optional

- (void)dropdownMenu:(ACEDropdownMenu *)menu selectedCellNumber:(NSInteger)number; // 当选择某个选项时调用
- (void)dropdownMenuDidTouchMainBtn:(ACEDropdownMenu *)menu;   // 当不存在下拉菜单时，点击mainBtn要给回调

@end




@interface ACEDropdownMenu : UIView <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UIButton * mainBtn;  // 主按钮 可以自定义样式 可在.m文件中修改默认的一些属性
@property (nonatomic,assign) BOOL isShowTableView; //是否需要下拉菜单，如果需要就会在mainBtn上加一个折叠图标
@property (nonatomic,strong) NSDictionary *listDic;

@property (nonatomic,strong) UIImageView *smallIV;

@property (nonatomic,strong) UIView *listView;    // 下拉列表背景View
@property (nonatomic,strong) UITableView *tableView;   // 下拉列表


@property (nonatomic,assign) int recordIndex;



@property (nonatomic, weak) EBrowserView *meBrwView;



@property (nonatomic, assign) id <ACEDropdownMenuDelegate>delegate;


- (void)setMenuTitles:(NSArray *)titlesArr rowHeight:(CGFloat)rowHeight;  // 设置下拉菜单控件样式
- (void)setMainBtnTitle:(NSString *)title; //设置按钮标题

- (void)showDropDown; // 显示下拉菜单
- (void)hideDropDown; // 隐藏下拉菜单

@end
