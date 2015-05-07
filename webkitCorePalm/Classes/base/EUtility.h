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
@interface EUtility : NSObject {
}
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
