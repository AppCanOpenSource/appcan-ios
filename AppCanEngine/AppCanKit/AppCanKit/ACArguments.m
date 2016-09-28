/**
 *
 *	@file   	: ACArguments.m  in AppCanKit
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

#import "ACArguments.h"
#import "ACJSON.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ACJSFunctionRefInternal.h"


NSString* _Nullable ac_stringArg(id _Nullable arg){
    if ([arg isKindOfClass:[JSValue class]]) {
        arg = [arg toObject];
    }
    if ([arg isKindOfClass:[NSString class]]) {
        return arg;
    }
    if ([arg isKindOfClass:[NSNumber class]]) {
        return [arg stringValue];
    }
    return nil;
}




NSNumber* _Nullable ac_numberArg(id _Nullable arg){
    if ([arg isKindOfClass:[JSValue class]]) {
        arg = [arg toObject];
    }
    if ([arg isKindOfClass:[NSString class]]  && [arg length] > 0) {
        return [NSDecimalNumber decimalNumberWithString:arg];
    }
    if ([arg isKindOfClass:[NSNumber class]]) {
        return arg;
    }
    return nil;
}

NSDictionary* _Nullable ac_dictionaryArg(id _Nullable arg){
    if ([arg isKindOfClass:[JSValue class]]) {
        arg = [arg toObject];
    }
    if ([arg isKindOfClass:[NSString class]]) {
        arg = [arg ac_JSONValue];
    }
    if ([arg isKindOfClass:[NSDictionary class]]) {
        return arg;
    }
    return nil;
}

NSArray* _Nullable ac_arrayArg(id _Nullable arg){
    if ([arg isKindOfClass:[JSValue class]]) {
        arg = [arg toObject];
    }
    NSString *arrayStr = nil;
    if ([arg isKindOfClass:[NSString class]]) {
        arg = [arg ac_JSONValue];
        //兼容JS SDK的URL转码得到的string
        arrayStr = [arg isKindOfClass:[NSString class]]? arg : nil;
    }
    if ([arg isKindOfClass:[NSArray class]]) {
        return arg;
    }
    
    arrayStr = [arrayStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([arrayStr hasPrefix:@"["] && [arrayStr hasSuffix:@"]"]){
        arrayStr = [arrayStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
        return [arrayStr componentsSeparatedByString:@","];
    }
    
    return nil;
}

ACJSFunctionRef * _Nullable ac_JSFunctionArg(id _Nullable arg){
    if ([arg isKindOfClass:[ACJSFunctionRef class]]) {
        return arg;
    }
    if ([arg isKindOfClass:[JSValue class]]) {
        return [ACJSFunctionRef functionRefFromJSValue:arg];
    }
    return nil;
}

typedef NS_ENUM(NSInteger,ACArgumentsHelperParseOption){
    ACArgumentsHelperParseDefault,
    ACArgumentsHelperParseAsNSString,
    ACArgumentsHelperParseAsNSNumber,
    ACArgumentsHelperParseAsNSDictionary,
    ACArgumentsHelperParseAsNSArray,
    ACArgumentsHelperParseAsJSFunction
};


#define _ACHasClassNamePrefix(cls) hasPrefix:NSStringFromClass([cls class])

@implementation ACArgumentsHelper

+ (ACArgumentsHelperParseOption)parseOptionFromDefination:(NSString *)definationStr{
    static NSArray * modifiers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modifiers = @[@"__weak",@"__block",@"__strong",@"__autoreleasing",@"__unsafe_unretained",@"__unused",@"__nullable",@"__nonnull"];
    });
    while (1) {
        BOOL changed = NO;
        NSString *tmp = [definationStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![tmp isEqual:definationStr]) {
            changed = YES;
            definationStr = tmp;
        }
        for (NSString *mod in modifiers) {
            if ([definationStr hasPrefix:mod]) {
                definationStr = [definationStr substringFromIndex:[mod length]];
                changed = YES;
            }
        }
        if (!changed) {
            break;
        }
    }
    if ([definationStr _ACHasClassNamePrefix(NSString)]) {
        return ACArgumentsHelperParseAsNSString;
    }
    if ([definationStr _ACHasClassNamePrefix(NSNumber)]) {
        return ACArgumentsHelperParseAsNSNumber;
    }
    if ([definationStr _ACHasClassNamePrefix(NSArray)]) {
        return ACArgumentsHelperParseAsNSArray;
    }
    if ([definationStr _ACHasClassNamePrefix(NSDictionary)]) {
        return ACArgumentsHelperParseAsNSDictionary;
    }
    if ([definationStr _ACHasClassNamePrefix(ACJSFunctionRef)]) {
        return ACArgumentsHelperParseAsJSFunction;
    }
    return ACArgumentsHelperParseDefault;
}

+ (instancetype)helper{
    static ACArgumentsHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

+ (nullable id)unpackedObjectFromObject:(nullable id)obj definitionString:(NSString *)defStr{
    if ([obj isKindOfClass:[ACNil class]]) {
        return nil;
    }
    ACArgumentsHelperParseOption option = [self parseOptionFromDefination:defStr];
    switch (option) {
        case ACArgumentsHelperParseDefault: {
            return obj;
            break;
        }
        case ACArgumentsHelperParseAsNSString: {
            return ac_stringArg(obj);
            break;
        }
        case ACArgumentsHelperParseAsNSNumber: {
            return ac_numberArg(obj);
            break;
        }
        case ACArgumentsHelperParseAsNSDictionary: {
            return ac_dictionaryArg(obj);
            break;
        }
        case ACArgumentsHelperParseAsNSArray: {
            return ac_arrayArg(obj);
            break;
        }
        case ACArgumentsHelperParseAsJSFunction: {
            return ac_JSFunctionArg(obj);
            break;
        }
    }
}

- (void)setObject:(NSArray *)args forKeyedSubscript:(NSArray<NSValue *> *)variables{
    NSCParameterAssert(variables != nil);
    [variables enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger index, BOOL *stop) {
        __strong id *ptr = (__strong id *)value.pointerValue;
        if (args.count > index) {
            *ptr = args[index];
        }
    }];
}

@end
