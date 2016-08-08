//
//  ACEPluginViewContainer.m
//  AppCanEngine
//
//  Created by xrg on 15/7/16.
//
//

#import "ACEPluginViewContainer.h"
#import "EUExWindow.h"

@implementation ACEPluginViewContainer

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _maxIndex = -1;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        _lastIndex = -1;
    }
    
    return self;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    NSInteger index = lround(fractionalPage) ;
    [self onPluginContainerPageChange:index];
}

- (void)onPluginContainerPageChange:(NSInteger)index{
    if (_lastIndex != index) {
        _lastIndex = index;
        [self.uexObj.webViewEngine callbackWithFunctionKeyPath:@"uexWindow.onPluginContainerPageChange" arguments:ACArgsPack(self.containerIdentifier,@1,@(index))];
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    NSInteger index = lround(fractionalPage) ;
    [self onPluginContainerPageChange:index];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
