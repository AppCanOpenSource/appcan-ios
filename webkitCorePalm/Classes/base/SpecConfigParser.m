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

#import "SpecConfigParser.h"
#import "BUtility.h"
#import "WidgetSQL.h"
#import "WWidgetMgr.h"
#import "WWidget.h"
#import "WgtReportParser.h"
#import "WidgetOneDelegate.h"
#import "FileEncrypt.h"

@implementation SpecConfigParser

#pragma mark parser
-(NSString *)initwithReqData:(id)inXmlData queryPara:(NSString*)inQueryPara type:(BOOL)isOfLoc{
	if (!inQueryPara) {
		return nil;
	}
	parameter = inQueryPara;
    
    
    
	if (isOfLoc &&[inXmlData isKindOfClass:[NSString class]]) {
		xmlData = (NSMutableData *)[NSData dataWithContentsOfFile:inXmlData];
	}else {
		xmlData = (NSMutableData *)[NSData dataWithData:inXmlData];
	}
    
    BOOL isEncrypt = [FileEncrypt isDataEncrypted:xmlData];
    
    if (isEncrypt) {
        
        NSURL *url = nil;
        if ([inXmlData hasSuffix:@"file://"]) {
            url = [BUtility stringToUrl:inXmlData];;
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", inXmlData]];
        }
        
        FileEncrypt *encryptObj = [[FileEncrypt alloc]init];
        NSString *data = [encryptObj decryptWithPath:url appendData:nil];
        
        [encryptObj release];
        
        xmlData = (NSMutableData *)[data dataUsingEncoding:NSUTF8StringEncoding];
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
		NSInteger errorCode = [httpRes statusCode];
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
	[resultData release];
	resultData = nil;
	[mParser release];
	mParser = nil;
    [super dealloc];
}

@end
