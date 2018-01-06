//
//  DJLogConstants.h
//  DJLog
//
//  Created by yang on 16/5/14.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOG_TEST_ENV 0

//API过期提醒
#define DJLogDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)

//log日志路径
FOUNDATION_EXPORT NSString * const DJLOG_Directory;

//上传的zip的路径
FOUNDATION_EXPORT NSString * const DJLOG_UPLOAD_Directory;

//.zip后缀
FOUNDATION_EXPORT NSString * const DJLOG_ZIP_SUFFIX;
//.txt后缀
FOUNDATION_EXPORT NSString * const DJLOG_TXT_SUFFIX;

//定时器秒数
FOUNDATION_EXPORT NSInteger  const DJLOG_TIME_SECOND;

//日志组件的版本号
FOUNDATION_EXPORT NSString * const DJLOG_VERSION;

//文件上传URL
FOUNDATION_EXPORT NSString * const DJLOG_URL_FILE;
//实时上传URL
FOUNDATION_EXPORT NSString * const DJLOG_URL_PStr;

//通用字段
FOUNDATION_EXPORT NSString * const DJLOG_COMMONSTR;

//上传sdkver字段
FOUNDATION_EXPORT NSString * const DJLOG_SDKVER;
//上传addId字段
FOUNDATION_EXPORT NSString * const DJLOG_APPID;
//上传uploadTime 字段
FOUNDATION_EXPORT NSString * const DJLOG_UPLOADTIME;

//上传zipFile字段
FOUNDATION_EXPORT NSString * const DJLOG_ZIPFILE;
//上传pstr字段
FOUNDATION_EXPORT NSString * const DJLOG_PSTR;


//日志分隔符 @“ \001”
FOUNDATION_EXPORT NSString * const DJLOG_SEPARATOR;

//空值占位符 @"-"
FOUNDATION_EXPORT NSString * const DJLOG_NODATA;


//IEMI存写标志
FOUNDATION_EXPORT  NSString *const DJLOG_KEY_IMEI;

//文件日志的开头
FOUNDATION_EXPORT NSString *const DJLOG_FixCommonMarkKey;

//默认的渠道FOUNDATION_EXPORT  NSString *const DJLOG_KEY_IMEI

FOUNDATION_EXPORT NSString *const DJLOG_DefaultChannelId;


@interface DJLogConstants : NSObject

@end
