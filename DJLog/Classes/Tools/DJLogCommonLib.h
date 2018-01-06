//
//  DJLogCommonLib.h
//  DJLog
//
//  Created by shaozhou li on 16/5/16.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG 
#define DJLLog(...) NSLog(__VA_ARGS__)
#else
#define DJLLog(...)
#endif

@interface DJLogKeyChain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end

@interface DJLogCommonLib : NSObject

/**  随机生成一个UUID，全球唯一标示*/
+ (NSString *)getUUID;

/** 获取IP地址 */
+ (NSString *)getIPAddress;

/** 从keychain获取内容 */
+ (NSString *)fetchKeychinWithKey:(NSString *)key;

/** 写入Keychain */
+ (void)writeKeychainWithKey:(NSString *)key
                       value:(NSString *)value;

/** 获取网络状态 */
+ (NSString *)getConnectionTypeString;

/** 获得设备型号 */
+ (NSString *)getCurrentDeviceModel;

/**
 *  处理包含特殊字符的字符串，Base64加密， 如url
 *
 *  @param str  字符串
 */
+ (NSString*)handleSpecialStr:(NSString*)str;

/**
 *  是否包含特殊字符的字符串
 *
 *  @param str  字符串
 */
+ (BOOL)containSpecialStr:(NSString*)str;
@end
