/**
 *
 *	@file   	: ACEJSCHandler.h  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/1/8.
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
#import <AppCanKit/ACJSContext.h>

@class EBrowserView;


extern NSString *const ACEJSCHandlerInjectField;





/**
 *  AppCan插件JSBridge交互管理
 */
@interface ACEJSCHandler : NSObject
@property (nonatomic,strong)NSMutableDictionary *pluginDict;
@property (nonatomic,weak)id<AppCanWebViewEngineObject> engine;

/**
 *  注册全局插件
 *
 *  @param pluginClass 插件类名  EUEx开头
 */
+ (void)registerGlobalPlugin:(NSString *)pluginClass;

/// 判断字符串格式是否为AppCanJSBridge，用作JS转OC的路由
+ (BOOL)isAppCanJSBridgePayload:(NSString *)jsPayloadStr;

/// 初始化JSCHandler;
- (void)initializeWithJSContext:(id<ACJSContext>)context;

/// 用于解析JS路由包内容
- (id)executeWithAppCanJSBridgePayload:(NSString *)payloadStr;

/**
 *  @note 此方法用于清除所有插件，以回收资源
 */
- (void)clean;

@end

//EBrowserView
@interface ACEJSCHandler()
@property (nonatomic,weak)EBrowserView *eBrowserView;
- (instancetype)initWithEBrowserView:(EBrowserView *)eBrowserView;
@end


