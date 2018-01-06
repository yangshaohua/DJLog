//
//  DJLogCommonLib.m
//  DJLog
//
//  Created by shaozhou li on 16/5/16.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLogCommonLib.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <Security/Security.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "sys/utsname.h"


typedef enum:NSInteger
{
    CLYConnectionNone,
    CLYConnectionWiFi,
    CLYConnectionCellNetwork,
    CLYConnectionCellNetwork2G,
    CLYConnectionCellNetwork3G,
    CLYConnectionCellNetworkLTE
} CLYConnectionType;

@implementation DJLogKeyChain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end

@implementation DJLogCommonLib

/**
 *  随机生成一个UUID，全球唯一标示
 *
 *  @return uuid
 */
+ (NSString *)getUUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return uuidString;
}

/**
 *  获取IP地址
 *
 *  @return IP
 */
+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString
                               stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)
                                                              ->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)getConnectionTypeString {
    NSString *conType = @"";
    NSUInteger conTypeInteger = [DJLogCommonLib connectionType];
    switch (conTypeInteger) {
        case CLYConnectionNone:
            conType = @"None";
            break;
        case CLYConnectionWiFi:
            conType = @"Wifi";
            break;
        case CLYConnectionCellNetwork:
            conType = @"CellNetwork";
            break;
        case CLYConnectionCellNetwork2G:
            conType = @"CellNetwork2G";
            break;
        case CLYConnectionCellNetwork3G:
            conType = @"CellNetwork3G";
            break;
        case CLYConnectionCellNetworkLTE:
            conType = @"CellNetworkLTE";
            break;
        default:
            break;
    }
    
    return conType;
}

//获得设备型号
+ (NSString *)getCurrentDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPod touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,7"]) return @"iPad mini 3";
    if ([platform isEqualToString:@"iPad4,8"]) return @"iPad mini 3";
    if ([platform isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    
    if ([platform isEqualToString:@"iPad5,1"]) return @"iPad mini 4";
    if ([platform isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPad Air 2";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
}


#pragma mark - Private

/** 从keychain获取内容 */
+ (NSString *)fetchKeychinWithKey:(NSString *)key {
    NSString *value = [DJLogKeyChain load: key];
    if (!value) {
        NSLog(@"----------------------从钥匙串获取%@失败",key);
    }
    return value;
}

/** 写入Keychain */
+ (void)writeKeychainWithKey:(NSString *)key
                       value:(NSString *)value {
    [DJLogKeyChain save:key data:value];
    
}

/** 获取网络状态 */
+ (NSUInteger)connectionType
{
    CLYConnectionType connType = CLYConnectionNone;
    
    @try
    {
        struct ifaddrs *interfaces, *i;
        
        if (!getifaddrs(&interfaces))
        {
            i = interfaces;
            
            while(i != NULL)
            {
                if(i->ifa_addr->sa_family == AF_INET)
                {
                    if([[NSString stringWithUTF8String:i->ifa_name] isEqualToString:@"pdp_ip0"])
                    {
                        connType = CLYConnectionCellNetwork;
                        
#if TARGET_OS_IOS
                        
                        if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0)
                        {
                            CTTelephonyNetworkInfo *tni = CTTelephonyNetworkInfo.new;
                            
                            if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
                            {
                                connType = CLYConnectionCellNetwork2G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge])
                            {
                                connType = CLYConnectionCellNetwork2G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x])
                            {
                                connType = CLYConnectionCellNetwork2G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD])
                            {
                                connType = CLYConnectionCellNetwork3G;
                            }
                            else if ([tni.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE])
                            {
                                connType = CLYConnectionCellNetworkLTE;
                            }
                        }
#endif
                    }
                    else if([[NSString stringWithUTF8String:i->ifa_name] isEqualToString:@"en0"])
                    {
                        connType = CLYConnectionWiFi;
                        break;
                    }
                }
                
                i = i->ifa_next;
            }
        }
        
        freeifaddrs(interfaces);
    }
    @catch (NSException *exception)
    {
        
    }
    
    return connType;
}


+ (NSString*)handleSpecialStr:(NSString*)str{
    
    NSData *nsdata = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    base64Encoded=[base64Encoded stringByReplacingOccurrencesOfString:@"="withString:@""];
    NSString * newStr =[NSString stringWithFormat:@"Base64_%@",base64Encoded];
    return newStr;
}
+ (BOOL)containSpecialStr:(NSString *)str{
    if([str rangeOfString:@"="].location !=NSNotFound){
        return YES;
    }else if([str rangeOfString:@"#"].location !=NSNotFound){
        return YES;
    }else if([str rangeOfString:@"&"].location !=NSNotFound){
        return YES;
    }else if([str rangeOfString:@","].location !=NSNotFound){
        return YES;
    }else if([str rangeOfString:@"\n"].location !=NSNotFound){
        return YES;
    }else if([str rangeOfString:@"\r"].location !=NSNotFound){
        return YES;
    }
    return NO;
}
@end
