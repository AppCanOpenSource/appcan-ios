/**
 *
 *	@file   	: ACPluginBundle.m  in AppCanKit
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

#import "ACPluginBundle.h"
#import "EUExBase.h"
#import "ACLog.h"
@implementation NSBundle (ACPluginBundle)



+ (instancetype)ac_bundleForPlugin:(NSString *)pluginName{
    static NSString *dynamicPluginFrameworkFolderPath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dynamicFrameworkFolder = @"dynamicPlugins";
        dynamicPluginFrameworkFolderPath=[documentsPath stringByAppendingPathComponent:dynamicFrameworkFolder];
        NSFileManager *fm=[NSFileManager defaultManager];
        NSError *error=nil;
        BOOL isFolder=NO;
        if(![fm fileExistsAtPath:dynamicPluginFrameworkFolderPath isDirectory:&isFolder] || !isFolder){// 如果目录不存在，或者目录不是文件夹，就创建一个
            [fm createDirectoryAtPath:dynamicPluginFrameworkFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
            if(error){
                ACLogWarning(@"%@",[error localizedDescription]);
            }
        }
    });
    NSString *bundleName = [NSString stringWithFormat:@"%@.bundle",pluginName];
    //检测是否加载了动态库插件
    NSString *dynamicFrameworkPath = [dynamicPluginFrameworkFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.framework",pluginName]];
    NSBundle *dynamicFramework = [NSBundle bundleWithPath:dynamicFrameworkPath];
    //测试用,检测res://目录下的framework
    if(!dynamicFramework){
        dynamicFrameworkPath= [[AppCanMainWidget() absResourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.framework",pluginName]];
        dynamicFramework = [NSBundle bundleWithPath:dynamicFrameworkPath];
    }
    
    if(dynamicFramework && [dynamicFramework isLoaded]){
        //如果有动态库插件，优先查看动态库中是否有bundle
        NSBundle *dynamicBundle=[NSBundle bundleWithPath:[dynamicFramework pathForResource:pluginName ofType:@"bundle"]];
        if(dynamicBundle){
            //如果有则返回
            return dynamicBundle;
        }
    }
    //返回静态库的bundle
    NSString *bundlePath = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:bundleName];
    return [NSBundle bundleWithPath:bundlePath];
}
@end


@implementation NSString (ACPluginBundle)

+(NSString *)ac_plugin:(NSString *)pluginName localizedString:(NSString *)key,...{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * userLanguage = [ud valueForKey:@"AppCanUserLanguage"];
    BOOL useCustomLanguage = YES;
    if (!userLanguage || userLanguage == nil || userLanguage.length == 0) {
        useCustomLanguage = NO;
    }
     NSBundle *pluginBundle = [NSBundle ac_bundleForPlugin:pluginName];
    if (useCustomLanguage) {
        NSString *customLanguageBundlePath = [pluginBundle pathForResource:userLanguage ofType:@"lproj"];
        pluginBundle = [NSBundle bundleWithPath:customLanguageBundlePath];
    }
    if(!pluginBundle){
        return key;
    }
    NSString *defaultValue=@"";
    va_list argList;
    va_start(argList,key);
    id arg=va_arg(argList,id);
    //if(arg && [arg isKindOfClass:[NSString class]]){
    if(arg){
        defaultValue=arg;
    }
    va_end(argList);
    return [pluginBundle localizedStringForKey:key value:defaultValue table:nil];
}

@end
