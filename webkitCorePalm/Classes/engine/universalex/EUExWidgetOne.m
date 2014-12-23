/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "EUExWidgetOne.h"
#import "BUtility.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "EBrowserView.h"
#import "EBrowserController.h"
#import "EBrowser.h"
#import "JSON.h"
#import "EUExBaseDefine.h"

@implementation EUExWidgetOne

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	if (buttonIndex == 0) {
		NSFileManager* fileMgr = [[NSFileManager alloc] init];
		NSError* err = nil;    
		
		//clear contents of NSTemporaryDirectory 
		NSString* tempDirectoryPath = NSTemporaryDirectory();
		ACENSLog(@"+++++Broad+++++: %@",tempDirectoryPath);
		NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];    
		NSString* fileName = nil;
		BOOL result;
		
		while ((fileName = [directoryEnumerator nextObject])) {
			NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
			ACENSLog(@"+++++Broad+++++: %@",filePath);
			result = [fileMgr removeItemAtPath:filePath error:&err];
			if (!result && err) {
				NSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
			}
		}    
		[fileMgr release];
		exit(0);
	}
}

-(id)initWithBrwView:(EBrowserView *) eInBrwView{	
	if (self = [super initWithBrwView:eInBrwView]) {
	}
	return self;
}

-(void)dealloc{
	ACENSLog(@"EUExWidgetOne retain count is %d",[self retainCount]);
	ACENSLog(@"EUExWidgetOne dealloc is %x", self);
	[super dealloc];
}

-(void)getId:(NSMutableArray *)inArguments {
    [self jsFailedWithOpId:0 errorCode:0 errorDes:@"widgetOne has been deprecated"];
	//NSString *wgtOneId =[self.meBrwView.meBrwCtrler.mwWgtMgr wgtOneID];
//	if (wgtOneId) {
//		[self jsSuccessWithName:F_CB_WIDGETONE_GET_ID opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:wgtOneId];
//	}else {
//		[self jsFailedWithOpId:0 errorCode:0 errorDes:@"widgetOne not register success"];
//	}
}

-(void)getVersion:(NSMutableArray *)inArguments {
    [self jsFailedWithOpId:0 errorCode:0 errorDes:@"widgetone version has been deprecated"];
//	NSString*version = [self.meBrwView.meBrwCtrler.mwWgtMgr WidgetOneVersion];
//	if (version!=nil) {
//		[self jsSuccessWithName:F_CB_WIDGETONE_GET_VERSION opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:version];
//	}else{
//		[self jsFailedWithOpId:0 errorCode:0 errorDes:@"no version"];
//	}
}

-(void)getPlatform:(NSMutableArray *)inArguments {
	[self jsSuccessWithName:F_CB_WIDGETONE_GET_PLATFORM opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:F_WIDGETONE_PLATFORM_IOS];
}

-(void)exit:(NSMutableArray *)inArguments {
    if (inArguments && [inArguments count]==1) {
        int flag =[[inArguments objectAtIndex:0] intValue];
        if (flag==0) {
            NSFileManager* fileMgr = [[NSFileManager alloc] init];
            NSError* err = nil;
            //clear contents of NSTemporaryDirectory
            NSString* tempDirectoryPath = NSTemporaryDirectory();
            ACENSLog(@"+++++Broad+++++: %@",tempDirectoryPath);
            NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
            NSString* fileName = nil;
            BOOL result;
            while ((fileName = [directoryEnumerator nextObject])) {
                NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
                ACENSLog(@"+++++Broad+++++: %@",filePath);
                result = [fileMgr removeItemAtPath:filePath error:&err];
                if (!result && err) {
                    NSLog(@"Failed to delete: %@ (error: %@)", filePath, err);
                }
            }    
            [fileMgr release];
            exit(0);
            return;
        }
    }
    NSString * title = NSLocalizedString(@"exitAlertTitle", nil);
    NSString * message = NSLocalizedString(@"exitAlertMessage", nil);
    NSString * exit = NSLocalizedString(@"exitAlertExitBtn", nil);
    NSString * cancel = NSLocalizedString(@"exitAlertCancelBtn", nil);
    
    UIAlertView *widgetOneConfirmView = [[UIAlertView alloc]
                                         initWithTitle:title
                                         message:message
                                         delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:exit,cancel,nil];
	[widgetOneConfirmView show];
	//
	[widgetOneConfirmView release];
}

-(void)getWidgetNumber:(NSMutableArray *)inArguments {
	ACENSLog(@"[EUExWidgetone getWidgetNumber]");
	int wgtNum = [self.meBrwView.meBrwCtrler.mwWgtMgr widgetNumber];
	[self jsSuccessWithName:F_CB_WIDGETONE_GET_WIDGET_NUM opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:wgtNum];	
}

-(void)getWidgetInfo:(NSMutableArray *)inArguments {
	ACENSLog(@"[EUExWidgetone getWidgetInfo]");
	NSString *inIndex = [inArguments objectAtIndex:0];
	int index = [inIndex intValue];
	ACENSLog(@"index=%d",index);
	WWidget *curWgt = [self.meBrwView.meBrwCtrler.mwWgtMgr wgtDataByID:index];
	if (curWgt) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:5];
		if (curWgt.appId) {
			[dict setObject:curWgt.appId forKey:F_JK_APP_ID];
		} 
		if (curWgt.widgetId) {
			[dict setObject:curWgt.widgetId forKey:F_JK_WIDGET_ID];
		}
		if (curWgt.widgetName) {
			[dict setObject:curWgt.widgetName forKey:F_JK_NAME];
		} 
		if (curWgt.iconPath) {
			[dict setObject:curWgt.iconPath forKey:F_JK_ICON];
		}
		if (curWgt.ver) {
			[dict setObject:curWgt.ver forKey:F_JK_VERSION];
		}
		NSString *info = [dict JSONFragment];
		//ACENSLog(@"info=%@",info);
		[self jsSuccessWithName:F_CB_WIDGETONE_GET_WIDGET_INFO opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:info];
		[dict release];
	}else {
		[self jsSuccessWithName:F_CB_WIDGETONE_GET_WIDGET_INFO opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
	}
}

-(void)getCurrentWidgetInfo:(NSMutableArray *)inArguments {
	WWidget *curWgt =self.meBrwView.mwWgt;
	if (curWgt) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:5];
		if (curWgt.appId) {
			[dict setObject:curWgt.appId forKey:F_JK_APP_ID];
		} 
		if (curWgt.widgetId) {
			[dict setObject:curWgt.widgetId forKey:F_JK_WIDGET_ID];
		}
		if (curWgt.widgetName) {
			[dict setObject:curWgt.widgetName forKey:F_JK_NAME];
		} 
		if (curWgt.iconPath) {
			[dict setObject:curWgt.iconPath forKey:F_JK_ICON];
		}
		if (curWgt.ver) {
			[dict setObject:curWgt.ver forKey:F_JK_VERSION];
		}
		NSString *info = [dict JSONFragment];
		//ACENSLog(@"info=%@",info);
		[self jsSuccessWithName:F_CB_WIDGETONE_GET_CURRENTWIDGET_INFO opId:0 dataType:UEX_CALLBACK_DATATYPE_JSON strData:info];
		[dict release];
	}else {
		[self jsSuccessWithName:F_CB_WIDGETONE_GET_CURRENTWIDGET_INFO opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CFAILED];
	}
}

-(void)cleanCache:(NSMutableArray *)inArguments {
	if (meBrwView.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
		NSURLCache *shareCache = [NSURLCache sharedURLCache];
		if (shareCache) {
			[shareCache removeAllCachedResponses];
		}
		[self jsSuccessWithName:F_CB_WIDGETONE_CLEAN_CACHE opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:0];
	} else {
		[self jsSuccessWithName:F_CB_WIDGETONE_CLEAN_CACHE opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:1];
	}
}

-(void)getMainWidgetId:(NSMutableArray *)inArguments {
	WWidget *widget = self.meBrwView.meBrwCtrler.mwWgtMgr.wMainWgt;
	if (widget) {
		NSString *appId =widget.appId; 
		[self jsSuccessWithName:F_CB_WIDGETONE_GET_MAINWIDGET_ID opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:appId];
	}else {
		[self jsSuccessWithName:F_CB_WIDGETONE_GET_MAINWIDGET_ID opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:[NSString stringWithFormat:@"%d",-1]];
	}

}
-(void)setBadgeNumber:(NSMutableArray*)inArguments{
    int number =[[inArguments objectAtIndex:0] intValue];
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:F_UD_BadgeNumber];
    [ud setObject:[NSNumber numberWithInt:number] forKey:F_UD_BadgeNumber];
    [ud synchronize];
}
@end
