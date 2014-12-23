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

#import "PluginParser.h"

@implementation PluginParser
-(NSString*)compentJS:(NSString*)inClassName funArr:(NSMutableArray*)inFunArr property:(NSMutableString*)inPorpertyStr{
	NSString *jsTmp = nil;
	if (!inClassName) {
		return nil;
	}
	//className + propertyStr
	if (inPorpertyStr && [inPorpertyStr length]>1 ) {
		jsTmp = [NSString stringWithFormat:@"window.%@={};\n%@",inClassName,inPorpertyStr];
	}else{
		jsTmp = [NSString stringWithFormat:@"window.%@={};\n",inClassName];
	}
	//funString
	if (inFunArr && [inFunArr count]>0) {
		for (NSString *jsFun in inFunArr) {
			NSString *funStr = nil;
			funStr = [NSString stringWithFormat:@"%@.%@=function(){uex.exec('%@.%@/'+uexJoin(arguments));};\n",inClassName,jsFun,inClassName,jsFun]; 
            
            if ([inClassName isEqualToString:@"uexDataBaseMgr"] && [jsFun isEqualToString:@"transaction"]) {
                funStr = @"uexDataBaseMgr.transaction=function(inDBName,inOpId,inFunc){var temp = encodeURIComponent(inDBName)+uex_s_uex+encodeURIComponent(inOpId);uex.exec('uexDataBaseMgr.beginTransaction/?'+temp); inFunc();uex.exec('uexDataBaseMgr.endTransaction/?'+temp);};";
            }
			jsTmp = [NSString stringWithFormat:@"%@%@",jsTmp,funStr];
		}
	}
	//ACENSLog(@"jsTmp=%@",jsTmp);
	return jsTmp;
}

-(void)dealloc{
	[super dealloc];
	[mParser release];
	mParser = nil;
	
	[funArr removeAllObjects];
	[funArr release];
	funArr = nil;
}
-(NSString*)initPluginJS{
	NSString *pluginJSPath = [NSString stringWithFormat:@"%@/plugin.xml",[[NSBundle mainBundle] resourcePath]];
	//NSLog(@"pluginJSPath=%@",pluginJSPath);
	if (![[NSFileManager defaultManager] fileExistsAtPath:pluginJSPath]) {
		return nil ;
	}
	NSData *pluginData = [NSData dataWithContentsOfFile:pluginJSPath];
	if (!pluginData ||[pluginData length]==0) {
		return nil ;
	}
	funArr = [[NSMutableArray alloc] initWithCapacity:0];
	resultJS = [NSMutableString stringWithFormat:@""];
	ObjectJS =[NSMutableString stringWithFormat:@"\n"];
	mParser = [[NSXMLParser alloc] initWithData:pluginData];
	[mParser setDelegate:self];
	[mParser setShouldProcessNamespaces:YES];
	[mParser setShouldReportNamespacePrefixes:YES];
	[mParser setShouldResolveExternalEntities:NO];
	[mParser parse];
	//ACENSLog(@"parseSUccess=%d\n resultJS=%@",parseSuccess,resultJS);
	
	return resultJS;
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	//if ([elementName isEqualToString:@"uexplugins"]) {}
	if ([elementName isEqualToString:@"method"]) {
		if ([attributeDict objectForKey:@"name"]) {
			funName = [attributeDict objectForKey:@"name"];
		}
	}else if ([elementName isEqualToString:@"property"]) {
		if ([attributeDict objectForKey:@"name"]) {
			propertyName = [attributeDict objectForKey:@"name"];
		}
	}else if ([elementName isEqualToString:@"plugin"]) {
		if ([attributeDict objectForKey:@"name"]) {
			className = [attributeDict objectForKey:@"name"];
		}
	}
	element=@"";
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	if ([string isEqualToString:@"\n\t"]==NO && [string length]>0) {
		element = [element stringByAppendingString:string];
	}
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"method"]) {
		if (funName && [funName length]>0) {
			[funArr addObject:funName];	
		}
		funName = @"";
	}else if([elementName isEqualToString:@"property"]){
		if (!element ||[element length]<1) {
			propertyName = @"";
		}else {
			ObjectJS = [NSMutableString stringWithFormat:@"%@.%@=%@;\n",className,propertyName,element];
			propertyName = @"";
		}	
	}else if ([elementName isEqualToString:@"plugin"]) {
		//执行js
		NSString *somePluginJS = [self compentJS:className funArr:funArr property:ObjectJS];
		[funArr removeAllObjects];
		ObjectJS = [NSMutableString stringWithString:@""];
		resultJS = [NSString stringWithFormat:@"%@\n%@",resultJS,somePluginJS];
	}else if ([elementName isEqualToString:@"uexplugins"]){
		return;
	}
}
@end
