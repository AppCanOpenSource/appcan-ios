/**
 *
 *	@file   	: ACEPluginInfo.h  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/1/9.
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

//#define ACE_METHOD_ASYNC @"AsyncMethod"
//#define ACE_METHOD_SYNC @"SyncMethod"

@class ONOXMLElement;

typedef NS_ENUM(NSInteger,ACEPluginMethodExecuteMode){
    ACEPluginMethodExecuteModeAsynchronous = 0,
    ACEPluginMethodExecuteModeSynchronous
};



@interface ACEPluginInfo : NSObject
@property (nonatomic,strong)NSString *uexName;
/**
 *  methods = {方法名:@(executeMode)}
 */
@property (nonatomic,strong)NSMutableDictionary<NSString *,NSNumber *> *methods;
/**
 *  properties = {属性名:值}
 */
@property (nonatomic,strong)NSMutableDictionary<NSString *,NSString *> *properties;

- (instancetype)initWithName:(NSString *)uexName;


-(void)updateWithXMLElement:(ONOXMLElement *)XMLElement;
@end
