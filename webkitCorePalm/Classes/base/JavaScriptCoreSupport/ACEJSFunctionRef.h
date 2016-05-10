/**
 *
 *	@file   	: ACEJSFunctionRef.h  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/5.
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
@class JSValue;
@interface ACEJSFunctionRef : NSObject



/**
 *  执行JSFunction
 *
 *  @param args 执行的参数,每一个参数都必须能够被转换成JSValue 详见https://developer.apple.com/library/ios/documentation/JavaScriptCore/Reference/JSValue_Ref/
 *  @param completionHandler JS端的函数执行完毕时,会触发此block,此block有一个JSValue类型的参数，是JS端函数的返回值
 */
- (void)executeWithArguments:(NSArray *)args completionHandler:(void (^)(JSValue *returnValue))completionHandler;

@end
