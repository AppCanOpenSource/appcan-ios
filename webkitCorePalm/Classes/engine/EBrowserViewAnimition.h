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
#import "EBrowserView.h"
#import <QuartzCore/CALayer.h>

enum brwViewAnimitionCurve {
	BrwViewAnimationCurveEaseInOut = 1,
	BrwViewAnimationCurveEaseIn,
	BrwViewAnimationCurveEaseOut,
	BrwViewAnimationCurveLinear
};

@interface EBrowserViewAnimition : NSObject {
	EBrowserView *meBrwView;
	NSString *mName;
	float mDelay;
	float mDuration;
	int mCurve;
	float mRepeatCount;
	BOOL mAutoReverse;
	NSMutableArray *mTransformArray;
	NSString *mFinishFunc;
	float mAlpha;
	CATransform3D mOldTransform;
}
@property (nonatomic, assign)EBrowserView *meBrwView;
@property (nonatomic, copy)NSString *mName;
@property float mDelay;
@property float mDuration;
@property int mCurve;
@property float mRepeatCount;
@property BOOL mAutoReverse;
@property (nonatomic, assign)NSMutableArray *mTransformArray;
@property (nonatomic, copy)NSString *mFinishFunc;
@property float mAlpha;
@property CATransform3D mOldTransform;

- (id)init;
- (void)doAnimition:(UIView*)inView;
- (void)clean;
@end
