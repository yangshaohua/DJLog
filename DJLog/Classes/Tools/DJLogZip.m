//
//  DJLogZip.m
//  DJLog
//
//  Created by yang on 16/5/14.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLogZip.h"
#import "ZipArchive.h"
#import "DJLogFile.h"
#import "DJLogConstants.h"

@implementation DJLogZip

+(void)zipLogFile
{

    NSArray * fileArray = [DJLogFile allTxtFileName];
    NSString * uploadPath = [DJLogFile djLogUploadDirectory];
    for (NSString * fileName in fileArray) {
        if ([fileName hasSuffix:DJLOG_TXT_SUFFIX]) {
            NSString * zipName = [fileName stringByReplacingOccurrencesOfString:DJLOG_TXT_SUFFIX withString:DJLOG_ZIP_SUFFIX];
            if ([self zipWithPath:uploadPath zipName:zipName fileName:fileName]) {
                NSString * textFilePath = [uploadPath stringByAppendingPathComponent:fileName];
                [DJLogFile deleteFileAtPath:textFilePath];
            }
        }
    }
    
}

+(BOOL)zipWithPath:(NSString*)path zipName:(NSString*)zipName fileName:(NSString*)fileName
{
    NSString *zipFilePath = [path stringByAppendingPathComponent:zipName];
    NSString * textFilePath = [path stringByAppendingPathComponent:fileName];
    BOOL success = [SSZipArchive createZipFileAtPath:zipFilePath withFilesAtPaths:@[textFilePath]];
    NSAssert(success,@"压缩失败");
    return success;
    
//    ZipArchive *za = [[ZipArchive alloc] init];
//
//    NSString *zipFilePath = [path stringByAppendingPathComponent:zipName];
//    [za CreateZipFile2:zipFilePath];
//
//    NSString * textFilePath = [path stringByAppendingPathComponent:fileName];
//
//    [za addFileToZip:textFilePath newname:fileName];
//    BOOL success = [za CloseZipFile2];
//    NSAssert(success,@"压缩失败");
//    return success;
}
@end
