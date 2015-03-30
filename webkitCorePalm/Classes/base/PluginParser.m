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

#import "PluginParser.h"
#import "ACEPluginModel.h"
#import "WidgetOneDelegate.h"

@implementation PluginParser

- (id)init
{
    self = [super init];
    
    if (self) {
        
        _classNameArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

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
	
	[_mParser release];
	_mParser = nil;
	
	[_funArr removeAllObjects];
	[_funArr release];
	_funArr = nil;
    
    self.element = nil;
    self.resultJS = nil;
    self.className = nil;
    self.funName = nil;
    self.propertyName = nil;
    self.propertyValue = nil;
    self.ObjectJS = nil;
    
    [_classNameArray release];
    [super dealloc];
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
	_funArr = [[NSMutableArray alloc] initWithCapacity:0];
	self.resultJS = [NSMutableString stringWithFormat:@""];
	self.ObjectJS =[NSMutableString stringWithFormat:@"\n"];
	_mParser = [[NSXMLParser alloc] initWithData:pluginData];
	[_mParser setDelegate:self];
	[_mParser setShouldProcessNamespaces:YES];
	[_mParser setShouldReportNamespacePrefixes:YES];
	[_mParser setShouldResolveExternalEntities:NO];
	[_mParser parse];
	//ACENSLog(@"parseSUccess=%d\n resultJS=%@",parseSuccess,resultJS);
	
	return _resultJS;
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
	//if ([elementName isEqualToString:@"uexplugins"]) {}
	if ([elementName isEqualToString:@"method"]) {
		if ([attributeDict objectForKey:@"name"]) {
			self.funName = [attributeDict objectForKey:@"name"];
		}
	}else if ([elementName isEqualToString:@"property"]) {
		if ([attributeDict objectForKey:@"name"]) {
			self.propertyName = [attributeDict objectForKey:@"name"];
		}
	}else if ([elementName isEqualToString:@"plugin"]) {
		if ([attributeDict objectForKey:@"name"]) {
			self.className = [attributeDict objectForKey:@"name"];
            
            if (self.className != nil && ![_classNameArray containsObject:self.className]) {
                
                [_classNameArray addObject:self.className];
            }
        }
        if ([attributeDict objectForKey:@"global"]) {
            
            NSString *str = [attributeDict objectForKey:@"global"];
            
            if ([str isEqualToString:@"true"] && self.className != nil) {
                
                [self addPluginToGlobal:_className];
                
            }
        }
	}
	self.element=@"";
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	if ([string isEqualToString:@"\n\t"]==NO && [string length]>0) {
		self.element = [_element stringByAppendingString:string];
	}
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
	if ([elementName isEqualToString:@"method"]) {
		if (_funName && [_funName length]>0) {
			[_funArr addObject:_funName];
		}
		self.funName = @"";
	}else if([elementName isEqualToString:@"property"]){
		if (!self.element ||[self.element length]<1) {
			self.propertyName = @"";
		}else {
			self.ObjectJS = [NSMutableString stringWithFormat:@"%@.%@=%@;\n",self.className,self.propertyName,self.element];
			self.propertyName = @"";
		}	
	}else if ([elementName isEqualToString:@"plugin"]) {
		//执行js
		NSString *somePluginJS = [self compentJS:self.className funArr:self.funArr property:self.ObjectJS];
		[self.funArr removeAllObjects];
		self.ObjectJS = [NSMutableString stringWithString:@""];
		self.resultJS = [NSMutableString stringWithFormat:@"%@\n%@",self.resultJS,somePluginJS];
	}else if ([elementName isEqualToString:@"uexplugins"]){
		return;
	}
}

- (void)addPluginToGlobal:(NSString *)name
{
    if (name == nil) {
        return;
    }
    ACEPluginModel *model = [[ACEPluginModel alloc] init];
    
    model.pluginName = name;
    model.pluginObj = nil;
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    
    [app.globalPluginDict setObject:model forKey:name];
    
    [model release];
}

@end
