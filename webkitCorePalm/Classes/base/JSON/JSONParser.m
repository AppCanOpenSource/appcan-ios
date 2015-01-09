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

#import "JSONParser.h"
#import "JSON.h"

@implementation JSONParser


+(NSArray *)parserUrlData:(NSString *)URLString isAllValues:(BOOL)isAllValues  valueForKey:(NSString *)valueForKey
{
	NSData *ndMain = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:URLString]];
	NSString *strData = [[NSString alloc] initWithData:ndMain encoding:NSUTF8StringEncoding]; 	
	
	NSArray *arrInfo=[NSArray array];
	if ([strData length] != 0) {		
		if (isAllValues) {
			arrInfo =[[strData JSONValue] allValues];
		}else {
			arrInfo =[[strData JSONValue] valueForKey:valueForKey];
		}
		
	}
	[ndMain release];
	[strData release]; 
	return arrInfo;
}

+(id)parserData:(NSData *)ndMain isAllValues:(BOOL)isAllValues  valueForKey:(NSString *)valueForKey
{
	NSString *strData = [[NSString alloc] initWithData:ndMain encoding:NSUTF8StringEncoding]; 
	id value = nil;
	if ([strData length]!=0) {
		if (isAllValues) {
			value = [strData JSONValue];
		}
		else {
			value = [[strData JSONValue] valueForKey:valueForKey];
		}
	}
	[strData release];
	return value;
}

@end
