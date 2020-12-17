//
//  FileEncrypt.h
//  WebKitCorePlam
//
//  Created by 正益无线 on 11-10-18.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileEncrypt : NSObject {
    
}
+(BOOL)isDataEncrypted:(NSData *)srcData;

-(NSString  *)decryptWithPath:(NSURL *)url appendData:(NSString *)appData;
@end

