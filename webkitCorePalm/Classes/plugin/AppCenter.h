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
#import "MySpaceView.h"
#import "AppItemView.h" 
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "EBrowserView.h"
#import "MBProgressHUD.h"
#import "sqlite3.h"

 
#define	WIDGET_START_SUCCESS	0
#define WIDGET_START_NOT_EXIST	1
#define WIDGET_START_FAIL		2
 


@interface AppCenter : NSObject <MySpcViewDelegate>{
	MySpaceView *sView;
	//保存一份app的字典，方便下载
	NSMutableDictionary *recmdAppRefDict;
	NSMutableDictionary *myAppRefDict;
 
	NSString *portalID;
	//下载队列
	ASINetworkQueue *dQueue;
	//主widget的目录
	NSString *mainWgtPath;		 //主widget的sandbox路径
	NSString *currentSessionKey; //当前的sessionkey
	NSString *availableSessionKey;//有效的sessionkey
	NSString *activeAppId;
	BOOL userHasLogin;
	NSString *userID;
	EBrowserView *eBView;
	BOOL needDownload;
	BOOL startWgtShowLoading;
	sqlite3 *ac_db_obj;
	
	NSString *myAppTableName;

}
@property(nonatomic,retain)NSString *myAppTableName;
@property(nonatomic,assign)BOOL startWgtShowLoading;
@property(nonatomic,assign)BOOL userHasLogin;
@property(nonatomic,assign)EBrowserView *eBView;
@property(nonatomic,copy)NSString *portalID;
@property(nonatomic,retain)NSString *availableSessionKey;
@property(nonatomic,retain)NSString *mainWgtPath;
@property(nonatomic,retain)NSString *currentSessionKey;
@property(nonatomic, retain)NSMutableDictionary *recmdAppRefDict;
@property(nonatomic, retain)NSMutableDictionary *myAppRefDict;
@property(nonatomic, assign)MySpaceView *sView;
@property(nonatomic,getter = hasShowTag)BOOL showTag;
-(void)openAppCenterWithEBrwView:(EBrowserView *)eView;
-(void)downloadWidgetWithItem:(AppItemView *)aItem;
-(void)userLoginSuccess:(NSString *)userID;
-(void)userLoginFail;
-(void)userLoginStart;
-(void)moreAppDownload:(NSString *)retJson;
-(void)drawBottomView:(NSMutableDictionary *)recAppArray;
-(void)cleanUserInfo;
-(void)hideLoading:(int)startTag retAppId:(NSString *)backAppId;
-(void)loadMyAppList;
-(void)loadPopAppList;
-(void)drawCommendApp:(NSMutableDictionary *)recAppDict;

@end
