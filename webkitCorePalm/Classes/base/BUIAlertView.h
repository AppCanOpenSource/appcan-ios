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

typedef NS_ENUM(NSInteger,ACEBUIAlertViewType){
    ACEBUIAlertViewTypeAlert = 0,
    ACEBUIAlertViewTypeConfirm,
    ACEBUIAlertViewTypePrompt
};


@interface BUIAlertView : NSObject
@property (nonatomic, assign)ACEBUIAlertViewType mType;
@property (nonatomic, strong) UIAlertView *mAlertView;
@property (nonatomic, strong) UITextField *mTextField;

- (instancetype)initWithType:(ACEBUIAlertViewType)type;


@end
