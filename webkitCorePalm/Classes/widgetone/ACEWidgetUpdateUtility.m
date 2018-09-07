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
#import "ACEConfigXML.h"
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
    
    NSString *tmpWidgetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ACEUpdate"];
    NSString *tmpZipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ACEUpdateZip"];
    
    
    void (^cleanup)() = ^{
        if ([FileManager fileExistsAtPath:tmpZipPath]) {
            [FileManager removeItemAtPath:tmpZipPath error:nil];
        }
        if ([FileManager fileExistsAtPath:tmpWidgetPath]) {
            [FileManager removeItemAtPath:tmpWidgetPath error:nil];
        }
    };
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    cleanup();

    
    NSError *error = nil;
    @onExit{
        cleanup();
    };
    
    if (![FileManager copyItemAtPath:oldWidgetPath toPath:tmpWidgetPath error:&error]) {
        ACLogError(@"copy old widget to tmpFolder failed: %@",error.localizedDescription);
        return ACEWidgetUpdateResultError;
    }

    if (![zip UnzipOpenFile:zipPath]
        || ![zip UnzipFileTo:tmpZipPath overWrite:YES]
        || ![zip UnzipCloseFile]) {
        return ACEWidgetUpdateResultError;
    }
    
    NSString *patchPath = tmpZipPath;
    if (![FileManager fileExistsAtPath:[tmpZipPath stringByAppendingPathComponent:@"config.xml"]]) {
        NSString *appid = [ACEConfigXML ACEOriginConfigXML][@"appId"];
    
        NSString *subpath = [NSString stringWithFormat:@"widget/%@",appid];
        BOOL widgetFolderExist = [FileManager fileExistsAtPath:[tmpZipPath stringByAppendingPathComponent:subpath] isDirectory:&widgetFolderExist] && widgetFolderExist;
        if (widgetFolderExist) {
            ACLogDebug(@"EMM 4.0 zip patch");
            patchPath = [tmpZipPath stringByAppendingPathComponent:subpath];
        }else{
            ACLogError(@"invalid update patch!");
            return ACEWidgetUpdateResultError;
        }
    }
    if (![self mergeFolderAtPath:patchPath intoPath:tmpWidgetPath error:&error]) {
        ACLogError(@"merge patch into widget failed: %@",error.localizedDescription);
        return ACEWidgetUpdateResultError;
    };
    
    NSData *xmlData = [NSData dataWithContentsOfFile:[tmpWidgetPath stringByAppendingPathComponent:@"config.xml"]];
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
    //原copy改为move，缩短主应用补丁包更新时间，减少8badf00d崩溃几率。
    if (![FileManager moveItemAtPath:tmpWidgetPath toPath:newWidgetPath error:&error]) {
        ACLogError(@"move tmpFolder to newWidgetPath failed: %@",error.localizedDescription);
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

+ (void)unZipSubWidgetNeedPatchUpdate:(NSString *)subWidgetPatchZipPath {
    
    ZipArchive *zip = [[ZipArchive alloc] init];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    //解压后的widget包的最终路径
    NSString *outputPath = [BUtility getDocumentsPath:@"widgets"];
    
    //创建临时目录做文件中转站
    NSString *tmpPatchPath = [BUtility getDocumentsPath:@"uexAppStoreMgrSubWidget"];
    [fileMgr removeItemAtPath:tmpPatchPath error:nil];
    [fileMgr createDirectoryAtPath:tmpPatchPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    if ([zip UnzipOpenFile:subWidgetPatchZipPath] &&
        [zip UnzipFileTo:tmpPatchPath overWrite:YES] &&
        [zip UnzipCloseFile]) {
        
        
        NSString *newVersion = @"";
        NSString *subAppID = @"";
        
        //先解压到临时目录,由于不同的EMM后台zip包的目录也不同,在copy前需判断zip包的目录结构
        
        NSArray *fileList = [fileMgr contentsOfDirectoryAtPath:tmpPatchPath error:nil];
        
        if ([fileList containsObject:@"widget"] && [fileList containsObject:@"plugin"]) {
            
            NSString  *tmpWidgetPath = [tmpPatchPath stringByAppendingPathComponent:@"widget"];
            
            NSArray *widgetPathFolderList = [fileMgr contentsOfDirectoryAtPath:tmpWidgetPath error:nil];
            
            subAppID = [NSString stringWithFormat:@"%@", [widgetPathFolderList firstObject]];
            //拼接上appID
            tmpWidgetPath = [tmpWidgetPath stringByAppendingPathComponent:subAppID];
            outputPath = [outputPath stringByAppendingPathComponent:subAppID];
            
            NSError *error;
            //新版补丁包config.xml目录结构: widget(plugin并列)/appID/config.xml
            NSData *xmlData = [NSData dataWithContentsOfFile:[tmpWidgetPath stringByAppendingPathComponent:@"config.xml"]];
            ONOXMLDocument *configDocument = [ONOXMLDocument XMLDocumentWithData:xmlData error:&error];
            if (!configDocument) {
                ACLogError(@"read patched config.xml failed: %@",error.localizedDescription);
            }
            newVersion = configDocument.rootElement[@"version"];
            
            //widgets/appId/version/config.xml 最终子应用的目录
            outputPath =[outputPath stringByAppendingPathComponent:newVersion];
            
            if ([ACEWidgetUpdateUtility copyItemsFromPath:tmpWidgetPath toPath:outputPath ]) {
                
                NSLog(@"appcan-->Engine-->ACEWidgetUpdateUtility.m-->unZipSubWidgetNeedPatchUpdate-->outputPath = %@", outputPath);
                
                [fileMgr removeItemAtPath:tmpPatchPath error:nil];
                [fileMgr removeItemAtPath:subWidgetPatchZipPath error:nil];
                
            } else {
                NSLog(@"新版本的补丁包--->>更新失败");
            }
            
        } else {
            
            NSArray *widgetPathFolderList = [fileMgr contentsOfDirectoryAtPath:tmpPatchPath error:nil];
            
            subAppID = [NSString stringWithFormat:@"%@", [widgetPathFolderList firstObject]];
            
            //拼接上appID
            NSString *tmpWidgetPath = [tmpPatchPath stringByAppendingPathComponent:subAppID];
            outputPath = [outputPath stringByAppendingPathComponent:subAppID];
            
            NSError *error;
            //旧版补丁包zip目录  appID/config.xml
            NSData *xmlData = [NSData dataWithContentsOfFile:[tmpWidgetPath stringByAppendingPathComponent:@"config.xml"]];
            ONOXMLDocument *configDocument = [ONOXMLDocument XMLDocumentWithData:xmlData error:&error];
            if (!configDocument) {
                ACLogError(@"old read patched config.xml failed: %@",error.localizedDescription);
            }
            newVersion = configDocument.rootElement[@"version"];
            
            //widgets/appId/version/config.xml 最终子应用的目录
            outputPath =[outputPath stringByAppendingPathComponent:newVersion];
            
            if ([ACEWidgetUpdateUtility copyItemsFromPath:tmpWidgetPath toPath:outputPath]) {
                
                NSLog(@"appcan-->old-->Engine-->ACEWidgetUpdateUtility.m-->unZipSubWidgetNeedPatchUpdate-->outputPath = %@", outputPath);
                
                [fileMgr removeItemAtPath:tmpPatchPath error:nil];
                [fileMgr removeItemAtPath:subWidgetPatchZipPath error:nil];
                
            } else {
                
                NSLog(@"旧版本的补丁包--->>更新失败");
                
            }
        }
        
        if (newVersion && newVersion.length > 0){
            
            [StandardUserDefaults setObject:newVersion forKey:subAppID];
            
        }
    }
    
}



+ (BOOL)copyItemsFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    
    NSError * error;
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    BOOL folderFlag = YES;
    
    
    NSArray *strArr = [toPath componentsSeparatedByString:@"/"];
    NSString *str = strArr.lastObject;
    NSString *path = [toPath substringToIndex:toPath.length - str.length -1 ];
    
    NSString *pathStr;
    if ([fileMgr fileExistsAtPath:path]) {
        NSDirectoryEnumerator * fromEnumerator = [fileMgr enumeratorAtPath:path];
        pathStr = [fromEnumerator nextObject];
    }
    if (pathStr) {
        path = [path stringByAppendingPathComponent:pathStr];
    }
    //旧版本文件移到新目录中
    if ([fileMgr fileExistsAtPath:path]) {
        NSError * error;
        NSDirectoryEnumerator * fromEnumerator = [fileMgr enumeratorAtPath:path];
        NSString * fileName = nil;
        BOOL result;
        NSMutableArray *arr = [NSMutableArray array];
        while ((fileName = [fromEnumerator nextObject])!= nil) {
            NSString * oldFilePath = [path stringByAppendingPathComponent:fileName];
            NSString * newFilePath = [toPath stringByAppendingPathComponent:fileName];
            [arr addObject:newFilePath];
            BOOL flag = YES;
            if ([fileMgr fileExistsAtPath:oldFilePath isDirectory:&flag]) {
                if (!flag) {
                    if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                        if ([fileMgr fileExistsAtPath:newFilePath]) {
                            result = [fileMgr removeItemAtPath:newFilePath error:&error];
                            if (!result && error) {
                                return NO;
                            }
                        }
                        result =  [fileMgr moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
                        if (!result && error) {
                            return NO;
                        }
                    }
                } else {
                    result = [fileMgr createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:&error];
                    if (!result && error) {
                        return NO;
                    }
                }
            }
        }
        [fileMgr removeItemAtPath:path error:&error];
    }
    
    if (![fileMgr fileExistsAtPath:toPath isDirectory:&folderFlag]) {//如果目标路径不存在则创建
        BOOL result = [fileMgr createDirectoryAtPath:toPath
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error];
        [BUtility addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:toPath]];
        if (!result && error) {
            return NO;
        }
    }
    //补丁包升级
    if ([fileMgr fileExistsAtPath:fromPath]) {
        NSError * error;
        NSDirectoryEnumerator * fromEnumerator = [fileMgr enumeratorAtPath:fromPath];
        NSString * fileName = nil;
        BOOL result;
        NSMutableArray *arr = [NSMutableArray array];
        while ((fileName = [fromEnumerator nextObject])!= nil) {
            NSString * oldFilePath = [fromPath stringByAppendingPathComponent:fileName];
            NSString * newFilePath = [toPath stringByAppendingPathComponent:fileName];
            [arr addObject:newFilePath];
            BOOL flag = YES;
            if ([fileMgr fileExistsAtPath:oldFilePath isDirectory:&flag]) {
                if (!flag) {
                    if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                        if ([fileMgr fileExistsAtPath:newFilePath]) {
                            result = [fileMgr removeItemAtPath:newFilePath error:&error];
                            if (!result && error) {
                                return NO;
                            }
                        }
                        result =  [fileMgr moveItemAtPath:oldFilePath toPath:newFilePath error:&error];
                        if (!result && error) {
                            return NO;
                        }else{
                            [fileMgr removeItemAtPath:oldFilePath error:&error];
                        }
                    }
                } else {
                    result = [fileMgr createDirectoryAtPath:newFilePath withIntermediateDirectories:YES attributes:nil error:&error];
                    if (!result && error) {
                        return NO;
                    }
                }
            }
        }
    } else {
        return NO;
    }
    return YES;
}


+ (BOOL)mergeFolderAtPath:(NSString *)src intoPath:(NSString *)dst error:(NSError **)error{
    
    __block NSError *err = nil;
    @onExit{
        if (error && err) {
            *error = err;
        }
    };
    NSDirectoryEnumerator *srcDirEnum = [FileManager enumeratorAtPath:src];
    NSString *subPath;
    while ((subPath = [srcDirEnum nextObject])) {
        
        NSString *srcFullPath =  [src stringByAppendingPathComponent:subPath];
        NSString *potentialDstPath = [dst stringByAppendingPathComponent:subPath];
        
        BOOL isDirectory = [FileManager fileExistsAtPath:srcFullPath isDirectory:&isDirectory] && isDirectory;
        

        if (isDirectory) {
            if(![FileManager createDirectoryAtPath:potentialDstPath withIntermediateDirectories:YES attributes:nil error:&err] || err){
                //return YES if the directory was created, YES if createIntermediates is set and the directory already exists, or NO if an error occurred.
                return NO;
            }else{
                if(![self mergeFolderAtPath:srcFullPath intoPath:potentialDstPath error:&err]){
                    return NO;
                }
            }
        }else {
            if ([FileManager fileExistsAtPath:potentialDstPath] && (![FileManager removeItemAtPath:potentialDstPath error:&err] || err)) {
                return NO;
            }
            if (![FileManager moveItemAtPath:srcFullPath toPath:potentialDstPath error:&err] || err) {
                return NO;
            }
        }
    }
    return YES;
}


@end
