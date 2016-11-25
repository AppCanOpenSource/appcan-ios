/**
 *
 *	@file   	: ACJSFunctionRefInternal.h  in AppCanKit
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 16/5/30.
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


@class JSManagedValue;
@class JSVirtualMachine;

NS_ASSUME_NONNULL_BEGIN
@interface ACJSFunctionRef()

@property (nonatomic,strong)JSManagedValue *managedFunction;
@property (nonatomic,strong)NSString *identifier;
@property (nonatomic,weak)JSVirtualMachine *machine;
@property (nonatomic,weak)JSContext *ctx;

/**
 *  根据JSValue获得一个ACJSFunctionRef
 *  @brief 在此对象被释放前,只要JS上下文没有被销毁,此对象会保证其对应的JS函数不被GC机制回收
 *
 *  @param value 必须是一个JS的function。不是function时此方法会返回nil
 */
+ (nullable instancetype)functionRefFromJSValue:(JSValue *)value;

@end

NS_ASSUME_NONNULL_END