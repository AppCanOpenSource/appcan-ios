/**
 *
 *	@file   	: ACJSFunctionRef.m  in AppCanKit
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

#import "ACJSFunctionRef.h"
#import "ACJSValueSupport.h"
#import "ACJSFunctionRefInternal.h"
#import "ACLog.h"



@implementation ACJSFunctionRef

+ (instancetype)functionRefFromJSValue:(JSValue *)value{
    if (!value || value.ac_type != ACJSValueTypeFunction) {
        return nil;
    }
    
    
    ACJSFunctionRef *funcRef = [[self alloc]init];
    if (funcRef) {
        JSContext *ctx = value.context;
        

        funcRef.ctx = ctx;
        funcRef.identifier = [NSUUID UUID].UUIDString;
        funcRef.managedFunction = [[JSManagedValue alloc]initWithValue:value];
        funcRef.machine = value.context.virtualMachine;
        [funcRef.machine addManagedReference:funcRef.managedFunction withOwner:self];
        
        JSValue *intenal = ctx[@"_ACJSFunctionRefIntenal"];
        if ([intenal isUndefined]) {
            intenal = [JSValue valueWithObject:@{} inContext:ctx];
            ctx[@"_ACJSFunctionRefIntenal"] = intenal;
        }
        
        intenal[funcRef.identifier] = value;
        ACLogVerbose(@"js funcRef %@ init",funcRef);
    }
    return funcRef;

}





- (void)executeWithArguments:(NSArray *)args completionHandler:(void (^)(JSValue *returnValue))completionHandler{
    JSValue *value = self.managedFunction.value;
    if (!value) {
        value = self.ctx[@"_ACJSFunctionRefIntenal"][self.identifier];
    }
    if (value) {
        [value ac_callWithArguments:args completionHandler:completionHandler];
    }else{
        if (completionHandler) {
            completionHandler(nil);
        }
    }
}

- (void)executeWithArguments:(NSArray *)args{
    [self executeWithArguments:args completionHandler:nil];
}

- (void)dealloc{
    self.ctx[@"_ACJSFunctionRefIntenal"][self.identifier] = nil;
    [self.machine removeManagedReference:self.managedFunction withOwner:self];
    ACLogVerbose(@"js funcRef %@ dealloc",self);
}



@end
