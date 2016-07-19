/**
 *
 *	@file   	: ACEAvailable.m  in AppCanEngine
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/10.
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

#import "ACEAvailable.h"
#import "ACEUtils.h"




static NSString *const kAppCanEngineVersion = @"3.4.4";


@interface ACEAvailability : NSObject<ACEAvailability>
@end
@implementation ACEAvailability




+ (NSString *)engineVersion{
    return kAppCanEngineVersion;
}

+ (NSInteger)engineVersionCode{
    ACE_ArgsUnpack(NSNumber *ver1,NSNumber *ver2,NSNumber *ver3) = [kAppCanEngineVersion componentsSeparatedByString:@"."];
    return ver1.integerValue * 10000 + ver2.integerValue * 100 + ver3.integerValue;
}

+ (NSComparisonResult)compareWithVersion:(NSString *)ver{
    return [[self engineVersion]compare:ver options:NSNumericSearch];
}

@end
