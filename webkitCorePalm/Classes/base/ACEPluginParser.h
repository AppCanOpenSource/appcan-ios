/**
 *
 *	@file   	: ACEPluginParser.h  in AppCanEngine Project
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 15/12/15
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
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
#import "ACEPluginInfo.h"

@interface ACEPluginParser : NSObject
/**
 *  pluginDict = {uexXXX:info}
 */
@property (nonatomic,strong)NSMutableDictionary<NSString *,ACEPluginInfo *> *pluginDict;
/**
 *  globalPluginDict = {EUExXXX:NSNull}
 */
@property (nonatomic,strong)NSMutableDictionary<NSString *,id> *globalPluginDict;
- (NSArray *)classNameArray;
- (NSString *)pluginBaseJS;

+ (instancetype)sharedParser;
@end
