/**
 *
 *	@file   	: EUExBaseDefine.m  in AppCanKit
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 16/8/9
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


#import "EUExBaseDefine.h"
#import "ACLog.h"

UEX_BOOL UEX_TRUE;
UEX_BOOL UEX_FALSE;
UEX_ERROR kUexNoError;



__attribute__((constructor)) static void initBaseDefine(){
    UEX_TRUE    = @(YES);
    UEX_FALSE   = @(NO);
    kUexNoError = @0;
}


APPCAN_EXPORT UEX_ERROR _uex_ErrorMake(NSInteger code,NSString * _Nullable description,NSDictionary * _Nullable info,const char * func){
    NSMutableString *log = nil;
    if (description) {
        log = [NSMutableString stringWithFormat:@"%s -> an error(code: %ld) happend: %@",func,(long)code,description];
    }
    if (info) {
        [log appendFormat:@", errInfo: %@",info];
    }
    if (log) {
        ACLogError(@"%@.",log);
    }
    return @(code);
}

