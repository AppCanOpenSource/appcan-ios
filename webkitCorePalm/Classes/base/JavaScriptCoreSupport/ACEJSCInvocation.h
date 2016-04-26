/**
 *
 *	@file   	: ACEJSCInvocation.h  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/4/21.
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

typedef NS_ENUM(NSInteger,ACEJSValueType){
    ACEJSValueTypeNotJSValue = -2,
    ACEJSValueTypeUnknown = -1,
    ACEJSValueTypeUndefined = 0,
    ACEJSValueTypeNull,
    ACEJSValueTypeNumber,
    ACEJSValueTypeFunction,
    ACEJSValueTypeObject,
    ACEJSValueTypeBoolean,
    ACEJSValueTypeString,
    ACEJSValueTypeArray,//iOS 9+
    ACEJSValueTypeDate,//iOS 9+
    
};


@interface ACEJSCInvocation : NSObject




+ (instancetype)invocationWithFunction:(JSValue *)function
                             arguments:(NSArray *)arguments
                     completionHandler:(void (^)(JSValue * returnValue))completionHandler;

- (void)invoke;

- (void)invokeOnMainThread;


+ (ACEJSValueType)JSTypeOf:(JSValue *)value;

@end
