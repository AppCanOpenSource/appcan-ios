/**
 *
 *	@file   	: ACPluginBundle.h  in AppCanKit
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

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (ACPluginBundle)
/**
 *  获取插件的资源包实例
 *
 *  @param pluginName 插件名
 *  @return 插件同名的资源文件对应的NSBundle实例
 */
+ (nullable instancetype)ac_bundleForPlugin:(NSString *)pluginName;
@end

@interface NSString (ACPluginBundle)
/**
 *  插件国际化
 *
 *  @param pluginName 插件名
 *  @param key        插件bundle中Localizable.string里声明的字符串key
 *  @param defaultValue 如果有传入第二个参数，即为defaultValue key匹配失败时会返回此值
 *  @return key对应的国际化字符串
 */
+ (instancetype)ac_plugin:(NSString *)pluginName localizedString:(NSString *)key,...;
@end

NS_ASSUME_NONNULL_END