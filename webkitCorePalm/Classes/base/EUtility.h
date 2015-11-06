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

#import <Foundation/Foundation.h>
@class EBrowserView;
void PluginLog(NSString *format, ...);

typedef NS_ENUM(NSInteger,uexPluginCallbackType){
    uexPluginCallbackWithJsonString,//回调json字符串（网页端需要首先JSON.parse才能使用）
    uexPluginCallbackWithJsonObject //回调json对象（网页的可以直接使用）
    
};

extern NSString * const cUexPluginCallbackInRootWindow;
extern NSString * const cUexPluginCallbackInFrontWindow;

@interface EUtility : NSObject {
}



/**
 *  @method 回调网页js
 *
 *  @param pluginName   回调的插件名
 *  @param functionName 回调的方法名
 *  @param obj          回调给网页的对象（NSDictionary、NSArray、NSString、nil)
 *  @param type         回调的方式（json字符串还是json对象）
 *  @param targetBrwView 要回调的网页 请传cUexPluginCallbackTargetRootWindow(回调给起始Window）cUexPluginCallbackTargetFrontWindow(回调给最前端Window) 或者(EBrowserView *)实例
 *
 *  @example [EUtility uexPlugin:@"uexDemo" callbackByName:@"cbOpen" withObject:@{@"result":@"success"} andType:uexPluginCallbackWithJsonString inTarget:meBrwView];
 *  @example [EUtility uexPlugin:@"uexDemo" callbackByName:@"cbOpen" withObject:@{@"result":@"success"} andType:uexPluginCallbackWithJsonString inTarget:cUexPluginCallbackInRootWindow];
 *
 *  @author  LiuKangli
 *  @version 2015-09-23
 */
+ (void)uexPlugin:(NSString *)pluginName callbackByName:(NSString *)functionName withObject:(id)obj andType:(uexPluginCallbackType)type inTarget:(id)target;



/**
 *
 *  @method 获取插件的资源包实例
 *
 *
 *  @param pluginName 插件名
 *  @return 插件同名的.bundle文件对应的NSBundle实例
 *
 *  @example NSBundle * mePluginBundle = [EUtility bundleForPlugin:@"uexDemo"];

 */
+(NSBundle *)bundleForPlugin:(NSString *)pluginName;


/**
 *  插件国际化
 *
 *  @param pluginName 插件名
 *  @param key        插件bundle中Localizable.string里声明的字符串key
 *  @param defaultValue 如果有传入第二个参数，即为defaultValue key匹配失败时会返回此值
 *  @return key对应的国际化字符串
 */
+(NSString *)uexPlugin:(NSString *)pluginName localizedString:(NSString *)key,...;

+ (BOOL)isUseSystemLanguage;

+ (NSString *)getAppCanUserLanguage;



+ (NSString*)makeUrl:(NSString*)inBaseStr url:(NSString*)inUrl;
+ (NSURL*)stringToUrl:(NSString*)inString;
+ (BOOL)isValidateOrientation:(UIInterfaceOrientation)inOrientation;
+ (void)setBrwView:(EBrowserView*)inBrwView hidden:(BOOL)isHidden;
+ (CGRect)brwWndFrame:(EBrowserView*)inBrwView;
+ (CGRect)brwViewFrame:(EBrowserView*)inBrwView;
+ (NSURL*)brwViewUrl:(EBrowserView*)inBrwView;
+ (void)brwView:(EBrowserView*)inBrwView addSubview:(UIView*)inSubView;
//2015-5-6
+ (void)brwView:(EBrowserView*)inBrwView addSubviewToScrollView:(UIView*)inSubView;
+ (void)brwView:(EBrowserView*)inBrwView addSubviewToContainer:(UIView*)inSubView WithIndex:(NSInteger)index andIndentifier:(NSString *)identifier;

+ (void)brwView:(EBrowserView*)inBrwView evaluateScript:(NSString*)inScript;
+ (void)brwView:(EBrowserView*)inBrwView presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
+ (BOOL)isIpad;
+ (NSString*)documentPath:(NSString*)inFileName;
+ (NSString*)brwViewWidgetId:(EBrowserView*)inBrwView;
+ (void)brwView:(EBrowserView*)inBrwView presentPopover:(UIPopoverController*)popViewControler FromRect:(CGRect)inRect permittedArrowDirections:(UIPopoverArrowDirection)inDir animated:(BOOL)inAnimated;
+ (NSString *)transferredString:(NSData *)inData;
+ (int)screenWidth;
+ (int)screenHeight;
+ (UIViewController*)brwCtrl:(EBrowserView*)inBrwView;
+ (NSString *)getResPath:(NSString *)fileName;
+ (void)brwView:(EBrowserView*)inBrwView forbidRotate:(BOOL)inForbid;
+ (void)brwView:(EBrowserView*)inBrwView insertSubView:(UIView*)inView aboveSubView:(UIView*)inSiblingSubview;
+ (void)brwView:(EBrowserView*)inBrwView insertSubView:(UIView*)inView belowSubView:(UIView*)inSiblingSubview;
+ (void)brwView:(EBrowserView *)inBrwView sendSubviewToBack:(UIView *)inSubView;
+ (void)brwView:(EBrowserView *)inBrwView bringSubviewToFront:(UIView *)inSubView;
+ (BOOL)brwViewIsFront:(EBrowserView*)inBrwView;
+(UIImage *)rotateImage:(UIImage *)aImage;
+(NSString *)getPlatform;
+(NSString *)deviceIdentifyNo;
+(BOOL)isNetConnected;
+(UIImage *)imageByScalingAndCroppingForSize:(UIImage *)image;
+(NSString*)LogServerIp:(EBrowserView*)inBrwView;
+(NSString*)macAddress;
+ (void)brwView:(EBrowserView*)inBrwView navigationPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
+(UIColor*)ColorFromString:(NSString*)inColor;
+(NSString*)getAbsPath:(EBrowserView*)meBrwView path:(NSString*)inPath;
+(NSInteger)supportedInterfaceOrientations:(EBrowserView*)meBrwView;
+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation brwView:(EBrowserView*)meBrwView;
+(BOOL)appCanDev;
+(void)evaluatingJavaScriptInRootWnd:(NSString*)script_;
+(void)evaluatingJavaScriptInFrontWnd:(NSString*)script_;
+(NSString*)getCachePath:(NSString*)fileName;
+(void)writeLog:(NSString*)inLog;
//20140616 softToken
+(NSString*)md5SoftToken;
+(void)setRootViewGestureRecognizerEnabled:(BOOL)isEnable;





@end
