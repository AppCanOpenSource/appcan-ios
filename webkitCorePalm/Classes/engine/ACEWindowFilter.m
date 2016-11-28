/**
 *
 *	@file   	: ACEWindowFilter.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2016/11/28
 *
 *	@copyright 	: 2016 The AppCan Open Source Project.
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


#import "ACEWindowFilter.h"

static NSMutableArray<Class> *_blacklists = nil;



@implementation ACEWindowFilter

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _blacklists = [NSMutableArray array];
    });
}

+ (BOOL)registerBlacklist:(Class<ACEWindowBlacklist>)blacklistClass{
    if (!blacklistClass || ![(Class)blacklistClass conformsToProtocol:@protocol(ACEWindowBlacklist)]) {
        return NO;
    }
    if ([_blacklists containsObject:blacklistClass]) {
        return NO;
    }
    [_blacklists addObject: blacklistClass];
    return YES;
}

+ (BOOL)shouldBanWindowWithName:(NSString *)windowName{
    for (Class cls in _blacklists) {
        if ([cls respondsToSelector:@selector(shouldBanWindowWithName:)]
            && [cls shouldBanWindowWithName:windowName]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)shouldBanPopoverWithName:(NSString *)popoverName inWindow:(NSString *)windowName{
    for (Class cls in _blacklists) {
        if ([cls respondsToSelector:@selector(shouldBanPopoverWithName:inWindow:)]
            && [cls shouldBanPopoverWithName:popoverName inWindow:windowName]) {
            return YES;
        }
    }
    return NO;
}

@end
