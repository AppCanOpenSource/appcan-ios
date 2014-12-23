/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "EUExManager.h"
#import "EUExBase.h"
#import "EBrowser.h"
#import "EBrowserView.h"
#import "EUExAction.h"
#import "BUtility.h"



#ifdef WIDGETONE_FOR_IDE_DEBUG
#import <objc/runtime.h>
#import <dlfcn.h>
#endif

@implementation EUExManager
@synthesize eBrwView;
@synthesize eBrwCtrler;
@synthesize uexObjDict;

- (id)initWithBrwView:(EBrowserView*)eInBrwView BrwCtrler:(EBrowserController*)eInBrwCtrler{
	if (self = [super init]) {
		eBrwView = eInBrwView;
		eBrwCtrler = eInBrwCtrler;
		uexObjDict = [[NSMutableDictionary alloc]initWithCapacity:UEX_OBJ_SIZE];
	}
	return self;
}


- (void)doAction:(EUExAction *)inAction{
	NSString *className = inAction.mClassName;
	NSString *methodName = inAction.mMethodName;
	EUExBase *eUExObj = [uexObjDict objectForKey:className];
	if (!eUExObj) {
		NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        ACENSLog(@"fullClassName--------->%@",fullClassName);
        ACENSLog(@"methodName--------->%@",methodName);
        
#ifdef WIDGETONE_FOR_IDE_DEBUG
        
        //modify for IDE debug
        
//        [self loadDynamicLibForIDEDebug:eUExObj];
        
        //        if (NO == [self loadDynamicLibForIDEDebug:eUExObj]) {
        //            [eUExObj release];
        //            return;
        //        }
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDirectory = nil;
        if ([paths count] != 0)
            documentDirectory = [paths objectAtIndex:0];
        
        
        NSString *libName = [NSString stringWithFormat:@"/dyFiles/%@.dylib", className];
//        NSString *libName = [NSString stringWithFormat:@"/dyFiles/Test1.dylib"];
        
        NSString *destLibPath = [documentDirectory stringByAppendingPathComponent:libName];
        
        NSLog(@"动态库路径是：#-------------#%@",destLibPath);
        if ([[NSFileManager defaultManager] fileExistsAtPath:destLibPath])
        {
            void *lib_handle = dlopen([destLibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LOCAL);
            if (!lib_handle) {
                ACENSLog(@"load dynamic lib = %@ failed", libName);
            }
        }
        else
        {
            BOOL success;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"dyFiles"];
         
            NSString  *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:libName];
            if ([fileManager fileExistsAtPath:defaultDBPath])
            {
                success = [BUtility copyMissingFile:defaultDBPath toPath:writableDBPath];
                if (!success) {
                    NSLog(0, @"Failed to create writable database file with message " );
                }else
                {
                    void *lib_handle = dlopen([destLibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LOCAL);
                    if (!lib_handle) {
                        ACENSLog(@"load dynamic lib = %@ failed", libName);
                    }
                }
            }
        }
		
#endif

		eUExObj = [[NSClassFromString(fullClassName) alloc] initWithBrwView:eBrwView];
		if (!eUExObj) {
			return;
		}
        
#ifdef WIDGETONE_FOR_IDE_DEBUG
        
        NSString *superClassName = NSStringFromClass([eUExObj.superclass class]);
        
        
        if (([eUExObj isKindOfClass:[EUExBase class]])) {
            
        } else if([superClassName isEqualToString:@"EUExBase"]) {
            
        } else {
            
            [eUExObj release];  //cui  20130603
			return;
        }
        
#else
        
        
        if (!([eUExObj isKindOfClass:[EUExBase class]])) {
            [eUExObj release];  //cui  20130603
			return;
		}
#endif

		[uexObjDict setObject:eUExObj forKey:className];
	}
	NSString* fullMethodName = [NSString stringWithFormat:@"%@:", methodName];
	if ([eUExObj respondsToSelector:NSSelectorFromString(fullMethodName)]) {
        //[eUExObj performSelector:NSSelectorFromString(fullMethodName) withObject:inAction.mArguments];
        [eUExObj performSelectorOnMainThread:NSSelectorFromString(fullMethodName)  withObject:inAction.mArguments waitUntilDone:NO];
    } else {
        ACENSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", methodName, inAction.mClassName);
    }
}

-(void)clean{
	if (!uexObjDict) {
		return;
	}
	for (EUExBase *eUExObj in [uexObjDict allValues]) {
		[eUExObj clean];
	}
}

- (void)notifyDocChange {
	[self clean];
}

- (void)stopAllNetService {
	if (!uexObjDict) {
		return;
	}
	NSArray *objArray = [uexObjDict allValues];
	for (EUExBase * eUExObj in objArray) {
		[eUExObj clean];
	}
}

-(void)dealloc{
	ACENSLog(@"EUExManager retain count is %d",[self retainCount]);
	ACENSLog(@"EUExManager dealloc is %x", self);
	if (!uexObjDict) {
		return;
	}
	NSArray *objArray = [uexObjDict allValues];
	for (EUExBase * eUExObj in objArray) {
		[eUExObj release];
	}
	[uexObjDict removeAllObjects];
	[uexObjDict release];
	uexObjDict =nil;
	[super dealloc];
}
#ifdef WIDGETONE_FOR_IDE_DEBUG

- (BOOL)loadDynamicLibForIDEDebug:(EUExBase *)eUExObj
{
    NSString *superClassName = NSStringFromClass([eUExObj.superclass class]);
    
    
    if (([eUExObj isKindOfClass:[EUExBase class]])) {
        
    } else if([superClassName isEqualToString:@"EUExBase"]) {
        
    } else {
        
        return NO;
    }
    
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = nil;
    if ([paths count] != 0)
        documentDirectory = [paths objectAtIndex:0];
    
    NSString *className = NSStringFromClass([eUExObj class]);
    
    NSString *libName = [NSString stringWithFormat:@"/dyFiles/%@.dylib", className];
    
    NSString *destLibPath = [documentDirectory stringByAppendingPathComponent:libName];
    
    NSLog(@"动态库路径是：#-------------#%@",destLibPath);
    
    void *lib_handle = dlopen([destLibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LOCAL);
    if (!lib_handle) {
        ACENSLog(@"load dynamic lib = %@ failed", libName);
        return NO;
    }
    
    return YES;
    
}

//- (void)doActionForIDEDebug:(EUExAction *)inAction
//{
//    NSString *className = inAction.mClassName;
//	NSString *methodName = inAction.mMethodName;
//	EUExBase *eUExObj = [uexObjDict objectForKey:className];
//	if (!eUExObj) {
//		NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
//		//NSLog(@"fullclassname = %@ and methodname = %@",fullClassName,methodName);
//		ACENSLogWithString(fullClassName,methodName);
//        ACENSLog(@"fullClassName--------->%@",fullClassName);
//        ACENSLog(@"methodName--------->%@",methodName);
//        
//		eUExObj = [[NSClassFromString(fullClassName) alloc] initWithBrwView:eBrwView];
//		if (!eUExObj) {
//			return;
//		}
//        //#ifdef WIDGETONE_FOR_IDE_DEBUG
//        
//        //modify for IDE debug
//        
//        if (NO == [self loadDynamicLibForIDEDebug:eUExObj]) {
//            [eUExObj release];
//            return;
//        }
//		
//        //#else
//        //
//        //
//        //        if (!([eUExObj isKindOfClass:[EUExBase class]])) {
//        //            [eUExObj release];  //cui  20130603
//        //			return;
//        //		}
//        //
//        //#endif
//		[uexObjDict setObject:eUExObj forKey:className];
//	}
//	NSString* fullMethodName = [NSString stringWithFormat:@"%@:", methodName];
//	if ([eUExObj respondsToSelector:NSSelectorFromString(fullMethodName)]) {
//        //[eUExObj performSelector:NSSelectorFromString(fullMethodName) withObject:inAction.mArguments];
//        [eUExObj performSelectorOnMainThread:NSSelectorFromString(fullMethodName)  withObject:inAction.mArguments waitUntilDone:NO];
//    } else {
//        ACENSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", methodName, inAction.mClassName);
//    }
//}


#endif

	 
@end
