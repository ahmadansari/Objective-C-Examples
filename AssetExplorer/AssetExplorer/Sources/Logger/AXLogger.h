//
//  AXLogger.h
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define SYSTEM_LOGS_ENABLED 0
#define CONSOLE_LOGS_ENABLED 1

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelDebug;
#endif


@interface AXLogger : NSObject

+ (instancetype _Nonnull)defaultLogger;

#pragma mark - Logs
- (void) configureLogs;
- (NSData *_Nullable)getConsoleLogs;
- (NSString *_Nullable)getConsoleLogsString;
@end
