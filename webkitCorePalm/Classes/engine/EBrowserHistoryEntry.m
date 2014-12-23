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

#import "EBrowserHistoryEntry.h"


@implementation EBrowserHistoryEntry

@synthesize mUrl;
@synthesize mIsObf;

- (void)dealloc {
	[mUrl release];
	mUrl = NULL;
	[super dealloc];
}

- (id)initWithUrl:(NSURL*)inUrl obfValue:(BOOL)inIsObf {
	self = [super init];
	if (self) {
		self.mUrl = inUrl;
		mIsObf = inIsObf;
	}
	return self;
}

@end
