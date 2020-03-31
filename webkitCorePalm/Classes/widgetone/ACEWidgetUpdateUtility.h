/**
 *
 *	@file   	: ACEWidgetUpdateUtility.h  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2017/2/10
 *
 *	@copyright 	: 2017 The AppCan Open Source Project.
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

//更新操作结果
typedef NS_ENUM(NSInteger,ACEWidgetUpdateResult) {
    ACEWidgetUpdateResultNotNeeded = -1,//当前应用不需要更新
    ACEWidgetUpdateResultSuccess = 0,   //更新成功
    ACEWidgetUpdateResultError = 1      //更新失败
};


@interface ACEWidgetUpdateUtility: NSObject
//应用是否支持热更新
@property (nonatomic,readonly,class)BOOL isWidgetUpdateEnabled;
//widget是否被成功拷贝至document文件夹
@property (nonatomic,assign,class)BOOL isWidgetCopyFinished;
//是否需要拷贝widget至document文件夹
@property (nonatomic,readonly,class)BOOL isWidgetCopyNeeded;
//当前document文件夹内的widget相对路径
@property (nonatomic,readonly,class)NSString *currentWidgetPath;
//当前document文件夹内的widget版本
@property (nonatomic,readonly,class)NSString *currentWidgetVersion;


/**
 拷贝widget至document文件夹
 @note 同步方法,拷贝操作会阻塞当前线程
 @param error NSError类型的指针,拷贝出错时会传出错误
 @return 是否拷贝成功
 */
+ (BOOL)copyMainWidgetToDocumentWithError:(NSError * _Nullable __autoreleasing *)error;

//当前widget是否需要更新
@property (nonatomic,readonly,class)BOOL isMainWidgetNeedPatchUpdate;

/**
 设置当前widget需要更新
 @note 调用此方法后,isMainWidgetNeedPatchUpdate会被置为YES
 @param patchZipPath 更新需要的的patchZip包路径
 @discussion
 */
+ (void)setMainWidgetNeedPatchUpdate:(NSString * __nullable)patchZipPath;

/**
 更新当前widget
 @note 同步方法,更新操作会阻塞当前线程
 @note isMainWidgetNeedPatchUpdate为YES时才会进行更新操作;更新成功后isMainWidgetNeedPatchUpdate会被置为NO,更新用到的zip包会被删除
 @note 每次应用启动后,会调用一次此方法
 @return 更新结果
 */
+ (ACEWidgetUpdateResult)installMainWidgetPatch;



/**
 
 @note
 @param subWidgetPatchZipPath  解压该路径下的zip包.
 @discussion
 */
+ (void)unZipSubWidgetNeedPatchUpdate:(NSString *)subWidgetPatchZipPath;

@end
NS_ASSUME_NONNULL_END
