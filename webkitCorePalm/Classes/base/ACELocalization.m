//
//  ACELocalization.m
//  AppCanEngine
//
//  Created by CeriNo on 15/9/28.
//
//

#import "ACELocalization.h"

@implementation ACELocalization

+ (NSString *)localizedString:(NSString *)key, ... {
    
    NSString *value = @"";
    if(!key){
        return value;
    }
    va_list argList;
    va_start(argList,key);
    id arg=va_arg(argList,id);
    if(arg){
        value=arg;
    }
    va_end(argList);
    
    return [ACELocalization localizedStringForKey:key defaultValue:value];
}

+ (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)value {
    
    if(![ACELocalization languageBundle]) {
        return value;
    }
    return [[ACELocalization languageBundle] localizedStringForKey:key value:value table:@"AppCanEngineLocalization"];
    
    
}

+ (BOOL)isUseSystemLanguage {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * userLanguag = [ud valueForKey:@"AppCanUserLanguage"];
    if (!userLanguag || userLanguag == nil || userLanguag.length == 0) {
        return YES;
    }
    return NO;
    
}

+ (NSString *)getAppCanUserLanguage {
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * userLanguag = [ud valueForKey:@"AppCanUserLanguage"];
    return userLanguag;
}

+ (NSBundle *)languageBundle {
    if ([ACELocalization isUseSystemLanguage]) {
        return [NSBundle mainBundle];
    } else {
        NSString * userLanguage = [ACELocalization getAppCanUserLanguage];
        return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:userLanguage ofType:@"lproj"]];
    }
}

@end
