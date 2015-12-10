/*
 *  Copyright (C) 2014 The AppCan Open Source Project.
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

#import "EUExManager.h"
#import "EUExBase.h"
#import "EBrowser.h"
#import "EBrowserView.h"
#import "EUExAction.h"
#import "BUtility.h"
#import "WidgetOneDelegate.h"
#import "ACEPluginModel.h"



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
    
    if (!inAction || inAction == nil || ![inAction isKindOfClass:[EUExAction class]]) {
        return;
    }
    
    NSString * className = inAction.mClassName;
    NSString * methodName = inAction.mMethodName;
    
    if (className == nil || !className || ![className isKindOfClass:[NSString class]] || [className length] <= 3) {
        return;
    }
    
    if (methodName == nil || !methodName || ![methodName isKindOfClass:[NSString class]] || [methodName length] < 1) {
        return;
    }
    
    if (className == nil) {
        return;
    }
    
    WidgetOneDelegate *app = (WidgetOneDelegate *)[UIApplication sharedApplication].delegate;
    ACEPluginModel *model = [app.globalPluginDict objectForKey:className];
    
    EUExBase *eUExObj = nil;
    
    
    if (model != nil) {
        
        eUExObj = model.pluginObj;
    } else {
        
        eUExObj = [uexObjDict objectForKey:className];
    }
	
	if (!eUExObj) {
		NSString * fullClassName = [NSString stringWithFormat:@"EUEx%@", [className substringFromIndex:3]];
        ACENSLog(@"fullClassName--------->%@",fullClassName);
        ACENSLog(@"methodName--------->%@",methodName);
        
#ifdef WIDGETONE_FOR_IDE_DEBUG
        [self loadDynamicFrameworkForPlugin:className];
#endif

        if (!eBrwView || eBrwView == nil || ![eBrwView isKindOfClass:[EBrowserView class]]) {
            return;
        }
        
		eUExObj = [[NSClassFromString(fullClassName) alloc] initWithBrwView:eBrwView];
		if (!eUExObj) {
			return;
		}
        

        
        NSString *superClassName = NSStringFromClass([eUExObj.superclass class]);
        
        
        if (![eUExObj isKindOfClass:[EUExBase class]] && ![superClassName isEqualToString:@"EUExBase"]) {
            [eUExObj release];
			return;
        }

        
        if (model != nil) {
            model.pluginObj = eUExObj;
        } else {
            [uexObjDict setObject:eUExObj forKey:className];
        }
	}
    
    if (model != nil) {
        model.pluginObj.meBrwView = eBrwView;
    }
    
	NSString* fullMethodName = [NSString stringWithFormat:@"%@:", methodName];
	if ([eUExObj respondsToSelector:NSSelectorFromString(fullMethodName)]) {
        //[eUExObj performSelector:NSSelectorFromString(fullMethodName) withObject:inAction.mArguments];
        [eUExObj performSelectorOnMainThread:NSSelectorFromString(fullMethodName)  withObject:inAction.mArguments waitUntilDone:NO];
    } else {
        ACENSLog(@"ERROR: Method '%@' not defined in Plugin '%@'", methodName, inAction.mClassName);
    }
}
#ifdef WIDGETONE_FOR_IDE_DEBUG
/**
 *  尝试载入插件的动态framework
 *
 *  @param pluginName uex开头的插件名
 */
-(void)loadDynamicFrameworkForPlugin:(NSString *)pluginName{
    NSString *frameworkName=[NSString stringWithFormat:@"%@.framework",pluginName];
    
    //载入指定document子目录下的framework
    NSBundle *dynamicBundle=[NSBundle bundleWithPath:[[BUtility dynamicPluginFrameworkFolderPath] stringByAppendingPathComponent:frameworkName]];
    if(dynamicBundle && [dynamicBundle load]){
        NSLog(@"load dynamic framework for plugin:%@",pluginName);
        return;
    }
    
    
    //载入res目录下的framework
    //测试用
#if DEBUG
    dynamicBundle=[NSBundle bundleWithPath:[BUtility wgtResPath:[NSString stringWithFormat:@"res://%@",frameworkName]]];
    if(dynamicBundle && [dynamicBundle load]){
        NSLog(@"load dynamic framework for plugin:%@",pluginName);
        return;
    }
#endif
    
    //旧IDE的载入方式
    //xrg说需要保留
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirectory = nil;
    if ([paths count] != 0){
        documentDirectory = [paths objectAtIndex:0];
    }
    NSString *oldDylibFolderPath=[documentDirectory stringByAppendingPathComponent:@"dyFiles"];
    dynamicBundle=[NSBundle bundleWithPath:[oldDylibFolderPath stringByAppendingPathComponent:frameworkName]];
    if(dynamicBundle && [dynamicBundle load]){
        NSLog(@"load dynamic framework for plugin:%@",pluginName);
        return;
    }
    
    NSString  *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:frameworkName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:defaultDBPath]){
        return;
    }
    if (![BUtility copyMissingFile:defaultDBPath toPath:oldDylibFolderPath]){
        return;
    }
    dynamicBundle=[NSBundle bundleWithPath:[oldDylibFolderPath stringByAppendingPathComponent:frameworkName]];
    if(dynamicBundle && [dynamicBundle load]){
        NSLog(@"load dynamic framework for plugin:%@",pluginName);
    }
}
#endif

-(void)clean{
	if (!uexObjDict) {
		return;
	}
	for (EUExBase *eUExObj in [uexObjDict allValues]) {
        if (eUExObj && [eUExObj respondsToSelector:@selector(clean)]) {
            [eUExObj clean];
        }
	}
}

- (void)notifyDocChange {
	[self clean];
}

- (void)stopAllNetService {
    /*
	if (!uexObjDict) {
		return;
	}
	NSArray *objArray = [uexObjDict allValues];
    
	for (EUExBase * eUExObj in objArray) {
		[eUExObj clean];
	}
    */
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
    
    NSString *libName = [NSString stringWithFormat:@"/dyFiles/%@.framework/%@", className,className];
    
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
