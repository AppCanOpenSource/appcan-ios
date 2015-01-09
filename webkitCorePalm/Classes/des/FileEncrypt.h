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

//#include "encrypt.cpp"
//#import "c_md5c.h"
@interface FileEncrypt : NSObject {
    
}
//path为绝对路径
//判断网页是否是被加密
//-(BOOL)isEncrypted:(NSString *)path;

+(BOOL)isDataEncrypted:(NSData *)srcData;

//解密一个网页，返回解密后的数据
-(NSString  *)decryptWithPath:(NSURL *)url appendData:(NSString *)appData;
@end
