//
//  ACEDropdownMenu.m
//
//  Version:1.0.0
//
//  Created by Jay on 15/5/4.
//  Copyright (c) 2015年 iOS开发者公会. All rights reserved.

#import "ACEDropdownMenu.h"

#define PIANYI_TABLEVIEW_iPhoneX 88.0
#define PIANYI_TABLEVIEW_NORMAL 64.0

#define VIEW_CENTER(aView)       ((aView).center)
#define VIEW_CENTER_X(aView)     ((aView).center.x)
#define VIEW_CENTER_Y(aView)     ((aView).center.y)

#define FRAME_ORIGIN(aFrame)     ((aFrame).origin)
#define FRAME_X(aFrame)          ((aFrame).origin.x)
#define FRAME_Y(aFrame)          ((aFrame).origin.y)

#define FRAME_SIZE(aFrame)       ((aFrame).size)
#define FRAME_HEIGHT(aFrame)     ((aFrame).size.height)
#define FRAME_WIDTH(aFrame)      ((aFrame).size.width)



#define VIEW_BOUNDS(aView)       ((aView).bounds)

#define VIEW_FRAME(aView)        ((aView).frame)

#define VIEW_ORIGIN(aView)       ((aView).frame.origin)
#define VIEW_X(aView)            ((aView).frame.origin.x)
#define VIEW_Y(aView)            ((aView).frame.origin.y)

#define VIEW_SIZE(aView)         ((aView).frame.size)
#define VIEW_HEIGHT(aView)       ((aView).frame.size.height)
#define VIEW_WIDTH(aView)        ((aView).frame.size.width)


#define VIEW_X_Right(aView)      ((aView).frame.origin.x + (aView).frame.size.width)
#define VIEW_Y_Bottom(aView)     ((aView).frame.origin.y + (aView).frame.size.height)






#define AnimateTime 0.25f   // 下拉动画时间



@implementation ACEDropdownMenu
{
    UIImageView * _arrowMark;   // 尖头图标
    UITableView * _tableView;   // 下拉列表
    
    NSArray     * _titleArr;    // 选项数组
    CGFloat       _rowHeight;   // 下拉列表行高
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createMainBtnWithFrame:frame];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];

    [self createMainBtnWithFrame:frame];
}


- (void)createMainBtnWithFrame:(CGRect)frame{
    
    [_mainBtn removeFromSuperview];
    _mainBtn = nil;
    
    // 主按钮 显示在界面上的点击按钮
    // 样式可以自定义
    _mainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_mainBtn setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [_mainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_mainBtn setTitle:@"" forState:UIControlStateNormal];
    [_mainBtn addTarget:self action:@selector(clickMainBtn:) forControlEvents:UIControlEventTouchUpInside];
    _mainBtn.titleLabel.font    = [UIFont systemFontOfSize:13.f];
    
//    if (self.isShowTableView == YES) {
//        _mainBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//        _mainBtn.titleEdgeInsets    = UIEdgeInsetsMake(0, 15, 0, 0);
//    }
    
    _mainBtn.selected           = NO;
    _mainBtn.backgroundColor    = [UIColor whiteColor];
    _mainBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    _mainBtn.layer.borderWidth  = SINGLE_LINE_WIDTH;

    [self addSubview:_mainBtn];
    
    if (self.isShowTableView) {
        [self createArrowMark];
    }
}

- (void)createArrowMark
{
    _smallIV = [[UIImageView alloc] initWithFrame:CGRectMake(_mainBtn.frame.size.width-11, _mainBtn.frame.size.height-11, 10, 10)];
    _smallIV.backgroundColor = [UIColor clearColor];
    _smallIV.image  = [UIImage imageNamed:@"img/acemp/platform_mp_window_icon_black_three.png"];
    [_mainBtn addSubview:_smallIV];
    
//    // 旋转尖头
//    _arrowMark = [[UIImageView alloc] initWithFrame:CGRectMake(_mainBtn.frame.size.width - 15, 0, 9, 9)];
//    _arrowMark.center = CGPointMake(VIEW_CENTER_X(_arrowMark), VIEW_HEIGHT(_mainBtn)/2);
//    _arrowMark.image  = [UIImage imageNamed:@"dropdownMenu_cornerIcon.png"];
//    _arrowMark.transform = CGAffineTransformMakeRotation(M_PI);
//    [_mainBtn addSubview:_arrowMark];
}

- (void)setMainBtnTitle:(NSString *)title
{
    if (self == nil) {
        return;
    }
    
    [_mainBtn setTitle:title forState:UIControlStateNormal];
}

- (void)setMenuTitles:(NSArray *)titlesArr rowHeight:(CGFloat)rowHeight{
    
    if (self == nil) {
        return;
    }
    
//    if (titlesArr.count == 0) {
//        return;
//    }
    
    _titleArr  = [NSArray arrayWithArray:titlesArr];
    _rowHeight = rowHeight;

    float pianyiNum = 0;
    if (iPhoneX) {
        pianyiNum = PIANYI_TABLEVIEW_iPhoneX;
    } else {
        pianyiNum = PIANYI_TABLEVIEW_NORMAL;
    }
    
    // 下拉列表背景View
    _listView = [[UIView alloc] init];
    _listView.frame = CGRectMake(VIEW_X(self) , VIEW_HEIGHT(_meBrwView)+pianyiNum, VIEW_WIDTH(self),  0);
    _listView.userInteractionEnabled = YES;
    _listView.clipsToBounds       = YES;
    _listView.layer.masksToBounds = NO;
    _listView.backgroundColor = [UIColor whiteColor];
    _listView.layer.borderColor   = [UIColor lightGrayColor].CGColor;
    _listView.layer.borderWidth   = SINGLE_LINE_WIDTH;
    [_meBrwView addSubview:_listView];

    
    // 下拉列表TableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView))];
    _tableView.delegate        = self;
    _tableView.dataSource      = self;
    _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    _tableView.bounces         = NO;
    [_listView addSubview:_tableView];
}

- (void)clickMainBtn:(UIButton *)button{
    
//    if (_listView) {
//        [self.superview addSubview:_listView]; // 将下拉视图添加到控件的俯视图上
//    }
    
    //[self.superview addSubview:_listView]; // 将下拉视图添加到控件的俯视图上
    
    if(button.selected == NO) {
        [self showDropDown];
    } else {
        [self hideDropDown];
    }
    
    if ([self.delegate respondsToSelector:@selector(dropdownMenuDidTouchMainBtn:)]) {
        [self.delegate dropdownMenuDidTouchMainBtn:self]; // 将要显示回调代理
    }
}

- (void)showDropDown{   // 显示下拉列表
    
//    if (!_listView) {
//        return;
//    }
    
    [_listView.superview bringSubviewToFront:_listView]; // 将下拉列表置于最上层
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
//        if (_arrowMark) {
//            _arrowMark.transform = CGAffineTransformIdentity;
//        }
        
        float pianyiNum = 0;
        if (iPhoneX) {
            pianyiNum = PIANYI_TABLEVIEW_iPhoneX;
        } else {
            pianyiNum = PIANYI_TABLEVIEW_NORMAL;
        }
        
        _listView.frame  = CGRectMake(VIEW_X(_listView), pianyiNum+VIEW_HEIGHT(_meBrwView)-_rowHeight*_titleArr.count, VIEW_WIDTH(_listView), _rowHeight*_titleArr.count);
        _tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
        
    }];
    
    _mainBtn.selected = YES;
}
- (void)hideDropDown{  // 隐藏下拉列表
    
//    if (!_listView) {
//        return;
//    }
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
//        if (_arrowMark) {
//            _arrowMark.transform = CGAffineTransformMakeRotation(M_PI);
//        }
        
        float pianyiNum = 0;
        if (iPhoneX) {
            pianyiNum = PIANYI_TABLEVIEW_iPhoneX;
        } else {
            pianyiNum = PIANYI_TABLEVIEW_NORMAL;
        }
        
        _listView.frame  = CGRectMake(VIEW_X(_listView), VIEW_HEIGHT(_meBrwView)+pianyiNum, VIEW_WIDTH(_listView), 0);
        _tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
        
    }];
    
    _mainBtn.selected = NO;
}

- (void)hideDropDownWithTableViewCellTouch:(NSIndexPath *)indexPath{  // 隐藏下拉列表
    
    //    if (!_listView) {
    //        return;
    //    }
    
    [UIView animateWithDuration:AnimateTime animations:^{
        
        //        if (_arrowMark) {
        //            _arrowMark.transform = CGAffineTransformMakeRotation(M_PI);
        //        }
        
        float pianyiNum = 0;
        if (iPhoneX) {
            pianyiNum = PIANYI_TABLEVIEW_iPhoneX;
        } else {
            pianyiNum = PIANYI_TABLEVIEW_NORMAL;
        }
        
        _listView.frame  = CGRectMake(VIEW_X(_listView), VIEW_HEIGHT(_meBrwView)+pianyiNum, VIEW_WIDTH(_listView), 0);
        _tableView.frame = CGRectMake(0, 0, VIEW_WIDTH(_listView), VIEW_HEIGHT(_listView));
        
    } completion:^(BOOL finished) {
        
        if ([self.delegate respondsToSelector:@selector(dropdownMenu:selectedCellNumber:)]) {
            [self.delegate dropdownMenu:self selectedCellNumber:indexPath.row]; // 回调代理
        }
    }];
    
    _mainBtn.selected = NO;
}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_titleArr count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ACEMPMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //---------------------------下拉选项样式，可在此处自定义-------------------------
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font          = [UIFont systemFontOfSize:13.f];
        cell.textLabel.textColor     = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle          = UITableViewCellSelectionStyleNone;
        
        UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, _rowHeight-SINGLE_LINE_WIDTH, VIEW_WIDTH(cell), SINGLE_LINE_WIDTH)];
        line.backgroundColor = [UIColor lightGrayColor];
        [cell addSubview:line];
        //---------------------------------------------------------------------------
    }
    
    cell.textLabel.text =[_titleArr objectAtIndex:indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //[_mainBtn setTitle:cell.textLabel.text forState:UIControlStateNormal];
    
    [self hideDropDownWithTableViewCellTouch:indexPath];
}




@end
