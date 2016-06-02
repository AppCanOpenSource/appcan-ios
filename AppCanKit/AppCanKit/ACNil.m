/**
 *
 *	@file   	: ACNil.m  in AppCanKit
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 16/5/25.
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

#import "ACNil.h"
#import "ACEXTRuntimeExtensions.h"
@implementation ACNil

static id nilSingleton = nil;


+ (void)initialize{
    if (self.class == [ACNil class]) {
        if (!nilSingleton) {
            nilSingleton = [[self alloc] init];
        }
    }
}


+ (instancetype)null{
    return nilSingleton;
}

- (instancetype)init{
    return self;
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark Forwarding machinery

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSUInteger returnLength = [[anInvocation methodSignature] methodReturnLength];
    if (!returnLength) {
        return;
    }
    
    char buffer[returnLength];
    memset(buffer, 0, returnLength);
    
    [anInvocation setReturnValue:buffer];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return ac_globalMethodSignatureForSelector(selector);
}

- (BOOL)respondsToSelector:(SEL)selector {
    return NO;

}

#pragma mark NSObject protocol

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return NO;
}

- (NSUInteger)hash {
    return 0;
}

- (BOOL)isEqual:(id)obj {
    return !obj || obj == self || [obj isEqual:[NSNull null]];
}

- (BOOL)isKindOfClass:(Class)class {
    return [class isEqual:[ACNil class]] || [class isEqual:[NSNull class]];
}

- (BOOL)isMemberOfClass:(Class)class {
    return [class isEqual:[ACNil class]] || [class isEqual:[NSNull class]];
}

- (BOOL)isProxy {
    return NO;
}

@end

