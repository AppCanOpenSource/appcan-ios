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

#import <Foundation/Foundation.h>

@class EBrowserController;
@class EBrowserView;
@class EUExAudio;
@class EUExAction;

#define UEX_OBJ_SIZE  5

@interface EUExManager : NSObject {
	EBrowserController *eBrwCtrler;
	EBrowserView *eBrwView;
	NSMutableDictionary *uexObjDict;
}
@property (nonatomic,assign)EBrowserController *eBrwCtrler;
@property (nonatomic,assign)EBrowserView *eBrwView;
@property(nonatomic,assign)NSMutableDictionary *uexObjDict;
- (id)initWithBrwView:(EBrowserView*)eInBrwView BrwCtrler:(EBrowserController*)eInBrwCtrler;
- (void)doAction:(EUExAction *)inAction;
- (void)notifyDocChange;
- (void)stopAllNetService;
- (void)clean;

#ifdef WIDGETONE_FOR_IDE_DEBUG
- (void)doActionForIDEDebug:(EUExAction *)inAction;
#endif
@end