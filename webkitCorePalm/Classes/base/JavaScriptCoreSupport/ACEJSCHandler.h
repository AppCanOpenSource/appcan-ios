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
#import <JavaScriptCore/JavaScriptCore.h>
@class EBrowserView;



@protocol ACEJSCHandler <JSExport>



JSExportAs(execute,-(id)executeWithPlugin:(NSString *)pluginName method:(NSString *)methodName arguments:(NSArray *)arguments asyncKey:(NSString *)asyncKey);


@end





@interface ACEJSCHandler : NSObject<ACEJSCHandler>
@property (nonatomic,strong)NSMutableDictionary *pluginDict;
@property (nonatomic,weak)EBrowserView *eBrowserView;

/**
 *  注册全局插件
 *
 *  @param pluginClass 插件类名  EUEx开头
 */
+ (void)registerGlobalPlugin:(NSString *)pluginClass;


- (instancetype)initWithEBrowserView:(EBrowserView *)eBrowserView;




@end
