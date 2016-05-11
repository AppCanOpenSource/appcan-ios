/**
 *
 *	@file   	: ACEAvailable.h  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/10.
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
#import "ACEMetamacros.h"
#define _ACE_Version() (_ACE_ACEAvailability ? [_ACE_ACEAvailability_Class engineVersion] : @"0")
#define _ACE_VersionCode() (_ACE_ACEAvailability ? [_ACE_ACEAvailability_Class engineVersionCode] : 0)

#define _ACE_Available(...) \
    metamacro_if_eq(1, metamacro_argcount(0,##__VA_ARGS__))(_ACE_Available1())(_ACE_Available2(__VA_ARGS__))

#define _ACE_Available1() \
    (_ACE_ACEAvailability ? [_ACE_ACEAvailability_Class compareWithVersion:@"3.4.0"] != NSOrderedAscending : NO)

#define _ACE_Available2(ver) \
    (_ACE_ACEAvailability ? [_ACE_ACEAvailability_Class compareWithVersion:ver] != NSOrderedAscending : NO)

#define _ACE_ACEAvailability \
    (_ACE_ACEAvailability_Class ? YES : NO)

#define _ACE_iOSVersion \
    ([[[UIDevice currentDevice] systemVersion] floatValue])

#define _ACE_ACEAvailability_Class _ACE_ClassFromName(ACEAvailability)

@protocol ACEAvailability <NSObject>


/**
 *  当前引擎的版本
 *
 *  @return 版本,比如@"3.4.0"
 */
+ (NSString *)engineVersion;

/**
 *  当前引擎版本号,转换规则如下
 *  3.4.0 => 30400
 *  3.5.2 => 30502
 *
 *  @return 版本号
 */
+ (NSInteger)engineVersionCode;


/**
 *  比较当前版本和指定版本的大小
 *
 *  @param ver 指定的版本
 *
 *  @return NSOrderedAscending:当前版本小于指定版本 NSOrderedSame:当前版本等于指定版本 NSOrderedDescending:当前版本大于指定版本
 */
+ (NSComparisonResult)compareWithVersion:(NSString *)ver;

@end



