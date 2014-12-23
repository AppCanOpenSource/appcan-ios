//
//  EUExBaseDefine.h
//  WBPalmLib
//
//  Created by 邹 达 on 12-4-17.
//  Copyright 2012 zywx. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UEX_PLATFORM_CALL_ARGS		5
//json,text,int
#define UEX_CALLBACK_DATATYPE_TEXT	0
#define UEX_CALLBACK_DATATYPE_JSON	1
#define UEX_CALLBACK_DATATYPE_INT	2
//const true/false
#define UEX_CTRUE				1
#define UEX_CFALSE				0
//success failed
#define UEX_CSUCCESS			0
#define UEX_CFAILED			1
//define error destribution
#define UEX_ERROR_DESCRIBE_ARGS				@"参数错误"
#define UEX_ERROR_DESCRIBE_FILE_EXIST		@"文件不存在"
#define UEX_ERROR_DESCRIBE_FILE_FORMAT		@"文件格式错误"
#define UEX_ERROR_DESCRIBE_FILE_OPEN		@"文件未打开错误"
#define UEX_ERROR_DESCRIBE_FILE_SAVE		@"保存文件失败"
#define UEX_ERROR_DESCRIBE_STORAGE_DEVICE   @"存储设备错误"
#define UEX_ERROR_DESCRIBE_FILE_TOO_LARGE   @"文件过大"
#define UEX_ERROR_DESCRIBE_DEVICE_SUPPORT   @"设备不支持错误"
#define UEX_ERROR_DESCRIBE_CONFIG			@"config文件未配置"

@interface EUExBaseDefine : NSObject {

}

@end
