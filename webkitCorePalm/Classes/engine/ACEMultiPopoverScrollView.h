//
//  ACEMultiPopoverScrollView.h
//  AppCanEngine
//
//  Created by CeriNo on 15/11/2.
//
//

#import <UIKit/UIKit.h>


typedef void (^ACEMultiPopoverPageLoadingBlock)(void);



@interface ACEMultiPopoverScrollView : UIScrollView


-(void)addLoadingBlock:(ACEMultiPopoverPageLoadingBlock)pageLoadingBlock;
-(void)startLoadingPopViewAtIndex:(NSInteger)index;

-(void)continueLoading;
@end
