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

#import "EUExAppCenter.h"
#import "EBrowserController.h"
#import "EBrowserMainFrame.h"
#import "BUtility.h"
#import "EUExBaseDefine.h"

@implementation EUExAppCenter

-(id)initWithBrwView:(EBrowserView *)eInBrwView{
	ACENSLog(@"enter appcenter");
	if (self=[super initWithBrwView:eInBrwView]) {
		appCenter = eInBrwView.meBrwCtrler.meBrwMainFrm.mAppCenter;
	}
	return self;
}

-(void)dealloc{
	ACENSLog(@"EUExAppCenter retain count is %d",[self retainCount]);
	ACENSLog(@"EUExAppCenter dealloc is %x", self);
	[super dealloc];
}

-(void)appCenterLoginResult:(NSMutableArray *)inArguments {
	NSString *uInfo = [inArguments objectAtIndex:0];
	if (uInfo==nil||[uInfo length]==0) {
		//登录失败
		[appCenter userLoginFail];
	}else {
		//登录成功
		[appCenter userLoginSuccess:uInfo];
	}
}

-(void)downloadApp:(NSMutableArray *)inArguments{
	NSString *retDldJson = [inArguments objectAtIndex:0];
	if (retDldJson) {
		[appCenter moreAppDownload:retDldJson];
	}
}

-(void)loginOut:(NSMutableArray *)inArguments{
	NSUserDefaults *dfts = [NSUserDefaults standardUserDefaults];
	[dfts removeObjectForKey:@"sessionKey"];
	[dfts removeObjectForKey:@"fromDomain"];
	[dfts removeObjectForKey:@"spuid"];
	[appCenter cleanUserInfo];
	[self jsSuccessWithName:@"uexAppCenter.cbLoginOut" opId:0 dataType:UEX_CALLBACK_DATATYPE_INT intData:UEX_CSUCCESS];
}

-(void)getSessionKey:(NSMutableArray *)inArguments{
	ACENSLog(@"getsessionkey enter");
	NSUserDefaults *dfts = [NSUserDefaults standardUserDefaults];
	NSString *skey = [dfts objectForKey:@"sessionKey"];
	if (dfts&&[skey length]>0) {
		[self jsSuccessWithName:@"uexAppCenter.cbGetSessionKey" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:skey];
	}else {
		[self jsSuccessWithName:@"uexAppCenter.cbGetSessionKey" opId:0 dataType:UEX_CALLBACK_DATATYPE_TEXT strData:NULL];
	}
}
@end
