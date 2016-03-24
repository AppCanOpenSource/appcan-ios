/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
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

@class EBrowserView;
@interface EUExBase :NSObject{
    __unsafe_unretained EBrowserView *meBrwView;
}

//插件所在的网页实例
@property (nonatomic, assign) EBrowserView *meBrwView;

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


