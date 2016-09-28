/**
 *
 *	@file   	: ACLogger.h  in AppCanKit
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
#import "ACLog.h"

NS_ASSUME_NONNULL_BEGIN

@class ACLogMessage;
@protocol ACLogger <NSObject>

+ (instancetype)sharedLogger;
- (void)logMessage:(ACLogMessage *)message;

@optional
@property (nonatomic,strong,readonly)dispatch_queue_t logQueue;
@property (nonatomic,strong,readonly)NSString *loggerName;
- (void)flush;

@end





@interface ACLogMessage : NSObject{
@public
    NSString *_message;
    ACLogLevel _level;
    NSString *_file;
    NSString *_fileName;
    NSString *_function;
    NSUInteger _line;
    NSDate *_timestamp;
    NSString *_threadID;
    NSString *_threadName;
    NSString *_queueLabel;
}
@property (nonatomic,readonly)NSString *message;
@property (nonatomic,readonly)ACLogLevel level;
@property (nonatomic,readonly)NSString *file;
@property (nonatomic,readonly)NSString *fileName;
@property (nonatomic,readonly)NSString *function;
@property (nonatomic,readonly)NSUInteger line;
@property (nonatomic,readonly)NSDate *timestamp;
@property (nonatomic,readonly)NSString *threadID;
@property (nonatomic,readonly)NSString *threadName;
@property (nonatomic,readonly)NSString *queueLabel;

- (instancetype)init NS_UNAVAILABLE;//用下面的方法进行初始化

- (instancetype)initWithMessage:(NSString *)message
                          level:(ACLogLevel)lvl
                           file:(NSString *)file
                       function:(NSString *)function
                           line:(NSUInteger)line
                      timestamp:(nullable NSDate *)timestamp;
@end


NS_ASSUME_NONNULL_END

