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

#import "AllConfigParser.h"
#import "BUtility.h"
@implementation AllConfigParser

-(NSMutableDictionary *)initwithReqData:(id)inXmlData{
	NSData *xmlData =nil;
	if  ([inXmlData isKindOfClass: [ NSString class]]){
		if ([inXmlData hasPrefix:@"http://"]) {
			NSURL *urlReq = [ NSURL URLWithString:inXmlData];
			xmlData = [NSData dataWithContentsOfURL:urlReq];
		}else {
			xmlData = [NSData dataWithContentsOfFile:inXmlData];
		}	
	}else if([inXmlData isKindOfClass:[NSData class]]){
		xmlData = [NSData dataWithData:inXmlData];
	}
	if (xmlData==nil) {
		return nil;
	}else {
		dataDict = [NSMutableDictionary dictionaryWithCapacity:20] ;
		mParser = [[NSXMLParser alloc] initWithData:xmlData];
		[mParser setDelegate:self];
		[mParser setShouldProcessNamespaces:YES];
		[mParser setShouldReportNamespacePrefixes:YES];
		[mParser setShouldResolveExternalEntities:NO];
		BOOL success = [mParser parse];
		if(success){
			ACENSLog(@"[XMLparser success]");
		}else{
			ACENSLog(@"[XMLparser failed]");
		}
	}
    
	return dataDict;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{ 
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithCapacity:10];
	if ([elementName caseInsensitiveCompare:CONFIG_TAG_WIDGET]==NSOrderedSame) {
		if (attributeDict!=nil) {
			[tmpDict removeAllObjects];
			if ([attributeDict objectForKey:CONFIG_TAG_APPID]) {
				[tmpDict setObject:[attributeDict objectForKey:CONFIG_TAG_APPID] forKey:CONFIG_TAG_APPID];
			}
			if ([attributeDict objectForKey:@"appid"]) {
				[tmpDict setObject:[attributeDict objectForKey:@"appid"] forKey:CONFIG_TAG_APPID];
			}
			if ([attributeDict objectForKey:CONFIG_TAG_VERSION]) {
				[tmpDict setObject:[attributeDict objectForKey:CONFIG_TAG_VERSION] forKey:CONFIG_TAG_VERSION];
			}
			if ([attributeDict objectForKey:CONFIG_TAG_CHANNELCODE]) {
				[tmpDict setObject:[attributeDict objectForKey:CONFIG_TAG_CHANNELCODE] forKey:CONFIG_TAG_CHANNELCODE];
			}
			if ([attributeDict objectForKey:@"channelcode"]) {
				[tmpDict setObject:[attributeDict objectForKey:@"channelcode"] forKey:CONFIG_TAG_CHANNELCODE];
			}
			[dataDict setObject:tmpDict forKey:CONFIG_TAG_WIDGET];
		}
	}else if ([elementName caseInsensitiveCompare:CONFIG_TAG_AUTHOR]==NSOrderedSame) {
		[tmpDict setObject:attributeDict forKey:CONFIG_TAG_AUTHOR];
		[dataDict addEntriesFromDictionary:tmpDict];
	}else if ([elementName caseInsensitiveCompare:CONFIG_TAG_LICENSE]==NSOrderedSame) {
		[tmpDict setObject:attributeDict forKey:CONFIG_TAG_LICENSE];
		[dataDict addEntriesFromDictionary:tmpDict];
	}else if ([elementName caseInsensitiveCompare:CONFIG_TAG_ICON]==NSOrderedSame) {
		[tmpDict removeAllObjects];
		[tmpDict setObject:attributeDict forKey:CONFIG_TAG_ICON];
		[dataDict addEntriesFromDictionary:tmpDict];
	}else if([elementName caseInsensitiveCompare:CONFIG_TAG_CONTENT]==NSOrderedSame){
		[tmpDict removeAllObjects];
		[tmpDict setObject:attributeDict forKey:CONFIG_TAG_CONTENT];
		[dataDict addEntriesFromDictionary:tmpDict];
    }else if([elementName caseInsensitiveCompare:CONFIG_TAG_WINDOWBACKGROUND]==NSOrderedSame){
        if (attributeDict!=nil) {
            [tmpDict removeAllObjects];
            if ([attributeDict objectForKey:@"opaque"]) {
                [tmpDict setObject:[attributeDict objectForKey:@"opaque"] forKey:@"opaque"];
            }
            if ([attributeDict objectForKey:@"bgColor"]) {
                [tmpDict setObject:[attributeDict objectForKey:@"bgColor"] forKey:@"bgColor"];
            }
            [dataDict setObject:tmpDict forKey:CONFIG_TAG_WINDOWBACKGROUND];
        }
    }
	element = @"";
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)tagText{
	if ([tagText isEqualToString:@"\n\t"]==NO) {
		//element = tagText;
		element = [element stringByAppendingString:tagText];
	}

}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{

	//
//	NSMutableDictionary *elementDict = nil;
	if([elementName caseInsensitiveCompare:CONFIG_TAG_AUTHOR]==NSOrderedSame){
		NSDictionary * tempDic =[dataDict objectForKey:CONFIG_TAG_AUTHOR];
        NSMutableDictionary * elementDict = [NSMutableDictionary dictionary];
        if ([tempDic isKindOfClass:[NSDictionary class]] && [tempDic allKeys].count > 0) {
            elementDict = [NSMutableDictionary dictionaryWithDictionary:tempDic];
        }else{
            elementDict = nil;
        }
        
		if (elementDict!=nil) {
			[elementDict setObject:element  forKey:CONFIG_TAG_NAME];
			[dataDict setObject:elementDict forKey:CONFIG_TAG_AUTHOR];
		}else {
			[dataDict setObject:element forKey:CONFIG_TAG_AUTHOR];
		}

	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_NAME]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_NAME];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_DESCRIPTION]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_DESCRIPTION];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_OBFUSCATION]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_OBFUSCATION];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_LOGSERVERIP]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_LOGSERVERIP];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_UPDATEURL]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_UPDATEURL];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_SHOWMYSPACE]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_SHOWMYSPACE];
	}
    if([elementName caseInsensitiveCompare:CONFIG_TAG_WEBAPP]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_WEBAPP];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_ORIENTATION]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_ORIENTATION];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_PRELOAD]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_PRELOAD];
	}
	if([elementName caseInsensitiveCompare:CONFIG_TAG_DEBUG]==NSOrderedSame){
		[dataDict setObject:element forKey:CONFIG_TAG_DEBUG];
	}
//    if([elementName caseInsensitiveCompare:CONFIG_TAG_WINDOWBACKGROUND]==NSOrderedSame){
//        [dataDict setObject:element forKey:CONFIG_TAG_WINDOWBACKGROUND];
//    }
}
- (void)dealloc {
	
	[dataDict removeAllObjects];
	//[dataDict release];
	dataDict = nil;
	[mParser release];
	mParser = nil;
    [super dealloc];
}


@end
