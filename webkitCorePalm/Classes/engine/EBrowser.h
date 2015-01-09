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

@class EBrowserController;
@class WWidget;
@class EBrowserView;

#define F_ACT_REQ_CODE_UEX_CAMERA						0
#define F_ACT_REQ_CODE_UEX_SCANNER						1
#define F_ACT_REQ_CODE_UEX_CONTACT						2
#define F_ACT_REQ_CODE_UEX_FILE_EXPLORER				3
#define F_ACT_REQ_CODE_UEX_AUDIO_RECORD					4
#define F_ACT_REQ_CODE_UEX_VIDEO_RECORD					5
#define F_ACT_REQ_CODE_DIALOG_BRW_EXIT					6
#define F_ACT_REQ_CODE_DIALOG_SEND_TO_FRIEND			7
#define F_ACT_REQ_CODE_UEX_LOCATION						8
#define F_ACT_REQ_CODE_UEX_GETADDRESS					9
#define F_ACT_REQ_CODE_UEX_SENSOR						10
#define F_ACT_REQ_CODE_UEX_ORIENTATION					11
//window
#define F_ACT_REQ_CODE_UEX_CONFIRM						12
#define F_ACT_REQ_CODE_UEX_POPMT						13
#define F_ACT_REQ_CODE_UEX_ALERT						14
//jabber
#define F_ACT_REQ_CODE_UEX_JABBER_LOGIN					15
#define F_ACT_REQ_CODE_UEX_JABBER_SENDDATA				16
#define F_ACT_REQ_CODE_UEX_JABBER_RECEIVEFILE			17
#define F_ACT_REQ_CODE_UEX_JABBER_SENDFILE				18
#define F_ACT_REQ_CODE_UEX_JABBER_REFACCEPTFILE			19
#define F_ACT_REQ_CODE_UEX_JABBER_LOGOUT				20
#define F_ACT_REQ_CODE_UEX_JABBER_RECEIVEDATA			21
//socket	
#define F_ACT_REQ_CODE_UEX_SOCKET_CREATEUDPSOCKET		22
#define F_ACT_REQ_CODE_UEX_SOCKET_CREATETCPSOCKET		23
#define F_ACT_REQ_CODE_UEX_SOCKET_SETINETADDRESSANDPORT	24
#define F_ACT_REQ_CODE_UEX_SOCKET_SENDATA				25
#define F_ACT_REQ_CODE_UEX_SOCKET_CLOSESOCKET			26
#define F_ACT_REQ_CODE_UEX_SOCKET_SETIMEOUT				34
//xmlHTTPMGR
#define F_ACT_REQ_CODE_UEX_XMLHTTPMGR					27
#define F_ACT_REQ_CODE_UEX_PAY							28
//download Percentage
#define F_ACT_REQ_CODE_UEX_DLPERCENTAGE					29
#define F_ACT_REQ_CODE_UEX_DOWNLOAD						30
//updateLoad
#define F_ACT_REQ_CODE_UEX_UPLOADPERCENTAGE				31
#define F_ACT_REQ_CODE_UEX_UPLOADERMGR					32
//Widgetone
#define F_ACT_REQ_CODE_UEX_UPDATEWIDGETMSG				33

#define F_EBRW_FLAG_WINDOW_IN_OPENING					0x1
#define F_EBRW_FLAG_WIDGET_IN_OPENING					0x2

#define F_INTENT_DATA_KEY_CALLBACK_REQ_CODE		@"requestCode"
#define F_INTENT_DATA_KEY_CALLBACK_RET_CODE		@"resultCode"
#define F_INTENT_DATA_KEY_CALLBACK_SUCCESS		@"successCallback"
#define F_INTENT_DATA_KEY_CALLBACK_FAILED		@"successFailed"
#define F_INTENT_DATA_KEY_CALLBACK_PERCENT		@"percentage"
#define F_INTENT_DATA_KEY_PHONE_NUM				@"phoneNumber"
#define F_INTENT_DATA_KEY_CLEAR_CACHE			@"clearCache"
#define F_INTENT_DATA_KEY_CLEAR_HIS				@"clearHistroy"
#define F_INTENT_DATA_KEY_AUDIOMGR_AUDIO_LIST	@"audioList"
#define F_INTENT_DATA_KEY_FILE_EXPLORER_NAME	@"fileExplorerName"

#define F_INTENT_DATA_VALUE_RET_CODE_SUCCESS	0
#define F_INTENT_DATA_VALUE_RET_CODE_FAILED		1

@interface EBrowser : NSObject{
	EBrowserController *meBrwCtrler;
	int mFlag;
}
@property (nonatomic, assign) EBrowserController *meBrwCtrler;
@property int mFlag;

- (void)start:(WWidget*)inWWgt;
- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView;
- (void)stopAllNetService;
- (void)removeAllNotActiveViews;
//- (void)processCallbackResult:(NSMutableDictionary*)inArgsDict;
@end


