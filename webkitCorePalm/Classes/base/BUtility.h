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





//协议路径
#define F_HTTP_PATH			@"http://"
#define F_HTTPS_PATH		@"https://"
#define F_APP_PATH			@"wgt://"
#define F_WGTS_PATH			@"wgts://"
#define F_RES_PATH			@"res://"
#define F_BOX_PATH			@"box://"
#define F_EXTERBOX_PATH		@"exterbox://"
#define F_DATA_PATH			@"data:"
#define F_WGTROOT_PATH		@"wgtroot://"


#define F_WIDGETONE_APPS_NAME		@"apps"


//encriypt
 
#define JSENCRYPTKEY			@"ZYWXWIDGETENCRYPTFORWEBKIT20111101"

#define MAMENCRYPTKEY			@"ZYWXWIDGETENCRYPTFORWEBKIT20121211225XLL"
//ud key
#define F_UD_BadgeNumber        @"AppCanBadgeNumber"

#define F_UD_StandardWgt          @"standWgt"
#define F_UD_UpdateWgtID        @"AppCanWgtID"
#define F_UD_WgtCopyFinish       @"AppCanWgtCopyFinish"

//clientCertificate.p12
//#define ClientCertficate_PATH [NSString stringWithFormat:@"%@/Documents/widget/wgtRes/clientCertificate.p12", NSHomeDirectory()]

#define iPhone4 ([UIScreen  instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

//iPhone 6,7,8P尺寸一致
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

//iPhone X he  iPhone XS
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//iPhone XR  828px × 1792px
#define iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

//iPhone XS Max 1242px x 2688px
#define iPhoneXS_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO) //2688×1242



#define APP_JSON_KEY_MULTIPOPNAME @"multiPopName"
#define APP_JSON_KEY_MULTIPOPSELECTEDNUM @"multiPopSelectedIndex"


#ifndef OUTPUT_LOG
//#define OUTPUT_LOG
#endif

#ifdef OUTPUT_LOG
#ifndef OUTPUT_LOG_CONTROL
#define OUTPUT_LOG_CONTROL
#endif

//插件log
#ifndef Plugin_OUTPUT_LOG_CONSOLE
#define Plugin_OUTPUT_LOG_CONSOLE
#endif
#endif

#define rgba(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//rc4
struct rc4_state 
{ 
    int x, y, m[256]; 
};
void rc4_setup( struct rc4_state *s, unsigned char *key, int length); 
void rc4_crypt( struct rc4_state *s, unsigned char *data, int length);
//Log
void ACENSLog (NSString *format, ...);

@class EBrowserView;
@interface BUtility : NSObject

//rc4 js
+(NSString*)getRC4LocalStoreJSKey;

//dev
+(void)setAppCanDevMode:(NSString*)inValue;
+(BOOL)getAppCanDevMode;
//client https pwd
+(void)setClientCertificatePwd:(NSString*)inPwd;
+(NSString*)ClientCertificatePassWord;

+ (NSString *) platform;
+(NSString *)getDeviceIdentifyNo;
//+(BOOL)isPhoneNumber:(NSString*)inPhoneNum;
+(int)getScreenWidth;
+(int)getScreenHeight;
+ (BOOL)useIOS7Style;
+ (CGRect)getApplicationInitFrame;
+(NSString*)getScreenWAndH;
+(float)getSystemVersion;
+(BOOL)isIpad;
+(BOOL)isSimulator;
+(NSString*)getDeviceVer;
+(NSString*)makeSpecUrl:(NSString*)inStr;
+(NSString*)makeUrl:(NSString*)inBaseUrl url:(NSString*)inUrl;
+(NSString *)getDocumentsPath:(NSString *)fileName;
+(NSString *)getResPath:(NSString *)fileName;
+(int)lastIndexOf:(NSString*)baseString findChar:(char)inChar;
//+(NSMutableArray*)convertToArray:(NSURL*)inURL;

+(NSURL*)stringToUrl:(NSString *)inString;
+(NSString*)wgtResPath:(NSString*)inUrl;
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;
+(BOOL) isValidateOrientation:(UIInterfaceOrientation)inOrientation;
+(BOOL)isHaveString:(NSString *)inSouceString subSting:(NSString *)inSubString;
+(int)fileisDirectoy:(NSString *)fileName;
+(NSString *)AESDecryptFile:(NSString *)srcFile;
+(void)writeLog:(NSString*)inLog;
+ (void)cookieDebugForBroad;
+(NSString *)getTransferredString:(NSData *)inData;
+(UIImage*)imageByScalingAndCroppingForSize:(UIImage *)sourceImage;
+(BOOL) isConnected;
+(double)usedMemory;
+(double)availableMemory;
+(void)exitWithClearData;
+(UIImage *)rotateImage:(UIImage *)aImage;
//数据统计
+(NSString*)appKey;
+(NSString*)appId;
+(NSString *)getSubWidgetAppKeyByAppid:(NSString*)appid;
+ (void)setAppCanViewActive:(int)wgtType opener:(NSString *)inOpener name:(NSString *)inName openReason:(int)inOpenReason mainWin:(int)inMainWnd appInfo:(NSDictionary *)appInfo;

+ (void)setAppCanViewBackground:(int)wgtType name:(NSString *)inName closeReason:(int)inOpenReason appInfo:(NSDictionary *)appInfo;
//mac
+(NSString *)macAddress;
//absPath
+(NSString*)getAbsPath:(EBrowserView*)meBrwView path:(NSString*)inPath;

+ (int)getRand ;
+(NSString*)rc4WithInput:(NSString*)aInput key:(NSString*)aKey;
+(NSString*)RC4DecryptWithInput:(NSString*)aInput key:(NSString*)aKey;
//p12 https://
+(BOOL)extractIdentity:(NSString*)pwdStr andIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef*)outTrust andCertChain:(SecCertificateRef*)outCertChain fromPKCS12Data:(NSData *)inPKCS12Data;
+(NSString*)clientCertficatePath;
//icloud
+(float)getSDKVersion;
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
+(NSString *)getCachePath:(NSString *)fileName;
#pragma mark - Jailbroken
+(BOOL)isJailbroken;

+(void)evaluatingJavaScriptInRootWnd:(NSString*)script_;
+(void)evaluatingJavaScriptInFrontWnd:(NSString*)script_;
// 获取config屏幕方向信息
+(NSString * )getMainWidgetConfigInterface;
//
+(NSDictionary *)getMainWidgetConfigWindowBackground;
+(NSString *)getMainWidgetConfigLogserverip;
+ (BOOL)copyMissingFile:(NSString *)sourcePath toPath:(NSString *)toPath;
+ (NSString *)bundleIdentifier;
+ (NSString *)getVarifyAppMd5Code:(NSString *)appId AppKey:(NSString *)appKey time:(NSTimeInterval)time_;
+ (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
+ (NSString *)dynamicPluginFrameworkFolderPath;

+ (NSString *)transcoding:(NSString *)inString;

@end
