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
#import "JSON.h"
#import "EUtility.h"
#import "BUtility.h"
#import "EBrowserView.h"
#import "EBrowserWindow.h"
#import "WWidget.h"
#import "EBrowserController.h"
#import "EBrowserWindowContainer.h"
#import "EBrowserWidgetContainer.h"
#import "EBrowserMainFrame.h"
#import "BStatusBarWindow.h"
#import <CommonCrypto/CommonDigest.h>
#import "WidgetOneDelegate.h"
#import "ACEDrawerViewController.h"
#import "ACEPluginViewContainer.h"
#import "ACEBrowserView.h"
#import "ACEJSCInvocation.h"
#import "ACEUtils.h"
#import "ACESubMultiPopScrollView.h"

void PluginLog (NSString *format, ...) {
    #ifdef Plugin_OUTPUT_LOG_CONSOLE
	va_list args;
	va_start(args,format);
	va_end(args);
	NSString *zdFormat = @"~~~~Plugin~~~~: ";
	zdFormat = [zdFormat stringByAppendingString:format];
	NSLogv(zdFormat, args);
    #endif
}




@implementation EUtility

+ (void)browserView:(EBrowserView *)brwView
callbackWithFunctionKeyPath:(NSString *)JSKeyPath
          arguments:(NSArray *)arguments
         completion:(void (^)(JSValue *))completion{
    __block BOOL errorOccured = YES;
    @onExit{
        if(errorOccured && completion){
            completion(nil);
        }
    };
    if (!brwView || !JSKeyPath) {
        return;
    }
    JSContext *ctx = brwView.meBrowserView.JSContext;
    if (!ctx || ![ctx isKindOfClass:[JSContext class]]) {
        return;
    }
    JSValue *func = nil;
    NSArray<NSString *> *components = [JSKeyPath componentsSeparatedByString:@"."];
    for ( int i = 0; i < components.count; i++) {
        if (!func) {
            func = [ctx objectForKeyedSubscript:components[i]];
        }else{
            func = [func objectForKeyedSubscript:components[i]];
        }
    }
    if (!func || [ACEJSCInvocation JSTypeOf:func] != ACEJSValueTypeFunction) {
        return;
    }
    errorOccured = NO;
    ACEJSCInvocation *invocation = [ACEJSCInvocation invocationWithFunction:func
                                                                  arguments:arguments
                                                          completionHandler:completion];
    [invocation invokeOnMainThread];
}


//2015-09-23 by lkl
+ (void)uexPlugin:(NSString *)pluginName callbackByName:(NSString *)functionName withObject:(id)obj andType:(uexPluginCallbackType)type inTarget:(id)target{
    
    BOOL isObject = [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]];
    NSString * result=[obj JSONFragment];
    
    if (type == uexPluginCallbackWithJsonString && isObject) {
        result = [result JSONFragment];
    }
    if (!obj || [obj isEqual:[NSNull null]]) {
        result = @"(undefined)";
    }
    
    NSString * callbackString = [NSString stringWithFormat:@"if(%@.%@){%@.%@(%@);}",pluginName,functionName,pluginName,functionName,result];
    
    if([target isEqual:cUexPluginCallbackInRootWindow]){
        [self evaluatingJavaScriptInRootWnd:callbackString];
    }else if([target isEqual:cUexPluginCallbackInFrontWindow]){
        [self evaluatingJavaScriptInFrontWnd:callbackString];
    }else if(target && [target isKindOfClass:[EBrowserView class]]){
        EBrowserView * inBrwView=(EBrowserView *)target;
        [self brwView:inBrwView evaluateScript:callbackString];
    }
}


+(NSBundle *)bundleForPlugin:(NSString *)pluginName{
    NSString *bundleName = [NSString stringWithFormat:@"%@.bundle",pluginName];
    //检测是否加载了动态库插件
    NSString *dynamicFrameworkPath=[[BUtility dynamicPluginFrameworkFolderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.framework",pluginName]];
    NSBundle *dynamicFramework=[NSBundle bundleWithPath:dynamicFrameworkPath];
    //测试用,检测res://目录下的framework
    if(!dynamicFramework){
        dynamicFrameworkPath=[BUtility wgtResPath:[NSString stringWithFormat:@"res://%@.framework",pluginName]];
        dynamicFramework=[NSBundle bundleWithPath:dynamicFrameworkPath];
    }

    if(dynamicFramework && [dynamicFramework isLoaded]){
        //如果有动态库插件，优先查看动态库中是否有bundle
        NSBundle *dynamicBundle=[NSBundle bundleWithPath:[dynamicFramework pathForResource:pluginName ofType:@"bundle"]];
        if(dynamicBundle){
        //如果有则返回
            return dynamicBundle;
        }
    }
    //返回静态库的bundle
    NSString *bundlePath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:bundleName];
    return [NSBundle bundleWithPath:bundlePath];
    
}



+(NSString *)uexPlugin:(NSString *)pluginName localizedString:(NSString *)key,...{
    
    NSBundle *pluginBundle = [self languageBundleForPlugin:pluginName];
    if(!pluginBundle){
        return key;
    }
    NSString *defaultValue=@"";
    va_list argList;
    va_start(argList,key);
    id arg=va_arg(argList,id);
    //if(arg && [arg isKindOfClass:[NSString class]]){
    if(arg){
        defaultValue=arg;
    }
    va_end(argList);
    return [pluginBundle localizedStringForKey:key value:defaultValue table:nil];
}


+ (UIColor *)colorFromHTMLString:(NSString *)HTMLColor{
        NSString *colorString=[[HTMLColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    UIColor *resultColor=nil;
    if([self parseColor:&resultColor fromHexString:colorString]){
        return resultColor;
    }
    if([self parseColor:&resultColor fromRGBString:colorString]){
        return resultColor;
    }
    return resultColor;
}
+ (BOOL)parseColor:(UIColor **)color fromHexString:(NSString *)colorString{
    if(![colorString hasPrefix:@"#"]){
        return NO;
    }
    unsigned int r,g,b,a;
    NSRange range;
    NSMutableArray *colorArray=[NSMutableArray arrayWithCapacity:4];
    switch ([colorString length]) {
        case 4:{//"#123"型字符串
            [colorArray addObject:@"ff"];
            for(int k=0;k<3;k++){
                range.location=k+1;
                range.length=1;
                NSMutableString *tmp=[[colorString substringWithRange:range] mutableCopy];
                [tmp  appendString:tmp];
                [colorArray addObject:tmp];
                
            }
            break;
        }
        case 7:{//"#112233"型字符串
            [colorArray addObject:@"ff"];
            for(int k=0;k<3;k++){
                range.location=2*k+1;
                range.length=2;
                [colorArray addObject:[colorString substringWithRange:range]];
                
            }
            break;
        }
        case 9:{//"#11223344"型字符串
            for(int k=0;k<4;k++){
                range.location=2*k+1;
                range.length=2;
                [colorArray addObject:[colorString substringWithRange:range]];
            }
            break;
        }
        default:{
            return NO;
            break;
        }
    }
    [[NSScanner scannerWithString:colorArray[0]] scanHexInt:&a];
    [[NSScanner scannerWithString:colorArray[1]] scanHexInt:&r];
    [[NSScanner scannerWithString:colorArray[2]] scanHexInt:&g];
    [[NSScanner scannerWithString:colorArray[3]] scanHexInt:&b];
    *color=[UIColor colorWithRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:(float)a/255.0];
    if(!*color){
        return NO;
    }
    return YES;
}

+ (BOOL)parseColor:(UIColor **)color fromRGBString:(NSString *)colorString{
    NSArray *rgbArray=nil;
    if ([colorString hasPrefix:@"rgb("]&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(4, [colorString length] -5)];
        rgbArray=[colorString componentsSeparatedByString:@","];
    }
    if ([colorString hasPrefix:@"rgba("]&&[colorString hasSuffix:@")"]){
        colorString=[colorString substringWithRange:NSMakeRange(5, [colorString length] -6)];
        rgbArray=[colorString componentsSeparatedByString:@","];
    }
    if(!rgbArray|| [rgbArray count]<3){
        return NO;
    }
    CGFloat alpha=1;
    if([rgbArray count]>3 && [rgbArray[3] isKindOfClass:[NSString class]]){
        alpha=[[rgbArray[3] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] floatValue];
    }
    *color=[UIColor colorWithRed:[self rgbValueFromString:rgbArray[0]]
                           green:[self rgbValueFromString:rgbArray[1]]
                            blue:[self rgbValueFromString:rgbArray[2]]
                           alpha:alpha];
    if(!*color){
        return NO;
    }
    return YES;
    
}
+ (CGFloat)rgbValueFromString:(NSString *)colorInfo{
    colorInfo=[colorInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    CGFloat value=0;
    if([colorInfo hasSuffix:@"%"]){
        colorInfo=[colorInfo substringWithRange:NSMakeRange(0, [colorInfo length] - 1)];
        return [colorInfo floatValue]/100.0;
    }
    value=[colorInfo floatValue];
    if(value>0 && value <1){
        return value;
    }
    return value/255.0;
}




+ (NSURL*)brwViewUrl:(EBrowserView*)inBrwView {
	return [inBrwView.request URL];
}

+ (void)brwView:(EBrowserView*)inBrwView addViewToCurrentMultiPop:(UIView*)inSubView WithPosition:(NSInteger)position{
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    [ud setValue:[NSString stringWithFormat:@"%ld",(long)position]forKey:@"addViewToCurrentMultiPop_position"];
    
    NSLog(@"addViewToCurrentMultiPop==>>inSubView=%@",inSubView);
    
    ACESubMultiPopScrollView *subMultiPopView = [[ACESubMultiPopScrollView alloc] initWithFrame:inSubView.frame];
    
    [subMultiPopView addSubview:inSubView];
    
    NSLog(@"addViewToCurrentMultiPop==>>subMultiPopView=%@",subMultiPopView);
    
    [inBrwView.superview addSubview:subMultiPopView];
    
    CGRect multiPopFrame = inBrwView.frame;
    
    CGRect subViewFrame = subMultiPopView.frame;
    
    subViewFrame.origin.x = multiPopFrame.origin.x;
    
    if (position == 0) {
        
        multiPopFrame.origin.y = CGRectGetMaxY(subViewFrame) + 2;
        
        multiPopFrame.size.height = multiPopFrame.size.height - multiPopFrame.origin.y;
        
        subMultiPopView.frame = subViewFrame;
        
        NSLog(@"addViewToCurrentMultiPop==>>subMultiPopView添加到头部时=%@",subMultiPopView);
        
    }else{
        
        subViewFrame.origin.y  = CGRectGetMaxY(multiPopFrame) - subMultiPopView.frame.size.height;
        
        subMultiPopView.frame = subViewFrame;
        
        multiPopFrame.size.height = subMultiPopView.frame.origin.y - 2;
        
        NSLog(@"addViewToCurrentMultiPop==>>subMultiPopView添加到底部时=%@",subMultiPopView);
        
    }
    
    inBrwView.frame = multiPopFrame;
    
    NSLog(@"addViewToCurrentMultiPop==>>inBrwView.frame=%@",inBrwView);
    
}


+ (void)brwView:(EBrowserView*)inBrwView addSubview:(UIView*)inSubView {
	[inBrwView.meBrwWnd addSubview:inSubView];
}
+ (void)brwView:(EBrowserView*)inBrwView addSubviewToScrollView:(UIView*)inSubView{
    [inBrwView.mScrollView addSubview:inSubView];
}
+ (void)brwView:(EBrowserView *)inBrwView presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    [inBrwView.meBrwCtrler presentViewController:viewControllerToPresent animated:flag completion:completion];
}

+(void)doJsCB:(NSDictionary*)dict{
    EBrowserView *brwView =(EBrowserView*)[dict objectForKey:@"Brw"];
    NSString *inScript =[dict objectForKey:@"CBStr"];
    [brwView stringByEvaluatingJavaScriptFromString:inScript];
}
+ (void)brwView:(EBrowserView*)inBrwView evaluateScript:(NSString*)inScript {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:inBrwView, @"Brw",inScript,@"CBStr",nil];
    [self performSelectorOnMainThread:@selector(doJsCB:) withObject:dict waitUntilDone:NO];
}



+ (BOOL)isIpad {
	return [BUtility isIpad];
}



+ (NSString*)brwViewWidgetId:(EBrowserView*)inBrwView {
	return inBrwView.mwWgt.appId;
}

+ (void)brwView:(EBrowserView*)inBrwView presentPopover:(UIPopoverController*)popViewControler FromRect:(CGRect)inRect permittedArrowDirections:(UIPopoverArrowDirection)inDir animated:(BOOL)inAnimated {
	[popViewControler presentPopoverFromRect:inRect inView:inBrwView permittedArrowDirections:inDir animated:inAnimated];
}


+ (UIViewController*)brwCtrl:(EBrowserView*)inBrwView {
	return inBrwView.meBrwCtrler;
}


+(NSString*)getAbsPath:(EBrowserView*)meBrwView path:(NSString*)inPath{
    return [BUtility getAbsPath:meBrwView path:inPath];
}

+(BOOL)appCanDev{
    return [BUtility getAppCanDevMode];
}
+ (EBrowserView *)rootBrwoserView{
    return theApp.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer.meRootBrwWnd.meBrwView;
}

+ (EBrowserView *)topBrowserView{
    return [theApp.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer.meRootBrwWndContainer aboveWindow].meBrwView;
}

+(void)evaluatingJavaScriptInRootWnd:(NSString*)script_{
	[BUtility evaluatingJavaScriptInRootWnd:script_];
}

+(void)evaluatingJavaScriptInFrontWnd:(NSString*)script_{
	[BUtility evaluatingJavaScriptInFrontWnd:script_];
}


@end


@implementation EUtility (Private)
+ (NSBundle *)languageBundleForPlugin:(NSString *)pluginName{
    if ([EUtility isUseSystemLanguage]){
        return [self bundleForPlugin:pluginName];
    }else{
        NSString * userLanguage = [EUtility getAppCanUserLanguage];
        
        return [NSBundle bundleWithPath:[[self bundleForPlugin:pluginName] pathForResource:userLanguage ofType:@"lproj"]];
    }
}
+(NSString*)makeUrl:(NSString*)inBaseStr url:(NSString*)inUrl {
    return [BUtility makeUrl:inBaseStr url:inUrl];
}



+(BOOL)isValidateOrientation:(UIInterfaceOrientation)inOrientation {
    return [BUtility isValidateOrientation:inOrientation];
}

+ (NSString*)documentPath:(NSString*)inFileName {
    return [BUtility getDocumentsPath:inFileName];
}
+(NSURL*)stringToUrl:(NSString*)inString {
    return [BUtility stringToUrl:inString];
}
+ (void)brwView:(EBrowserView *)inBrwView addSubviewToContainer:(UIView *)inSubView WithIndex:(NSInteger)index andIndentifier:(NSString *)identifier {
    for (UIView * subView in [inBrwView.meBrwWnd subviews]) {
        if ([subView isKindOfClass:[ACEPluginViewContainer class]]) {
            ACEPluginViewContainer * container = (ACEPluginViewContainer *)subView;
            if ([container.containerIdentifier isEqualToString:identifier]) {
                CGRect tmpRect = inSubView.frame;
                tmpRect.origin.y = 0;
                tmpRect.origin.x = index*tmpRect.size.width;
                inSubView.frame = tmpRect;
                [container addSubview:inSubView];
                if (container.maxIndex < index) {
                    container.maxIndex = index;
                    [container setContentSize:CGSizeMake(container.frame.size.width * (index + 1), container.frame.size.height)];
                }
                return;
            }
        }
    }
    [inBrwView.meBrwWnd addSubview:inSubView];
}
+ (BOOL)isUseSystemLanguage {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    NSString * userLanguag = [ud valueForKey:@"AppCanUserLanguage"];
    
    if (!userLanguag || userLanguag == nil || userLanguag.length == 0) {
        
        return YES;
        
    }
    
    return NO;
    
}

+ (NSString *)getAppCanUserLanguage {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    NSString * userLanguag = [ud valueForKey:@"AppCanUserLanguage"];
    
    return userLanguag;
    
}
+ (void)setBrwView:(EBrowserView*)inBrwView hidden:(BOOL)isHidden {
    inBrwView.hidden = isHidden;
}

+ (CGRect)brwWndFrame:(EBrowserView*)inBrwView {
    return inBrwView.meBrwWnd.frame;
}

+ (CGRect)brwViewFrame:(EBrowserView*)inBrwView {
    return inBrwView.frame;
}
+ (NSString *)transferredString:(NSData *)inData {
    return [BUtility getTransferredString:inData];
}


+ (int)screenWidth {
    return [BUtility getScreenWidth];
}

+ (int)screenHeight {
    return [BUtility getScreenHeight];
}
+ (NSString *)getResPath:(NSString *)fileName {
    return [BUtility getResPath:fileName];
}

+ (void)brwView:(EBrowserView*)inBrwView forbidRotate:(BOOL)inForbid {
    if (inForbid == YES) {
        inBrwView.meBrwCtrler.mFlag |= F_EBRW_CTRL_FLAG_FORBID_ROTATE;
    } else {
        inBrwView.meBrwCtrler.mFlag &= ~F_EBRW_CTRL_FLAG_FORBID_ROTATE;
    }
}

+ (void)brwView:(EBrowserView*)inBrwView insertSubView:(UIView*)inView aboveSubView:(UIView*)inSiblingSubview {
    [inBrwView.meBrwWnd insertSubview:inView aboveSubview:inSiblingSubview];
}

+ (void)brwView:(EBrowserView*)inBrwView insertSubView:(UIView*)inView belowSubView:(UIView*)inSiblingSubview {
    [inBrwView.meBrwWnd insertSubview:inView belowSubview:inSiblingSubview];
}

+ (void)brwView:(EBrowserView *)inBrwView sendSubviewToBack:(UIView *)inSubView {
    [inBrwView.meBrwWnd sendSubviewToBack:inSubView];
}

+ (void)brwView:(EBrowserView *)inBrwView bringSubviewToFront:(UIView *)inSubView {
    [inBrwView.meBrwWnd bringSubviewToFront:inSubView];
}

+ (BOOL)brwViewIsFront:(EBrowserView*)inBrwView {
    UIView *brwWndContainer = inBrwView.meBrwWnd.superview;
    if (!brwWndContainer) {
        return NO;
    }
    NSArray *brwWnds = [brwWndContainer subviews];
    UIView *frontBrwWnd = [brwWnds objectAtIndex:([brwWnds count] - 1)];
    if (frontBrwWnd == inBrwView.meBrwWnd) {
        return YES;
    }
    return NO;
}
+(UIImage *)rotateImage:(UIImage *)aImage{
    return [BUtility rotateImage:aImage];
}
+(NSString *)getPlatform{
    return  [BUtility platform];
}
+(NSString *)deviceIdentifyNo{
    return [BUtility getDeviceIdentifyNo];
}
+(BOOL)isNetConnected{
    return [BUtility isConnected];
}
+(UIImage *)imageByScalingAndCroppingForSize:(UIImage *)image{
    return [BUtility imageByScalingAndCroppingForSize:image];
}
+(NSString*)LogServerIp:(EBrowserView*)inBrwView{
    return inBrwView.mwWgt.logServerIp;
}

//20140616 softToken
+(NSString*)md5SoftToken{
    NSData *mac = [[EUtility macAddress] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *Others = [@":" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *uuid = [[EUtility macAddress] dataUsingEncoding:NSUTF8StringEncoding];
    NSString * appKey=[BUtility appKey];
    NSData *appkeyData = [appKey dataUsingEncoding:NSUTF8StringEncoding];
    
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    
    CC_MD5_Update(&md5, [mac bytes], [mac length]);
    CC_MD5_Update(&md5, [Others bytes], [Others length]);
    CC_MD5_Update(&md5, [Others bytes], [Others length]);
    CC_MD5_Update(&md5, [uuid bytes], [uuid length]);
    CC_MD5_Update(&md5, [Others bytes], [Others length]);
    CC_MD5_Update(&md5, [Others bytes], [Others length]);
    CC_MD5_Update(&md5, [appkeyData bytes], [appkeyData length]);
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    NSString *md5Str = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        digest[0], digest[1], digest[2], digest[3],
                        digest[4], digest[5], digest[6], digest[7],
                        digest[8], digest[9], digest[10], digest[11],
                        digest[12], digest[13], digest[14], digest[15]];
    
    NSString * softToken = [[NSString alloc] initWithString:[md5Str lowercaseString]];
    
    return softToken;
}
+(NSString*)getCachePath:(NSString*)fileName{
    return [BUtility getCachePath:fileName];
}

@end





@implementation EUtility (Deprecated)

NSString * const cUexPluginCallbackInRootWindow = @"uexPluginCallbackInRootWindow";
NSString * const cUexPluginCallbackInFrontWindow = @"uexPluginCallbackInFrontWindow";

+(UIColor*)ColorFromString:(NSString*)inColor{
    UIColor *color =[UIColor blackColor];
    if (inColor && inColor.length != 0) {
        BGColor bgColor = [BUtility bgColorFromNSString:inColor];
        color = [UIColor colorWithRed:bgColor.rgba.r/255.0f green:bgColor.rgba.g/255.0f blue:bgColor.rgba.b/255.0f alpha:bgColor.rgba.a/255.0f];
    }
    return color;
}
+(void)setRootViewGestureRecognizerEnabled:(BOOL)isEnable
{

}
+(void)writeLog:(NSString*)inLog{
    return [BUtility writeLog:inLog];
}

+(NSInteger)supportedInterfaceOrientations:(EBrowserView*)meBrwView{
    int orientation = 0;
    EBrowserWindowContainer *aboveWndContainer = [meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
    if (aboveWndContainer) {
        if ((meBrwView.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
            orientation |= UIInterfaceOrientationMaskPortrait;
        }
        if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
            orientation |= UIInterfaceOrientationMaskPortraitUpsideDown;
        }
        if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
            orientation |= UIInterfaceOrientationMaskLandscapeLeft;
        }
        if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
            orientation |= UIInterfaceOrientationMaskLandscapeRight;
        }
    }
    return orientation;
}

+(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation brwView:(EBrowserView*)meBrwView{
    EBrowserWindowContainer *aboveWndContainer = [meBrwView.meBrwCtrler.meBrwMainFrm.meBrwWgtContainer aboveWindowContainer];
    if (aboveWndContainer) {
        EBrowserWindow *eBrwWnd = [aboveWndContainer aboveWindow];
        if (eBrwWnd && eBrwWnd.meBottomSlibingBrwView && ((eBrwWnd.meBottomSlibingBrwView.mFlag & F_EBRW_VIEW_FLAG_FORBID_ROTATE) == F_EBRW_VIEW_FLAG_FORBID_ROTATE)) {
            return NO;
        }
        if ((meBrwView.meBrwCtrler.mFlag & F_EBRW_CTRL_FLAG_FORBID_ROTATE) == F_EBRW_CTRL_FLAG_FORBID_ROTATE) {
            return NO;
        }
        if (meBrwView.meBrwCtrler.meBrwMainFrm.mSBWnd && (meBrwView.meBrwCtrler.meBrwMainFrm.mSBWnd.hidden == NO)) {
            return NO;
        }
        switch (toInterfaceOrientation) {
            case UIInterfaceOrientationPortrait:
                if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT) {
                    return YES;
                }
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) == F_DEVICE_INFO_ID_ORIENTATION_PORTRAIT_UPSIDEDOWN) {
                    return YES;
                }
                break;
            case UIInterfaceOrientationLandscapeLeft:
                if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_LEFT) {
                    return YES;
                }
                break;
            case UIInterfaceOrientationLandscapeRight:
                if ((aboveWndContainer.mwWgt.orientation & F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) == F_DEVICE_INFO_ID_ORIENTATION_LANDSCAPE_RIGHT) {
                    return YES;
                }
                break;
            default:
                break;
        }
    }
    NSString *oritent =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIInterfaceOrientation"] ;
    if ([oritent isEqualToString:@"UIInterfaceOrientationPortraitUpsideDown"]) {
        return (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }else if ([oritent isEqualToString:@"UIInterfaceOrientationLandscapeLeft"]) {
        return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft);
    }if ([oritent isEqualToString:@"UIInterfaceOrientationLandscapeRight"]) {
        return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}
+(NSString*)macAddress{
    return [BUtility macAddress];
}

+ (void)brwView:(EBrowserView*)inBrwView presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [inBrwView.meBrwCtrler presentModalViewController:modalViewController animated:animated];

}

+ (void)brwView:(EBrowserView*)inBrwView navigationPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [inBrwView.meBrwCtrler.navigationController presentModalViewController:modalViewController animated:animated];
}



@end

