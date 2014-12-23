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

#import "EBrowserHistory.h"
#import "EBrowserHistoryEntry.h"


@implementation EBrowserHistory

- (void)dealloc {
	if (mHisEntryArray) {
		for (EBrowserHistoryEntry *entry in mHisEntryArray) {
			[entry release];
		}
	}
	[mHisEntryArray removeAllObjects];
	[mHisEntryArray release];
	mHisEntryArray =nil;
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		mHisEntryArray = [NSMutableArray arrayWithCapacity:20];
		[mHisEntryArray retain];
		mCurIndex = -1;
	}
	return self;
}

- (BOOL)canGoBack {
	if (mCurIndex == 0) {
		return NO;
	}
	return YES;
}

- (BOOL)canGoForward {
	if (mCurIndex == (mHisEntryArray.count - 1)) {
		return NO;
	}
	return YES;
}

- (void)goBack {
	if (mCurIndex > 0) {
		mCurIndex--;
	}
}

- (void)goForward {
	if (mCurIndex+1 < mHisEntryArray.count) {
		mCurIndex++;
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
        [mHisEntryArray insertObject:eInHisEntry atIndex:++mCurIndex];
        int arrayCount = mHisEntryArray.count;
        if (mCurIndex+1 < arrayCount) {
            /*for (int i=mCurIndex+1; i<arrayCount; i++) {
             [(EBrowserHistoryEntry*)[mHisEntryArray objectAtIndex:i] release];
             }*/
            NSRange range = NSMakeRange(mCurIndex+1, arrayCount-(mCurIndex+1));
            [mHisEntryArray removeObjectsInRange:range];
        }
//    }
}

- (EBrowserHistoryEntry*)hisEntryByStep:(int)inStep {
	EBrowserHistoryEntry *eHisEntry = nil;
	switch (inStep) {
		case F_EBRW_HISTORY_STEP_BACK:
			if (mHisEntryArray.count != 0 && mCurIndex+1 > 0) {
				eHisEntry = (EBrowserHistoryEntry*)[mHisEntryArray objectAtIndex:mCurIndex-1];
			}
			break;
		case F_EBRW_HISTORY_STEP_CUR:
			if (mHisEntryArray.count != 0) {
				eHisEntry = (EBrowserHistoryEntry*)[mHisEntryArray objectAtIndex:mCurIndex];
			}
			break;
		case F_EBRW_HISTORY_STEP_FORWARD:
			if (mHisEntryArray.count != 0 && mCurIndex+1 < mHisEntryArray.count) {
				eHisEntry = (EBrowserHistoryEntry*)[mHisEntryArray objectAtIndex:mCurIndex+1];
			}
			break;
		default:
			break;
	}
	return eHisEntry;
}

- (void)clean {
	[mHisEntryArray release];
	mHisEntryArray = [NSMutableArray arrayWithCapacity:20];
	[mHisEntryArray retain];
	mCurIndex = -1;
}

@end
