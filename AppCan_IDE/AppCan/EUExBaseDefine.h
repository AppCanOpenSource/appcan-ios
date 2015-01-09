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
