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

#import <UIKit/UIKit.h>
#define F_BUIALERTVIEW_TYPE_ALERT		0
#define F_BUIALERTVIEW_TYPE_CONFIRM		1
#define F_BUIALERTVIEW_TYPE_PROMPT		2

@interface BUIAlertView : NSObject {
	int mType;
	UIAlertView *mAlertView;
	UITextField *mTextField;
}
@property int mType;
@property (nonatomic, retain) UIAlertView *mAlertView;
@property (nonatomic, retain) UITextField *mTextField;

- (void)initWithType:(int)inType;
@end
