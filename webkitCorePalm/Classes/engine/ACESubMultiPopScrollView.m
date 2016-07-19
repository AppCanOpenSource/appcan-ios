//
//  ACESubMultiPopScrollView.m
//  AppCanEngine
//
//  Created by zywx on 15/12/22.
//
//

#import "ACESubMultiPopScrollView.h"

@implementation ACESubMultiPopScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
  
        self.bounces = NO;
        
        self.delegate = self;
        
    }
    
    return self;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
  
}


@end
