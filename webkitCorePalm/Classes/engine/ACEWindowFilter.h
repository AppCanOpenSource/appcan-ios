/**
 *
 *	@file   	: ACEWindowFilter.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/28
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


@protocol ACEWindowBlacklist <NSObject>

@optional

/**
 是否禁止特定名字的window打开

 @param windowName 要打开的windowName
 @return YES表示 **禁止**
 */
+ (BOOL)shouldBanWindowWithName:(NSString *)windowName;

/**
  是否禁止特定名字的popover打开

 @param popoverName 要打开的popoverName
 @param windowName 打开此popover的windowName
 @return YES表示 **禁止**
 */
+ (BOOL)shouldBanPopoverWithName:(NSString *)popoverName inWindow:(NSString *)windowName;
@end




@interface ACEWindowFilter: NSObject<ACEWindowBlacklist>

/**
 注册全局的window黑名单
 
 @param blacklistClass 要添加的黑名单的Class,必须遵循ACEWindowBlacklist协议
 @return 是否注册成功
 */
+ (BOOL)registerBlacklist:(Class<ACEWindowBlacklist>) blacklistClass;
@end




