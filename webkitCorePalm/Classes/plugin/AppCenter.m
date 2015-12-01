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

#import "AppCenter.h"
#import "EBrowserView.h"
#import "EBrowserController.h"
#import "EUExAppCenter.h"
#import "AppItemView.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "EBrowserWindow.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserWindowContainer.h"
#import "EUExWidget.h"
#import "JSON.h"
#import "BUtility.h"
#import "ZipArchive.h"
#import "EBrowserToolBar.h"
#import "EBrowserMainFrame.h"
#import "MBProgressHUD.h"
#import "ACUtility.h"
//获取推荐引用列表
#define APPLIST_URL @"http://open.appcan.cn/myspace/getAppList.action"
//获取我的引用列表
#define MY_APP_LIST_URL  @"http://open.appcan.cn/myspace/getMyAppList.action"
//获取sessionkey
#define SESSION_KEY_URL @"http://open.appcan.cn/oauth2/getTxSessionKey.do"
//安装上报
#define INSTALL_SUCCESS_URL @"http://open.appcan.cn/myspace/installWidget.action"
//卸载上报
#define UNINSTALL_FINISH_URL @"http://open.appcan.cn/myspace/unInstallWidget.action"
//启动上报
#define START_WIDGET_REPORT_URL @"http://open.appcan.cn/myspace/startWidget.action"
#if 1
//延迟安装上报
#define DELAY_INSTALL_REPORT_URL @"http://open.appcan.cn/myspace/delayInstallWidget.action"
//延迟卸载上报
#define DELAY_UNINSTALL_REPORT_URL @"http://open.appcan.cn/myspace/delayUnInstallWidget.action"
//延迟启动上报
#define DELAY_START_REPORT_URL  @"http://open.appcan.cn/myspace/delayStartWidget.action"
#else
//延迟安装上报
#define DELAY_INSTALL_REPORT_URL @"http://192.168.1.98/txOpen/myspace/delayInstallWidget.action"
//延迟卸载上报
#define DELAY_UNINSTALL_REPORT_URL @"http://192.168.1.98/txOpen/myspace/delayUnInstallWidget.action"
//延迟启动上报
#define DELAY_START_REPORT_URL  @"http://192.168.1.98/txOpen/myspace/delayStartWidget.action"
#endif

#define PlatformIOS @"0"
#define AC_DB_NAME @"AC_DataBase"
#define AC_DB_POPTABLE @"POPAPPTABLE"
@implementation AppCenter
@synthesize eBView;
@synthesize showTag = _showTag;
@synthesize sView,myAppRefDict,recmdAppRefDict;
@synthesize currentSessionKey;
@synthesize mainWgtPath;
@synthesize portalID;
@synthesize availableSessionKey;
@synthesize userHasLogin;
@synthesize startWgtShowLoading;
@synthesize myAppTableName;

#pragma mark database operation

- (void)Open_database:(NSString*)dbName{
	NSString *DBPath = [[NSString stringWithFormat:@"%@/data",mainWgtPath]	stringByAppendingPathComponent:dbName];
	if (sqlite3_open([DBPath UTF8String], &ac_db_obj)==SQLITE_OK) {
		sqlite3_config(SQLITE_CONFIG_SERIALIZED);
		ACENSLog(@"[success to open DBName=%@]",dbName);
	}else {
		sqlite3_close(ac_db_obj);
		ACENSLog(@"[fail to open DBName=%@]",dbName);
	}
}
- (void)close_database{
	sqlite3_close(ac_db_obj);
}
-(void)operateSQL:(const char*)inSql{
	@synchronized(self){
		ACENSLog(@"appcenter insql = %s",inSql);
		char *errorMsg;
		int errorCode = sqlite3_exec(ac_db_obj, inSql, NULL, NULL, &errorMsg);
		if(errorCode==SQLITE_OK){
			ACENSLog(@"[APPCENTER do sql success]");
		}else {
			ACENSLog(@"\n error message = %s \n",errorMsg);
		}
	}

}
-(NSArray*)selectSQL:(const char*)inSQL{
	@synchronized(self){
		char *errMsg = NULL;
		sqlite3_stmt *stmt;
		NSMutableDictionary *entry;
		int stepStatus,i,count,column_type;
		NSObject *columnValue;
		NSString *columnName;
		NSMutableArray *resultRows = [NSMutableArray arrayWithCapacity:0];
		BOOL keepGoing = NO;
		int preStatus = sqlite3_prepare_v2(ac_db_obj, inSQL, -1, &stmt, NULL);
		if (preStatus != SQLITE_OK) {
			errMsg = (char *) sqlite3_errmsg (ac_db_obj);
			 ACENSLog(@" selectSQL errMsg=%s",errMsg);
			keepGoing = NO;
		}
		keepGoing = YES;
		while (keepGoing) {
			stepStatus = sqlite3_step(stmt);
			switch (stepStatus) {
				case SQLITE_ROW:{
					i = 0;
					entry = [NSMutableDictionary dictionaryWithCapacity:0];
					count = sqlite3_column_count(stmt);
					while (i<count) {
						column_type = sqlite3_column_type(stmt, i);
						switch (column_type) {
							case SQLITE_INTEGER:
								columnValue = [NSNumber numberWithInt: sqlite3_column_int(stmt, i)];
								columnName = [NSString stringWithFormat:@"%s", sqlite3_column_name(stmt, i)];
								[entry setObject:columnValue forKey:columnName];
								break;
							case SQLITE_TEXT:
							{
								char * cValue = (char *)(sqlite3_column_text(stmt, i));
								columnValue = [NSString stringWithCString:cValue encoding:NSUTF8StringEncoding];
								columnName = [NSString stringWithFormat:@"%s",sqlite3_column_name(stmt, i)];
								[entry setObject:columnValue forKey:columnName];
							}
								break;
							case SQLITE_FLOAT:
								columnValue = [NSNumber numberWithFloat:sqlite3_column_double(stmt, i)];
								columnName = [NSString stringWithFormat:@"%s",sqlite3_column_name(stmt, i)];
								[entry setObject:columnValue forKey:columnName];
								break;
							case SQLITE_BLOB:
								break;
							case SQLITE_NULL:
								break;
						}
						i++;
					}
					[resultRows addObject:entry];
					break;
				}
				case SQLITE_DONE:{
					keepGoing = NO;
					break;
				}
				default:{
					errMsg ="stmt error";
					keepGoing = NO;
					break;
				}
			}
		}
		sqlite3_finalize(stmt);
		if (errMsg!=NULL) {
			ACENSLog(@"selectSQL errMsg=%s",errMsg);
		}else {
			return resultRows;
		}
	}
		return NULL;
	 
}
#pragma mark common
-(NSString *)timeSince1970Seconds{
	NSDate *date = [NSDate date];
	double time = [date timeIntervalSince1970];	 
	return [NSString stringWithFormat:@"%.0f",time*1000];
}
-(void)showAlert:(NSString *)title message:(NSString *)msg{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:msg 
												   delegate:self 
										  cancelButtonTitle:ACELocalized(@"确定")
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}
-(BOOL)hasShowTag{
	return _showTag;
}
//判断一个应用是否安装
-(BOOL)appHasInstall:(NSString *)_appid{
	BOOL ret = NO;
	NSString *selectSqlStr = [NSString stringWithFormat:@"select * from %@ where appid = %d",myAppTableName,[_appid intValue]];
	NSArray *result = [self selectSQL:[selectSqlStr UTF8String]];
	if([result count]>0){
		NSNumber *num = [(NSDictionary *)[result objectAtIndex:0] objectForKey:@"installedtag"];
		if([num intValue]==1){
			ret = YES;
		}else {
			ret = NO;
		}
	}
	return ret;
}
//启动
-(void)startWidgetWithAppId:(NSString *)appID{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sView animated:YES];
	hud.labelText = ACELocalized(@"请稍候");
	[hud show:YES];
	startWgtShowLoading = YES;
	NSString *jsString = [NSString stringWithFormat:@"uexWidget.startWidget(\"%@\",\"0\",\"\",\"\");",appID];
	[self.eBView stringByEvaluatingJavaScriptFromString:jsString];
	
}
#pragma mark init

-(void)initForDisplay{
	//init
	sView= [[MySpaceView alloc] initWithFrame:CGRectMake(0, 0, [BUtility getScreenWidth], [BUtility getScreenHeight])];
	sView.delegate = self;
	//判断是不是显示“更多”
	if ([eBView.meBrwCtrler.mwWgtMgr.wMainWgt getMoreWgtsStatus]) {
		sView.moreDisplay = YES;
	}else {
		sView.moreDisplay = NO;
	}
	//先获取主appid
	self.portalID = eBView.meBrwCtrler.mwWgtMgr.wMainWgt.appId;
	//获取widgetpath
	NSString *wgtPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"apps/%@",portalID]];
	self.mainWgtPath = wgtPath;
	ACENSLog(@"mainWgtPath = %@",mainWgtPath);
	NSString *dataPath = [mainWgtPath stringByAppendingPathComponent:@"data"];
	NSFileManager *fm = [NSFileManager defaultManager];
	if(![fm fileExistsAtPath:dataPath]){
		[fm createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
		
	}
	//初始化一个下载队列
	{
		dQueue  = [[ASINetworkQueue alloc] init];
		[dQueue reset];
		[dQueue setShowAccurateProgress:YES];
		[dQueue setShouldCancelAllRequestsOnFailure:NO];
		[dQueue setDelegate:self];
 		[dQueue go];
	}
	[self Open_database:AC_DB_NAME];
	//初始化dict
	myAppRefDict = [[NSMutableDictionary alloc]initWithCapacity:8];
	recmdAppRefDict = [[NSMutableDictionary alloc] initWithCapacity:8];
}
-(void)openAppCenterWithEBrwView:(EBrowserView *)eView{
	self.eBView = eView;
	if (sView) {
		//如果sview已经存在了。直接显示（要不要刷新?）
		sView.hidden = NO;
		[eBView.meBrwWnd.superview bringSubviewToFront:sView];
		EBrowserMainFrame *eBrwMainFrm = eBView.meBrwCtrler.meBrwMainFrm;
		if (eBrwMainFrm.meAdBrwView) {
			eBrwMainFrm.meAdBrwView.hidden = YES;
			[eBrwMainFrm invalidateAdTimers];
		}
	}else {
		//初始化
		[self initForDisplay];
	}
	//先判断用户是否登录
	NSUserDefaults *dfs = [NSUserDefaults standardUserDefaults];
	self.availableSessionKey = [dfs objectForKey:@"sessionKey"];
	if (availableSessionKey) {
	    userID = [dfs objectForKey:@"spuid"];
		self.myAppTableName = [@"AC" stringByAppendingString:userID];
		userHasLogin = YES;
		 //启动一个新线程去上报安装信息
		 [NSThread detachNewThreadSelector:@selector(startReportOldInfo) toTarget:self withObject:nil];
		 
	}else {
		userHasLogin = NO;
	}
	[self.eBView.meBrwWnd.superview addSubview:sView];
 	[eBView.meBrwWnd.superview bringSubviewToFront:sView];
	EBrowserMainFrame *eBrwMainFrm = eBView.meBrwCtrler.meBrwMainFrm;
	if (eBrwMainFrm.meAdBrwView) {
		eBrwMainFrm.meAdBrwView.hidden = YES;
		[eBrwMainFrm invalidateAdTimers];
	}
	_showTag = YES;	
	//加载推荐应用数据
 	[self loadPopAppList];
	if (userHasLogin) {
		//加载我的应用数据,
		[self loadMyAppList];
	}
}

#pragma mark popapp 
-(BOOL)haveNativePopApp{
	//判断是不是本地有推荐应用的缓存
	NSString *CreateSql = [NSString stringWithFormat:@"select * from %@",AC_DB_POPTABLE];
	NSArray  *ret =  [self selectSQL:[CreateSql UTF8String]];
	if([ret count]>0){
		return YES;
	}else {
		return NO;
	}

}
-(void)loadNativePopApp{
	//如果本地缓存有内容
	//加载本地缓存
	//先查询数据库
	NSString *sqlstr = [NSString stringWithFormat:@"select * from %@",AC_DB_POPTABLE];
	NSArray *itemsArray = [self selectSQL:[sqlstr UTF8String]];
	for (NSDictionary *dict in itemsArray) {
		AppItemView *item = [[AppItemView alloc] init];
		item.appId = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"appid"] intValue]];
		item.appName = [dict objectForKey:@"appname"];
		item.appSize = [dict objectForKey:@"size"];
		item.downloadUrl = [dict objectForKey:@"downloadurl"];
		item.appIconUrl = [NSURL fileURLWithPath:[dict objectForKey:@"iconpath"]];
		item.softwareId = [dict objectForKey:@"softid"];
		item.appMode = [dict objectForKey:@"createmode"];
		[recmdAppRefDict setObject:item forKey:item.appId];
	}
	
	[self drawCommendApp:recmdAppRefDict];
}
-(void)downloadPopAppInfo{
	//直接去网络请求数据
	NSString *appListUrlStr = [NSString stringWithFormat:@"%@?portalAppId=%@&platFormId=%@",APPLIST_URL,portalID,PlatformIOS]; 
	ACENSLog(@"applisturl = %@",appListUrlStr);
	NSURL *reqUrl = [NSURL URLWithString:appListUrlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:reqUrl];
	[request setDelegate:self];
	[request setUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:@"requestID"]];
	[dQueue addOperation:request];
	[request release];
}
-(void)loadPopAppList{
	//先判断有没有本地缓存
	BOOL havePop = [self haveNativePopApp];
	if (havePop) {
		//如果本地缓存有内容
		//加载本地缓存
		[self loadNativePopApp];
	} 
	//后台加载数据
	//该下载机制改为用户每天只下载一次，然后用户手动刷新
	//先判断是不是过了一天，如果是的话，就去下载，如果不够一天，直接返回
	//计算时间差
	 NSDate *readDate= [[NSUserDefaults standardUserDefaults] objectForKey:@"popAppLoadDate"];
	if(readDate==nil){
		[self downloadPopAppInfo];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"popAppLoadDate"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}else {
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		unsigned int unitFlags = NSDayCalendarUnit;
		NSDateComponents *comps = [gregorian components:unitFlags fromDate:readDate  toDate:[NSDate date]  options:0];
		NSInteger days = [comps day];
		if(days>1){
			[self downloadPopAppInfo];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"popAppLoadDate"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}else {
			return;
		}
	}
}

-(void)savePopAppInfo:(NSString *)appid{     
	//创建数据库，创建表
	NSString *CreateSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(appid INTEGER PRIMARY KEY,appname text,size text,downloadurl text,iconpath text,softid text,createmode text)",AC_DB_POPTABLE];
	[self operateSQL:[CreateSql UTF8String]];
	AppItemView *item = [recmdAppRefDict objectForKey:appid];
	//写入数据库
	NSString *appId = item.appId;
	NSString *appName = item.appName;
	NSString *appSize = item.appSize;
	NSString *softId = item.softwareId;
	NSString *durl = item.downloadUrl;
	NSString *mode = item.appMode;
	NSString *iconCacheDir = [mainWgtPath stringByAppendingPathComponent:@"/data/iconCache"];
	NSString *iconCachePath = [iconCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",item.appId]];

    //查询数据库
	NSString *selectSqlStr = [NSString stringWithFormat:@"select * from %@ where appid = %d",AC_DB_POPTABLE,[appid intValue]];
	NSArray *array = [self selectSQL:[selectSqlStr UTF8String]];
	if([array count]==0){
		NSString *insertSqlStr = [NSString stringWithFormat:@"INSERT INTO %@(appid,appname,size,downloadurl,iconpath,softid,createmode) VALUES (%d,'%@','%@','%@','%@','%@','%@')",AC_DB_POPTABLE,[appId intValue],appName,appSize,durl,iconCachePath,softId,mode];
		ACENSLog(@"pop app insert insert sql = %@",insertSqlStr);
		[self operateSQL:[insertSqlStr UTF8String]];
	}else {
		NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set appname = '%@',size = '%@',downloadurl = '%@',iconpath = '%@',softid = '%@',createmode = '%@' where appid = %d",AC_DB_POPTABLE,appName,appSize,durl,iconCachePath,softId,mode,[appId intValue]];
		[self operateSQL:[updateSqlStr UTF8String]];
	}
}
 
-(void)popAppReceiveFinish:(NSString *)resultStr{
	if (resultStr&&[resultStr length]>0&&(![resultStr isEqualToString:@"-1"])) {
		id jsonValue = [resultStr JSONValue];
		if (jsonValue) {
			//缓存一个推荐应用的列表，appid－－－》app
			ACENSLog(@"popappstring = %@",resultStr);
			//初始化列表集合
			NSDictionary *appResult = (NSDictionary *)jsonValue;
			if (appResult) {
				NSArray *recArray = [appResult objectForKey:@"recommendAppList"];
				if (recArray&&[recArray count]>0) {
					for (int i = 0; i<[recArray count]; i++) {
						NSDictionary *itemDict = [recArray objectAtIndex:i];
						 
						AppItemView *item = [[AppItemView alloc] init];
						item.appIconUrl = [NSURL URLWithString:[itemDict objectForKey:@"iconLoc"]];
						item.appId = [itemDict objectForKey:@"appId"];
						item.appName = [itemDict objectForKey:@"name"];
						item.appSize = [itemDict objectForKey:@"size"];
						item.softwareId = [itemDict objectForKey:@"id"];
						item.downloadUrl = [itemDict objectForKey:@"downloadUrl"];
						item.appMode = [itemDict objectForKey:@"createMethod"];
						[recmdAppRefDict setObject:item forKey:item.appId];
						//download icon
						NSFileManager *fm = [NSFileManager defaultManager];
						NSString *iconCacheDir = [mainWgtPath stringByAppendingPathComponent:@"/data/iconCache"];
						if (![fm fileExistsAtPath:iconCacheDir ]) {
							[fm createDirectoryAtPath:iconCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
						}
						NSString *iconCachePath = [iconCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",item.appId]];
						if(![fm fileExistsAtPath:iconCachePath]){
							ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:item.appIconUrl];
							[request setDelegate:self];
							[request setUserInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:2],item.appId,nil] forKeys:[NSArray arrayWithObjects:@"requestID",@"appid",nil]]];
							[request setDownloadDestinationPath:iconCachePath];
							[dQueue addOperation:request];
						}else {
							[self savePopAppInfo:item.appId];
						}

						[item release];
					}
					//刷新界面
					[self drawCommendApp:recmdAppRefDict];
				}
				 
			}
		}
	}else {
		[self loadNativePopApp];
	}	
}
#pragma mark myApp
-(void)saveMyAppInfo:(NSString *)appid{
	//创建数据库，创建表
	NSString *CreateSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(appid INTEGER PRIMARY KEY,appname text,iconpath text,mode text,softid text,size text,downloadurl text,downloadtag integer,installedtag integer,installreportTag integer,installtime text,uninstallrpttag integer,uninstalltime text)",myAppTableName];
	[self operateSQL:[CreateSql UTF8String]];
	AppItemView *item = [myAppRefDict objectForKey:appid];
	//写入数据库
	NSString *appId = item.appId;
	NSString *appName = item.appName;
	NSString *appSize = item.appSize;
	NSString *softId = item.softwareId;
	NSString *durl = item.downloadUrl;
	NSString *mode = item.appMode;
	NSString *iconCacheDir = [mainWgtPath stringByAppendingPathComponent:@"/data/iconCache"];
	NSString *iconCachePath = [iconCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",item.appId]];
	
    //查询数据库
	NSString *selectSqlStr = [NSString stringWithFormat:@"select * from %@ where appid = %d",myAppTableName,[appid intValue]];
	NSArray *array = [self selectSQL:[selectSqlStr UTF8String]];
	if([array count]==0){
		NSString *insertSqlStr = [NSString stringWithFormat:@"INSERT INTO %@(appid,appname,iconpath,mode,softid,size,downloadurl,downloadtag,installedtag,installreporttag,installtime,uninstallrpttag,uninstalltime) VALUES (%d,'%@','%@','%@','%@','%@','%@',0,0,0,'',0,'')",myAppTableName,[appId intValue],appName,iconCachePath,mode,softId,appSize,durl];
		ACENSLog(@"my app insert insert sql = %@",insertSqlStr);
		[self operateSQL:[insertSqlStr UTF8String]];
	}else {
		NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set appname='%@',iconpath='%@',mode='%@',softid ='%@',size ='%@',downloadurl ='%@' where appid=%d",myAppTableName,appName,iconCachePath,mode,softId,appSize,durl,[appId intValue]];
		[self operateSQL:[updateSqlStr UTF8String]];
	}
	
}
-(void)myAppReceiveFinish:(NSString *)responseStr{
	ACENSLog(@"myappreq finish");
	[ACUtility showNetworkActivityIndicator:NO];
	ACENSLog(@"myappstr = %@",responseStr);
	if ([responseStr isEqualToString:@"-1"]) {
		//如果服务器上面都没有安装过的信息，
		[self drawBottomView:nil];
		return;
	}
	id jsonValue = [responseStr JSONValue];
	if (jsonValue==nil) {
		[self drawBottomView:nil];
		return;
	}
	NSDictionary *appResult = (NSDictionary *)jsonValue;
	if (appResult) {
		NSMutableArray *recArray = [appResult objectForKey:@"myAppList"];
		ACENSLog(@"myappdict = %@,[recArray count] = %d",[appResult description],[recArray count]);
		for (int i = 0; i<[recArray count]; i++) {
			NSDictionary *itemDict = [recArray objectAtIndex:i];
			
			AppItemView *item = [[AppItemView alloc] init];
			item.appIconUrl = [NSURL URLWithString:[itemDict objectForKey:@"iconLoc"]];
			item.appId = [itemDict objectForKey:@"appId"];
			item.appName = [itemDict objectForKey:@"name"];
			item.appSize = [itemDict objectForKey:@"size"];
			item.softwareId = [itemDict objectForKey:@"id"];
			item.appMode = [itemDict objectForKey:@"createMethod"];
			item.downloadUrl = [itemDict objectForKey:@"downloadUrl"];
			BOOL isInstalled = [self appHasInstall:item.appId];
			if(isInstalled){
				item.downloadTag = 3;
			}else {
				item.downloadTag = 0;
			}

    		[myAppRefDict setObject:item forKey:item.appId];
			
			//download icon
			NSFileManager *fm = [NSFileManager defaultManager];
			NSString *iconCacheDir = [mainWgtPath stringByAppendingPathComponent:@"/data/iconCache"];
			if (![fm fileExistsAtPath:iconCacheDir ]) {
				[fm createDirectoryAtPath:iconCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
			}
			NSString *iconCachePath = [iconCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",item.appId]];
			if(![fm fileExistsAtPath:iconCachePath]){
				ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:item.appIconUrl];
				[request setDelegate:self];
				[request setUserInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:3],item.appId,nil] forKeys:[NSArray arrayWithObjects:@"requestID",@"appid",nil]]];
				[request setDownloadDestinationPath:iconCachePath];
				[dQueue addOperation:request];
			}else {
				[self saveMyAppInfo:item.appId];
			}
			[item release];
		} 
		[self drawBottomView:myAppRefDict];
	}
}
-(void)getMyAppWithSessionKey{
	if (!availableSessionKey) {
		return;
	}
	NSString *myAppListUrlStr = [NSString stringWithFormat:@"%@?portalAppId=%@&platFormId=%@&txSessionKey=%@",MY_APP_LIST_URL,portalID,PlatformIOS,availableSessionKey]; 
	ACENSLog(@"applistrul = %@",myAppListUrlStr);
	ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:myAppListUrlStr]];
	[req setDelegate:self];
	[req setUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"requestID"]];
	[dQueue addOperation:req];
}
-(void)loadMyAppList{
	[ACUtility showNetworkActivityIndicator:YES];
	[self getMyAppWithSessionKey];
}
#pragma mark httprequest
- (void)requestFinished:(ASIHTTPRequest *)request{
	ACENSLog(@"request finish");
	NSString *recString = [request responseString];
	NSInteger reqId = [[request.userInfo objectForKey:@"requestID"] intValue];
	switch (reqId) {
		case 0:
			[self popAppReceiveFinish:recString];
			break;
		case 1:
			[self myAppReceiveFinish:recString];
			break;
		case 2:
			[self savePopAppInfo:[request.userInfo objectForKey:@"appid"]];
			break;
		case 3:
			[self saveMyAppInfo:[request.userInfo objectForKey:@"appid"]];
			break;

		default:
			break;
	}
}
- (void)requestFailed:(ASIHTTPRequest *)request{
	[ACUtility showNetworkActivityIndicator:NO];
	ACENSLog(@"request respon header = %@,reson status = %d,[resstring = ]",[[request responseHeaders] description],request.responseStatusCode);
	NSInteger reqId = [[request.userInfo objectForKey:@"requestID"] intValue];
	switch (reqId) {
		case 0:
			//[self showAlert:ACELocalized(@"提示") message:@"加载失败"];
			break;
		case 1:
		{
			[ACUtility showNetworkActivityIndicator:NO];
			ACENSLog(@"myapp fail");
			[self drawBottomView:nil];
		}
			break;
		case 2:
			break;
			
		default:
			break;
	}


}
#pragma mark draw view
-(void)drawCommendApp:(NSMutableDictionary *)recAppDict{
	[MBProgressHUD hideHUDForView:sView animated:YES];
	[ACUtility showNetworkActivityIndicator:NO];
	//判断是不是显示“更多”
	if ([eBView.meBrwCtrler.mwWgtMgr.wMainWgt getMoreWgtsStatus]) {
		sView.moreDisplay = YES;
	}else {
		sView.moreDisplay = NO;
	}
	if (sView) {
		NSArray *recAppArray = [recAppDict allValues];
		[sView drawTopView:recAppArray];
	}
}
-(void)drawBottomView:(NSMutableDictionary *)recAppDict{
	if (userID == nil){
		return;
	}
	if(recAppDict==nil){
		//如果网络没有拿到，但是用户登录了，那么加载本地本账户下已经安装的应用
		NSString *selectSqlStr = [NSString stringWithFormat:@"select * from %@ where installedtag = 1 and uninstallrpttag = 0",myAppTableName];
		NSArray *myAppArray = [self selectSQL:[selectSqlStr UTF8String]];
		if(myAppArray){
			for (NSDictionary *saveItem in myAppArray) {
				AppItemView *app = [[AppItemView alloc] init];
				app.appId = [NSString stringWithFormat:@"%d",[[saveItem objectForKey:@"appid"] intValue]];
				NSString *savePath = [saveItem objectForKey:@"iconpath"];
				if([savePath hasPrefix:@"http://"]){
				app.appIconUrl = [NSURL URLWithString:savePath];
				}else {
				app.appIconUrl = [NSURL fileURLWithPath:savePath];
				}
 				app.appMode = [saveItem objectForKey:@"mode"];
				app.appSize = [saveItem objectForKey:@"size"];
				app.downloadUrl = [saveItem objectForKey:@"downloadurl"];
				app.appName = [saveItem objectForKey:@"appname"];
				app.softwareId = [saveItem objectForKey:@"softid"];
				BOOL isInstalled = [self appHasInstall:app.appId];
				if(isInstalled){
					app.downloadTag = 3;
				}else {
					app.downloadTag = 0;
				}
				[myAppRefDict setObject:app forKey:app.appId];
				[app release];
				
			}
			[sView drawMyAppView:[myAppRefDict allValues]];
		}else {
			return;
		}
	}else {
		[sView drawMyAppView:[recAppDict allValues]];
	}
}
#pragma mark report
-(void)startReportOldInfo{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	ACENSLog(@"report");
	if([BUtility isConnected]){
		//先查询数据库，找出没有上报的项目
		//安装上报
		NSString *installRepSqlSelectStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE installreporttag=1",myAppTableName];
		NSArray *noInstallRepItems = [self selectSQL:[installRepSqlSelectStr UTF8String]];
		if([noInstallRepItems count]>0){
			NSMutableArray *sendArray = [[NSMutableArray alloc] initWithCapacity:5];
			for (NSDictionary *itemdict in noInstallRepItems) {
				NSString *sid = [itemdict objectForKey:@"softid"];
				NSString *installTime = [itemdict objectForKey:@"installtime"];
				if(installTime==nil){
					installTime = [self timeSince1970Seconds];
				}
				NSDictionary *newRecordDict = [NSDictionary dictionaryWithObjects:
											   [NSArray arrayWithObjects:availableSessionKey,portalID,sid,@"0",installTime,nil] 
											forKeys:[NSArray arrayWithObjects:@"txSessionKey",@"portalAppId",@"intallAppId",@"platFormId",@"reportTime",nil]];
				[sendArray addObject:newRecordDict];
			}
			NSString *sendstring = [sendArray JSONFragment];
			ACENSLog(@"install sendstring = %@",sendstring);
			NSURL *installUrl = [NSURL URLWithString:DELAY_INSTALL_REPORT_URL];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:installUrl];
			[request setHTTPMethod:@"post"];
			[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
			[request setHTTPBody:[sendstring dataUsingEncoding:NSUTF8StringEncoding]];
			NSHTTPURLResponse *response;
			[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
			if([response statusCode]==200){
				ACENSLog(@"延迟安装上报成功");
				//更新数据库
				for (NSDictionary *dict in noInstallRepItems) {
					NSNumber *appid = [dict objectForKey:@"appid"];
					NSString *updtSql = [NSString stringWithFormat:@"update %@ set installreporttag=0 where appid=%d",myAppTableName,[appid intValue]];
					[self operateSQL:[updtSql UTF8String]];
				}
				}
			[sendArray release];
		}
		//卸载上报
		NSString *uninstallSqlStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE uninstallrpttag = 1",myAppTableName];
		NSArray *noUninstallArr = [self selectSQL:[uninstallSqlStr UTF8String]];
		if([noUninstallArr count]>0){
			NSMutableArray *noUninSendArr = [[NSMutableArray alloc] initWithCapacity:5];
			for (NSDictionary *itemdict in noUninstallArr) {
				NSString *sid = [itemdict objectForKey:@"softid"];
				NSString *uninstallTime = [itemdict objectForKey:@"uninstalltime"];
				if(uninstallTime==nil){
					uninstallTime = [self timeSince1970Seconds];
				}
				NSDictionary *newRecordDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:availableSessionKey,portalID,sid,uninstallTime,@"0",nil] forKeys:[NSArray arrayWithObjects:@"txSessionKey",@"portalAppId",@"intallAppId",@"reportTime",@"platFormId",nil]];
				[noUninSendArr addObject:newRecordDict];
			}
			NSString *noUninSendStr = [noUninSendArr JSONFragment];
			[noUninSendArr release];
			ACENSLog(@"uninstall sendstring = %@",noUninSendStr);
			NSURL *uninstallUrl = [NSURL URLWithString:DELAY_UNINSTALL_REPORT_URL];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uninstallUrl];
			[request setHTTPMethod:@"post"];
			[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
			[request setHTTPBody:[noUninSendStr dataUsingEncoding:NSUTF8StringEncoding]];
			NSHTTPURLResponse *response;
			[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
			if([response statusCode]==200){
				ACENSLog(@"延迟卸载上报成功");
				NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where uninstallrpttag = 1",myAppTableName];
				
				[self operateSQL:[deleteSql UTF8String]];
			} 
		}
		//启动上报
		NSString *startTableName = [NSString stringWithFormat:@"RP%@",userID];
		NSString *startSql = [NSString stringWithFormat:@"SELECT * FROM %@",startTableName];
		NSArray *startArr = [self selectSQL:[startSql UTF8String]];
		if([startArr count]>0){
			NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:5];
			for (NSDictionary *strDict in startArr) {
				NSString *sendStr = [strDict objectForKey:@"startrptjson"];
				NSArray *subItems = [sendStr componentsSeparatedByString:@"&"];
				for (NSString *subStr in subItems) {
					NSDictionary *jsonResDict = [subStr JSONValue];
					[resultArray addObject:jsonResDict];
				}
			}
			NSString *sendJson = [resultArray JSONFragment];
			ACENSLog(@"sendjson = %@",sendJson);
			[resultArray release];
			NSURL *startUrl = [NSURL URLWithString:DELAY_START_REPORT_URL];
			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:startUrl];
			[request setHTTPMethod:@"post"];
			[request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
			[request setHTTPBody:[sendJson dataUsingEncoding:NSUTF8StringEncoding]];
			NSHTTPURLResponse *response;
			NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
			ACENSLog(@"response data = %s ,response statuscode = %d",[data bytes],[response statusCode]);
			if([response statusCode]==200){
				ACENSLog(@"延迟启动上报成功");
				NSString *deleteSql = [NSString stringWithFormat:@"DROP TABLE %@",startTableName];
				[self operateSQL:[deleteSql UTF8String]];
			}
			
		}
	}
	[pool release];
}
-(void)reportInstallInfo:(AppItemView *)item{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (availableSessionKey==nil||portalID==nil) {
		return;
	}
	NSString *skey = [NSString stringWithFormat:@"%@",availableSessionKey];
	NSString *urlStr = [NSString stringWithFormat:@"%@?txSessionKey=%@&portalAppId=%@&intallAppId=%@&platFormId=%@",INSTALL_SUCCESS_URL,skey,portalID,item.softwareId,PlatformIOS];
	ACENSLog(@"urlstr = %@",urlStr);
	NSURL *reqUrl = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:reqUrl];
	NSHTTPURLResponse *response;
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	[request release];
	
	if ([response statusCode]!=200) {
		//查询数据库
		NSString *selectSqlStr = [NSString stringWithFormat:@"select * from %@ where appid = %d",myAppTableName,[item.appId intValue]];
		NSArray *array = [self selectSQL:[selectSqlStr UTF8String]];
		if(array){
			NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set installreporttag=1,installtime ='%@' where appid=%d",myAppTableName,[self timeSince1970Seconds],[item.appId intValue]];
			[self operateSQL:[updateSqlStr UTF8String]];
		}
	}else {
		ACENSLog(@"安装上报成功");
	}

	[pool release];
}

-(void)reportStartWidget:(NSString *)appid{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE appid = %d",myAppTableName,[appid intValue]];
	NSArray *selectResult = [self selectSQL:[selectSql UTF8String]];
	NSString *sid = NULL;
	if([selectResult count]>0){
		sid = [(NSDictionary *)[selectResult objectAtIndex:0] objectForKey:@"softid"];
	}else {
		return;
	}
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?txSessionKey=%@&startId=%@",START_WIDGET_REPORT_URL,availableSessionKey,sid]];
	ACENSLog(@"url = %@",url);
	NSHTTPURLResponse *response;
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	[request release];
	ACENSLog(@"normal start statuscode = %d",[response statusCode]);
	if ([response statusCode]!=200) {
		//上报失败
		NSString *tableName = [@"RP" stringByAppendingString:userID];
		NSString *createSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(appid INTEGER PRIMARY KEY,startrptjson text)",tableName];
		[self operateSQL:[createSql UTF8String]];
		NSString *selectSql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE appid = %d",tableName,[appid intValue]];
		NSArray *results = [self selectSQL:[selectSql UTF8String]];
		NSString *installTime = [self timeSince1970Seconds];
		NSDictionary *newRecordDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:availableSessionKey,sid,installTime,nil] forKeys:[NSArray arrayWithObjects:@"txSessionKey",@"startId",@"reportTime",nil]];
		NSString *newRecord = [newRecordDict JSONFragment];
		if([results count]>0){
			NSString *resultStr = [(NSDictionary *)[results objectAtIndex:0] objectForKey:@"startrptjson"];
			if(newRecord){
				NSString *finalStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"&%@",newRecord]];
				 
				ACENSLog(@"resultstr = %@",finalStr);
				NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET startrptjson = '%@' WHERE appid = %d",tableName,finalStr,[appid intValue]];
				[self operateSQL:[updateSql UTF8String]];
			}
		}else {
			NSString *insertStr = [NSString stringWithFormat:@"INSERT INTO %@(appid,startrptjson) VALUES (%d,'%@')",tableName,[appid intValue],newRecord];
			[self operateSQL:[insertStr UTF8String]];
		}
	}else {
		ACENSLog(@"正常启动，上报成功");
	}
	[pool release];
}
-(void)uninstallReport:(AppItemView *)item{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *sid = item.softwareId;
	if (sid==nil) {
		return;
	}
	NSString *urlstr = [NSString stringWithFormat:@"%@?txSessionKey=%@&portalAppId=%@&intallAppId=%@&platFormId=%@",UNINSTALL_FINISH_URL,availableSessionKey,portalID,sid,@"0"];
	ACENSLog(@"uninstall url = %@",urlstr);
	NSURL *url = [NSURL URLWithString:urlstr];
	if (url) {
		NSHTTPURLResponse *response;
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
		NSInteger status = [response statusCode];
		if (status==200) {
			ACENSLog(@"卸载上报成功");
			//删除配置
			NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where appid = %d",myAppTableName,[item.appId intValue]];
			[self operateSQL:[deleteSql UTF8String]];
			[eBView.meBrwCtrler.mwWgtMgr removeWgtByAppId:item.appId];
		}else {
			NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET uninstallrpttag = 1,uninstalltime = '%@' where appid = %d",myAppTableName,[self timeSince1970Seconds],[item.appId intValue]];
			[self operateSQL:[updateSql UTF8String]];
		}
	}
	[pool release];
}

#pragma mark viewdelegate

-(void)appCenterCloseBtnClick{
	if (sView) {
		sView.hidden = YES;
		_showTag = NO;
		self.eBView.meBrwCtrler.mFlag = 0;
		if ([eBView.meBrwCtrler.mwWgtMgr.wMainWgt getMySpaceStatus]) {
			self.eBView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = NO;
		}else {
			self.eBView.meBrwCtrler.meBrwMainFrm.meBrwToolBar.hidden = YES;
		} 
//		[self close_database];
//		self.eBView.meBrwCtrler.ballHasShow = NO;
		EBrowserWindow *eAboveWnd = [[self.eBView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer] aboveWindow];
		[eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:@"if(uexWindow.onStateChange!=null){uexWindow.onStateChange(0);}"];
		if ((eAboveWnd.meBrwView.mFlag & F_EBRW_VIEW_FLAG_HAS_AD) == F_EBRW_VIEW_FLAG_HAS_AD) {
			NSString *openAdStr = [NSString stringWithFormat:@"uexWindow.openAd(\'%d\',\'%d\',\'%d\',\'%d\')",eAboveWnd.meBrwView.mAdType, eAboveWnd.meBrwView.mAdDisplayTime, eAboveWnd.meBrwView.mAdIntervalTime, eAboveWnd.meBrwView.mAdFlag];
			[eAboveWnd.meBrwView stringByEvaluatingJavaScriptFromString:openAdStr];
		}
	}
}
-(void)appPressLongForDelete:(NSString *)appID{
	ACENSLog(@"DELETE APP");
	NSFileManager *fm = [NSFileManager defaultManager];
	//删除安装包
	NSString *pkgPath = [BUtility getDocumentsPath:[NSString stringWithFormat:@"widgets/%@",appID]];
	if ([fm fileExistsAtPath:pkgPath]) {
		[fm removeItemAtPath:pkgPath error:nil];
	}
	//删除缓存图片
	NSString *imageCachePath = [mainWgtPath stringByAppendingPathComponent:[NSString stringWithFormat:@"data/iconCache/%@.png",appID]];
	if ([fm fileExistsAtPath:imageCachePath]) {
		[fm removeItemAtPath:imageCachePath error:nil];
	}
	//上报
	[NSThread detachNewThreadSelector:@selector(uninstallReport:) toTarget:self withObject:[myAppRefDict objectForKey:appID]];
	//删除内存cache刷新界面
	[myAppRefDict removeObjectForKey:appID];
	
	[sView drawMyAppView:[myAppRefDict allValues]];
}
-(void)appItemClick:(NSString *)appID{
	//icon 被点击
	ACENSLog(@"appcenter appitem click");
	if ([appID intValue]==0) {
		return;
	}
	AppItemView *myItem = [myAppRefDict objectForKey:appID];
	if (myItem) {
		if (myItem.downloadTag == 1) {
			ACENSLog(@"isdownloading return");
			return;
		}
	}
	activeAppId = [appID copy];
	BOOL hasInstalled = NO; 
	if ([appID isEqualToString:@"9999997"]) {
		if (![BUtility isConnected]) {
			[self showAlert:@"" message:ACELocalized(@"获取信息失败")];
			return;
		}
		[self startWidgetWithAppId:appID];
		return;
	}
    NSString *userid= [[NSUserDefaults standardUserDefaults] objectForKey:@"spuid"];
	if (userid&&[userid length]>0) {
		userHasLogin = YES;
		userID = userid;
		self.myAppTableName = [@"AC" stringByAppendingString:userID];
	}else {
		userHasLogin = NO;
	}
	
	//判断用户是否登录
	if(userHasLogin){
		//如果用户已经登录
		//判断该应用是否已经安装
		hasInstalled =[self appHasInstall:appID]; 
		if (hasInstalled==YES) {
			//已经安装，直接启动
			[self startWidgetWithAppId:appID];
			return;
		}
		if (hasInstalled==NO) {
			needDownload = YES;
			//获取应用的url，下载应用
			AppItemView *dItem = [recmdAppRefDict objectForKey:appID];
			ACENSLog(@"URLSTR = %@",dItem.downloadUrl);
			
			if (dItem&&dItem.downloadUrl) {
				[self downloadWidgetWithItem:dItem];
			}else{
				dItem = [myAppRefDict objectForKey:appID];
				[self downloadWidgetWithItem:dItem];
			}
		}
		
	}else {
 		[self userLoginStart];
		needDownload = YES;
	}
}
-(void)notifyAppCenterReloadData{
	[self downloadPopAppInfo];
}
#pragma mark userlogin
-(void)sessionKeyFinish:(NSData *)reqData{
	NSString *sessionKey = [[NSString alloc] initWithData:reqData encoding:NSUTF8StringEncoding];
	ACENSLog(@"sessionkey = %@",sessionKey);
	if (sessionKey==nil) {
		[MBProgressHUD hideHUDForView:sView animated:YES];
		[self showAlert:@"" message:ACELocalized(@"获取信息失败")];
	}
	NSString *sessionKeyStr = [[sessionKey JSONValue] objectForKey:@"txSessionKey"];
	if (sessionKeyStr!=nil&&[sessionKeyStr length]>0) {
		//start 登录的widget
		ACENSLog(@"sessionkey = %@",sessionKeyStr);
		self.currentSessionKey = [NSString stringWithString:sessionKeyStr];
		NSString *infoStr;
		NSString *fromDomainStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"fromDomain"];
		if (fromDomainStr&&[fromDomainStr length]>0) {
			infoStr = [NSString stringWithFormat:@"txSessionKey=%@&appId=%@&fromDomain=%@",sessionKeyStr,portalID,fromDomainStr];
		}else {
			infoStr = [NSString stringWithFormat:@"txSessionKey=%@&appId=%@",sessionKeyStr,portalID];
		}
		ACENSLog(@"infostr = %@",infoStr);
		NSString *jsString = [NSString stringWithFormat:@"uexWidget.startWidget(\"9999998\",\"0\",\"\",\"%@\");",infoStr];
		ACENSLog(@"jsstr = %@",jsString);
		[self.eBView stringByEvaluatingJavaScriptFromString:jsString];
	}else {
		[MBProgressHUD hideHUDForView:sView animated:YES];
		[self showAlert:@"" message:ACELocalized(@"获取信息失败")];
	}	
}
-(void)sessionKeyFail{
	ACENSLog(@"session key fail");
	[MBProgressHUD hideHUDForView:sView animated:YES];
	[self showAlert:@"" message:ACELocalized(@"获取信息失败")];
	return;
}
-(void)userLoginStart{
	if (![BUtility isConnected]) {
		[self showAlert:@"" message:ACELocalized(@"获取信息失败")];
		return;
	}
	//用户登录
	//联网拿到sessionkey
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sView animated:YES];
	hud.labelText = ACELocalized(@"请稍候");
	[hud show:YES];
	startWgtShowLoading = YES;
	[NSThread detachNewThreadSelector:@selector(dldSessionKey) toTarget:self withObject:nil];
}
-(void)dldSessionKey{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *sessionUrlStr = [NSString stringWithFormat:@"%@?&appId=%@",SESSION_KEY_URL,portalID];
	ACENSLog(@"sessionurl = %@",sessionUrlStr);
    NSURL *url = [NSURL URLWithString:sessionUrlStr];
	NSHTTPURLResponse *response;
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	if ([response statusCode]==200) {
	
		[self performSelectorOnMainThread:@selector(sessionKeyFinish:) withObject:data waitUntilDone:NO];
	}else {
		[self performSelectorOnMainThread:@selector(sessionKeyFail) withObject:nil waitUntilDone:NO];
	}
	[pool release];
}
-(BOOL)saveSessionKey:(NSString *)uInfo{
	if (uInfo) {
		NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
		NSDictionary *dict = [uInfo JSONValue];
		if (dict) {
			NSString *uid = [dict objectForKey:@"uid"];
			if (uid) {
				[udf setValue:uid forKey:@"spuid"];
				userID = [uid copy];
				self.myAppTableName = [@"AC" stringByAppendingString:userID];
			}else {
				return NO;
			}
			if (currentSessionKey) {
				[udf setValue:currentSessionKey forKey:@"sessionKey"];
			}else {
				return NO;
			}
			NSString *domaim = [dict objectForKey:@"fromDomain"];
			if (domaim) {
				[udf setValue:domaim forKey:@"fromDomain"];
			} 
		}else {
			return NO;
		}
		
	}else {
		return NO;
	}
	
	return YES;
}
//在widget的回调函数里面,处理用户登录后的后事
-(void)userLoginSuccess:(NSString *)uInfo{
	ACENSLog(@"userloginsuccess");
	//用户登录成功
	//保存sessionkey
	if ([self saveSessionKey:uInfo]) {
		userHasLogin = YES;
		self.availableSessionKey = currentSessionKey;
		//刷新界面
		[self loadMyAppList];
		//todo：开始下载异步
		if (recmdAppRefDict!=nil&&activeAppId!=NULL&&needDownload ==YES) {
			//先判断有木有安装
			if ([self appHasInstall:activeAppId]) {
				[self showAlert:@"" message:ACELocalized(@"该应用已经安装")];
			}else {
				AppItemView *item = [recmdAppRefDict objectForKey:activeAppId];
				if (item) {
					ACENSLog(@"recomapp has item app");
					[self downloadWidgetWithItem:item];
				}else {
					item = [myAppRefDict objectForKey:activeAppId];
					[self downloadWidgetWithItem:item];
				}
				
			}
			
		}
	}else {
		userHasLogin = NO;
	}
}
-(void)userLoginFail{
	userHasLogin = NO;
	ACENSLog(@"login fail");
}
#pragma mark downloadWidget
-(void)downloadWidgetWithItem:(AppItemView *)aItem{
	if (aItem==nil) {
		return;
	}
	NSString *urlstr = [NSString stringWithString:aItem.downloadUrl];
	NSString *idStr = [NSString stringWithString:aItem.appId];
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSURL *dUrl = [NSURL URLWithString:urlstr];
	ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:dUrl];
	//TODO:获取保存widget包的临时文件夹
	NSString *tempDir = [mainWgtPath stringByAppendingPathComponent:@"data/temp"];
	if (![fmanager fileExistsAtPath:tempDir]) {
		[fmanager createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
	NSString *tempPath  = [tempDir stringByAppendingPathComponent:[NSString stringWithFormat:@"widget_%@.zip",idStr]];
	
	
	//TODO:获取保存widget包的目标文件夹
	NSString *saveDir =[mainWgtPath stringByAppendingPathComponent:@"data"];
	if (![fmanager fileExistsAtPath:saveDir]) {
		[fmanager createDirectoryAtPath:saveDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
	NSString *savePath = [saveDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",idStr]];
 	//设置代理
	[request setDelegate:self];
//	[request setTimeOutSeconds:180];
	//设置文件保存路径
	[request setDownloadDestinationPath:savePath];
	//设置临时文件路径
	[request setTemporaryFileDownloadPath:tempPath];
//	//设置进度条的代理,
 	[request setDownloadProgressDelegate:aItem];
	//设置下载代理
	[request setDidFinishSelector:@selector(widgetDidDownloadFinish:)];
	//下载失败代理
	[request setDidFailSelector:@selector(widgetDidDownloadFail:)];
	[request setDidStartSelector:@selector(widgetDidStartDownload:)];
	//设置是否支持断点下载
	[request setAllowResumeForFileDownloads:YES];
	//设置基本信息
	[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:aItem,@"downloadItem",nil]];
	//添加到ASINetworkQueue队列去下载
	[dQueue addOperation:request];
	//收回request
	[request release];
	
}
-(void)widgetDidStartDownload:(ASIHTTPRequest *)request{
	ACENSLog(@"start download");
	if (userID==nil||[userID length]==0) {
		 userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"spuid"];
		self.myAppTableName = [@"AC" stringByAppendingString:userID];
	}
	AppItemView *newItem  = [request.userInfo objectForKey:@"downloadItem"];
	newItem.downloadTag = 1;
	ACENSLog(@"START DOWMLOAD APPID = %@",newItem.appId);
	[myAppRefDict setObject:newItem forKey:newItem.appId];
  	[sView widgetStartDownload:myAppRefDict];
}
-(BOOL)installWidgetWithWidgetID:(NSString *)wID{
	BOOL ret;
	NSString *srcPath = [mainWgtPath stringByAppendingPathComponent:[NSString stringWithFormat:@"data/%@.zip",wID]];
	ACENSLog(@"srcpath = %@",srcPath);
	NSFileManager *fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:srcPath]) {
		return NO;
	}
	//获取安装的路径
	NSString *destPath = [BUtility getDocumentsPath:@"widgets"];
	if (![fm fileExistsAtPath:destPath]) {
		[fm createDirectoryAtPath:destPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	ZipArchive *zipObj = [[ZipArchive alloc] init];
	[zipObj UnzipOpenFile:srcPath];
	ret = [zipObj UnzipFileTo:destPath overWrite:YES];
	[zipObj UnzipCloseFile];
	[zipObj release];
	return ret;
}
-(void)dldWidgetSuccess:(AppItemView *)item{
	//下载完成，刷新界面
	[sView widgetFinishDld:item];
}
-(void)widgetDidDownloadFinish:(ASIHTTPRequest *)request{
	ACENSLog(@"download success");
	needDownload = NO;
	NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:@"spuid"];
	userID = [userid copy];
	self.myAppTableName = [@"AC" stringByAppendingString:userID];
	AppItemView *dItem = [request.userInfo objectForKey:@"downloadItem"];
	[self performSelector:@selector(dldWidgetSuccess:) withObject:dItem];
	//开始安装
	BOOL succ = [self installWidgetWithWidgetID:dItem.appId];
	if (succ) {
		//安装完成后删除原文件
		NSString *srcPath = [mainWgtPath stringByAppendingPathComponent:[NSString stringWithFormat:@"data/%@.zip",dItem.appId]];
		NSFileManager *fm = [NSFileManager defaultManager];
		if ([fm fileExistsAtPath:srcPath]) {
			[fm removeItemAtPath:srcPath error:nil];
			ACENSLog(@"remove srcPath");
		}
	}
	if (!dItem) {
		return;
	}
	NSString *sId = dItem.softwareId;
	//安装完成后上报
	if (succ&&sId) {
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:sView animated:YES];
		hud.labelText = ACELocalized(@"正在安装");
		[hud show:YES];
		//查询数据库
		//如果没有表就创建一个表
		NSString *CreateSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(appid INTEGER PRIMARY KEY,appname text,iconpath text,mode text,softid text,size text,downloadurl text,downloadtag integer,installedtag integer,installreportTag integer,installtime text,uninstallrpttag integer,uninstalltime text)",myAppTableName];
		[self operateSQL:[CreateSql UTF8String]];
		NSString *selectSqlStr = [NSString stringWithFormat:@"select * from %@ where appid = %d",myAppTableName,[dItem.appId intValue]];
		NSArray *array = [self selectSQL:[selectSqlStr UTF8String]];
		if([array count]==0){
			NSString *insertSqlStr = [NSString stringWithFormat:@"INSERT INTO %@(appid,appname,iconpath,mode,softid,size,downloadurl,downloadtag,installedtag,installreporttag,installtime,uninstallrpttag,uninstalltime) VALUES (%d,'%@','%@','%@','%@','%@','%@',1,1,0,'',0,'')",myAppTableName,[dItem.appId intValue],dItem.appName,dItem.appIconUrl,dItem.appMode,dItem.softwareId,dItem.appSize,dItem.downloadUrl];
			ACENSLog(@"pop app insert insert sql = %@",insertSqlStr);
			[self operateSQL:[insertSqlStr UTF8String]];
		}else {
			NSString *updateSqlStr = [NSString stringWithFormat:@"update %@ set downloadtag=1,installedtag=1,installreporttag=0 where appid = %d",myAppTableName,[dItem.appId intValue]];
			[self operateSQL:[updateSqlStr UTF8String]];
		}
		
		[NSThread detachNewThreadSelector:@selector(reportInstallInfo:) toTarget:self withObject:dItem];

	}
	[MBProgressHUD hideHUDForView:sView animated:YES];
	
}
-(void)widgetDidDownloadFail:(ASIHTTPRequest *)request{
	ACENSLog(@"download fail");
	needDownload = NO;
	[self showAlert:ACELocalized(@"下载失败") message: ACELocalized(@"请检查网络连接")];
	AppItemView *item = [request.userInfo objectForKey:@"downloadItem"];
	[myAppRefDict removeObjectForKey:item.appId];
	[self drawBottomView:myAppRefDict];
}
-(void)moreAppDownload:(NSString *)retJson{
	NSString *skey = [[NSUserDefaults standardUserDefaults] objectForKey:@"sessionKey"];
	if (skey==nil) {
		userHasLogin = NO;
	}
	NSDictionary *retDict = [retJson JSONValue];
	if (retDict) {
		AppItemView *appItem = [[AppItemView alloc] init];
		appItem.softwareId = [retDict objectForKey:@"id"];
		appItem.appId = [retDict objectForKey:@"appId"];
		appItem.appName = [retDict objectForKey:@"name"];
		NSString *iconUrlStr = [retDict objectForKey:@"iconLoc"];
		appItem.appIconUrl = [NSURL URLWithString:iconUrlStr];
		appItem.appSize = [retDict objectForKey:@"size"];
		appItem.appMode = [retDict objectForKey:@"createMethod"];
		appItem.downloadUrl = [retDict objectForKey:@"downloadUrl"];
		activeAppId = [appItem.appId copy];
		if (userHasLogin) {
			//如果用户已经登录
			//判断该应用是否已经安装
			BOOL hasInstalled =[self appHasInstall:appItem.appId]; 
			if (hasInstalled==YES) {
				//已经安装 
				[self showAlert:@"" message:ACELocalized(@"该应用已经安装")];
				return;
			}
			if (hasInstalled==NO) {
				//下载应用
				needDownload = YES;
				[self downloadWidgetWithItem:appItem];
			}
			
		}else {
			[myAppRefDict setObject:appItem forKey:appItem.appId];
			activeAppId = appItem.appId;
			[self userLoginStart];
			needDownload = YES;
		}

	}
}
-(void)appCenterSetting{
	ACENSLog(@"setting");
  	[self userLoginStart];
}

-(void)cleanUserInfo{
	ACENSLog(@"clean userinfo");
	userID = nil;
	availableSessionKey = nil;
	userHasLogin = NO;
	[myAppRefDict removeAllObjects];
	[sView drawMyAppView:nil];
}
-(void)hideLoading:(int)startTag retAppId:(NSString *)backAppId{
	ACENSLog(@"hide loading");
	[MBProgressHUD hideHUDForView:sView animated:YES];
	startWgtShowLoading =	NO;
	switch (startTag) {
		case WIDGET_START_SUCCESS:
		{
			ACENSLog(@"启动成功");
			if (![backAppId isEqualToString:@"9999997"]&&![backAppId isEqualToString:@"9999998"]) {
				[NSThread detachNewThreadSelector:@selector(reportStartWidget:) toTarget:self withObject:backAppId];
			}
		}	
			break;
		case WIDGET_START_NOT_EXIST:
			ACENSLog(@"app不存在");
			[self showAlert:ACELocalized(@"提示")  message:ACELocalized(@"该程序还没有安装")];
			break;
		case WIDGET_START_FAIL:
			ACENSLog(@"加载失败");
			break;

		default:
			break;
	}
	
}

-(void)dealloc{
	[dQueue release];
	[mainWgtPath release];
	[currentSessionKey release];
	[availableSessionKey release];
	[portalID release];
	[recmdAppRefDict release];
	[myAppRefDict release];
	[sView release];
	[super dealloc];
}

@end
