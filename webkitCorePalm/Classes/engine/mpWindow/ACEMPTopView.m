//
//  ACEMPTopView.m
//  DropdownMenu
//
//  Created by Jay on 2018/1/29.
//  Copyright © 2018年 iOS开发者公会. All rights reserved.
//

#import "ACEMPTopView.h"

#define LeftWidth 60.0
#define TitleHeight 44.0

@implementation ACEMPTopView

- (id)initWithFrame:(CGRect)frame WindowOptions:(ACEMPWindowOptions *)windowOption meBrwView:(EBrowserView *)meBrwView
{
    if (self = [super initWithFrame:frame]) {
        
        _meBrwView = meBrwView;
        [self createSubViewWithFrame:frame WindowOptions:windowOption];
    }
    return self;
}

- (void)createSubViewWithFrame:(CGRect)frame WindowOptions:(ACEMPWindowOptions *)windowOption
{
    
    self.windowOptions = windowOption;
    
    if (self.windowOptions.titleBarBgColor) {
        self.backgroundColor = [self colorWithHexString:[NSString stringWithFormat:@"%@",self.windowOptions.titleBarBgColor]];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(LeftWidth, frame.size.height-TitleHeight, frame.size.width-LeftWidth*2, TitleHeight);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = [NSString stringWithFormat:@"%@",self.windowOptions.windowTitle];
    
    if (self.windowOptions.titleTextColor) {
        _titleLabel.textColor = [self colorWithHexString:[NSString stringWithFormat:@"%@",self.windowOptions.titleTextColor]];
    } else {
        _titleLabel.textColor = [UIColor blackColor];
    }
    
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:_titleLabel];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(15, frame.size.height-TitleHeight, LeftWidth-15*2, TitleHeight);
    [_leftBtn setBackgroundColor:[UIColor clearColor]];
    //[_leftBtn setTitle:@"Back" forState:UIControlStateNormal];
    //[_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //_leftBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    if (self.windowOptions.titleLeftIcon) {
        [_leftBtn setImage:[UIImage imageNamed:self.windowOptions.titleLeftIcon] forState:UIControlStateNormal];
    }
    _leftBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftBtn];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.frame = CGRectMake(_leftBtn.frame.origin.x+_leftBtn.frame.size.width+15, frame.size.height-TitleHeight, LeftWidth-15*2, TitleHeight);
    [_closeBtn setBackgroundColor:[UIColor clearColor]];
    //[_leftBtn setTitle:@"Back" forState:UIControlStateNormal];
    //[_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //_leftBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    _closeBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    if (self.windowOptions.titleCloseIcon && ![self.windowOptions.titleCloseIcon isEqualToString:@""]) {
        [_closeBtn setImage:[UIImage imageNamed:self.windowOptions.titleCloseIcon] forState:UIControlStateNormal];
        _closeBtn.hidden = NO;
    } else {
        _closeBtn.hidden = YES;
    }
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(frame.size.width-LeftWidth+15, frame.size.height-TitleHeight, LeftWidth-15*2, TitleHeight);
    [_rightBtn setBackgroundColor:[UIColor clearColor]];
//    [_rightBtn setTitle:@"Done" forState:UIControlStateNormal];
//    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    if (self.windowOptions.titleRightIcon) {
        [_rightBtn setImage:[UIImage imageNamed:self.windowOptions.titleRightIcon] forState:UIControlStateNormal];
    }
    _rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rightBtn];
}

- (void)resetWindowOptions:(ACEMPWindowOptions *)windowOptions
{
    self.windowOptions = windowOptions;
    
    self.backgroundColor = [self colorWithHexString:[NSString stringWithFormat:@"%@",self.windowOptions.titleBarBgColor]];
    _titleLabel.text = [NSString stringWithFormat:@"%@",self.windowOptions.windowTitle];
    if (self.windowOptions.titleLeftIcon) {
        [_leftBtn setImage:[UIImage imageNamed:self.windowOptions.titleLeftIcon] forState:UIControlStateNormal];
    }
    if (self.windowOptions.titleRightIcon) {
        [_rightBtn setImage:[UIImage imageNamed:self.windowOptions.titleRightIcon] forState:UIControlStateNormal];
    }
    if (self.windowOptions.titleCloseIcon && ![self.windowOptions.titleCloseIcon isEqualToString:@""]) {
        [_closeBtn setImage:[UIImage imageNamed:self.windowOptions.titleCloseIcon] forState:UIControlStateNormal];
        _closeBtn.hidden = NO;
    } else {
        _closeBtn.hidden = YES;
    }
}

- (void)closeBtnClick
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"4",@"type", nil];
    NSString *jsStr = [dic ac_JSONFragment];
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onMPWindowClicked!=null){uexWindow.onMPWindowClicked(%@);}",jsStr];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
}

- (void)leftBtnClick
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"0",@"type", nil];
    NSString *jsStr = [dic ac_JSONFragment];
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onMPWindowClicked!=null){uexWindow.onMPWindowClicked(%@);}",jsStr];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
}

- (void)rightBtnClick
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"type", nil];
    NSString *jsStr = [dic ac_JSONFragment];
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWindow.onMPWindowClicked!=null){uexWindow.onMPWindowClicked(%@);}",jsStr];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
}

- (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
