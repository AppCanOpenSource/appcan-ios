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

#import "BUtility.h"
#import "FBEncryptorAES.h"
//#import "RegexKitLite.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <netdb.h>

#import <SystemConfiguration/SystemConfiguration.h>
#import "WWidget.h"
//#import "AppCanBase.h"
#import "EBrowserView.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWindow.h"
#import "EBrowserController.h"
#import "WWidgetMgr.h"
#import "WidgetOneDelegate.h"
#import "EBrowserMainFrame.h"


//mac begin
#include <sys/socket.h> // Per msqr 
#include <sys/sysctl.h> 
#include <net/if.h> 
#include <net/if_dl.h> 
//icloud
#import <sys/xattr.h>
#import <objc/runtime.h> 
#import <objc/message.h>
//mac end
#import "AllConfigParser.h"
#import "OpenUDID.h"

#import "FileEncrypt.h"
#import <CommonCrypto/CommonDigest.h>
#import <AppCanKit/ACInvoker.h>
#import "DataAnalysisInfo.h"


void rc4_setup( struct rc4_state *s, unsigned char *key, int length ) 
{ 
    int i, j, k, *m, a;
    s->x = 0; 
    s->y = 0; 
    m = s->m;
    for( i = 0; i < 256; i++ ) 
    { 
        m[i] = i; 
    }
    j = k = 0;
    for( i = 0; i < 256; i++ ) 
    { 
        a = m[i]; 
        j = (unsigned char) ( j + a + key[k] ); 
        m[i] = m[j]; m[j] = a; 
        if( ++k >= length ) k = 0; 
    } 
}

void rc4_crypt( struct rc4_state *s, unsigned char *data, int length ) 
{ 
    int i, x, y, *m, a, b;
    x = s->x; 
    y = s->y; 
    m = s->m;
    for( i = 0; i < length; i++ ) 
    { 
        x = (unsigned char) ( x + 1 ); a = m[x]; 
        y = (unsigned char) ( y + a ); 
        m[x] = b = m[y]; 
        m[y] = a; 
        data[i] ^= m[(unsigned char) ( a + b )]; 
    }
    s->x = x; 
    s->y = y; 
}
void printHEX(unsigned char* buf,int len)
{
	int p = 0 ;
	for(p=0;p<len;p+=16)
	{
		//char bb[1024]={0};
		int l = (len-p)>16?16:(len-p);
		for(int j = 0; j<l ; j++)
		{
			printf("%02x,%d",*(buf+p+j),1);
		}
		
	}
    
}


void ACENSLog (NSString *format, ...) {
#ifdef OUTPUT_LOG_CONTROL
	va_list args;
	va_start(args,format);
	va_end(args);
	NSString *aceFormat = @"~~~~~ACELog~~~~~: ";
	aceFormat = [aceFormat stringByAppendingString:format];
	NSLogv(aceFormat, args);
#endif
}



@implementation BUtility
#pragma BaseJSKey
/*
static NSString *baseJSKey = @"var uex_s_uex='&';"
"function uexJoin(a){ var l = a.length; var t = ''; if (l > 0) { t += '?'; for(var i=0;i<l;i++){ t += encodeURIComponent(a[i]); if (i+1 == l) { return t; } t += uex_s_uex; } } return t;}"
"window.uex={ queue:{commands:[],timer:null } };"
"uex.exec=function(){ uex.queue.commands.push(arguments); if(uex.queue.timer==null){ uex.queue.timer = setInterval(uex.runCommand,10); } };"
"uex.runCommand=function(){ var arguments = uex.queue.commands[0]; if(uex.queue.commands.length==0){ clearInterval(uex.queue.timer); uex.queue.timer = null; } document.location = 'uex://'+arguments[0];};"

"window.uexWidgetOne={}; uexWidgetOne.cbError = null; uexWidgetOne.cbGetId = null; uexWidgetOne.cbGetVersion = null; uexWidgetOne.cbGetPlatform = null; uexWidgetOne.cbGetWidgetNumber = null; uexWidgetOne.cbGetWidgetInfo = null; uexWidgetOne.cbGetCurrentWidgetInfo = null; uexWidgetOne.cbCleanCache = null; uexWidgetOne.cbGetMainWidgetId = null; uexWidgetOne.platformName = 'iOS'; uexWidgetOne.platformVersion = null;uexWidgetOne.iOS7Style = null;uexWidgetOne.isFullScreen = null;"
"uexWidgetOne.getId=function(){ uex.exec('uexWidgetOne.getId/'); };"
"uexWidgetOne.getVersion=function(){ uex.exec('uexWidgetOne.getVersion/'); };"
"uexWidgetOne.getPlatform=function(){ uex.exec('uexWidgetOne.getPlatform/'); return 0; };"
"uexWidgetOne.exit=function(){ uex.exec('uexWidgetOne.exit/'+uexJoin(arguments));};"
"uexWidgetOne.cleanCache=function(){ uex.exec('uexWidgetOne.cleanCache/');};"
"uexWidgetOne.getWidgetNumber=function(){ uex.exec('uexWidgetOne.getWidgetNumber/');};"
"uexWidgetOne.getWidgetInfo=function(){ uex.exec('uexWidgetOne.getWidgetInfo/'+uexJoin(arguments));};"
"uexWidgetOne.getCurrentWidgetInfo=function(){ uex.exec('uexWidgetOne.getCurrentWidgetInfo/');};"
"uexWidgetOne.getMainWidgetId=function(){ uex.exec('uexWidgetOne.getMainWidgetId/');};"
"uexWidgetOne.setBadgeNumber=function(){ uex.exec('uexWidgetOne.setBadgeNumber/'+uexJoin(arguments));};"
"window.uexWidget={};uexWidget.cbStartWidget = null;uexWidget.cbRemoveWidget = null;uexWidget.cbGetOpennerInfo = null;uexWidget.cbCheckUpdate = null;uexWidget.cbGetPushInfo = null;uexWidget.onSuspend = null;uexWidget.onResume = null;uexWidget.onTerminate = null;uexWidget.onKeyPressed = null;"
"uexWidget.reloadWidgetByAppId=function(){ uex.exec('uexWidget.reloadWidgetByAppId/'+uexJoin(arguments));};"
"uexWidget.startWidget=function(){ uex.exec('uexWidget.startWidget/'+uexJoin(arguments));};"
"uexWidget.finishWidget=function(){ uex.exec('uexWidget.finishWidget/'+uexJoin(arguments));};"
"uexWidget.removeWidget=function(){ uex.exec('uexWidget.removeWidget/'+uexJoin(arguments));};"
"uexWidget.getOpenerInfo=function(){ uex.exec('uexWidget.getOpenerInfo/');};"
"uexWidget.loadApp=function(){ uex.exec('uexWidget.loadApp/'+uexJoin(arguments));};"
"uexWidget.checkUpdate=function(){ uex.exec('uexWidget.checkUpdate/');};"
"uexWidget.checkMAMUpdate=function(){ uex.exec('uexWidget.checkMAMUpdate/');};"
"uexWidget.setPushNotifyCallback=function(){ uex.exec('uexWidget.setPushNotifyCallback/'+uexJoin(arguments));};"
"uexWidget.getPushInfo = function(){ uex.exec('uexWidget.getPushInfo/'+uexJoin(arguments));};"
"uexWidget.setPushInfo = function(){ uex.exec('uexWidget.setPushInfo/'+uexJoin(arguments));};"
"uexWidget.delPushInfo = function(){ uex.exec('uexWidget.delPushInfo/'+uexJoin(arguments));};"
"uexWidget.getPushState = function(){ uex.exec('uexWidget.getPushState/');};"
"uexWidget.setSpaceEnable = function(){ uex.exec('uexWidget.setSpaceEnable/');};"
"uexWidget.setPushState = function(){ uex.exec('uexWidget.setPushState/'+uexJoin(arguments));};"
"uexWidget.setLogServerIp = function(){ uex.exec('uexWidget.setLogServerIp/'+uexJoin(arguments));};"
//20150703 by lkl
"uexWidget.isAppInstalled = function(){ uex.exec('uexWidget.isAppInstalled/'+uexJoin(arguments));};"

"window.uexWindow={}; uexWindow.cbConfirm = null; uexWindow.cbPrompt = null; uexWindow.cbActionSheet = null; uexWindow.cbGetState = null; uexWindow.cbGetUrlQuery = null; uexWindow.onOAuthInfo = null; uexWindow.onStateChange = null; uexWindow.onBounceStateChange = null; uexWindow.didShowKeyboard = 0; uexWindow.onAnimationFinish = null;"
"uexWindow.forward=function(){ uex.exec('uexWindow.forward/');};"
"uexWindow.back=function(){ uex.exec('uexWindow.back/');};"
"uexWindow.setMultiPopoverFrame=function(){ uex.exec('uexWindow.setMultiPopoverFrame/'+uexJoin(arguments));};"
"uexWindow.evaluateMultiPopoverScript=function(){ uex.exec('uexWindow.evaluateMultiPopoverScript/'+uexJoin(arguments));};"
"uexWindow.pageForward=function(){ uex.exec('uexWindow.pageForward/');};"
"uexWindow.pageBack=function(){ uex.exec('uexWindow.pageBack/');	};"
"uexWindow.reload=function(){ uex.exec('uexWindow.reload/');	};"
"uexWindow.alert=function(){ uex.exec('uexWindow.alert/'+uexJoin(arguments));};"
"uexWindow.confirm=function(){ uex.exec('uexWindow.confirm/'+uexJoin(arguments));};"
"uexWindow.prompt=function(){ uex.exec('uexWindow.prompt/'+uexJoin(arguments));	};"
"uexWindow.actionSheet=function(){ uex.exec('uexWindow.actionSheet/'+uexJoin(arguments));};"
"uexWindow.open=function(){ uex.exec('uexWindow.open/'+uexJoin(arguments));	};"
"uexWindow.openPresentWindow=function(){ uex.exec('uexWindow.openPresentWindow/'+uexJoin(arguments));	};"
"uexWindow.setLoadingImagePath=function(){ uex.exec('uexWindow.setLoadingImagePath/'+uexJoin(arguments));	};"
"uexWindow.toggleSlidingWindow=function(){ uex.exec('uexWindow.toggleSlidingWindow/'+uexJoin(arguments));	};"
"uexWindow.setSlidingWindowEnabled=function(){ uex.exec('uexWindow.setSlidingWindowEnabled/'+uexJoin(arguments));	};"
"uexWindow.setSlidingWindow=function(){ uex.exec('uexWindow.setSlidingWindow/'+uexJoin(arguments));	};"
"uexWindow.closeByName=function(){ uex.exec('uexWindow.closeByName/'+uexJoin(arguments));};"
"uexWindow.closeAboveWndByName=function(){ uex.exec('uexWindow.closeAboveWndByName/'+uexJoin(arguments));};"
"uexWindow.close=function(){ uex.exec('uexWindow.close/'+uexJoin(arguments));};"
"uexWindow.openSlibing=function() { uex.exec('uexWindow.openSlibing/'+uexJoin(arguments));};"
"uexWindow.openMultiPopover=function() { uex.exec('uexWindow.openMultiPopover/'+uexJoin(arguments));};"
"uexWindow.closeMultiPopover=function(){ uex.exec('uexWindow.closeMultiPopover/'+uexJoin(arguments));};"
"uexWindow.setSelectedPopOverInMultiWindow=function(){ uex.exec('uexWindow.setSelectedPopOverInMultiWindow/'+uexJoin(arguments));};"
"uexWindow.setAutorotateEnable = function() { uex.exec('uexWindow.setAutorotateEnable/'+uexJoin(arguments));};"
"uexWindow.closeSlibing=function(){ uex.exec('uexWindow.closeSlibing/'+uexJoin(arguments));};"
"uexWindow.showSlibing=function(){ uex.exec('uexWindow.showSlibing/'+uexJoin(arguments));};"
"uexWindow.evaluateScript=function(){ uex.exec('uexWindow.evaluateScript/'+uexJoin(arguments));};"
"uexWindow.windowForward=function(){ uex.exec('uexWindow.windowForward/'+uexJoin(arguments));};"
"uexWindow.windowBack=function(){ uex.exec('uexWindow.windowBack/'+uexJoin(arguments));	};"
"uexWindow.loadObfuscationData=function(){ uex.exec('uexWindow.loadObfuscationData/'+uexJoin(arguments));};"
"uexWindow.toast=function(){ uex.exec('uexWindow.toast/'+uexJoin(arguments));};"
"uexWindow.closeToast=function(){ uex.exec('uexWindow.closeToast/');	};"
"uexWindow.setReportKey=function(){uex.exec('uexWindow.setReportKey/'+uexJoin(arguments));};"
"uexWindow.getState=function(){ uex.exec('uexWindow.getState/');	};"
"uexWindow.openPopover=function() { uex.exec('uexWindow.openPopover/'+uexJoin(arguments));};"
"uexWindow.closePopover=function(){ uex.exec('uexWindow.closePopover/'+uexJoin(arguments));};"
"uexWindow.setWindowHidden=function(){ uex.exec('uexWindow.setWindowHidden/'+uexJoin(arguments));	};"
"uexWindow.insertWindowAboveWindow=function(){ uex.exec('uexWindow.insertWindowAboveWindow/'+uexJoin(arguments));	};"
"uexWindow.insertWindowBelowWindow=function(){ uex.exec('uexWindow.insertWindowBelowWindow/'+uexJoin(arguments));	};"
"uexWindow.setOrientation=function(){ uex.exec('uexWindow.setOrientation/'+uexJoin(arguments));	};"
"uexWindow.setStatusBarTitleColor=function(){ uex.exec('uexWindow.setStatusBarTitleColor/'+uexJoin(arguments));	};"
"uexWindow.setWindowScrollbarVisible=function(){ uex.exec('uexWindow.setWindowScrollbarVisible/'+uexJoin(arguments));	};"
"uexWindow.setPopoverFrame=function(){ uex.exec('uexWindow.setPopoverFrame/'+uexJoin(arguments));	};"
"uexWindow.evaluatePopoverScript=function(){ uex.exec('uexWindow.evaluatePopoverScript/'+uexJoin(arguments));};"
"uexWindow.openAd=function(){ uex.exec('uexWindow.openAd/'+uexJoin(arguments));};"
"uexWindow.setBounce=function(){ uex.exec('uexWindow.setBounce/'+uexJoin(arguments));};"
"uexWindow.getBounce=function(){ uex.exec('uexWindow.getBounce/'+uexJoin(arguments));};"
"uexWindow.setBounceParams=function(){ uex.exec('uexWindow.setBounceParams/'+uexJoin(arguments));};"
"uexWindow.setRightSwipeEnable=function(){ uex.exec('uexWindow.setRightSwipeEnable/'+uexJoin(arguments));};"
"uexWindow.topBounceViewRefresh=function(){ uex.exec('uexWindow.topBounceViewRefresh/'+uexJoin(arguments));};"
"uexWindow.showBounceView=function(){ uex.exec('uexWindow.showBounceView/'+uexJoin(arguments));};"
"uexWindow.hiddenBounceView=function(){ uex.exec('uexWindow.hiddenBounceView/'+uexJoin(arguments));};"
"uexWindow.resetBounceView=function(){ uex.exec('uexWindow.resetBounceView/'+uexJoin(arguments));};"
"uexWindow.notifyBounceEvent = function(){ uex.exec('uexWindow.notifyBounceEvent/'+uexJoin(arguments));};"
"uexWindow.getUrlQuery = function(){ uex.exec('uexWindow.getUrlQuery/');	 return null;};"
"uexWindow.statusBarNotification = function(){ uex.exec('uexWindow.statusBarNotification/'+uexJoin(arguments));};"
"uexWindow.preOpenStart = function() { uex.exec('uexWindow.preOpenStart/'+uexJoin(arguments));};"
"uexWindow.preOpenFinish = function() { uex.exec('uexWindow.preOpenFinish/'+uexJoin(arguments));};"
"uexWindow.beginAnimition = function() { uex.exec('uexWindow.beginAnimition/'+uexJoin(arguments));};"
"uexWindow.setAnimitionDelay = function() { uex.exec('uexWindow.setAnimitionDelay/'+uexJoin(arguments));};"
"uexWindow.setAnimitionDuration = function() { uex.exec('uexWindow.setAnimitionDuration/'+uexJoin(arguments));};"
"uexWindow.setAnimitionCurve = function() { uex.exec('uexWindow.setAnimitionCurve/'+uexJoin(arguments));};"
"uexWindow.createPluginViewContainer = function() { uex.exec('uexWindow.createPluginViewContainer/'+uexJoin(arguments));};"
"uexWindow.closePluginViewContainer = function() { uex.exec('uexWindow.closePluginViewContainer/'+uexJoin(arguments));};"
"uexWindow.setPageInContainer = function() { uex.exec('uexWindow.setPageInContainer/'+uexJoin(arguments));};"
"uexWindow.setAnimitionRepeatCount = function() { uex.exec('uexWindow.setAnimitionRepeatCount/'+uexJoin(arguments));};"
"uexWindow.setAnimitionAutoReverse = function() { uex.exec('uexWindow.setAnimitionAutoReverse/'+uexJoin(arguments));};"
"uexWindow.makeAlpha = function() { uex.exec('uexWindow.makeAlpha/'+uexJoin(arguments));};"
"uexWindow.makeTranslation = function() { uex.exec('uexWindow.makeTranslation/'+uexJoin(arguments));};"
"uexWindow.makeScale = function() { uex.exec('uexWindow.makeScale/'+uexJoin(arguments));};"
"uexWindow.makeRotate = function() { uex.exec('uexWindow.makeRotate/'+uexJoin(arguments));};"
"uexWindow.commitAnimition = function() { uex.exec('uexWindow.commitAnimition/'+uexJoin(arguments));};"
"uexWindow.insertPopoverAbovePopover = function() { uex.exec('uexWindow.insertPopoverAbovePopover/'+uexJoin(arguments));};"
"uexWindow.insertPopoverBelowPopover = function() { uex.exec('uexWindow.insertPopoverBelowPopover/'+uexJoin(arguments));};"
"uexWindow.bringPopoverToFront = function() { uex.exec('uexWindow.bringPopoverToFront/'+uexJoin(arguments));};"
"uexWindow.sendPopoverToBack = function() { uex.exec('uexWindow.sendPopoverToBack/'+uexJoin(arguments));};"
"uexWindow.insertAbove = function() { uex.exec('uexWindow.insertAbove/'+uexJoin(arguments));};"
"uexWindow.insertBelow = function() { uex.exec('uexWindow.insertBelow/'+uexJoin(arguments));};"
"uexWindow.bringToFront = function() { uex.exec('uexWindow.bringToFront/'+uexJoin(arguments));};"
"uexWindow.sendToBack = function() { uex.exec('uexWindow.sendToBack/'+uexJoin(arguments));};"
"uexWindow.setWindowFrame = function() { uex.exec('uexWindow.setWindowFrame/'+uexJoin(arguments));};"
"uexWindow.hideStatusBar = function() { uex.exec('uexWindow.hideStatusBar/'+uexJoin(arguments));};"
"uexWindow.showStatusBar = function() { uex.exec('uexWindow.showStatusBar/'+uexJoin(arguments));};"

"uexWindow.setMultilPopoverFlippingEnbaled = function() { uex.exec('uexWindow.setMultilPopoverFlippingEnbaled/'+uexJoin(arguments));};"
"uexWindow.getSlidingWindowState = function() { uex.exec('uexWindow.getSlidingWindowState/'+uexJoin(arguments));};"

//
"uexWindow.postGlobalNotification=function(){ uex.exec('uexWindow.postGlobalNotification/'+uexJoin(arguments));};"
"uexWindow.onGlobalNotification=null;"
"uexWindow.subscribeChannelNotification=function(){ uex.exec('uexWindow.subscribeChannelNotification/'+uexJoin(arguments));};"
"uexWindow.publishChannelNotification=function(){ uex.exec('uexWindow.publishChannelNotification/'+uexJoin(arguments));};"
"uexWindow.publishChannelNotificationForJson=function(){ uex.exec('uexWindow.publishChannelNotificationForJson/'+uexJoin(arguments));};"
//

//2015-10-21 by lkl
"uexWindow.disturbLongPressGesture = function() { uex.exec('uexWindow.disturbLongPressGesture/'+uexJoin(arguments));};"
//2015-11-06 by lkl
"uexWindow.setSwipeCloseEnable = function() { uex.exec('uexWindow.setSwipeCloseEnable/'+uexJoin(arguments));};"
"uexWindow.setWebViewScrollable = function() { uex.exec('uexWindow.setWebViewScrollable/'+uexJoin(arguments));};"
"uexWindow.createProgressDialog = function() { uex.exec('uexWindow.createProgressDialog/'+uexJoin(arguments));};"
"uexWindow.destroyProgressDialog = function() { uex.exec('uexWindow.destroyProgressDialog/'+uexJoin(arguments));};"


"uexWindow.log = function() { uex.exec('uexWindow.log/'+uexJoin(arguments));};"


//2016-2-1 share by lkl
"uexWindow.share = function() { uex.exec('uexWindow.share/'+uexJoin(arguments));};"


"window.uexAppCenter = {}; uexAppCenter.cbGetSessionKey = null; uexAppCenter.cbLoginOut = null;"
"uexAppCenter.appCenterLoginResult = function(){ uex.exec('uexAppCenter.appCenterLoginResult/'+uexJoin(arguments));};"
"uexAppCenter.downloadApp = function(){ uex.exec('uexAppCenter.downloadApp/'+uexJoin(arguments));};"
"uexAppCenter.loginOut = function(){ uex.exec('uexAppCenter.loginOut/');};"
"uexAppCenter.getSessionKey = function(){ uex.exec('uexAppCenter.getSessionKey/');};"

"window.uexConsole = {};"
"uexConsole.log = function(){uex.exec('uexConsole.log/'+uexJoin(arguments));};"
"window.uexPay = {};"
"uexPay.pay = function(){uex.exec('uexPay.pay/'+uexJoin(arguments));};"
"uexPay.setPayInfo = function(){uex.exec('uexPay.setPayInfo/'+uexJoin(arguments));};"
//"window.uexDataAnalysis = {};"
//"uexDataAnalysis.setEvent = function(){uex.exec('uexDataAnalysis.setEvent/'+uexJoin(arguments));};"
//"uexDataAnalysis.beginEvent = function(){uex.exec('uexDataAnalysis.beginEvent/'+uexJoin(arguments));};"
//"uexDataAnalysis.endEvent = function(){uex.exec('uexDataAnalysis.endEvent/'+uexJoin(arguments));};"
//"uexDataAnalysis.updateParams = function(){ uex.exec('uexDataAnalysis.updateParams/');};"
//"uexDataAnalysis.getAuthorizeID = function(){ uex.exec('uexDataAnalysis.getAuthorizeID/');};"
//"uexDataAnalysis.refreshGetAuthorizeID = function(){ uex.exec('uexDataAnalysis.refreshGetAuthorizeID/');};"
//"uexDataAnalysis.setErrorReport = function(){uex.exec('uexDataAnalysis.setErrorReport/'+uexJoin(arguments));};"
//"uexDataAnalysis.getDisablePlugins = function(){uex.exec('uexDataAnalysis.getDisablePlugins/'+uexJoin(arguments));};"
//"uexDataAnalysis.getDisableWindows = function(){uex.exec('uexDataAnalysis.getDisableWindows/'+uexJoin(arguments));};"
//"uexDataAnalysis.getUserInfo = function(){uex.exec('uexDataAnalysis.getUserInfo/'+uexJoin(arguments));};"
"window.uexGameEngine={};uexGameEngine.screenWidth =null;uexGameEngine.screenHeight =null";

+ (NSString *)getBaseJSKey{
    return baseJSKey;
}
*/

#pragma  mark - RC4EnryptLocalstorage
static NSString *rc4JSKey = @"uexSecure={ls:localStorage,open:function(p){try{this.t=true;this.o=uexCrypto.m(p)}catch(e){}},write:function(k,v){if(this.t){try{this.ls.setItem(this.o+k,uexCrypto.zy_rc4ex(v,this.o))}catch(e){}}},read:function(k){if(this.t){try{return uexCrypto.zy_rc4ex(this.ls.getItem(this.o+k),this.o)}catch(e){return null}}else{return null}},remove:function(k){if(this.t){try{this.ls.removeItem(this.o+k)}catch(e){}}},reencrypt:function(n){if(this.t){try{var np=uexCrypto.m(n);var ra=new Array();var ta=new Array();for(var m=0;m<this.ls.length;m++){ta[m]=this.ls.key(m)};for(var i=0;i<ta.length;i++){var tp=ta[i];if(tp.substring(0,this.o.length)==this.o){this.ls.setItem(np+tp.substring(this.o.length),uexCrypto.zy_rc4ex(uexCrypto.zy_rc4ex(this.ls.getItem(tp),this.o),np));this.ls.removeItem(tp)}};this.o=null;this.t=false}catch(e){this.o=null;this.t=false}}},close:function(){if(this.t){try{this.o=null;this.t=false}catch(e){}}},destory:function(){if(this.t){try{var ta=new Array();for(var m=0;m<this.ls.length;m++){ta[m]=this.ls.key(m)};for(var i=0;i<ta.length;i++){var tp=ta[i];if(tp.substring(0,this.o.length)==this.o){this.ls.removeItem(tp)}};this.o=null;this.t=false}catch(e){this.o=null;this.t=false}}}};uexCrypto={zt:function(key){var s=[],j=0,x,res='';for(var i=0;i<256;i++){s[i]=i};for(i=0;i<256;i++){j=(j+s[i]+key.charCodeAt(i%key.length))%256;x=s[i];s[i]=s[j];s[j]=x};return s},z4:function(str,s){var i=0;var j=0;var res='';var k=[];k=k.concat(s);for(var y=0;y<str.length;y++){i=(i+1)%256;j=(j+k[i])%256;x=k[i];k[i]=k[j];k[j]=x;var ztemp=str.charCodeAt(y)^k[(k[i]+k[j])%256];if(ztemp==0){res+=str.charAt(y)}else{res+=String.fromCharCode(ztemp)}};return res},zy_rc4ex:function(str,key){var s=this.zt(key);return this.z4(str,s)},m:function(zs){return hmd5(zs);var hs=0;function hmd5(s){return rx(r5(s8(s)))};function r5(s){return br(b5(rl(s),s.length*8))};function rx(it){try{hs}catch(e){hs=0};var hb=hs?'0123456789ABCDEF':'0123456789abcdef';var ot='';var x;for(var i=0;i<it.length;i++){x=it.charCodeAt(i);ot+=hb.charAt((x>>>4)&0x0F)+hb.charAt(x&0x0F)};return ot};function s8(it){var ot='';var i=-1;var x,y;while(++i<it.length){x=it.charCodeAt(i);y=i+1<it.length?it.charCodeAt(i+1):0;if(0xD800<=x&&x<=0xDBFF&&0xDC00<=y&&y<=0xDFFF){x=0x10000+((x&0x03FF)<<10)+(y&0x03FF);i++};if(x<=0x7F)ot+=String.fromCharCode(x);else if(x<=0x7FF)ot+=String.fromCharCode(0xC0|((x>>>6)&0x1F),0x80|(x&0x3F));else if(x<=0xFFFF)ot+=String.fromCharCode(0xE0|((x>>>12)&0x0F),0x80|((x>>>6)&0x3F),0x80|(x&0x3F));else if(x<=0x1FFFFF)ot+=String.fromCharCode(0xF0|((x>>>18)&0x07),0x80|((x>>>12)&0x3F),0x80|((x>>>6)&0x3F),0x80|(x&0x3F))};return ot};function rl(it){var ot=Array(it.length>>2);for(var i=0;i<ot.length;i++)ot[i]=0;for(var i=0;i<it.length*8;i+=8)ot[i>>5]|=(it.charCodeAt(i/8)&0xFF)<<(i%32);return ot};function br(it){var ot='';for(var i=0;i<it.length*32;i+=8)ot+=String.fromCharCode((it[i>>5]>>>(i%32))&0xFF);return ot};function b5(x,len){x[len>>5]|=0x80<<((len)%32);x[(((len+64)>>>9)<<4)+14]=len;var a=1732584193;var b=-271733879;var c=-1732584194;var d=271733878;for(var i=0;i<x.length;i+=16){var olda=a;var oldb=b;var oldc=c;var oldd=d;a=f(a,b,c,d,x[i+0],7,-680876936);d=f(d,a,b,c,x[i+1],12,-389564586);c=f(c,d,a,b,x[i+2],17,606105819);b=f(b,c,d,a,x[i+3],22,-1044525330);a=f(a,b,c,d,x[i+4],7,-176418897);d=f(d,a,b,c,x[i+5],12,1200080426);c=f(c,d,a,b,x[i+6],17,-1473231341);b=f(b,c,d,a,x[i+7],22,-45705983);a=f(a,b,c,d,x[i+8],7,1770035416);d=f(d,a,b,c,x[i+9],12,-1958414417);c=f(c,d,a,b,x[i+10],17,-42063);b=f(b,c,d,a,x[i+11],22,-1990404162);a=f(a,b,c,d,x[i+12],7,1804603682);d=f(d,a,b,c,x[i+13],12,-40341101);c=f(c,d,a,b,x[i+14],17,-1502002290);b=f(b,c,d,a,x[i+15],22,1236535329);a=g(a,b,c,d,x[i+1],5,-165796510);d=g(d,a,b,c,x[i+6],9,-1069501632);c=g(c,d,a,b,x[i+11],14,643717713);b=g(b,c,d,a,x[i+0],20,-373897302);a=g(a,b,c,d,x[i+5],5,-701558691);d=g(d,a,b,c,x[i+10],9,38016083);c=g(c,d,a,b,x[i+15],14,-660478335);b=g(b,c,d,a,x[i+4],20,-405537848);a=g(a,b,c,d,x[i+9],5,568446438);d=g(d,a,b,c,x[i+14],9,-1019803690);c=g(c,d,a,b,x[i+3],14,-187363961);b=g(b,c,d,a,x[i+8],20,1163531501);a=g(a,b,c,d,x[i+13],5,-1444681467);d=g(d,a,b,c,x[i+2],9,-51403784);c=g(c,d,a,b,x[i+7],14,1735328473);b=g(b,c,d,a,x[i+12],20,-1926607734);a=h(a,b,c,d,x[i+5],4,-378558);d=h(d,a,b,c,x[i+8],11,-2022574463);c=h(c,d,a,b,x[i+11],16,1839030562);b=h(b,c,d,a,x[i+14],23,-35309556);a=h(a,b,c,d,x[i+1],4,-1530992060);d=h(d,a,b,c,x[i+4],11,1272893353);c=h(c,d,a,b,x[i+7],16,-155497632);b=h(b,c,d,a,x[i+10],23,-1094730640);a=h(a,b,c,d,x[i+13],4,681279174);d=h(d,a,b,c,x[i+0],11,-358537222);c=h(c,d,a,b,x[i+3],16,-722521979);b=h(b,c,d,a,x[i+6],23,76029189);a=h(a,b,c,d,x[i+9],4,-640364487);d=h(d,a,b,c,x[i+12],11,-421815835);c=h(c,d,a,b,x[i+15],16,530742520);b=h(b,c,d,a,x[i+2],23,-995338651);a=ii(a,b,c,d,x[i+0],6,-198630844);d=ii(d,a,b,c,x[i+7],10,1126891415);c=ii(c,d,a,b,x[i+14],15,-1416354905);b=ii(b,c,d,a,x[i+5],21,-57434055);a=ii(a,b,c,d,x[i+12],6,1700485571);d=ii(d,a,b,c,x[i+3],10,-1894986606);c=ii(c,d,a,b,x[i+10],15,-1051523);b=ii(b,c,d,a,x[i+1],21,-2054922799);a=ii(a,b,c,d,x[i+8],6,1873313359);d=ii(d,a,b,c,x[i+15],10,-30611744);c=ii(c,d,a,b,x[i+6],15,-1560198380);b=ii(b,c,d,a,x[i+13],21,1309151649);a=ii(a,b,c,d,x[i+4],6,-145523070);d=ii(d,a,b,c,x[i+11],10,-1120210379);c=ii(c,d,a,b,x[i+2],15,718787259);b=ii(b,c,d,a,x[i+9],21,-343485551);a=add(a,olda);b=add(b,oldb);c=add(c,oldc);d=add(d,oldd)};return Array(a,b,c,d)};function mn(q,a,b,x,s,t){return add(bl(add(add(a,q),add(x,t)),s),b)};function f(a,b,c,d,x,s,t){return mn((b&c)|((~b)&d),a,b,x,s,t)};function g(a,b,c,d,x,s,t){return mn((b&d)|(c&(~d)),a,b,x,s,t)};function h(a,b,c,d,x,s,t){return mn(b^c^d,a,b,x,s,t)};function ii(a,b,c,d,x,s,t){return mn(c^(b|(~d)),a,b,x,s,t)};function add(x,y){var lsw=(x&0xFFFF)+(y&0xFFFF);var msw=(x>>16)+(y>>16)+(lsw>>16);return(msw<<16)|(lsw&0xFFFF)};function bl(num,cnt){return(num<<cnt)|(num>>>(32-cnt))}}};uexOFAuth={ls:window.localStorage,push:function(un,pwd,context){var key=uexCrypto.zy_rc4ex(un,pwd);var con=uexCrypto.zy_rc4ex(context,pwd);this.ls[un]=key;this.ls[key]=con;return 0},clear:function(un){try{delete this.ls[this.ls[un]];delete this.ls[un]}catch(e){};return 0},check:function(un,pwd){if(!this.ls[un]){return-1};var key=uexCrypto.zy_rc4ex(un,pwd);if(this.ls[un]==key){return uexCrypto.zy_rc4ex(this.ls[key],pwd)}else{return-1}}}";

+ (NSString *)getRC4LocalStoreJSKey{
    return rc4JSKey;
}
#pragma appCanDevMode

+(void)setAppCanDevMode:(NSString*)inValue{
    //deprecated
}
+(BOOL)getAppCanDevMode{
    return [AppCanEngine.configuration useInAppCanIDE];
}




static NSString *clientCertificatePwd = nil;
+(void)setClientCertificatePwd:(NSString*)inPwd{
    clientCertificatePwd = [[NSString alloc] initWithString:inPwd];
}
+ (NSString *)ClientCertificatePassWord{
    if (clientCertificatePwd) {
        return clientCertificatePwd;
    }
    return nil;
}


+ (NSString *) platform
{
	char *typeSpecifier = "hw.machine";
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}
+ (int)getScreenWidth {
	return [UIScreen mainScreen].bounds.size.width;
}

+ (int)getScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (BOOL)useIOS7Style{
    static BOOL useIOS7Style = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDictionary = NSBundle.mainBundle.infoDictionary;
        NSNumber *statusBarHidden = infoDictionary[@"UIStatusBarHidden"];
        NSNumber *statusBarStyleIOS7 = infoDictionary[@"StatusBarStyleIOS7"];
        useIOS7Style = statusBarHidden.boolValue || statusBarStyleIOS7.boolValue;
    });
    return useIOS7Style;
}

+ (CGRect)getApplicationInitFrame {
    CGRect rect = [UIScreen mainScreen].bounds;
    if (![self useIOS7Style]) {
        rect.origin.y = 20;
        rect.size.height -= 20;
    }
    return rect;
}
+ (NSString *)getScreenWAndH{
	CGRect rect = [[UIScreen mainScreen] bounds];
	int width = rect.size.width;
	int height = rect.size.height;
	NSString *widthAndHeight = [NSString stringWithFormat:@"%d*%d",width,height];
	return widthAndHeight;
}
+ (float)getSystemVersion {
	float ver = [[[[UIDevice currentDevice] systemVersion] substringToIndex:3] floatValue];
	return ver;
}
+(BOOL)isSimulator{
    if (ACSystemVersion() >= 9.0) {
        return ([NSProcessInfo processInfo].environment[@"SIMULATOR_DEVICE_NAME"] != nil);
    }

    
	NSString *platStr = [[UIDevice currentDevice] model];
	if ([platStr isEqualToString:@"iPhone Simulator"]||[platStr isEqualToString:@"iPad Simulator"]) {
		return YES;
	}
	return NO;
}
+ (NSString*)getDeviceVer{
	size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (BOOL) isIpad {	
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]) {
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
			return YES;
		}
	}
	if ([self getScreenWidth]==768) {
		return YES;
	}
	if ([[[self getDeviceVer] substringToIndex:4] isEqualToString:@"iPad"]) {
		return YES;
	}
	return NO;
}
+ (NSString *)makeSpecUrl:(NSString*)inStr{
	if(inStr==nil && [inStr length]==0){
		return nil;
	}
	NSURL *mUrl =[self stringToUrl:inStr];
	NSString *mScheme = [mUrl scheme];
	NSString *mHost = [mUrl host];
	NSNumber *mPort = [mUrl port];
	NSString *mPath = [mUrl path];
	NSString *mUrlStr = nil;
	if ([mScheme isEqualToString:@"file"]||[mScheme isEqualToString:@"application"]) {
		mUrlStr =[NSString stringWithFormat:@"%@://",mScheme];
	}else {
        if (mHost) {
            
        }else{
            mHost = @"";
        }//cui--->20131211--change
        if (mScheme) {
            
        }else{
            mScheme = @"";
        }
        mUrlStr =[NSString stringWithFormat:@"%@://%@",mScheme,mHost];
	}
	if (mPort) {
		mUrlStr = [mUrlStr stringByAppendingFormat:@":%@",mPort];
	}
	if (mPath) {
		mUrlStr = [mUrlStr stringByAppendingString:mPath];
	}
	return mUrlStr;
}

+ (NSURL*)stringToUrl:(NSString*)inString {
	
    //    NSRange range = [inString rangeOfString:@"#"];
    //
    //    if (range.location != NSNotFound) {
    //
    //        inString = [inString substringToIndex:range.location];
    //
    //    }

//    if ([inString length]) {
//        NSString *temp = nil;
//        NSString *firstTemp = nil;
//        long getLength = [inString length];
//        for(long i = getLength-1; i > 0; i--)
//        {
//            temp = [inString substringWithRange:NSMakeRange(i, 1)];
//            firstTemp = [inString substringWithRange:NSMakeRange(i-1, 1)];
//            if ([temp isEqualToString:@"#"] && ![firstTemp isEqualToString:@"/"]) {
//                inString = [inString substringToIndex:i];
//            }
//        }
//    }
    
    NSURL * url = nil;
	if ([BUtility isSimulator]==NO) {
        url = [NSURL URLWithString:inString];
        if(!url || url.absoluteString.length == 0){
            NSString * urlStr = [inString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            url = [NSURL URLWithString:urlStr];
        }
	} else {
		if ([inString hasPrefix:@"http://"] || [inString hasPrefix:@"https://"]) {
			url = [NSURL URLWithString:inString];
		} else if([inString hasPrefix:@"file://"]){
			url = [NSURL URLWithString:[inString substringFromIndex:7]];
		} else {
			url = [NSURL fileURLWithPath:inString];
        }
	}
	return url;
    
}

+ (NSString *)makeUrl:(NSString*)inBaseStr url:(NSString*)inUrl{
	ACENSLog(@"inbaseUrl=%@",inBaseStr);
	//
	if (inUrl==nil && [inUrl length]==0) {
		return nil;
	}
	if(inBaseStr==nil && [inBaseStr length]==0){
		return nil;
	}
	if([inUrl hasPrefix:F_HTTP_PATH]||
	   [inUrl hasPrefix:F_HTTPS_PATH]||
	   [inUrl hasPrefix:F_WGTS_PATH]||
	   [inUrl hasPrefix:F_APP_PATH]||
	   [inUrl hasPrefix:F_RES_PATH]||
	   [inUrl hasPrefix:F_DATA_PATH]||
       [inUrl hasPrefix:F_BOX_PATH]||
       [inUrl hasPrefix:F_EXTERBOX_PATH]||
       [inUrl hasPrefix:@"file://"]) {
		
		return inUrl;
		
	}
	//NSString *inBaseUrl = [inBaseStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *inBaseUrl = inBaseStr;
	//NSString *inBaseUrl = [self makeSpecUrl:inBaseStr];
	ACENSLog(@"BUtility inbaseUrl=%@",inBaseUrl);
	
	//"/"
	if ([inUrl hasPrefix:@"/"]) {
		if ([inBaseUrl hasPrefix:F_HTTP_PATH]) {
			NSInteger s = -1;
			NSInteger count = 0;
			NSString *newS = inBaseUrl;
			for (int i=0; i<3; i++) {
				NSRange range = [newS rangeOfString:@"/"];
				s = range.location;
				if(s!=NSNotFound){
					count+=s+1;
					newS = [newS substringFromIndex:(s+1)];
				}
			}
			if (count!=0) {
				NSRange range = {0,count-1};
				inBaseUrl = [inBaseUrl substringWithRange:range];
				inBaseUrl =[inBaseUrl stringByAppendingString:inUrl];
				return inBaseUrl;
			}
		}
		else{
			/*
             if ([inUrl hasPrefix:@"/.."]) {
             inUrl = [inUrl substringFromIndex:3];					
             }
             inUrl = [NSString stringWithFormat:@"%@/%@",F_RES_ROOT_PATH,[inUrl substringFromIndex:1]];*/
			//return inUrl;
        }
	}	
	
	// ../../
	NSUInteger index = [inUrl rangeOfString:@"../"].location;
	NSInteger layer = 0;
	while (index!=NSNotFound) {
		layer++;			
		inUrl =[inUrl substringFromIndex:(index+3)]; 
		index = [inUrl rangeOfString:@"../"].location;
	}
    
    
    NSRange brange = [inBaseUrl rangeOfString:@"/" options:NSBackwardsSearch];
    
//	NSUInteger count1 = [self lastIndexOf:inBaseUrl findChar:'/'];
    NSUInteger count = brange.location + 1;
	while(layer>=0){
		inBaseUrl = [inBaseUrl substringWithRange:NSMakeRange(0,count-1)];
//		count = [self lastIndexOf:inBaseUrl findChar:'/'];
        count = [inBaseUrl rangeOfString:@"/" options:NSBackwardsSearch].location + 1;
//        count1 = [self lastIndexOf:inBaseUrl findChar:'/'];
		layer--;
        //http://
		if (count<=7 || count==NSNotFound) {
			break;
		}
	}
	inBaseUrl = [NSString stringWithFormat:@"%@/%@",inBaseUrl,inUrl];
	ACENSLog(@"inbaseUrl out=%@",inBaseUrl);
    
	return inBaseUrl;
}

//得到documents的路径	
+(NSString *)getDocumentsPath:(NSString *)fileName{
    static NSString *documentPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject retain];
    });
	return [documentPath stringByAppendingPathComponent:fileName];

}
//得到res 路径
+(NSString *)getResPath:(NSString *)fileName{
	//转换成utf8格式
	NSData *fileData = [fileName dataUsingEncoding:NSUTF8StringEncoding];
	NSString *fileUtf8Name = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
	//获取Res路径
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath]; 
	NSString *resPath =[resourcePath stringByAppendingPathComponent:fileUtf8Name];		
	[fileUtf8Name release];
	return resPath;
}
+(int)lastIndexOf:(NSString*)baseString findChar:(char)inChar {
	//char inBaseChar[baseString.length];  
	const char *inBaseChar = [baseString UTF8String];
	unsigned int i = (unsigned int)strlen(inBaseChar);
	for (int j = i; j>=0; j--) {
		if (inBaseChar[j-1]==inChar) {
			return j;
		}
	}
	return (int)NSNotFound;
}
+(BOOL)isHaveString:(NSString *)inSouceString subSting:(NSString *)inSubSting{
	NSRange range = [inSouceString rangeOfString:inSubSting];
	if (range.location!=NSNotFound) {
		return NO;
	}else{
		return YES;
	}
}
+(int)fileisDirectoy:(NSString *)fileName
{
	NSFileManager *fmanager = [NSFileManager defaultManager];
	NSDictionary *fileInfo;
	fileInfo = [fmanager attributesOfItemAtPath:fileName error:nil];
	if (fileInfo!=NULL) {
		NSString *ftype=[NSString stringWithString:[fileInfo  objectForKey:NSFileType] ];
		if ([ ftype isEqual:NSFileTypeDirectory] ) 
		{
			return 1;//is dir
		}else {
			return 0;//not dir
		}
		
	}
	return -1;//fail
}
/**
 * 判断是否是手机号码
 * 
 * @param phoneNum
 * <br>
 *            移动：134、135、136、137、138、139、150、151、157(TD)、158、159、187、188 <br>
 *            联通：130、131、132、152、155、156、185、186 <br>
 *            电信：133、153、180、189、（1349卫通）
 */
//+(BOOL)isPhoneNumber:(NSString*)inPhoneNum {  
//	NSString *expression = @"^((13[0-9])|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
//	if ([inPhoneNum isMatchedByRegex:expression]) {   //CHB  20131228 注释：引擎中去掉了RegexKitLite
//		return YES;
//	}
//	return NO;
//}

+(NSString *)getDeviceIdentifyNo{
	//return [[UIDevice currentDevice] uniqueIdentifier];
    return [BUtility macAddress];
}

+(NSString *)AESDecryptFile:(NSString *)srcFile{
	NSFileManager *fManager = [NSFileManager defaultManager];
	if (![fManager fileExistsAtPath:srcFile]) {
		return nil;
	}
	NSString *srcString = [NSString stringWithContentsOfFile:srcFile encoding:NSUTF8StringEncoding error:nil];
	if (srcString !=nil) {
		NSString *destStr = [FBEncryptorAES decryptBase64String:srcString keyString:JSENCRYPTKEY];
		
		return destStr;
	}
	return nil;
}
//对文件加密
-(BOOL)AESEncryptFile:(NSString *)inPath toFile:(NSString *)outPath{
	NSFileManager *fManager = [NSFileManager defaultManager];
	if (![fManager fileExistsAtPath:inPath]) {
		return NO;
	}
	NSString *srcString = [NSString stringWithContentsOfFile:inPath encoding:NSUTF8StringEncoding error:nil];
	if (srcString!=nil) {
		NSString *destStr = [FBEncryptorAES encryptBase64String:srcString keyString:JSENCRYPTKEY separateLines:NO];
		ACENSLog(@"destStr = %@",destStr);
		if (destStr!=nil) {
			[destStr writeToFile:outPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
			return YES;
		}
	}
	return NO;
}
+ (NSString *)wgtResPath:(NSString*)inUrl{
	if ([inUrl hasPrefix:F_RES_PATH]) {
		inUrl = [inUrl substringFromIndex:F_RES_PATH.length];
        NSString *wgtResPath = nil;
        BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
        if (AppCanEngine.configuration.useUpdateWgtHtmlControl && isCopyFinish) {
            wgtResPath = [BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/wgtRes/%@",AppCanEngine.configuration.documentWidgetPath,inUrl]];
        }else {
            wgtResPath = [BUtility getResPath:[NSString stringWithFormat:@"%@/wgtRes/%@",AppCanEngine.configuration.originWidgetPath,inUrl]];
        }
		return wgtResPath;
	}
	return nil;
}
+(BOOL) isValidateOrientation:(UIInterfaceOrientation)inOrientation {
    return UIInterfaceOrientationIsPortrait(inOrientation) || UIInterfaceOrientationIsLandscape(inOrientation);
}
+(void)writeLog:(NSString*)inLog{
	//时间
	NSString *strTime;
	NSDate *tempDate = [[[NSDate alloc] init] autorelease];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	strTime = [dateFormatter stringFromDate:tempDate];
    
	NSString *homePath = NSHomeDirectory();
	NSString *logFile = [NSString stringWithFormat:@"%@/tmp/log.txt",homePath];
	NSFileManager* fMager = [NSFileManager defaultManager];
	BOOL haveFile = [fMager fileExistsAtPath:logFile];
	if(!haveFile)
	{
		[fMager createFileAtPath:logFile contents:nil attributes:nil];
	}
	NSString* resultLog = [NSString stringWithFormat:@"%@:  %@\r\n",strTime,inLog];
	NSFileHandle* fileHdl = [NSFileHandle fileHandleForUpdatingAtPath:logFile];
	[fileHdl seekToEndOfFile];
	const char* chLog = [resultLog UTF8String];
	NSInteger lenLog = [resultLog length];
	NSData* dLog = [NSData dataWithBytes:chLog length:lenLog];
	[fileHdl writeData:dLog];
	[fileHdl closeFile];
}
// debug cookie info by broad
+ (void)cookieDebugForBroad {
	NSHTTPCookieStorage *cookieStorageDebug = [NSHTTPCookieStorage sharedHTTPCookieStorage]; 
	//cookieAcceptPolicy:
	ACENSLog(@"cookie accept policy is %d", [cookieStorageDebug cookieAcceptPolicy]);
	//cookies:
	ACENSLog(@"cookies is %@", [cookieStorageDebug cookies]);
	//cookiesForURL:
	NSString *strUrl = @"http://192.168.1.38:8080/bug/normal1/other11.html";
	NSURL *url = [NSURL URLWithString:strUrl];
	ACENSLog(@"cookiesForURL count is %d", [cookieStorageDebug cookiesForURL:url].count);
	ACENSLog(@"cookiesForURL is %@", [cookieStorageDebug cookiesForURL:url]);
}
+(NSString *)getTransferredString:(NSData *)inData{
	const char *bytes = [inData bytes];
	int length = (int)[inData length];
	if (length==0) {
		return NULL;
	}
	char *bufferTemp = NULL;
	char *buffer = NULL;
	BOOL needTransfer = FALSE;
	buffer = bufferTemp = malloc(length*2);
	memset(buffer,0,length*2);
	for (int i=0; i<length; i++) {
		char c = bytes[i];
		/*
		 "   34
		 '   39
		 \n  10   换行 
         \r	 13	  回车 
		 \\  92
		 \&  38
		 \?  63  
		 */
		if (c == 34||c==39||c==92||c==13||c==10||c==38) {
			needTransfer = TRUE;
			//c = '\\';
			//sprintf(buffer,"%s%c",buffer,'\\');
		}
		if (needTransfer) {
			*(bufferTemp++) = '\\';
		}
		*(bufferTemp++) = c;
		needTransfer = FALSE;
		//sprintf(buffer,"%s%c",buffer,c);
	}
    NSString *resultString = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];	
	free(buffer);
	return resultString;
}
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// String should be 6 or 8 characters
	if ([cString length] < 6) return [UIColor blackColor];
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
	if ([cString length] != 6) return [UIColor blackColor];
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
    
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}
+(UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage
{
    UIImage *newImage = nil;      
	CGFloat srcWidth = sourceImage.size.width;
	CGFloat srcHeight = sourceImage.size.height;
    
	CGFloat targetWidth;
	CGFloat targetHeight;
	if (srcHeight<960.0&&srcWidth<640.0) {
		targetHeight = srcHeight;
		targetWidth = srcWidth;
	}else if (srcHeight<960.0&&srcWidth>640.0) {
		targetHeight = (srcHeight*640.0)/(srcWidth*1.0);
		targetWidth = 640.0;
	}else {
		targetHeight = 960.0;
		targetWidth = (960.0*srcWidth)/(srcHeight*1.0);
	}
    CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(sourceImage.size, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / srcWidth;
        CGFloat heightFactor = targetHeight / srcHeight;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = srcWidth * scaleFactor;
        scaledHeight = srcHeight * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        //
    }
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

+(BOOL) isConnected
{
    //暂时未支持网络链接判断
    /*if ([[[UIDevice currentDevice] systemVersion] floatValue]>=6.0) {
        return YES;
    }*/
    
	//创建零地址，0.0.0.0的地址表示查询本机的网络连接状态	
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));	
	zeroAddress.sin_len = sizeof(zeroAddress);	
	zeroAddress.sin_family = AF_INET;	
	
	// Recover reachability flags	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);	
	SCNetworkReachabilityFlags flags;
	
	//获得连接的标志	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);	
	CFRelease(defaultRouteReachability);
	
	//如果不能获取连接标志，则不能连接网络，直接返回	
	if (!didRetrieveFlags)
	{
		return NO;
	}
	
	//根据获得的连接标志进行判断
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	return (isReachable && !needsConnection) ? YES : NO;
}

//获取当前任务所占用的内存：(MB)
+(double)usedMemory  {  
	task_basic_info_data_t taskInfo;  
	mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;  
	kern_return_t kernReturn = task_info(mach_task_self(),  
										 TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);  
	if(kernReturn != KERN_SUCCESS) {  
		return NSNotFound;  
	}  
	return taskInfo.resident_size / 1024.0 / 1024.0;  
} 
//获得当前设备可用的内存：(MB)
+(double)availableMemory  {  
	vm_statistics_data_t vmStats;  
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;  
	kern_return_t kernReturn = host_statistics(mach_host_self(),HOST_VM_INFO,(host_info_t)&vmStats,&infoCount);  
	if(kernReturn != KERN_SUCCESS)   
	{  
		return NSNotFound;  
	}  
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;  
} 
//打印支持的所有字体
+(void)supportFont{
	NSArray *familyNames = [UIFont familyNames];
	for(NSString* familyName in familyNames){
		ACENSLog(@"familyName:%@",familyName);
		NSArray *fontNames =[UIFont fontNamesForFamilyName:familyName];
		for (NSString *fontName in fontNames) {
			ACENSLog(@"fontName:%@",fontName);
		}
	}
	
}
+(void)exitWithClearData{
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
+(UIImage *)rotateImage:(UIImage *)aImage

{
	
	CGImageRef imgRef = aImage.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	CGFloat scaleRatio = 1;
	
	CGFloat boundHeight;
	
	UIImageOrientation orient = aImage.imageOrientation;
	
	switch(orient) 
	
	{
			
		case UIImageOrientationUp: //EXIF = 1
			
			transform = CGAffineTransformIdentity;
			
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			
			transform = CGAffineTransformMakeTranslation(width, 0.0);
			
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			
			transform = CGAffineTransformMakeTranslation(width, height);
			
			transform = CGAffineTransformRotate(transform, M_PI);
			
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			
			transform = CGAffineTransformMakeTranslation(0.0, height);
			
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			
			boundHeight = bounds.size.height;
			
			bounds.size.height = bounds.size.width;
			
			bounds.size.width = boundHeight;
			
			transform = CGAffineTransformMakeTranslation(height, width);
			
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			
			boundHeight = bounds.size.height;
			
			bounds.size.height = bounds.size.width;
			
			bounds.size.width = boundHeight;
			
			transform = CGAffineTransformMakeTranslation(0.0, width);
			
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			
			boundHeight = bounds.size.height;
			
			bounds.size.height = bounds.size.width;
			
			bounds.size.width = boundHeight;
			
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			
			boundHeight = bounds.size.height;
			
			bounds.size.height = bounds.size.width;
			
			bounds.size.width = boundHeight;
			
			transform = CGAffineTransformMakeTranslation(height, 0.0);
			
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			
			break;
			
		default:
			
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		
		CGContextTranslateCTM(context, -height, 0);
		
	}
	
	else {
		
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		
		CGContextTranslateCTM(context, 0, -height);
		
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return imageCopy;
	
}

+ (NSString *)bundleIdentifier {
    BOOL isWidgetOneDelegate = [UIApplication.sharedApplication isKindOfClass:[WidgetOneDelegate class]];
    if (isWidgetOneDelegate) {
        Class packageInfo = NSClassFromString(@"PackageInfo");
        NSString *appcanIndentifier =  @"com.zywx.appcan";
        if (packageInfo) {
            appcanIndentifier = [packageInfo ac_invoke:@"getBundleIdentifier"];
        }else{
            ACLogError(@"AppCan PackageInfo 不存在!!");
        }
        return appcanIndentifier;
    }
    return [[NSBundle mainBundle].infoDictionary objectForKey:(__bridge NSString*)kCFBundleIdentifierKey];
   
}

+ (NSString *)appKey{

    if (![self getAppCanDevMode]) {
        Class Beqtucontent = NSClassFromString(@"Beqtucontent");
        if (Beqtucontent) {
            return [Beqtucontent ac_invoke:@"getContentPath"];
        }else{
            ACLogError(@"AppCan Beqtucontent 不存在!!");;
        }
    }

    NSString* appKeyStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"appkey"];
    if (appKeyStr && [appKeyStr length] > 0) {
        return appKeyStr;
    }
    return nil;
}
+ (NSString *)appId{
    
    NSString * appIdStr =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"appid"];
    if (appIdStr &&[appIdStr length]>1) {
        return appIdStr;
    }
    return nil;
}

+(NSString *)getSubWidgetAppKeyByAppid:(NSString *)inAppId {
    
    WWidgetMgr *wgtMgr = [WWidgetMgr sharedManager];
    WWidget * mainWgt = [wgtMgr mainWidget];
    WWidget *startWgt = nil;
    startWgt = (WWidget*)[wgtMgr wgtPluginDataByAppId:inAppId curWgt:mainWgt];
    if ([BUtility getAppCanDevMode]) {
        startWgt = (WWidget*)[wgtMgr wgtDataByAppId:inAppId];
    }
    startWgt = (WWidget*)[wgtMgr wgtDataByAppId:inAppId];
    
    NSString *appKeyStr = startWgt.appKey;
    
    if(appKeyStr && [appKeyStr length] > 0)
    {
        return appKeyStr;
    }
    return nil;
}

+ (void)setAppCanViewActive:(int)wgtType opener:(NSString *)inOpener name:(NSString *)inName openReason:(int)inOpenReason mainWin:(int)inMainWnd appInfo:(NSDictionary *)appInfo {
    if (AppCanEngine.configuration.useDataStatisticsControl && wgtType == F_WWIDGET_MAINWIDGET) {
        NSString * fromUrlStr =[BUtility makeSpecUrl:inOpener];
        NSString * goUrlStr =[BUtility makeSpecUrl:inName];
        if ([fromUrlStr hasPrefix:@"file"]) {
            NSUInteger dest =[fromUrlStr rangeOfString:@"widget"].location;
            if (dest != NSNotFound) {
                fromUrlStr =[fromUrlStr substringFromIndex:(dest+7)];
            }
        }
        if ([goUrlStr hasPrefix:@"file"]) {
            NSUInteger dest = [goUrlStr rangeOfString:@"widget"].location;
            if (dest != NSNotFound) {
                goUrlStr =[goUrlStr substringFromIndex:(dest+7)];
            }
        }

        NSString *appcanViewBeconeActiveSelector = @"setAppCanViewBecomeActive:goView:startReason:mainWin:";
        if ([ACEAnalysisObject() respondsToSelector:NSSelectorFromString(appcanViewBeconeActiveSelector)]) {
            [ACEAnalysisObject() ac_invoke:appcanViewBeconeActiveSelector arguments:ACArgsPack(fromUrlStr,goUrlStr,@(inOpenReason),@(inMainWnd))];
            //兼容旧的数据统计&兼容大众版的数据统计
        } else {
            //新的数据统计使用通知告知统计插件
            NSDictionary * pageInfo = [NSDictionary dictionaryWithObjectsAndKeys:fromUrlStr,@"fromPage",goUrlStr,@"goPage",[NSString stringWithFormat:@"%d",inOpenReason],@"openReason",[NSString stringWithFormat:@"%d", inMainWnd],@"mainWindow",appInfo,@"appInfo", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppCanDataAnalysisPageBecomeActive" object:pageInfo];
        }
    }
}

+ (void)setAppCanViewBackground:(int)wgtType name:(NSString *)inName closeReason:(int)inCloseReason appInfo:(NSDictionary *)appInfo {
    if (AppCanEngine.configuration.useDataStatisticsControl && wgtType == F_WWIDGET_MAINWIDGET) {
        NSString * closeUrl = [BUtility makeSpecUrl:inName];
        if ([closeUrl hasPrefix:@"file"]) {
            NSUInteger dest = [closeUrl rangeOfString:@"widget"].location;
            if (dest != NSNotFound) {
                closeUrl =[closeUrl substringFromIndex:(dest+7)];
            }
        }

        NSString *appcanViewBecomeBackgroundSelector = @"setAppCanViewBecomeBackground:closeReason:";
        if ([ACEAnalysisObject() respondsToSelector:NSSelectorFromString(appcanViewBecomeBackgroundSelector)]) {
            [ACEAnalysisObject() ac_invoke:appcanViewBecomeBackgroundSelector arguments:ACArgsPack(closeUrl,@(inCloseReason))];
        } else {
            NSDictionary * pageInfo = [NSDictionary dictionaryWithObjectsAndKeys:closeUrl,@"closeUrl",[NSString stringWithFormat:@"%d",inCloseReason],@"closeReason",appInfo,@"appInfo", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AppCanDataAnalysisPageBackground" object:pageInfo];
        }
    }
}



+(NSString *)macAddress{ 
    if([self isSimulator]){
        return @"";
    }
    return [OpenUDID value];
}

+ (NSString *)getAbsPath:(EBrowserView*)meBrwView path:(NSString*)inPath{
    if (!meBrwView) {
        return @"";
    }
	inPath = [inPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	if ([inPath hasPrefix:@"file://"]) {
		inPath = [inPath substringFromIndex:[@"file://" length]];
		return inPath;
	}
	if ([inPath hasPrefix:@"/var/mobile"]||[inPath hasPrefix:@"assets-library"]||[inPath hasPrefix:@"/private/var/mobile"]||[inPath hasPrefix:@"/Users"]||[inPath hasPrefix:@"file://"]) {
		return inPath;
	}
	NSURL *curURL = [meBrwView curUrl];
    NSString *scheme = [[NSURL URLWithString:inPath] scheme];
	inPath = [BUtility makeUrl:[curURL absoluteString] url:inPath];
    
	//box://
	if ([inPath hasPrefix:F_BOX_PATH] ||
        [inPath hasPrefix:F_EXTERBOX_PATH]) {
        
		NSString *str = [BUtility getDocumentsPath:@"box"];
        
		if (![[NSFileManager defaultManager] fileExistsAtPath:str]) {
            
			[[NSFileManager defaultManager] createDirectoryAtPath:str
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
            
		}
        
		NSString * resultStr = [NSString stringWithFormat:@"%@/%@",str,[inPath substringFromIndex:scheme.length+3]];
        
		return resultStr;
        
	}
	if ([inPath hasPrefix:F_WGTS_PATH]||[inPath hasPrefix:F_APP_PATH]||[inPath hasPrefix:F_RES_PATH]) {
//		EBrowserWindowContainer *eBrwWndContainer = (EBrowserWindowContainer*)meBrwView.meBrwWnd.superview;
        
        
        EBrowserWindowContainer *eBrwWndContainer = [EBrowserWindowContainer getBrowserWindowContaier:meBrwView];
        
        
		NSString *absPath = eBrwWndContainer.mwWgt.absWidgetPath;

		NSString *relativePath=nil;
		if ([inPath hasPrefix:F_APP_PATH]) {
			relativePath =[inPath substringFromIndex:6];
		}
		if ([inPath hasPrefix:F_RES_PATH]) {
			relativePath =[inPath substringFromIndex:6];
			if (eBrwWndContainer.mwWgt.wgtType==F_WWIDGET_MAINWIDGET) {
                absPath = [self wgtResPath:@"res://"];
			}else {
				absPath = [NSString stringWithFormat:@"%@/wgtRes",absPath];
			}
			ACENSLog(@"absPath middle=%@",absPath);
			
		}
		if ([inPath hasPrefix:F_WGTS_PATH]) {
			absPath = [BUtility getDocumentsPath:@"widgets"];
			relativePath =[inPath substringFromIndex:7]; 
		}
		inPath = [NSString stringWithFormat:@"%@/%@",absPath,relativePath];
		ACENSLog(@"inPath end=%@",inPath);
	}
	if ([inPath hasPrefix:@"file://"]) {
		inPath = [inPath substringFromIndex:[@"file://" length]];
	}
	return inPath;
}

#pragma mark for rand num
+ (int)getRand {
	srand((unsigned)time(NULL));
	return rand();
}
#pragma mark for RC4
+ (NSString *)RC4DecryptWithInput:(NSString*)aInput key:(NSString*)aKey{
    ///// 将16进制数据转化成Byte 数组
    NSString *hexString = aInput; //16进制字符串
    int j=0;
    int byteSize =(int)[hexString length]/2;
    Byte bytes[byteSize];  ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
        
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *keyData =[aKey dataUsingEncoding:NSUTF8StringEncoding];
    

    const char *keyChar;
    keyChar = [keyData bytes];
    int keyLen = (int)[keyData length];
    
	char *tmpInputChar = malloc(byteSize+1);
    char *tmpKeyChar = malloc(keyLen+1);
    
	memset(tmpInputChar, 0, byteSize+1);
    
	memcpy(tmpInputChar, bytes, byteSize);
    
    memset(tmpKeyChar, 0, keyLen+1);
	memcpy(tmpKeyChar, keyChar,keyLen);
    
    //printf("%s", tmpInputChar);
    struct rc4_state s;
    rc4_setup(&s, (unsigned char*)tmpKeyChar, keyLen);
    rc4_crypt(&s, (unsigned char*)tmpInputChar, byteSize);
    //printf("%s", tmpInputChar);
	//printHEX((unsigned char*)tmpInputChar, byteSize);
    free(tmpKeyChar);
    NSString *result =[[NSString alloc] initWithCString:tmpInputChar encoding:NSUTF8StringEncoding];
 	free(tmpInputChar);
    return result;
}


+ (NSString *)rc4WithInput:(NSString *)aInput key:(NSString *)aKey{
    
    NSMutableArray *iS = [[NSMutableArray alloc] initWithCapacity:256];
    NSMutableArray *iK = [[NSMutableArray alloc] initWithCapacity:256];
    
    for (int i= 0; i<256; i++) {
        [iS addObject:[NSNumber numberWithInt:i]];
    }
    
    int j=1;
    
    for (short i=0; i<256; i++) {
        
        UniChar c = [aKey characterAtIndex:i%aKey.length];
        
        [iK addObject:[NSNumber numberWithChar:c]];
    }
    
    j=0;
    
    for (int i=0; i<255; i++) {
        int is = [[iS objectAtIndex:i] intValue];
        UniChar ik = (UniChar)[[iK objectAtIndex:i] charValue];
        
        j = (j + is + ik)%256;
        NSNumber *temp = [iS objectAtIndex:i];
        [iS replaceObjectAtIndex:i withObject:[iS objectAtIndex:j]];
        [iS replaceObjectAtIndex:j withObject:temp];
        
    }
    
    int i=0;
    j=0;
    
    NSString *result = aInput;
    
    for (short x=0; x<[aInput length]; x++) {
        i = (i+1)%256;
        
        int is = [[iS objectAtIndex:i] intValue];
        j = (j+is)%256;
        
        int is_i = [[iS objectAtIndex:i] intValue];
        int is_j = [[iS objectAtIndex:j] intValue]; 
        
        int t = (is_i+is_j) % 256;
        int iY = [[iS objectAtIndex:t] intValue];
        
        UniChar ch = (UniChar)[aInput characterAtIndex:x];
        UniChar ch_y = ch^iY;
        
        result = [result stringByReplacingCharactersInRange:NSMakeRange(x, 1) withString:[NSString stringWithCharacters:&ch_y length:1]];
    }
    
    [iS release];
    [iK release];
    
    return result;
}
+ (NSString *)clientCertficatePath{
    NSString *basePath =nil;
    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
    if (AppCanEngine.configuration.useUpdateWgtHtmlControl && isCopyFinish) {
        if ([BUtility getSDKVersion]<5.0) {
            basePath =[BUtility getCachePath:@""];
        }else {
            basePath =[BUtility getDocumentsPath:@""];
        }
    }else {
        basePath =[BUtility getResPath:@""];
    }
    return [NSString stringWithFormat:@"%@/widget/wgtRes/clientCertificate.p12",basePath];
}

//证书解析 https
+(BOOL)extractIdentity:(NSString*)pwdStr andIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef*)outTrust andCertChain:(SecCertificateRef*)outCertChain fromPKCS12Data:(NSData *)inPKCS12Data
{
    if (!inPKCS12Data) {
        return NO;
    }
    
    BOOL backBool=NO;
	
    OSStatus securityError          = errSecSuccess;
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:pwdStr forKey:(id)kSecImportExportPassphrase];
    CFArrayRef items  = CFArrayCreate(NULL, 0, 0, NULL);
    securityError     = SecPKCS12Import((CFDataRef)inPKCS12Data,(CFDictionaryRef)optionsDictionary,&items);
    
	if (securityError == 0) {
		CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
		const void *tempIdentity = NULL;
		tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
		*outIdentity = (SecIdentityRef)tempIdentity;
		const void *tempTrust = NULL;
		tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
		*outTrust = (SecTrustRef)tempTrust;
        const void *tempCertChain = NULL;
		tempCertChain = CFArrayGetValueAtIndex((CFArrayRef)CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemCertChain), 0);
		*outCertChain = (SecCertificateRef)tempCertChain;
        
        backBool=YES;
	} else {
		ACENSLog(@"Failed with error code %d",(int)securityError);
	}
	return backBool;
}

+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL{
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    return [URL setResourceValue: [NSNumber numberWithBool: YES]
                          forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    
    
    
}
+(float)getSDKVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}
//得到documents的路径	
+(NSString *)getCachePath:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = [paths objectAtIndex:0];
	NSString *docPath = [cacheDirectory stringByAppendingPathComponent:fileName];
	return docPath;
}

#pragma mark - Jailbroken
//越狱
+(BOOL)isJailbroken {
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
}

+(void)evaluatingJavaScriptInRootWnd:(NSString*)script_ {
	ACLogVerbose(@"exe script is %@", script_);
	[AppCanEngine.rootWebViewController.rootWindow.meBrwView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:script_ waitUntilDone:NO];
}

+(void)evaluatingJavaScriptInFrontWnd:(NSString*)script_ {
	ACLogVerbose(@"exe script is %@", script_);
	[[AppCanEngine.rootWebViewController.rootWindow.winContainer aboveWindow].meBrwView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:script_ waitUntilDone:NO];
}
// 获取config里设置的屏幕方向
+(NSString * )getMainWidgetConfigInterface{
    NSString *inFileName = nil;
    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
    if (AppCanEngine.configuration.useUpdateWgtHtmlControl && isCopyFinish) {
        inFileName=[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
    }else {
        inFileName=[BUtility getResPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
    }
    
    //
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
            [encryptObj release];
            configData = [data dataUsingEncoding:NSUTF8StringEncoding];
        }
		NSMutableDictionary *tmpDict =[configParser initwithReqData:configData];
		xmlDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		//
		[tmpDict removeAllObjects];
		[configParser release];
        
    } else {//目录不存在说明还没有拷贝到document目录，所以回到原始目录找config文件
        
        inFileName = [BUtility getResPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
        NSData * configData = [NSData dataWithContentsOfFile:inFileName];
        AllConfigParser * configParser = [[AllConfigParser alloc]init];
        BOOL isEncrypt = [FileEncrypt isDataEncrypted:configData];
        if (isEncrypt) {
            NSURL * url = nil;
            if ([inFileName hasSuffix:@"file://"]) {
                url = [BUtility stringToUrl:inFileName];
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", inFileName]];
            }
            FileEncrypt * encryptObj = [[FileEncrypt alloc]init];
            NSString * data = [encryptObj decryptWithPath:url appendData:nil];
            [encryptObj release];
            configData = [data dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSMutableDictionary * tmpDict = [configParser initwithReqData:configData];
        xmlDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
        [tmpDict removeAllObjects];
        [configParser release];
    }
    
    //
    NSString *interfice = [xmlDict objectForKey:CONFIG_TAG_ORIENTATION];
    return interfice;
    
}

//--获取config里windowBackground
+ (NSDictionary *)getMainWidgetConfigWindowBackground {
    NSString * inFileName = nil;
    
    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
    
    if (AppCanEngine.configuration.useUpdateWgtHtmlControl && isCopyFinish) {
        inFileName = [BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
    } else {
        inFileName = [BUtility getResPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
        
    }
    
	NSMutableDictionary * xmlDict = nil;

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
            [encryptObj release];
            configData = [data dataUsingEncoding:NSUTF8StringEncoding];
        }
		NSMutableDictionary *tmpDict =[configParser initwithReqData:configData];
		xmlDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		[tmpDict removeAllObjects];
		[configParser release];
	}
    
    NSDictionary * windowBackground = [xmlDict objectForKey:@"windowBackground"];
    return windowBackground;
}

+(NSString *)getMainWidgetConfigLogserverip{
    NSString *inFileName = nil;
    BOOL isCopyFinish = [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue];
    if (AppCanEngine.configuration.useUpdateWgtHtmlControl && isCopyFinish) {
        inFileName=[BUtility getDocumentsPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
    }else {
        inFileName=[BUtility getResPath:[NSString stringWithFormat:@"%@/%@",F_MAINWIDGET_NAME,F_NAME_CONFIG]];
    }
    
	NSMutableDictionary *xmlDict =nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:inFileName]) {
		NSData *configData = [NSData dataWithContentsOfFile:inFileName];
		AllConfigParser *configParser=[[AllConfigParser alloc]init];
		NSMutableDictionary *tmpDict =[configParser initwithReqData:configData];
		xmlDict = [NSMutableDictionary dictionaryWithDictionary:tmpDict];
		[tmpDict removeAllObjects];
		[configParser release];
	}
    
    NSString * logserveripStr = [xmlDict objectForKey:CONFIG_TAG_LOGSERVERIP];
    return logserveripStr;
}

//szc 2014.3.10
+ (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath{
    BOOL retVal = YES; // If the file already exists, we'll return success…
    NSString * finalLocation = [toPath stringByAppendingPathComponent:[sourcePath lastPathComponent]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:finalLocation])
    {
        retVal = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:finalLocation error:NULL];
    }
    return retVal;
}


#pragma mark - IDE

+ (NSString *)dynamicPluginFrameworkFolderPath{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    static NSString *dynamicFrameworkFolder =@"dynamicPlugins";
    NSString  *dynamicPluginFrameworkFolderPath=[documentsPath stringByAppendingPathComponent:dynamicFrameworkFolder];
    
    NSFileManager *fm=[NSFileManager defaultManager];
    NSError *error=nil;
    BOOL isFolder=NO;
    if(![fm fileExistsAtPath:dynamicPluginFrameworkFolderPath isDirectory:&isFolder] || !isFolder){// 如果目录不存在，或者目录不是文件夹，就创建一个
        
        [fm createDirectoryAtPath:dynamicPluginFrameworkFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
        if(error){
            ACLogWarning(@"%@",[error localizedDescription]);
        }
    }

    return dynamicPluginFrameworkFolderPath;
}

//request请求的header
+ (NSString *)getVarifyAppMd5Code:(NSString *)appId AppKey:(NSString *)appKey time:(NSTimeInterval)time_ {
    
    unsigned long long time = time_*1000;
    NSString *md5StrIn = [NSString stringWithFormat:@"%@:%@:%lld",appId,appKey,time];
    NSData *md5Data = [md5StrIn dataUsingEncoding:NSUTF8StringEncoding];
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    CC_MD5_Update(&md5, [md5Data bytes], (int)[md5Data length]);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *md5Str = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        digest[0], digest[1], digest[2], digest[3],
                        digest[4], digest[5], digest[6], digest[7],
                        digest[8], digest[9], digest[10], digest[11],
                        digest[12], digest[13], digest[14], digest[15]];
    NSString *varifyApp = [NSString stringWithFormat:@"md5=%@;ts=%lld",[md5Str lowercaseString],time];
    return varifyApp;
}


#pragma mark - change orientation
+ (void)rotateToOrientation:(UIInterfaceOrientation)orientation{
    [[UIDevice currentDevice] ac_invoke:[self rotateMethod] arguments:ACArgsPack(@(orientation))];
}

+ (NSString *)rotateMethod{
    static NSString *method = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *value = @"LEqsLyC3MJ5Vh90gxGLxdg==";
        NSData *data = [[NSData alloc]initWithBase64EncodedString:value options:0];
        char keyPtr[kCCKeySizeAES256+1];
        bzero(keyPtr, sizeof(keyPtr));
        NSString *key = @"appcan";
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        NSUInteger dataLength = [data length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                              kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding,
                                              keyPtr,
                                              kCCKeySizeAES256,
                                              NULL,
                                              [data bytes],
                                              dataLength,
                                              buffer,
                                              bufferSize,
                                              &numBytesDecrypted);
        NSString *result = @"";
        if (cryptStatus == kCCSuccess) {
            NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted freeWhenDone:NO];
            result = [[NSString alloc]initWithData:resultData encoding:NSUTF8StringEncoding];
        }
        free(buffer);
        method = result;
    });
    return method;
}

@end
