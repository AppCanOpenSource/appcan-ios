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

#import "EUExWidgetOne.h"
#import "BUtility.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "EBrowserView.h"
#import "EBrowserController.h"
#import "EBrowser.h"
#import "JSON.h"


#define UEX_EXITAPP_ALERT_TITLE @"退出提示"
#define UEX_EXITAPP_ALERT_MESSAGE @"确定要退出程序吗"
#define UEX_EXITAPP_ALERT_EXIT @"确定"
#define UEX_EXITAPP_ALERT_CANCLE @"取消"
@interface EUExWidgetOne()
@property (nonatomic,readonly)EBrowserView *EBrwView;
@end


@implementation EUExWidgetOne

- (EBrowserView *)EBrwView{
    id brwView = [self webViewEngine];
    BOOL isEBrowserView = [brwView isKindOfClass:[EBrowserView class]];
    NSAssert(isEBrowserView,@"uexWidgetOne only use for EBrowserView *");
    return isEBrowserView ? brwView : nil;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	if (buttonIndex == 0) {
		NSFileManager* fileMgr = [[NSFileManager alloc] init];
		    
		
		//clear contents of NSTemporaryDirectory 
		NSString *tempDirectoryPath = NSTemporaryDirectory();
		NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];    
		NSString *fileName = nil;
		
		while ((fileName = [directoryEnumerator nextObject])) {
            NSError* err = nil;
			NSString* filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
			BOOL result = [fileMgr removeItemAtPath:filePath error:&err];
			if (!result || err) {
				ACLogWarning(@"Failed to delete: %@ (error: %@)", filePath, err);
			}
		}
		exit(0);
	}
}
- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (self = [super initWithWebViewEngine:engine]) {
        
    }
    return self;
}


- (void)dealloc{

}

- (void)getId:(NSMutableArray *)inArguments {
    ACLogInfo(@"uexWidgetOne.getId has been deprecated");
    //[self jsFailedWithOpId:0 errorCode:0 errorDes:@"widgetOne has been deprecated"];
	//NSString *wgtOneId =[self.meBrwView.meBrwCtrler.mwWgtMgr wgtOneID];
//	if (wgtOneId) {
//		[self jsSuccessWithName:F_CB_WIDGETONE_GET_ID opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:wgtOneId];
//	}else {
//		[self jsFailedWithOpId:0 errorCode:0 errorDes:@"widgetOne not register success"];
//	}
}

- (void)getVersion:(NSMutableArray *)inArguments {
    ACLogInfo(@"uexWidgetOne.getVersion has been deprecated");

}

- (NSNumber *)getPlatform:(NSMutableArray *)inArguments {
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetPlatform" arguments:ACArgsPack(@0,@2,@0)];
    return @0;
}

- (void)exit:(NSMutableArray *)inArguments {
    ACArgsUnpack(NSNumber *inFlag) = inArguments;
    if (inFlag) {
        NSInteger flag = inFlag.integerValue;
        if (flag == 0) {
            NSFileManager* fileMgr = [NSFileManager defaultManager];
           
            //clear contents of NSTemporaryDirectory
            NSString* tempDirectoryPath = NSTemporaryDirectory();
            NSDirectoryEnumerator* directoryEnumerator = [fileMgr enumeratorAtPath:tempDirectoryPath];
            NSString* fileName = nil;
            BOOL result;
            while ((fileName = [directoryEnumerator nextObject])) {
                NSError *err = nil;
                NSString *filePath = [tempDirectoryPath stringByAppendingPathComponent:fileName];
                result = [fileMgr removeItemAtPath:filePath error:&err];
                if (!result || err) {
                    ACLogWarning(@"Failed to delete: %@ (error: %@)", filePath, err);
                }
            }
            exit(0);
            return;
        }
    }
    NSString * title = ACELocalized(UEX_EXITAPP_ALERT_TITLE);
    NSString * message = ACELocalized(UEX_EXITAPP_ALERT_MESSAGE);
    NSString * exit = ACELocalized(UEX_EXITAPP_ALERT_EXIT);
    NSString * cancel = ACELocalized(UEX_EXITAPP_ALERT_CANCLE);
    
    UIAlertView *widgetOneConfirmView = [[UIAlertView alloc]
                                         initWithTitle:title
                                         message:message
                                         delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:exit,cancel,nil];
	[widgetOneConfirmView show];

}

- (void)getWidgetNumber:(NSMutableArray *)inArguments {

	int wgtNum = [self.EBrwView.meBrwCtrler.mwWgtMgr widgetNumber];
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetWidgetNumber" arguments:ACArgsPack(@0,@2,@(wgtNum))];
	
}

- (void)getWidgetInfo:(NSMutableArray *)inArguments {

    ACArgsUnpack(NSNumber *inIndex) = inArguments;
    int index =inIndex.intValue;

	WWidget *curWgt = [self.EBrwView.meBrwCtrler.mwWgtMgr wgtDataByID:index];
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

        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetWidgetInfo" arguments:ACArgsPack(@0,@1,dict.ac_JSONFragment)];
	}else {
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetWidgetInfo" arguments:ACArgsPack(@0,@2,@1)];
	}
}

- (NSDictionary *)getCurrentWidgetInfo:(NSMutableArray *)inArguments {
	WWidget *curWgt =self.EBrwView.mwWgt;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	if (curWgt) {
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
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetCurrentWidgetInfo" arguments:ACArgsPack(@0,@1,dict.ac_JSONFragment)];
	}else {
        [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetCurrentWidgetInfo" arguments:ACArgsPack(@0,@2,@1)];
	}
    return dict.count > 0 ? dict : nil;
}

- (void)cleanCache:(NSMutableArray *)inArguments {
    NSNumber *result = @1;
	if (self.EBrwView.mwWgt.wgtType == F_WWIDGET_MAINWIDGET) {

		[[NSURLCache sharedURLCache] removeAllCachedResponses];
        result = @0;
	}
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbCleanCache" arguments:ACArgsPack(@0,@2,result)];
}

- (NSString *)getMainWidgetId:(NSMutableArray *)inArguments {
    
    NSString *appId = nil;
	WWidget *widget = self.EBrwView.meBrwCtrler.mwWgtMgr.mainWidget;
	if (widget) {
		appId = widget.appId;
	}
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbGetMainWidgetId" arguments:ACArgsPack(@0,@0,appId ?: @"-1")];
    return appId;

}
- (void)setBadgeNumber:(NSMutableArray*)inArguments{
    ACArgsUnpack(NSNumber *inNumber) = inArguments;
    NSUserDefaults *ud =[NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:F_UD_BadgeNumber];
    [ud setObject:inNumber forKey:F_UD_BadgeNumber];
    [ud synchronize];
}

- (NSNumber *)getEngineVersionCode:(NSMutableArray*)inArguments{
    return @(ACEngineVersionCode());
}

- (NSString *)getEngineVersion:(NSMutableArray*)inArguments{
    return ACEnginVersion();
}

@end
