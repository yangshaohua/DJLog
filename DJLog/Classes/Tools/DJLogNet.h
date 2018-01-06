//
//  DJLogNet.h
//  DJLog
//
//  Created by chenyk on 16/5/13.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DJLogNetBlock)(id data, NSURLResponse*response, NSError *error);
@interface DJLogNet : NSObject

//+(void)djLogNetPostWithPath:(NSString*)path parmas:(id)params callBack:(DJLogNetBlock)callBack;
//
//+(void)djLogNetPost2WithPath:(NSString*)path parmas:(id)params callBack:(DJLogNetBlock)callBack;



//文件接口
+ (void)djlogNetFilePostSdkVer:(NSString *)sdkVer appId:(NSString *)appId zipFilePath:(NSString *)zipFilePath callBack:(DJLogNetBlock)callBack;


//实时接口
+ (void)djlogNetRealTimePostSdkVer:(NSString*)sdkVer appId:(NSString*)appId pstr:(NSString*)pstr commonstr:(NSString *)commonstr callBack:(DJLogNetBlock)callBack;

@end
