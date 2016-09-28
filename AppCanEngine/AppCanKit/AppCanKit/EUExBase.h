/**
 *
 *	@file   	: EUExBase.h  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/27.
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
#import <UIKit/UIKit.h>
#import "ACMetamacros.h"
#import "AppCanObjectProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class JSValue;





/**
 *  AppCan插件基类
 */
@interface EUExBase : NSObject<AppCanApplicationEventObserver>

@property (nonatomic, weak) id<AppCanWebViewEngineObject> webViewEngine;

#pragma mark - Global Object
/**
 *  获取当前应用root网页的webViewEngine
 */
APPCAN_EXPORT id<AppCanWebViewEngineObject> AppCanRootWebViewEngine(void);


/**
 *  获取当前应用的主widget
 */
APPCAN_EXPORT id<AppCanWidgetObject> AppCanMainWidget(void);

#pragma mark - Life Cycle


/**
 *  插件默认的初始化方法
 *  重载此方法,以进行插件默认的初始化操作,重载时必须先调用[super initWithEngine:engine]
 */
- (instancetype)initWithWebViewEngine:(id<AppCanWebViewEngineObject>)engine NS_REQUIRES_SUPER;


/**
 *  网页关闭,网页引擎被销毁前会调用此方法
 *  重载此方法以进行清除缓存等操作
 *
 *  @note 此方法被调用后,插件不应该再对网页引擎进行任何操作
 */
- (void)clean;

#pragma mark - Absolute Path

/**
 *  解析协议路径获取绝对路径
 *
 *  @param inPath AppCan协议路径
 *  @return 绝对路径,
 */
- (NSString *)absPath:(NSString*)inPath;

@end












/**
 *  3.X Legacy Capability
 *  ALL properties and methods below are DEPRECATED!
 *
 */
@class EBrowserView;
@interface EUExBase(){
    __weak EBrowserView* meBrwView APPCAN_LEGACY_PROPERTY;
}
@property (nonatomic,weak)EBrowserView *meBrwView APPCAN_LEGACY_METHOD;
- (instancetype)initWithBrwView:(id<AppCanWebViewEngineObject>)eInBrwView APPCAN_LEGACY_METHOD;
- (void)stopNetService APPCAN_LEGACY_METHOD;
- (void)jsSuccessWithName:(NSString *)inCallbackName opId:(int)inOpId dataType:(int)inDataType strData:(NSString*)inData APPCAN_LEGACY_METHOD;
- (void)jsSuccessWithName:(NSString *)inCallbackName opId:(int)inOpId dataType:(int)inDataType intData:(int)inData APPCAN_LEGACY_METHOD;
- (void)jsFailedWithOpId:(int)inOpId errorCode:(int)inErrorCode errorDes:(NSString*)inErrorDes APPCAN_LEGACY_METHOD;
@end


NS_ASSUME_NONNULL_END