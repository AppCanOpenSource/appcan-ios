/**
 *
 *	@file   	: ACEJSCHandler.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/1/8.
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

#import "ACEJSCHandler.h"
#import "BUtility.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "ACEJSCBaseJS.h"
#import "ACEPluginParser.h"
#import "ACEJSCInvocation.h"
#import "EBrowserView.h"
#import "ACEPluginInfo.h"
#import "EBrowserWindow.h"
#import "ACEBrowserView.h"

#import <AppCanKit/ACEXTScope.h>
#import <AppCanKit/ACJSFunctionRefInternal.h>
#import <AppCanKit/ACInvoker.h>
#import <AppCanKit/ACJSON.h>

#define ACE_LOG_TRACE(cmd)\
    _Pragma("clang diagnostic push")\
    _Pragma("clang diagnostic ignored \"-Wformat\"")\
    if(ACLogGlobalLogMode & ACLogLevelVerbose)\
        cmd;\
    _Pragma("clang diagnostic pop")


static NSMutableDictionary *ACEJSCGlobalPlugins;




@interface ACEJSCHandler()
@property (nonatomic,assign)BOOL disposed;
@property (nonatomic,weak)id<ACJSContext> ctx;
@end



NSString *const ACEJSCHandlerInjectField = @"__uex_JSCHandler_";

@implementation ACEJSCHandler



+ (void)initializeGlobalPlugins{
    ACEJSCGlobalPlugins = [NSMutableDictionary dictionary];
    ACEPluginParser *parser = [ACEPluginParser sharedParser];
    [parser.globalPluginDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self registerGlobalPlugin:key];
    }];
}

+ (void)registerGlobalPlugin:(NSString *)pluginClassName{
    if(ACEJSCGlobalPlugins[pluginClassName]){
        return;
    }
    [ACEJSCGlobalPlugins setObject:[NSNull null] forKey:pluginClassName];
}

+ (BOOL)isAppCanJSBridgePayload:(NSString *)jsPayload{
    return [jsPayload hasPrefix:JS_APPCAN_ONJSPARSE_HEADER_NSSTRING];
}


- (instancetype)initWithEBrowserView:(EBrowserView *)eBrowserView{
    return [self initWithWebViewEngine:eBrowserView];
}

- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine{
    if (!engine || ![engine conformsToProtocol:@protocol(AppCanWebViewEngineObject)]) {
        return nil;
    }
    self = [super init];
    if (self) {
        _pluginDict = [NSMutableDictionary dictionary];
        _engine = engine;
        if ([engine isKindOfClass:[EBrowserView class]]) {
            _eBrowserView = (EBrowserView *)engine;
        }
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}




- (void)initializeWithJSContext:(id<ACJSContext>)context{
    NSString *baseJS = [ACEJSCBaseJS baseJS];
    [context ac_evaluateJavaScript:baseJS];
    self.ctx = context;
}



/// 用于解析JS路由包内容
- (id)executeWithAppCanJSBridgePayload:(NSString *)payloadStr {
    // AppCanWKTODO 这里用于解析JS路由包内容
    ACLogDebug(@"AppCan4.0===>executeWithAppCanJSBridgePayload:%@", payloadStr);
    NSString *header = JS_APPCAN_ONJSPARSE_HEADER_NSSTRING;
    NSString *payloadContent = [payloadStr substringFromIndex:[header length]];
    NSMutableDictionary *responseDic = [payloadContent ac_JSONValue];
    NSString *uexName = responseDic[@"uexName"];
    NSString *method = responseDic[@"method"];
    NSArray *argsArray = responseDic[@"args"];
    NSArray *typesArray = responseDic[@"types"];
    id result = [self executeWithPlugin:uexName method:method arguments:argsArray argumentsTypes:typesArray];
//    NSMutableDictionary *resultDic = [NSMutableDictionary dictionary];
//    [resultDic setObject:@"200" forKey:@"code"];
//    [resultDic setObject:result forKey:@"result"];
//    NSString *resultStr = [resultDic ac_JSONFragment];
    if ([result isKindOfClass:[NSString class]]) {
        result = result;
    }else if([result isKindOfClass:[NSNumber class]]){
        result = [NSString stringWithFormat:@"%@", result];
    }else{
        result = [result ac_JSONFragment];
    }
    result = [result isKindOfClass:[NSString class]] ? result : nil;
    return result;
}

- (id)executeWithPlugin:(NSString *)pluginName method:(NSString *)methodName arguments:(NSArray *)arguments argumentsTypes:(NSArray *)types{
    if(self.disposed){
        return nil;
    }
    if(!ACEJSCGlobalPlugins){
        [self.class initializeGlobalPlugins];
    }
    if(!pluginName || ![pluginName hasPrefix:@"uex"] || !methodName || methodName.length < 1){
        return nil;
    }
    NSString *className = [@"EUEx" stringByAppendingString:[pluginName substringFromIndex:3]];
    [self loadDynamicPlugins:pluginName];
    id pluginInstance = [self getGlobalPluginInstanceByClassName:className];
    if(!pluginInstance){
        pluginInstance = [self getNormalPluginInstanceByClassName:className];
    }
    if(![self isPluginInstanceValid:pluginInstance]){
        return nil;
    }
    
    NSString *selector = [methodName stringByAppendingString:@":"];
    SEL sel = NSSelectorFromString(selector);
    if(![pluginInstance respondsToSelector:sel]){
        return nil;
    }
    
    id args = [self arrayFromArguments:arguments andArgTypes:types];

    BOOL isAsync = [self selector:sel isAsynchronousMethodInClass:[pluginInstance class]];
    
    

    //log trace
    ACE_LOG_TRACE(ACLogVerbose(@"exec <%x> in webView:%@.%@ method:%@.%@ async:%@",args,self.eBrowserView.meBrwWnd.meBrwView.muexObjName,self.eBrowserView.muexObjName,pluginName,methodName,isAsync?@"YES":@"NO"))
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (isAsync) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ACE_LOG_TRACE(@onExit{ACLogVerbose(@"exec <%x> finish",args);})
            [pluginInstance ac_invoke:selector arguments:ACArgsPack(args)];

        });
        return nil;
    }else{
        ACE_LOG_TRACE(@onExit{ACLogVerbose(@"exec <%x> finish",args);})
        return [pluginInstance ac_invoke:selector arguments:ACArgsPack(args)];
    }
#pragma clang diagnostic pop
}

- (BOOL)selector:(SEL)sel isAsynchronousMethodInClass:(Class)cls{
    NSParameterAssert(sel != nil);
    NSParameterAssert(cls != nil);
    
    static NSMutableDictionary<NSString *,NSNumber *> *selCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        selCache = [NSMutableDictionary dictionary];
    });
    NSString *identifier = [NSStringFromClass(cls) stringByAppendingString:NSStringFromSelector(sel)];
    if ([selCache objectForKey:identifier]) {
        return selCache[identifier].boolValue;
    }
    
    Method method = class_getInstanceMethod(cls, sel);
    NSParameterAssert(method != NULL);
    
    NSString *type = [NSString stringWithCString:method_getTypeEncoding(method) encoding:NSUTF8StringEncoding];
    BOOL isAsync = YES;
    if ([type hasPrefix:@"@"]) {
        isAsync = NO;
    }
    [selCache setValue:@(isAsync) forKey:identifier];
    return isAsync;
}



/// 处理JS端传入的参数，按照需要将特定的参数类型进行转换使用
- (NSMutableArray *)arrayFromArguments:(NSArray *)arguments andArgTypes:(NSArray *)argTypes{
    NSMutableArray *array = [NSMutableArray array];
    // AppCanWKTODO
    NSUInteger argCount = arguments.count;
    for (int i = 0; i < argCount; i++) {
        NSString *argType = argTypes[i];
        id value = arguments[i];
        if ([@"function" isEqualToString:argType] && [value isKindOfClass:[NSString class]]) {
            // 参数类型为JS方法，则特殊处理一下
            id obj = [ACJSFunctionRef functionRefWithACJSContext:self.ctx fromFunctionId:value];
            if (!obj || [obj isKindOfClass:[NSNull class]]) {
                obj = [ACNil null];
            }
            [array addObject:obj];
            continue;
        }
        if (!value || [value isKindOfClass:[NSNull class]]) {
            value = [ACNil null];
        }
        [array addObject:value];
    }
    return array;
}














- (BOOL)isVersion4Plugin:(Class)cls{
    static NSMutableDictionary *cacheDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheDict = [NSMutableDictionary dictionary];
    });
    NSString *clsName = NSStringFromClass(cls);
    NSNumber *cache = cacheDict[clsName];
    if (cache) {
        return cache.boolValue;
    }
    unsigned count = 0;
    BOOL isVersion4 = NO;
    Method *classMethods = class_copyMethodList(cls, &count);
    if (!classMethods) {
        return NO;
    }
    for (NSInteger i = 0;i < count;i++){
        Method method = classMethods[i];
        const char *methodName = sel_getName(method_getName(method));
        if(strcmp(methodName, "initWithWebViewEngine:") == 0){
            isVersion4 = YES;
            break;
        }
    }
    free (classMethods);
    [cacheDict setValue:@(isVersion4) forKey:clsName];
    return isVersion4;
}

- (id)newPluginInstanceForClass:(Class)instanceClass{
    id instance;
    if ([self isVersion4Plugin:instanceClass]) {
        instance = [[instanceClass alloc] initWithWebViewEngine:self.engine];
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
        instance = [[instanceClass alloc] initWithBrwView:self.engine];
#pragma clang diagnostic pop
    }
    return instance;
}

- (id)getGlobalPluginInstanceByClassName:(NSString *)className{
    if(!ACEJSCGlobalPlugins[className]){
        return nil;
    }
    id instance = ACEJSCGlobalPlugins[className];
    if (![instance isEqual:[NSNull null]]) {
        return instance;
    }
    Class instanceClass = NSClassFromString(className);
    if(!instanceClass){
        return nil;
    }
    instance = [self newPluginInstanceForClass:instanceClass];
    if(!instance){
        return nil;
    }
    [ACEJSCGlobalPlugins setValue:instance forKey:className];
    return instance;
}

- (id)getNormalPluginInstanceByClassName:(NSString *)className{

    if(self.pluginDict[className]){
        return self.pluginDict[className];
    }
    id instance;
    Class instanceClass = NSClassFromString(className);
    if(!instanceClass){
        return nil;
    }

    instance = [self newPluginInstanceForClass:instanceClass];

    
    if(!instance){
        return nil;
    }
    [self.pluginDict setValue:instance forKey:className];
    return instance;
}




- (void)loadDynamicPlugins:(NSString *)pluginName{
    static NSMutableArray *loadedPlugins;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loadedPlugins = [NSMutableArray array];
    });
    if ([loadedPlugins containsObject:pluginName]) {
        return;
    }
    [loadedPlugins addObject:pluginName];
    
    NSString *frameworkName = [NSString stringWithFormat:@"%@.framework",pluginName];
    
    //载入指定document子目录下的framework
    NSBundle *dynamicBundle = [NSBundle bundleWithPath:[[BUtility dynamicPluginFrameworkFolderPath] stringByAppendingPathComponent:frameworkName]];
    
    if(dynamicBundle && [dynamicBundle load]){
        ACLogInfo(@"load dynamic framework for plugin:%@",pluginName);
        return;
    }
    
    //载入res目录下的framework
    //测试用
    
    dynamicBundle = [NSBundle bundleWithPath:[BUtility wgtResPath:[NSString stringWithFormat:@"res://%@",frameworkName]]];
    if(dynamicBundle && [dynamicBundle load]){
        ACLogInfo(@"load dynamic framework in res for plugin:%@",pluginName);
        return;
        
    }
    //载入dyFiles目录下的framework
    //本地打包用
    
    dynamicBundle = [NSBundle bundleWithPath:[NSString pathWithComponents:@[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject,@"dyFiles",frameworkName]]];
    if(dynamicBundle && [dynamicBundle load]){
        ACLogInfo(@"load dynamic framework in dyFiles for plugin:%@",pluginName);
        return;
    }

}

- (BOOL)isPluginInstanceValid:(id)pluginInstance{
    if(!pluginInstance){
        return NO;
    }
    if(![NSStringFromClass([pluginInstance superclass]) isEqual:@"EUExBase"]){
        return NO;
    }
    return YES;
}



- (void)clean{
    for(__kindof EUExBase *plugin in self.pluginDict.allValues){
        [plugin clean];
    }
    [self.pluginDict removeAllObjects];
    self.eBrowserView = nil;
    self.engine = nil;
    self.ctx = nil;
    self.disposed = YES;
    

}


@end
