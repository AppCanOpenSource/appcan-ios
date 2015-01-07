/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "ACECustomURLProtocol.h"
#import "WidgetOneDelegate.h"
#import "WWidget.h"
#import "FileEncrypt.h"
#import "BUtility.h"

@implementation ACECustomURLProtocol

+ (void)enable
{
    [NSURLProtocol registerClass:[ACECustomURLProtocol class]];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    // Do something here with request.URL.absolutestring
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    if (app.enctryptcj == F_WWIDGET_NO_ENCRYPTCJ) {
        
        return NO;
        
    }
    
    NSString *absoluteStr = [[request URL] absoluteString];
    
    if ([absoluteStr hasSuffix:@".css"]
        || [absoluteStr hasSuffix:@".js"]) {
        
        return YES;
    }

    
    
    
    return NO;
}

+ (NSURLRequest*) canonicalRequestForRequest:(NSURLRequest *)req
{
    return req;
}

- (void) startLoading
{
    
    NSString *urlResSpec = [self.request.URL resourceSpecifier];
    
    NSString* filePath = urlResSpec;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSData *data = nil;
    
    if ([fileManager fileExistsAtPath:filePath])
    {
        data = [NSData dataWithContentsOfFile:filePath];
        
        
        BOOL isEncrypt = [FileEncrypt isDataEncrypted:data];
        
        if (isEncrypt) {
            NSURL *url = nil;
            if ([filePath hasSuffix:@"file://"]) {
                url = [BUtility stringToUrl:filePath];;
            } else {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", filePath]];
            }
            
            FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
            NSString *enData = [encryptObj decryptWithPath:url appendData:nil];
            
            [encryptObj release];
            
            data = [enData dataUsingEncoding:NSUTF8StringEncoding];
        }

    }

    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:[self.request URL] MIMEType:@"text/plain" expectedContentLength:[data length] textEncodingName:nil];
    
    [[self client] URLProtocol: self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [[self client] URLProtocol:self didLoadData:data];
    [[self client] URLProtocolDidFinishLoading:self];
    
    [response release];
}

- (void) stopLoading
{
    
}


@end
