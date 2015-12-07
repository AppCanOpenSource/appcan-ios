/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "BAnimation.h"
#import "BUtility.h"
#import <QuartzCore/QuartzCore.h>

@implementation BAnimation

+ (BOOL)isMoveIn:(int)inAnimiID {
    switch (inAnimiID) {
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_FLIP:
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_FLIP:
		case F_BRW_WND_SWITCH_ANIMI_ID_FADE_IN_FADE_OUT:
            return NO;
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_MOVEIN:
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_MOVEIN:
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_MOVEIN:
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_MOVEIN:
            return YES;
		default:
			break;
	}
    return NO;
}

+ (BOOL)isPush:(int)inAnimiID
{
    if (UIVIEW_ANIMATION_PUSH_USE == NO) {
        return NO;
    }
    
    switch (inAnimiID)
    {
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
            return YES;
		default:
			break;
	}
    return NO;
}

+ (int)ReverseAnimiId:(int)inAnimiID {
	switch (inAnimiID) {
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
			return F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
			return F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
			return F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
			return F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_FLIP:
			return F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_FLIP;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_FLIP:
			return F_BRW_WND_SWITCH_ANIMI_ID_LEFT_FLIP;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_FADE_IN_FADE_OUT:
			return F_BRW_WND_SWITCH_ANIMI_ID_FADE_IN_FADE_OUT;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_MOVEIN:
			return F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_REVEAL;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_MOVEIN:
			return F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_REVEAL;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_MOVEIN:
			return F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_REVEAL;
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_MOVEIN:
			return F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_REVEAL;
			break;
		default:
			break;
	}
	return F_BRW_WND_SWITCH_ANIMI_ID_NONE;
}

+ (void)doMoveInAnimition:(UIView*)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime {
    
    CGRect oldFrame = inView.frame;
    CGSize oldSize = oldFrame.size;
    switch (inAnimiId) {
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_MOVEIN:
            inView.frame = CGRectMake(0.0-oldSize.width, 0, oldSize.width, oldSize.height);
            break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_MOVEIN:
            inView.frame = CGRectMake(0.0+oldSize.width, 0, oldSize.width, oldSize.height);
            break;
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_MOVEIN:
            inView.frame = CGRectMake(0.0, 0.0-oldSize.height, oldSize.width, oldSize.height);
            break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_MOVEIN:
            inView.frame = CGRectMake(0.0, 0.0+oldSize.height, oldSize.width, oldSize.height);
            break;
		default:
			break;
	}
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:inAnimiTime];
    inView.frame = oldFrame;
    [UIView commitAnimations];
}

+ (void)doPushAnimition:(UIView *)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime
{
    UIView *superView = inView.superview;
    CGRect originSelfRect = inView.frame;
    CGRect originSuperRect = superView.frame;
    CGRect animationRect;
    switch(inAnimiId){
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x-inView.bounds.size.width, inView.frame.origin.y, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x+superView.bounds.size.width, superView.frame.origin.y, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x+inView.bounds.size.width, inView.frame.origin.y, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x-superView.bounds.size.width, superView.frame.origin.y, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x, inView.frame.origin.y-inView.bounds.size.height, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x, superView.frame.origin.y+superView.bounds.size.height, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x, inView.frame.origin.y+inView.bounds.size.height, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x, superView.frame.origin.y-superView.bounds.size.height, superView.bounds.size.width, superView.bounds.size.height);
			break;
        default:
            break;
    }
    [UIView animateWithDuration:inAnimiTime animations:^{
        superView.frame = animationRect;
    } completion:^(BOOL finished){
        inView.frame = originSelfRect;
        superView.frame = originSuperRect;
    }];
}

+ (void)doPushAnimition:(UIView *)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime completion:(void (^)(BOOL finished))completion
{
    UIView *superView = inView.superview;
    CGRect originSelfRect = inView.frame;
    CGRect originSuperRect = superView.frame;
    CGRect animationRect;
    switch(inAnimiId){
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x-inView.bounds.size.width, inView.frame.origin.y, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x+superView.bounds.size.width, superView.frame.origin.y, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x+inView.bounds.size.width, inView.frame.origin.y, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x-superView.bounds.size.width, superView.frame.origin.y, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x, inView.frame.origin.y-inView.bounds.size.height, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x, superView.frame.origin.y+superView.bounds.size.height, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x, inView.frame.origin.y+inView.bounds.size.height, inView.bounds.size.width, inView.bounds.size.height);
            animationRect = CGRectMake(superView.frame.origin.x, superView.frame.origin.y-superView.bounds.size.height, superView.bounds.size.width, superView.bounds.size.height);
			break;
        default:
            break;
    }
    [UIView animateWithDuration:inAnimiTime animations:^{
        superView.frame = animationRect;
    } completion:^(BOOL finished){
        inView.frame = originSelfRect;
        superView.frame = originSuperRect;
        
        completion(YES);
    }];
}

/*
 window close专用
 */
+ (void)doPushCloseAnimition:(UIView *)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime completion:(void (^)(BOOL finished))completion
{
    UIView *superView = inView.superview;
    CGRect originSelfRect = inView.frame;
    CGRect originSuperRect = superView.frame;
    switch(inAnimiId){
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x+inView.bounds.size.width, inView.frame.origin.y, inView.bounds.size.width, inView.bounds.size.height);
            superView.frame = CGRectMake(superView.frame.origin.x-superView.bounds.size.width, superView.frame.origin.y, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x-inView.bounds.size.width, inView.frame.origin.y, inView.bounds.size.width, inView.bounds.size.height);
            superView.frame = CGRectMake(superView.frame.origin.x+superView.bounds.size.width, superView.frame.origin.y, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x, inView.frame.origin.y+inView.bounds.size.height, inView.bounds.size.width, inView.bounds.size.height);
            superView.frame = CGRectMake(superView.frame.origin.x, superView.frame.origin.y-superView.bounds.size.height, superView.bounds.size.width, superView.bounds.size.height);
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
            inView.frame = CGRectMake(inView.frame.origin.x, inView.frame.origin.y-inView.bounds.size.height, inView.bounds.size.width, inView.bounds.size.height);
            superView.frame = CGRectMake(superView.frame.origin.x, superView.frame.origin.y+superView.bounds.size.height, superView.bounds.size.width, superView.bounds.size.height);
			break;
        default:
            break;
    }
    [UIView animateWithDuration:inAnimiTime animations:^{
        superView.frame = originSuperRect;
    } completion:^(BOOL finished){
        inView.frame = originSelfRect;
        superView.frame = originSuperRect;
        
        completion(YES);
    }];
}

+ (void)SwapAnimationWithView:(UIView*)inView AnimiId:(int)inAnimiID AnimiTime:(float)inAnimiTime {
	CATransition *animation = [CATransition animation];
	[animation setDuration:inAnimiTime];		
	switch(inAnimiID){
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			animation.type = kCATransitionPush; 
			animation.subtype = kCATransitionFromLeft;
			[inView.layer addAnimation:animation forKey:NULL];
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			animation.type = kCATransitionPush;
			animation.subtype = kCATransitionFromRight;
			[inView.layer addAnimation:animation forKey:NULL];
			break;	
		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			animation.type = kCATransitionPush;
			animation.subtype = kCATransitionFromBottom;  
			[inView.layer addAnimation:animation forKey:NULL];
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			animation.type = kCATransitionPush;
			animation.subtype = kCATransitionFromTop;
			[inView.layer addAnimation:animation forKey:NULL];
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_FADE_IN_FADE_OUT:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			animation.type = kCATransitionFade; 
			[inView.layer addAnimation:animation forKey:NULL];
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_FLIP:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			animation.type = @"oglFlip";
			animation.subtype = kCATransitionFromLeft;
			[inView.layer addAnimation:animation forKey:NULL];
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_FLIP:
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			animation.type = @"oglFlip";
			animation.subtype =  kCATransitionFromRight;
			[inView.layer addAnimation:animation forKey:NULL];
			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_RIPPLE:
			animation.type = @"rippleEffect";//110 水波抖动
			[inView.layer addAnimation:animation forKey:NULL];
			 break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_MOVEIN://从左到右，新页面覆盖当前页面
//			 animation.fillMode = kCAFillModeForwards;
//			 [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			 animation.type = kCATransitionMoveIn;  
//			 animation.subtype = kCATransitionFromLeft;
//			 [inView.layer addAnimation:animation forKey:NULL];
//			 break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_MOVEIN://从右到左，新页面覆盖当前页面
//			 animation.fillMode = kCAFillModeForwards;
//			 [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			 animation.type = kCATransitionMoveIn; 
//			 animation.subtype = kCATransitionFromRight;
//			 [inView.layer addAnimation:animation forKey:NULL];
//			 break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_MOVEIN://从上到下，新页面覆盖当前页面
//			animation.fillMode = kCAFillModeForwards;
//			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			animation.type = kCATransitionMoveIn;  
//			animation.subtype = kCATransitionFromBottom;
//			[inView.layer addAnimation:animation forKey:NULL];
//			break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_MOVEIN://从下到上，新页面覆盖当前页面
//			animation.fillMode = kCAFillModeForwards;
//			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			animation.type = kCATransitionMoveIn; 
//			animation.subtype = kCATransitionFromTop;
//			[inView.layer addAnimation:animation forKey:NULL];
//			break;
		case F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_REVEAL://把当前页面从上抽出
			animation.fillMode = kCAFillModeForwards;
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
			animation.type = kCATransitionReveal; 
			animation.subtype = kCATransitionFromLeft;
			[inView.layer addAnimation:animation forKey:NULL];
			break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_REVEAL://从下抽出
//			animation.fillMode = kCAFillModeForwards;
//			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			animation.type = kCATransitionReveal; 
//			animation.subtype = kCATransitionFromRight;
//			[inView.layer addAnimation:animation forKey:NULL];
//			break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_REVEAL://从左抽出
//			animation.fillMode = kCAFillModeForwards;
//			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			animation.type = kCATransitionReveal; 
//			animation.subtype = kCATransitionFromBottom;
//			[inView.layer addAnimation:animation forKey:NULL];
//			break;
//		case F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_REVEAL://从右抽出
//			animation.fillMode = kCAFillModeForwards;
//			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
//			animation.type = kCATransitionReveal; 
//			animation.subtype = kCATransitionFromTop;
//			[inView.layer addAnimation:animation forKey:NULL];
//			break;
		/*case 9:
			 animation.type = @"pageCurl";//101  上翻页
			 break;
			 case 10:
			 animation.type = @"pageUnCurl";//102  下翻页
			 break;
			 case 11:
			 animation.type = kCATransitionPush; //从上到下, 新页面把当前页面推出去
			 animation.subtype = kCATransitionFromTop;
			 break;
			 case 12:
			 animation.type=@"cube";
			 animation.subtype = kCATransitionFromLeft;
			 break;
			 case 13:
			 animation.type = @"cube";//---立方体旋转 从下往上走
			 break;
			 case 14:
			 animation.type = @"suckEffect";//103 把页面抽走 从左上角拉动
			 break;*/
		default:
			break;
			
	}
}

@end
