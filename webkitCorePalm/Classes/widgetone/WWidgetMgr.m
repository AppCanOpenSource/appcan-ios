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

#import "BUtility.h"
#import "WWidget.h"
#import "UpdateParser.h"
#import "ZipArchive.h"
#import "EUExWidgetOne.h"
#import "WidgetOneDelegate.h"
#import "FileEncrypt.h"
#import "ACEConfigXML.h"
#import "ACEDes.h"
#import "AppCanEngine.h"
#import "ACEWidgetUpdateUtility.h"

NSString * webappShowAactivety;

@interface WWidgetMgr()
@property (nonatomic,strong,readwrite)WWidget* mainWidget;
@end


@implementation WWidgetMgr


+ (instancetype)sharedManager{
    static WWidgetMgr *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}



#pragma mark mainWidget


- (void)initMainWidget {
    
	NSString * queryMainWidget = [NSString stringWithFormat:@"select * from %@ where wgtType=%d",SQL_WGTS_TABLE,F_WWIDGET_MAINWIDGET];
	WidgetSQL * widgetSql = [[WidgetSQL alloc] init];
	[widgetSql Open_database:SQL_WGTONE_DATABASE];
	
	//解析config.xml
    
    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
    
    NSString *configPath, *tmpWgtPath, *basePath;
    if (AppCanEngine.configuration.useUpdateWgtHtmlControl && isCopyFinish && ![ACEWidgetUpdateUtility isWidgetCopyNeeded]) {
        tmpWgtPath = AppCanEngine.configuration.documentWidgetPath;
        configPath = [BUtility getDocumentsPath:[tmpWgtPath stringByAppendingPathComponent:@"config.xml"]];
        basePath = [BUtility getDocumentsPath:@""];
    } else {
        tmpWgtPath = AppCanEngine.configuration.originWidgetPath;
        configPath = [BUtility getResPath:[tmpWgtPath stringByAppendingPathComponent:@"config.xml"]];
        basePath = [BUtility getResPath:@""];
    }
    NSMutableDictionary * tmpWgtDict = [self wgtParameters:configPath];


    
	//数据库里存在，
	NSMutableArray *tempArr = [widgetSql selectWgt:queryMainWidget];
	WWidget*wgtobj = (WWidget*)[tempArr objectAtIndex:0];
    wgtobj.isDebug = [[tmpWgtDict objectForKey:CONFIG_TAG_DEBUG] boolValue];
    wgtobj.widgetOneId = [BUtility appKey];
    
    NSString *obfuscationStr = [tmpWgtDict objectForKey:CONFIG_TAG_OBFUSCATION];
    if([obfuscationStr isEqualToString:@"true"]){
        wgtobj.obfuscation = F_WWIDGET_OBFUSCATION;
        ACEDes.decryptionEnable = YES;
    }else {
        wgtobj.obfuscation = F_WWIDGET_NO_OBFUSCATION;

    }
    
    NSString * logServerIp = [tmpWgtDict objectForKey:CONFIG_TAG_LOGSERVERIP];
    
    if (logServerIp && ![wgtobj.logServerIp isEqualToString:logServerIp]) {
        wgtobj.logServerIp = logServerIp;
    }
//	if (wgtobj!=nil) {
//		wgtobj.openAdStatus = 0;//不显示广告
//		if ([wgtobj.ver isEqualToString:mVer]) {
//			self.mainWidget = wgtobj;
//			[widgetSql close_database];
//			return;
//		}
//		//remove table
//		const char *deleteTable = "drop table wgtTab";
//		[widgetSql operateSQL:deleteTable];
//	}
	//得到mainWidget,config.xml
	


    NSString * tmpWgtOneId = [BUtility appKey];
    if (tmpWgtOneId) {
        [tmpWgtDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
    }
	[tmpWgtDict setObject:tmpWgtPath forKey:CONFIG_TAG_WIDGETPATH];
	[tmpWgtDict setObject:[NSNumber numberWithInt:F_WWIDGET_MAINWIDGET] forKey:CONFIG_TAG_WIDGETTYPE];
		
	wgtobj = [self dictToWgt:tmpWgtDict];
	
	if (wgtobj.showMySpace == 1) {
		wgtobj.showMySpace = (WIDGETREPORT_SPACESTATUS_OPEN | WIDGETREPORT_SPACESTATUS_EXTEN_OPEN);
	}
    wgtobj.widgetPath = [basePath stringByAppendingPathComponent:wgtobj.widgetPath];
    

    if (![wgtobj.indexUrl hasPrefix:F_HTTP_PATH] && ![wgtobj.indexUrl hasPrefix:F_HTTPS_PATH]) {
        wgtobj.indexUrl = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:wgtobj.indexUrl]].standardizedURL.absoluteString;
    }
    wgtobj.iconPath = [NSURL fileURLWithPath:[basePath stringByAppendingPathComponent:wgtobj.iconPath]].standardizedURL.absoluteString;
	
	wgtobj.openAdStatus = 0;//不显示广告。3.30
	self.mainWidget = wgtobj;
    
    //写数据操作
    [self writeWgtToDB:wgtobj createTab:YES];
	[widgetSql close_database];

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
							   @"",wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,wgtObj.logServerIp,wgtObj.updateUrl,wgtObj.showMySpace,wgtObj.desc,wgtObj.author,wgtObj.email,wgtObj.license,wgtObj.orientation,wgtObj.preload, tmpWidget.wId];
		[widgetSql updateSql:[updateSQL UTF8String]];
		
	}else{
		//数据库操作(创建)
		if (isCreateTab==YES) {
			NSString *createTabSQL =[NSString stringWithFormat:@"create table if not exists %@(id integer primary key,widgetOneId text,widgetId text, appId text,ver text,channelCode text,imei text,md5Code text,widgetName text,iconPath text,widgetPath text,indexUrl text,obfuscation integer,wgtType integer,logServerIp text,updateUrl text,showMySpace integer,description text,author text,email text,license text,orientation integer,preload integer)",SQL_WGTS_TABLE];
			[widgetSql createTable:[createTabSQL UTF8String]];
		}
		//插入语句
		NSString *insertStrSQL = [NSString stringWithFormat:@"INSERT INTO %@(widgetOneId,appId,ver,channelCode,imei,widgetName,iconPath,widgetPath,indexUrl,obfuscation,wgtType,logServerIp,updateUrl,showMySpace,description,author,email,license,orientation,preload) VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@',%d,%d,'%@','%@',%d,'%@','%@','%@','%@',%d,%d)",SQL_WGTS_TABLE,
								  @"",wgtObj.appId,wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,wgtObj.wgtType,wgtObj.logServerIp,wgtObj.updateUrl,wgtObj.showMySpace,wgtObj.desc,wgtObj.author,wgtObj.email,wgtObj.license,wgtObj.orientation,wgtObj.preload];
		
		[widgetSql insertSql:[insertStrSQL UTF8String]];
	}
	[arr removeAllObjects];
	[widgetSql close_database];

}

- (NSMutableDictionary*)wgtParameters:(NSString*)inFileName{
	//获得了当地的xml配置文件信息，得到字典
	
	NSMutableDictionary *xmlDict =nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:inFileName]) {
		NSData *configData = [NSData dataWithContentsOfFile:inFileName];
		AllConfigParser *configParser=[[AllConfigParser alloc]init];
        BOOL isEncrypt = [FileEncrypt isDataEncrypted:configData];
        if (isEncrypt) {
            NSURL *url = nil;
            if ([inFileName hasSuffix:@"file://"]) {
                url = [BUtility stringToUrl:inFileName];;
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", inFileName]];
            }
            
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *data = [encryptObj decryptWithPath:url appendData:nil];
            configData = [data dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        
		NSMutableDictionary *tmpDict =[configParser initwithReqData:configData];
		xmlDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		//
		[tmpDict removeAllObjects];
	}
    
    
    NSString *showActiveStr = [xmlDict objectForKey:CONFIG_TAG_WEBAPP];
    webappShowAactivety = nil;
	if ([showActiveStr isEqualToString:@"true"]) {
		webappShowAactivety = @"yes";
	}else{webappShowAactivety = @"no";}
    
	return xmlDict;
}


- (NSMutableDictionary*)wgtUpdate:(WWidget*)inWgt{
	if (inWgt!=nil&&inWgt.appId!=nil && inWgt.ver!=nil && inWgt.updateUrl!=nil) {
		NSString *urlStr = inWgt.updateUrl;
		NSString *requestUrl = nil;
		if ([urlStr rangeOfString:@"?"].location!=NSNotFound) {
			requestUrl = [NSString stringWithFormat:@"%@&appId=%@&ver=%@&platform=%d",urlStr,inWgt.appId,inWgt.ver,0];
		}else {
			requestUrl = [NSString stringWithFormat:@"%@?appId=%@&ver=%@&platform=%d",urlStr,inWgt.appId,inWgt.ver,0];
		}
		ACENSLog(@"requestUrl=%@",requestUrl);
		wgtUpParser =[[UpdateParser alloc]init];
		
		NSMutableDictionary *updateDict =[NSMutableDictionary  dictionaryWithCapacity:1];	
		updateDict =[wgtUpParser initwithReqData:requestUrl];
		return updateDict;
	}
	return nil;
}
- (void)initLoginAndMoreWidget{
	WWidget *loginWgt = [[WWidget alloc] init];
	loginWgt.indexUrl = F_WIDGET_LOGIN_URL;
	loginWgt.appId = @"9999998";
	loginWgt.widgetPath=[BUtility getDocumentsPath:[NSString stringWithFormat:@"apps/%@/%@",self.mainWidget.appId,loginWgt.appId]];
	if (!wgtDict) {
		wgtDict = [NSMutableDictionary dictionary];
	}
	[wgtDict setObject:loginWgt forKey:loginWgt.appId];	

	WWidget *moreWgt = [[WWidget alloc] init];
	moreWgt.indexUrl =F_WIDGET_MOREWIDGET_URL;
	moreWgt.appId = @"9999997";
	moreWgt.widgetPath=[BUtility getDocumentsPath:[NSString stringWithFormat:@"apps/%@/%@",self.mainWidget.appId,moreWgt.appId]];
	[wgtDict setObject:moreWgt forKey:moreWgt.appId];

	
}
#pragma mark commonWidget

- (WWidget *)wgtDataByAppId:(NSString*)inAppId{
    
    NSString *tmpAppId = [NSString stringWithString:inAppId];
    //查询缓存
    WWidget *wgtObj =[wgtDict objectForKey:tmpAppId];
    
    //解析config.xml
    
    NSString *configPath = @"";
    NSString *newVersion = @"";
    BOOL isNewVersion = NO;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:tmpAppId]) {
        
        newVersion = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:tmpAppId]];
                      
        configPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@/%@/%@", F_NAME_WIDGETS, tmpAppId, newVersion, F_NAME_CONFIG]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
            
            isNewVersion = YES;
            
        } else {
            
            configPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@/%@",F_NAME_WIDGETS,tmpAppId,F_NAME_CONFIG]];
            
        }
    } else {
        
        configPath =[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@/%@",F_NAME_WIDGETS,tmpAppId,F_NAME_CONFIG]];
        
    }
    //热修复路径
    
    NSString *mVer = newVersion;
    
    //比对缓存的子应用信息与新的子应用信息的version，若相同，则直接用缓存；不相同，则更新信息
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
            
            [tempArr removeAllObjects];
            return wgtObj;
        }
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
        
        NSMutableDictionary *tmpWgtDict = [self wgtParameters:configPath];
        NSString *tmpWgtOneId = [BUtility appKey];
        NSString *wgtPath=[NSString stringWithFormat:@"%@/%@",F_NAME_WIDGETS,tmpAppId];
        if (isNewVersion) {
            wgtPath = [wgtPath stringByAppendingPathComponent:newVersion];
        }
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
    
    [tempArr removeAllObjects];
    return wgtObj;
}
//plugin widget
- (WWidget *)wgtPluginDataByAppId:(NSString*)inWgtId curWgt:(WWidget*)inCurWgt{
	
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
			[tmpWgtDict setObject:tmpWgtOneId forKey:CONFIG_TAG_WIDGETONEID];
		}
		[tmpWgtDict setObject:wgtPath forKey:CONFIG_TAG_WIDGETPATH];
		[tmpWgtDict setObject:[NSNumber numberWithInt:F_WWIDGET_PLUGINWIDGET] forKey:CONFIG_TAG_WIDGETTYPE];
		WWidget * tmpWgtObj = [self dictToWgt:tmpWgtDict];
		
		if (![BUtility isSimulator]) {
            if (![tmpWgtObj.indexUrl hasPrefix:F_HTTP_PATH] && ![tmpWgtObj.indexUrl hasPrefix:F_HTTPS_PATH]) {
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

//公众号样式的窗口的参数从前端传入
- (WWidget *)wgtOptionsDataByAppId:(NSString*)inWgtId curWgt:(WWidget*)inCurWgt infoDic:(NSDictionary *)infoDic{
    
    NSMutableDictionary *tmpDict =[NSMutableDictionary dictionaryWithDictionary:infoDic];
    WWidget * tmpWgtObj = [self dictToMPWgt:tmpDict];
    
    if (![BUtility isSimulator]) {
        if (![tmpWgtObj.indexUrl hasPrefix:F_HTTP_PATH] && ![tmpWgtObj.indexUrl hasPrefix:F_HTTPS_PATH]) {
            tmpWgtObj.indexUrl =[NSString stringWithFormat:@"file://%@",tmpWgtObj.indexUrl];
        }
        if (tmpWgtObj.iconPath) {
            tmpWgtObj.iconPath = [NSString stringWithFormat:@"file://%@",tmpWgtObj.iconPath];
        }
    }
    
    tmpWgtObj.widgetPath = inCurWgt.widgetPath;
    
    return tmpWgtObj;
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
	[tmpArr removeAllObjects];
	return deleteWgt;
}
#pragma mark util
- (WWidget *)dictToWgt:(NSMutableDictionary*)inDict{
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
		tmpWgt.desc = desStr;
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
	return tmpWgt;
}

#pragma mark - 公众号WWidget赋值
//部分参数名称与原方法有出入，比如大小写、前缀
- (WWidget *)dictToMPWgt:(NSMutableDictionary*)inDict{
    
    NSMutableDictionary *tmpDict =[NSMutableDictionary dictionaryWithDictionary:inDict];
    WWidget *tmpWgt = [[WWidget alloc]init];
    
    //打开公众号时，前端传入的参数
    //appId
    NSString *tmpAppId = [tmpDict objectForKey:CONFIG_TAG_APPID];
    if (tmpAppId) {
        tmpWgt.appId =tmpAppId;
    }
    //appkey
    NSString *appkey = [tmpDict objectForKey:@"appkey"];
    if (appkey) {
        tmpWgt.appKey = appkey;
    }
    //widgetName
    NSString *widgetName = [tmpDict objectForKey:@"widgetName"];
    if (widgetName) {
        tmpWgt.widgetName = widgetName;
    }
    //17.description
    NSString *desStr = [tmpDict objectForKey:CONFIG_TAG_DESCRIPTION];
    if (desStr) {
        tmpWgt.desc = desStr;
    }
    
    //indexUrl 11
    NSString *indexStr = [tmpDict objectForKey:@"indexUrl"];
    if ([indexStr hasPrefix:F_HTTP_PATH] || [indexStr hasPrefix:F_HTTPS_PATH] ) {
        tmpWgt.indexUrl =indexStr;
    }else{
        if ([indexStr isEqualToString:@"#"]) {
            indexStr = @"index.html";
        }
        tmpWgt.indexUrl = [[self mainWidget].widgetPath stringByAppendingPathComponent:indexStr];
    }
    
    //errorPath
    NSString *errorPath =[tmpDict objectForKey:@"errorPath"];
    if (errorPath) {
        if ([errorPath hasPrefix:F_HTTP_PATH] || [errorPath hasPrefix:F_HTTPS_PATH] ) {
            tmpWgt.errorPath = errorPath;
        }else{
            if ([errorPath isEqualToString:@"#"]) {
                errorPath = @"index.html";
            }
            tmpWgt.errorPath = [[self mainWidget].widgetPath stringByAppendingPathComponent:errorPath];
        }
    }
    
    //加密 12
    NSString *obfuscationStr = [tmpDict objectForKey:CONFIG_TAG_OBFUSCATION];
    if([obfuscationStr isEqualToString:@"true"]){
        tmpWgt.obfuscation = F_WWIDGET_OBFUSCATION; //加密
    }else {
        tmpWgt.obfuscation = F_WWIDGET_NO_OBFUSCATION;
    }
    //isDebug
    NSString * isDebug = [tmpDict objectForKey:CONFIG_TAG_DEBUG];
    if (isDebug) {
        tmpWgt.isDebug = [isDebug boolValue];
    } else{
        tmpWgt.isDebug = NO;
    }
    //wgtType 13
    NSString *wgtTypeStr = [tmpDict objectForKey:CONFIG_TAG_WIDGETTYPE];
    if (wgtTypeStr) {
        tmpWgt.wgtType = [wgtTypeStr intValue];
    } else {
        tmpWgt.wgtType = 4;
    }
    
    
    
    
    
    /*
     * 下面这些参数公众号方法里暂时没有传入
     */
    //widgetOneId 1
    NSString *tmpWoId = [tmpDict objectForKey:CONFIG_TAG_WIDGETONEID];
    if (tmpWoId) {
        tmpWgt.widgetOneId = tmpWoId;
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
    
    [tmpDict removeAllObjects];
    return tmpWgt;
}

//create request folder
-(void)createReqFolder{
	NSFileManager *fManager = [NSFileManager defaultManager];
	if (self.mainWidget) {
		NSString *absMainPath = self.mainWidget.absWidgetPath;
		NSString *videoPath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_VIDEO];
		NSString *audioPath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_AUDIO];
		NSString *photoPath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_PHOTO];
		NSString *myspacePath = [NSString stringWithFormat:@"%@/%@",absMainPath,F_NAME_MYSPACE];
        if (![fManager fileExistsAtPath:absMainPath]) {
            [fManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
             [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:absMainPath]];
        }
		if(![fManager fileExistsAtPath:videoPath]){
			[fManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		if(![fManager fileExistsAtPath:audioPath]){
			[fManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		if(![fManager fileExistsAtPath:photoPath]){
			[fManager createDirectoryAtPath:photoPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		if(![fManager fileExistsAtPath:myspacePath]){
			[fManager createDirectoryAtPath:myspacePath withIntermediateDirectories:YES attributes:nil error:nil];
		}
		
	}
	NSString *wgtFolders = [BUtility getDocumentsPath:F_NAME_WIDGETS];
	if (![fManager fileExistsAtPath:wgtFolders]) {
		[fManager createDirectoryAtPath:wgtFolders withIntermediateDirectories:YES attributes:nil error:nil];
        [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:wgtFolders]];

	}

}
//init load
- (void) loadMainWidget {	
	[self initMainWidget];
	[self createReqFolder];
	if ([BUtility getAppCanDevMode]) {
		[self unZipNormal];
         [self createTmpFolder];
	}else {
		[self initLoginAndMoreWidget];
	}
}
#pragma mark develop_version
-(void)createTmpFolder{
	NSFileManager *fManager = [NSFileManager defaultManager];
	NSString *absPath = [BUtility getDocumentsPath:@"widgetone/widgetapp"];
	for (int i =1; i<21; i++) {
		NSString *tmpPath = [NSString stringWithFormat:@"%@/%d",absPath,i];
		if(![fManager fileExistsAtPath:tmpPath]){
			[fManager createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
	}
}

-(void)unZipNormal{
    ZipArchive *zipObj = [[ZipArchive alloc] init];
    NSString *sourceWgt = [BUtility getResPath:@"widget/hiAppcan.zip"];
    NSString *outPath =[BUtility getDocumentsPath:@"widgetone/widgetapp/hiAppcan"];
    NSString *configPath = [NSString stringWithFormat:@"%@/config.xml",outPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configPath] && [[NSFileManager defaultManager] fileExistsAtPath:sourceWgt]) {
        [zipObj UnzipOpenFile:sourceWgt];
        [zipObj UnzipFileTo:outPath overWrite:NO];
        [zipObj UnzipCloseFile];
    }
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
										  @"",wgtObj.appId,wgtObj.ver,wgtObj.channelCode,wgtObj.imei, wgtObj.widgetName,wgtObj.iconPath,wgtObj.widgetPath,wgtObj.indexUrl,wgtObj.obfuscation,F_WWIDGET_TMPWIDGET,wgtObj.logServerIp,wgtObj.updateUrl,wgtObj.showMySpace,wgtObj.desc,wgtObj.author,wgtObj.email,wgtObj.license,wgtObj.orientation];
				
				[insertStrSQL appendString:tmpInsert];
			}
		}
		[doSql insertSql:[insertStrSQL UTF8String]];
		[doSql close_database];

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
	[tmpArr removeAllObjects];
	return (int)wgtsNum;
}
- (WWidget *)wgtDataByID:(int)inIndex{
	if (inIndex<[wgtArr count]) {
		WWidget *wgtObj = [wgtArr objectAtIndex:inIndex];
		return wgtObj;
	}
	return nil;
}

#pragma mark - update
- (BOOL)isNeetUpdateWgt {
    
    if (!AppCanEngine.configuration.useUpdateWgtHtmlControl) {
        return NO;
    }
    if (![ACEConfigXML isWidgetConfigXMLAvailable]) {
        return YES;
    }
    NSString *originWidgetVersion = [ACEConfigXML ACEOriginConfigXML][@"version"];
    NSParameterAssert(originWidgetVersion != nil);
    NSString *documentWidgetVersion = [ACEConfigXML ACEWidgetConfigXML][@"version"] ?: @"";
    return [self version:originWidgetVersion isGreaterThan:documentWidgetVersion];
        
}

- (BOOL)version:(NSString *)version1 isGreaterThan:(NSString *)version2 {

    NSArray *versions1 = [version1 componentsSeparatedByString:@"."];
    NSArray *versions2 = [version2 componentsSeparatedByString:@"."];
    
    for (int i = 0; i < (versions1.count > versions2.count) ? versions1.count : versions2.count; i++) {
        
        if (versions1.count < i+1) return NO;
        if (versions2.count < i+1) return YES;
        
        int v1 = [versions1[i] intValue];
        int v2 = [versions2[i] intValue];
        if (v1 != v2) return v1 > v2;
    }
    
    return NO;
    
}


@end
