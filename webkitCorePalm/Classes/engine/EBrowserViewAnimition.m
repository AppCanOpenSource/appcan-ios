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

#import "EBrowserViewAnimition.h"
#import "BAnimationTransform.h"
#import "BUtility.h"

@implementation EBrowserViewAnimition
@synthesize meBrwView;
@synthesize mName;
@synthesize mDelay;
@synthesize mDuration;
@synthesize mCurve;
@synthesize mRepeatCount;
@synthesize mAutoReverse;
@synthesize mTransformArray;
@synthesize mFinishFunc;
@synthesize mAlpha;
@synthesize mOldTransform;

- (void)dealloc {
	[mName release];
    [mFinishFunc release];
    [super dealloc];
}


- (id)init {
	if (self = [super init]) {
		mName = nil;
		mDelay = 0.0f;
		mDuration = 0.2f;
		mCurve = BrwViewAnimationCurveLinear;
		mRepeatCount = 0;
		mAutoReverse = NO;
		mTransformArray = [[NSMutableArray alloc]initWithCapacity:1];
		mFinishFunc = nil;
		mAlpha = 1.0f;
	}
	return self;
}

- (void)clean {
	self.mName = nil;
	mDelay = 0.0f;
	mDuration = 0.2f;
	mCurve = BrwViewAnimationCurveLinear;
	mRepeatCount = 0;
	mAutoReverse = NO;
	[mTransformArray removeAllObjects];
	self.mFinishFunc = nil;
	mAlpha = 1.0f;
}

- (void)doAnimition:(UIView*)inView {
	self.meBrwView = (EBrowserView*)inView;
	[UIView beginAnimations:mName context:inView];
	[UIView setAnimationDelay:mDelay];
	[UIView setAnimationDuration:mDuration];
	[UIView setAnimationCurve:mCurve];
	[UIView setAnimationRepeatCount:mRepeatCount];
	[UIView setAnimationRepeatAutoreverses:mAutoReverse];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	CATransform3D commitTransForm = inView.layer.transform;
	self.mOldTransform = inView.layer.transform;
	for (BAnimationTransform *transForm in mTransformArray) {
		commitTransForm = CATransform3DConcat(commitTransForm, transForm.mTransForm3D);
	}
	inView.layer.transform = commitTransForm;
	inView.alpha = mAlpha;
	[UIView commitAnimations];
}

- (void)notifyAnimationFinish {
	if (meBrwView) {
		[meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onAnimationFinish!=null){uexWindow.onAnimationFinish();}"];
	}
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    @try {
        UIView *view = (UIView*)context;
        if (mAutoReverse) {
            [UIView beginAnimations:mName context:view];
            [UIView setAnimationDuration:0.1];
            view.layer.transform = self.mOldTransform;
            [UIView commitAnimations];
        }
        [self performSelectorOnMainThread:@selector(notifyAnimationFinish) withObject:nil waitUntilDone:YES];
    }
    @catch (NSException *exception) {
        [BUtility writeLog:[NSString stringWithFormat:@"animationDidStop==>catch==>%@,%@,%@",[exception name],[exception reason],[[exception userInfo] description]]];
    }
    @finally {
        //
    }
    
    
}
@end
