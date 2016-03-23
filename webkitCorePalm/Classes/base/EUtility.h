/*
 *  Copyright (C) 2016 The AppCan Open Source Project.
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

@interface EUtility : NSObject


#pragma mark - JavaScript Callback JS回调的相关方法
#pragma mark 回调网页JS
/**
 *  @method 回调网页js
 *
 *  @param pluginName   回调的插件名
 *  @param functionName 回调的方法名
 *  @param obj          回调给网页的对象（NSDictionary、NSArray、NSString、NSNumber,nil)
 *  @param type         回调的方式（json字符串还是json对象）
 *  @param targetBrwView 要回调的网页 请传cUexPluginCallbackTargetRootWindow(回调给起始Window）cUexPluginCallbackTargetFrontWindow(回调给最前端Window) 或者(EBrowserView *)实例
 *
 *  @example [EUtility uexPlugin:@"uexDemo" callbackByName:@"cbOpen" withObject:@{@"result":@"success"} andType:uexPluginCallbackWithJsonString inTarget:self.meBrwView];//,回调给当前网页
 *  @example [EUtility uexPlugin:@"uexDemo" callbackByName:@"cbOpen" withObject:@{@"result":@"success"} andType:uexPluginCallbackWithJsonString inTarget:cUexPluginCallbackInRootWindow];//回调给root窗口
 *
 */
+ (void)uexPlugin:(NSString *)pluginName callbackByName:(NSString *)functionName withObject:(id)obj andType:(uexPluginCallbackType)type inTarget:(id)target;

#pragma mark 在指定网页中执行JS脚本

/**
 *  在指定网页中执行JS脚本
 *
 *  @param inBrwView 要执行JS的网页
 *  @param inScript  需要执行的JS脚本
 */
+ (void)brwView:(EBrowserView*)inBrwView evaluateScript:(NSString*)inScript;

#pragma mark 在主窗口中执行JS脚本
/**
 *  在主窗口中执行JS脚本
 *
 *  @param script 需要执行的JS脚本
 */
+ (void)evaluatingJavaScriptInRootWnd:(NSString*)script;

#pragma mark 在最顶端的窗口中执行JS脚本

/**
 *  在最顶端的窗口中执行JS脚本
 *
 *  @param script 需要执行的JS脚本
 */
+ (void)evaluatingJavaScriptInFrontWnd:(NSString*)script;


#pragma mark - Plugin Bundle 插件资源Bundle的相关方法

#pragma mark 获取插件的资源包实例
/**
 *
 *  @method 获取插件的资源包实例
 *
 *  @param pluginName 插件名
 *  @return 插件同名的资源文件对应的NSBundle实例
 *
 *  @example NSBundle * mePluginBundle = [EUtility bundleForPlugin:@"uexDemo"];
 */
+ (NSBundle *)bundleForPlugin:(NSString *)pluginName;

#pragma mark 插件国际化
/**
 *  插件国际化
 *
 *  @param pluginName 插件名
 *  @param key        插件bundle中Localizable.string里声明的字符串key
 *  @param defaultValue 如果有传入第二个参数，即为defaultValue key匹配失败时会返回此值
 *  @return key对应的国际化字符串
 */
+ (NSString *)uexPlugin:(NSString *)pluginName localizedString:(NSString *)key,...;

#pragma mark - View Operation 网页View级别的操作

#pragma mark 在指定网页窗口中添加View
/**
 *  在指定网页窗口中添加View
 *  @note 被添加的view不会跟随网页滑动
 *  @param inBrwView 指定的网页对象
 *  @param inSubView 被添加的View
 */
+ (void)brwView:(EBrowserView*)inBrwView addSubview:(UIView*)inSubView;
#pragma mark 在指定网页中添加View
/**
 *  在指定网页中添加View
 *  @note 被添加的view可以跟随网页滑动
 *  @param inBrwView 指定的网页对象
 *  @param inSubView 被添加的View
 */
+ (void)brwView:(EBrowserView*)inBrwView addSubviewToScrollView:(UIView*)inSubView;


#pragma mark - ViewController Operation 网页ViewController级别的操作
#pragma mark 获取指定网页的viewController
/**
 *  获取指定网页的viewController
 *
 *  @param inBrwView 网页对象
 *
 *  @return 网页对象的viewController
 */
+ (UIViewController*)brwCtrl:(EBrowserView*)inBrwView;

#pragma mark 在指定的网页中present一个viewController
/**
 *  在指定的网页中present一个viewController
 *  
 *  @warning 此方法仅限3.3引擎。旧引擎请用+ (void)brwView:(EBrowserView*)inBrwView presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
 *
 *  @param inBrwView               指定的网页对象
 *  @param viewControllerToPresent 被present的viewController
 *  @param flag                    present时是否需要动画
 *  @param completion              present完成后的回调block
 */
+ (void)brwView:(EBrowserView *)inBrwView presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;

#pragma mark 判断当前设备是否是iPad
/**
 *  判断当前设备是否是iPad
 */
+ (BOOL)isIpad;

#pragma mark 在指定的网页中present一个UIPopoverController

/**
 *  在指定的网页中present一个UIPopoverController
 *  @note 此接口应在iPad中才会被调用，使用前需先判断当前设备是否是iPad
 *
 *  @param inBrwView         指定的网页
 *  @param popViewController 被present的popViewController
 *  @param inRect            popViewController的frame
 *  @param inDir             UIPopoverArrowDirection
 *  @param inAnimated        present时是否需要动画
 */
+ (void)brwView:(EBrowserView*)inBrwView presentPopover:(UIPopoverController*)popViewController FromRect:(CGRect)inRect permittedArrowDirections:(UIPopoverArrowDirection)inDir animated:(BOOL)inAnimated;


#pragma mark - Tools 实用工具
#pragma mark 解析HTML颜色字符串获取UIColor
/**
 *  解析HTML颜色字符串获取UIColor
 *
 *  @param HTMLColor HTML颜色字符串 目前支持#123 #112233 #11223344 rgb(x,y,z) rgba(x,y,z,w)
 *
 *  @return 获取到的UIColor
 *  @warning 如果解析失败，会返回nil;
 */
+ (UIColor *)colorFromHTMLString:(NSString *)HTMLColor;


#pragma mark 解析网页中的协议路径
/**
 *  解析网页中的协议路径
 *
 *  @note 只会处理 wgt://,res://,wgts://,wgtroot://,file://, 开头的网页协议路径。其他路径会原样返回。
 *  @param meBrwView 网页对象
 *  @param inPath    协议路径
 *
 *  @return 解析后的绝对路径
 */
+ (NSString*)getAbsPath:(EBrowserView*)meBrwView path:(NSString*)inPath;


#pragma mark 判断当前是否是AppCan IDE测试环境(即本地打包环境)
/**
 *  判断当前是否是AppCan IDE测试环境(即本地打包环境)
 *
 *  @return 是AppCan IDE测试环境时 返回YES，否则返回NO
 */
+ (BOOL)appCanDev;


#pragma mark 获取网页所在的widget的WidgetId
/**
 *  获取网页所在的widget的WidgetId
 *
 *  @param inBrwView 网页对象
 *
 *  @return WidgetId
 */
+ (NSString*)brwViewWidgetId:(EBrowserView*)inBrwView;


#pragma mark 获取网页的当前URL
/**
 *  获取网页的当前URL
 *
 *  @param inBrwView 指定的网页对象
 *
 *  @return URL
 */
+ (NSURL*)brwViewUrl:(EBrowserView*)inBrwView;


@end

#pragma mark - 引擎私有方法
@interface EUtility(Private)
/**
 *  获取插件的语言包实例
 *
 *  @param pluginName 插件名
 *
 *  @return 插件同名的语言资源包对应的NSBundle实例
 */
+ (NSBundle *)languageBundleForPlugin:(NSString *)pluginName;

+ (BOOL)isUseSystemLanguage;
+ (NSString *)getAppCanUserLanguage;
+ (void)brwView:(EBrowserView*)inBrwView addSubviewToContainer:(UIView*)inSubView WithIndex:(NSInteger)index andIndentifier:(NSString *)identifier;
+ (void)setBrwView:(EBrowserView*)inBrwView hidden:(BOOL)isHidden;
+ (CGRect)brwWndFrame:(EBrowserView*)inBrwView;
+ (CGRect)brwViewFrame:(EBrowserView*)inBrwView;
+ (NSString*)makeUrl:(NSString*)inBaseStr url:(NSString*)inUrl;
+ (NSURL*)stringToUrl:(NSString*)inString;
+ (BOOL)isValidateOrientation:(UIInterfaceOrientation)inOrientation;
+ (NSString*)documentPath:(NSString*)inFileName;
+ (NSString *)transferredString:(NSData *)inData;
+ (int)screenWidth;
+ (int)screenHeight;
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
+(NSString*)md5SoftToken;
+(NSString*)getCachePath:(NSString*)fileName;
@end

#pragma mark - 已废弃的方法

@interface EUtility(Deprecated)
+(UIColor*)ColorFromString:(NSString*)inColor;
+(void)setRootViewGestureRecognizerEnabled:(BOOL)isEnable;
+(void)writeLog:(NSString*)inLog;
+(NSInteger)supportedInterfaceOrientations:(EBrowserView*)meBrwView;
+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation brwView:(EBrowserView*)meBrwView;
+(NSString*)macAddress;
+ (void)brwView:(EBrowserView*)inBrwView navigationPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
+ (void)brwView:(EBrowserView*)inBrwView presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;
@end


