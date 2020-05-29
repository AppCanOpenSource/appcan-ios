/**
 *
 *	@file   	: ACEJSCBaseJS.h  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/1/9.
 *
 *	@copyright 	: 2015 The AppCan Open Source Project.
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

#define JS_APPCAN_ONJSPARSE_HEADER "AppCan_onJsParse:"
#define JS_APPCAN_ONJSPARSE_HEADER_NSSTRING @JS_APPCAN_ONJSPARSE_HEADER

@interface ACEJSCBaseJS : NSObject

+ (NSString *)baseJS;


@end
