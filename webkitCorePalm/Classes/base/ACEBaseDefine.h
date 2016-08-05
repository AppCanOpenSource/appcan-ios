/**
 *
 *	@file   	: ACEBaseDefine.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 16/8/2
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








/**
 *  保证parameters满足一定的condition
 *
 *  @param parameter1 - 要满足的condition
 *  @param parameter2 - 不满足condition时此scope的返回值.此参数不传表示没有返回值.
 *
 *  @note 用法参考NSAssert,当condition不满足时,会输出debug日志并退出当前scope
 */

#define UEX_PARAM_GUARD(...) metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(_UEX_PARAM_GUARD1(__VA_ARGS__))(_UEX_PARAM_GUARD2(__VA_ARGS__))

/**
 *  保证param非空
 *
 *  @param parameter1 - 要保证非空的param
 *  @param parameter2 - param为空时此scope的返回值.此参数不传表示没有返回值.
 *
 *  @note 用法参考NSAssert,当condition不满足时,会输出debug日志并退出当前scope
 */
#define UEX_PARAM_GUARD_NOT_NIL(...) metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(_UEX_PARAM_GUARD_NOT_NIL1(__VA_ARGS__))(_UEX_PARAM_GUARD_NOT_NIL2(__VA_ARGS__))



typedef NS_OPTIONS(NSInteger, ACEInterfaceOrientation){
    ACEInterfaceOrientationUnknown = 0,
    ACEInterfaceOrientationProtrait = 1 << 0,
    ACEInterfaceOrientationLandscapeLeft = 1 << 1,
    ACEInterfaceOrientationProtraitUpsideDown = 1 << 2,
    ACEInterfaceOrientationLandscapeRight = 1 << 3
};

APPCAN_EXPORT ACEInterfaceOrientation ace_interfaceOrientationFromUIDeviceOrientation(UIDeviceOrientation orientation);
APPCAN_EXPORT ACEInterfaceOrientation ace_interfaceOrientationFromUIInterfaceOrientation(UIInterfaceOrientation orientation);



#pragma mark - Private


#define _UEX_PARAM_GUARD_NOT_NIL1(param)                                                                            \
    if(!param){                                                                                                     \
        ACLogDebug(@"%s error! parameter '%s' should not be null",__FUNCTION__,metamacro_stringify(param));         \
        return;                                                                                                     \
    }

#define _UEX_PARAM_GUARD_NOT_NIL2(param,returnValue)                                                                \
    if(!param){                                                                                                     \
        ACLogDebug(@"%s error! parameter '%s' should not be null",__FUNCTION__,metamacro_stringify(param));         \
        return returnValue;                                                                                         \
    }

#define _UEX_PARAM_GUARD1(condition)                                                                                \
    if(!(condition)){                                                                                               \
        ACLogDebug(@"%s error! parameters not satisfy: %s",__FUNCTION__,metamacro_stringify(condition));            \
        return;                                                                                                     \
    }



#define _UEX_PARAM_GUARD2(condition,returnValue)                                                                    \
    if(!(condition)){                                                                                               \
        ACLogDebug(@"%s error! parameters not satisfy: %s",__FUNCTION__,metamacro_stringify(condition));            \
        return returnValue;                                                                                         \
    }





