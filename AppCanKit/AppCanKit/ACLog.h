/**
 *
 *	@file   	: ACLog.h  in AppCanKit
 *
 *	@author 	: CeriNo 
 * 
 *	@date   	: Created on 16/6/13.
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
 
#import <Foundation/Foundation.h>
#import "ACMetamacros.h"

/**
 *  @abstract AppCan日志系统
 *  ACLog是NSLog的替代,用于向Xcode控制台和苹果系统日志(ASL)中输出日志信息
 *
 *  @note ACLog把日志信息分为5个等级,从高到底分别为Error,Warning,Info,Debug,Verbose
 *  默认设置下 在debug环境中,会输出Debug及以上等级的log,在release环境中,会输出Info及以上等级的log
 *  此设置可以进行自定义
 *
 *  @note ACLog 会显示本次log的等级和执行log操作所在的线程信息(优先级为"main" -> 自定义的GCDQueueLabel -> ThreadName -> ThreadID)
 *
 *  @bug ACLog在main()函数执行之前执行时,可能会失效(比如在+load方法中),如果需要在这些时间点输出日志,请不要使用ACLog;
 *
 */





/**
 *  用下列宏来输出相应等级的log,参数同NSLog
 */

#define ACLogError(fmt,...)     _ACLogError(fmt, ##__VA_ARGS__)
#define ACLogWarning(fmt,...)   _ACLogWarning(fmt, ##__VA_ARGS__)
#define ACLogInfo(fmt,...)      _ACLogInfo(fmt, ##__VA_ARGS__)
#define ACLogDebug(fmt,...)     _ACLogDebug(fmt, ##__VA_ARGS__)
#define ACLogVerbose(fmt,...)   _ACLogVerbose(fmt, ##__VA_ARGS__)



//ACLog等级
typedef NS_ENUM(NSUInteger,ACLogLevel){
    ACLogLevelError   = 1 << 0,
    ACLogLevelWarning = 1 << 1,
    ACLogLevelInfo    = 1 << 2,
    ACLogLevelDebug   = 1 << 3,
    ACLogLevelVerbose = 1 << 4
};

//ACLog输出模式
typedef NS_ENUM(NSUInteger,ACLogMode){
    ACLogModeNone = 0,                                      //不输出任何Log
    ACLogModeError = ACLogLevelError,                       //只输出等级为Error的Log
    ACLogModeWarning = ACLogModeError | ACLogLevelWarning,  //输出等级为Warning或更高的Log
    ACLogModeInfo = ACLogModeWarning | ACLogLevelInfo,      //输出等级为Info或更高的Log
    ACLogModeDebug = ACLogModeInfo | ACLogLevelDebug,       //输出等级为Debug或更高的Log
    ACLogModeVerbose = ACLogModeDebug | ACLogLevelVerbose,  //输出等级为Verbose或更高的Log
    ACLogModeAll = NSUIntegerMax                            //输出所有Log
};



/**
 *  全局的日志输出模式 @see ACLogMode
 *
 *  @discussion 在debug环境下,此值默认为ACLogModeDebug,在release环境下,此值默认为ACLogModeInfo
 *
 *  通过ACLogSetGlobalLogMode宏来修改此值,不要直接更改!
 */
APPCAN_EXPORT ACLogMode ACLogGlobalLogMode;


/**
 *  设置全局的日志输出模式
 *
 *  @param mode ACLogMode类型 要设置的logMode
 *
 */
#define ACLogSetGlobalLogMode(mode) \
    _ACLogSetGlobalLogMode(mode)





/**
 *  设置当前文件的日志输出模式
 *
 *  @param mode ACLogMode类型 要设置的logMode
 *
 *  @discussion 设置后从当前文件发出的ACLog仅受此logMode限制,不受全局logMode的影响
 *  @discussion 此宏建议配合和宏#ifdef DEBUG #endif配合,仅在debug时使用,避免在release环境中输出无用日志
 *  例子如下
 @code
 //in .m file
 #ifdef DEBUG
 ACLogSetLogModeForThisFile(ACLogAll);
 #endif
 @endcode
 *
 *  @note 必须在.m或者.mm文件中设置,每个文件中只能设置一次
 */
#define ACLogSetLogModeForThisFile(mode)\
    _ACLogSetLogModeForThisFile(mode)






/**
 *  是否启用异步日志输出,默认值为YES
 *  @discussion 采用异步日志输出会拥有更好的性能(优于NSLog),但在断点调试时,有可能造成日志没有及时输出的情况;
 *      除了ACLogLevelError等级的log会一直同步输出,其他等级的log都会根据此值来决定是否采用异步日志输出
 *
 *  可以通过ACLogSetAsyncLogEnabled宏来修改此设置
 */
APPCAN_EXPORT BOOL ACLogAsyncLogEnabled;

/**
 *  开启/关闭异步日志输出
 *
 *  @param isEnabled BOOL类型 是否采用异步日志输出
 *
 *  @note 此宏建议配合和宏#ifdef DEBUG #endif配合,仅在debug时关闭异步日志输出,避免影响release环境中的APP性能
 */
#define ACLogSetAsyncLogEnabled(isEnabled)\
    _ACLogSetAsyncLogEnabled(isEnabled)










/**
 *  请不要直接使用以下任何方法或者宏=.=!
 */
#pragma mark - Implementation


#define _ACLogError(fmt,...)     _ACLogMacro(NO,ACLogLevelError,__PRETTY_FUNCTION__,fmt, ##__VA_ARGS__)
#define _ACLogWarning(fmt,...)   _ACLogMacro(ACLogAsyncLogEnabled,ACLogLevelWarning,__PRETTY_FUNCTION__,fmt, ##__VA_ARGS__)
#define _ACLogInfo(fmt,...)      _ACLogMacro(ACLogAsyncLogEnabled,ACLogLevelInfo,__PRETTY_FUNCTION__,fmt, ##__VA_ARGS__)
#define _ACLogDebug(fmt,...)     _ACLogMacro(ACLogAsyncLogEnabled,ACLogLevelDebug,__PRETTY_FUNCTION__,fmt, ##__VA_ARGS__)
#define _ACLogVerbose(fmt,...)   _ACLogMacro(ACLogAsyncLogEnabled,ACLogLevelVerbose,__PRETTY_FUNCTION__,fmt, ##__VA_ARGS__)




#define _ACLogMacro(isAsync,lvl,func,fmt,...)   \
    do{                                         \
        [ACLog log: isAsync                     \
             level: lvl                         \
              file: __FILE__                    \
          function: func                        \
              line: __LINE__                    \
            format: (fmt),## __VA_ARGS__];       \
    }while(0)


#define _ACLogSetLogModeForThisFile(mode)       \
    __attribute__((constructor)) static void _ACLogSetCurrentFileLogMode(void){\
        [ACLog setLogMode:mode forFile:__FILE__];\
}

#define _ACLogSetGlobalLogMode(mode) \
    do{[ACLog setGlobalLogMode:mode];}while(0)

#define _ACLogRegisterLogger(loggerClass) \
    __attribute__((constructor)) static void metamacro_concat(_ACLogRegisterLogger_, loggerClass)(void){\
        Class cls = NSClassFromString(@metamacro_stringify(loggerClass));\
        if(!cls || ![cls conformsToProtocol:@protocol(ACLogger)]){\
            return;\
        }\
        id<ACLogger> logger = [cls sharedLogger];\
        [ACLog addLogger:logger];\
    }

#define _ACLogSetAsyncLogEnabled(isEnabled)\
    do{[ACLog setAsyncLogEnabled:isEnabled];}while(0)





@protocol ACLogger;
NS_ASSUME_NONNULL_BEGIN
@interface ACLog : NSObject
+ (void)log:(BOOL)isAsynchronous
      level:(ACLogLevel)level
       file:(const char *)file
   function:(const char *)func
       line:(NSUInteger)line
     format:(nullable NSString *)fmt,... NS_FORMAT_FUNCTION(6,7);

+ (void)setGlobalLogMode:(ACLogMode)mode;
+ (void)setLogMode:(ACLogMode)mode forFile:(const char *)file;
+ (void)addLogger:(nullable id<ACLogger>)logger;
+ (void)setAsyncLogEnabled:(BOOL)isEnabled;

@end
NS_ASSUME_NONNULL_END
