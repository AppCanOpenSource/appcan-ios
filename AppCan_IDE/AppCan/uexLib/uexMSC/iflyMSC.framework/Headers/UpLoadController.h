//
//  UpLoadController.h
//  MSC20Demo
//  ypzhao add
//  Created by ypzhao on 12-10-16.
//
//

#import <UIKit/UIKit.h>

@class DataUploader;
@class UpLoadView;

@protocol UpLoadControllerDelegate

- (void) onGrammer: (NSString*)grammer error: (int)err;

@end

@interface UpLoadController : UIView
{
    DataUploader *_dataUploader;
    UpLoadView   *_upLoadView;
    
    id <UpLoadControllerDelegate> _delegate;
}

@property(assign) id<UpLoadControllerDelegate> delegate;
/**
 * @fn      initWithOrigin
 * @brief   初始化控件
 *
 * @return  
 * @param   CGPoint origin           -[in] 控件的位置
 * @see
 */
- (id) initWithOrigin:(CGPoint) origin;
/**
 * @fn      setContent
 * @brief   设置上传数据
 *
 * @return  
 * @param   NSString* name           -[in] 命令词名称,可以自定义
 * @param   NSString* data           -[in] 命令词数据
 * @param   NSString* params         -[in] 上传的参数
 * @see
 */
- (void) setContent: (NSString *)name data: (NSString*)data params: (NSString*)params;
/**
 * @fn      setContent
 * @brief   开始上传
 *
 * @return  
 * @see
 */
- (void) start;

@end
