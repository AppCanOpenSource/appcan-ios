/**
 *
 *	@file   	: ACEConfigXML.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/15
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
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


#import "ACEConfigXML.h"

#import "WidgetOneDelegate.h"
#import "BUtility.h"
#import "FileEncrypt.h"


@implementation ACEConfigXML
static ONOXMLDocument * originDocument = nil;
static ONOXMLDocument * widgetDocument = nil;

__attribute__((constructor)) static void buildDocuments (void){
    NSURL *originConfigURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"widget/config.xml"];
    originDocument = [ONOXMLDocument XMLDocumentWithData:decrytedDataWithURL(originConfigURL) error:nil];
    
    
    if (theApp.useUpdateWgtHtmlControl && [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue]) {
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSURL *documentURL = [NSURL fileURLWithPath:documentPath];
        NSURL *widgetConfigURL = [documentURL URLByAppendingPathComponent:@"widget/config.xml"];
        
        NSData *data = decrytedDataWithURL(widgetConfigURL);
        if (data) {
            widgetDocument = [ONOXMLDocument XMLDocumentWithData:data error:nil];
        }
    }
}

static NSData * _Nullable decrytedDataWithURL(NSURL * fileURL){
    NSData *originData = [NSData dataWithContentsOfURL:fileURL];
    if (!originData || ![FileEncrypt isDataEncrypted:originData]) {
        return originData;
    }
    FileEncrypt *decrypter = [[FileEncrypt alloc]init];
    return [[decrypter decryptWithPath:fileURL appendData:nil] dataUsingEncoding:NSUTF8StringEncoding];
}



+ (ONOXMLElement *)ACEOriginConfigXML{
    return originDocument.rootElement;
}

+ (ONOXMLElement *)ACEWidgetConfigXML{
    if (widgetDocument) {
        return widgetDocument.rootElement;
    }
    return originDocument.rootElement;
}




@end
