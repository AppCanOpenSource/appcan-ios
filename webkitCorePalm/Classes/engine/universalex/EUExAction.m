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

#import "EUExAction.h"

@implementation EUExAction
@synthesize mClassName;
@synthesize mMethodName;
@synthesize mArguments;

- (void)dealloc {
	if (mClassName) {
		[mClassName release];
		mClassName = NULL;
	}
	if (mMethodName) {
		[mMethodName release];
		mMethodName = NULL;
	}
	[mArguments release];
	mArguments = NULL;
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		mClassName = NULL;
		mMethodName = NULL;
		mArguments = [[NSMutableArray alloc] initWithCapacity:8];
	}
	return self;
}

@end
