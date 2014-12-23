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

#import "SpecConfigParser.h"
#import "BUtility.h"
#import "WidgetSQL.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "WgtReportParser.h"
#import "WidgetOneDelegate.h"
@implementation SpecConfigParser

#pragma mark parser
-(NSString *)initwithReqData:(id)inXmlData queryPara:(NSString*)inQueryPara type:(BOOL)isOfLoc{
	if (!inQueryPara) {
		return nil;
	}
	parameter = inQueryPara;
	if (isOfLoc &&[inXmlData isKindOfClass:[NSString class]]) {
		xmlData = [NSData dataWithContentsOfFile:inXmlData];
	}else {
		xmlData = [NSData dataWithData:inXmlData];
	}
	if (xmlData) {
		queryResult = @"";
		mParser = [[NSXMLParser alloc] initWithData:xmlData];
		[mParser setDelegate:self];
		[mParser setShouldProcessNamespaces:YES];
		[mParser setShouldReportNamespacePrefixes:YES];
		[mParser setShouldResolveExternalEntities:NO];
		[mParser parse];
		ACENSLog(@"specconfigParser queryResult=%@",queryResult);
    }
	return queryResult;
}  
- (void)parser:(NSXMLParser *)inParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{ 
	element = @"";
	NSMutableDictionary *tmpDict = [NSMutableDictionary dictionaryWithDictionary:attributeDict];
	if ([tmpDict objectForKey:parameter]) {
		queryResult = [tmpDict objectForKey:parameter];
		[inParser abortParsing];
	}

}
- (void)parser:(NSXMLParser *)inParser foundCharacters:(NSString *)tagText{
	if ([tagText isEqualToString:@"\n\t"]==NO) {
		//element = tagText;
		element = [element stringByAppendingString:tagText];
	}
	
}
- (void)parser:(NSXMLParser *)inParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:parameter]) {
		queryResult = element;
		[inParser abortParsing];
	}
}
#pragma mark HttpcallBack
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"error=%@",[error localizedDescription]);
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[resultData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	NSHTTPURLResponse *httpRes = (NSHTTPURLResponse*)response;
	if ([httpRes respondsToSelector:@selector(allHeaderFields)]) {
		int errorCode = [httpRes statusCode];
		ACENSLog(@"spec status=%d",errorCode);
	}		
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if (resultData) {
		[self initwithReqData:resultData queryPara:parameter type:NO];
		[resultData setLength:0];
	}
} 

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
	[BUtility exitWithClearData];
	[alertView release];
}

- (void)dealloc {
	ACENSLog(@"SpeconfigParser dealloc resultData retaincont=%d",[resultData retainCount]);
	[resultData release];
	resultData = nil;
	ACENSLog(@"SpeconfigParser dealloc mParser retaincont=%d",[mParser retainCount]);
	[mParser release];
	mParser = nil;
    [super dealloc];
}

@end
