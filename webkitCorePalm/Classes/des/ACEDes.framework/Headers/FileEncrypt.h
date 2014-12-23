//
//  FileEncrypt.h
//  WebKitCorePlam
//
//  Created by 正益无线 on 11-10-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//#include "encrypt.cpp"
//#import "c_md5c.h"
@interface FileEncrypt : NSObject {

}
//path为绝对路径
//判断网页是否是被加密
//-(BOOL)isEncrypted:(NSString *)path;
//解密一个网页，返回解密后的数据
-(NSString  *)decryptWithPath:(NSURL *)url appendData:(NSString *)appData;
@end
