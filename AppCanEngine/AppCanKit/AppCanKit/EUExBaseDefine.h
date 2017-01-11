/**
 *
 *	@file   	: EUExBaseDefine.h  in AppCanKit
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 16/8/9
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

NS_ASSUME_NONNULL_BEGIN


/**
 *  插件接口返回的Boolean值
 */
typedef NSNumber * UEX_BOOL;

APPCAN_EXPORT UEX_BOOL UEX_TRUE;
APPCAN_EXPORT UEX_BOOL UEX_FALSE;

/**
 *  插件接口返回的Error值
 */
typedef NSNumber * UEX_ERROR;

//此值表示没有错误发生(errCode == 0)
APPCAN_EXPORT UEX_ERROR kUexNoError;


/**
 *  生成一个uexError
 *
 *  @note 此宏只应该在插件接口中被使用
 *  @note 传入1~3个参数,只传1个参数时不会输出日志
 *  @param parameter1 -     NSInteger类型      必选  错误码,必须非零
 *  @param parameter2 -     NSString类型       可选  错误描述,会输出debug级别的日志
 *  @param parameter3 -     NSDictionary类型   可选  错误额外信息,会输出debug级别的日志
 *
 *  @return 生成的uexError
 *
 *  @example UEX_ERROR err = uexErrorMake(-1,@"网络请求错误",@{@"responseCode": @404});
 */

#define uexErrorMake(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(_uexErrorMake1(__VA_ARGS__))(metamacro_if_eq(2, metamacro_argcount(__VA_ARGS__))(_uexErrorMake2(__VA_ARGS__))(_uexErrorMake3(__VA_ARGS__)))









/**
 *  保证参数满足一定的condition
 *  用法参考NSAssert,当condition不满足时,会输出error日志并退出当前scope
 *
 *  @note 此宏只应该在插件接口中被使用
 *  @note 传入1~2个参数
 *  @param parameter1 - 必选 要满足的condition
 *  @param parameter2 - 可选 不满足condition时退出此scope的返回值.若此scope的返回值为void类型,则不传此参数,表示没有返回值.
 *
 *  @example 
 
 - (NSString *)test:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *inSpeed) = inArguments;
    NSInteger speed = inSpeed.floatValue;
    UEX_PARAM_GUARD(speed > 0,@"1"); //如果speed <= 0,会直接输出日志并退出test方法,返回值为@"1"
    return @"2";
 }
 
 */

#define UEX_PARAM_GUARD(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(_UEX_PARAM_GUARD1(__VA_ARGS__))(_UEX_PARAM_GUARD2(__VA_ARGS__))

/**
 *  保证参数非nil
 *  用法参考NSAssert,当condition不满足时,会输出error日志并退出当前scope
 *
 *  @note 此宏只应该在插件接口中被使用
 *  @note 传入1~2个参数
 *  @param parameter1 - 必选 要保证非nil的参数,参数必须是NSObject的子类
 *  @param parameter2 - 可选 参数为空时此scope的返回值.若此scope的返回值为void类型,则不传此参数,表示没有返回值.
 *
 *  @example 
 
 - (NSString *)test:(NSMutableArray *)inArguments{
    ACArgsUnpack(NSNumber *inSpeed) = inArguments;
    UEX_PARAM_GUARD_NOT_NIL(inSpeed,@"1"); //如果inSpeed 为nil,会直接输出日志并退出test方法,返回值为@"1"
    return @"2";
 }
 
 */
#define UEX_PARAM_GUARD_NOT_NIL(...) \
    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(_UEX_PARAM_GUARD_NOT_NIL1(__VA_ARGS__))(_UEX_PARAM_GUARD_NOT_NIL2(__VA_ARGS__))













#pragma mark - Private


#define _UEX_PARAM_GUARD_NOT_NIL1(param)                                                                            \
    if(!param){                                                                                                     \
        ACLogError(@"%s error! parameter '%s' should not be null",__FUNCTION__,metamacro_stringify(param));         \
        return;                                                                                                     \
    }

#define _UEX_PARAM_GUARD_NOT_NIL2(param,returnValue)                                                                \
    if(!param){                                                                                                     \
        ACLogError(@"%s error! parameter '%s' should not be null",__FUNCTION__,metamacro_stringify(param));         \
        return returnValue;                                                                                         \
    }

#define _UEX_PARAM_GUARD1(condition)                                                                                \
    if(!(condition)){                                                                                               \
        ACLogError(@"%s error! parameters not satisfy: %s",__FUNCTION__,metamacro_stringify(condition));            \
        return;                                                                                                     \
    }

#define _UEX_PARAM_GUARD2(condition,returnValue)                                                                    \
    if(!(condition)){                                                                                               \
        ACLogError(@"%s error! parameters not satisfy: %s",__FUNCTION__,metamacro_stringify(condition));            \
        return returnValue;                                                                                         \
    }






#define _uexErrorMake1(code)                            \
    _uex_ErrorMake(code,nil,nil,__FUNCTION__)
#define _uexErrorMake2(code,desc)                       \
    _uex_ErrorMake(code,desc,nil,__FUNCTION__)
#define _uexErrorMake3(code,desc,info)                  \
    _uex_ErrorMake(code,desc,info,__FUNCTION__)


APPCAN_EXPORT UEX_ERROR _uex_ErrorMake(NSInteger code,NSString * _Nullable description,NSDictionary * _Nullable info,const char * func);


NS_ASSUME_NONNULL_END
