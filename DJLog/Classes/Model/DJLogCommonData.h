//
//  DJLogCommonData.h
//  DJLog
//
//  Created by shaozhou li on 16/5/16.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DJLogCommonData : NSObject

/** 公共数据标记 */
@property (nonatomic, copy) NSString *fixCommonMark;

/** 每次启动客户端生成的uuid,唯一标识一条 */
@property (nonatomic, copy) NSString *uuid;

/** 移动设备唯一编号 */
@property (nonatomic, copy) NSString *imei;

/** 客户ID */
@property (nonatomic, copy) NSString *userid;

/** 产品id 家政用户端 1，家政商家端 2，速运用户端 3，速运商家端 4，美甲商家端 5，保姆商家端 6，经纪人商家端 7 */
@property (nonatomic, copy) NSString *appid;

/** 客户端版本 v1.2.1 */
@property (nonatomic, copy) NSString *version;

/** 渠道id */
@property (nonatomic, copy) NSString *channelid;

/** 移动设备型号 iPhone4 */
@property (nonatomic, copy) NSString *ua;

/** 日志版本 1.0 */
@property (nonatomic, copy) NSString *logsdkver;

/** 移动设备操作系统 Android，iOS */
@property (nonatomic, copy) NSString *os;

/** 移动设备操作系统版本 v4.0.3 */
@property (nonatomic, copy) NSString *osv;

/** 分辨率 471.235 */
@property (nonatomic, copy) NSString *res;

/** ?暂存放imei信息 */
@property (nonatomic, copy) NSString *idfa;

/** userAgent信息 */
@property (nonatomic, copy) NSString *userAgent;

/** cityID信息,记录所在城市的信息 选择的城市*/
@property (nonatomic, copy) NSString *cityID;

/** cityID信息,记录所在城市的信息 定位的城市 */
@property (nonatomic,copy)NSString * cityIdGPS;

/** 用户分组 从配置中心读取的用户所属组	例如：usergroup=A1 */
@property (nonatomic, copy) NSString *userGroup;

#pragma mark - 可变公共数据

/** 经度 */
@property (nonatomic, copy) NSString *lat;

/** 纬度 */
@property (nonatomic, copy) NSString *lon;

/** 网络接入方式 wifi,cmnet */
@property (nonatomic, copy) NSString *apn;

/** 上传的时间  */
@property (nonatomic, copy) NSString *uploadtime;

/** 客户端IP地址 */
@property (nonatomic, copy) NSString *clientip;


@property (nonatomic,strong)NSString * idfv;

@property (nonatomic,strong)NSString * deviceId;

@property (nonatomic,strong)NSString * idfa_real;
/** 获取写入文件的固定公共数据 */
- (NSString *)getFixCommonDataString;

/** 获取写入的事件信息 */
- (NSString *)getStringByEvent:(NSString *)event eventType:(NSString *)eventType attributes:(NSDictionary *)attribute;

@end
