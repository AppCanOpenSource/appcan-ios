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

#import "WidgetSQL.h"
#import "BUtility.h"
#import "WWidget.h"
#import "WidgetOneDelegate.h"
@implementation WidgetSQL
//打开数据库
- (void)Open_database:(NSString*)databaseName{
	NSString *DBPath = [BUtility getDocumentsPath:databaseName];
	if (sqlite3_open([DBPath UTF8String], &dbObject)==SQLITE_OK) {
		ACENSLog(@"[success to open DBName=%@]",databaseName);
	}else {
		ACENSLog(@"[fail to open DBName=%@]",databaseName);
	}
}
//关闭数据库
- (void)close_database{
	sqlite3_close(dbObject);
}
//sql执行
-(BOOL)operateSQL:(const char*)inSql{
	ACENSLog(@"insql=%@",[NSString stringWithUTF8String:inSql]);

	char *errorMsg;
	if(sqlite3_exec(dbObject, inSql, NULL, NULL, &errorMsg)==SQLITE_OK){
		ACENSLog(@"[WidgetSQL do sql success]");
		return YES;
	}else {
		ACENSLog(@"[WidgetSQL do sql failed, error=%s]",errorMsg);
		sqlite3_free(errorMsg);
		return NO;
	}
}
//创建表
- (void)createTable:(const char*)inSql{
	[self operateSQL:inSql];
}
//查询
-(NSString*)select:(NSString*)sqlStr{
	sqlite3_stmt *statement; 
	const char *sql = [sqlStr UTF8String];
	if(sqlite3_prepare_v2(dbObject, sql, -1, &statement, NULL)==SQLITE_OK){		
		NSString *fieldValue;
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *rowData = (char *)sqlite3_column_text(statement,1);  
			if (rowData && !(strcmp(rowData, "(null)")==0)) {
				//fieldValue = [[NSString alloc] initWithUTF8String:rowData];
				fieldValue = [NSString stringWithUTF8String:rowData];
			}
			ACENSLog(@"[widgetSQL fileValue=%@]",fieldValue);
		}
		sqlite3_finalize(statement);  //结束数据库查询后关闭
		return fieldValue;
	}
	return nil;
}
//查询widget 
-(NSMutableArray*)selectWgt:(NSString*)sqlStr{
	//YFMOD
//	NSMutableArray *widgetArray = [NSMutableArray arrayWithCapacity:5];
	NSMutableArray *widgetArray = [[[NSMutableArray alloc] initWithCapacity:5] autorelease]; 
	sqlite3_stmt *statement; 
	ACENSLog(@"select sqlStr=%@",sqlStr);
	const char *sql = [sqlStr UTF8String];
	if(sqlite3_prepare_v2(dbObject, sql, -1, &statement, NULL)==SQLITE_OK){		
		while (sqlite3_step(statement) == SQLITE_ROW) {
			int wId = sqlite3_column_int(statement,0); 
			char *wWidgetOneId =(char *)sqlite3_column_text(statement,1);
			char *wWidgetId =(char *)sqlite3_column_text(statement,2);
			char *wAppId =(char *)sqlite3_column_text(statement,3);
			char *wVer =(char *)sqlite3_column_text(statement,4);
			char *wChannelCode =(char *)sqlite3_column_text(statement,5); 
			char *wImei =(char *)sqlite3_column_text(statement,6); 
			char *wmd5Code =(char *)sqlite3_column_text(statement,7); 
			char *wWidgetName=(char *)sqlite3_column_text(statement,8);
			char *wIconPath=(char *)sqlite3_column_text(statement,9);
			char *wWidgetPath=(char *)sqlite3_column_text(statement,10);
			char *wIndexUrl =(char *)sqlite3_column_text(statement,11);
			int wObfuscation =sqlite3_column_int(statement, 12);
			int wWgtType=sqlite3_column_int(statement, 13);
			char *wLogServerIp =(char *)sqlite3_column_text(statement,14);
			char *wUpdateUrl =(char *)sqlite3_column_text(statement,15);
			int wShowMySpace =sqlite3_column_int(statement,16);
			char *wDescription =(char *)sqlite3_column_text(statement,17);
			char *wAuthor =(char *)sqlite3_column_text(statement,18);
			char *wEmail =(char *)sqlite3_column_text(statement,19);
			char *wLicense =(char *)sqlite3_column_text(statement,20);
			int wOrientation = sqlite3_column_int(statement,21); 
			
			WWidget *wgtObj =[[[WWidget alloc]init] autorelease];
			//ACENSLog(@"widgetsql wgtObj retaincount=%d",[wgtObj retainCount]);
			wgtObj.wId = wId;
			if (wWidgetOneId && !(strcmp(wWidgetOneId, "(null)")==0)) {
				//ACENSLog(@"widgetsql wgtObj.widgetOneId retaincount=%d",[wgtObj.widgetOneId retainCount]);
				wgtObj.widgetOneId = [NSString stringWithUTF8String:wWidgetOneId];
				//ACENSLog(@"widgetsql wgtObj.widgetOneId after retaincount=%d",[wgtObj.widgetOneId retainCount]);

			}
			//ACENSLog(@"widgetId=%s",wWidgetId);
			if (wWidgetId && !(strcmp(wWidgetId,"(null)")==0)) {
				wgtObj.widgetId = [NSString stringWithUTF8String:wWidgetId];
			}
			if (wAppId && !(strcmp(wAppId,"(null)")==0)) {
				wgtObj.appId = [NSString stringWithUTF8String:wAppId];
				//ACENSLog(@"widgetsql wgtObj.wAppId retaincount=%d",[wgtObj.appId retainCount]);
				
				
			}
			if (wVer && !(strcmp(wVer,"(null)")==0)) {
				wgtObj.ver = [NSString stringWithUTF8String:wVer];
			}
			if (wChannelCode && !(strcmp(wChannelCode, "(null)")==0)) {
				wgtObj.channelCode = [NSString stringWithUTF8String:wChannelCode];
			}
			if (wImei && !(strcmp(wImei, "(null)")==0)) {
				wgtObj.imei = [NSString stringWithUTF8String:wImei];
			}
			if (wmd5Code && !(strcmp(wmd5Code, "(null)")==0)) {
				wgtObj.md5Code = [NSString stringWithUTF8String:wmd5Code];
			}
			if (wWidgetName && !(strcmp(wWidgetName, "(null)")==0)) {
				wgtObj.widgetName = [NSString stringWithUTF8String:wWidgetName];
			}
			if (wIconPath && !(strcmp(wIconPath, "(null)")==0)) {
				wgtObj.iconPath = [NSString stringWithUTF8String:wIconPath];
			}
			if (wWidgetPath && !(strcmp(wWidgetPath, "(null)")==0)) {
				wgtObj.widgetPath = [NSString stringWithUTF8String:wWidgetPath];
			}
			if (wIndexUrl && !(strcmp(wIndexUrl, "(null)")==0)) {
				wgtObj.indexUrl = [NSString stringWithUTF8String:wIndexUrl];
			}
			if (wLogServerIp && !(strcmp(wLogServerIp, "(null)")==0)) {
				wgtObj.logServerIp = [NSString stringWithUTF8String:wLogServerIp];
			}
			if (wUpdateUrl && !(strcmp(wUpdateUrl, "(null)")==0)) {
				wgtObj.updateUrl = [NSString stringWithUTF8String:wUpdateUrl];
			}
			if (wDescription && !(strcmp(wDescription, "(null)")==0)) {
				wgtObj.description = [NSString stringWithUTF8String:wDescription];
			}
			if (wAuthor && !(strcmp(wAuthor, "(null)")==0)) {
				wgtObj.author = [NSString stringWithUTF8String:wAuthor];
			}
			if (wEmail && !(strcmp(wEmail, "(null)")==0)) {
				wgtObj.email = [NSString stringWithUTF8String:wEmail];
			}
			if (wLicense && !(strcmp(wLicense, "(null)")==0)) {
				wgtObj.license = [NSString stringWithUTF8String:wLicense];
			}
			wgtObj.obfuscation =wObfuscation;
			wgtObj.showMySpace =wShowMySpace;
			wgtObj.wgtType = wWgtType;
			wgtObj.orientation =wOrientation;
			switch (wgtObj.wgtType) {
				case F_WWIDGET_MAINWIDGET:{
					NSString *resPath = nil;
                    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
                    if (theApp.useUpdateWgtHtmlControl && isCopyFinish) {
                        if ([BUtility getSDKVersion]<5.0) {
                            resPath =[BUtility getCachePath:@""];
                        }else {
                            resPath =[BUtility getDocumentsPath:@""];
                        }
                    }else {
                        resPath =[BUtility getResPath:@""];
                    }
					wgtObj.widgetPath = [NSString stringWithFormat:@"%@/%@",resPath,wgtObj.widgetPath];	
					if ([BUtility isSimulator]==YES) {
						if (![wgtObj.indexUrl hasPrefix:F_HTTP_PATH] && ![wgtObj.indexUrl hasPrefix:F_HTTPS_PATH]) {
							wgtObj.indexUrl =[NSString stringWithFormat:@"%@/%@",resPath,wgtObj.indexUrl];
						}
						wgtObj.iconPath = [NSString stringWithFormat:@"%@/%@",resPath,wgtObj.iconPath];
					}else{
						if (![wgtObj.indexUrl hasPrefix:F_HTTP_PATH] && ![wgtObj.indexUrl hasPrefix:F_HTTPS_PATH]){
							wgtObj.indexUrl =[NSString stringWithFormat:@"file://%@/%@",resPath,wgtObj.indexUrl];
						}
						wgtObj.iconPath = [NSString stringWithFormat:@"file://%@/%@",resPath,wgtObj.iconPath];
					}
					break;
				}					
				case F_WWIDGET_SPACEWIDGET:
				case F_WWIDGET_OTHERSWIDGET:
				case F_WWIDGET_TMPWIDGET:{
					NSString *DocPath = [BUtility getDocumentsPath:@""];
					wgtObj.widgetPath = [NSString stringWithFormat:@"%@/%@",DocPath,wgtObj.widgetPath];	
					if ([BUtility isSimulator]==YES) {
						if (![wgtObj.indexUrl hasPrefix:F_HTTP_PATH] && ![wgtObj.indexUrl hasPrefix:F_HTTPS_PATH]){
							wgtObj.indexUrl =[NSString stringWithFormat:@"%@/%@",DocPath,wgtObj.indexUrl];
						}
						wgtObj.iconPath = [NSString stringWithFormat:@"%@/%@",DocPath,wgtObj.iconPath];
					}else{
						if (![wgtObj.indexUrl hasPrefix:F_HTTP_PATH] && ![wgtObj.indexUrl hasPrefix:F_HTTPS_PATH]){
							wgtObj.indexUrl =[NSString stringWithFormat:@"file://%@/%@",DocPath,wgtObj.indexUrl];
						}	
						wgtObj.iconPath = [NSString stringWithFormat:@"file://%@/%@",DocPath,wgtObj.iconPath];
					}
					break;
				}
				default:
					break;
			}
			[widgetArray addObject:wgtObj];
			//ACENSLog(@"widgetsql wgtObj after retaincount=%d",[wgtObj retainCount]);
			//[wgtObj release];
			//ACENSLog(@"[widgetSQL wgtObj=%@]",[wgtObj description]);
		}
		sqlite3_finalize(statement);  //结束数据库查询后关闭
		if ([widgetArray count]>0) {
			ACENSLog(@"[widgetSQL widgetArray count=%d",[widgetArray count]);
			return widgetArray;
		}
	}
	return nil;
}
//插入表中数据
-(void)insertSql:(const char*)inSql{
	[self operateSQL:inSql];
}
//更新数据
-(void)updateSql:(const char*)inSql{
	[self operateSQL:inSql];
}
//删除数据
-(BOOL)deleteSql:(const char*)inSql{
	return [self operateSQL:inSql];
}
//删除表(结构)
- (void)dropTable:(NSString *)tableName{
	NSString *sqlStr = [NSString stringWithFormat:@"DROP TABLE %@",tableName];
	const char*sql = [sqlStr UTF8String];
	[self operateSQL:sql];
}

- (void)dealloc {
	[super dealloc];
}
@end
