//
//  WVSSFileLogger.m
//  WebViewScreenSaver
//
//  Created by Alexandru Gologan on 11/14/25.
//
//  Copyright 2025 Alexandru Gologan.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "WVSSFileLogger.h"

@implementation WVSSFileLogger {
  NSFileHandle *_fileHandle;
  NSString *_logFilePath;
  NSISO8601DateFormatter *_dateFormatter;
}

+ (instancetype)defaultLogger {
  static WVSSFileLogger *defaultLogger = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSURL *libraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory
                                                               inDomain:NSUserDomainMask
                                                      appropriateForURL:nil
                                                                 create:YES
                                                                  error:nil];
    NSURL *logsURL = [libraryURL URLByAppendingPathComponent:@"Logs"];
    NSURL *appLogsURL =
        [logsURL URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];

    defaultLogger = [[self alloc] initWithLogDirectory:appLogsURL.path
                                           logFileName:@"wvss.log"
                                           maxFileSize:1024 * 1024
                                              maxFiles:3];
  });
  return defaultLogger;
}

+ (void)log:(id)caller fct:(const char *)fct format:(NSString *)format, ... {
  va_list args;
  va_start(args, format);
  [[self defaultLogger] log:[[NSString alloc] initWithFormat:@"%p %s %@", caller, fct, format]
                  arguments:args];
  va_end(args);
}

- (instancetype)initWithLogDirectory:(NSString *)directory
                         logFileName:(NSString *)fileName
                         maxFileSize:(NSUInteger)maxSize
                            maxFiles:(NSUInteger)maxFiles {
  self = [super init];
  if (self) {
    _logDirectory = [directory copy];
    _logFileName = [fileName copy];
    _maxFileSize = maxSize;
    _maxFiles = maxFiles;
    _dateFormatter = [[NSISO8601DateFormatter alloc] init];

    [self prepareLogDirectory];
    [self prepareLogFile];
  }
  return self;
}

- (void)dealloc {
  [_fileHandle closeFile];
}

- (void)prepareLogDirectory {
  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:_logDirectory]) {
    [fm createDirectoryAtPath:_logDirectory
        withIntermediateDirectories:YES
                         attributes:nil
                              error:nil];
  }
}

- (void)prepareLogFile {
  _logFilePath = [_logDirectory stringByAppendingPathComponent:_logFileName];

  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:_logFilePath]) {
    [fm createFileAtPath:_logFilePath contents:nil attributes:nil];
  }

  _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
  [_fileHandle seekToEndOfFile];
}

- (void)log:(NSString *)format, ... {
  va_list args;
  va_start(args, format);
  [self log:format arguments:args];
  va_end(args);
}

- (void)log:(NSString *)format arguments:(va_list)args {
  NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

  NSString *timestamp = [_dateFormatter stringFromDate:[NSDate date]];
  NSString *logEntry = [NSString stringWithFormat:@"%@ %@\n", timestamp, message];

  NSData *data = [logEntry dataUsingEncoding:NSUTF8StringEncoding];

  // Check if should rotate
  [_fileHandle seekToEndOfFile];
  unsigned long long fileSize = [_fileHandle offsetInFile];
  if (fileSize + data.length > _maxFileSize) {
    [self rotateLogs];
  }

  [_fileHandle seekToEndOfFile];
  [_fileHandle writeData:data];
  if (@available(macOS 10.15, *)) {
    [_fileHandle synchronizeAndReturnError:NULL];
  } else {
    [_fileHandle synchronizeFile];
  }
}

- (void)rotateLogs {
  [_fileHandle closeFile];

  NSFileManager *fm = [NSFileManager defaultManager];

  // Remove oldest file if exceeds maxFiles
  NSString *oldestPath = [self rotatedFilePathForIndex:_maxFiles - 1];
  if ([fm fileExistsAtPath:oldestPath]) {
    [fm removeItemAtPath:oldestPath error:nil];
  }

  // Shift files: log.2 -> log.3, log.1 -> log.2, ...
  for (NSInteger i = _maxFiles - 2; i >= 0; i--) {
    NSString *src = (i == 0) ? _logFilePath : [self rotatedFilePathForIndex:i - 1];
    NSString *dst = [self rotatedFilePathForIndex:i];
    if ([fm fileExistsAtPath:src]) {
      [fm moveItemAtPath:src toPath:dst error:nil];
    }
  }

  // Create new log file
  [fm createFileAtPath:_logFilePath contents:nil attributes:nil];
  _fileHandle = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
}

- (NSString *)rotatedFilePathForIndex:(NSInteger)index {
  return [_logDirectory
      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%ld", _logFileName,
                                                                (long)index + 1]];
}

@end
