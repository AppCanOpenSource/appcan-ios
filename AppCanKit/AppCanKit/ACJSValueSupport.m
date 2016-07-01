/**
 *
 *	@file   	: ACJSValueSupport.m  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/30.
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

#import "ACJSValueSupport.h"

@implementation JSValue (AppCanKit)


- (ACJSValueType)ac_type{
    if ([self isNull]) {
        return ACJSValueTypeNull;
    }
    if ([self isUndefined]) {
        return ACJSValueTypeUndefined;
    }
    if ([self isString]) {
        return ACJSValueTypeString;
    }
    if ([self isBoolean]) {
        return ACJSValueTypeBoolean;
    }
    if ([self isNumber]) {
        return ACJSValueTypeNumber;
    }
    if ([self respondsToSelector:@selector(isArray)] && [self isArray]) {
        return ACJSValueTypeArray;
    }
    if ([self respondsToSelector:@selector(isDate)] && [self isDate]) {
        return ACJSValueTypeDate;
    }
    JSValueRef valueRef = self.JSValueRef;
    JSContextRef ctxRef = self.context.JSGlobalContextRef;
    if (JSValueIsObject(ctxRef, valueRef)) {
        JSObjectRef objRef = (JSObjectRef)valueRef;
        if (JSObjectIsFunction(ctxRef, objRef)) {
            return ACJSValueTypeFunction;
        }else{
            return ACJSValueTypeObject;
        }
    }
    return ACJSValueTypeUnknown;
}


- (void)ac_callWithArguments:(NSArray *)arguments{
    [self ac_callWithArguments:arguments waitingUntilNextRunLoop:YES inQueue:nil completionHandler:nil];
}

- (void)ac_callWithArguments:(NSArray *)arguments
           completionHandler:(void (^)(JSValue *))completionHandler{
    [self ac_callWithArguments:arguments waitingUntilNextRunLoop:YES inQueue:nil completionHandler:completionHandler];
}

- (void)ac_callWithArguments:(NSArray *)arguments
     waitingUntilNextRunLoop:(BOOL)waitingUntilNextRunLoop
                     inQueue:(dispatch_queue_t)queue
           completionHandler:(void (^)(JSValue *))completionHandler{
    ACJSValueType type = self.ac_type;
    if (type != ACJSValueTypeFunction) {
        if (completionHandler) {
            completionHandler(nil);
        }
        return;
    }
    
    if (!queue) {
        queue = dispatch_get_main_queue();
    }
    dispatch_async(queue, ^{
        void (^exec)(void) = ^{
            JSValue *returnValue = [self callWithArguments:arguments];
            if (completionHandler) {
                completionHandler(returnValue);
            }
        };
        if (!waitingUntilNextRunLoop) {
            exec();
            return;
        }
        JSValue *setTimeout = self.context[@"setTimeout"];
        ACJSValueType type = setTimeout.ac_type;
        
        if (type == ACJSValueTypeFunction) {
            [setTimeout callWithArguments:@[exec,@0]];
        }else{
            //当前JSContext没有setTimeout方法。可能是自定义的JSContext,而非来自webView
            exec();
        }
        
    });
}

@end

@implementation JSContext(AppCanKit)

- (JSValue *)ac_JSValueForKeyPath:(NSString *)keyPath{
    JSValue *value = nil;
    NSArray<NSString *> *components = [keyPath componentsSeparatedByString:@"."];
    for (int i = 0; i < components.count; i++) {
        if (!value) {
            value = [self objectForKeyedSubscript:components[i]];
        }else{
            value = [value objectForKeyedSubscript:components[i]];
        }
    }
    return value;
}

@end


