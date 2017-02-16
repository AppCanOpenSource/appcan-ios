/**
 *
 *	@file   	: ACEWidgetUpdateUtility.m  in AppCanEngine
 *
 *	@author 	: CeriNo
 * 
 *	@date   	: 2017/2/10
 *
 *	@copyright 	: 2017 The AppCan Open Source Project.
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


#import "ACEWidgetUpdateUtility.h"
#import "AppCanEnginePrivate.h"
#import "ACEConfigXML.h"
#import "ZipArchive.h"
#import <Ono/Ono.h>
#import <AppCanKit/ACEXTScope.h>
#import "BUtility.h"
#import "WWidgetMgr.h"
@interface ACEWidgetUpdateUtility()


@end


#define FileManager (NSFileManager.defaultManager)
#define StandardUserDefaults (NSUserDefaults.standardUserDefaults)



@implementation ACEWidgetUpdateUtility



FOUNDATION_STATIC_INLINE NSString *ACEDocumentPath(){
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}


#pragma mark - UserDefaults Keys

//替代F_StandardUserDefaults_WgtCopyFinish
static NSString *const ACEWidgetCopyFinishedUserDefaultsKey =       @"AppCanWgtCopyFinish";

static NSString *const ACEMainWidgetNeedPatchUpdateUserDefaultsKey =  @"AppCanMainWidgetNeedPatchUpdateUserDefaultsKey";
static NSString *const ACEMainWidgetPatchZipPathUserDefaultsKey =     @"AppCanMainWidgetPatchZipPathUserDefaultsKey";
static NSString *const ACEWidgetVersionUserDefaultsKey =            @"AppCanWidgetVersionUserDefaultsKey";


#pragma mark - Class Properties



+ (BOOL)isWidgetCopyNeeded{
    if (!AppCanEngine.configuration.useUpdateWgtHtmlControl) {
        return NO;
    }
    if (![ACEConfigXML isWidgetConfigXMLAvailable]) {
        return YES;
    }
    NSString *originWidgetVersion = [ACEConfigXML ACEOriginConfigXML][@"version"];
    NSParameterAssert(originWidgetVersion != nil);
    NSString *documentWidgetVersion = [ACEConfigXML ACEWidgetConfigXML][@"version"] ?: @"";

    return [self isVersion:originWidgetVersion greaterThanVersion:documentWidgetVersion];
}


+ (BOOL)isVersion:(NSString *)ver1 greaterThanVersion:(NSString *)ver2{
    NSInteger (^versionNumber)(NSString *) = ^NSInteger(NSString * version){
        NSArray<NSNumber *> *weights = @[@1000000,@10000,@1];
        NSArray *vers = [version componentsSeparatedByString:@"."];
        
        NSInteger versionNumber = 0;
        for (NSInteger i =  MIN(vers.count, 3) - 1 ; i >= 0 ; i--) {
            versionNumber += weights[i].integerValue * [vers[i] integerValue];
        }
        
        return versionNumber;
    };
    return [@(versionNumber(ver1)) compare:@(versionNumber(ver2))] == NSOrderedDescending;
}




+ (NSString *)currentWidgetVersion{
    NSString *version = [StandardUserDefaults valueForKey:ACEWidgetVersionUserDefaultsKey];
    if (!version || ![version isKindOfClass:[NSString class]]) {
        ONOXMLElement *configXML = [ACEConfigXML ACEOriginConfigXML];
        version = configXML[@"version"];
        [StandardUserDefaults setValue:version forKey:ACEWidgetVersionUserDefaultsKey];
    }
    return version;
}


+ (NSString *)widgetPathForVersion:(NSString *)version{
    static NSString *widgetFolderPath = @"widget";
    if ([BUtility getAppCanDevMode]) {
        return widgetFolderPath;
    }

    
    BOOL isFolder = NO;
    NSString *absWidgetPath = [ACEDocumentPath() stringByAppendingPathComponent:widgetFolderPath];
    NSError *error = nil;
    if (![FileManager fileExistsAtPath:absWidgetPath isDirectory:&isFolder] || !isFolder) {
        if (![FileManager createDirectoryAtPath:absWidgetPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            ACLogError(@"create document widget folder failed: %@",error.localizedDescription);
        }
    }
    
    return [widgetFolderPath stringByAppendingPathComponent:version];
}

+ (NSString *)currentWidgetPath{
    return [self widgetPathForVersion:self.currentWidgetVersion];
}

#pragma mark - UpdateTmpFolder

+ (NSString *)updateTmpFolderPath{

    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"ACEUpdate"];
}

+ (void)cleanupUpdateTmpFolder{
    if ([FileManager fileExistsAtPath:self.updateTmpFolderPath]) {
        [FileManager removeItemAtPath:self.updateTmpFolderPath error:nil];
    }
}



+ (BOOL)isWidgetUpdateEnabled{
    return AppCanEngine.configuration.useUpdateWgtHtmlControl;
}

+ (BOOL)isWidgetCopyFinished{
    return [StandardUserDefaults boolForKey:ACEWidgetCopyFinishedUserDefaultsKey];
}
+ (void)setIsWidgetCopyFinished:(BOOL)isWidgetCopyFinished{
    [StandardUserDefaults setBool:isWidgetCopyFinished forKey:ACEWidgetCopyFinishedUserDefaultsKey];
    [StandardUserDefaults synchronize];
}





+ (BOOL)copyMainWidgetToDocumentWithError:(NSError *__autoreleasing  _Nullable *)errPtr{


    NSString * wgtOldPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[AppCanEngine.configuration originWidgetPath]];
    NSString * wgtNewPath = [ACEDocumentPath() stringByAppendingPathComponent:[AppCanEngine.configuration documentWidgetPath]];
    
    if ([FileManager fileExistsAtPath:wgtNewPath] && ![FileManager removeItemAtPath:wgtNewPath error:errPtr]) {
        return NO;
    }
    BOOL ret = [FileManager copyItemAtPath:wgtOldPath toPath:wgtNewPath error:errPtr];
    if (ret) {
        [ACEConfigXML updateWidgetConfigXML];
    }
    return ret;
}



+ (BOOL)isMainWidgetNeedPatchUpdate{
    return [StandardUserDefaults boolForKey:ACEMainWidgetNeedPatchUpdateUserDefaultsKey];
}

+ (void)setMainWidgetNeedPatchUpdate:(NSString *)patchZipPath{
    [StandardUserDefaults setBool:YES forKey:ACEMainWidgetNeedPatchUpdateUserDefaultsKey];
    [StandardUserDefaults setValue:patchZipPath forKey:ACEMainWidgetPatchZipPathUserDefaultsKey];
    [StandardUserDefaults synchronize];
}

+ (NSString *)patchZipPath{
    return [StandardUserDefaults valueForKey:ACEMainWidgetPatchZipPathUserDefaultsKey];
}

+ (ACEWidgetUpdateResult)installMainWidgetPatch{

    
    if (!self.isWidgetUpdateEnabled || !self.isWidgetCopyFinished || !self.isMainWidgetNeedPatchUpdate) {
        return ACEWidgetUpdateResultNotNeeded;
    }
    NSString *zipPath = self.patchZipPath;
    if (!zipPath || ![FileManager fileExistsAtPath:zipPath]) {
        return ACEWidgetUpdateResultNotNeeded;
        
    }
    
    NSString *oldVersion = self.currentWidgetVersion;
    NSString *oldWidgetPath = [ACEDocumentPath() stringByAppendingPathComponent:[AppCanEngine.configuration documentWidgetPath]];
    NSString *tmpFolderPath = self.updateTmpFolderPath;
    ZipArchive *zip = [[ZipArchive alloc] init];
    [self cleanupUpdateTmpFolder];

    
    NSError *error = nil;
    @onExit{
        [self cleanupUpdateTmpFolder];
    };
    
    if (![FileManager copyItemAtPath:oldWidgetPath toPath:tmpFolderPath error:&error]) {
        ACLogError(@"copy old widget to tmpFolder failed: %@",error.localizedDescription);
        return ACEWidgetUpdateResultError;
    }

    if (![zip UnzipOpenFile:zipPath]
        || ![zip UnzipFileTo:tmpFolderPath overWrite:YES]
        || ![zip UnzipCloseFile]) {
        return ACEWidgetUpdateResultError;
    }
    NSData *xmlData = [NSData dataWithContentsOfFile:[tmpFolderPath stringByAppendingPathComponent:@"config.xml"]];
    ONOXMLDocument *configDocument = [ONOXMLDocument XMLDocumentWithData:xmlData error:&error];
    if (!configDocument) {
        ACLogError(@"read patched config.xml failed: %@",error.localizedDescription);
        return ACEWidgetUpdateResultError;
    }
    NSString *newVersion = configDocument.rootElement[@"version"];
    if (![self isVersion:newVersion greaterThanVersion:oldVersion]) {
        ACLogError(@"patched config.xml version is invalid!");
        return ACEWidgetUpdateResultError;
    }
    NSString *newWidgetPath = [ACEDocumentPath() stringByAppendingPathComponent:[self widgetPathForVersion:newVersion]];
    
    if ([FileManager fileExistsAtPath:newWidgetPath]) {
        [FileManager removeItemAtPath:newWidgetPath error:nil];
    }
    
    if (![FileManager copyItemAtPath:tmpFolderPath toPath:newWidgetPath error:&error]) {
        ACLogError(@"copy tmpFolder to newWidgetPath failed: %@",error.localizedDescription);
        return ACEWidgetUpdateResultError;
    }
    if (![oldWidgetPath isEqualToString:newWidgetPath] && ![FileManager removeItemAtPath:oldWidgetPath error:&error]) {
        ACLogWarning(@"Warning ~> remove old widgetFolder failed: %@",error.localizedDescription);
        error = nil;
    }
    
    
    if (![FileManager removeItemAtPath:zipPath error:&error]) {
        ACLogWarning(@"Warning ~> remove widget patch zip failed: %@",error.localizedDescription);

    }
    [StandardUserDefaults setBool:NO forKey:ACEMainWidgetNeedPatchUpdateUserDefaultsKey];
    [StandardUserDefaults setValue:nil forKey:ACEMainWidgetPatchZipPathUserDefaultsKey];
    [StandardUserDefaults setValue:newVersion forKey:ACEWidgetVersionUserDefaultsKey];
    [StandardUserDefaults synchronize];
    
    
    [ACEConfigXML updateWidgetConfigXML];
    [[WWidgetMgr sharedManager] loadMainWidget];
    return ACEWidgetUpdateResultSuccess;

}


@end
