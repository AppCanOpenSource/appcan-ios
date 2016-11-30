/**
 *
 *	@file   	: ACEBasicAniation.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/29
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


#import "ACEBasicAnimation.h"
#import <AppCanKit/ACEXTScope.h>

@interface ACEBasicAnimationDelegate : NSObject<CAAnimationDelegate>
@property (nonatomic,strong)NSString *uuid;
@property (nonatomic,strong)ACEAnimateCompletionBlock completion;
@end

@implementation ACEBasicAnimationDelegate

- (instancetype)init{
    self = [super init];
    if (self) {
        _uuid = [NSUUID UUID].UUIDString;
    }
    return self;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if(self.completion) self.completion(flag);
}


@end


#pragma mark - Push Animation
@interface ACEPushAnimation: NSObject<ACEAnimation>
@end
@implementation ACEPushAnimation

+ (NSSet<NSNumber *> *)availableAnimationIDs{
    return [NSSet setWithArray:@[@(ACEPushAnimationLeftToRignt),@(ACEPushAnimationRightToLeft),@(ACEPushAnimationDownToUp),@(ACEPushAnimationUpToDown)]];
}

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID{
    if (![[self availableAnimationIDs]containsObject:@(openAnimationID)]) {
        return kACEAnimationNone;
    }
    ACEPushAnimationType type = (ACEPushAnimationType)openAnimationID;
    switch (type) {
        case ACEPushAnimationLeftToRignt:
            return ACEPushAnimationRightToLeft;
        case ACEPushAnimationRightToLeft:
            return ACEPushAnimationLeftToRignt;
        case ACEPushAnimationUpToDown:
            return ACEPushAnimationDownToUp;
        case ACEPushAnimationDownToUp:
            return ACEPushAnimationUpToDown;
    }
}

+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(NSDictionary *)config
                completionHandler:(ACEAnimateCompletionBlock)completion{
    
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    [self addPushAnimation:(ACEPushAnimationType)animationID toView:fromView duration:duration completionHandler:completion];
}

+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(NSDictionary *)config
                completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    [self addPushAnimation:(ACEPushAnimationType)animationID toView:toView duration:duration completionHandler:completion];
}



+ (void)addPushAnimation:(ACEPushAnimationType)type
                  toView:(UIView *)inView
                duration:(NSTimeInterval)duration
       completionHandler:(ACEAnimateCompletionBlock)completion{
    static NSMutableDictionary *_pushAnimationDelegates;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pushAnimationDelegates = [NSMutableDictionary dictionary];
    });
    
    
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.type = kCATransitionPush;

    switch (type) {
        case ACEPushAnimationLeftToRignt:
            animation.subtype = kCATransitionFromLeft;
            break;
        case ACEPushAnimationRightToLeft:
            animation.subtype = kCATransitionFromRight;
            break;
        case ACEPushAnimationUpToDown:
            animation.subtype = kCATransitionFromTop;
            break;
        case ACEPushAnimationDownToUp:
            animation.subtype = kCATransitionFromBottom;
            break;
    }
    
    ACEBasicAnimationDelegate *delegate = [[ACEBasicAnimationDelegate alloc]init];
    animation.delegate = delegate;
    _pushAnimationDelegates[delegate.uuid] = delegate;
    @weakify(delegate);
    delegate.completion = ^(BOOL finished){
        @strongify(delegate)
        if(completion) completion(finished);
        _pushAnimationDelegates[delegate.uuid] = nil;
    };
    [inView.layer addAnimation:animation forKey:nil];
}

@end

#pragma mark - Transition Animation
@interface  ACETransitionAnimation: NSObject<ACEAnimation>
@end

@implementation ACETransitionAnimation


+ (NSSet<NSNumber *> *)availableAnimationIDs{
    return [NSSet setWithArray:@[@(ACETransitionAnimationFade),@(ACETransitionAnimationLeftFlip),@(ACETransitionAnimationRightFlip),@(ACETransitionAnimationRipple)]];
}

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID{
    if (![[self availableAnimationIDs]containsObject:@(openAnimationID)]) {
        return kACEAnimationNone;
    }
    ACETransitionAnimationType type = (ACETransitionAnimationType)openAnimationID;
    switch (type) {
        case ACETransitionAnimationFade:
            return ACETransitionAnimationFade;
        case ACETransitionAnimationLeftFlip:
            return ACETransitionAnimationRightFlip;
        case ACETransitionAnimationRightFlip:
            return ACETransitionAnimationLeftFlip;
        case ACETransitionAnimationRipple:
            return ACETransitionAnimationRipple;
    }
}

+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(NSDictionary *)config
                completionHandler:(ACEAnimateCompletionBlock)completion{
    
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    [self addTransitionAnimation:(ACETransitionAnimationType)animationID toView:fromView duration:duration completionHandler:completion];
}

+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID
                         fromView:(UIView *)fromView
                           toView:(UIView *)toView
                         duration:(NSTimeInterval)duration
                    configuration:(NSDictionary *)config
                completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    [self addTransitionAnimation:(ACETransitionAnimationType)animationID toView:toView duration:duration completionHandler:completion];
}



+ (void)addTransitionAnimation:(ACETransitionAnimationType)type
                        toView:(UIView *)inView
                      duration:(NSTimeInterval)duration
             completionHandler:(ACEAnimateCompletionBlock)completion{
    static NSMutableDictionary *_transitionAnimationDelegates;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _transitionAnimationDelegates = [NSMutableDictionary dictionary];
    });
    
    
    CATransition *animation = [CATransition animation];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    switch (type) {
        case ACETransitionAnimationFade:
            animation.type = kCATransitionFade;
            break;
        case ACETransitionAnimationLeftFlip:
            animation.type = @"oglFlip";
            animation.subtype = kCATransitionFromLeft;
            break;
        case ACETransitionAnimationRightFlip:
            animation.type = @"oglFlip";
            animation.subtype = kCATransitionFromRight;
            break;
        case ACETransitionAnimationRipple:
            animation.type = @"rippleEffect";
            break;
    }
    
    ACEBasicAnimationDelegate *delegate = [[ACEBasicAnimationDelegate alloc]init];
    animation.delegate = delegate;
    _transitionAnimationDelegates[delegate.uuid] = delegate;
    @weakify(delegate);
    delegate.completion = ^(BOOL finished){
        @strongify(delegate)
        if(completion) completion(finished);
        _transitionAnimationDelegates[delegate.uuid] = nil;
    };
    [inView.layer addAnimation:animation forKey:nil];
}

@end


@interface ACEMoveAnimation : NSObject<ACEAnimation>

@end

@implementation ACEMoveAnimation


+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID{
    if (![[self availableMoveInAnimationIDs] containsObject:@(openAnimationID)]) {
        return kACEAnimationNone;
    }
    ACEMoveAnimationType type = (ACEMoveAnimationType)openAnimationID;
    switch (type) {
        case ACEMoveInAnimationFromLeft:
            return ACEMoveOutAnimationFromLeft;
        case ACEMoveInAnimationFromRight:
            return ACEMoveOutAnimationFromRight;
        case ACEMoveInAnimationFromTop:
            return ACEMoveOutAnimationFromTop;
        case ACEMoveInAnimationFromBottom:
            return ACEMoveOutAnimationFromBottom;
        default:
            return kACEAnimationNone;
    }
    
    
}

+ (NSSet<NSNumber *> *)availableMoveInAnimationIDs{
    return [NSSet setWithArray:@[@(ACEMoveInAnimationFromLeft),@(ACEMoveInAnimationFromRight),@(ACEMoveInAnimationFromTop),@(ACEMoveInAnimationFromBottom)]];
}

+ (NSSet<NSNumber *> *)availableMoveOutAnimationIDs{
    return [NSSet setWithArray:@[@(ACEMoveOutAnimationFromLeft),@(ACEMoveOutAnimationFromRight),@(ACEMoveOutAnimationFromTop),@(ACEMoveOutAnimationFromBottom)]];
}

+ (NSSet<NSNumber *> *)availableAnimationIDs{
    return [self.availableMoveInAnimationIDs setByAddingObjectsFromSet:self.availableMoveOutAnimationIDs];
}

+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableMoveInAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    ACEMoveAnimationType type = (ACEMoveAnimationType)animationID;
    
    CGRect originFrame = toView.frame;
    CGRect tmpFrame = originFrame;
    switch (type) {
        case ACEMoveInAnimationFromLeft:
            tmpFrame.origin.x -= originFrame.size.width;
            break;
        case ACEMoveInAnimationFromRight:
            tmpFrame.origin.x += originFrame.size.width;
            break;
        case ACEMoveInAnimationFromTop:
            tmpFrame.origin.y -= originFrame.size.height;
            break;
        case ACEMoveInAnimationFromBottom:
            tmpFrame.origin.y += originFrame.size.height;
            break;
        default:
            if(completion) completion(NO);
            return;
    }
    toView.frame = tmpFrame;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         toView.frame = originFrame;
                     }
                     completion:completion];
}
+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableMoveOutAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    ACEMoveAnimationType type = (ACEMoveAnimationType)animationID;
    
    CGRect originFrame = fromView.frame;
    CGRect tmpFrame = originFrame;
    switch (type) {
        case ACEMoveOutAnimationFromLeft:
            tmpFrame.origin.x -= originFrame.size.width;
            break;
        case ACEMoveOutAnimationFromRight:
            tmpFrame.origin.x += originFrame.size.width;
            break;
        case ACEMoveOutAnimationFromTop:
            tmpFrame.origin.y -= originFrame.size.height;
            break;
        case ACEMoveOutAnimationFromBottom:
            tmpFrame.origin.y += originFrame.size.height;
            break;
        default:
            if(completion) completion(NO);
            return;
    }
    [UIView animateWithDuration:duration
                     animations:^{
                         fromView.frame = tmpFrame;
                     }
                     completion:completion];
}



@end


