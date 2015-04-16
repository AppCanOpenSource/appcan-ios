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
#import <UIKit/UIKit.h>


#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
typedef enum {
	EBounceViewStatusReleaseToReload,
	EBounceViewStatusPullToReload,
	EBounceViewStatusLoading
}EBounceViewStatus;

typedef enum {
	EBounceViewTypeTop,
	EBounceViewTypeBottom
}EBounceViewType;

@interface EBrowserViewBounceView : UIView {
	int						  mType;
	NSDate*                   mLastUpdatedDate;
	UILabel*                  mLastUpdatedLabel;
	UILabel*                  mStatusLabel;
	UIImageView*              mArrowImage;
	UIActivityIndicatorView*  mActivityView;
    NSMutableDictionary*      bounceParamsDict;//8.22
    
    UIImageView * mActivityImageView;
}
- (void)setCurrentDate;
- (void)setUpdateDate:(NSDate*)date;
- (void)setStatus:(EBounceViewStatus)status;
-(void)setLevelText:(NSString*)inText;
//- (id)initWithFrame:(CGRect)frame andType:(int)inType;
- (id)initWithFrame:(CGRect)frame andType:(int)inType params:(NSMutableDictionary*)dict;

-(void)resetDataWithType:(int)inType andParams:(NSMutableDictionary *)dict;
@property(nonatomic,retain)NSString * projectID;

@property(nonatomic,assign) BOOL isImgCenter;

@end
