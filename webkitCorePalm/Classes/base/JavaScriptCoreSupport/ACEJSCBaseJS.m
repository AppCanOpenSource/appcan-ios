/**
 *
 *	@file   	: ACEJSCBaseJS.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/1/9.
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
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

#import "ACEJSCBaseJS.h"
#import "ACEPluginParser.h"
#import "ACEJSCHandler.h"

static NSString *AppCanEngineJavaScriptCoreBaseJS;

#define ACE_METHOD_SYNC          @(ACEPluginMethodExecuteModeSynchronous)
#define ACE_METHOD_ASYNC         @(ACEPluginMethodExecuteModeAsynchronous)








@implementation ACEJSCBaseJS

+ (void)generateBaseJS{
    ACEPluginParser *parser = [ACEPluginParser sharedParser];
    __block NSMutableDictionary<NSString *,ACEPluginInfo *> *plugins = [parser.pluginDict mutableCopy];
    
    NSArray <ACEPluginInfo *> *enginePlugins = @[[self uexWindowInfo],[self uexWidgetInfo],[self uexWidgetOneInfo],[self uexAppCenterInfo]];
    [enginePlugins enumerateObjectsUsingBlock:^(ACEPluginInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [plugins setValue:obj forKey:obj.uexName];
    }];
    __block NSMutableString *js = [NSMutableString stringWithFormat:@""];
    [plugins enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ACEPluginInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        [js appendString:[self javaScriptForPlugin:obj]];
    }];
    AppCanEngineJavaScriptCoreBaseJS = [js copy];
    
}

+ (NSString *)javaScriptForPlugin:(ACEPluginInfo *)plugin{
    if(!plugin){
        return @"";
    }
    NSMutableString *js =[NSMutableString stringWithFormat:@""];
    [js appendFormat:@"%@={};",plugin.uexName];
    [plugin.methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
        [js appendString:[self javaScriptForMethod:key plugin:plugin.uexName execMode:obj]];
    }];
    [plugin.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [js appendString:[self javaScriptForProperty:key plugin:plugin.uexName value:obj]];
    }];
    return js;
}

+ (NSString *)javaScriptForMethod:(NSString *)method plugin:(NSString *)plugin execMode:(NSNumber *)execMode{
    if([[self exceptions]objectForKey:[NSString stringWithFormat:@"%@.%@",plugin,method]]){
        return [[self exceptions]objectForKey:[NSString stringWithFormat:@"%@.%@",plugin,method]];
    }
    return [NSString stringWithFormat:@"%@.%@=function(){var argCount = arguments.length;return uex.execute('%@','%@',arguments,argCount,%@)};",plugin,method,plugin,method,execMode];
}
+ (NSString *)javaScriptForProperty:(NSString *)property plugin:(NSString *)plugin value:(NSString *)value{
    return [NSString stringWithFormat:@"%@.%@=%@;",plugin,property,value];
}

+ (NSDictionary *)exceptions{
    return @{@"uexDataBaseMgr.transaction":@"uexDataBaseMgr.transaction=function(inDBName,inOpId,inFunc){var temp = [inDBName,inOpId];uex.execute('uexDataBaseMgr','beginTransaction',temp,2,1); inFunc();uex.execute('uexDataBaseMgr','endTransaction',temp,2,1);};"};
}









+ (NSString *)baseJS{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self generateBaseJS];
    });
    return AppCanEngineJavaScriptCoreBaseJS;
}

+ (ACEPluginInfo *)uexWindowInfo{
    
    ACEPluginInfo *uexWindowInfo = [[ACEPluginInfo alloc] initWithName:@"uexWindow"];
    uexWindowInfo.methods = [@{
                               @"forward":ACE_METHOD_ASYNC,
                               @"back":ACE_METHOD_ASYNC,
                               @"setMultiPopoverFrame":ACE_METHOD_ASYNC,
                               @"evaluateMultiPopoverScript":ACE_METHOD_ASYNC,
                               @"pageForward":ACE_METHOD_ASYNC,
                               @"pageBack":ACE_METHOD_ASYNC,
                               @"reload":ACE_METHOD_ASYNC,
                               @"alert":ACE_METHOD_ASYNC,
                               @"confirm":ACE_METHOD_ASYNC,
                               @"prompt":ACE_METHOD_ASYNC,
                               @"actionSheet":ACE_METHOD_ASYNC,
                               @"open":ACE_METHOD_ASYNC,
                               @"openPresentWindow":ACE_METHOD_ASYNC,
                               @"setLoadingImagePath":ACE_METHOD_ASYNC,
                               @"toggleSlidingWindow":ACE_METHOD_ASYNC,
                               @"setSlidingWindowEnabled":ACE_METHOD_ASYNC,
                               @"setSlidingWindow":ACE_METHOD_ASYNC,
                               @"closeByName":ACE_METHOD_ASYNC,
                               @"closeAboveWndByName":ACE_METHOD_ASYNC,
                               @"close":ACE_METHOD_ASYNC,
                               @"openSlibing":ACE_METHOD_ASYNC,
                               @"openMultiPopover":ACE_METHOD_ASYNC,
                               @"closeMultiPopover":ACE_METHOD_ASYNC,
                               @"setSelectedPopOverInMultiWindow":ACE_METHOD_ASYNC,
                               @"setAutorotateEnable":ACE_METHOD_ASYNC,
                               @"closeSlibing":ACE_METHOD_ASYNC,
                               @"showSlibing":ACE_METHOD_ASYNC,
                               @"evaluateScript":ACE_METHOD_ASYNC,
                               @"windowForward":ACE_METHOD_ASYNC,
                               @"windowBack":ACE_METHOD_ASYNC,
                               @"loadObfuscationData":ACE_METHOD_ASYNC,
                               @"toast":ACE_METHOD_ASYNC,
                               @"closeToast":ACE_METHOD_ASYNC,
                               @"setReportKey":ACE_METHOD_ASYNC,
                               @"getState":ACE_METHOD_SYNC,
                               @"openPopover":ACE_METHOD_ASYNC,
                               @"closePopover":ACE_METHOD_ASYNC,
                               @"setWindowHidden":ACE_METHOD_ASYNC,
                               @"setPopoverVisibility":ACE_METHOD_ASYNC,
                               @"insertWindowAboveWindow":ACE_METHOD_ASYNC,
                               @"insertWindowBelowWindow":ACE_METHOD_ASYNC,
                               @"setOrientation":ACE_METHOD_ASYNC,
                               @"setStatusBarTitleColor":ACE_METHOD_ASYNC,
                               @"setWindowScrollbarVisible":ACE_METHOD_ASYNC,
                               @"setPopoverFrame":ACE_METHOD_ASYNC,
                               @"evaluatePopoverScript":ACE_METHOD_ASYNC,
                               @"openAd":ACE_METHOD_ASYNC,
                               @"setBounce":ACE_METHOD_ASYNC,
                               @"getBounce":ACE_METHOD_ASYNC,
                               @"setBounceParams":ACE_METHOD_ASYNC,
                               @"setRightSwipeEnable":ACE_METHOD_ASYNC,
                               @"topBounceViewRefresh":ACE_METHOD_ASYNC,
                               @"showBounceView":ACE_METHOD_ASYNC,
                               @"hiddenBounceView":ACE_METHOD_ASYNC,
                               @"resetBounceView":ACE_METHOD_ASYNC,
                               @"notifyBounceEvent":ACE_METHOD_ASYNC,
                               @"getUrlQuery":ACE_METHOD_SYNC,
                               @"statusBarNotification":ACE_METHOD_ASYNC,
                               @"preOpenStart":ACE_METHOD_ASYNC,
                               @"preOpenFinish":ACE_METHOD_ASYNC,
                               @"beginAnimition":ACE_METHOD_ASYNC,
                               @"setAnimitionDelay":ACE_METHOD_ASYNC,
                               @"setAnimitionDuration":ACE_METHOD_ASYNC,
                               @"setAnimitionCurve":ACE_METHOD_ASYNC,
                               @"creatPluginViewContainer":ACE_METHOD_ASYNC,
                               @"setPageInContainer":ACE_METHOD_ASYNC,
                               @"setAnimitionRepeatCount":ACE_METHOD_ASYNC,
                               @"setAnimitionAutoReverse":ACE_METHOD_ASYNC,
                               @"makeAlpha":ACE_METHOD_ASYNC,
                               @"makeTranslation":ACE_METHOD_ASYNC,
                               @"makeScale":ACE_METHOD_ASYNC,
                               @"makeRotate":ACE_METHOD_ASYNC,
                               @"commitAnimition":ACE_METHOD_ASYNC,
                               @"insertPopoverAbovePopover":ACE_METHOD_ASYNC,
                               @"insertPopoverBelowPopover":ACE_METHOD_ASYNC,
                               @"bringPopoverToFront":ACE_METHOD_ASYNC,
                               @"sendPopoverToBack":ACE_METHOD_ASYNC,
                               @"insertAbove":ACE_METHOD_ASYNC,
                               @"insertBelow":ACE_METHOD_ASYNC,
                               @"bringToFront":ACE_METHOD_ASYNC,
                               @"sendToBack":ACE_METHOD_ASYNC,
                               @"setWindowFrame":ACE_METHOD_ASYNC,
                               @"setMultilPopoverFlippingEnbaled":ACE_METHOD_ASYNC,
                               @"getSlidingWindowState":ACE_METHOD_ASYNC,
                               @"postGlobalNotification":ACE_METHOD_ASYNC,
                               @"onGlobalNotification":ACE_METHOD_ASYNC,
                               @"subscribeChannelNotification":ACE_METHOD_ASYNC,
                               @"publishChannelNotification":ACE_METHOD_ASYNC,
                               @"disturbLongPressGesture":ACE_METHOD_ASYNC,
                               @"setSwipeCloseEnable":ACE_METHOD_ASYNC,
                               @"setWebViewScrollable":ACE_METHOD_ASYNC,
                               @"createProgressDialog":ACE_METHOD_ASYNC,
                               @"destroyProgressDialog":ACE_METHOD_ASYNC,
                               @"hideStatusBar":ACE_METHOD_ASYNC,
                               @"showStatusBar":ACE_METHOD_ASYNC,
                               @"createPluginViewContainer":ACE_METHOD_ASYNC,
                               @"closePluginViewContainer":ACE_METHOD_ASYNC,
                               @"log":ACE_METHOD_SYNC,
                               @"getWidth":ACE_METHOD_SYNC,
                               @"getHeight":ACE_METHOD_SYNC,
                               @"putLocalData":ACE_METHOD_ASYNC,
                               @"getLocalData":ACE_METHOD_SYNC,
                               @"publishChannelNotificationForJson":ACE_METHOD_ASYNC,
                               @"setIsSupportSwipeCallback":ACE_METHOD_ASYNC,
                               @"share":ACE_METHOD_ASYNC,
                               @"getWindowName":ACE_METHOD_SYNC,
                               } mutableCopy];
    return uexWindowInfo;
}

+ (ACEPluginInfo *)uexWidgetInfo{
    ACEPluginInfo *uexWidgetInfo = [[ACEPluginInfo alloc] initWithName:@"uexWidget"];
    uexWidgetInfo.methods = [@{
                               @"reloadWidgetByAppId":ACE_METHOD_ASYNC,
                               @"startWidget":ACE_METHOD_ASYNC,
                               @"finishWidget":ACE_METHOD_ASYNC,
                               @"removeWidget":ACE_METHOD_ASYNC,
                               @"getOpenerInfo":ACE_METHOD_ASYNC,
                               @"loadApp":ACE_METHOD_ASYNC,
                               @"checkUpdate":ACE_METHOD_ASYNC,
                               @"checkMAMUpdate":ACE_METHOD_ASYNC,
                               @"setPushNotifyCallback":ACE_METHOD_ASYNC,
                               @"getPushInfo":ACE_METHOD_ASYNC,
                               @"setPushInfo":ACE_METHOD_ASYNC,
                               @"delPushInfo":ACE_METHOD_ASYNC,
                               @"getPushState":ACE_METHOD_ASYNC,
                               @"setSpaceEnable":ACE_METHOD_ASYNC,
                               @"setPushState":ACE_METHOD_ASYNC,
                               @"setLogServerIp":ACE_METHOD_ASYNC,
                               @"isAppInstalled":ACE_METHOD_SYNC,
                               @"closeLoading":ACE_METHOD_ASYNC,
                               @"getMBaaSHost":ACE_METHOD_ASYNC,
                               } mutableCopy];
    return uexWidgetInfo;
}

+ (ACEPluginInfo *)uexWidgetOneInfo{
    ACEPluginInfo *uexWidgetOneInfo = [[ACEPluginInfo alloc] initWithName:@"uexWidgetOne"];

    uexWidgetOneInfo.methods = [@{
                                  @"getId":ACE_METHOD_ASYNC,
                                  @"getVersion":ACE_METHOD_ASYNC,
                                  @"getPlatform":ACE_METHOD_SYNC,
                                  @"exit":ACE_METHOD_ASYNC,
                                  @"cleanCache":ACE_METHOD_ASYNC,
                                  @"getWidgetNumber":ACE_METHOD_ASYNC,
                                  @"getWidgetInfo":ACE_METHOD_ASYNC,
                                  @"getCurrentWidgetInfo":ACE_METHOD_ASYNC,
                                  @"getMainWidgetId":ACE_METHOD_ASYNC,
                                  @"setBadgeNumber":ACE_METHOD_ASYNC,
                                  @"getEngineVersion":ACE_METHOD_SYNC,
                                  @"getEngineVersionCode":ACE_METHOD_SYNC,
                                  } mutableCopy];
    uexWidgetOneInfo.properties = [@{@"platformName":@"'iOS'"} mutableCopy];
    return uexWidgetOneInfo;
    
}
+ (ACEPluginInfo *)uexAppCenterInfo {
    ACEPluginInfo *uexAppCenterInfo = [[ACEPluginInfo alloc] initWithName:@"uexAppCenter"];
    uexAppCenterInfo.methods = [@{
                                  @"appCenterLoginResult":ACE_METHOD_ASYNC,
                                  @"downloadApp":ACE_METHOD_ASYNC,
                                  @"loginOut":ACE_METHOD_ASYNC,
                                  @"getSessionKey":ACE_METHOD_ASYNC,
                                  } mutableCopy];
    return uexAppCenterInfo;
}
@end
