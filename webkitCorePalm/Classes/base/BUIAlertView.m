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

#import "BUIAlertView.h"

@implementation BUIAlertView


- (instancetype)initWithType:(ACEBUIAlertViewType)type{
    self = [self init];
    if (self) {
        _mType = type;
    }
    return self;
}

- (void)dealloc {
	if (_mTextField) {
		[_mTextField removeFromSuperview];
		_mTextField = nil;
	}
	if (_mAlertView) {
		[_mAlertView dismissWithClickedButtonIndex:0 animated:YES];
		_mAlertView = nil;
	}
}
@end
