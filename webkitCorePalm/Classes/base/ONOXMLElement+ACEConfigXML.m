/**
 *
 *	@file   	: ONOXMLElement+ACEConfigXML.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 *
 *	@date   	: Created on 16/5/19.
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

#import "ONOXMLElement+ACEConfigXML.h"
#import "WidgetOneDelegate.h"
#import "BUtility.h"
@implementation ONOXMLElement (ACEConfigXML)

static ONOXMLDocument * originDocument = nil;
static ONOXMLDocument * newestDocument = nil;

__attribute__((constructor)) static void buildDocuments (void){
    NSString *XMLPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"widget/config.xml"];
    NSString *XMLString = [NSString stringWithContentsOfFile:XMLPath encoding:NSUTF8StringEncoding error:nil];
    originDocument = [ONOXMLDocument XMLDocumentWithString:XMLString encoding:NSUTF8StringEncoding error:nil];
    
    if (theApp.useUpdateWgtHtmlControl && [[[NSUserDefaults standardUserDefaults]objectForKey:F_UD_WgtCopyFinish] boolValue]) {
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *XMLPath = [documentPath stringByAppendingPathComponent:@"widget/config.xml"];
        NSData *data = [NSData dataWithContentsOfFile:XMLPath];
        if (data) {
            newestDocument = [ONOXMLDocument XMLDocumentWithData:data error:nil];
        }
    }
}

+ (instancetype)ACEOriginConfigXML{
    return originDocument.rootElement;
}

+ (instancetype)ACENewestConfigXML{
    if (newestDocument) {
        return newestDocument.rootElement;
    }
    return originDocument.rootElement;
}

@end
