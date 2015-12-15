//
//  EUExBase+Bundle.m
//  AppCanEngine
//
//  Created by Cerino on 15/9/11.
//
//

#import "EUExBase+Bundle.h"
#import "EUtility.h"
@implementation EUExBase (Bundle)

- (NSBundle *)pluginBundle {
    
    NSString *EUExName = NSStringFromClass([self class]);
    NSString *uexName = [NSString stringWithFormat:@"uex%@",[EUExName substringFromIndex:4]];
    return [EUtility bundleForPlugin:uexName];
}

- (BOOL)isUseSystemLanguage {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    NSString * userLanguag = [ud valueForKey:@"AppCanUserLanguage"];
    
    if (!userLanguag || userLanguag == nil || userLanguag.length == 0) {
        
        return YES;
        
    }
    
    return NO;
    
}

- (NSString *)getAppCanUserLanguage {
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    NSString * userLanguag = [ud valueForKey:@"AppCanUserLanguage"];
    
    return userLanguag;
    
}

-(NSString*)localizedString:(NSString *)key, ...{
    
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
    return [self localizedStringForKey:key defaultValue:value];
}


-(NSBundle *)languageBundle{
    if ([self isUseSystemLanguage]) {
        return meBundle;
    } else {
        NSString * userLanguage = [self getAppCanUserLanguage];
        return [NSBundle bundleWithPath:[meBundle pathForResource:userLanguage ofType:@"lproj"]];
    }
}

-(NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)value{
    if(![self languageBundle]){
        return value;
    }
    return [[self languageBundle] localizedStringForKey:key value:value table:nil];
    
    
}
@end
