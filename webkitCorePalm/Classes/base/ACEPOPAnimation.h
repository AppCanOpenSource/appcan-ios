/**
 *
 *	@file   	: ACEPOPAnimation.h  in AppCanEngine Project
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 15/11/26
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
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


#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,ACEPOPAnimateType){
    ACEPOPAnimationIdStart =100,//标识用，永远不会被使用
    //Circle Zoom Animation
    ACEPOPAnimationCircleZoomAtCenter,
    ACEPOPAnimationCircleZoomAtLeftTop,
    ACEPOPAnimationCircleZoomAtRightTop,
    ACEPOPAnimationCircleZoomAtLeftButtom,
    ACEPOPAnimationCircleZoomAtRightButtom,
    //Bounce Animation
    ACEPOPAnimationBounceFromLeft,
    ACEPOPAnimationBounceFromTop,
    ACEPOPAnimationBounceFromRight,
    ACEPOPAnimationBounceFromBottom,
    ACEPOPAnimationIdEnd,//标识用，永远不会被使用
};

typedef NS_ENUM(NSInteger,ACEPOPAnimateFlag){
    ACEPOPAnimateWhenWindowOpening,
    ACEPOPAnimateWhenWindowClosing
};

extern NSString * const ACEPOPAnimateConfigutarionDurationKey;


typedef void (^ACEPOPAnimateCompletionBlock)(void);


@interface ACEPOPAnimateConfiguration : NSObject
@property (nonatomic,assign)NSTimeInterval duration;
+ (instancetype)configurationWithInfo:(NSDictionary *)animateInfo;
@end



@interface ACEPOPAnimation : NSObject

+ (NSInteger)reverseAnimationId:(NSInteger)animationId;
+ (BOOL)isPopAnimation:(NSInteger)inAnimiId;
+ (void)doAnimationInView:(UIView *)inView
                     type:(ACEPOPAnimateType)type
            configuration:(ACEPOPAnimateConfiguration *)config
                     flag:(ACEPOPAnimateFlag)flag
               completion:(ACEPOPAnimateCompletionBlock)completion;


@end
