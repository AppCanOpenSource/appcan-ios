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
#import "EUExBase.h"

#define UEX_JVUpdate		0
#define UEX_JVNoUpdate		1
#define UEX_JVError			2
#define UEX_JVParametersError		3

#define UEX_JKVERSION		@"version"
#define UEX_JKNAME			@"name"
#define UEX_JKSIZE			@"size"
#define UEX_JKURL			@"url"
#define UEX_JKRESULT		@"result"
@interface EUExWidget : EUExBase {
}
@end
