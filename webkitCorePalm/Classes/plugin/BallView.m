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

#import "BallView.h"



@implementation BallView

@synthesize backView;

@synthesize image;

@synthesize currentPoint;

@synthesize previousPoint;

@synthesize acceleration;

@synthesize ballXVelocity;

@synthesize ballYVelocity;

@synthesize soundFileURLRef;
@synthesize soundFileObject;

static CGFloat invalidateX = 80.0f;
static CGFloat invalidateY = 80.0f;
static CGFloat invalidateWidth;
static CGFloat invalidateHeight;

static BOOL bDraw = YES;

- (void) initData {
	bDraw = YES;
	ballXVelocity = 0.0f;
	ballYVelocity = 0.0f;
}
 
- (id)initWithCoder:(NSCoder *)coder {
	
    if (self = [super initWithCoder:coder]) {
		self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"img/my_space_ball.png"];
		
        self.currentPoint = CGPointMake((self.bounds.size.width / 2.0f) +
										
                                        (image.size.width / 2.0f), 
										
                                        (self.bounds.size.height / 2.0f) + (image.size.height / 2.0f));
		
		
		
        ballXVelocity = 0.0f;
        ballYVelocity = 0.0f;
	}
	
    return self;
	
}

- (void) enterApp {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BallEnter" object:nil];
}


- (id)initWithFrame:(CGRect)frame {
	
    if (self = [super initWithFrame:frame]) {
		[self setUserInteractionEnabled:YES];
		UIButton *clickImageButton = [UIButton buttonWithType:(UIButtonType)UIButtonTypeCustom];
		
		UIImage *buttonImage = [UIImage imageNamed:@"img/my_space_ball_enter.png"];
		
		invalidateWidth = buttonImage.size.width/2.0f;
		invalidateHeight = buttonImage.size.height/2.0f;
		[clickImageButton setImage:buttonImage forState:(UIControlState)UIControlStateNormal];
		[clickImageButton addTarget:self action: @selector(enterApp) forControlEvents:(UIControlEvents)UIControlEventTouchDown];
		clickImageButton.frame = CGRectMake(invalidateX, invalidateY, invalidateWidth, invalidateHeight); // 画球�
        // Initialization code
		[self setAutoresizesSubviews:YES];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		self.image = [UIImage imageNamed:@"img/my_space_ball.png"];
		imageView = [[UIImageView alloc] initWithImage:self.image];
		[imageView setUserInteractionEnabled:YES];
		backView =  [[UIImageView alloc] initWithFrame:self.bounds];
		[backView setUserInteractionEnabled:YES];
		[backView setImage:[UIImage imageNamed:@"img/my_space_ball_bg.png"]];
		[backView addSubview:clickImageButton];
		[backView addSubview:imageView];
		[self addSubview:backView];
		
        self.currentPoint = CGPointMake((self.bounds.size.width / 2.0f) +
										
                                        (image.size.width / 2.0f), 
										
                                        (self.bounds.size.height / 2.0f) + (image.size.height / 2.0f));
		
		
		
        ballXVelocity = 0.0f;
        ballYVelocity = 0.0f;
    }
	{
		// Create the URL for the source audio file. The URLForResource:withExtension: method is
		//    new in iOS 4.0.
		NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"collision" withExtension: @"wav"];
		
		// Store the URL as a CFURLRef instance
		self.soundFileURLRef = (CFURLRef) ([tapSound retain]);
		
		// Create a system sound object representing the sound file.
		AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileObject);
	}
	
    return self;
	
}

- (void)dealloc {
	{
		AudioServicesDisposeSystemSoundID(soundFileObject);
		CFRelease(soundFileURLRef);
	}
	
    [image release];
	
    [acceleration release];
	[backView release];
	[imageView release];
	
    [super dealloc];
	
}



#pragma mark -

- (CGPoint)currentPoint {
    return currentPoint;
}

- (void)setCurrentPoint:(CGPoint)newPoint {
	
	if(!bDraw)
		return;
	
    previousPoint = currentPoint;
	
    currentPoint = newPoint;
	
	
	
    if (currentPoint.x < 0) {
		
        currentPoint.x = 0;
		
        //ballXVelocity = 0;
		
        ballXVelocity = - (ballXVelocity / 1.6);
		if (ballXVelocity < -0.1f || ballXVelocity > 0.1f)
			AudioServicesPlaySystemSound(soundFileObject);

		
    }
	
    if (currentPoint.y < 0){
		
        currentPoint.y = 0;
		
        //ballYVelocity = 0;
		
        ballYVelocity = - (ballYVelocity / 1.6);
		if (ballYVelocity < -0.1f || ballYVelocity > 0.1f)
			AudioServicesPlaySystemSound(soundFileObject);
    } 
	
    if (currentPoint.x > self.bounds.size.width - image.size.width) {
		
        currentPoint.x = self.bounds.size.width  - image.size.width; 
		
		//ballXVelocity = 0;
		
        ballXVelocity = - (ballXVelocity / 1.6);
		if (ballXVelocity < -0.1f || ballXVelocity > 0.1f)
			AudioServicesPlaySystemSound(soundFileObject);
    }
	
    if (currentPoint.y > self.bounds.size.height - image.size.height) {
		
        currentPoint.y = self.bounds.size.height - image.size.height;
		
        //ballYVelocity = 0;
		
        ballYVelocity = - (ballYVelocity /1.6);
		if (ballYVelocity < -0.1f || ballYVelocity > 0.1f)
			AudioServicesPlaySystemSound(soundFileObject);

    }
	CGRect frameRect;
	frameRect.origin = currentPoint;
	frameRect.size = image.size;
	[imageView setFrame:frameRect];
}

- (void)draw {
	if (!bDraw)
		return;
	
    static NSDate *lastDrawTime;
	
    if (lastDrawTime != nil) {
		
        NSTimeInterval secondsSinceLastDraw = -([lastDrawTime timeIntervalSinceNow]);
		
		
		if (fabs (acceleration.y) > 1.0) {
			 ballYVelocity = ballYVelocity + -(acceleration.y * secondsSinceLastDraw*20);
		}
		else {
			ballYVelocity = ballYVelocity + -(acceleration.y * secondsSinceLastDraw);
		}

        if (fabs (acceleration.x) > 1.0) {
			ballXVelocity = ballXVelocity + acceleration.x * secondsSinceLastDraw*20;
		}
		else {
			ballXVelocity = ballXVelocity + acceleration.x * secondsSinceLastDraw;
		}   
		CGFloat xAcceleration;
		CGFloat yAcceleration; 
		UIInterfaceOrientation cOrientation = [[UIApplication sharedApplication] statusBarOrientation];
		if (cOrientation == UIInterfaceOrientationPortrait) {
			 xAcceleration = secondsSinceLastDraw * ballXVelocity * kVelocityMultiplier;
			  yAcceleration = secondsSinceLastDraw * ballYVelocity * kVelocityMultiplier;
		}else if (cOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			xAcceleration = -(secondsSinceLastDraw * ballXVelocity * kVelocityMultiplier);
			yAcceleration = -(secondsSinceLastDraw * ballYVelocity * kVelocityMultiplier);
		}else if (cOrientation == UIInterfaceOrientationLandscapeLeft) {
			xAcceleration = secondsSinceLastDraw * ballXVelocity * kVelocityMultiplier;
			yAcceleration = secondsSinceLastDraw * ballYVelocity * kVelocityMultiplier;
		}else if (cOrientation == UIInterfaceOrientationLandscapeRight) {
			xAcceleration = secondsSinceLastDraw * ballXVelocity * kVelocityMultiplier;
			yAcceleration = secondsSinceLastDraw * ballYVelocity * kVelocityMultiplier;
		}
		{
		CGFloat currentPointX = currentPoint.x;
		CGFloat currentPointY = currentPoint.y;
	if (currentPointX > invalidateX && 
				currentPointX < invalidateX + invalidateWidth && 
				currentPointY > invalidateY &&
				currentPointY < invalidateY + invalidateHeight) {
//				UIAlertView* uiAlertView= [[UIAlertView alloc] initWithTitle:@"\n提示" 
//																	 message:@"您已进入重灾区！" 
//																	delegate:self 
//														   cancelButtonTitle:@"确定" 
//														   otherButtonTitles:nil];
//				[uiAlertView show];
//				[uiAlertView release];
			    [[NSNotificationCenter defaultCenter] postNotificationName:@"BallEnter" object:nil];
				//bDraw = NO;
				[lastDrawTime release];
				lastDrawTime = [[NSDate alloc] init];
				return;
			}
		}
		
        self.currentPoint = CGPointMake(self.currentPoint.x + xAcceleration,
										
                                        self.currentPoint.y +yAcceleration);
		
    }
	
    // Update last time with current time
	 {
    [lastDrawTime release];
		lastDrawTime = nil;
    lastDrawTime = [[NSDate alloc] init];
	}	
}
//
//- (void)drawRect:(NSRect)rect
//
//{
//	
//    CGContextRef myContext = [[NSGraphicsContext currentContext] graphicsPort];
//	
//	// ********** Your drawing code here ********** // 2
//	
//    CGContextSetRGBFillColor(myContext, 1, 0, 0, 1);// 3
//	
//    CGContextFillRect (myContext, CGRectMake (0, 0, 200, 100 ));// 4
//	
//    CGContextSetRGBFillColor(myContext, 0, 0, 1, .5);// 5
//	
//    CGContextFillRect (myContext, CGRectMake (0, 0, 100, 200));// 6
//	
//}

@end

