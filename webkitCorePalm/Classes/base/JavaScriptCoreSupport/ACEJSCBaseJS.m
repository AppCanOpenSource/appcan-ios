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

#define ACE_METHOD_EXEC_OPT_DEFAULT          @(ACEPluginMethodExecuteNormally)









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
        [js appendString:[self javaScriptForMethod:key plugin:plugin.uexName executeOptions:obj]];
    }];
    [plugin.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [js appendString:[self javaScriptForProperty:key plugin:plugin.uexName value:obj]];
    }];
    return js;
}

+ (NSString *)javaScriptForMethod:(NSString *)method plugin:(NSString *)plugin executeOptions:(NSNumber *)options{
    if([[self exceptions]objectForKey:[NSString stringWithFormat:@"%@.%@",plugin,method]]){
        return [[self exceptions]objectForKey:[NSString stringWithFormat:@"%@.%@",plugin,method]];
    }
    return [NSString stringWithFormat:@"%@.%@=function(){var argCount = arguments.length;var args = [];for(var i = 0; i < argCount; i++){args[i] = arguments[i];};return __uex_JSCHandler_.execute('%@','%@',args,argCount,%@);};",plugin,method,plugin,method,options];
}
+ (NSString *)javaScriptForProperty:(NSString *)property plugin:(NSString *)plugin value:(NSString *)value{
    return [NSString stringWithFormat:@"%@.%@=%@;",plugin,property,value];
}

+ (NSDictionary *)exceptions{
    return @{
             };
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
                               @"forward":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"back":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setMultiPopoverFrame":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"evaluateMultiPopoverScript":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"pageForward":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"pageBack":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"reload":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"alert":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"confirm":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"prompt":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"actionSheet":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"open":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"openWithOptions":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setWindowOptions":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"openPresentWindow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setLoadingImagePath":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"toggleSlidingWindow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setSlidingWindowEnabled":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setSlidingWindow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closeByName":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closeAboveWndByName":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"close":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"openSlibing":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"openMultiPopover":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closeMultiPopover":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setSelectedPopOverInMultiWindow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setAutorotateEnable":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closeSlibing":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"showSlibing":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"evaluateScript":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"windowForward":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"windowBack":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"loadObfuscationData":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"toast":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closeToast":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setReportKey":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getState":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"openPopover":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closePopover":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setWindowHidden":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"insertWindowAboveWindow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"insertWindowBelowWindow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setOrientation":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setStatusBarTitleColor":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setWindowScrollbarVisible":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setPopoverFrame":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"evaluatePopoverScript":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"openAd":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setBounce":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getBounce":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setBounceParams":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setRightSwipeEnable":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"topBounceViewRefresh":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"showBounceView":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"hiddenBounceView":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"resetBounceView":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"notifyBounceEvent":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getUrlQuery":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"statusBarNotification":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"preOpenStart":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"preOpenFinish":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"beginAnimition":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setAnimitionDelay":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setAnimitionDuration":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setAnimitionCurve":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"creatPluginViewContainer":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setPageInContainer":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setAnimitionRepeatCount":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setAnimitionAutoReverse":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"makeAlpha":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"makeTranslation":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"makeScale":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"makeRotate":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"commitAnimition":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"insertPopoverAbovePopover":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"insertPopoverBelowPopover":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"bringPopoverToFront":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"sendPopoverToBack":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"insertAbove":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"insertBelow":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"bringToFront":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"sendToBack":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setWindowFrame":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setMultilPopoverFlippingEnbaled":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getSlidingWindowState":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"postGlobalNotification":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"onGlobalNotification":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"subscribeChannelNotification":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"publishChannelNotification":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"disturbLongPressGesture":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setSwipeCloseEnable":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setWebViewScrollable":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"createProgressDialog":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"destroyProgressDialog":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"hideStatusBar":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"showStatusBar":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"createPluginViewContainer":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closePluginViewContainer":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"log":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getWidth":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getHeight":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"putLocalData":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getLocalData":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"publishChannelNotificationForJson":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setIsSupportSwipeCallback":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"share":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getWindowName":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setPopoverVisibility":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setInlineMediaPlaybackEnable":ACE_METHOD_EXEC_OPT_DEFAULT,
#ifdef DEBUG
                               @"test":ACE_METHOD_EXEC_OPT_DEFAULT,
#endif
                               } mutableCopy];
    return uexWindowInfo;
}

+ (ACEPluginInfo *)uexWidgetInfo{
    ACEPluginInfo *uexWidgetInfo = [[ACEPluginInfo alloc] initWithName:@"uexWidget"];
    uexWidgetInfo.methods = [@{
                               @"reloadWidgetByAppId":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"startWidget":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"startWidgetWithConfig":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"finishWidget":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"removeWidget":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getOpenerInfo":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"loadApp":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"checkUpdate":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"checkMAMUpdate":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setPushNotifyCallback":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getPushInfo":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setPushInfo":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"delPushInfo":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"getPushState":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setSpaceEnable":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setPushState":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"setLogServerIp":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"isAppInstalled":ACE_METHOD_EXEC_OPT_DEFAULT,
                               @"closeLoading":ACE_METHOD_EXEC_OPT_DEFAULT,
                               } mutableCopy];
    return uexWidgetInfo;
}

+ (ACEPluginInfo *)uexWidgetOneInfo{
    ACEPluginInfo *uexWidgetOneInfo = [[ACEPluginInfo alloc] initWithName:@"uexWidgetOne"];

    uexWidgetOneInfo.methods = [@{
                                  @"getId":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getVersion":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getPlatform":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"exit":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"cleanCache":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getWidgetNumber":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getWidgetInfo":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getCurrentWidgetInfo":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getMainWidgetId":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"setBadgeNumber":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getEngineVersion":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getEngineVersionCode":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"restart":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  } mutableCopy];
    uexWidgetOneInfo.properties = [@{@"platformName":@"'iOS'"} mutableCopy];
    return uexWidgetOneInfo;
    
}
+ (ACEPluginInfo *)uexAppCenterInfo {
    ACEPluginInfo *uexAppCenterInfo = [[ACEPluginInfo alloc] initWithName:@"uexAppCenter"];
    uexAppCenterInfo.methods = [@{
                                  @"appCenterLoginResult":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"downloadApp":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"loginOut":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  @"getSessionKey":ACE_METHOD_EXEC_OPT_DEFAULT,
                                  } mutableCopy];
    return uexAppCenterInfo;
}
@end
