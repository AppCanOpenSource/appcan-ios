/**
 *
 *	@file   	: ACEJSFunctionRef.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/5.
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

#import "ACEJSFunctionRef.h"
#import "ACEJSFunctionRefPrivate.h"
#import "ACEJSCHandler.h"
#import "ACEJSCInvocation.h"
#import "EBrowserView.h"
@implementation ACEJSFunctionRef


- (instancetype)initWithJSCHandler:(ACEJSCHandler *)handler function:(JSValue *)function{
    self = [super init];
    if (self) {
        _handler = handler;
        JSManagedValue *managedValue = [JSManagedValue managedValueWithValue:function];
        _managedFunc = managedValue;
        [self.handler.ctx.virtualMachine addManagedReference:managedValue withOwner:self];
        _uuid = [NSUUID UUID].UUIDString;
    }
    return self;
}



- (void)executeWithArguments:(NSArray *)args completionHandler:(void (^)(JSValue *returnValue))completionHandler{
    ACEJSCInvocation *invocation = [ACEJSCInvocation invocationWithFunction:[self.managedFunc value] arguments:args completionHandler:completionHandler];
    [invocation invokeOnMainThread];
}

- (void)dealloc{
    [self.handler.ctx.virtualMachine removeManagedReference:self.managedFunc withOwner:self];
    NSLog(@"js func dealloc");
}


@end
