//
//  ACEPluginViewContainer.m
//  AppCanEngine
//
//  Created by xrg on 15/7/16.
//
//

#import "ACEPluginViewContainer.h"


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
    
    [self performSelectorOnMainThread:@selector(onPluginContainerPageChange:) withObject:[NSString stringWithFormat:@"%ld",(long)index] waitUntilDone:NO];
    
}

- (void)onPluginContainerPageChange:(id)userInfo {
    
    NSInteger index = [(NSString *)userInfo integerValue];
    
    if (_lastIndex != index) {
        _lastIndex = index;
        [_uexObj jsSuccessWithName:@"uexWindow.onPluginContainerPageChange" opId:self.containerIdentifier dataType:1 intData:index];
    }
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.bounds.size.width ;
    float fractionalPage = scrollView.contentOffset.x / pageWidth ;
    NSInteger index = lround(fractionalPage) ;

    [self performSelectorOnMainThread:@selector(onPluginContainerPageChange:) withObject:[NSString stringWithFormat:@"%ld",(long)index] waitUntilDone:NO];
    
    
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
