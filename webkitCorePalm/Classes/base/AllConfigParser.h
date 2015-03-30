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

#define CONFIG_TAG_WIDGET				@"widget"
#define CONFIG_TAG_APPID				@"appId"
#define CONFIG_TAG_CHANNELCODE			@"channelCode"
#define CONFIG_TAG_VERSION				@"version"
#define CONFIG_TAG_NAME					@"name"
#define CONFIG_TAG_DESCRIPTION			@"description"

#define CONFIG_TAG_AUTHOR				@"author"
#define CONFIG_TAG_EMAIL				@"email"

#define CONFIG_TAG_LICENSE				@"license"
#define CONFIG_TAG_HREF				@"href"

#define CONFIG_TAG_ICON				@"icon"
#define CONFIG_TAG_CONTENT				@"content"
#define CONFIG_TAG_SRC				@"src"
#define CONFIG_TAG_LOGSERVERIP			@"logServerIp"
#define CONFIG_TAG_OBFUSCATION			@"obfuscation"

#define CONFIG_TAG_UPDATEURL			@"updateUrl"
#define CONFIG_TAG_SHOWMYSPACE			@"showMySpace"
#define CONFIG_TAG_ORIENTATION			@"orientation"
#define CONFIG_TAG_PRELOAD				@"preload"
#define CONFIG_TAG_WEBAPP				@"webapp"

//
#define CONFIG_TAG_WIDGETID				@"widgetId"
#define CONFIG_TAG_WIDGETONEID			@"widgetOneId"
#define CONFIG_TAG_WIDGETPATH			@"widgetPath"
#define CONFIG_TAG_WIDGETTYPE			@"wgtType"
#define CONFIG_TAG_DEBUG                @"debug"
//
#define CONFIG_TAG_WINDOWBACKGROUND     @"windowBackground"

@interface AllConfigParser : NSObject <NSXMLParserDelegate>{
	NSXMLParser *mParser;
	NSString *element;
	NSMutableDictionary *dataDict;

}
-(NSMutableDictionary *)initwithReqData:(id)inXmlData;
@end
