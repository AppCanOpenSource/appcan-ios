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

#import "EBrowserHistory.h"
#import "EBrowserHistoryEntry.h"


@implementation EBrowserHistory

- (void)dealloc {

	[_mHisEntryArray removeAllObjects];

	_mHisEntryArray =nil;

}

- (id)init {
	self = [super init];
	if (self) {
		_mHisEntryArray = [NSMutableArray arrayWithCapacity:20];
		_mCurIndex = -1;
	}
	return self;
}

- (BOOL)canGoBack {
	if (self.mCurIndex == 0) {
		return NO;
	}
	return YES;
}

- (BOOL)canGoForward {
	if (self.mCurIndex == (self.mHisEntryArray.count - 1)) {
		return NO;
	}
	return YES;
}

- (void)goBack {
	if (self.mCurIndex > 0) {
		self.mCurIndex--;
	}
}

- (void)goForward {
	if (self.mCurIndex+1 < self.mHisEntryArray.count) {
		self.mCurIndex++;
	}
}

- (void)addHisEntry:(EBrowserHistoryEntry*)eInHisEntry {
	//ACENSLog(@"EBrowserHistory allHisentry %d",[eInHisEntry retainCount]);
//    BOOL isInHis=NO;
//    for (int i=0; i<[mHisEntryArray count]; i++)
//    {
//       EBrowserHistoryEntry * temp = [mHisEntryArray objectAtIndex:i];
//        if ([temp.mUrl isEqual:eInHisEntry.mUrl])
//        {
//            isInHis=YES;
//        }
//    }
//    if (!isInHis)
//    {
        [self.mHisEntryArray insertObject:eInHisEntry atIndex:++self.mCurIndex];
        NSInteger arrayCount = self.mHisEntryArray.count;
        if (self.mCurIndex+1 < arrayCount) {
            /*for (int i=mCurIndex+1; i<arrayCount; i++) {
             [(EBrowserHistoryEntry*)[mHisEntryArray objectAtIndex:i] release];
             }*/
            NSRange range = NSMakeRange(self.mCurIndex+1, arrayCount-(self.mCurIndex+1));
            [self.mHisEntryArray removeObjectsInRange:range];
        }
//    }
}

- (EBrowserHistoryEntry*)hisEntryByStep:(int)inStep {
	EBrowserHistoryEntry *eHisEntry = nil;
	switch (inStep) {
		case F_EBRW_HISTORY_STEP_BACK:
			if (self.mHisEntryArray.count != 0 && self.mCurIndex+1 > 0) {
				eHisEntry = (EBrowserHistoryEntry*)[self.mHisEntryArray objectAtIndex:self.mCurIndex-1];
			}
			break;
		case F_EBRW_HISTORY_STEP_CUR:
			if (self.mHisEntryArray.count != 0) {
				eHisEntry = (EBrowserHistoryEntry*)[self.mHisEntryArray objectAtIndex:self.mCurIndex];
			}
			break;
		case F_EBRW_HISTORY_STEP_FORWARD:
			if (self.mHisEntryArray.count != 0 && self.mCurIndex+1 < self.mHisEntryArray.count) {
				eHisEntry = (EBrowserHistoryEntry*)[self.mHisEntryArray objectAtIndex:self.mCurIndex+1];
			}
			break;
		default:
			break;
	}
	return eHisEntry;
}

- (void)clean {
	[self.mHisEntryArray removeAllObjects];
	self.mHisEntryArray = [NSMutableArray arrayWithCapacity:20];
	self.mCurIndex = -1;
}

@end
