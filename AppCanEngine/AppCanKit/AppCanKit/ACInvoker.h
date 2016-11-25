/**
 *
 *	@file   	: ACInvoker.h  in AppCanKit
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


#import <Foundation/Foundation.h>




NS_ASSUME_NONNULL_BEGIN
@interface NSObject(ACInvoker)

/**
 *  @brief NSInvocation的封装,动态调用方法
 *
 *  @discussion 本Category支持参数和返回值均为以下类型的方法
        - void
        - objc_class (Class类型)
        - NSObject及其子类
        - 基础数据类型,包括int8,int16,int32,int64及他们相应的无符号整形,bool,float,double以及UTF8编码的char *
        - CoreGraphics结构体 包括CGRect,CGSize,CGPoint 以及 UIEdgeInsets
 * @warning 当参数或者返回值类型不在上述类型中时,使用本Category中的方法可能会发生未知错误
 *
 * @discussion 本Category的返回值遵循以下规则
        - void类型或者调用失败时返回nil
        - objc_class会返回Class类型
        - NSObject及其子类会直接返回
        - char * 会用NSString进行封装
        - 其他基础类型会用NSNumber进行封装
        - CoreGraphics结构体会用相应的NSValue进行封装
 *  @note 调用方法传入参数时,也应该遵循以上规则
 *
 */




/**
 *  调用名为selector的实例方法
 *
 *  @param selector 要调用的方法名
 *  @param arguments 调用方法的参数
 *
 *  @return 调用的结果
 */

- (id)ac_invoke:(NSString *)selector arguments:(nullable NSArray *)arguments;

/**
 * 调用名为selector的实例方法
 * 是以上方法的封装,无需传入参数时可直接使用本方法
 */
- (id)ac_invoke:(NSString *)selector;

/**
 *  调用名为selector的类方法
 *
 *  @param selector 要调用的方法名
 *  @param arguments 调用方法的参数
 *
 *  @return 调用的结果
 */
+ (id)ac_invoke:(NSString *)selector arguments:(nullable NSArray *)arguments;

/**
 * 调用名为selector的实例方法
 * 是以上方法的封装,无需传入参数时可直接使用本方法
 */
+ (id)ac_invoke:(NSString *)selector;


@end
NS_ASSUME_NONNULL_END
