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

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#define F_SBWND_FONT_SIZE_PAD		24
#define F_SBWND_FONT_SIZE_PHONE		12

@interface BStatusBarWindow : UIWindow {
	UIDeviceOrientation mInitOrientation;
	UILabel *mTextView;
	SystemSoundID mAlertSoundID;
}
@property UIDeviceOrientation mInitOrientation;
@property (nonatomic,assign)SystemSoundID mAlertSoundID;

- (id)initWithFrame:(CGRect)frame andNotifyText:(NSString*)notifyText;
- (void)setNotifyText:(NSString*)inNotifyText;
@end
