/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

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
+(NSString*)makeUrl:(NSString*)inBaseStr url:(NSString*)inUrl {
	return [BUtility makeUrl:inBaseStr url:inUrl];
}

+(NSURL*)stringToUrl:(NSString*)inString {
	return [BUtility stringToUrl:inString];
}

+(BOOL)isValidateOrientation:(UIInterfaceOrientation)inOrientation {
	return [BUtility isValidateOrientation:inOrientation];
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

+ (NSURL*)brwViewUrl:(EBrowserView*)inBrwView {
	return [inBrwView.request URL];
}

+ (void)brwView:(EBrowserView*)inBrwView addSubview:(UIView*)inSubView {
	[inBrwView.meBrwWnd addSubview:inSubView];
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

+ (void)brwView:(EBrowserView*)inBrwView presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
	[inBrwView.meBrwCtrler presentModalViewController:modalViewController animated:animated];
}

+ (void)brwView:(EBrowserView*)inBrwView navigationPresentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
	[inBrwView.meBrwCtrler.navigationController presentModalViewController:modalViewController animated:animated];
}

+ (BOOL)isIpad {
	return [BUtility isIpad];
}

+ (NSString*)documentPath:(NSString*)inFileName {
	return [BUtility getDocumentsPath:inFileName];
}

+ (NSString*)brwViewWidgetId:(EBrowserView*)inBrwView {
	return inBrwView.mwWgt.appId;
}

+ (void)brwView:(EBrowserView*)inBrwView presentPopover:(UIPopoverController*)popViewControler FromRect:(CGRect)inRect permittedArrowDirections:(UIPopoverArrowDirection)inDir animated:(BOOL)inAnimated {
	[popViewControler presentPopoverFromRect:inRect inView:inBrwView permittedArrowDirections:inDir animated:inAnimated];
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
+ (UIViewController*)brwCtrl:(EBrowserView*)inBrwView {
	return inBrwView.meBrwCtrler;
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
+(NSString*)macAddress{
    return [BUtility macAddress];
}
+(UIColor*)ColorFromString:(NSString*)inColor{
    UIColor *color =[UIColor blackColor];
    if (inColor && inColor.length != 0) {
		BGColor bgColor = [BUtility bgColorFromNSString:inColor];
		color = [UIColor colorWithRed:bgColor.rgba.r/255.0f green:bgColor.rgba.g/255.0f blue:bgColor.rgba.b/255.0f alpha:bgColor.rgba.a/255.0f];
	}
    return color;
}
+(NSString*)getAbsPath:(EBrowserView*)meBrwView path:(NSString*)inPath{
    return [BUtility getAbsPath:meBrwView path:inPath];
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
+(BOOL)appCanDev{
    return [BUtility getAppCanDevMode];
}

+(void)evaluatingJavaScriptInRootWnd:(NSString*)script_{
	[BUtility evaluatingJavaScriptInRootWnd:script_];
}

+(void)evaluatingJavaScriptInFrontWnd:(NSString*)script_{
	[BUtility evaluatingJavaScriptInFrontWnd:script_];
}
+(NSString*)getCachePath:(NSString*)fileName{
    return [BUtility getCachePath:fileName];
}
+(void)writeLog:(NSString*)inLog{
    return [BUtility writeLog:inLog];
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
@end
