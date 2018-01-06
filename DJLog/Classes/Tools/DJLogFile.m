//
//  DJLogFile.m
//  DJLog
//
//  Created by yang on 16/5/14.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLogFile.h"
#import "DJLogConstants.h"
@implementation DJLogFile

+ (NSString*)documentsDirectory{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    return documentsDirectory;
}

+ (NSString * )createDirectoryWithPath:(NSString *)path;
{

    if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        NSAssert(success,@"创建目录失败");
        return path;
    }
    return path;
}
+ (NSString *)djLogDirectory
{
    NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:DJLOG_Directory];

    return [self createDirectoryWithPath:path];
}
+ (NSString *)djLogUploadDirectory
{
    NSString *path = [[self djLogDirectory] stringByAppendingPathComponent:DJLOG_UPLOAD_Directory];
    return [self createDirectoryWithPath:path];
}

+(NSArray*)allFileNameAtPath:(NSString*)path
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSDirectoryEnumerator * enumerator=[fileManager enumeratorAtPath:path];
    return enumerator.allObjects;
}

+ (NSArray *)fileNameAtPath:(NSString*)path fileType:(NSString*)fileType
{
    NSMutableArray * array = [NSMutableArray array];
    NSArray * fileArray = [DJLogFile allFileNameAtPath:[DJLogFile djLogUploadDirectory]];
    for (NSString * fileName in fileArray) {
        if ([fileName hasSuffix:fileType]) {
            [array addObject:fileName];
        }
    }
    return array;
}
+(NSArray *)allTxtFileName
{
    return [self fileNameAtPath:[DJLogFile djLogUploadDirectory] fileType:DJLOG_TXT_SUFFIX];
}
+(NSArray *)allZipFileName
{
    return [self fileNameAtPath:[DJLogFile djLogUploadDirectory] fileType:DJLOG_ZIP_SUFFIX];

}

#pragma mark - File Helper

+ (NSString *)newLogFileName {
    @synchronized (self) {
        NSDateFormatter *dateFormatter = [self logFileDateFormatter];
        NSString *formattedDate = [dateFormatter stringFromDate:[NSDate date]];
        NSString * fileName = [NSString stringWithFormat:@"sdk_app_%@_%d%@", formattedDate, arc4random() % 1000, DJLOG_TXT_SUFFIX];
        return fileName;
    }
}

+ (NSDateFormatter *)logFileDateFormatter {
    NSMutableDictionary *dictionary = [[NSThread currentThread]
                                       threadDictionary];
    NSString *dateFormat = @"yyyy'-'MM'-'dd'_'HH'-'mm'-'ss'";
    NSString *key = [NSString stringWithFormat:@"logFileDateFormatter.%@", dateFormat];
    NSDateFormatter *dateFormatter = dictionary[key];
    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        // zh_CN en_US_POSIX
        [dateFormatter setLocale:[NSLocale systemLocale]];
        [dateFormatter setDateFormat:dateFormat];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        dictionary[key] = dateFormatter;
    }
    
    return dateFormatter;
}

+ (NSString *)applicationName {
    static NSString *_appName;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
        
        if (!_appName) {
            _appName = [[NSProcessInfo processInfo] processName];
        }
        
        if (!_appName) {
            _appName = @"";
        }
    });
    
    return _appName;
}

#pragma mark - File operation

+ (BOOL)deleteFileAtPath:(NSString *)path
{
    NSFileManager*fileManager=[NSFileManager defaultManager];
    BOOL isSuccess=[fileManager removeItemAtPath:path error:nil];
    NSAssert(isSuccess,@"删除失败");
    return isSuccess;
}


+ (BOOL)createFileAtPath:(NSString *)path content:(NSString *) content{
    NSFileManager *fm = [NSFileManager defaultManager];
    //创建一个内容文件
    BOOL createSuccess = [fm createFileAtPath:path contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    return createSuccess;
    
}

+ (BOOL)writeDataToFileAtPath:(NSString *)path content:(NSString *)content{
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    
    if(fileHandle == nil) {
        return NO;
    }
    
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
    return YES;
}

+ (BOOL)moveFile:(NSString *)path toPath:(NSString *)toPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm moveItemAtPath:path toPath:toPath error:nil];
}


@end
