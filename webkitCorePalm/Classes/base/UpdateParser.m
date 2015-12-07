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

#import "UpdateParser.h"
#import "BUtility.h"
@implementation UpdateParser
-(NSMutableDictionary *)initwithReqData:(id)inXmlData{
	queryDict = [NSMutableDictionary dictionaryWithCapacity:20];
	NSData *xmlData =nil;
	if  ([inXmlData isKindOfClass: [ NSString class]]){
		if ([inXmlData hasPrefix:@"http://"]) {
			NSURL *urlReq = [ NSURL URLWithString:inXmlData];
            NSHTTPURLResponse *response = nil;
            NSError *error = nil;
            NSURLRequest *req = [NSURLRequest requestWithURL:urlReq];
          NSData *responseData =   [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
 			//NSLog(@"error=%@",error);
			if (!error) {
				//NSLog(@"response=%d",[req responseStatusCode]);
				[queryDict setObject:[NSNumber numberWithInt:[response statusCode]] forKey:@"statusCode"];
				xmlData = responseData;
			}
		}	
	}
	
	ACENSLog(@"xmlData=%@",xmlData);
	if (xmlData==nil) {
		return nil;
	}else {
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
	return queryDict;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{ 
	[queryDict addEntriesFromDictionary:attributeDict];
	element = @"";
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)tagText{
	if ([tagText isEqualToString:@"\n\t"]==NO) {
		element = [element stringByAppendingString:tagText];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	[queryDict setObject:element forKey:elementName];
}

-(void)dealloc{
	[mParser dealloc];
	mParser = nil;
	[super dealloc];
}
@end
