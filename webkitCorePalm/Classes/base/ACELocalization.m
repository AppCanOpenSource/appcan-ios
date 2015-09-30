//
//  ACELocalization.m
//  AppCanEngine
//
//  Created by CeriNo on 15/9/28.
//
//

#import "ACELocalization.h"

@implementation ACELocalization


+(NSString*)localizedString:(NSString *)key, ...{
    
    NSString *value = @"";
    if(!key){
        return value;
    }
    va_list argList;
    va_start(argList,key);
    id arg=va_arg(argList,id);
    if(arg && [arg isKindOfClass:[NSString class]]){
        value=arg;
    }
    va_end(argList);
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:@"AppCanEngineLocalization"];
}


@end
