/**
 *
 *	@file   	: ACEViewControllerAnimator.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/30
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


#import "ACEViewControllerAnimator.h"


@interface ACEViewControllerOpeningAnimator : ACEViewControllerAnimator

@end

@interface ACEViewControllerClosingAnimator : ACEViewControllerAnimator

@end
@interface ACEViewControllerAnimator()
@property (nonatomic,assign)NSTimeInterval duration;
@property (nonatomic,assign)ACEAnimationID animationID;
@property (nonatomic,strong,nullable)NSDictionary *config;
@end

@implementation ACEViewControllerAnimator


+ (nullable instancetype)openingAnimatorWithAnimationID:(ACEAnimationID)animationID duration:(NSTimeInterval)duration config:(NSDictionary *)config{
    return [[ACEViewControllerOpeningAnimator alloc] initWithAnimationID:animationID duration:duration config:config];
}

+ (nullable instancetype)closingAnimatorWithAnimationID:(ACEAnimationID)animationID duration:(NSTimeInterval)duration config:(NSDictionary *)config{
    return [[ACEViewControllerClosingAnimator alloc] initWithAnimationID:animationID duration:duration config:config];
}
- (nullable instancetype)initWithAnimationID:(ACEAnimationID)animationID duration:(NSTimeInterval)duration config:(NSDictionary *)config{
    if (![ACEAnimations isAnimationValid:animationID]) {
        return nil;
    }
    self = [super init];
    if (self) {
        _duration = duration;
        _animationID = animationID;
        _config = config;
    }
    return self;
}
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return self.duration;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    NSAssert(NO, @"subclass must override this method");
}

@end



@implementation ACEViewControllerOpeningAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = transitionContext.containerView;
    toView.frame = fromView.frame;
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    [ACEAnimations addOpeningAnimationWithID:self.animationID
                                    fromView:fromView
                                      toView:toView
                                    duration:self.duration
                               configuration:self.config
                           completionHandler:^(BOOL finished) {
                               [transitionContext completeTransition:YES];
                           }];
}

@end


@implementation ACEViewControllerClosingAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = transitionContext.containerView;
    toView.frame = fromView.frame;
    [containerView addSubview:toView];
    [containerView addSubview:fromView];
    
    [ACEAnimations addClosingAnimationWithID:self.animationID
                                    fromView:fromView
                                      toView:toView
                                    duration:self.duration
                               configuration:self.config
                           completionHandler:^(BOOL finished) {
                               [transitionContext completeTransition:YES];
                           }];
}

@end


