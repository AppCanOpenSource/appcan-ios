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

#import "BStatusBarWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "BUtility.h"

@implementation BStatusBarWindow
@synthesize mInitOrientation;
@synthesize mAlertSoundID;

- (void)dealloc {
	if (mTextView.superview) {
		[mTextView removeFromSuperview];
	}
	AudioServicesDisposeSystemSoundID(mAlertSoundID);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame andNotifyText:(NSString*)notifyText {
    self = [super initWithFrame:frame];
    if (self) {
		UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.backgroundColor = [UIColor redColor];
		self.opaque = YES;
		mInitOrientation = orientation;
		mTextView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
		mTextView.backgroundColor = [UIColor clearColor];
        if (__IPHONE_OS_VERSION_MAX_ALLOWED>__IPHONE_6_0) {
            mTextView.textAlignment = NSTextAlignmentCenter;
        }else{
            mTextView.textAlignment = NSTextAlignmentCenter;
        }
		mTextView.numberOfLines = 1;
		mTextView.textColor = [UIColor whiteColor];
		mTextView.text = notifyText;
		[mTextView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
		switch (orientation) {
			case UIInterfaceOrientationPortrait:
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.01f];
				[mTextView layer].transform = CATransform3DMakeRotation(0, 0.0f, 0.0f, 1.0f);
				[UIView commitAnimations];
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.01f];
				[mTextView layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
				[UIView commitAnimations];
				break;
			case UIInterfaceOrientationLandscapeLeft:
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.01f];
				[mTextView layer].transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
				[UIView commitAnimations];
				break;
			case UIInterfaceOrientationLandscapeRight:
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:0.01f];
				[mTextView layer].transform = CATransform3DMakeRotation(M_PI/2, 0.0f, 0.0f, 1.0f);
				[UIView commitAnimations];
				break;
			default:
				break;
		}
		if ([BUtility isIpad]) {
			mTextView.font = [UIFont systemFontOfSize:F_SBWND_FONT_SIZE_PAD];
		} else {
			mTextView.font = [UIFont systemFontOfSize:F_SBWND_FONT_SIZE_PHONE];
		}
		NSURL* alert_sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound/collision" ofType:@"wav"]];
		AudioServicesCreateSystemSoundID((CFURLRef)alert_sound_url, &mAlertSoundID);
		[self addSubview:mTextView];
		[mTextView release];
    }
    return self;
}

- (void)setNotifyText:(NSString*)inNotifyText {
	[mTextView setText:inNotifyText];
}

@end
