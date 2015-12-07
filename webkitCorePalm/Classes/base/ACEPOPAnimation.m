/**
 *
 *	@file   	: ACEPOPAnimation.m  in AppCanEngine Project
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

#import "ACEPOPAnimation.h"
#import <pop/pop.h>

#define ACEPOPAnimateConfigPropertyValid(property,maxValue,defaultValue) ((config.property>=0 && config.property <=1)?config.property*maxValue:defaultValue)

static NSTimeInterval ACEPOPAnimationDefaultDuration=0.26;
@interface ACEPOPAnimateConfiguration ()
@property (nonatomic,assign)CGFloat bounciness;
@property (nonatomic,assign)CGFloat speed;
@end

@implementation ACEPOPAnimateConfiguration


+ (instancetype)configurationWithInfo:(NSDictionary *)Info{
    ACEPOPAnimateConfiguration *config=[[self alloc] init];
    if(config){
        config.duration=ACEPOPAnimationDefaultDuration;
        config.bounciness=Info[@"bounciness"]?[Info[@"bounciness"] floatValue]:-1;
        config.speed=Info[@"speed"]?[Info[@"speed"] floatValue]:-1;
    }
    return config;
}

@end

@implementation ACEPOPAnimation

+ (NSInteger)reverseAnimationId:(NSInteger)animationId{
    if(![self isPopAnimation:animationId]){
        return 0;
    }
    ACEPOPAnimateType type=(ACEPOPAnimateType)animationId;
    switch (type) {
        case ACEPOPAnimationCircleZoomAtCenter:
        case ACEPOPAnimationCircleZoomAtLeftTop:
        case ACEPOPAnimationCircleZoomAtRightTop:
        case ACEPOPAnimationCircleZoomAtLeftButtom:
        case ACEPOPAnimationCircleZoomAtRightButtom:
        case ACEPOPAnimationBounceFromLeft:
        case ACEPOPAnimationBounceFromTop:
        case ACEPOPAnimationBounceFromRight:
        case ACEPOPAnimationBounceFromBottom:
        case ACEPOPAnimationIdStart:{
            return type;
            break;
        }
        case ACEPOPAnimationIdEnd: {
            return 0;
            break;
        }
    }
}

+ (BOOL)isPopAnimation:(NSInteger)inAnimiID{
    if(inAnimiID > ACEPOPAnimationIdStart && inAnimiID < ACEPOPAnimationIdEnd){
        return YES;
    }
    return NO;
}

+ (void)doAnimationInView:(UIView *)inView
                     type:(ACEPOPAnimateType)type
            configuration:(ACEPOPAnimateConfiguration *)config
                     flag:(ACEPOPAnimateFlag)flag
               completion:(ACEPOPAnimateCompletionBlock)completion{

    switch (type) {
            //ZOOM Animation
        case ACEPOPAnimationCircleZoomAtCenter:
        case ACEPOPAnimationCircleZoomAtLeftTop:
        case ACEPOPAnimationCircleZoomAtRightTop:
        case ACEPOPAnimationCircleZoomAtLeftButtom:
        case ACEPOPAnimationCircleZoomAtRightButtom:{
            [self doCircleZoomAnimation:inView
                           animatedType:type
                          configuration:config
                                   flag:flag
                             completion:completion];
            break;
        }

            
        case ACEPOPAnimationBounceFromLeft:
        case ACEPOPAnimationBounceFromTop:
        case ACEPOPAnimationBounceFromRight:
        case ACEPOPAnimationBounceFromBottom: {
            [self doBounceAnimation:inView
                       animatedType:type
                      configuration:config
                               flag:flag
                         completion:completion];
            break;
        }
        case ACEPOPAnimationIdStart:
        case ACEPOPAnimationIdEnd:{
            break;
        }
            
    }
}

+ (void)doBounceAnimation:(UIView *)inView
             animatedType:(ACEPOPAnimateType)type
            configuration:(ACEPOPAnimateConfiguration *)config
                     flag:(ACEPOPAnimateFlag)flag
               completion:(ACEPOPAnimateCompletionBlock)completion{

    CGPoint direction;
    switch (type) {
        case ACEPOPAnimationBounceFromLeft: {
            direction=CGPointMake(-1, 0);
            break;
        }
        case ACEPOPAnimationBounceFromTop: {
            direction=CGPointMake(0,-1);
            break;
        }
        case ACEPOPAnimationBounceFromRight: {
            direction=CGPointMake(1,0);
            break;
        }
        case ACEPOPAnimationBounceFromBottom: {
            direction=CGPointMake(0,1);
            break;
        }
        default: {
            return;
            break;
        }
    }
    [inView pop_removeAllAnimations];
    CGRect oldFrame=inView.frame;
    CGFloat viewHeight=oldFrame.size.height;
    CGFloat viewWidth=oldFrame.size.width;
    CGPoint oldcenter=inView.center;
    POPSpringAnimation *center=[POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];

    center.springBounciness = ACEPOPAnimateConfigPropertyValid(bounciness,20,12);
    center.springSpeed = ACEPOPAnimateConfigPropertyValid(speed,20,8);
    
    //scale.springBounciness=center.springBounciness;
    //scale.springSpeed=center.springSpeed;
    
    [center setCompletionBlock:^(POPAnimation *anim, BOOL finish) {
        if(!finish){
            inView.center=oldcenter;
        }
        if(completion){
            completion();
        }
    }];
    switch (flag) {
        case ACEPOPAnimateWhenWindowOpening: {
            center.fromValue=[NSValue valueWithCGPoint:CGPointMake(oldcenter.x+direction.x*viewWidth, oldcenter.y+direction.y*viewHeight)];
            break;
        }
        case ACEPOPAnimateWhenWindowClosing: {
            center.toValue=[NSValue valueWithCGPoint:CGPointMake(oldcenter.x+2*direction.x*viewWidth, oldcenter.y+2*direction.y*viewHeight)];
            break;
        }
    }
    [inView pop_addAnimation:center forKey:@"center"];

}



+ (void)doCircleZoomAnimation:(UIView *)inView
         animatedType:(ACEPOPAnimateType)type
         configuration:(ACEPOPAnimateConfiguration *)config
                  flag:(ACEPOPAnimateFlag)flag
            completion:(ACEPOPAnimateCompletionBlock)completion{
    CGFloat inViewHeight=inView.frame.size.height;
    CGFloat inViewWidth=inView.frame.size.width;
    CGFloat minRadius=1;
    CGFloat maxRadius=(inViewHeight>inViewWidth)?inViewHeight*1.42:inViewWidth*1.42;//准确值应该是2^0.5
    CGPoint anchor;
    switch (type) {
        case ACEPOPAnimationCircleZoomAtCenter: {
            maxRadius=(inViewHeight>inViewWidth)?inViewHeight*0.71:inViewWidth*0.71;//准确值应该是0.5^0.5
            anchor=CGPointMake(inViewWidth/2, inViewHeight/2);
            break;
        }
        case ACEPOPAnimationCircleZoomAtLeftTop: {
            anchor=CGPointZero;
            break;
        }
        case ACEPOPAnimationCircleZoomAtRightTop: {
            anchor=CGPointMake(inViewWidth, 0);
            break;
        }
        case ACEPOPAnimationCircleZoomAtLeftButtom: {
            anchor=CGPointMake(0, inViewHeight);
            break;
        }
        case ACEPOPAnimationCircleZoomAtRightButtom: {
            anchor=CGPointMake(inViewWidth, inViewHeight);
            break;
        }
        default: {
            return;
            break;
        }
    }
    if(minRadius>maxRadius){
        //VIEW太小，直接返回
        return;
    }
    [inView.layer pop_removeAllAnimations];
    CAShapeLayer *circleLayer=[CAShapeLayer layer];
    circleLayer.frame=CGRectMake(anchor.x-minRadius, anchor.y-minRadius, 2*minRadius, 2*minRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(minRadius,minRadius) radius:minRadius startAngle:0 endAngle:2*M_PI clockwise:NO];
    circleLayer.path=path.CGPath;
    inView.layer.mask=circleLayer;
    POPBasicAnimation *scaleAnimation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    switch (flag) {
        case ACEPOPAnimateWhenWindowOpening: {
            scaleAnimation.fromValue=[NSValue valueWithCGSize:CGSizeMake(minRadius, minRadius)];
            scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(maxRadius, maxRadius)];
            break;
        }
        case ACEPOPAnimateWhenWindowClosing: {
            scaleAnimation.fromValue=[NSValue valueWithCGSize:CGSizeMake(maxRadius, maxRadius)];
            scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(minRadius, minRadius)];
            break;
        }

    }
    scaleAnimation.duration=config.duration;
    if(completion){
        [scaleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
            completion();
        }];
    }
    [circleLayer pop_addAnimation:scaleAnimation forKey:@"zoomAnimation"];
}
@end
