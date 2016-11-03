//
//  ACEMultiPopoverScrollView.h
//  AppCanEngine
//
//  Created by CeriNo on 15/11/2.
//
//

#import <UIKit/UIKit.h>
#import <AppCanKit/AppCanWindowObject.h>





typedef void (^ACEMultiPopoverPageLoadingBlock)(void);




@interface ACEMultiPopoverScrollView : UIScrollView<AppCanScrollViewEventProducer>


-(void)addLoadingBlock:(ACEMultiPopoverPageLoadingBlock)pageLoadingBlock;
-(void)startLoadingPopViewAtIndex:(NSInteger)index;

-(void)continueLoading;
@end




@interface EScrollView : UIImageView
@property (nonatomic, strong) NSString *mainPopName;
@property (nonatomic, strong) ACEMultiPopoverScrollView * scrollView;
@end
