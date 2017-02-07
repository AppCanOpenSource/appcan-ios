/**
 *
 *	@file   	: ACEAnimation.m  in AppCanEngine
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


#import "ACEAnimation.h"
#import <objc/runtime.h>

ACEAnimationID kACEAnimationNone = 0;

@implementation ACEAnimations

static NSMutableDictionary<NSNumber *,NSString *> *_animations;


+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _animations = [NSMutableDictionary dictionary];
        [self getAllAnimations];
    });
}

+ (void)getAllAnimations{
    unsigned classCount = 0;
    Class *allClasses = objc_copyClassList(&classCount);
    if (!classCount || !allClasses) {
        return;
    }
    Protocol *proto = @protocol(ACEAnimation);
    @autoreleasepool {
        for (int i = 0;i < classCount;i++) {
            Class class = allClasses[i];           
            if (!class_respondsToSelector(class, @selector(methodSignatureForSelector:))) {
                continue;
            }
            if (!class_conformsToProtocol(class, proto)) {
                continue;
            }
            for (NSNumber * idNumber in [class availableAnimationIDs]) {
                _animations[idNumber] = NSStringFromClass(class);
            }
        }
    }
    free(allClasses);
}

+ (BOOL)isAnimationValid:(ACEAnimationID)animationID{
    return (animationID != kACEAnimationNone) && [_animations.allKeys containsObject:@(animationID)];
}

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID{
    NSString *className = _animations[@(openAnimationID)];
    Class animateClass = NSClassFromString(className);
    if (!animateClass) {
        return kACEAnimationNone;
    }
    return [animateClass closeAnimationForOpenAnimation:openAnimationID];
}


+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    NSString *className = _animations[@(animationID)];
    Class animateClass = NSClassFromString(className);
    if (!animateClass) {
        if(completion) completion(NO);
        return;
    }
    [animateClass addOpeningAnimationWithID:animationID fromView:fromView toView:toView duration:duration configuration:config completionHandler:completion];
}

+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    NSString *className = _animations[@(animationID)];
    Class animateClass = NSClassFromString(className);
    if (!animateClass) {
        if(completion) completion(NO);
        return;
    }
    [animateClass addClosingAnimationWithID:animationID fromView:fromView toView:toView duration:duration configuration:config completionHandler:completion];
}




@end
