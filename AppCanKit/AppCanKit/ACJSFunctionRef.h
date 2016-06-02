/**
 *
 *	@file   	: ACJSFunctionRef.h  in AppCanKit
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
 
#import <Foundation/Foundation.h>

/**
 *  使用包含JSValue的方法时,需在头文件引入<JavaScriptCore/JavaScriptCore.h>
 */
@class JSValue;


/**
 *  AppCan JavaScript Function Reference
 *  此对象对应着一个对JS函数的引用
 *  在此对象被释放前,只要JS上下文没有被销毁,此对象会保证其对应的JS函数不被GC机制回收
 */
@interface ACJSFunctionRef : NSObject


/**
 *  执行JSFunction
 *
 *  @param args 执行的参数,每一个参数都必须能够被转换成JSValue 详见https://developer.apple.com/library/ios/documentation/JavaScriptCore/Reference/JSValue_Ref/
 *  @param completionHandler JS端的函数执行完毕时,会触发此block,此block有一个JSValue类型的参数，是JS端函数的返回值
 *
 */
- (void)executeWithArguments:(nullable NSArray *)args completionHandler:(nullable void (^)(JSValue * _Nullable returnValue))completionHandler;


/**
 *  执行JSFunction,参数同上
 *  不需要关心返回值时可以使用此方法
 */
- (void)executeWithArguments:(nullable NSArray *)args;



@end







