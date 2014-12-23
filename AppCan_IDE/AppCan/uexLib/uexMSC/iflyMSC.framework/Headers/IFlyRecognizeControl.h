//
//  IFlyRecognizeControl.h
//
//  Description: 语言识别控件
//
//  Created by iflytek on 11-2-23.
//  Copyright 2011 iFLYTEK. All rights reserved.
//


#import <UIKit/UIKit.h>

#define SpeechError int


@class IFlyRecognizeControlImp;
@class IFlyRecognizeControl;

@protocol IFlyRecognizeControlDelegate

/*
	 @function	onResult
	 @abstract	回调返回识别结果
	 @discussion	
	 @param     resultArray - 返回的识别结果，为一个数组，数组中存放的为字典，key值"NAME"对应的为返回结果
*/
- (void)onResult:(IFlyRecognizeControl *)iFlyRecognizeControl theResult:(NSArray *)resultArray;

/*
	@function	onRecognizeEnd
	@abstract	识别结束回调
	@discussion	
	@param	
*/
- (void)onRecognizeEnd:(IFlyRecognizeControl *)iFlyRecognizeControl theError:(SpeechError) error;
@end


@interface IFlyRecognizeControl : UIView
{	
	// 实现部分
	IFlyRecognizeControlImp			 *_iFlyRecognizeControlImp;

	// 接口
	id<IFlyRecognizeControlDelegate> _delegate;
}
@property(assign)id<IFlyRecognizeControlDelegate> delegate;

/*
	@function	initWithOrigin
	@abstract	初始化
	@discussion	
	@param		initParam－初始化参数，用逗号隔开，中间不要有空格
    @param      origin-控件左上角位置
*/
- (id)initWithOrigin:(CGPoint)origin initParam:(NSString *)initParam;

/*
	 @function		setEngine
	 @abstract		设置识别引擎
	 @discussion	默认使用sms
	 @param			engineType - sms,keyword,keywordupload,poi,vsearch,video
	 @param			engineParam - 如:当engineType为poi时,该参数可接受如下参数:@"area=合肥市"
	 @param			grammarID	- 如:当engineType为keyword时,该参数接受的参数为上传命令词时返回的结果
*/
- (void)setEngine:(NSString *)engineType 
   engineParam:(NSString *)engineParam
	 grammarID:(NSString *)grammarID;

/*
	 @function	setSampleRate
	 @abstract	设置录音采样率
	 @discussion	
	 @param		仅支持8k、16k，设置错误或不设置会默认用16k
*/
- (void)setSampleRate:(int)rate;

/*
	 @function      start
	 @abstract      开始识别
	 @discussion	启动语音识别
     @return        启动成功返回YES
*/
- (BOOL)start;

/*
	 @function      cancel
	 @abstract      取消识别
	 @discussion	
*/
- (void)cancel;


/*
	 @function      getUpflow
	 @abstract      查询流量
	 @discussion	
	 @param         返回字节数
     @return        返回字节数
*/
- (int)getUpflow;

/*
	 @function      getUpflow
	 @abstract      查询流量
	 @discussion	
	 @param         返回字节数
*/
- (int)getDownflow;

/*
	 @function      getErrorDescription
	 @abstract      根据错误码获取错误描述
	 @discussion	
	 @param         errorCode - 错误描述码
     @return        返回错误描述
*/
- (NSString *)getErrorDescription:(SpeechError)errorCode;


/*
    @function:      setShowLog
    @abstract:      设置是否在控制台打印log
    @discussion:	
    @param:         
 */
- (void) setShowLog:(BOOL)param;
/*
    @function:      getVersion
    @abstract:      获取版本号
    @discussion:
    @param:
    @return :       返回SDK的版本号
 */
- (NSString *) getVersion;

@end
