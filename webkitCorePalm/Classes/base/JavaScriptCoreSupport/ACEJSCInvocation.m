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
    self.returnValue = nil;
    if (!self.function || [self.class JSTypeOf:self.function] != ACEJSValueTypeFunction) {
        [self executeBlock:nil];
    }else{
        self.returnValue = [self.function callWithArguments:self.arguments];
        [self executeBlock:self.returnValue];
    }
    
    
}

- (void)invokeOnMainThread{
    [self performSelectorOnMainThread:@selector(delayedInvoke) withObject:nil waitUntilDone:NO];
}

- (void)delayedInvoke{
    //加了延时之后可以解决网页中的alert卡死的问题
    [self performSelector:@selector(invoke) withObject:nil afterDelay:0.01];
}

- (void)executeBlock:(JSValue *)returnValue{
    if (self.completionHandler) {
        self.completionHandler(returnValue);
    }
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
    JSContext *ctx = value.context;
    NSString *tmp = nil;
    do{
        tmp = [[@"_" stringByAppendingString:[NSUUID UUID].UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }while (![ctx[tmp] isUndefined]);
    [ctx evaluateScript:[NSString stringWithFormat:@"var %@ = function(x){return typeof(x);};",tmp]];
    NSString *type = [ctx[tmp] callWithArguments:@[value]].toString;
    ctx[tmp] = nil;
    if ([type.lowercaseString isEqual:@"function"]) {
        return ACEJSValueTypeFunction;
    }
    if ([type.lowercaseString isEqual:@"number"]) {
        return ACEJSValueTypeNumber;
    }
    if ([type.lowercaseString isEqual:@"string"]) {
        return ACEJSValueTypeString;
    }
    if ([type.lowercaseString isEqual:@"boolean"]) {
        return ACEJSValueTypeBoolean;
    }
    if ([type.lowercaseString isEqual:@"object"]) {
        return ACEJSValueTypeObject;
    }
    if ([type.lowercaseString isEqual:@"undefined"]) {
        return ACEJSValueTypeUndefined;
    }
    return ACEJSValueTypeUnknown;
}


@end

