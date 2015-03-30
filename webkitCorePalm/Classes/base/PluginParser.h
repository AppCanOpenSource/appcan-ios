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

#import <Foundation/Foundation.h>
@interface PluginParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) NSXMLParser *mParser;
@property (nonatomic, retain) NSString *element;
@property (nonatomic, retain) NSMutableArray *funArr;
@property (nonatomic, retain) NSMutableString *resultJS;
@property (nonatomic, retain) NSString *className;
@property (nonatomic, retain) NSString *funName;
@property (nonatomic, retain) NSString *propertyName;
@property (nonatomic, retain) NSString *propertyValue;
@property (nonatomic, retain) NSMutableString *ObjectJS;
@property (nonatomic, retain) NSMutableArray *classNameArray;

-(NSString*)initPluginJS;
@end
