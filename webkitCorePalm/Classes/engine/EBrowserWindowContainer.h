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

#import <UIKit/UIKit.h>

#define F_BRW_WND_CONTAINER_LOAD_WGT_DONE					0x1

#define F_BRW_WND_CONTAINER_BRW_WND_DICT_SIZE				30
#define F_BRW_WND_ROOT_NAME									@"root"

@class EBrowserController;
@class EBrowserWindow;
@class EBrowserView;
@class AliPayInfo;

extern NSString *const kUexPushNotifyBrwViewNameKey;
extern NSString *const kUexPushNotifyCallbackFunctionNameKey;

@interface EBrowserWindowContainer : UIView
@property (nonatomic, weak) EBrowserController *meBrwCtrler;
@property (nonatomic, strong) EBrowserWindow *meRootBrwWnd;
@property (nonatomic, strong) NSMutableDictionary *mBrwWndDict;
@property (nonatomic, weak) WWidget *mwWgt;
@property (nonatomic, weak) EBrowserWindowContainer *meOpenerContainer;
@property (nonatomic, strong) NSString *mOpenerForRet;
@property (nonatomic, strong) NSString *mOpenerInfo;
@property (nonatomic, strong) AliPayInfo *mAliPayInfo;
@property (nonatomic, assign)int mStartAnimiId;
@property (nonatomic, assign)float mStartAnimiDuration;
@property (nonatomic, assign)int mFlag;

- (id)initWithFrame:(CGRect)frame BrwCtrler:(EBrowserController*)eInBrwCtrler Wgt:(WWidget*)inWgt;
- (void)notifyLoadPageStartOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageFinishOfBrwView: (EBrowserView*)eInBrwView;
- (void)notifyLoadPageErrorOfBrwView: (EBrowserView*)eInBrwView;
- (EBrowserWindow*)aboveWindow;
- (EBrowserWindow*)brwWndForKey: (id)inKey;
- (void)removeAllUnActiveBrwWnd;
- (void)removeFromWndDict:(id)inKey;
- (void)pushNotify;
- (void)clean;
+ (EBrowserWindowContainer *)getBrowserWindowContaier:(EBrowserView *)browserView;
@end
