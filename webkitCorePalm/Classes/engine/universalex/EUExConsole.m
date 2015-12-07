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

#import "EUExConsole.h"
#import "BUtility.h"
#import "WWidget.h"
#import "WWidgetMgr.h"
#import "EBrowserController.h"
#import "EBrowserView.h"
#import "EUExBaseDefine.h"

@implementation EUExConsole

-(id)initWithBrwView:(EBrowserView *) eInBrwView{	
	if (self = [super initWithBrwView:eInBrwView]) {
	}
	return self;
}

-(void)dealloc{
	[super dealloc];
}

-(void)log:(NSMutableArray *)inArguments {
	NSString *logInfo = [inArguments objectAtIndex:0];
}


@end
