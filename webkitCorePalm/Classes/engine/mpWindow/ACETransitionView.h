//
//  ACETransitionView.h
//  AppCanEngine
//
//  Created by Jay on 2018/5/15.
//

#import <UIKit/UIKit.h>
#import "EBrowserView.h"
#import "BUtility.h"
#import "WWidget.h"

@interface ACETransitionView : UIView

@property (nonatomic, strong) UIImageView *iconIv;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *pointArr;
@property (nonatomic, assign) int pointAnimationCount;
@property (nonatomic, strong) UIImage *brownImg;
@property (nonatomic, strong) UIImage *blackImg;

@property (nonatomic, weak) EBrowserView *meBrwView;

@property (nonatomic, weak) WWidget *wgtObj;

- (id)initWithFrame:(CGRect)frame WWidget:(WWidget *)wgtObj meBrwView:(EBrowserView *)meBrwView;

@end
