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

+ (void)setMainWidgetNeedPatchUpdate:(NSString * __nullable)patchZipPath{
    BOOL isNeedPatchUpdate = NO;
    if (patchZipPath) {
        // 如果传入的补丁包路径存在，则意味着存在补丁包升级
        isNeedPatchUpdate = YES;
    }
    [StandardUserDefaults setBool:isNeedPatchUpdate forKey:ACEMainWidgetNeedPatchUpdateUserDefaultsKey];
    [StandardUserDefaults setValue:patchZipPath forKey:ACEMainWidgetPatchZipPathUserDefaultsKey];
    [StandardUserDefaults synchronize];
}

+ (NSString *)patchZipPath{
    return [StandardUserDefaults valueForKey:ACEMainWidgetPatchZipPathUserDefaultsKey];
}

+ (ACEWidgetUpdateResult)installMainWidgetPatch{
    
    
    if (!self.isWidgetUpdateEnabled || !self.isWidgetCopyFinished || !self.isMainWidgetNeedPatchUpdate) {
        ACLogInfo(@"installMainWidgetPatch ACEWidgetUpdateResultNotNeeded");
        return ACEWidgetUpdateResultNotNeeded;
    }
    
    //初始化Documents路径
    NSArray *cacheList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //初始化临时文件路径
    NSString *folderPath = [cacheList objectAtIndex:0];
    
    NSString *zipPath = [NSString stringWithFormat:@"%@/%@",folderPath,self.patchZipPath];
    
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
        // 更新补丁包逻辑全部执行完毕，无论成功与失败，全部清空。
        if ([FileManager fileExistsAtPath:zipPath]) {
            [FileManager removeItemAtPath:zipPath error:nil];
        }
        [[self class] setMainWidgetNeedPatchUpdate:nil];
    };
    
    if (!zipPath || ![FileManager fileExistsAtPath:zipPath]) {
        zipPath = self.patchZipPath;
        if (!zipPath || ![FileManager fileExistsAtPath:zipPath]) {
            ACLogInfo(@"patch file is not exist, escape.");
            return ACEWidgetUpdateResultNotNeeded;
        }
    }
    
    if (![FileManager copyItemAtPath:oldWidgetPath toPath:tmpWidgetPath error:&error]) {
        ACLogError(@"copy old widget to tmpFolder failed: %@",error.localizedDescription);
        return ACEWidgetUpdateResultError;
    }
    
    if (![zip UnzipOpenFile:zipPath]
        || ![zip UnzipFileTo:tmpZipPath overWrite:YES]
        || ![zip UnzipCloseFile]) {
        ACLogError(@"unzip patch failed!!!");
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
        
        /*
         JayTag 2019.1.7
         中化发现的问题：提交主应用补丁包时，如果config中的版本号与上传的版本号不一致，会导致永远无法更新新版本的补丁包。
         定位的原因：经过排查，发现旧的逻辑中更新失败时不会清除<需要更新>这个状态，这个状态会导致后面启动上报获取到新版本的补丁包时不进行下载，而下次应用启动时会继续更新上次更新失败的补丁包。问题就出在，正常情况下，一次更新失败后（比如应用刚打开就关闭导致某一步文件操作未执行完），下次应用启动时重新更新成功即可使逻辑正常执行。但如果补丁包的版本等于或者比当前的版本低，则会导致每次更新都会失败，且不会清除<需要更新>这个状态，导致启动上报获取到的新版本也无法下载。
         旧的逻辑：启动时会检查是否已经有下载好的补丁包需要解压更新，如果需要更新(ACEMainWidgetNeedPatchUpdateUserDefaultsKey)，就会执行当前方法进行更新（包括解压拷贝等操作），这时会判断补丁包zip文件路径是否存在、拷贝/移动/解压是否成功、config是否存在等，更新结束后（无论是否成功）会进行启动上报。启动上报获取到新版本的补丁包时会进行下载，但如果本地有未完成的更新则会不进行下载。
         新的逻辑：因为补丁包的版本等于或者比当前的版本低导致更新失败时，清除补丁包和<需要更新>的状态。
         优化思路：目前只是在这一种原因导致更新失败时做了清理，后面是否可以改成只要更新失败就做清理呢（把这里的清理操作移动到@onExit中即可）？弊端是，在更新失败后，下次更新前就要重新下载补丁包，会消耗更多的流量；优点是无论什么原因导致的更新失败（比如手机存储空间已满导致文件拷贝无法完成？），都不会影响到下次更新的流程。
         2020.03.31
         最新修改 by yipeng：已经按照上方的优化思路进行修改，现在出了最开始的判断return之外，其他的return情况都会执行@onExit中的代码，即将补丁包下载的状态归位，下次启动时会进行更新。因为已经遇到了可能影响到下次更新的流程。
         另外备注：由于补丁包本地保存的地址在UD中保存了全路径而不是相对路径，正常使用不会出现问题，但是在xcode调试时，由于每次Run之后的沙箱ID会改变，因此按照原绝对路径寻找补丁包则永远不会成功。若要验证补丁包升级，要么第二次重启app时不要Run，而是手动点开app。要么就是把绝对路径修改为相对路径保存和使用。暂不更改。
         */
//        [FileManager removeItemAtPath:zipPath error:nil];
//        [StandardUserDefaults setBool:NO forKey:ACEMainWidgetNeedPatchUpdateUserDefaultsKey];
//        [StandardUserDefaults setValue:nil forKey:ACEMainWidgetPatchZipPathUserDefaultsKey];
//        [StandardUserDefaults synchronize];
        
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
    
    /*
     JayTag 2019.1.7
     该标识供主应用使用，为使主应用正常更新，注释掉了这里
     */
    //子应用解压后修改解压标识
    //[StandardUserDefaults setBool:NO forKey:ACEMainWidgetNeedPatchUpdateUserDefaultsKey];
    
    NSError * error;
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    BOOL folderFlag = YES;
    
    
    NSArray *strArr = [toPath componentsSeparatedByString:@"/"];
    
    
    
    if (strArr.count > 3) {
        //判断是否为补丁包更新
        NSString *thirdStr = [NSString stringWithFormat:@"%@",strArr[strArr.count - 3]];
        if ([thirdStr isEqualToString:@"widgets"]) {
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
                                result =  [fileMgr copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
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
            }
        }
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
                        result =  [fileMgr copyItemAtPath:oldFilePath toPath:newFilePath error:&error];
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
