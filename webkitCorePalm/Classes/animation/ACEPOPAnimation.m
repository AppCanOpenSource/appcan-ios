/**
 *
 *	@file   	: ACEPOPAnimation.m  in AppCanEngine Project
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/11/30
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

#import "ACEPOPAnimation.h"
#import <pop/pop.h>


@interface ACECircleZoomAnimation : NSObject<ACEAnimation>

@end
@implementation ACECircleZoomAnimation

+ (NSSet<NSNumber *> *)availableAnimationIDs{
    return [NSSet setWithArray:@[@(ACECircleZoomAnimationAtCenter),@(ACECircleZoomAnimationAtLeftTop),@(ACECircleZoomAnimationAtRightTop),@(ACECircleZoomAnimationAtLeftBottom),@(ACECircleZoomAnimationAtRightBottom)]];
}

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID{
    if (![[self availableAnimationIDs] containsObject:@(openAnimationID)]) {
        return kACEAnimationNone;
    }
    return openAnimationID;
}


+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    ACECircleZoomAnimationType type = (ACECircleZoomAnimationType)animationID;
    CGFloat maxRadius = [self circleMaxRadiusForAnimation:type inView:toView];
    CGFloat minRadius = 1;
    [self addCiecleZoomAnimation:type toView:toView fromRadius:minRadius toRadius:maxRadius duration:duration completionHandler:completion];
    
    
    
}


+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    ACECircleZoomAnimationType type = (ACECircleZoomAnimationType)animationID;
    CGFloat maxRadius = [self circleMaxRadiusForAnimation:type inView:fromView];
    CGFloat minRadius = 1;
    [self addCiecleZoomAnimation:type toView:fromView fromRadius:maxRadius toRadius:minRadius duration:duration completionHandler:completion];
}

+ (void)addCiecleZoomAnimation:(ACECircleZoomAnimationType)type
                        toView:(UIView *)view
                    fromRadius:(CGFloat)fromRadius
                      toRadius:(CGFloat)toRadius
                      duration:(NSTimeInterval)duration
             completionHandler:(ACEAnimateCompletionBlock)completion{
    CGPoint center = [self circleCenterForAnimation:type inView:view];
    CAShapeLayer *circleLayer=[CAShapeLayer layer];
    CGFloat minRadius = MIN(fromRadius, toRadius);
    
    circleLayer.frame = CGRectMake(center.x - minRadius, center.y - minRadius, 2 * minRadius, 2 * minRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(minRadius,minRadius) radius:minRadius startAngle:0 endAngle:2*M_PI clockwise:NO];
    circleLayer.path = path.CGPath;
    view.layer.mask = circleLayer;
    
    POPBasicAnimation *animation = [self circleZoomAnimationFromRadius:fromRadius toRadius:toRadius duration:duration];
    [animation setCompletionBlock:^(POPAnimation * _, BOOL finished) {
        if(completion) completion(finished);
    }];
    [circleLayer pop_addAnimation:animation forKey:@"ACECircleZoom"];
}





+ (CGPoint)circleCenterForAnimation:(ACECircleZoomAnimationType)type inView:(UIView *)view{
    CGSize size = view.frame.size;
    switch (type) {
        case ACECircleZoomAnimationAtCenter:        return CGPointMake(size.width / 2, size.height / 2);
        case ACECircleZoomAnimationAtLeftTop:       return CGPointZero;
        case ACECircleZoomAnimationAtRightTop:      return CGPointMake(size.width, 0);
        case ACECircleZoomAnimationAtLeftBottom:    return CGPointMake(0, size.height);
        case ACECircleZoomAnimationAtRightBottom:   return CGPointMake(size.width, size.height);
    }
}
+ (CGFloat)circleMaxRadiusForAnimation:(ACECircleZoomAnimationType)type inView:(UIView *)view{
    CGFloat longer = MAX(view.frame.size.width, view.frame.size.height);
    longer = MAX(longer, 2);
    switch (type) {
        case ACECircleZoomAnimationAtCenter:
            return longer * 0.71;   // 2^0.5/2
        default:
            return longer * 1.42;   // 2^0.5
    }
}

+ (POPBasicAnimation *)circleZoomAnimationFromRadius:(CGFloat)fromRadius toRadius:(CGFloat)toRadius duration:(NSTimeInterval)duration{
    POPBasicAnimation *animation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    animation.fromValue = [NSValue valueWithCGSize:CGSizeMake(fromRadius, fromRadius)];
    animation.toValue = [NSValue valueWithCGSize:CGSizeMake(toRadius, toRadius)];
    animation.duration = duration;
    return animation;
    
}

@end


@interface ACEBounceMoveAnimation : NSObject<ACEAnimation>

@end
@implementation ACEBounceMoveAnimation

+ (NSSet<NSNumber *> *)availableAnimationIDs{
    return [NSSet setWithArray:@[@(ACEBounceMoveAnimationFromLeft),@(ACEBounceMoveAnimationFromTop),@(ACEBounceMoveAnimationFromRight),@(ACEBounceMoveAnimationFromBottom)]];
    //return [NSSet set];
}

+ (ACEAnimationID)closeAnimationForOpenAnimation:(ACEAnimationID)openAnimationID{
    if (![[self availableAnimationIDs] containsObject:@(openAnimationID)]) {
        return kACEAnimationNone;
    }
    return openAnimationID;
}

+ (void)addOpeningAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    
    CGPoint direction = [self moveDirectionForAnimation:(ACEBounceMoveAnimationType)animationID];
    CGRect originFrame = toView.frame;
    CGFloat viewHeight = originFrame.size.height;
    CGFloat viewWidth = originFrame.size.width;
    CGPoint originCenter = toView.center;
    POPSpringAnimation * animation = [self bounceMoveAnimationWithConfig:config];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(originCenter.x + direction.x * viewWidth, originCenter.y + direction.y * viewHeight)];
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
        if(!finish){
            toView.center = originCenter;
        }
        if(completion) completion(finish);
    }];
    [toView pop_addAnimation:animation forKey:@"ACEBounceMove"];
}

+ (void)addClosingAnimationWithID:(ACEAnimationID)animationID fromView:(UIView *)fromView toView:(UIView *)toView duration:(NSTimeInterval)duration configuration:(NSDictionary *)config completionHandler:(ACEAnimateCompletionBlock)completion{
    if (![[self availableAnimationIDs] containsObject:@(animationID)]) {
        if(completion) completion(NO);
        return;
    }
    CGPoint direction = [self moveDirectionForAnimation:(ACEBounceMoveAnimationType)animationID];
    CGRect originFrame = fromView.frame;
    CGFloat viewHeight = originFrame.size.height;
    CGFloat viewWidth = originFrame.size.width;
    CGPoint originCenter = fromView.center;
    POPSpringAnimation * animation = [self bounceMoveAnimationWithConfig:config];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(originCenter.x + 2 * direction.x * viewWidth, originCenter.y + 2 * direction.y * viewHeight)];
    [animation setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
        if(!finish){
            fromView.center = originCenter;
        }
        if(completion) completion(finish);
    }];
    [fromView pop_addAnimation:animation forKey:@"ACEBounceMove"];
}

+ (POPSpringAnimation *)bounceMoveAnimationWithConfig:(NSDictionary *)config{
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    NSNumber *bounciness = numberArg(config[@"bounciness"]);
    NSNumber *speed = numberArg(config[@"speed"]);
    CGFloat (^toRate)(NSNumber *num) = ^CGFloat(NSNumber *num){
        CGFloat number = num.floatValue;
        if (number < 0) {
            return 0;
        }
        if (number > 1) {
            return 1;
        }
        return number;
    };
    animation.springBounciness = bounciness ? toRate(bounciness) * 20 : 12;
    animation.springSpeed = speed ? toRate(speed) * 20 : 8;
    return animation;
}


+ (CGPoint)moveDirectionForAnimation:(ACEBounceMoveAnimationType)type{
    switch (type) {
        case ACEBounceMoveAnimationFromLeft:    return CGPointMake(-1, 0);
        case ACEBounceMoveAnimationFromTop:     return CGPointMake(0,-1);
        case ACEBounceMoveAnimationFromRight:   return CGPointMake(1,0);
        case ACEBounceMoveAnimationFromBottom:  return CGPointMake(0,1);
    }
}


@end

