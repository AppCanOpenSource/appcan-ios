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
#define F_BRW_WND_SWITCH_ANIMI_ID_NONE						0
#define F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_PUSH		1
#define F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_PUSH		2
#define F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_PUSH		3
#define F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_PUSH		4
#define F_BRW_WND_SWITCH_ANIMI_ID_FADE_IN_FADE_OUT			5
#define F_BRW_WND_SWITCH_ANIMI_ID_LEFT_FLIP					6
#define F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_FLIP				7
#define F_BRW_WND_SWITCH_ANIMI_ID_RIPPLE					8
#define F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_MOVEIN		9
#define F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_MOVEIN		10
#define F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_MOVEIN		11
#define F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_MOVEIN		12
#define F_BRW_WND_SWITCH_ANIMI_ID_LEFT_TO_RIGHT_REVEAL		13
#define F_BRW_WND_SWITCH_ANIMI_ID_RIGHT_TO_LEFT_REVEAL		14
#define F_BRW_WND_SWITCH_ANIMI_ID_TOP_TO_BOTTOM_REVEAL		15
#define F_BRW_WND_SWITCH_ANIMI_ID_BOTTOM_TO_TOP_REVEAL		16

@interface BAnimation : NSObject {
}
+ (int)ReverseAnimiId:(int)inAnimiID;
+ (BOOL)isMoveIn:(int)inAnimiID;
+ (BOOL)isPush:(int)inAnimiID;
+ (void)doMoveInAnimition:(UIView*)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime;
+ (void)doPushAnimition:(UIView *)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime;
+ (void)doPushAnimition:(UIView *)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime completion:(void (^)(BOOL finished))completion;
+ (void)doPushCloseAnimition:(UIView *)inView animiId:(int)inAnimiId animiTime:(float)inAnimiTime completion:(void (^)(BOOL finished))completion;
+ (void)SwapAnimationWithView:(UIView*)inView AnimiId:(int)inAnimiID AnimiTime:(float)inAnimiTime;
@end
