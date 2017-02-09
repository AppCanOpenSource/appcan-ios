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
#import <AppCanKit/ACJSValueSupport.h>
#import <AppCanKit/ACEXTScope.h>
#import <AppCanKit/ACJSFunctionRefInternal.h>
#import "ACEJSCInvocation.h"
#import "EBrowserView.h"
#import "ACEPluginInfo.h"
#import <AppCanKit/ACInvoker.h>
#import "EBrowserWindow.h"
#import "ACEBrowserView.h"

#define ACE_LOG_TRACE(cmd)\
    _Pragma("clang diagnostic push")\
    _Pragma("clang diagnostic ignored \"-Wformat\"")\
    if(ACLogGlobalLogMode & ACLogLevelVerbose)\
        cmd;\
    _Pragma("clang diagnostic pop")


static NSMutableDictionary *ACEJSCGlobalPlugins;



@protocol ACEJSCHandler <JSExport>



JSExportAs(execute,-(id)executeWithPlugin:(NSString *)pluginName method:(NSString *)methodName arguments:(JSValue *)arguments argCount:(NSInteger)argCount executeOptions:(ACEPluginMethodExecuteOptions)options);


- (void)log:(JSValue *)value,...;

@end




@interface ACEJSCHandler()<ACEJSCHandler>

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




- (void)initializeWithJSContext:(JSContext *)context{
    context[ACEJSCHandlerInjectField] = self;
    NSString *baseJS = [ACEJSCBaseJS baseJS];
    [context evaluateScript:baseJS];
    [context setExceptionHandler:^(JSContext *ctx, JSValue *exception) {
        ACLogWarning(@"JS ERROR!ctx:%@ exception:%@",ctx,exception);
        ctx.exception = exception;
    }];
    self.ctx = context;
}






- (void)log:(JSValue *)value, ...{
    NSArray *args = [JSContext currentArguments];
    NSMutableString *log = [NSMutableString string];
    for (int i = 0; i < args.count; i++) {
        [log appendFormat:@"%@",args[i]];
    }
    ACLogInfo(@"%@",log);
}







- (id)executeWithPlugin:(NSString *)pluginName method:(NSString *)methodName arguments:(JSValue *)arguments argCount:(NSInteger)argCount executeOptions:(ACEPluginMethodExecuteOptions)options{
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
    id args = nil;
    if (options & ACEPluginMethodExecuteWithOriginJSValue) {
        args = arguments;
    }
    
    if (!args) {
        args = [self arrayFromArguments:arguments count:argCount];
    }
    

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




- (NSMutableArray *)arrayFromArguments:(JSValue *)arguments count:(NSInteger)argCount{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < argCount; i++) {
        JSValue *value = arguments[i];
        if (value.ac_type != ACJSValueTypeFunction) {
            id obj = [value toObject];
            if (!obj || [obj isKindOfClass:[NSNull class]]) {
                obj = [ACNil null];
            }
            [array addObject:obj];
            continue;
        }
        id ref = [ACJSFunctionRef functionRefFromJSValue: value];
        if (!ref) {
            ref = [ACNil null];
        }
        [array addObject:ref];
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
    

}


@end
