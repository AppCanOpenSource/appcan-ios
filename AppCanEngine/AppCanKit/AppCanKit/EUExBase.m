/**
 *
 *	@file   	: EUExBase.m  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/27.
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
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

#import "EUExBase.h"
#import "ACArguments.h"
#import "AppCanGlobalObjectGetter.h"
NSString *const kAppCanLocalURLPrefixFile = @"file://";
NSString *const kAppCanLocalURLPrefixWidget = @"wgt://";
NSString *const kAppCanLocalURLPrefixWidgets = @"wgts://";
NSString *const kAppCanLocalURLPrefixResource = @"res://";
NSString *const kAppCanLocalURLPrefixWidgetRoot = @"wgtroot://";
NSString *const kAppCanLocalURLPrefixBox = @"box://";

NSString *const kAppCanRemoteURLPrefixHTTP = @"http://";
NSString *const kAppCanRemoteURLPrefixHTTPS = @"https://";




@interface AppCanCunstomURLParser : NSObject
@property(nonatomic,strong) NSString *prefix;
@property(nonatomic,strong) NSString *basicPath;


- (instancetype)initWithPrefix:(NSString *)prefix basicPath:(NSString *)basicPath;
- (BOOL)canParse:(NSString *)relativePath;
- (NSString *)parse:(NSString *)relativePath;




@end


@implementation AppCanCunstomURLParser

- (instancetype)initWithPrefix:(NSString *)prefix basicPath:(NSString *)basicPath
{
    self = [super init];
    if (self) {
        _prefix = prefix;
        _basicPath = basicPath; 
    }
    return self;
}

- (BOOL)canParse:(NSString *)relativePath{
    NSString *pathFeature = relativePath.lowercaseString;
    return [pathFeature hasPrefix:self.prefix];
}
- (NSString *)parse:(NSString *)relativePath{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.basicPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.basicPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [self.basicPath stringByAppendingPathComponent:[relativePath substringFromIndex:self.prefix.length]];
}

+ (NSArray<AppCanCunstomURLParser*> *)parsersForWidget:(id<AppCanWidgetObject>)widget{
    static NSMutableDictionary *parserGroup;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        parserGroup = [NSMutableDictionary dictionary];
    });
    if (parserGroup[widget.appId]) {
        return parserGroup[widget.appId];
    }

    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSMutableArray *parsers = [NSMutableArray array];
    [parsers addObject:[[AppCanCunstomURLParser alloc] initWithPrefix:kAppCanLocalURLPrefixWidget basicPath:widget.absWidgetPath]];
    [parsers addObject:[[AppCanCunstomURLParser alloc] initWithPrefix:kAppCanLocalURLPrefixResource basicPath:widget.absResourcePath]];
    [parsers addObject:[[AppCanCunstomURLParser alloc] initWithPrefix:kAppCanLocalURLPrefixFile basicPath:@""]];
    [parsers addObject:[[AppCanCunstomURLParser alloc] initWithPrefix:kAppCanLocalURLPrefixWidgets basicPath:[documentPath stringByAppendingPathComponent:@"widgets"]]];
    [parsers addObject:[[AppCanCunstomURLParser alloc] initWithPrefix:kAppCanLocalURLPrefixWidgetRoot basicPath:widget.widgetPath]];
    [parsers addObject:[[AppCanCunstomURLParser alloc] initWithPrefix:kAppCanLocalURLPrefixBox basicPath:[documentPath stringByAppendingPathComponent:@"box"]]];
    [parserGroup setObject:parsers forKey:widget.appId];
    return parsers;
}



@end

@interface EUExBase()

@end

@implementation EUExBase


id<AppCanWebViewEngineObject> AppCanRootWebViewEngine(void){
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([[appDelegate class] conformsToProtocol:@protocol(AppCanGlobalObjectGetter)]) {
        if ([appDelegate respondsToSelector:@selector(getAppCanRootWebViewEngine)]) {
            return [appDelegate getAppCanRootWebViewEngine];
        }
    }
    return nil;
}
id<AppCanWidgetObject> AppCanMainWidget(void){
    id appDelegate = [UIApplication sharedApplication].delegate;
    if ([[appDelegate class] conformsToProtocol:@protocol(AppCanGlobalObjectGetter)]) {
        if ([appDelegate respondsToSelector:@selector(getAppCanMainWidget)]) {
            return [appDelegate getAppCanMainWidget];
        }
    }
    return nil;
};




@synthesize meBrwView;


- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    self = [super init];
    if (self) {
        _webViewEngine = engine;
        
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        if ([engine isKindOfClass:NSClassFromString(@"EBrowserView")]) {
            meBrwView = (EBrowserView *)engine;
        }
#pragma clang diagnostic pop
    }
    return self;
}

- (void)clean{
    //do nothing
}

- (NSArray<NSString *> *)pathPrefixExceptions{
    static NSArray *exceptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        exceptions = @[@"/var/mobile",@"assets-library",@"/private/var/mobile",@"/Users"];
    });
    return exceptions;
}

- (NSString *)absPath:(NSString *)inPath{
    inPath = [inPath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    for (NSString *prefix in self.pathPrefixExceptions) {
        if ([inPath hasPrefix:prefix]) {
            return inPath;
        }
    }
    for (AppCanCunstomURLParser *parser in [AppCanCunstomURLParser parsersForWidget:self.webViewEngine.widget]) {
        if ([parser canParse:inPath]) {
            return [parser parse:inPath];
        }
    }
    return inPath;
}

#pragma mark - 3.x Legacy

- (void)jsSuccessWithName:(NSString *)inCallbackName opId:(int)inOpId dataType:(int)inDataType intData:(int)inData{
    [self.webViewEngine callbackWithFunctionKeyPath:inCallbackName arguments:ACArgsPack(@(inOpId),@(inDataType),@(inData))];
}

- (void)jsSuccessWithName:(NSString *)inCallbackName opId:(int)inOpId dataType:(int)inDataType strData:(NSString *)inData{
    [self.webViewEngine callbackWithFunctionKeyPath:inCallbackName arguments:ACArgsPack(@(inOpId),@(inDataType),inData)];
}

- (void)jsFailedWithOpId:(int)inOpId errorCode:(int)inErrorCode errorDes:(NSString *)inErrorDes{
    [self.webViewEngine callbackWithFunctionKeyPath:@"uexWidgetOne.cbError" arguments:ACArgsPack(@(inOpId),@(inErrorCode),inErrorDes)];
}
- (void)stopNetService{
    //do nothing
}

- (instancetype)initWithBrwView:(id<AppCanWebViewEngineObject>)eInBrwView{
    return [self initWithWebViewEngine:eInBrwView];
}

@end
