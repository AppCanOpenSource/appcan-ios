/**
 *
 *	@file   	: ACInvoker.m  in AppCanKit
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 16/8/5
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


#import "ACInvoker.h"
#import "ACLog.h"
#import "ACJSON.h"
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>



typedef NS_ENUM(NSInteger, ACMethodArgumentType) {
    ACMethodArgumentTypeUnknown             = 0,
    ACMethodArgumentTypeVoid,
    ACMethodArgumentTypeChar,
    ACMethodArgumentTypeInt,
    ACMethodArgumentTypeShort,
    ACMethodArgumentTypeLong,
    ACMethodArgumentTypeLongLong,
    ACMethodArgumentTypeUnsignedChar,
    ACMethodArgumentTypeUnsignedInt,
    ACMethodArgumentTypeUnsignedShort,
    ACMethodArgumentTypeUnsignedLong,
    ACMethodArgumentTypeUnsignedLongLong,
    ACMethodArgumentTypeBool,
    ACMethodArgumentTypeFloat,
    ACMethodArgumentTypeDouble,
    ACMethodArgumentTypeCharacterString,
    ACMethodArgumentTypeCGPoint,
    ACMethodArgumentTypeCGSize,
    ACMethodArgumentTypeCGRect,
    ACMethodArgumentTypeUIEdgeInsets,
    ACMethodArgumentTypeObject,
    ACMethodArgumentTypeClass
};

#pragma mark - NSMethodSignature Category

@implementation NSMethodSignature(ACInvoker)

+ (ACMethodArgumentType)ac_argumentTypeWithEncoding:(const char*)encoding{
    if (strcmp(encoding, @encode(void)) == 0) {
        return ACMethodArgumentTypeVoid;
    }
    if (strcmp(encoding, @encode(char)) == 0) {
        return ACMethodArgumentTypeChar;
    }
    if (strcmp(encoding, @encode(int)) == 0) {
        return ACMethodArgumentTypeInt;
    }
    if (strcmp(encoding, @encode(short)) == 0) {
        return ACMethodArgumentTypeShort;
    }
    if (strcmp(encoding, @encode(long)) == 0) {
        return ACMethodArgumentTypeLong;
    }
    if (strcmp(encoding, @encode(long long)) == 0) {
        return ACMethodArgumentTypeLongLong;
    }
    if (strcmp(encoding, @encode(unsigned char)) == 0) {
        return ACMethodArgumentTypeUnsignedChar;
    }
    if (strcmp(encoding, @encode(unsigned int)) == 0) {
        return ACMethodArgumentTypeUnsignedInt;
    }
    if (strcmp(encoding, @encode(unsigned short)) == 0) {
        return ACMethodArgumentTypeUnsignedShort;
    }
    if (strcmp(encoding, @encode(unsigned long)) == 0) {
        return ACMethodArgumentTypeUnsignedLong;
    }
    if (strcmp(encoding, @encode(unsigned long long)) == 0) {
        return ACMethodArgumentTypeUnsignedLongLong;
    }
    if (strcmp(encoding, @encode(BOOL)) == 0) {
        return ACMethodArgumentTypeBool;
    }
    if (strcmp(encoding, @encode(float)) == 0) {
        return ACMethodArgumentTypeFloat;
    }
    if (strcmp(encoding, @encode(double)) == 0) {
        return ACMethodArgumentTypeDouble;
    }
    if (strcmp(encoding, @encode(char *)) == 0) {
        return ACMethodArgumentTypeCharacterString;
    }
    if (strcmp(encoding, @encode(id)) == 0) {
        return ACMethodArgumentTypeObject;
    }
    if (strcmp(encoding, @encode(Class)) == 0) {
        return ACMethodArgumentTypeClass;
    }
    if (strcmp(encoding, @encode(CGPoint)) == 0) {
        return ACMethodArgumentTypeCGPoint;
    }
    if (strcmp(encoding, @encode(CGSize)) == 0) {
        return ACMethodArgumentTypeCGSize;
    }
    if (strcmp(encoding, @encode(CGRect)) == 0) {
        return ACMethodArgumentTypeCGRect;
    }
    if (strcmp(encoding, @encode(UIEdgeInsets)) == 0) {
        return ACMethodArgumentTypeUIEdgeInsets;
    }
    ACLogError(@"ACInvoker: unknown type encoding '%s' received!",encoding);
    return ACMethodArgumentTypeUnknown;
}
- (ACMethodArgumentType)ac_returnType{
    return [NSMethodSignature ac_argumentTypeWithEncoding:[self methodReturnType]];
}
- (ACMethodArgumentType)ac_argumentTypeAtIndex:(NSUInteger)index{
    return [NSMethodSignature ac_argumentTypeWithEncoding:[self getArgumentTypeAtIndex:index]];
}

- (NSInvocation *)ac_invocationWithArguments:(NSArray *)arguments{
    if (arguments && ![arguments isKindOfClass:[NSArray class]]) {
        ACLogDebug(@"ACInvoker: invalid arguments!");
        NSAssert(NO, @"ACInvoker Error!");
        return nil;
    }
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:self];
    [arguments enumerateObjectsUsingBlock:^(id  _Nonnull argument, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = idx + 2;
        ACMethodArgumentType type = [self ac_argumentTypeAtIndex:index];
        switch (type) {
            case ACMethodArgumentTypeUnknown:
            case ACMethodArgumentTypeVoid:{
                break;
            }
            case ACMethodArgumentTypeChar: {
                char value = [argument charValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeInt: {
                int value = [argument intValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeShort: {
                short value = [argument shortValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeLong: {
                long value = [argument longValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeLongLong: {
                long long value = [argument longLongValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeUnsignedChar: {
                unsigned char value = [argument unsignedCharValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeUnsignedInt: {
                unsigned int value = [argument unsignedIntValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeUnsignedShort: {
                unsigned short value = [argument unsignedShortValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeUnsignedLong: {
                unsigned long value = [argument unsignedLongValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeUnsignedLongLong: {
                unsigned long long value = [argument unsignedLongLongValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeBool: {
                BOOL value = [argument boolValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeFloat: {
                float value = [argument floatValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeDouble: {
                double value = [argument doubleValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeCharacterString: {
                const char *value = [argument UTF8String];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeCGPoint: {
                CGPoint value = [argument CGPointValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeCGSize: {
                CGSize value = [argument CGSizeValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeCGRect: {
                CGRect value = [argument CGRectValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeUIEdgeInsets: {
                UIEdgeInsets value = [argument UIEdgeInsetsValue];
                [invocation setArgument:&value atIndex:index];
                break;
            }
            case ACMethodArgumentTypeObject: {
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case ACMethodArgumentTypeClass: {
                Class value = [argument class];
                [invocation setArgument:&value atIndex:index];
                break;
            }
        }
    }];
    return invocation;
}
@end

#pragma mark - NSInvocation Category

@implementation NSInvocation (ACInvoker)

- (id)ac_invoke:(id)target selector:(SEL)selector returnType:(ACMethodArgumentType)type{
    self.target = target;
    self.selector = selector;
    [self invoke];
    return [self ac_returnValueWithType:type];
}
- (id)ac_returnValueWithType:(ACMethodArgumentType)type{
    __unsafe_unretained id returnValue;
    switch (type) {
        case ACMethodArgumentTypeUnknown:
        case ACMethodArgumentTypeVoid: {
            break;
        }
        case ACMethodArgumentTypeChar: {
            char value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeInt: {
            int value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeShort: {
            short value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeLong: {
            long value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeLongLong: {
            long long value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeUnsignedChar: {
            unsigned char value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeUnsignedInt: {
            unsigned int value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeUnsignedShort: {
            unsigned short value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeUnsignedLong: {
            unsigned long value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeUnsignedLongLong: {
            unsigned long long value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeBool: {
            BOOL value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeFloat: {
            float value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeDouble: {
            double value;
            [self getReturnValue:&value];
            returnValue = @(value);
            break;
        }
        case ACMethodArgumentTypeCharacterString: {
            const char *value;
            [self getReturnValue:&value];
            returnValue = [NSString stringWithUTF8String:value];
            break;
        }
        case ACMethodArgumentTypeCGPoint: {
            CGPoint value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGPoint:value];
            break;
        }
        case ACMethodArgumentTypeCGSize: {
            CGSize value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGSize:value];
            break;
        }
        case ACMethodArgumentTypeCGRect: {
            CGRect value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithCGRect:value];
            break;
        }
        case ACMethodArgumentTypeUIEdgeInsets: {
            UIEdgeInsets value;
            [self getReturnValue:&value];
            returnValue = [NSValue valueWithUIEdgeInsets:value];
            break;
        }
        case ACMethodArgumentTypeObject:
        case ACMethodArgumentTypeClass: {
             [self getReturnValue:&returnValue];
            break;
        }
    }
    return returnValue;
}
@end

#pragma mark - Verbose Description


#pragma mark - NSObject Category

@implementation NSObject (ACInvoker)

- (NSString *)ac_description{
    if ([self isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"<String>%@",[self ac_JSONFragment]];
    }
    if ([self isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)self;
        return [NSString stringWithFormat:@"<Number.%s>%@",num.objCType,num];
    }
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableString *desc = [@"<Array>[\n" mutableCopy];
        NSArray *arr = (NSArray *)self;
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [desc appendFormat:@"\t%@,\n",[[obj ac_description] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
        }];
        [desc appendString:@"]"];
        return [desc copy];
    }
    if ([self isKindOfClass:[NSDictionary class]]) {
        NSMutableString *desc = [@"<Dictionary>{\n" mutableCopy];
        NSDictionary *dict = (NSDictionary *)self;
        [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [desc appendFormat:@"\t%@: %@\n",[[key ac_description] stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"],[[obj ac_description]  stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t"]];
        }];
        [desc appendString:@"}"];
        return desc;
    }
    if ([self isKindOfClass:[JSValue class]]) {
        return [[(JSValue *)self toArray] ac_description];
    }
    
    return self.debugDescription;
}

static id _ac_invoke(id target, NSString *selector, NSArray *arguments){
    SEL sel = NSSelectorFromString(selector);
    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
    if (signature) {
        NSInvocation *invocation = [signature ac_invocationWithArguments:arguments];
        if(ACLogGlobalLogMode & ACLogLevelVerbose){
            NSMutableString *args = nil;
            if (arguments) {
                args = [@"\n" mutableCopy];
                [arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [args appendFormat:@"%@\n",[obj ac_description]];
                }];
            }
            ACLogVerbose(@"ACInvoker: %@ invoke '%@' with args:%@",target,selector,args);
        }
        id returnValue = [invocation ac_invoke:target selector:sel returnType:[signature ac_returnType]];
        return returnValue;
    }else{
        ACLogDebug(@"ACInvoker: method with selector '%@' not found!",selector);
        return nil;
    }
}

- (id)ac_invoke:(NSString *)selector arguments:( NSArray *)arguments{
    return _ac_invoke(self, selector, arguments);
}

- (id)ac_invoke:(NSString *)selector{
    return [self ac_invoke:selector arguments:nil];
}

+ (id)ac_invoke:(NSString *)selector arguments:(NSArray *)arguments{
    return _ac_invoke(self.class, selector, arguments);
}

+ (id)ac_invoke:(NSString *)selector{
    return [self ac_invoke:selector arguments:nil];
}

@end



