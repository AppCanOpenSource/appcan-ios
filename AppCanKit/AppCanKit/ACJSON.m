/**
 *
 *	@file   	: ACJSON.m  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/5/25.
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

#import "ACJSON.h"
#import "ACLog.h"
@implementation  NSString (ACJSON)

- (id)ac_JSONValue{
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        //ACLogWarning(@"JSON parse error:%@",error.localizedDescription);
    }
    return obj;
}

@end

@implementation NSObject (ACJSON)

- (NSString *)ac_JSONFragment{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error = nil;
        NSData *stringData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
        if (error) {
            //ACLogWarning(@"JSON stringify error:%@",error.localizedDescription);
        }
        return [[NSString alloc]initWithData:stringData encoding:NSUTF8StringEncoding];
    }
    if ([self isKindOfClass:[NSString class]]) {

        NSString *arrStr = [@[self] ac_JSONFragment];
        NSString *result = [arrStr substringWithRange:NSMakeRange(1, arrStr.length -2)];
        return result;
        

    }
    return nil;
}

@end