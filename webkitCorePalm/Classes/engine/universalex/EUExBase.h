/*
 *  Copyright (C) 2016 The AppCan Open Source Project.
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

#define ACE_JSFunctionRef id<ACEJSFunctionReference>

@class JSValue;
@protocol ACEJSFunctionReference <NSObject>

@required
/**
 *  执行JSFunction
 *
 *  @param args 执行的参数,每一个参数都必须能够被转换成JSValue 详见https://developer.apple.com/library/ios/documentation/JavaScriptCore/Reference/JSValue_Ref/
 *  @param completionHandler JS端的函数执行完毕时,会触发此block,此block有一个JSValue类型的参数，是JS端函数的返回值
 */
- (void)executeWithArguments:(NSArray *)args completionHandler:(void (^)(JSValue *returnValue))completionHandler;
@end




@class EBrowserView;
@interface EUExBase :NSObject{
    __weak EBrowserView *meBrwView;
}

//插件所在的网页实例
@property (nonatomic, weak) EBrowserView *meBrwView;

- (instancetype)initWithBrwView:(EBrowserView *)eInBrwView NS_DESIGNATED_INITIALIZER;
/**
 *  网页被关闭时，会调用此方法;
 */
- (void)clean;

/**
 *  根据协议路径获取绝对路径
 *
 *  @param inPath 协议路径
 *
 *  @return 绝对路径
 */
- (NSString*)absPath:(NSString*)inPath;
@end


@interface EUExBase(Deprecated)
- (void)stopNetService;
- (void)jsSuccessWithName:(NSString *)inCallbackName opId:(int)inOpId dataType:(int)inDataType strData:(NSString*)inData;
- (void)jsSuccessWithName:(NSString *)inCallbackName opId:(int)inOpId dataType:(int)inDataType intData:(int)inData;
- (void)jsFailedWithOpId:(int)inOpId errorCode:(int)inErrorCode errorDes:(NSString*)inErrorDes;
@end


