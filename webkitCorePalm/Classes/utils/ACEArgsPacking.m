/**
 *
 *	@file   	: ACEArgsPacking.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/9.
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

#import "ACEArgsPacking.h"
#import "ACENil.h"
#import "ACEJSFunctionRef.h"
#import "ACEJSFunctionRefPrivate.h"



typedef NS_ENUM(NSInteger,ACEArgsUnpackingArgType){
    ACEArgsUnpackingArgTypeNSString = 0,
    ACEArgsUnpackingArgTypeNSNumber,
    ACEArgsUnpackingArgTypeNSArray,
    ACEArgsUnpackingArgTypeNSDictionary,
    ACEArgsUnpackingArgTypeJSFunction,
    ACEArgsUnpackingArgTypeOther,
};



NS_ASSUME_NONNULL_BEGIN

@interface ACEArgsPackingHelper: NSObject

+ (instancetype)trampoline;
+ (id)objectOrNil:(nullable id)obj;
+ (nullable id)unpackedObjectFromObject:(nullable id)obj definitionString:(NSString *)defStr;
- (void)setObject:(NSArray *)args forKeyedSubscript:(NSArray<NSValue *> *)variables;

@end

NS_ASSUME_NONNULL_END

#define ACE_HasClassNamePrefix(cls) hasPrefix:NSStringFromClass([cls class])

@implementation ACEArgsPackingHelper

+ (instancetype)trampoline{
    static ACEArgsPackingHelper *trampoline = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trampoline = [[self alloc]init];
    });
    return trampoline;
}

+ (id)objectOrNil:(id)obj{
    
    if (obj && ![obj isKindOfClass:[ACENil class]]) {
        return obj;
    }else{
        return [ACENil null];
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


+ (nullable id)unpackedObjectFromObject:(id)obj definitionString:(NSString *)defStr{
    ACEArgsUnpackingArgType type = [self argTypeFromDefinitionString:defStr];
    if ([obj isKindOfClass:[ACENil class]]) {
        return nil;
    }
    switch (type) {
        case ACEArgsUnpackingArgTypeNSString: {
            if([obj isKindOfClass:[NSString class]]){
                return obj;
            }
            if ([obj isKindOfClass:[NSNumber class]]) {
                return [obj stringValue];
            }
            break;
        }
        case ACEArgsUnpackingArgTypeNSNumber: {
            if ([obj isKindOfClass:[NSNumber class]]) {
                return obj;
            }
            if ([obj isKindOfClass:[NSString class]]) {
                if ([obj length] > 0) {
                    return [NSDecimalNumber decimalNumberWithString:obj];
                }
            }
            break;
        }
        case ACEArgsUnpackingArgTypeNSArray: {
            if ([obj isKindOfClass:[NSArray class]]) {
                return obj;
            }
            if ([obj isKindOfClass:[NSString class]]) {
                NSString *arrayStr = obj;
                id result = [self JSONValue:arrayStr];
                if (result && [result isKindOfClass:[NSArray class]]) {
                    return result;
                }
                
                arrayStr = [arrayStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if([arrayStr hasPrefix:@"["] && [arrayStr hasSuffix:@"]"]){
                    arrayStr = [arrayStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]];
                    return [arrayStr componentsSeparatedByString:@","];
                }
                
                
                
            }
            break;
        }
        case ACEArgsUnpackingArgTypeNSDictionary: {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                return obj;
            }
            if ([obj isKindOfClass:[NSString class]]) {
                id result = [self JSONValue:obj];
                if (result && [result isKindOfClass:[NSDictionary class]]) {
                    return result;
                }
            }
            break;
        }
        case ACEArgsUnpackingArgTypeJSFunction: {
            if ([obj isKindOfClass:[ACEJSFunctionRef class]]) {
                return obj;
            }
            break;
        }
        case ACEArgsUnpackingArgTypeOther: {
            return obj;
            break;
        }
    }
    return nil;
}

+ (id)JSONValue:(NSString *)jsonStr{
    NSError *error = nil;
    id value = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        //NSLog(@"ACEArgsUnpacking JSON parse error:%@",error.localizedDescription);
    }
    return value;
}


+ (ACEArgsUnpackingArgType)argTypeFromDefinitionString:(NSString *)defStr{
    NSString *trimmedStr = defStr;
    static NSArray * modifiers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modifiers = @[@"__weak",@"__block",@"__strong",@"__autoreleasing",@"__unsafe_unretained"];
    });
    
    while (1) {
        BOOL changed = NO;
        NSString *tmp = [trimmedStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![tmp isEqual:trimmedStr]) {
            changed = YES;
            trimmedStr = tmp;
        }
        for (NSString *mod in modifiers) {
            if ([trimmedStr hasPrefix:mod]) {
                trimmedStr = [trimmedStr substringFromIndex:[mod length]];
                changed = YES;
            }
        }
        if (!changed) {
            break;
        }
    }

    if ([trimmedStr ACE_HasClassNamePrefix(NSDictionary)]) {
        return ACEArgsUnpackingArgTypeNSDictionary;
    }
    if ([trimmedStr ACE_HasClassNamePrefix(NSArray)]) {
        return ACEArgsUnpackingArgTypeNSArray;
    }
    if ([trimmedStr ACE_HasClassNamePrefix(NSString)]) {
        return ACEArgsUnpackingArgTypeNSString;
    }
    if ([trimmedStr ACE_HasClassNamePrefix(NSNumber)]) {
        return ACEArgsUnpackingArgTypeNSNumber;
    }
    if ([trimmedStr rangeOfString:@"<ACEJSFunctionReference>"].length > 0) {
        return ACEArgsUnpackingArgTypeJSFunction;
    }
    return ACEArgsUnpackingArgTypeOther;
}






@end








