/**
 *
 *	@file   	: ACArguments.h  in AppCanKit
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
 
#import <Foundation/Foundation.h>
#import "ACMetamacros.h"
#import "ACJSFunctionRef.h"
#import "ACNil.h"



/**
 *  AppCanKit 参数解析工具
 */


/**
 *  把若干参数打包成一个数组,若参数为nil,则会用一个ACNil替代(@see ACNil)
 *
 *  @param ... 至少传一个参数,必须是NSObject对象或者nil
 *  @return 打包得到的数组,一个NSArray对象
 *  @discussion 此宏用于解决使用@[]方式构造数组,当其中的参数有为空,会导致崩溃的问题
 *  @example
 
 id arg1 = ...;
 id arg2 = ...;
 id arg3 = ...;
 NSArray *args = @[arg1,arg2,arg3];//若arg1,arg2,arg3中存在nil,则会Crash
 NSArray *args = ACArgsPack(arg1,arg2,arg3);//永远是安全的
 *
 *  @note 受宏的机制所限,若参数中包含',' 则需要将此参数用()包含,否则宏展开会报错
 *  比如 ACArgsPack(@"123",@[@1,@2,@3]) -> ERROR!  ACArgsPack(@"123",(@[@1,@2,@3])) -> OK!
 */
#define ACArgsPack(...) \
    _ACArgsPack(__VA_ARGS__)


/**
 *  解包一个数组,取出若干参数
 *  @discussion 此宏用于一个等式的左边,宏的参数为取出的参数的定义,多个参数定义之间用","隔开,等式的右边为参数数组
 *      若定义的参数数量小于参数数组个数,则数组中多余的项将会被忽略
 *      若定义的参数数量大于参数数组的个数,则多余的参数会被置为nil
 *      定义的参数数量至多为10个
 *      当定义的参数类型为以下之一时,会对此参数进行解析以尽量赋予正确的值,否则会将数组中的项直接赋值给相应的参数,不进行类型校验
 *      会被解析的类型:NSString,NSNumber,NSDictionary,NSArray,ACJSFunctionRef.解析规则见下文中提供的ac_xxxArg方法
 *
 *  @example
 
 NSArray *args = ...;//获得一个参数数组
 ACArgsUnpack(NSString *arg1,NSNumber *arg2,NSArray *arg3) = args;
 NSLog(@"参数1:%@ 参数2:%@ 参数3:%@",arg1,arg2,arg3);
 
 *  @param 参数的定义
        参数 必须 是NSObject的子类或者id,至多10个
        参数不支持可变类型(比如NSMutableDictionary等),需要可变类型时应该先获得不可变类型,然后用mutableCopy进行转换
        参数目前不支持NSInteger等基本类型或者C的struct类型。若需要获取数值类型的参数,应定义为NSNumber *,然后进行转换
 *  @note 此宏不能单独存在于一个Scope或者Condition中,且此宏的参数必须写在同一行中,否则宏展开会出错
 *
 *  @todo 参数支持NSInteger等数值基本类型
 */
#define ACArgsUnpack(...)\
    _ACArgsUnpack(__VA_ARGS__)



/**
 *  尝试转换一个参数为NSString
 *  @param NSString->直接返回, JSValue->解析并返回, NSNumber-> 返回其stringValue
 *  @return 其他情况或解析失败时返回nil
 */
APPCAN_EXPORT NSString* _Nullable ac_stringArg(id _Nullable arg);
APPCAN_EXPORT_AS_SHORT(NSString* _Nullable stringArg(id _Nullable arg), ac_stringArg(arg))

/**
 *  尝试转换一个参数为NSNumber
 *  @param NSNumber->直接返回, JSValue->解析并返回, NSString且长度>0->返回一个NSDecimalNumber
 *  @return 其他情况或解析失败时返回nil
 */
APPCAN_EXPORT NSNumber* _Nullable ac_numberArg(id _Nullable arg);
APPCAN_EXPORT_AS_SHORT(NSNumber* _Nullable numberArg(id _Nullable arg), ac_numberArg(arg))

/**
 *  尝试转换一个参数为NSDictionary
 *  @param NSDictionary->直接返回, JSValue且是Object->解析并返回, NSString且为JSON字符串 -> 解析并返回
 *  @return 其他情况或解析失败时返回nil
 */
APPCAN_EXPORT NSDictionary* _Nullable ac_dictionaryArg(id _Nullable arg);
APPCAN_EXPORT_AS_SHORT(NSDictionary* _Nullable dictionaryArg(id _Nullable arg), ac_dictionaryArg(arg))

/**
 *  尝试转换一个参数为NSArray
 *  @param NSArray->直接返回 ,JSValue且是Array->解析并返回, NSString且为JSON字符串 -> 解析并返回
 *  @return 其他情况或解析失败时返回nil
 */
APPCAN_EXPORT NSArray* _Nullable ac_arrayArg(id _Nullable arg);
APPCAN_EXPORT_AS_SHORT(NSArray* _Nullable arrayArg(id _Nullable arg), ac_arrayArg(arg))


/**
 *  尝试转换一个参数为ACJSFunctionRef(@see ACJSFunctionRef)
 *
 *  @return arg不是一个ACJSFunctionRef时会返回nil
 */
APPCAN_EXPORT ACJSFunctionRef* _Nullable ac_JSFunctionArg(id _Nullable arg);
APPCAN_EXPORT_AS_SHORT(ACJSFunctionRef* _Nullable JSFunctionArg(id _Nullable arg), ac_JSFunctionArg(arg))


#pragma mark - 不要使用下面的任何类和方法!
#pragma mark Private Implementation




#define _ACArgsPack(...) (@[metamacro_foreach(_ACObjectOrNil,,__VA_ARGS__ )])
#define _ACObjectOrNil(idx,obj) (id)(obj) ?: [ACNil null],
#define _ACArgsUnpack(...)\
    metamacro_foreach(_ACArgsUnpack_Declare,, __VA_ARGS__) \
    int _ACArgsUnpackState = 0;\
    _ACArgsUnpack_After:\
        ;\
        metamacro_foreach(_ACArgsUnpack_Assign,, __VA_ARGS__) \
        if (_ACArgsUnpackState != 0) _ACArgsUnpackState = 2; \
        while (_ACArgsUnpackState != 2) \
            if (_ACArgsUnpackState == 1) { \
                goto _ACArgsUnpack_After; \
            } else \
            for (; _ACArgsUnpackState != 1; _ACArgsUnpackState = 1) \
                [ACArgumentsHelper helper][ @[ metamacro_foreach(_ACArgsUnpack_Value,, __VA_ARGS__) ] ]

#define _ACArgsUnpackState \
    metamacro_concat(_ACArgsUnpackState, __LINE__)

#define _ACArgsUnpack_After \
    metamacro_concat(_ACArgsUnpack_After, __LINE__)

#define _ACArgsUnpack_Declare_Name(INDEX) \
    metamacro_concat(metamacro_concat(_ACArgsUnpack, __LINE__), metamacro_concat(_var, INDEX))

#define _ACArgsUnpack_Declare(INDEX, ARG) \
    __strong id _ACArgsUnpack_Declare_Name(INDEX);

#define _ACArgsUnpack_Assign(INDEX, ARG) \
    __strong ARG = [ACArgumentsHelper unpackedObjectFromObject:_ACArgsUnpack_Declare_Name(INDEX) definitionString:@metamacro_stringify(ARG)];

#define _ACArgsUnpack_Value(INDEX, ARG) \
    [NSValue valueWithPointer:&_ACArgsUnpack_Declare_Name(INDEX)],





NS_ASSUME_NONNULL_BEGIN
@interface ACArgumentsHelper : NSObject
+ (instancetype)helper;
+ (nullable id)unpackedObjectFromObject:(nullable id)obj definitionString:(NSString *)defStr;
- (void)setObject:(NSArray *)args forKeyedSubscript:(NSArray<NSValue *> *)variables;
@end
NS_ASSUME_NONNULL_END