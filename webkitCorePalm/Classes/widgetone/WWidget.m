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

#import "WWidget.h"
#import "BUtility.h"
#import "WidgetOneDelegate.h"
@implementation WWidget

@synthesize wId;
@synthesize widgetOneId;
@synthesize widgetId;
@synthesize appId;
@synthesize ver;
@synthesize channelCode;
@synthesize widgetName;
@synthesize imei;
@synthesize md5Code;
@synthesize iconPath;
@synthesize widgetPath;
@synthesize indexUrl;
@synthesize obfuscation;
@synthesize wgtType;
@synthesize logServerIp;
@synthesize updateUrl;
@synthesize showMySpace;
@synthesize author;
@synthesize description;
@synthesize email;
@synthesize license;
@synthesize orientation;
@synthesize openAdStatus;
@synthesize preload;
@synthesize appKey;
-(void)dealloc{
	[widgetOneId release];
	widgetOneId =nil;
	[widgetId release];
	widgetId = nil;
	[ver release];
	ver = nil;
	[appId release];
	appId = nil;
	[channelCode release];
	channelCode = nil;
	[imei release];
	imei = nil;
	[md5Code release];
	md5Code = nil;
	[widgetName release];
	widgetName = nil;
	[widgetPath release];
	widgetPath =nil;
	[iconPath release];
	iconPath = nil;
	[indexUrl release];
	indexUrl = nil;
	[logServerIp release];
	logServerIp = nil;
	[updateUrl release];
	updateUrl = nil;
	[email release];
	email = nil;
	[description release];
	description = nil;
	[author release];
	author = nil;
	[license release];
	license = nil;
	[super dealloc];
}
-(BOOL)getMySpaceStatus{
	if ((showMySpace & WIDGETREPORT_SPACESTATUS_OPEN)==WIDGETREPORT_SPACESTATUS_OPEN) {
		return YES;
	}
	return NO;

}
-(BOOL)getMoreWgtsStatus{
	if ((showMySpace & WIDGETREPORT_SPACESTATUS_EXTEN_OPEN)==WIDGETREPORT_SPACESTATUS_EXTEN_OPEN) {
		return YES;
	}
	return NO;
}

- (NSString *)absWidgetPath{
    NSString *absPath = [BUtility getDocumentsPath:@""];
    NSString *wgtPath = nil;
    if (self.wgtType==F_WWIDGET_MAINWIDGET) {
        wgtPath = [NSString stringWithFormat:@"%@/apps/%@",absPath,self.appId];
    } else {
        wgtPath = self.widgetPath;
        NSString *wgtPathString = self.indexUrl;
        NSRange range = [self.indexUrl rangeOfString:@"widget/plugin/"];
        if (range.location != NSNotFound) {
            wgtPath = [wgtPathString substringToIndex:range.location+range.length];
            NSRange range1 = [wgtPath rangeOfString:@"file://"];
            wgtPath = [wgtPath substringFromIndex:range1.location+range1.length];
            wgtPath = [wgtPath stringByAppendingString:self.appId];
        }
    }
    return wgtPath;
}

- (NSString *)absResourcePath{
    if (self.wgtType==F_WWIDGET_MAINWIDGET) {
        BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
        if (theApp.useUpdateWgtHtmlControl && isCopyFinish) {
            return  [BUtility getDocumentsPath:@"widget/wgtRes"];
        }else {
            return [BUtility getResPath:@"widget/wgtRes"];
        }
    }else {
        return [NSString stringWithFormat:@"%@/wgtRes",[self absWidgetPath]];
    }
}

@end
