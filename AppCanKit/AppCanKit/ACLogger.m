/**
 *
 *	@file   	: ACLogger.m  in AppCanKit
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

#import "ACLogger.h"
#import <pthread.h>
#import <sys/uio.h>
#import <UIKit/UIKit.h>
#import <asl.h>

@implementation ACLogMessage

- (instancetype)initWithMessage:(NSString *)message
                          level:(ACLogLevel)lvl
                           file:(NSString *)file
                       function:(NSString *)function
                           line:(NSUInteger)line
                      timestamp:(nullable NSDate *)timestamp{
    self = [super init];
    if (self) {
        _message = message;
        _level = lvl;
        _line = line;
        _file = file ;
        _fileName = file.lastPathComponent.stringByDeletingPathExtension;
        _timestamp = timestamp ?:[NSDate date];
        _function = function;
        __uint64_t tid;
        pthread_threadid_np(NULL, &tid);
        _threadID = [[NSString alloc] initWithFormat:@"%llu", tid];
        _threadName   = NSThread.currentThread.name;
        _queueLabel = [[NSString alloc] initWithFormat:@"%s", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
    }
    return self;
}
@end

/**
 *  向ASL输出log
 *  @see https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html
 */
@interface ACASLLogger : NSObject<ACLogger>{
    aslclient _client;
}
@end

@implementation ACASLLogger

_ACLogRegisterLogger(ACASLLogger);

+ (instancetype)sharedLogger{
    static ACASLLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[ACASLLogger alloc]init];
    });
    return logger;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _client = asl_open(NULL, "com.apple.console", 0);
    }
    return self;
}

- (NSString *)loggerName{
    return @"com.AppCan.AppCanKit.ACASLLogger";
}


- (void)logMessage:(ACLogMessage *)message{
    const char *msg = [message->_message UTF8String];
    
    size_t aslLogLevel;
    switch (message->_level) {
        case ACLogLevelError: {
            aslLogLevel = ASL_LEVEL_CRIT;
            break;
        }
        case ACLogLevelWarning: {
            aslLogLevel = ASL_LEVEL_ERR;
            break;
        }
        case ACLogLevelInfo: {
            aslLogLevel = ASL_LEVEL_WARNING;
            break;
        }
        case ACLogLevelDebug:
        case ACLogLevelVerbose: {
            aslLogLevel = ASL_LEVEL_NOTICE;
            break;
        }
    }
    
    static char const *const level_strings[] = { "0", "1", "2", "3", "4", "5", "6", "7" };
    

    uid_t const readUID = geteuid();
    
    char readUIDString[16];

    snprintf(readUIDString, sizeof(readUIDString), "%d", readUID);
    
    
    
    aslmsg m = asl_new(ASL_TYPE_MSG);
    if (m != NULL) {
        if (asl_set(m, ASL_KEY_LEVEL, level_strings[aslLogLevel]) == 0 &&
            asl_set(m, ASL_KEY_MSG, msg) == 0 &&
            asl_set(m, ASL_KEY_READ_UID, readUIDString) == 0 &&
            asl_set(m, "ACASLLog", "1") == 0) {
            asl_send(_client, m);
        }
        asl_free(m);
    }

}
@end



@interface ACSTDERRLoggerColorInfo : NSObject{
    @public
    
    char fgCode[24];
    size_t fgCodeLen;
    
    char bgCode[24];
    size_t bgCodeLen;
    
    char resetCode[8];
    size_t resetCodeLen;
}


- (instancetype)initWithBackgroundColor:(UIColor *)bgColor foregroundColor:(UIColor *)fgColor;
@end

static BOOL isXcodeColorEnabled = NO;


/**
 *  XcodeColor常量
 *  @see https://github.com/robbiehanson/XcodeColors
 */

#define XCODE_COLORS_ESCAPE "\033["
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE "fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE "bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE ";"   // Clear any foreground or background color
@implementation ACSTDERRLoggerColorInfo

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        char *xcode_colors = getenv("XcodeColors");
        if (xcode_colors && (strcmp(xcode_colors, "YES") == 0)) {
            isXcodeColorEnabled = YES;
        }
    });
}


//bgColor和fgColor必须是RGBColor
- (instancetype)initWithBackgroundColor:(UIColor *)bgColor foregroundColor:(UIColor *)fgColor{
    self = [super init];
    if (self) {
        [self setupBackgroundColor:bgColor];
        [self setupForegroundColor:fgColor];
        [self setupResetCode];
    }
    return self;
}

- (void)setupBackgroundColor:(UIColor *)bgColor{
    if (!bgColor || !isXcodeColorEnabled) {
        bgCode[0] = '\0';
        bgCodeLen = 0;
        return;
    }
    
    CGFloat r,g,b;
    [bgColor getRed:&r green:&g blue:&b alpha:NULL];
    uint8_t iR = (uint8_t)(r * 255.0f),iG = (uint8_t)(g * 255.0f),iB = (uint8_t)(b * 255.0f);;
    
    int result = snprintf(bgCode, 24, "%sbg%u,%u,%u;", XCODE_COLORS_ESCAPE, iR, iG, iB);
    bgCodeLen = (NSUInteger)MAX(MIN(result, (24 - 1)), 0);
    
}

- (void)setupForegroundColor:(UIColor *)fgColor{
    if (!fgColor || !isXcodeColorEnabled) {
        fgCode[0] = '\0';
        fgCodeLen = 0;
        return;
    }
    
    CGFloat r,g,b;
    [fgColor getRed:&r green:&g blue:&b alpha:NULL];
    uint8_t iR = (uint8_t)(r * 255.0f),iG = (uint8_t)(g * 255.0f),iB = (uint8_t)(b * 255.0f);;
    
    int result = snprintf(fgCode, 24, "%sfg%u,%u,%u;", XCODE_COLORS_ESCAPE, iR, iG, iB);
    fgCodeLen = (NSUInteger)MAX(MIN(result, (24 - 1)), 0);
}

- (void)setupResetCode{
    if (!isXcodeColorEnabled) {
        resetCode[0] = '\0';
        resetCodeLen = 0;
    }else{
        resetCodeLen = (NSUInteger)MAX(snprintf(resetCode, 8,XCODE_COLORS_RESET), 0);
    }
    
}

@end


/**
 *  向Console输出log
 */
@interface ACSTDERRLogger : NSObject<ACLogger>

@property (nonatomic,strong)NSDateFormatter *dateFormatter;
@property (nonatomic,strong)NSMutableDictionary<NSNumber *,ACSTDERRLoggerColorInfo *> *colorInfo;
@end

@implementation ACSTDERRLogger

_ACLogRegisterLogger(ACSTDERRLogger);

+ (instancetype)sharedLogger{
    static ACSTDERRLogger *logger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[self alloc] init];
    });
    return logger;
}

- (instancetype)init{
    self = [super init];
    if (self) {
//XcodeColor仅在debug模式有效
#ifdef DEBUG
        _colorInfo = [NSMutableDictionary dictionary];
        UIColor *defaultBGColor = RGBColor(35, 35, 35);
        [_colorInfo setObject:[[ACSTDERRLoggerColorInfo alloc] initWithBackgroundColor:defaultBGColor foregroundColor:RGBColor(204,51,26)] forKey:@(ACLogLevelError)];
        [_colorInfo setObject:[[ACSTDERRLoggerColorInfo alloc] initWithBackgroundColor:defaultBGColor foregroundColor:RGBColor(204,102,0)] forKey:@(ACLogLevelWarning)];
        [_colorInfo setObject:[[ACSTDERRLoggerColorInfo alloc] initWithBackgroundColor:defaultBGColor foregroundColor:RGBColor(128,178,178)] forKey:@(ACLogLevelInfo)];
        [_colorInfo setObject:[[ACSTDERRLoggerColorInfo alloc] initWithBackgroundColor:defaultBGColor foregroundColor:[UIColor lightGrayColor]] forKey:@(ACLogLevelDebug)];
        [_colorInfo setObject:[[ACSTDERRLoggerColorInfo alloc] initWithBackgroundColor:defaultBGColor foregroundColor:[UIColor darkGrayColor]] forKey:@(ACLogLevelVerbose)];
#endif
    }
    return self;
}


- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        _dateFormatter = dateFormatter;
    }
    return _dateFormatter;
}




- (void)logMessage:(ACLogMessage *)message{
    struct iovec v[5];
    
    NSString *logMsg = [self formatedMessage:message];
    NSUInteger msgLen = [logMsg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const BOOL useStack = msgLen < (1024 * 4);
    
    char msgStack[useStack ? (msgLen + 1) : 1]; // Analyzer doesn't like zero-size array, hence the 1
    char *msg = useStack ? msgStack : (char *)malloc(msgLen + 1);
    
    if (msg == NULL) {
        return;
    }
    
    BOOL logMsgEnc = [logMsg getCString:msg maxLength:(msgLen + 1) encoding:NSUTF8StringEncoding];
    
    if (!logMsgEnc) {
        if (!useStack && msg != NULL) {
            free(msg);
        }
        return;
    }
    v[2].iov_base = (char *)msg;
    v[2].iov_len = msgLen;
    

    v[3].iov_base = "\n";
    v[3].iov_len = (msg[msgLen] == '\n') ? 0 : 1;
    //XcodeColorSupport
    ACSTDERRLoggerColorInfo *info = self.colorInfo[@(message->_level)];
    if (!info) {
        v[0].iov_base = "";
        v[0].iov_len = 0;
        
        v[1].iov_base = "";
        v[1].iov_len = 0;
        
        v[4].iov_base = "";
        v[4].iov_len = 0;
    }else{
        v[0].iov_base = info->fgCode;
        v[0].iov_len = info->fgCodeLen;
        
        v[1].iov_base = info->bgCode;
        v[1].iov_len = info->bgCodeLen;
        
        v[4].iov_base = info->resetCode;
        v[4].iov_len = info->resetCodeLen;
    }
    writev(STDERR_FILENO, v, 5);
    if (!useStack) {
        free(msg);
    }
}


- (NSString *)formatedMessage:(ACLogMessage *)message{
    NSString *dateStr = [self.dateFormatter stringFromDate:message->_timestamp];
    NSString *queueStr = nil;
    BOOL useQueueLabel = YES;
    BOOL useThreadName = [message->_threadName length] > 0;
    if (message->_queueLabel) {
        NSArray<NSString *> *GCDQueueLabels = @[
                           @"com.apple.root.low-priority",
                           @"com.apple.root.default-priority",
                           @"com.apple.root.high-priority",
                           @"com.apple.root.low-overcommit-priority",
                           @"com.apple.root.default-overcommit-priority",
                           @"com.apple.root.high-overcommit-priority",
                           @"com.apple.root.low-qos.overcommit",
                           @"com.apple.root.default-qos.overcommit",
                           @"com.apple.root.high-qos.overcommit",
                           @"com.apple.root.low-qos",
                           @"com.apple.root.default-qos",
                           @"com.apple.root.high-qos",
                           ];
        
        for (NSString * label in GCDQueueLabels) {
            if ([message->_queueLabel isEqualToString:label]) {
                useQueueLabel = NO;
                break;
            }
        }
    }else{
        useQueueLabel = NO;

    }
    if (useQueueLabel) {
        queueStr = message->_queueLabel;
    }else if(useThreadName){
        queueStr = message->_threadName;
    }else{
        queueStr = message->_threadID;
    }
    
    NSDictionary<NSString *,NSString *> *replacement = @{
                                                       @"com.apple.main-thread": @"main"
                                                       };
    if (replacement[queueStr]) {
        queueStr = replacement[queueStr];
    }
    
    NSString *lvlStr = nil;
    switch (message->_level) {
        case ACLogLevelError: {
            lvlStr = @"E";
            break;
        }
        case ACLogLevelWarning: {
            lvlStr = @"W";
            break;
        }
        case ACLogLevelInfo: {
            lvlStr = @"I";
            break;
        }
        case ACLogLevelDebug: {
            lvlStr = @"D";
            break;
        }
        case ACLogLevelVerbose: {
            lvlStr = @"V";
            break;
        }
    }
    return [NSString stringWithFormat:@"%@ [%@:%@] %@",dateStr,lvlStr,queueStr,message->_message];
}

- (NSString *)loggerName{
    return @"com.AppCan.AppCanKit.ACSTDERRLogger";
}


static inline UIColor * RGBColor(CGFloat r,CGFloat g,CGFloat b){
    return [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f];
}

@end

