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
#import "ASIProgressDelegate.h"
#import "UIImageView+WebCache.h"
@protocol AppItemDelegate <NSObject>


-(void)iconItemClick:(NSString *)appId;
-(void)sendAppIdForLongPress:(NSString *)appId;
@end

@interface AppItemView : UIView <ASIProgressDelegate,SDWebImageManagerDelegate>{
	NSString *softwareId;
	NSString *appId;
	NSString *downloadUrl;
	NSString *appName;
	NSURL *appIconUrl;
	NSString *appSize;
	NSString *appMode;
	//0 未下载
	//1 在下载
	//2下载完成
	//3安装完成
	NSInteger downloadTag;
	id<AppItemDelegate> _delegate;
	UIProgressView *progressView;
	UIButton *btn;
	//标志是否是我的应用的app，方便卸载
	BOOL isMyAppItem;
	UIActivityIndicatorView *actView;
}
//是否已经下载的标志
@property(nonatomic,retain)UIActivityIndicatorView *actView;
@property(nonatomic,retain)UIButton *btn;
@property(nonatomic,assign)BOOL isMyAppItem;
@property(nonatomic,assign)NSInteger downloadTag;
@property(nonatomic,retain)NSString *softwareId;
@property(nonatomic,retain)NSString *appId;
@property(nonatomic,retain)NSString *downloadUrl;
@property(nonatomic,retain)NSString *appName;
@property(nonatomic,retain)NSURL *appIconUrl;
@property(nonatomic, retain)NSString *appSize;
@property(nonatomic,retain)	NSString *appMode;

@property(nonatomic,retain)UIProgressView *progressView;
@property(nonatomic,assign)id<AppItemDelegate>delegate;
- (id)initWithFrame:(CGRect)frame image:(NSURL *)imgUrl title:(NSString *)titleText appTag:(NSString *)_appId;
-(void)updateImage;
@end
