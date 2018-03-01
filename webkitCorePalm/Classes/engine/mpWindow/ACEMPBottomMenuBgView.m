//
//  ACEMPBottomMenuBgView.m
//  DropdownMenu
//
//  Created by Jay on 2018/1/24.
//  Copyright © 2018年 iOS开发者公会. All rights reserved.
//

#import "ACEMPBottomMenuBgView.h"

#define KeyboardBtnWidth 50.0 //键盘按钮宽度
#define SubMenuHeight 44.0 //底部各按钮高度
#define MenuTableCellHeight 49.0 //菜单列表cell的高度
#define KeyboardBtnImgSize 32.0//键盘按钮的图标的尺寸

#define HideDuration 0.2
#define ShowDuration 0.2

#define menuId_MENU @"menuId"
#define menuTitle_MENU @"menuTitle"
#define subItems_MENU @"subItems"
#define itemId_MENU @"itemId"
#define itemTitle_MENU @"itemTitle"

@interface ACEMPBottomMenuBgView () <ACEDropdownMenuDelegate>

@end

@implementation ACEMPBottomMenuBgView

- (instancetype)initWithFrame:(CGRect)frame windowOptions:(ACEMPWindowOptions *)windowOptions meBrwView:(EBrowserView *)meBrwView
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _meBrwView = meBrwView;
        [self setBgViewWithFrame:frame windowOptions:windowOptions];
        [self setSubViewWithWindowOptions:windowOptions];
    }
    return self;
}

- (void)setBgViewWithFrame:(CGRect)frame windowOptions:(ACEMPWindowOptions *)windowOptions
{
    self.backgroundColor = [UIColor clearColor];
    self.windowOptions = windowOptions;
    self.recordFrame = frame;
}

- (void)setSubViewWithWindowOptions:(ACEMPWindowOptions *)windowOptions
{
    
    if (self.subviews.count > 0) {
        for (ACEDropdownMenu *getView in self.subviews) {
            if ([getView isKindOfClass:[ACEDropdownMenu class]]) {
                
                getView.delegate = nil;
                
                getView.tableView.delegate = nil;
                getView.tableView.dataSource = nil;
                [getView.tableView removeFromSuperview];
                getView.tableView = nil;
                
                [getView.listView removeFromSuperview];
                getView.listView = nil;
            }
        }
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (windowOptions.menuList.count == 0) {
        return;
    }
    
    float subMenuWidth = (self.frame.size.width-KeyboardBtnWidth)/windowOptions.menuList.count;
    for (int i = 0; i < windowOptions.menuList.count; i ++) {
        
        NSDictionary *listDic = [windowOptions.menuList objectAtIndex:i];
        NSArray *subItemsArr = listDic[subItems_MENU];
        if (!subItemsArr) {
            subItemsArr = [[NSArray alloc] init];
        }
        NSMutableArray *itemTitleArr = [[NSMutableArray alloc] init];
        if (subItemsArr.count > 0) {
            for (NSDictionary *itemDic in subItemsArr) {
                NSString *itemTitle = [NSString stringWithFormat:@"%@",itemDic[itemTitle_MENU]];
                [itemTitleArr addObject:itemTitle];
            }
        }
        
        ACEDropdownMenu * dropdownMenu = [[ACEDropdownMenu alloc] init];
        dropdownMenu.recordIndex = i;
        
        dropdownMenu.meBrwView = _meBrwView;
        
        //这里的传值要在setFrame方法之前进行
        dropdownMenu.listDic = listDic;
        if (itemTitleArr.count > 0) {
            dropdownMenu.isShowTableView = YES;
        }
        
        [dropdownMenu setFrame:CGRectMake(KeyboardBtnWidth + subMenuWidth * i, 0, subMenuWidth, SubMenuHeight)];
        [dropdownMenu setMenuTitles:itemTitleArr rowHeight:MenuTableCellHeight];
        [dropdownMenu setMainBtnTitle:[NSString stringWithFormat:@"%@",listDic[menuTitle_MENU]]];
        dropdownMenu.delegate = self;
        [self addSubview:dropdownMenu];
    }
    
    _keyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_keyboardBtn setFrame:CGRectMake(0, 0, KeyboardBtnWidth, SubMenuHeight)];
    [_keyboardBtn setBackgroundColor:[UIColor whiteColor]];
    //[_keyboardBtn setImage:[UIImage imageNamed:@"img/acemp/platform_mp_window_keybord_up.png"] forState:UIControlStateNormal];
    //_keyboardBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _keyboardBtn.layer.borderColor   = [UIColor lightGrayColor].CGColor;
    _keyboardBtn.layer.borderWidth   = SINGLE_LINE_WIDTH;
    [_keyboardBtn addTarget:self action:@selector(clickKeyboardBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_keyboardBtn];
    
    UIImageView *keyboardIV = [[UIImageView alloc] init];
    keyboardIV.frame = CGRectMake(0, 0, KeyboardBtnImgSize, KeyboardBtnImgSize);
    keyboardIV.image = [UIImage imageNamed:@"img/acemp/platform_mp_window_keybord_up.png"];
    keyboardIV.contentMode = UIViewContentModeScaleAspectFit;
    keyboardIV.backgroundColor = [UIColor clearColor];
    [_keyboardBtn addSubview:keyboardIV];
    keyboardIV.center = _keyboardBtn.center;
}

- (void)aceShow:(BOOL)isAnimation
{
    if (isAnimation == YES) {
        [UIView animateWithDuration:ShowDuration animations:^{
            self.frame = self.recordFrame;
        }];
    } else {
        self.frame = self.recordFrame;
    }
}

- (void)aceHiden:(BOOL)isAnimation
{
    if (isAnimation == YES) {
        [UIView animateWithDuration:HideDuration animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.recordFrame.origin.y+self.recordFrame.size.height, self.frame.size.width, 0);
        }];
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.recordFrame.origin.y+self.recordFrame.size.height, self.frame.size.width, 0);
    }
}

- (void)clickKeyboardBtn:(UIButton *)sender
{
    NSLog(@"AppCan-->ACEMP-->KeyboardBtn touched");
    
    for (ACEDropdownMenu *getView in self.subviews) {
        if ([getView isKindOfClass:[ACEDropdownMenu class]]) {
            [getView hideDropDown];
        }
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"3",@"type", nil];
    NSString *jsStr = [dic ac_JSONFragment];
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onMPWindowClicked!=null){uexWindow.onMPWindowClicked(%@);}",jsStr];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
}

#pragma mark - ACEDropdownMenu Delegate

- (void)dropdownMenu:(ACEDropdownMenu *)menu selectedCellNumber:(NSInteger)number{
    NSLog(@"AppCan-->ACEMP-->TabList index = %ld",(long)number);
    
    NSDictionary *itemsDic = [self.windowOptions.menuList objectAtIndex:menu.recordIndex];
    NSString *menuId = itemsDic[@"menuId"];

    NSArray *subItems = itemsDic[@"subItems"];
    NSDictionary *subItemDic =[subItems objectAtIndex:number];
    NSString *itemId = subItemDic[@"itemId"];

    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"type",menuId,@"menuId",itemId,@"itemId", nil];
    NSString *jsStr = [dic ac_JSONFragment];
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onMPWindowClicked!=null){uexWindow.onMPWindowClicked(%@);}",jsStr];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
}

- (void)dropdownMenuDidTouchMainBtn:(ACEDropdownMenu *)menu{
    NSLog(@"AppCan-->ACEMP-->MainBtn touched");
    
    for (ACEDropdownMenu *getView in self.subviews) {
        if ([getView isKindOfClass:[ACEDropdownMenu class]]) {
            if (getView.recordIndex != menu.recordIndex) {
                [getView hideDropDown];
            }
        }
    }
    
    if (menu.isShowTableView == YES) {
        return;
    }
    
    NSDictionary *itemsDic = [self.windowOptions.menuList objectAtIndex:menu.recordIndex];
    NSString *menuId = itemsDic[@"menuId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"2",@"type",menuId,@"menuId", nil];
    NSString *jsStr = [dic ac_JSONFragment];
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onMPWindowClicked!=null){uexWindow.onMPWindowClicked(%@);}",jsStr];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
}

@end
