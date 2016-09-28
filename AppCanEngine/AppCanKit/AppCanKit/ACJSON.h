/**
 *
 *	@file   	: ACJSON.h  in AppCanKit
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

@interface NSString (ACJSON)

/**
 *  尝试将一个JSON字符串反序列化为对象
 *
 *  @return 反序列化后的对象,解析失败时返回nil
 */
- (id)ac_JSONValue;

@end


@interface NSObject (ACJSON)

/**
 *  尝试将一个对象(NSString,NSDictionary,NSArray)序列化为JSON字符串
 *  @return 序列化后的JSON字符串,序列化失败时返回nil;
 */
- (NSString *)ac_JSONFragment;
@end