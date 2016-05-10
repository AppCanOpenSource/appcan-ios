/**
 *
 *	@file   	: ACEUtils.h  in AppCanEngine
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
#import "ACEEXTScope.h"

#ifndef ACEUtils_h
#define ACEUtils_h


#pragma mark - Arguments Packing & Unpacking

/**
 *  把若干元素打包成一个数组
 *  若元素为nil,将会用一个的ACENil类型占位符替代。ACENil是一个引擎中定义的类,和NSNull很类似,但在某些方面更像nil,较NSNull更不容易导致崩溃
 *
 *  @param 参数至少得传一个,可以是nil或任意NSObject
 *
 *  @return 一个NSArray,包含所有传入的元素
 *
 *  @discussion 此宏用于解决使用@[]方式构造数组,当其中的参数有为空,会导致崩溃的问题 
 *
 *  @example
 *  id arg1 = ...;
 *  id arg2 = ...;
 *  id arg3 = ...;
 *  NSArray *args = @[arg1,arg2,arg3];//若arg1,arg2,arg3中有一个为nil,则会Crash
 *  NSArray *args = ACE_ArgsPack(arg1,arg2,arg3);//永远是安全的
 *
 *  @note 受宏的机制所限,若参数中包含',' 则需要将此参数用()包含,否则宏展开会报错
 *  比如 ACE_ArgsPack(@"123",@[1,2,3]) -> ERROR!  ACE_ArgsPack(@"123",(@[1,2,3])) -> OK!
 */
#define ACE_ArgsPack(...) \
    _ACE_ArgsPack(__VA_ARGS__)



/**
 *  解包一个参数数组,取出若干参数
 *  @discussion 此宏用于一个等式的左边,宏的参数为所需的参数的定义,多个参数定义之间用","隔开,等式的右边为参数数组
 *      若定义的参数数量小于参数数组个数,则数组中多余的项将会被忽略
 *      若定义的参数数量大于参数数组的个数,则多余的参数会被置为nil
 *      当定义的参数类型为以下之一时,引擎会对此参数进行解析以尽量赋予正确的值,否则会将数组中的项直接赋值给相应的参数
 *      会被引擎解析的类型:NSString,NSNumber,NSDictionary,NSArray,ACEJSFunctionRef.解析规则详见宏末尾的说明
 *
 *  @example
 *      NSArray *args = ...;//获得一个参数数组
 *      ACE_ArgsUnpack(NSString *arg1,NSNumber *arg2,NSArray *arg3) = args;
 *      NSLog(@"参数1:%@ 参数2:%@ 参数3:%@",arg1,arg2,arg3);
 *
 *  @param 定义的参数类型必须是NSObject类型或者id,不支持int等基本类型。若需要获取数值类型的参数,应定义为NSNumber然后进行转换
 *  @note 此宏不能单独存在于一个Scope或者Condition中
 *  @note 此宏所在的等式必须写在同一行中,并且此行最好不要包含其他的内容,否则宏展开可能会出错
 *
 */
#define ACE_ArgsUnpack(...) \
    _ACE_ArgsUnpack(__VA_ARGS__)

/**
 *  ACE_ArgsUnpack参数解析规则
 *  
 *  @class ACENil NSNull
 *      -> 若数组中的参数为此类型,直接返回nil
 *
 *  其他以下所有参数的定义类型,当参数数组中项的类型恰为此类型时,会直接返回,不做任何处理
 *
 *  @class NSString
 *      -> 若数组中对象为NSNumber,返回此number的stringValue
 *      -> 其他情况,返回nil
 *  @class NSNumber
 *      -> 若数组中对象为NSString,且长度 > 0,假定此NSString为一个数字的十进制表示形式,解析得到NSNumber并返回
 *      -> 其他情况返回nil
 *  @class NSDictionary
 *      -> 若数组中的对象为NSString,会以尝试以JSON方式解析此字符串,若解析得到的是一个NSDictionary,则返回
 *      -> 其他情况返回nil
 *  @class NSArray
 *      -> 若数组中的对象为NSString,会以尝试以JSON方式解析此字符串,若解析得到的是一个NSArray,则返回
 *      -> 若此字符串以"["开头,以"]"结尾,会去掉首尾的"[]",然后按","分割字符串得到一个字符串数组并返回(注意,此时返回的是一个NSArray<NSString *> *);
 *      -> 其他情况返回nil
 *  @class ACEJSFunctionRef
 *      -> 若数组中的对象类型不是ACEJSFunctionRef,会直接返回nil
 *
 */

#pragma mark - EXTScope
/**
 *  见ACEEXTScope.h
 */


#endif /* ACEUtils_h */
