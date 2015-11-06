//
//  ACEMultiPopoverScrollView.m
//  AppCanEngine
//
//  Created by CeriNo on 15/11/2.
//
//

#import "ACEMultiPopoverScrollView.h"


typedef NS_ENUM(NSInteger,ACEMultiPopoverLoadingStatus) {
    ACEMultiPopoverInitialized,
    ACEMultiPopoverStartLoading,
    ACEMultiPopoverCompleteLoading
};

@interface ACEMultiPopoverScrollView()
@property (nonatomic,strong)NSMutableArray<ACEMultiPopoverPageLoadingBlock> *loadPopViewBlocks;
@property (nonatomic,assign)ACEMultiPopoverLoadingStatus status;
@end

@implementation ACEMultiPopoverScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializer];
    }
    return self;
}
-(void)initializer {
    self.loadPopViewBlocks=[NSMutableArray array];
    self.status=ACEMultiPopoverInitialized;
}

-(void)addLoadingBlock:(ACEMultiPopoverPageLoadingBlock)pageLoadingBlock{
    if(self.status != ACEMultiPopoverInitialized){
        return;
    }
    [self.loadPopViewBlocks addObject:pageLoadingBlock];
}
-(void)startLoadingPopViewAtIndex:(NSInteger)index{
    if(self.status != ACEMultiPopoverInitialized){
        return;
    }
    if(index < 0 || index>[self.loadPopViewBlocks count]-1){
        index=0;
    }
    
    ACEMultiPopoverPageLoadingBlock firstLoadingBlock =[self.loadPopViewBlocks objectAtIndex:index];
    [self.loadPopViewBlocks removeObject:firstLoadingBlock];
    firstLoadingBlock();
    
    self.status=ACEMultiPopoverStartLoading;

}
-(void)continueLoading{
    if(self.status != ACEMultiPopoverStartLoading){
        return;
    }
    self.status=ACEMultiPopoverCompleteLoading;
    for (ACEMultiPopoverPageLoadingBlock pageLoadingBlock in self.loadPopViewBlocks) {
        pageLoadingBlock();
    
    }
    [self.loadPopViewBlocks removeAllObjects];
    self.loadPopViewBlocks=nil;
}
@end
