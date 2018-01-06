//
//  DJLogCommonData.m
//  DJLog
//
//  Created by shaozhou li on 16/5/16.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLogCommonData.h"
#import "DJLogCommonLib.h"
#import <UIKit/UIKit.h>
#import "DJLogConstants.h"
#import <AdSupport/AdSupport.h>
#import "DJLog.h"

@interface DJLogCommonData()

@end

@implementation DJLogCommonData

#pragma mark - Outer Method

- (NSString *)getFixCommonDataString {
    NSMutableString *fixStr = [NSMutableString new];
    
    [fixStr appendFormat:@"%@",self.fixCommonMark];
    
    [fixStr appendFormat:@"%@app_id=%@", DJLOG_SEPARATOR, self.appid];
    [fixStr appendFormat:@"%@uuid=%@", DJLOG_SEPARATOR, self.uuid];
    [fixStr appendFormat:@"%@app_imei=%@", DJLOG_SEPARATOR, self.imei];
//    [fixStr appendFormat:@"%@app_mac=%@", DJLOG_SEPARATOR, DJLOG_NODATA];
    [fixStr appendFormat:@"%@app_idfa=%@", DJLOG_SEPARATOR, self.idfa];
    [fixStr appendFormat:@"%@app_idfv=%@", DJLOG_SEPARATOR, self.idfv];
    [fixStr appendFormat:@"%@device_id=%@", DJLOG_SEPARATOR, self.deviceId];
    
    [fixStr appendFormat:@"%@app_idfa_real=%@", DJLOG_SEPARATOR, self.idfa_real];

    [fixStr appendFormat:@"%@os=%@", DJLOG_SEPARATOR, self.os];
    [fixStr appendFormat:@"%@os_version=%@", DJLOG_SEPARATOR, self.osv];
    [fixStr appendFormat:@"%@res=%@", DJLOG_SEPARATOR, self.res];

    // client_ip
//    [fixStr appendFormat:@"%@client_ip=%@", DJLOG_SEPARATOR, self.clientip];
    
    [fixStr appendFormat:@"%@app_version=%@", DJLOG_SEPARATOR, self.version];

    // city_id
    [fixStr appendFormat:@"%@city_id_select=%@", DJLOG_SEPARATOR, self.cityID];
    // city_idGPS
    [fixStr appendFormat:@"%@city_id_gps=%@", DJLOG_SEPARATOR, self.cityIdGPS];
    
    
    // user_agent
    [fixStr appendFormat:@"%@user_agent=%@", DJLOG_SEPARATOR, self.userAgent];

    [fixStr appendFormat:@"%@dev_type=%@", DJLOG_SEPARATOR, self.ua];
    
    
    [fixStr appendFormat:@"%@user_id=%@", DJLOG_SEPARATOR, self.userid];
    
    // usergroup
    [fixStr appendFormat:@"%@user_group=%@", DJLOG_SEPARATOR, self.userGroup];
    
    [fixStr appendFormat:@"%@log_sdk_ver=%@", DJLOG_SEPARATOR, self.logsdkver];

    
    [fixStr appendFormat:@"%@app_list=%@", DJLOG_SEPARATOR, DJLOG_NODATA];

    [fixStr appendFormat:@"%@apn=%@", DJLOG_SEPARATOR, self.apn];
    
    [fixStr appendFormat:@"%@channel_id=%@", DJLOG_SEPARATOR, self.channelid];
    
   
    return fixStr;
}

- (NSString *)getStringByEvent:(NSString *)event eventType:(NSString *)eventType attributes:(NSDictionary *)attribute {
    NSMutableString *eventStr = [NSMutableString new];
    [eventStr appendFormat:@"\n"];
    
    // 事件类型
    [eventStr appendFormat:@"event_type=%@", eventType];
    
    // 客户端事件发生时间 10位数字，例如：event_timestamp=1468684809
    [eventStr appendFormat:@"%@event_timestamp=%lld", DJLOG_SEPARATOR, (long long)[[NSDate date] timeIntervalSince1970]];
    
    //事件ID
    [eventStr appendFormat:@"%@event_id=%@",DJLOG_SEPARATOR,event];


    // 经纬度
    [eventStr appendFormat:@"%@lat=%@", DJLOG_SEPARATOR, self.lat];
    [eventStr appendFormat:@"%@lon=%@", DJLOG_SEPARATOR, self.lon];
    
    if (attribute.allKeys > 0) {
        // 附件属性
        [eventStr appendFormat:@"%@extra_parameter=", DJLOG_SEPARATOR];
        for (id key in [attribute allKeys]) {
            NSString * value = [NSString stringWithFormat:@"%@",attribute[key]];
            if ([DJLogCommonLib containSpecialStr:value]) {
                value = [DJLogCommonLib handleSpecialStr:value];
            }
            
            [eventStr appendFormat:@"%@/s_kv%@/s_pair", key, value];
        }
        if ([eventStr hasSuffix:@"#"]) {
             [eventStr deleteCharactersInRange:NSMakeRange(eventStr.length-1, 1)];
        }
        
    }else{
        // 附件属性
        [eventStr appendFormat:@"%@extra_parameter=%@", DJLOG_SEPARATOR, DJLOG_NODATA];
    }

    return eventStr;
}


#pragma mark - Property


- (NSString *)fixCommonMark {
    if (!_fixCommonMark) {
        _fixCommonMark = DJLOG_FixCommonMarkKey;
    }
    return _fixCommonMark;
}

- (NSString *)uuid {
    if (!_uuid) {
        _uuid = [DJLogCommonLib getUUID];
    }
    return _uuid;
}

- (NSString *)imei {
    return DJLOG_NODATA;
}

- (NSString *)userid {
    if (!_userid) {
        _userid = DJLOG_NODATA;
    }
    return _userid;
}

- (NSString *)appid {
    if (!_appid) {
        DJLLog(@"未设置 appid ，请按正确方式使用");
        _appid = DJLOG_NODATA;
    }
    return _appid;
}


- (NSString *)version {
    if (!_version) {
        _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return _version;
}

- (NSString *)channelid {
    if(!_channelid) {
        _channelid = DJLOG_DefaultChannelId;
    }
    return _channelid;
}

- (NSString *)ua {
    if(!_ua) {
        _ua = [DJLogCommonLib getCurrentDeviceModel];
        if (!_ua) {
            _ua = DJLOG_NODATA;
        }
    }
    return _ua;
}

- (NSString *)logsdkver {
    if(!_logsdkver) {
        _logsdkver = DJLOG_VERSION;
    }
    return _logsdkver;
}

- (NSString *)os {
    if(!_os) {
        _os = @"iPhone OS";
    }
    return _os;
}

- (NSString *)osv {
    if(!_osv) {
        _osv = [[UIDevice currentDevice] systemVersion];
    }
    return _osv;
}

- (NSString *)res {
    if(!_res) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat screenScale = [UIScreen mainScreen].scale;
        _res = [NSString stringWithFormat:@"%dx%d", (int)(screenBounds.size.width * screenScale), (int)(screenBounds.size.height * screenScale)];
    }
    return _res;
}

- (NSString *)idfa {
    if(!_idfa) {
       // _idfa = self.imei;
        DJLLog(@"Warning imei = nil");
    }
    return _idfa;
}

- (NSString *)idfv
{
    if (!_idfv) {
        _idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _idfv;
}
- (NSString *)deviceId
{
    if (!_deviceId) {
        
        NSString * key = @"com.daojia.djlog";
        
        NSString * tempString = [DJLogCommonLib fetchKeychinWithKey:key];
        
        if (!tempString) {
            NSString * tempIdfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            [DJLogCommonLib writeKeychainWithKey:key value:tempIdfv];
            tempString = [DJLogCommonLib fetchKeychinWithKey:key];
#if DEBUG
            NSAssert(tempString != nil, @"钥匙串写入和获取失败,请检查项目是否开启钥匙串访问权限");
#endif
            if(!tempString){
                //记录日志
//                [DJLog errorEvent:@"readKeychinFailure" attributes:nil];
            }
        }
        _deviceId = tempString;
        
    }
    return _deviceId;
}
- (NSString *)userAgent {
    if (!_userAgent) {
        _userAgent = DJLOG_NODATA;
    }
    return _userAgent;
}

- (NSString *)cityID {
    if(!_cityID) {
        _cityID = DJLOG_NODATA;
    }
    return _cityID;
}

- (NSString *)cityIdGPS{
    if (!_cityIdGPS) {
        _cityIdGPS = DJLOG_NODATA;
    }
    return _cityIdGPS;
}

- (NSString *)userGroup {
    if (!_userGroup) {
        _userGroup = DJLOG_NODATA;
    }
    return _userGroup;
}

#pragma mark - 可变公共数据

- (NSString *)lat {
    if(!_lat) {
        _lat = DJLOG_NODATA;
    }
    return _lat;
}

- (NSString *)lon {
    if(!_lon) {
        _lon = DJLOG_NODATA;
    }
    return _lon;
}

- (NSString *)apn {
    if(!_apn) {
        _apn = [DJLogCommonLib getConnectionTypeString];
        if (!_apn) {
            _apn = DJLOG_NODATA;
        }
    }
    return _apn;
}

- (NSString *)uploadtime {
    if(!_uploadtime) {
        NSDate *date = [[NSDate alloc] init];
        long long seconds = [date timeIntervalSince1970];
        NSNumber *number = [NSNumber numberWithLongLong:seconds];
        _uploadtime = [number stringValue];
    }
    return _uploadtime;
}

- (NSString *)clientip {
    if(!_clientip) {
        _clientip = [DJLogCommonLib getIPAddress];
        if (!_clientip) {
            _clientip = DJLOG_NODATA;
        }
    }
    return _clientip;
}

- (NSString*)idfa_real{
    if (!_idfa_real) {
        _idfa_real = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return _idfa_real;
}


@end
