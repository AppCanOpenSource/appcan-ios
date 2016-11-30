/**
 *
 *	@file   	: ACEAnimation.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/28
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
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

NS_ASSUME_NONNULL_BEGIN


typedef NSUInteger ACEAnimationID;
typedef void (^ACEAnimateCompletionBlock)(BOOL finished);

extern ACEAnimationID kACEAnimationNone;


@protocol ACEAnimation <NSObject>


+ (NSSet<NSNumber *> *)availableAnimationIDs;

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID;

+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(nullable NSDictionary *)config
                completionHandler:(nullable ACEAnimateCompletionBlock)completion;

+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(nullable NSDictionary *)config
                completionHandler:(nullable ACEAnimateCompletionBlock)completion;



@end



@interface ACEAnimations : NSObject

+ (BOOL)isAnimationValid:(ACEAnimationID)animationID;

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID;
+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(nullable NSDictionary *)config
                completionHandler:(nullable ACEAnimateCompletionBlock)completion;

+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(nullable NSDictionary *)config
                completionHandler:(nullable ACEAnimateCompletionBlock)completion;


@end

NS_ASSUME_NONNULL_END


