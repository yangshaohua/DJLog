//
//  DJLogFile.h
//  DJLog
//
//  Created by yang on 16/5/14.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJLogFile : NSObject


//获取日志文件夹的根目录
+ (NSString *)djLogDirectory;
+ (NSString *)djLogUploadDirectory;
//+ (NSArray*)allFileNameAtPath:(NSString*)path;
+ (NSArray*)allZipFileName;
+ (NSArray*)allTxtFileName;

+ (BOOL)deleteFileAtPath:(NSString *)path;

/** 获取新文件名字 */
+ (NSString *)newLogFileName;

/**
 *  创建文件
 *
 *  @param path    路径
 *  @param content 文件内容
 *
 *  @return 是否创建成功
 */
+ (BOOL)createFileAtPath:(NSString *)path content:(NSString *) content;

/**
 *  写入新数据到文件
 *
 *  @param path    路径
 *  @param content 文件内容
 *
 *  @return 是否写入成功
 */
+ (BOOL)writeDataToFileAtPath:(NSString *)path content:(NSString *)content;

/**
 *  剪切文件操作，该操作比较耗时，需要放在子线程进行。
 *
 *  @param path   文件路径
 *  @param toPath 目标文件路径
 *
 *  @return 是否剪切成功
 */
+ (BOOL)moveFile:(NSString *)path toPath:(NSString *)toPath;

@end
