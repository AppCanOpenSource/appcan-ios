/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#define kVelocityMultiplier    1000



@interface BallView : UIView {
	
    UIImage *image;
	
	
	
    CGPoint    currentPoint;
	
    CGPoint    previousPoint;
	
	
	
    UIAcceleration *acceleration;
	
    CGFloat    ballXVelocity;
	
    CGFloat     ballYVelocity;
	UIImageView *imageView;
	UIImageView *backView;
	
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
}
@property(nonatomic, retain)UIImageView *backView;
@property (nonatomic, retain) UIImage *image;

@property CGPoint currentPoint;

@property CGPoint previousPoint;

@property (nonatomic, retain) UIAcceleration *acceleration;

@property CGFloat ballXVelocity;

@property CGFloat ballYVelocity;

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

- (void)draw;

@end


