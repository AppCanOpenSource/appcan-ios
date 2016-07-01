/**
 *
 *	@file   	: ACJSValueSupport.h  in AppCanKit
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
#import <JavaScriptCore/JavaScriptCore.h>
typedef NS_ENUM(NSInteger,ACJSValueType){
    ACJSValueTypeUnknown = -1,
    ACJSValueTypeUndefined = 0,
    ACJSValueTypeNull,
    ACJSValueTypeNumber,
    ACJSValueTypeFunction,
    ACJSValueTypeObject,
    ACJSValueTypeBoolean,
    ACJSValueTypeString,
    ACJSValueTypeArray,//仅iOS 9+. 在低版本系统上,JS Array会返回ACJSValueTypeObject
    ACJSValueTypeDate,//仅iOS 9+. 在低版本系统上,JS Date会返回ACJSValueTypeObject
    
};

@interface JSValue (AppCanKit)

/**
 *  返回当前JSValue的类型
 */
- (ACJSValueType)ac_type;


/**
 *  调用一个JS函数
 *
 *  @param arguments
 *  @param waitingUntilNextRunLoop  NO-立即执行 YES-加入队列中,等待下一次JS的RunLoop再执行
 *  @discussion                     当此JS函数含有alert或者更新UI操作时,立刻执行可能会导致主线程死锁。因此除非此方法对延迟非常敏感,否则此参数应该传YES
 *  @param queue                    执行JS的线程,不传时默认为主线程。
 *  @discussion                     对基于UIWebView实现的AppCan网页,必须在主线程中调用JS函数
 *  @param completionHandler        执行完毕时会在queue线程执行此block.此block有参数为调用此JS函数的返回值,当且仅当函数调用失败时，此block参数returnValue为nil。
 *  @discussion                     对于无返回值的JS函数,returnValue为一个代表<undefined>的JSValue,而不是nil
 */
- (void)ac_callWithArguments:(NSArray *)arguments
     waitingUntilNextRunLoop:(BOOL)waitingUntilNextRunLoop
                     inQueue:(dispatch_queue_t)queue
           completionHandler:(void (^)(JSValue * returnValue))completionHandler;

/**
 *  上个方法的便捷实现
 *  在主线程执行JS,在主线程执行completionHandler回调
 */
- (void)ac_callWithArguments:(NSArray *)arguments
           completionHandler:(void (^)(JSValue * returnValue))completionHandler;
/**
 *  不需要返回值时,可以直接使用此方法
 */
- (void)ac_callWithArguments:(NSArray *)arguments;
@end

@interface JSContext(AppCanKit)

/**
 *  根据keyPath获得对应的JSValue
 *  @example [ctx ac_JSValueForKeyPath:@"a.b.c"] 相当于 ctx[@"a"][@"b"][@"c"]
 *
 *  @return keyPath对应的JSValue
 */
- (JSValue *)ac_JSValueForKeyPath:(NSString *)keyPath;
@end


