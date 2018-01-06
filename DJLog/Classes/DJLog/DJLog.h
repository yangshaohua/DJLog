//
//  DJLog.h
//  DJLog
//
//  Created by chenyk on 16/5/12.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DJLogConstants.h"

@class CLLocation;
extern NSString *const DJLogDidUploadNotification;
@interface DJLog : NSObject

/** 初始化到家统计模块
 @param appKey appKey.
 @param userId 用户id.
 @param idfa 唯一标识.
 @return void
 */
+ (void)startWithAppkey:(NSString *)appKey userId:(NSString *)userId idfa:(NSString *)idfa;

/** 初始化统计模块
 @param appKey
 @param userId 用户id.
 @param idfa 唯一标识.
 @param channelId 渠道名称,为nil或@""时, 默认为@"App Store"渠道
 @return void
 */
+ (void)startWithAppkey:(NSString *)appKey channelId:(NSString *)cid userId:(NSString *)userId idfa:(NSString *)idfa;


/**
 *  设置app版本号。默认提取的是(CFBundleShortVersionString)，如需和App Store版本一致,请调用此方法。
 *
 *  @param appVersion 版本号
 */
+ (void)setAppVersion:(NSString *)appVersion;

/** 设置经纬度信息
 @param latitude 纬度.
 @param longitude 经度.
 @return void
 */
+ (void)setLatitude:(double)latitude longitude:(double)longitude;

/** 设置经纬度信息
 @param location CLLocation 经纬度信息
 @return void
 */
+ (void)setLocation:(CLLocation *)location;

/** 设置用户id信息
 @param uid 用户 id.
 @return void
 */
+ (void)setUserId:(NSString *)uid;


/**
 *  设置城市ID
 *
 *  @param cityId 城市ID //手动选择的城市
 */
+ (void)setCityId:(NSString *)cityId;

/**
 *  设置城市ID
 *
 *  @param cityId 城市ID //定位的城市
 */
+ (void)setCityIdGPS:(NSString *)cityIdGPS;



/**
 *  设置 用户组
 *
 *  @param userGroup 用户组
 */
+ (void)setUserGroup:(NSString*)userGroup;

#pragma mark - Event

/**
 *  自定义事件，数量统计 默认为点击事件
 *
 *  @param eventId 事件 id
 */
+ (void)event:(NSString *)eventId DJLogDeprecated("请使用 clickEvent:(NSString *)eventId attributes:(NSDictionary *)attributes");

/**
 *  页面加载事件统计
 *
 *  @param eventId    事件 id
 *  @param attributes 事件参数仅支持value值是字符串，
 */
+ (void)nativeLoadEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 *  点击事件统计
 *
 *  @param eventId    事件 id
 *  @param attributes 事件参数仅支持value值是字符串，
 */
+ (void)clickEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 *  h5页面加载事件统计
 *
 *  @param eventId    url字符串不要特殊处理sdk会自动处理
 *  @param attributes 事件参数仅支持value值是字符串，
 */
+ (void)htmlLoadEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;

/**
 *  错误或异常事件统计，具体错误信息写入errorContent中
 *
 *  @param errorContent    错误或异常信息内容
 *  @param attributes 事件参数仅支持value值是字符串，
 */
+ (void)errorEvent:(NSString *)errorContent attributes:(NSDictionary *)attributes;

/**
 *  系统日志，非业务埋点，具体错误信息写入systemEvent中
 *
 *  @param errorContent    错误或异常信息内容
 *  @param attributes 事件参数数据
 */
+ (void)systemEvent:(NSString *)errorContent attributes:(NSDictionary *)attributes;

/**
 *   自定义事件，数量统计。默认为点击事件。
 *
 *  @param eventId    事件 id
 *  @param attributes 事件参数仅支持value值是字符串，
 */
+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes DJLogDeprecated("请使用 clickEvent:(NSString *)eventId attributes:(NSDictionary *)attributes");

/**
 *  实时上传事件
 *
 *  @param eventId    事件 id
 *  @param attributes 事件参数数据
 */
+ (void)realTimeEvent:(NSString *)eventId attributes:(NSDictionary *)attributes;




+ (NSString*)getDeviceId;
/**
 *  强制上传日志
 *
 */
+ (void)forceUpload;

/**
 * 来网检测device_first_open是否上传
 *
 */
+ (void)deviceFirstEventUpload;


@end
