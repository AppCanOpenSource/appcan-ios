/**
 *
 *	@file   	: ACAvailability.m  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/31.
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

#import "ACAvailability.h"
#import "ACArguments.h"
#import "ACInvoker.h"
static NSString *kAppCanEngineVersion = @"";
static NSInteger kAppCanEngineVersionCode = 0;


static NSInteger versionCodeFromVersion(NSString * version){
    ACArgsUnpack(NSNumber *ver1 , NSNumber *ver2,NSNumber *ver3) = [version componentsSeparatedByString:@"."];
    return ver1.integerValue * 10000 + ver2.integerValue * 100 + ver3.integerValue;
}




@implementation ACAvailability

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aceVersion = NSClassFromString(@"ACEVersion");
        if (aceVersion && [aceVersion respondsToSelector:@selector(version)]) {
            kAppCanEngineVersion = [aceVersion ac_invoke:@"version"];
        }
        if (kAppCanEngineVersion.length > 0) {
            kAppCanEngineVersionCode = versionCodeFromVersion(kAppCanEngineVersion);
        }
    });
}


+ (NSString *)engineVersion{
    return kAppCanEngineVersion;
}
+ (NSInteger)engineVersionCode{
    return kAppCanEngineVersionCode;
}

+ (BOOL)isEngineAvailable:(NSString *)engineVersion{
    return kAppCanEngineVersionCode > versionCodeFromVersion(engineVersion);
}


@end
