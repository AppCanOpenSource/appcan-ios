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
#import "AppItemView.h"

#import "PullDownRefreshHeaderView.h"

@protocol MySpcViewDelegate;
 

@interface MySpaceView : UIView <UIScrollViewDelegate,PullDownRefreshHeaderDelegate,AppItemDelegate,ASIProgressDelegate,UIActionSheetDelegate>{
	UIScrollView *mainView;
	UIImageView *popAppView;
	UIView *topView;
	UIImageView *myAppView;
	UIView *bottomView;
	id<MySpcViewDelegate> _delegate;
	BOOL actionShowed;
	BOOL moreDisplay;
	//下拉刷新
	PullDownRefreshHeaderView *_refreshHeaderView;
	BOOL _reloading;
	
}
@property(nonatomic,assign)BOOL moreDisplay;
@property(nonatomic,assign)BOOL actionShowed;
@property (nonatomic,retain)id<MySpcViewDelegate> delegate;
-(void)drawTopView:(NSArray *)itemsArray;
-(void)drawMyAppView:(NSArray *)itemArray;
-(void)widgetStartDownload:(NSMutableDictionary *)newItemSet;
-(void)widgetFinishDld:(AppItemView *)dItem;
-(void)showMoreAppBtn:(BOOL)showTag;

- (void)reloadDataSource;
- (void)doneLoadingData;
@end
@protocol MySpcViewDelegate <NSObject>
-(void)appCenterSetting;
-(void)appCenterCloseBtnClick;
-(void)appItemClick:(NSString *)appID;
-(void)appPressLongForDelete:(NSString *)appID;
-(void)notifyAppCenterReloadData;
@end
