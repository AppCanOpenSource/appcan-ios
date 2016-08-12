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

#import "WWidgetMgr.h"
#import "WidgetSQL.h"
#import "AllConfigParser.h"
#import "SpecConfigParser.h"
#import "BUtility.h"
#import "WWidget.h"
#import "UpdateParser.h"
#import "ZipArchive.h"
#import "EUExWidgetOne.h"
#import "WidgetOneDelegate.h"
#import "FileEncrypt.h"


NSString * webappShowAactivety;

@implementation WWidgetMgr
@synthesize wMainWgt;


-(void)dealloc{
	ACENSLog(@"wwidgetMgr dealloc");
    [wMainWgt release];
	wMainWgt = nil;
	[wgtDict release];
	[wgtArr release];
	[super dealloc];
}
#pragma mark mainWidget
//得到主widget
-(WWidget*)mainWidget{
	return wMainWgt;
}
//get wgtPath by wgtObj
- (NSString*)curWidgetPath:(WWidget*)inWgtObj {
    
    WWidget *wgtObj = inWgtObj;
    
    NSString *absPath = [BUtility getDocumentsPath:@""];
    
    NSString *wgtPath = nil;
    
    if (wgtObj.wgtType==F_WWIDGET_MAINWIDGET) {
        
        wgtPath = [NSString stringWithFormat:@"%@/apps/%@",absPath,wgtObj.appId];
        
    } else {
        
        wgtPath = wgtObj.widgetPath;
        
        NSString *wgtPathString = wgtObj.indexUrl;
        
        NSRange range = [wgtObj.indexUrl rangeOfString:@"widget/plugin/"];
        
        if (range.location != NSNotFound) {
            
            wgtPath = [wgtPathString substringToIndex:range.location+range.length];
            
            NSRange range1 = [wgtPath rangeOfString:@"file://"];
            
            wgtPath = [wgtPath substringFromIndex:range1.location+range1.length];
            
            wgtPath = [wgtPath stringByAppendingString:wgtObj.appId];
            
        } else {
            
            
        }
        
    }
    
    NSFileManager *fManager =[[NSFileManager alloc] init];
    
    if ([fManager fileExistsAtPath:wgtPath]==NO) {
        
        [fManager createDirectoryAtPath:wgtPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:wgtPath]];
        
    }
    
    [fManager release];
    
    return wgtPath;
    
}
- (void)initMainWidget {
    
	NSString * queryMainWidget = [NSString stringWithFormat:@"select * from %@ where wgtType=%d",SQL_WGTS_TABLE,F_WWIDGET_MAINWIDGET];
	WidgetSQL * widgetSql = [[WidgetSQL alloc] init];
	[widgetSql Open_database:SQL_WGTONE_DATABASE];
	
	//解析config.xml
    
    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
    
    NSString *configPath = nil;
    if (theApp.useUpdateWgtHtmlControl && isCopyFinish) {
        
        if ([BUtility getSDKVersion] < 5.0) {
            
            configPath = [BUtility getCachePath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
            
        } else {
            
            configPath = [BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
            
        }
        
    } else {
        
        configPath=[BUtility getResPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
        
    }
    
    NSMutableDictionary * tmpWgtDict = [self wgtParameters:configPath];
    
	SpecConfigParser * widgetXml = [[SpecConfigParser alloc] init];
    
	NSString * mVer = [widgetXml initwithReqData:configPath queryPara:CONFIG_TAG_VERSION type:YES];
    
	[widgetXml release];
    
    WidgetOneDelegate * app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
	//数据库里存在，
	NSMutableArray *tempArr = [widgetSql selectWgt:queryMainWidget];
	WWidget*wgtobj = (WWidget*)[tempArr objectAtIndex:0];
    wgtobj.isDebug = [[tmpWgtDict objectForKey:CONFIG_TAG_DEBUG] boolValue];
    wgtobj.widgetOneId = [BUtility appKey];
    
    NSString *obfuscationStr = [tmpWgtDict objectForKey:CONFIG_TAG_OBFUSCATION];
    if([obfuscationStr isEqualToString:@"true"]){
        wgtobj.obfuscation = F_WWIDGET_OBFUSCATION;
        app.enctryptcj = F_WWIDGET_ENCRYPTCJ;
    }else {
        wgtobj.obfuscation = F_WWIDGET_NO_OBFUSCATION;
        app.enctryptcj = F_WWIDGET_NO_ENCRYPTCJ;
    }
    
    NSString * logServerIp = [tmpWgtDict objectForKey:CONFIG_TAG_LOGSERVERIP];
    
    if (logServerIp && ![wgtobj.logServerIp isEqualToString:logServerIp]) {
        
        wgtobj.logServerIp = logServerIp;
        
    }
    
	if (wgtobj!=nil) {
		wgtobj.openAdStatus = 0;//不显示广告
		if ([wgtobj.ver isEqualToString:mVer]) {
			self.wMainWgt = wgtobj;
			ACENSLog(@"wwidgetMgr wmainwgt=%d",[wMainWgt retainCount]);
			[widgetSql close_database];
			[widgetSql release];
			[tempArr removeAllObjects];
			return;
		}
		//remove table
		const char *deleteTable = "drop table wgtTab";
		[widgetSql operateSQL:deleteTable];
	}
	//得到mainWidget,config.xml
	
	ACENSLog(@"tmpWgtDict retainCount=%d",[tmpWgtDict retainCount]);
	NSString *tmpWgtPath =F_MAINWIDGET_NAME;

    NSString * tmpWgtOneId = [BUtility appKey];
    if (tmpWgtOneId) {
        [tmpWgtDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
    }
    
	[tmpWgtDict setObject:tmpWgtPath forKey:CONFIG_TAG_WIDGETPATH];
	[tmpWgtDict setObject:[NSNumber numberWithInt:F_WWIDGET_MAINWIDGET] forKey:CONFIG_TAG_WIDGETTYPE];
		
	wgtobj = [self dictToWgt:tmpWgtDict];
	
	if (wgtobj.showMySpace==1) {
		wgtobj.showMySpace =(WIDGETREPORT_SPACESTATUS_OPEN | WIDGETREPORT_SPACESTATUS_EXTEN_OPEN);
	} 
	//写数据操作
	[self writeWgtToDB:wgtobj createTab:YES];
    
	//组合路径,第一次安装的时候 返回
    
	NSString * resPath = nil ;
    
    if (theApp.useUpdateWgtHtmlControl && isCopyFinish) {
        
        if ([BUtility getSDKVersion] < 5.0) {
            
            resPath=[BUtility getCachePath:@""];
            
        } else {
            
            resPath=[BUtility getDocumentsPath:@""];
            
        }
        
    } else {
        
        resPath=[BUtility getResPath:@""];
        
    }
    
	wgtobj.widgetPath = [NSString stringWithFormat:@"%@/%@",resPath,wgtobj.widgetPath];	
	if ([BUtility isSimulator]==YES) {
		if (![wgtobj.indexUrl hasPrefix:F_HTTP_PATH]) {
			wgtobj.indexUrl =[NSString stringWithFormat:@"%@/%@",resPath,wgtobj.indexUrl];
		}
		wgtobj.iconPath = [NSString stringWithFormat:@"%@/%@",resPath,wgtobj.iconPath];
	}else{
		if (![wgtobj.indexUrl hasPrefix:F_HTTP_PATH] && ![wgtobj.indexUrl hasPrefix:F_HTTPS_PATH]) {
			wgtobj.indexUrl =[NSString stringWithFormat:@"file://%@/%@",resPath,wgtobj.indexUrl];
		}
		wgtobj.iconPath = [NSString stringWithFormat:@"file://%@/%@",resPath,wgtobj.iconPath];
	}
	wgtobj.openAdStatus = 0;//不显示广告。3.30
	self.wMainWgt = wgtobj;
	[widgetSql close_database];
	[widgetSql release];
	[tempArr removeAllObjects];
}

//更新数据库
-(void)writeWgtToDB:(WWidget*)inWidget createTab:(BOOL)isCreateTab{	
	WWidget *wgtObj = inWidget;
	//查询
	NSString *queryWgtSQL = [NSString stringWithFormat:@"select * from %@ where appId='%@' ",SQL_WGTS_TABLE,wgtObj.appId];
	WidgetSQL *widgetSql =[[WidgetSQL alloc] init];
	//打开数据库
	[widgetSql Open_database:SQL_WGTONE_DATABASE];
    wgtObj.widgetOneId = [BUtility appKey];

	NSMutableArray *arr =[widgetSql selectWgt:queryWgtSQL];
	//更新
	if([arr count]>0 && [arr objectAtIndex:0]!=nil){
		WWidget *tmpWidget = (WWidget*)[arr objectAtIndex:0];
		NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET widgetOneId='%@',ver='%@',channelCode='%@',imei='%@',widgetName='%@',iconPath='%@',widgetPath='%@',indexUrl='%@',obfuscation=%d, logServerIp='%@',updateUrl='%@',showMySpace=%d,description='%@',author='%@',email='%@',license='%@',orientation=%d,preload=%d, WHERE id=%d",SQL_WGTS_TABLE,
							   @"",wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,wgtObj.logServerIp,wgtObj.updateUrl,wgtObj.showMySpace,wgtObj.description,wgtObj.author,wgtObj.email,wgtObj.license,wgtObj.orientation,wgtObj.preload, tmpWidget.wId];
		[widgetSql updateSql:[updateSQL UTF8String]];
		
	}else{
		//数据库操作(创建)
		if (isCreateTab==YES) {
			NSString *createTabSQL =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key,widgetOneId text,widgetId text, appId text,ver text,channelCode text,imei text,md5Code text,widgetName text,iconPath text,widgetPath text,indexUrl text,obfuscation integer,wgtType integer,logServerIp text,updateUrl text,showMySpace integer,description text,author text,email text,license text,orientation integer,preload integer)",SQL_WGTS_TABLE];
			[widgetSql createTable:[createTabSQL UTF8String]];
		}
		//插入语句
		NSString *insertStrSQL = [NSString stringWithFormat:@"INSERT INTO %@(widgetOneId,appId,ver,channelCode,imei,widgetName,iconPath,widgetPath,indexUrl,obfuscation,wgtType,logServerIp,updateUrl,showMySpace,description,author,email,license,orientation,preload) VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@',%d,'%@','%@','%@','%@',%d,%d)",SQL_WGTS_TABLE,
								  @"",wgtObj.appId,wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,wgtObj.wgtType,wgtObj.logServerIp,wgtObj.updateUrl,wgtObj.showMySpace,wgtObj.description,wgtObj.author,wgtObj.email,wgtObj.license,wgtObj.orientation,wgtObj.preload];
		
		[widgetSql insertSql:[insertStrSQL UTF8String]];
	}
	[arr removeAllObjects];
	[widgetSql close_database];
	[widgetSql release];
}

-(NSMutableDictionary*)wgtParameters:(NSString*)inFileName{
	//获得了当地的xml配置文件信息，得到字典
	
	NSMutableDictionary *xmlDict =nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:inFileName]) {
		NSData *configData = [NSData dataWithContentsOfFile:inFileName];
		AllConfigParser *configParser=[[AllConfigParser alloc]init];
        
        BOOL isEncrypt = [FileEncrypt isDataEncrypted:configData];
        
        if (isEncrypt) {
            
//            WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
            
            

            
            NSURL *url = nil;
            if ([inFileName hasSuffix:@"file://"]) {
                url = [BUtility stringToUrl:inFileName];;
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", inFileName]];
            }
            
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *data = [encryptObj decryptWithPath:url appendData:nil];
            
            [encryptObj release];
            
            configData = [data dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        
		NSMutableDictionary *tmpDict =[configParser initwithReqData:configData];
		xmlDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		//
		[tmpDict removeAllObjects];
		[configParser release];
	}
    
    
    NSString *showActiveStr = [xmlDict objectForKey:CONFIG_TAG_WEBAPP];
    webappShowAactivety = nil;
	if ([showActiveStr isEqualToString:@"true"]) {
		webappShowAactivety = @"yes";
	}else
    {webappShowAactivety = @"no";}
    
	return xmlDict;
}


-(NSMutableDictionary*)wgtUpdate:(WWidget*)inWgt{
	if (inWgt!=nil&&inWgt.appId!=nil && inWgt.ver!=nil && inWgt.updateUrl!=nil) {
		NSString *urlStr = inWgt.updateUrl;
		NSString *requestUrl = nil;
		if ([urlStr rangeOfString:@"?"].location!=NSNotFound) {
			requestUrl = [NSString stringWithFormat:@"%@&appId=%@&ver=%@&platform=%d",urlStr,inWgt.appId,inWgt.ver,F_WIDGETONE_PLATFORM_IOS];
		}else {
			requestUrl = [NSString stringWithFormat:@"%@?appId=%@&ver=%@&platform=%d",urlStr,inWgt.appId,inWgt.ver,F_WIDGETONE_PLATFORM_IOS];
		}
		ACENSLog(@"requestUrl=%@",requestUrl);
		wgtUpParser =[[UpdateParser alloc]init];
		
		NSMutableDictionary *updateDict =[NSMutableDictionary  dictionaryWithCapacity:1];	
		updateDict =[wgtUpParser initwithReqData:requestUrl];
		return updateDict;
	}
	return nil;
}
-(void)initLoginAndMoreWidget{
	WWidget *loginWgt = [[WWidget alloc] init];
	loginWgt.indexUrl = F_WIDGET_LOGIN_URL;
	loginWgt.appId = @"9999998";
	loginWgt.widgetPath=[BUtility getDocumentsPath:[NSString stringWithFormat:@"apps/%@/%@",wMainWgt.appId,loginWgt.appId]];
	if (!wgtDict) {
		wgtDict = [[NSMutableDictionary alloc] initWithCapacity:0];
	}
	[wgtDict setObject:loginWgt forKey:loginWgt.appId];	
	[loginWgt release];
	WWidget *moreWgt = [[WWidget alloc] init];
	moreWgt.indexUrl =F_WIDGET_MOREWIDGET_URL;
	moreWgt.appId = @"9999997";
	moreWgt.widgetPath=[BUtility getDocumentsPath:[NSString stringWithFormat:@"apps/%@/%@",self.wMainWgt.appId,moreWgt.appId]];	
	[wgtDict setObject:moreWgt forKey:moreWgt.appId];
	[moreWgt release];
	
}
#pragma mark commonWidget

-(WWidget*)wgtDataByAppId:(NSString*)inAppId{
    
    NSString *tmpAppId = [NSString stringWithString:inAppId];
    
    //查询缓存
    WWidget *wgtObj =[wgtDict objectForKey:tmpAppId];
    
    //解析config.xml
    NSString *configPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@/%@",F_NAME_WIDGETS,tmpAppId,F_NAME_CONFIG]];
    ACENSLog(@"configPath=%@",configPath);
    SpecConfigParser *widgetXml = [[SpecConfigParser alloc] init];
    NSString *mVer = [widgetXml initwithReqData:configPath queryPara:CONFIG_TAG_VERSION type:YES];
    [widgetXml release];
    
    
    if ([wgtObj.ver isEqualToString:mVer]) {
        return wgtObj;
    }
    //打开数据库
    WidgetSQL *widgetSql =[[WidgetSQL alloc] init];
    [widgetSql Open_database:SQL_WGTONE_DATABASE];
    NSString *queryComWgt = [NSString stringWithFormat:@"select * from %@ where appId='%@'",SQL_WGTS_TABLE,tmpAppId];
    
    //数据库里存在
    NSMutableArray *tempArr = [widgetSql selectWgt:queryComWgt];
    wgtObj = [tempArr objectAtIndex:0];
    if (wgtObj!=nil) {
        if ([wgtObj.ver isEqualToString:mVer]) {
            [wgtDict setObject:wgtObj forKey:wgtObj.appId];
            [widgetSql close_database];
            [widgetSql release];
            [tempArr removeAllObjects];
            return wgtObj;
        }
    }
    //
    if ([[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        NSMutableDictionary *tmpWgtDict = [self wgtParameters:configPath];
        NSString *tmpWgtOneId = [BUtility appKey];
        NSString *wgtPath=[NSString stringWithFormat:@"%@/%@",F_NAME_WIDGETS,tmpAppId];
        if (tmpWgtOneId) {
            [tmpWgtDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
        }
        [tmpWgtDict setObject:wgtPath forKey:CONFIG_TAG_WIDGETPATH];
        [tmpWgtDict setObject:[NSNumber numberWithInt:F_WWIDGET_OTHERSWIDGET] forKey:CONFIG_TAG_WIDGETTYPE];
        WWidget * tmpWgtObj = [self dictToWgt:tmpWgtDict];
        //写数据操作
        if (wgtObj) {
            [self removeWgtByAppId:tmpAppId];
        }
        [self writeWgtToDB:tmpWgtObj createTab:NO];
        //组合路径,第一次安装的时候 返回
        NSString *DocPath = [BUtility getDocumentsPath:@""];
        
        tmpWgtObj.widgetPath = [NSString stringWithFormat:@"%@/%@",DocPath,tmpWgtObj.widgetPath];
        if ([BUtility isSimulator]==YES) {
            if (![tmpWgtObj.indexUrl hasPrefix:F_HTTP_PATH]) {
                tmpWgtObj.indexUrl =[NSString stringWithFormat:@"%@/%@",DocPath,tmpWgtObj.indexUrl];
            }
            tmpWgtObj.iconPath = [NSString stringWithFormat:@"%@/%@",DocPath,tmpWgtObj.iconPath];
        }else{
            if (![tmpWgtObj.indexUrl hasPrefix:F_HTTP_PATH]) {
                tmpWgtObj.indexUrl =[NSString stringWithFormat:@"file://%@/%@",DocPath,tmpWgtObj.indexUrl];
            }
            tmpWgtObj.iconPath = [NSString stringWithFormat:@"file://%@/%@",DocPath,tmpWgtObj.iconPath];
        }
        wgtObj = tmpWgtObj;
        [wgtDict setObject:wgtObj forKey:wgtObj.appId];
    }else{
        wgtObj=nil;
    }
    [widgetSql close_database];
    [widgetSql release];
    [tempArr removeAllObjects];
    return wgtObj;
}
//plugin widget
-(WWidget*)wgtPluginDataByAppId:(NSString*)inWgtId curWgt:(WWidget*)inCurWgt{
	
	NSString *pluginId = [NSString stringWithString:inWgtId];
	WWidget *pluginWgtObj = nil;
	//得到当前widget,plugin 路径
	NSString *curWgtPath = [NSString stringWithFormat:@"%@/plugin",inCurWgt.widgetPath];
	//解析config.xml
	NSString *configPath =[NSString stringWithFormat:@"%@/%@/%@",curWgtPath,pluginId,F_NAME_CONFIG];
	ACENSLog(@"configPath=%@",configPath);
	if ([[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
		NSMutableDictionary *tmpWgtDict = [self wgtParameters:configPath];
		NSString *tmpWgtOneId = [BUtility appKey];
		NSString *wgtPath=[NSString stringWithFormat:@"%@/%@",curWgtPath,pluginId];
		if (tmpWgtOneId) {
			//ACENSLog(@"tmpWgtOneId retaincount =%d",[tmpWgtOneId retainCount]);
			ACENSLog(@"tmpWgtDict retaincount =%d",[tmpWgtDict retainCount]);
			[tmpWgtDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
		}
		[tmpWgtDict setObject:wgtPath forKey:CONFIG_TAG_WIDGETPATH];
		[tmpWgtDict setObject:[NSNumber numberWithInt:F_WWIDGET_PLUGINWIDGET] forKey:CONFIG_TAG_WIDGETTYPE];
		WWidget * tmpWgtObj = [self dictToWgt:tmpWgtDict];
		
		if ([BUtility isSimulator]==YES) {
			//if (![tmpWgtObj.indexUrl hasPrefix:F_HTTP_PATH]) {
			//	tmpWgtObj.indexUrl =[NSString stringWithFormat:@"%@/%@",wgtPath,tmpWgtObj.indexUrl];
			//}
			//tmpWgtObj.iconPath = [NSString stringWithFormat:@"%@/%@",wgtPath,tmpWgtObj.iconPath];
		}else{
			if (![tmpWgtObj.indexUrl hasPrefix:F_HTTP_PATH]) {
				tmpWgtObj.indexUrl =[NSString stringWithFormat:@"file://%@",tmpWgtObj.indexUrl];
			}
			tmpWgtObj.iconPath = [NSString stringWithFormat:@"file://%@",tmpWgtObj.iconPath];
		}
		//处理widgetpath 以备给插件调用 写文件，共用当前widget文件夹
		NSString *absPath = [BUtility getDocumentsPath:@""];
		if (inCurWgt.wgtType==F_WWIDGET_MAINWIDGET) {
			tmpWgtObj.widgetPath = [NSString stringWithFormat:@"%@/apps/%@",absPath,inCurWgt.appId];
		}else {
			tmpWgtObj.widgetPath = inCurWgt.widgetPath;
		}
		pluginWgtObj = tmpWgtObj;
	}
	return pluginWgtObj;
	
}
//delete wgt by appId
-(BOOL)removeWgtByAppId:(NSString*)inAppId{
	BOOL deleteWgt = NO;
	//删除缓存
	WWidget *wgtObj = [wgtDict objectForKey:inAppId];
	if (wgtObj) {
		[wgtDict removeObjectForKey:inAppId];
	}
	//删除表
	//打开数据库
	WidgetSQL *wgtSql =[[WidgetSQL alloc] init];
	[wgtSql Open_database:SQL_WGTONE_DATABASE];
	NSString *queryComWgt = [NSString stringWithFormat:@"select * from %@ where appId='%@'",SQL_WGTS_TABLE,inAppId];
	//数据库里存在，
	NSMutableArray *tmpArr =[wgtSql selectWgt:queryComWgt]; 
	wgtObj = (WWidget*)[tmpArr objectAtIndex:0];
	if (wgtObj!=nil) {
		NSString *deleteComWgt = [NSString stringWithFormat:@"delete * from %@ where appId='%@'",SQL_WGTS_TABLE,inAppId];
		deleteWgt = [wgtSql deleteSql:[deleteComWgt UTF8String]];
	}
	[wgtSql close_database];
	[wgtSql release];
	[tmpArr removeAllObjects];
	/*NSString *wgtPath;
	//删除文件夹
	if ([inAppId isEqualToString:F_WIDGET_MYSPACE]) {
		wgtPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@/%@",F_NAME_APPS,self.wMainWgt.appId,F_NAME_MYSPACE]];
	}else {
		wgtPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_NAME_WIDGETS,inAppId]];
	}
	NSFileManager *fMan = [NSFileManager defaultManager];
	if ([fMan fileExistsAtPath:wgtPath]) {
		BOOL removeSuccess = [fMan removeItemAtPath:wgtPath error:nil];
		if (removeSuccess) {
			return F_WIDGET_REMOVE_SUCCESS;
		}
	}
	//[fMan release];*/
	return deleteWgt;
}
#pragma mark util
-(WWidget*)dictToWgt:(NSMutableDictionary*)inDict{
	NSMutableDictionary *tmpDict =[NSMutableDictionary dictionaryWithDictionary:inDict];
	
	WWidget *tmpWgt = [[WWidget alloc]init];
	//widgetId  2
	NSString *tmpWId = [tmpDict objectForKey:CONFIG_TAG_WIDGETID];
	if (tmpWId) {
		tmpWgt.widgetId = tmpWId;
	}
	//widgetOneId 1
	NSString *tmpWoId = [tmpDict objectForKey:CONFIG_TAG_WIDGETONEID];
	if (tmpWoId) {
		tmpWgt.widgetOneId = tmpWoId;
	}
	//appId 3
	NSString *tmpAppId = [[tmpDict objectForKey:CONFIG_TAG_WIDGET] objectForKey:CONFIG_TAG_APPID];
	if (tmpAppId) {
		tmpWgt.appId =tmpAppId;
	}
	//ver 4
	NSString *tmpVer = [[tmpDict objectForKey:CONFIG_TAG_WIDGET] objectForKey:CONFIG_TAG_VERSION];
	if (tmpVer) {
		tmpWgt.ver = tmpVer;
	}
	//channel 5
	NSString *tmpChannelCode = [[tmpDict objectForKey:CONFIG_TAG_WIDGET] objectForKey:CONFIG_TAG_CHANNELCODE];
	if (tmpChannelCode) {
		tmpWgt.channelCode =tmpChannelCode;
	}
	//imei 6
	tmpWgt.imei = [BUtility getDeviceIdentifyNo];
	
	//widgetName 8
	NSString *tmpName= [tmpDict objectForKey:CONFIG_TAG_NAME];
	if (tmpName) {
		tmpWgt.widgetName = tmpName;
	}
	//widgetPath
	NSString *wgtPath = [tmpDict objectForKey:CONFIG_TAG_WIDGETPATH];
	tmpWgt.widgetPath = wgtPath;
	//indexUrl 11
	NSString *indexStr =[[tmpDict objectForKey:CONFIG_TAG_CONTENT] objectForKey:CONFIG_TAG_SRC];
	//1.4 http://
	if ([indexStr hasPrefix:F_HTTP_PATH] || [indexStr hasPrefix:F_HTTPS_PATH] ) {
		tmpWgt.indexUrl =indexStr;
	}else{
		if ([indexStr isEqualToString:@"#"]) {
			indexStr = @"index.html";
		}
		tmpWgt.indexUrl = [NSString stringWithFormat:@"%@/%@",wgtPath,indexStr];
	}
			

	//indexIcon 9,10
	NSString *iconStr = [[tmpDict objectForKey:CONFIG_TAG_ICON] objectForKey:CONFIG_TAG_SRC];
	tmpWgt.iconPath = [NSString stringWithFormat:@"%@/%@",wgtPath,iconStr];
	//加密 12 
	NSString *obfuscationStr = [tmpDict objectForKey:CONFIG_TAG_OBFUSCATION];
	if([obfuscationStr isEqualToString:@"true"]){
		tmpWgt.obfuscation = F_WWIDGET_OBFUSCATION; //加密
	}else {
		tmpWgt.obfuscation = F_WWIDGET_NO_OBFUSCATION;
	}
    
	//wgtType 13
	NSString *wgtTypeStr = [tmpDict objectForKey:CONFIG_TAG_WIDGETTYPE];
	if (wgtTypeStr) {
		tmpWgt.wgtType = [wgtTypeStr intValue];
	}
	//logIP 14
	NSString *logServerIpStr = [tmpDict objectForKey:CONFIG_TAG_LOGSERVERIP];
	if (logServerIpStr) {
		tmpWgt.logServerIp = logServerIpStr;
	}
	//updateUrl 15
	NSString *updateUrlStr = [tmpDict objectForKey:CONFIG_TAG_UPDATEURL];
	if (updateUrlStr) {
		tmpWgt.updateUrl = updateUrlStr;
	}
	//16 showMySpace
	NSString *showMySpaceStr = [tmpDict objectForKey:CONFIG_TAG_SHOWMYSPACE];
	if (showMySpaceStr && [showMySpaceStr isEqualToString:@"true"]) {
		tmpWgt.showMySpace = F_WIDGET_SHOWMYSPACE;
	}
	//17.description
	NSString *desStr = [tmpDict objectForKey:CONFIG_TAG_DESCRIPTION];
	if (desStr) {
		tmpWgt.description = desStr;
	}
	//author 18,19
	NSString *authorStr = [[tmpDict objectForKey:CONFIG_TAG_AUTHOR] objectForKey:CONFIG_TAG_NAME];
	NSString *emailStr = [[tmpDict objectForKey:CONFIG_TAG_AUTHOR] objectForKey:CONFIG_TAG_EMAIL];
	if (authorStr) {
		tmpWgt.author = authorStr;
	}
	if (emailStr) {
		tmpWgt.email = emailStr;
	}
	//license 20
	NSString *licenseStr = [[tmpDict objectForKey:CONFIG_TAG_LICENSE] objectForKey:CONFIG_TAG_HREF];
	if (licenseStr) {
		tmpWgt.license = licenseStr;
	}
	//orientation 21
	NSString *orientationStr = [tmpDict objectForKey:CONFIG_TAG_ORIENTATION];
	if (orientationStr) {
		tmpWgt.orientation = [orientationStr intValue];
	}else {
		tmpWgt.orientation = 1;
	}
	//preload 22
	NSString *preloadFlag = [tmpDict objectForKey:CONFIG_TAG_PRELOAD];
	if (preloadFlag && [preloadFlag isEqualToString:@"true"]) {
		tmpWgt.preload = 1;
	}else {
		tmpWgt.preload = 0;
	}
    //isDebug
    NSString * isDebug = [tmpDict objectForKey:CONFIG_TAG_DEBUG];
    if (isDebug) {
        tmpWgt.isDebug = [isDebug boolValue];
    } else{
        tmpWgt.isDebug = NO;
    }
    
	[tmpDict removeAllObjects];
	return [tmpWgt autorelease];
}

//create request folder
-(void)createReqFolder{
	NSFileManager *fManager = [NSFileManager defaultManager];
	if (wMainWgt) {
		NSString *absMainPath =[self curWidgetPath:wMainWgt];
		NSString *videoPath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_VIDEO];
		NSString *audioPath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_AUDIO];
		NSString *photoPath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_PHOTO];
		NSString *myspacePath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_MYSPACE];
    
        if ([fManager fileExistsAtPath:absMainPath]==NO) {
            [fManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
             [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:absMainPath]];
        }
        
		if([fManager fileExistsAtPath:videoPath]==NO){
			[fManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
        
		if([fManager fileExistsAtPath:audioPath]==NO){
			[fManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		if([fManager fileExistsAtPath:photoPath]==NO){
			[fManager createDirectoryAtPath:photoPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		if([fManager fileExistsAtPath:myspacePath]==NO){
			[fManager createDirectoryAtPath:myspacePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
	}
	NSString *wgtFolders = [BUtility getDocumentsPath:F_NAME_WIDGETS];
	if ([fManager fileExistsAtPath:wgtFolders]==NO) {
		[fManager createDirectoryAtPath:wgtFolders withIntermediateDirectories:YES attributes:nil error:nil];
        [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:wgtFolders]];

	}
	[fManager release];
}
//init load
- (void) loadMainWidget {	
	[self initMainWidget];
	[self createReqFolder];
	if ([BUtility getAppCanDevMode]) {
		[ self unZipNormal];
	}else {
		[self initLoginAndMoreWidget];
	}
    //开发模式
    if ([BUtility getAppCanDevMode]) {
        [self createTmpFolder];
    }
}
#pragma mark develop_version
-(void)createTmpFolder{
	NSFileManager *fManager = [NSFileManager defaultManager];
	NSString *absPath = [BUtility getDocumentsPath:@"widgetone/widgetapp"];
	for (int i =1; i<21; i++) {
		NSString *tmpPath = [NSString stringWithFormat:@"%@/%d",absPath,i];
		if([fManager fileExistsAtPath:tmpPath]==NO){
			[fManager createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
}

-(void)unZipNormal{
	ZipArchive *zipObj = [[ZipArchive alloc] init];
	NSString *sourceWgt = [BUtility getResPath:@"widget/hiAppcan.zip"];
	NSString *outPath =[BUtility getDocumentsPath:@"widgetone/widgetapp/hiAppcan"];
	NSString *configPath = [NSString stringWithFormat:@"%@/config.xml",outPath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:sourceWgt]==YES) {
			[zipObj UnzipOpenFile:sourceWgt]; 
			[zipObj UnzipFileTo:outPath overWrite:NO];
			[zipObj UnzipCloseFile];
		}
	}
	[zipObj release];
}


-(void)loadAllWidget{
	//查找指定目录下文件夹个数 widgets
	NSString *appRootDir = [BUtility getDocumentsPath:@"widgetone/widgetapp"];
	NSFileManager *fManager = [NSFileManager defaultManager];
	if (![fManager fileExistsAtPath:appRootDir]) {	
		[fManager createDirectoryAtPath:appRootDir withIntermediateDirectories:YES attributes:nil error:nil];	
	}else if ([BUtility fileisDirectoy:appRootDir]) {
		//打开数据库，插入操作。。。
		WidgetSQL *doSql =[[WidgetSQL alloc] init];
		//打开数据库
		[doSql Open_database:SQL_WGTONE_DATABASE];
		NSString *deleteComWgt = [NSString stringWithFormat:@"delete from %@ where wgtType=%d",SQL_WGTS_TABLE,F_WWIDGET_TMPWIDGET];
		//数据库里存在，删除
		[doSql deleteSql:[deleteComWgt UTF8String]]; 
		//插入语句
		NSMutableString	*insertStrSQL =[NSMutableString stringWithString:@""]; 
		NSArray *fileList = [NSMutableArray arrayWithCapacity:50];
		fileList = [fManager contentsOfDirectoryAtPath:appRootDir error:nil];
		for (int i=0; i<[fileList count]; i++) {
			NSString *fileName = [fileList objectAtIndex:i];
			NSString *widgetPath = [NSString stringWithFormat:@"widgetone/widgetapp/%@",fileName];
			NSString *configName = [NSString stringWithFormat:@"%@/%@/%@",appRootDir,fileName,@"config.xml"];
			if ([fileName hasPrefix:@"."]==NO &&[fManager fileExistsAtPath:configName]) {
				NSMutableDictionary *tmpDict =[NSMutableDictionary dictionaryWithCapacity:10];
				tmpDict = [self wgtParameters:configName];
				[tmpDict setObject:widgetPath forKey:CONFIG_TAG_WIDGETPATH];
				NSString *tmpWgtOneId = [BUtility appKey];
				if (tmpWgtOneId) {
					[tmpDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
					
				}
				WWidget *wgtObj =[self dictToWgt:tmpDict];
				//NSString *tmpInsert = [NSString stringWithFormat:@"INSERT INTO %@(widgetOneId,appId,ver,channelCode,imei,widgetName,iconPath,widgetPath,indexUrl,obfuscation,wgtType,logServerIp,updateUrl) VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@');",SQL_WGTS_TABLE, 
//									   wgtObj.widgetOneId,wgtObj.appId,wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,F_WWIDGET_TMPWIDGET,wgtObj.logServerIp,wgtObj.updateUrl];
				NSString *tmpInsert = [NSString stringWithFormat:@"INSERT INTO %@(widgetOneId,appId,ver,channelCode,imei,widgetName,iconPath,widgetPath,indexUrl,obfuscation,wgtType,logServerIp,updateUrl,showMySpace,description,author,email,license,orientation) VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@',%d,'%@','%@','%@','%@',%d);",SQL_WGTS_TABLE,
										  @"",wgtObj.appId,wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,F_WWIDGET_TMPWIDGET,wgtObj.logServerIp,wgtObj.updateUrl,wgtObj.showMySpace,wgtObj.description,wgtObj.author,wgtObj.email,wgtObj.license,wgtObj.orientation];
				
				[insertStrSQL appendString:tmpInsert];
			}
		}
		[doSql insertSql:[insertStrSQL UTF8String]];
		[doSql close_database];
		[doSql release];
	}
}

-(int)widgetNumber{
	[self loadAllWidget];
	WidgetSQL *widgetObj =[[WidgetSQL alloc] init];
	//打开数据库
	[widgetObj Open_database:SQL_WGTONE_DATABASE];
	NSString *queryComWgt = [NSString stringWithFormat:@"select * from %@ where wgtType=%d",SQL_WGTS_TABLE,F_WWIDGET_TMPWIDGET];
	//数据库里存在，
	NSMutableArray *tmpArr =[widgetObj selectWgt:queryComWgt];
	wgtArr =[[NSMutableArray alloc] initWithArray:tmpArr];
	NSUInteger wgtsNum = [wgtArr count];
	[widgetObj close_database];
	[widgetObj release];
	[tmpArr removeAllObjects];
	return wgtsNum;
}
-(WWidget*)wgtDataByID:(int)inIndex{
	if (inIndex<[wgtArr count]) {
		WWidget *wgtObj = [wgtArr objectAtIndex:inIndex];
		return wgtObj;
	}
	return nil;
}

#pragma mark -update 
-(BOOL)isNeetUpdateWgt{
    if (theApp.useUpdateWgtHtmlControl) {
        NSString *newConfigPath = nil;
        NSString *appConfigPath = nil;
        if ([BUtility getSDKVersion]<5.0) {
            newConfigPath=[BUtility getCachePath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
        }else {
            newConfigPath=[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
        }
        appConfigPath =[BUtility getResPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
        //new
        SpecConfigParser *newWidgetXml = [[SpecConfigParser alloc] init];
        NSString *mNewVer = [newWidgetXml initwithReqData:newConfigPath queryPara:CONFIG_TAG_VERSION type:YES];
        if (!mNewVer) {
            mNewVer = @"";
        }
        [newWidgetXml release];
        //app
        SpecConfigParser *appWidgetXml = [[SpecConfigParser alloc] init];
        NSString *mAppVer = [appWidgetXml initwithReqData:appConfigPath queryPara:CONFIG_TAG_VERSION type:YES];
        [appWidgetXml release];
        NSComparisonResult result = [mNewVer compare:mAppVer];
        if (result==NSOrderedAscending) {
            return YES;
        }
    }
    return NO;
}
/*
 //md5 deprecate 1.1.022
 -(NSString *)md5Str:(NSString *)inImei widgetOneId:(NSString*)inWidgetOneId appId:(NSString*)inAppId ver:(NSString*)inVer channelCode:(NSString*)inChannelCode{
 NSData *imeiData = [inImei dataUsingEncoding:NSUTF8StringEncoding];
 NSData *key1Data =[WIDGET_REG_KEY_1 dataUsingEncoding:NSUTF8StringEncoding];
 NSData *widgetOneIdData = [inWidgetOneId dataUsingEncoding:NSUTF8StringEncoding];
 NSData *key2Data = [WIDGET_REG_KEY_2 dataUsingEncoding:NSUTF8StringEncoding];
 NSData *appIdData = [inAppId dataUsingEncoding:NSUTF8StringEncoding];
 NSData *key3Data = [WIDGET_REG_KEY_3 dataUsingEncoding:NSUTF8StringEncoding];
 NSData *verData = [inVer dataUsingEncoding:NSUTF8StringEncoding];
 NSData *key4Data = [WIDGET_REG_KEY_4 dataUsingEncoding:NSUTF8StringEncoding];
 NSData *channelCodeData = [inChannelCode dataUsingEncoding:NSUTF8StringEncoding];
 
 CC_MD5_CTX md5;  
 CC_MD5_Init(&md5);
 
 CC_MD5_Update(&md5, [imeiData bytes],[imeiData length]);
 CC_MD5_Update(&md5, [key1Data bytes],[key1Data length]);
 CC_MD5_Update(&md5, [widgetOneIdData bytes],[widgetOneIdData length]);
 CC_MD5_Update(&md5, [key2Data bytes],[key2Data length]);
 CC_MD5_Update(&md5, [appIdData bytes],[appIdData length]);
 CC_MD5_Update(&md5, [key3Data bytes],[key3Data length]);
 CC_MD5_Update(&md5, [verData bytes],[verData length]);
 CC_MD5_Update(&md5, [key4Data bytes],[key4Data length]);
 CC_MD5_Update(&md5, [channelCodeData bytes],[channelCodeData length]);
 
 unsigned char digest[CC_MD5_DIGEST_LENGTH];  
 CC_MD5_Final(digest, &md5); 
 NSString *md5Str = [NSString stringWithFormat:
 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
 digest[0], digest[1], digest[2], digest[3], 
 digest[4], digest[5], digest[6], digest[7],
 digest[8], digest[9], digest[10], digest[11],
 digest[12], digest[13], digest[14], digest[15]]; 
 return [md5Str lowercaseString];
 }
 
 -(void)unZipCase{
 ZipArchive *zipObj = [[ZipArchive alloc] init];
 NSString *caseWgt = [BUtility getResPath:@"space/test.zip"];
 NSString *caseToRoot = [BUtility getDocumentsPath:@"widgetone/widgetapp/test"];
 NSString *caseConfig = [NSString stringWithFormat:@"%@/config.xml",caseToRoot];
 if ([[NSFileManager defaultManager] fileExistsAtPath:caseConfig]==NO) {
 if ([[NSFileManager defaultManager] fileExistsAtPath:caseWgt]==YES) {
 [zipObj UnzipOpenFile:caseWgt]; 
 [zipObj UnzipFileTo:caseToRoot overWrite:NO];
 [zipObj UnzipCloseFile];
 }
 }
 [zipObj release];
 }
 -(void)unZipSpace{
 ZipArchive *zipObj = [[ZipArchive alloc] init];
 NSString *spaceSourceWgt = [BUtility getResPath:@"space/space.zip"];
 NSString *spaceToWgt = [NSString stringWithFormat:@"%@/%@",[self curWidgetPath:self.wMainWgt],F_NAME_MYSPACE];
 NSString *spaceToConfig = [NSString stringWithFormat:@"%@/config.xml",spaceToWgt];
 if ([[NSFileManager defaultManager] fileExistsAtPath:spaceToConfig]==NO) {
 if ([[NSFileManager defaultManager] fileExistsAtPath:spaceSourceWgt]==YES) {
 [zipObj UnzipOpenFile:spaceSourceWgt]; 
 [zipObj UnzipFileTo:spaceToWgt overWrite:NO];
 [zipObj UnzipCloseFile];
 }
 }
 [zipObj release];
 }
 #pragma mark widgetOne
 //deprecate in Version 1.1.022
 -(NSString*)WidgetOneVersion{
 NSString* wgtOneVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:F_WIDGETONEVERSION];
 return wgtOneVer;
 }
 -(void)wgtOneRegist{
 NSString *wgtOneId = [self wgtOneID];
 
 if (wgtOneId==NULL && [self WidgetOneVersion]!=nil) {
 //请求连接
 NSString *requestUrl = [NSString stringWithFormat:@"%@?ver=%@&screenSize=%@&imei=%@",
 F_WIDGETONE_REGIST_URL,
 [self WidgetOneVersion],
 [BUtility getScreenWAndH],
 [BUtility getDeviceIdentifyNo]];
 ACENSLog(@"[wgtOneRegist requestUrl=%@]",requestUrl);
 wgtOneRegParser = [[SpecConfigParser alloc] init];
 [wgtOneRegParser sendHttpReq:requestUrl queryPara:CONFIG_TAG_WIDGETONEID doSql:DOSQL_WIDGETONE_NUM];
 }
 }
 -(BOOL)isHaveWgtOneId{
 NSString *mWgtOneId = [self wgtOneID];
 if (mWgtOneId!=nil) {
 return YES;
 }
 return NO;
 }
 -(NSString*)wgtOneID{
 WidgetSQL *wgtSqlObj =[[WidgetSQL alloc] init];
 [wgtSqlObj Open_database:SQL_WGTONE_DATABASE];
 NSString *wgtOneIdSql = [NSString stringWithFormat:@"select * from %@",SQL_WGTONE_TABLE];
 NSString *wgtOneId = [wgtSqlObj select:wgtOneIdSql];
 [wgtSqlObj close_database];
 [wgtSqlObj release];
 if (wgtOneId) {
 return wgtOneId;
 }
 return nil;
 }
 //deprecate 1.1.022 2012-06-25
 */
#pragma mark spaceWidget
/*-(void)initSpaceWidget{
 //zip
 [self unZipSpace];
 //打开数据库
 WidgetSQL *widgetSql =[[WidgetSQL alloc] init];
 [widgetSql Open_database:SQL_WGTONE_DATABASE];
 NSString *querySpaceWgt = [NSString stringWithFormat:@"select * from %@ where wgtType=%d",SQL_WGTS_TABLE,F_WWIDGET_SPACEWIDGET];
 //得到space,config.xml
 NSString *configPath = [BUtility getDocumentsPath:[NSString stringWithFormat:@"apps/%@/%@/%@",self.wMainWgt.appId,F_NAME_MYSPACE,F_NAME_CONFIG]];
 SpecConfigParser *widgetXml = [[SpecConfigParser alloc] init];
 NSString *mVer = [widgetXml initwithReqData:configPath queryPara:CONFIG_TAG_VERSION type:YES];
 [widgetXml release];
 //数据库里存在，
 NSMutableArray *tempArr = [widgetSql selectWgt:querySpaceWgt];
 if ([tempArr objectAtIndex:0]!=nil) {
 WWidget *wgtobj = [tempArr objectAtIndex:0];
 if ([wgtobj.ver isEqualToString:mVer]) {
 self.wSpaceWgt = wgtobj;
 [widgetSql close_database];
 [widgetSql release];
 return;
 }
 }
 NSMutableDictionary *tmpWgtDict = [self wgtParameters:configPath];
 //	NSLog(@"tmpWgtDict=%@",tmpWgtDict);
 NSString *tmpWgtOneId = [self wgtOneID];
 NSString *wgtPath = [NSString stringWithFormat:@"apps/%@/%@",self.wMainWgt.appId,F_NAME_MYSPACE];
 if (tmpWgtOneId) {
 [tmpWgtDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
 }
 [tmpWgtDict setObject:wgtPath forKey:CONFIG_TAG_WIDGETPATH];
 [tmpWgtDict setObject:[NSNumber numberWithInt:F_WWIDGET_SPACEWIDGET] forKey:CONFIG_TAG_WIDGETTYPE];
 WWidget *wgtObj= [self dictToWgt:tmpWgtDict];
 //写数据操作
 [self writeWgtToDB:wgtObj createTab:NO];
 //组合路径,第一次安装的时候 返回
 NSString *DocPath = [BUtility getDocumentsPath:@""];
 wgtObj.widgetPath = [NSString stringWithFormat:@"%@/%@",DocPath,wgtObj.widgetPath];	
 if ([BUtility isSimulator]==YES) {
 if (![wgtObj.indexUrl hasPrefix:F_HTTP_PATH]) {
 wgtObj.indexUrl =[NSString stringWithFormat:@"%@/%@",DocPath,wgtObj.indexUrl];
 }
 wgtObj.iconPath = [NSString stringWithFormat:@"%@/%@",DocPath,wgtObj.iconPath];
 }else{
 if (![wgtObj.indexUrl hasPrefix:F_HTTP_PATH]) {
 wgtObj.indexUrl =[NSString stringWithFormat:@"file://%@/%@",DocPath,wgtObj.indexUrl];
 }
 wgtObj.iconPath = [NSString stringWithFormat:@"file://%@/%@",DocPath,wgtObj.iconPath];
 }
 self.wSpaceWgt = wgtObj;
 [widgetSql close_database];
 [widgetSql release];
 }*/
/* deprecate 1.1.022
 -(void)wgtRegist:(WWidget*)inWgt{
 WWidget *widgetObj = inWgt;
 //查询widgetOneId
 if (!widgetObj.widgetOneId) {
 widgetObj.widgetOneId = [self wgtOneID];
 }
 //判断widgetId,是否存在，不存在，则注册
 if(!widgetObj.widgetId) {
 if (widgetObj.widgetOneId!=NULL && widgetObj.channelCode!=NULL && widgetObj.ver!=NULL &&widgetObj.imei!=NULL) {
 NSString *widgetMd5 = [self md5Str:widgetObj.imei widgetOneId:widgetObj.widgetOneId appId:widgetObj.appId ver:widgetObj.ver channelCode:widgetObj.channelCode];
 NSString *requestUrl = [NSString stringWithFormat:@"%@?widgetOneId=%@&appId=%@&channelCode=%@&ver=%@&imei=%@&md5Code=%@",
 F_WIDGET_REGIST_URL,
 widgetObj.widgetOneId,
 widgetObj.appId,
 widgetObj.channelCode,
 widgetObj.ver,
 widgetObj.imei,
 widgetMd5];
 ACENSLog(@"[wgtRegist requestUrl=%@]",requestUrl);
 //3.26
 wgtRegParser = [[SpecConfigParser alloc] init];
 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:5];
 [dict setObject:widgetObj.widgetOneId forKey:@"widgetOneId"];
 [dict setObject:widgetMd5 forKey:@"md5Code"];
 [dict setObject:widgetObj.appId forKey:@"appId"];
 [wgtRegParser sendHttpReq:requestUrl queryPara:@"widgetId" doSql:DOSQL_WIDGET_NUM wgtDict:dict];
 }
 }	
 }
 
 -(void)wgtReport:(WWidget*)inWgtObj{
 if (inWgtObj!=nil&&inWgtObj.widgetId!=nil) {
 wgtRepParser = [[WgtReportParser alloc] init];
 [wgtRepParser wgtReport:inWgtObj];
 }	
 }*/
@end
