/**
 *
 *	@file   	: ACEJSCInvocation.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/4/21.
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

#import "ACEJSCInvocation.h"

#import "BUtility.h"

@interface ACEJSCInvocation()

@property (nonatomic,weak)id<ACJSContext> context;
@property (nonatomic,strong)NSString *functionJs;
@property (nonatomic,strong)NSArray *arguments;
@property (nonatomic,strong)ACJSFunctionRef *functionRef;
@property (nonatomic,strong)void (^completionHandler)(id _Nullable, NSError * _Nullable);

@end

@implementation ACEJSCInvocation

+ (instancetype)invocationWithACJSContext:(id<ACJSContext>)context
                               FunctionJs:(NSString *)functionJs
                             arguments:(NSArray *)arguments
                     completionHandler:(nullable void (^)(id _Nullable, NSError * _Nullable))completionHandler{
    ACEJSCInvocation *invocation = [[self alloc] init];
    if (invocation) {
        invocation.context = context;
        invocation.functionJs = functionJs;
        invocation.arguments = arguments;
        invocation.completionHandler = completionHandler;
    }
    return invocation;
}

+ (instancetype)invocationWithACJSContext:(id<ACJSContext>)context
                      withACJSFunctionRef:(ACJSFunctionRef *)functionRef
                            withArguments:(NSArray *)args
                        completionHandler:(nullable void (^)(id _Nullable, NSError * _Nullable))completionHandler{
    // 处理JS匿名回调方法的逻辑，需要增加与引擎框架交互的协议参数，一起执行。
    NSMutableArray *inArgs = [NSMutableArray array];
    // functionId：本匿名回调在定义时，在框架中定义的方法ID，可以唯一标识JS中保存好的匿名方法。
    [inArgs addObject:[functionRef getJSFunctionRefId]];
    // flag：代表本callback是否还会有下一次回调，0没有，1有。此参数来自于Android逻辑，然而此处在iOS中默认为1，是因为在iOS引擎中我们利用ACJSFunctionRef实例的回收时机来判断是否应当回收前端的JS方法。参见本文件的dealloc方法。
    NSString *flag = @"1";
    [inArgs addObject:flag];
    // 将插件回调的原本参数都加入进来。
    [inArgs addObjectsFromArray:args];
    ACEJSCInvocation *invocation = [ACEJSCInvocation invocationWithACJSContext:context FunctionJs:@"uexCallback.callback" arguments:inArgs completionHandler:completionHandler];
    invocation.functionRef = functionRef;
    return invocation;
}

- (void)invoke{

    if (!self.context || !self.functionJs) {
        if (self.completionHandler) {
            self.completionHandler(nil, nil);
        }
    }else{
        NSArray *args = self.arguments;
        NSMutableString *callbackJsStr = [NSMutableString stringWithCapacity:0];
        // 拼接后形如：if(uexWidget.onTest){uexWidget.onTest();}
        [callbackJsStr appendFormat:@"if(%@){%@(", _functionJs, _functionJs];
        // 开始解析转换各种JS参数类型，拼接JS字符串
        for (int i = 0; i < args.count; i++) {
            id arg = args[i];
            if ([arg isKindOfClass:[NSString class]]) {
                // string类型
                [callbackJsStr appendString:@"\'"];
                // 给特殊符号增加转义符，以免在JS中执行错误
                arg = [BUtility transcoding:arg];
                [callbackJsStr appendString:arg];
                [callbackJsStr appendString:@"\'"];
            }else if([arg isKindOfClass:[NSNumber class]]){
                // NSNumber内需要进一步判断
                // 由于BOOL类型无法准确区分，故不做区分。如果想回调true 和 false，直接用字符串类型。
//                if (strcmp([arg objCType], @encode(BOOL))) {
//                    // boolean类型
//                    NSString *argToStr = arg ? @"true" : @"false";
//                    [callbackJsStr appendString:argToStr];
//                }else{
                // number类型
                NSString *argToStr = [NSString stringWithFormat:@"%@", arg];
                [callbackJsStr appendString:argToStr];
//                }
            }else if ([arg isKindOfClass:[ACNil class]]){
                [callbackJsStr appendString:@"undefined"];
            }
            else{
                // object类型
                NSString *argToStr = [arg ac_JSONFragment];
                [callbackJsStr appendString:argToStr];
            }
            if (i < args.count - 1) {
                [callbackJsStr appendString:@","];
            }
        }
        [callbackJsStr appendString:@");}"];
        ACLogDebug(@"AppCan===>ACEJSCInvocation===>invoke===>%@", callbackJsStr);
        [_context ac_evaluateJavaScript:callbackJsStr completionHandler:_completionHandler];
    }
}

- (void)invokeOnMainThread{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self invoke];
    });
}

+ (NSString *)randomJSName{
    return [[@"_" stringByAppendingString:[NSUUID UUID].UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (void)dealloc {
    self.functionRef = nil;
}

@end

