//
//  AXLogger.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXLogger.h"

@interface AXLogger()
@property(nonatomic) DDFileLogger *fileLogger;
@end

@implementation AXLogger


#pragma mark -
#pragma mark ARC Singleton Implementation
static AXLogger *sharedInstance = nil; // Singleton Instence
+ (instancetype _Nonnull)defaultLogger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    Class myClass = [self class];
    @synchronized(myClass) {
        if ((self = [super init]) != nil) {
            sharedInstance = self;
            // Do any other initialisation stuff here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Logs
- (void) configureLogs {
    @autoreleasepool {
        // Configure CocoaLumberjack
#if SYSTEM_LOGS_ENABLED
        [DDLog addLogger:[DDASLLogger sharedInstance]];
#endif
        
#if CONSOLE_LOGS_ENABLED
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
        
        // Enable Colors (Terminal Only)
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagInfo];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor redColor] backgroundColor:nil forFlag:DDLogFlagError];
        
        // Initialize File Logger
        if(!_fileLogger) {
            _fileLogger = [[DDFileLogger alloc] init];
        }
        
        // Configure File Logger
        /*[_fileLogger setMaximumFileSize:(1024 * 1024) * ];
         [_fileLogger setRollingFrequency:(3600.0 * 24.0)];
         [[_fileLogger logFileManager] setMaximumNumberOfLogFiles:7];*/
        [DDLog addLogger:_fileLogger];
        
        DDLogVerbose(@"Verbose...");
        DDLogDebug(@"Debug...");
        DDLogInfo(@"Info...");
        DDLogWarn(@"Warning...");
        DDLogError(@"Error...");
    }
}

- (NSData *)getConsoleLogs {
    NSData *consoleLogs = nil;
    @autoreleasepool {
        NSUInteger maximumLogFilesToReturn = MIN(self.fileLogger.logFileManager.maximumNumberOfLogFiles, 10);
        NSMutableArray *errorLogFiles = [NSMutableArray arrayWithCapacity:maximumLogFilesToReturn];
        DDFileLogger *logger = self.fileLogger;
        NSArray *sortedLogFileInfos = [logger.logFileManager sortedLogFileInfos];
        for (long i = MIN(sortedLogFileInfos.count, maximumLogFilesToReturn); i > 0; i--) {
            DDLogFileInfo *logFileInfo = sortedLogFileInfos[i - 1];
            NSData *fileData = [NSData dataWithContentsOfFile:logFileInfo.filePath];
            [errorLogFiles addObject:fileData];
        }
        NSMutableData *errorLogData = [NSMutableData data];
        for (NSData *logData in errorLogFiles) {
            [errorLogData appendData:logData];
        }
        consoleLogs = [NSData dataWithData:errorLogData];
    }
    return consoleLogs;
}

- (NSString *)getConsoleLogsString {
    NSString *logsString = nil;
    @autoreleasepool {
        NSData *consoleLogs = [self getConsoleLogs];
        logsString = [[NSString alloc] initWithData:consoleLogs encoding:NSUTF8StringEncoding];
    }
    return logsString;
}

@end
