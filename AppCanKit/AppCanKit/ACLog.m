/**
 *
 *	@file   	: ACLog.m  in AppCanKit
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

#import "ACLog.h"

#import "ACLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACLogNode : NSObject
@property (nonatomic,strong)id<ACLogger> logger;
@property (nonatomic,strong)dispatch_queue_t logQueue;

@end

@implementation ACLogNode

- (nullable instancetype)initWithLogger:(id<ACLogger>)logger{
    if (!logger) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _logger = logger;
        NSString *loggerName = NSStringFromClass([logger class]);
        if ([logger respondsToSelector:@selector(loggerName)]) {
            loggerName = [logger loggerName];
        }
        if([logger respondsToSelector:@selector(logQueue)]){
            _logQueue = [logger logQueue];
        }
        if (!_logQueue) {
            _logQueue = dispatch_queue_create([loggerName UTF8String], DISPATCH_QUEUE_SERIAL);
        }
    }
    return self;
}

- (void)flush{
    if ([_logger respondsToSelector:@selector(flush)]) {
        [_logger flush];
    }
}

@end




ACLogMode ACLogGlobalLogMode;
BOOL ACLogAsyncLogEnabled = YES;

static NSMutableDictionary<NSString *,NSNumber*> *ACLogFileLogModes;
static NSMutableArray<ACLogNode *> *ACLogNodes;

static void *const ACLogDispatchMessageQueueIdentity = (void *)&ACLogDispatchMessageQueueIdentity;
static dispatch_queue_t ACLogDispatchMessageQueue;
static dispatch_group_t ACLogDispatchMessageGroup;
static const NSUInteger kACLogMaxQueueMessageCount = 500;
static dispatch_semaphore_t ACLogDispatchMessageSemaphore;


@implementation ACLog


+ (void)load{
#if DEBUG
    ACLogGlobalLogMode = ACLogModeDebug;
#else
    ACLogGlobalLogMode = ACLogModeInfo;
#endif
    ACLogFileLogModes = [NSMutableDictionary dictionary];
    ACLogDispatchMessageQueue = dispatch_queue_create("com.AppCan.AppCanKit.ACLog.dispatchQueue",DISPATCH_QUEUE_SERIAL);
    dispatch_queue_set_specific(ACLogDispatchMessageQueue, ACLogDispatchMessageQueueIdentity, ACLogDispatchMessageQueueIdentity, NULL);
    ACLogDispatchMessageGroup = dispatch_group_create();
    ACLogDispatchMessageSemaphore = dispatch_semaphore_create(kACLogMaxQueueMessageCount);
    ACLogNodes = [NSMutableArray array];
    
}

+ (void)setGlobalLogMode:(ACLogMode)mode{
    ACLogGlobalLogMode = mode;
}

+ (void)setAsyncLogEnabled:(BOOL)isEnabled{
    ACLogAsyncLogEnabled = isEnabled;
}

+ (void)setLogMode:(ACLogMode)mode forFile:(const char *)file{
    NSString *fileStr = [NSString stringWithFormat:@"%s",file];
    [ACLogFileLogModes setValue:@(mode) forKey:fileStr];
}


+ (void)addLogger:(nullable id<ACLogger>)logger{
    ACLogNode *node = [[ACLogNode alloc]initWithLogger:logger];
    if (node) {
        [ACLogNodes addObject:node];
    }
}

+ (void)log:(BOOL)isAsynchronous level:(ACLogLevel)level file:(const char *)file function:(const char *)func line:(NSUInteger)line format:(nullable NSString *)fmt, ...{
    if (!fmt) {
        return;
    }
    NSString *fileStr = [NSString stringWithFormat:@"%s",file];
    NSString *funcStr = [NSString stringWithFormat:@"%s",func];
    ACLogMode mode = ACLogGlobalLogMode;
    if (ACLogFileLogModes[fileStr]) {
        mode = (ACLogMode)ACLogFileLogModes[fileStr].integerValue;
    }
    if (! (mode & level)) {
        return;
    }
    va_list args;
    va_start(args, fmt);
    NSString *message = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    ACLogMessage *msg = [[ACLogMessage alloc]initWithMessage:message
                                                       level:level
                                                        file:fileStr
                                                    function:funcStr
                                                        line:line
                                                   timestamp:nil];
    [self queueMessage:msg asynchronous:isAsynchronous];
}

+ (void)queueMessage:(ACLogMessage *)message asynchronous:(BOOL)isAsynchronous{
    dispatch_semaphore_wait(ACLogDispatchMessageSemaphore, DISPATCH_TIME_FOREVER);
    dispatch_block_t log = ^{
        @autoreleasepool {
            [self log:message];
        }
    };
    if(isAsynchronous){
        dispatch_async(ACLogDispatchMessageQueue, log);
    }else{
        dispatch_sync(ACLogDispatchMessageQueue, log);
    }
}

+ (void)log:(ACLogMessage *)message{
    NSAssert(dispatch_get_specific(ACLogDispatchMessageQueueIdentity),@"这个方法只应该在ACLogDispatchMessageQueue中运行");
    
    for (ACLogNode *node in ACLogNodes) {
        dispatch_group_async(ACLogDispatchMessageGroup, node.logQueue, ^{
            [node.logger logMessage:message];
        });
    }
    dispatch_group_wait(ACLogDispatchMessageGroup, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_signal(ACLogDispatchMessageSemaphore);
     
}


@end







NS_ASSUME_NONNULL_END