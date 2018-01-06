//
//  DJLogConstants.m
//  DJLog
//
//  Created by yang on 16/5/14.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLogConstants.h"



NSString * const DJLOG_Directory = @"DJLOG";
NSString * const DJLOG_UPLOAD_Directory = @"UPLOAD";

NSString * const DJLOG_ZIP_SUFFIX = @".zip";
NSString * const DJLOG_TXT_SUFFIX = @".txt";

NSInteger  const DJLOG_TIME_SECOND= 180.f;
NSString * const DJLOG_VERSION = @"2.2.4";

#if LOG_TEST_ENV

NSString * const DJLOG_URL_FILE = @"http://applog.djtest.cn/ios/uplog/";
NSString * const DJLOG_URL_PStr = @"http://applog.djtest.cn/ios/rt";

#else

NSString * const DJLOG_URL_FILE = @"https://applog.daojia.com/ios/uplog/";
NSString * const DJLOG_URL_PStr = @"https://applog.daojia.com/ios/rt";

#endif


NSString * const DJLOG_SDKVER = @"sdkVer";
NSString * const DJLOG_APPID = @"appId";
NSString * const DJLOG_UPLOADTIME = @"uploadTime";


NSString * const DJLOG_ZIPFILE = @"zipFile";
NSString * const DJLOG_PSTR = @"pstr";
NSString * const DJLOG_COMMONSTR = @"commonstr";

NSString * const DJLOG_SEPARATOR = @" \001";

NSString * const DJLOG_NODATA = @"-";




NSString *const DJLOG_KEY_IMEI = @"DJLogSaveUdidAsImei";

NSString *const DJLOG_FixCommonMarkKey = @"58DAOJIA_APP_LOGCOLLECTOR_SDK_COMMONLOGINFO_START_SIGN";

NSString *const DJLOG_DefaultChannelId = @"AppStore";




@implementation DJLogConstants

@end
