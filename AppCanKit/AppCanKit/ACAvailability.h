/**
 *
 *	@file   	: ACAvailability.h  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/31.
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


/**
 *  获得当前引擎版本
 *
 *  @return NSString类型 当前引擎的版本,比如@"4.0.0"
 */
#define ACEnginVersion() \
    ([ACAvailability engineVersion])

/**
 *  获得当前引擎版本号
 *
 *  @discussion 版本=>版本号的转换规则如下
 *  @"4.1.0"  => 40100
 *  @"4.2.11" => 40211
 *
 *  @return NSInteger类型 版本号
 */
#define ACEngineVersionCode() \
    ([ACAvailability engineVersionCode])

/**
 *  判断某个引擎版本是否可用
 *
 *  @param ver NSString类型 指定的引擎版本 比如@"4.0.1"
 *
 *  @return BOOL类型 若 当前引擎版本大于等于指定引擎版本 返回YES 否则返回NO
 */
#define ACEngineAvailable(ver) \
    ([ACAvailability isEngineAvailable:ver])




/**
 *  当前iOS系统的版本号
 *
 *  @return float类型 比如9.3
 */
#define ACSystemVersion() \
    ([[[UIDevice currentDevice] systemVersion] floatValue])





















#pragma mark - 不要直接用这个类的方法>.<

@interface ACAvailability : NSObject

+ (BOOL)isEngineAvailable:(NSString *)engineVersion;
+ (NSString *)engineVersion;
+ (NSInteger)engineVersionCode;
@end






