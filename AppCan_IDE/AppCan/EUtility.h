//
//  EUtility.h
//  WBPalm
//
//  Created by 邹 达 on 12-4-19.
//  Copyright 2012 zywx. All rights reserved.
//

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
@end
