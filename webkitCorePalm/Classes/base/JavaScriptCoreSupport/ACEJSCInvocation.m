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
@interface ACEJSCInvocation()
@property (nonatomic,strong)JSValue *function;
@property (nonatomic,strong)NSArray *arguments;
@property (nonatomic,strong)void (^completionHandler)(JSValue * returnValue);
@end

@implementation ACEJSCInvocation

+ (instancetype)invocationWithFunction:(JSValue *)function
                             arguments:(NSArray *)arguments
                     completionHandler:(void (^)(JSValue *))completionHandler{
    ACEJSCInvocation *invocation = [[self alloc]init];
    if (invocation) {
        invocation.function = function;
        invocation.arguments = arguments;
        invocation.completionHandler = completionHandler;
    }
    return invocation;
}

- (void)invoke{

    if (!self.function || [self.class JSTypeOf:self.function] != ACEJSValueTypeFunction) {
        if (self.completionHandler) {
            self.completionHandler(nil);
        }
    }else{
        @try {
            JSContext *ctx = self.function.context;
            JSValue *function = self.function;
            NSArray *args = self.arguments;
            JSValue *setTimeOut = ctx[@"setTimeout"];
            void (^completionHandler)(JSValue * returnValue) = self.completionHandler;
            void (^exec)(void) = ^{
                JSValue *r = [function callWithArguments:args];
                if (completionHandler) {
                    completionHandler(r);
                }
            };
            if ([setTimeOut isUndefined]) {
                //ctx中没有setTimeout方法的情况
                //多见于非网页的JSContext
                exec();
            }else{
                NSString *tmp = nil;
                do{
                    tmp = [self.class randomJSName];
                }while (![ctx[tmp] isUndefined]);
                ctx[tmp] = exec;
                [setTimeOut callWithArguments:@[ctx[tmp],@0]];
                ctx[tmp] = nil;
            }

        } @catch (...) {}
    }
    
    
}

- (void)invokeOnMainThread{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self invoke];
    });
}





- (void)dealloc{
   //NSLog(@"JSInvocation dealloc");
}
+ (ACEJSValueType)JSTypeOf:(JSValue *)value{
    
    if(!value || ![value isKindOfClass:[JSValue class]]){
        return ACEJSValueTypeNotJSValue;
    }
    if ([value isNull]) {
        return ACEJSValueTypeNull;
    }
    
    if ([value isUndefined]) {
        return ACEJSValueTypeUndefined;
    }
    if ([value isString]) {
        return ACEJSValueTypeString;
    }
    if ([value isBoolean]) {
        return ACEJSValueTypeBoolean;
    }
    if ([value isNumber]) {
        return ACEJSValueTypeNumber;
    }
    if ([value respondsToSelector:@selector(isArray)] && [value isArray]) {
        return ACEJSValueTypeArray;
    }
    if ([value respondsToSelector:@selector(isDate)] && [value isDate]) {
        return ACEJSValueTypeDate;
    }
    
    JSValueRef valueRef = value.JSValueRef;
    JSContextRef ctxRef = value.context.JSGlobalContextRef;
    if (JSValueIsObject(ctxRef, valueRef)) {
        JSObjectRef objRef = (JSObjectRef)valueRef;
        if (JSObjectIsFunction(ctxRef, objRef)) {
            return ACEJSValueTypeFunction;
        }else{
            return ACEJSValueTypeObject;
        }
    }
    return ACEJSValueTypeUnknown;
}

+ (NSString *)randomJSName{
    return [[@"_" stringByAppendingString:[NSUUID UUID].UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end

