//
//  ACETransitionView.m
//  AppCanEngine
//
//  Created by Jay on 2018/5/15.
//

#import "ACETransitionView.h"

#define NaviHeight (iPhoneX?88:64)

//图标的宽高
#define iconHeight 64
//标题到左侧边的距离
#define LeftWidth 40.0
//左侧叉号按钮的宽高
#define LeftHeight 24.0
//标题高度
#define TitleHeight 44.0
//小圆点的宽高
#define PointHeight 8.0
//小圆点位置偏移量
#define PointOffset (iconHeight/3-PointHeight)/2
//icon、标题和小圆点之间的间距
#define UpAndDownLength 10.0

@implementation ACETransitionView

- (id)initWithFrame:(CGRect)frame WWidget:(WWidget *)wgtObj meBrwView:(EBrowserView *)meBrwView
{
    if (self = [super initWithFrame:frame]) {
        
        _meBrwView = meBrwView;
        _pointArr = [[NSMutableArray alloc] init];
        _pointAnimationCount = 0;
        _brownImg = [UIImage imageNamed:@"img/acemp/platform_mp_widget_loading_brown_point.png"];
        _blackImg = [UIImage imageNamed:@"img/acemp/platform_mp_widget_loading_black_point.png"];
        
        [self createSubViewWithFrame:frame WWidget:wgtObj];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onACEMP_TransitionView_Close_Notify:) name:ACEMP_TransitionView_Close_Notify object:nil];
    }
    return self;
}

- (void)createSubViewWithFrame:(CGRect)frame WWidget:(WWidget *)wgtObj
{
    self.wgtObj = wgtObj;
    
    self.backgroundColor = [UIColor whiteColor];
    
    _iconIv = [[UIImageView alloc] init];
    _iconIv.frame = CGRectMake((frame.size.width-iconHeight)/2, NaviHeight+10, iconHeight, iconHeight);
    _iconIv.image = [UIImage imageNamed:self.wgtObj.appIcon];
    _iconIv.contentMode = UIViewContentModeScaleAspectFit;
    _iconIv.backgroundColor = [UIColor clearColor];
    _iconIv.layer.cornerRadius = iconHeight/2;
    _iconIv.layer.masksToBounds = YES;
    [self addSubview:_iconIv];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.frame = CGRectMake(LeftWidth, NaviHeight+iconHeight+UpAndDownLength*2, frame.size.width-LeftWidth*2, TitleHeight);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = [NSString stringWithFormat:@"%@",self.wgtObj.widgetName];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:_titleLabel];
    
    _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn.frame = CGRectMake(15, NaviHeight-LeftHeight, LeftHeight, LeftHeight);
    [_leftBtn setBackgroundColor:[UIColor clearColor]];
    //[_leftBtn setTitle:@"Back" forState:UIControlStateNormal];
    //[_leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //_leftBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_leftBtn setImage:[UIImage imageNamed:@"img/acemp/platform_mp_widget_loading_close_x.png"] forState:UIControlStateNormal];
    _leftBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [_leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leftBtn];
    
    for (int i = 0; i < 3; i ++) {
        UIImageView *pointIv = [[UIImageView alloc] init];
        pointIv.frame = CGRectMake((frame.size.width-iconHeight)/2+PointOffset+iconHeight/3*i, _titleLabel.frame.origin.y+_titleLabel.frame.size.height+UpAndDownLength, PointHeight, PointHeight);
        pointIv.image = [UIImage imageNamed:@"img/acemp/platform_mp_widget_loading_brown_point.png"];
        pointIv.backgroundColor = [UIColor clearColor];
        pointIv.layer.cornerRadius = PointHeight/2;
        pointIv.layer.masksToBounds = YES;
        [self addSubview:pointIv];
        [_pointArr addObject:pointIv];
    }
    
    _pointAnimationCount = 1;
    [self startPointAnimation];
    
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)startPointAnimation
{
    if (self.pointAnimationCount < 1) {
        return;
    }
    
    if (self.pointAnimationCount > 2) {
        self.pointAnimationCount = 1;
    } else {
        self.pointAnimationCount ++;
    }
    
    for (int i = 0; i < 3; i ++) {
        if (self.pointAnimationCount == (i + 1)) {
            self.pointArr[i].image = self.blackImg;
        } else {
            self.pointArr[i].image = self.brownImg;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        [self startPointAnimation];
    });
}

- (void)leftBtnClick
{
    NSString *toBeExeJs = [NSString stringWithFormat:@"if(uexWidget.cbCloseLoading!=null){uexWidget.cbCloseLoading();}"];
    //ACENSLog(@"toBeExeJS: %@", toBeExeJs);
    [self.meBrwView stringByEvaluatingJavaScriptFromString:toBeExeJs];
    [self removeACEMPTransitionViewWithAnimation];
}

- (void)removeACEMPTransitionViewWithAnimation
{
    CGRect newFrame = self.frame;
    newFrame.origin.y = self.frame.origin.y+self.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = newFrame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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

- (void)onACEMP_TransitionView_Close_Notify:(NSNotification *)notification {
    EBrowserView *ebrwView = (EBrowserView *)notification.object;
    if ([self.wgtObj.appId isEqualToString:ebrwView.mwWgt.appId]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
}

- (void)dealloc{
    self.pointAnimationCount = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
