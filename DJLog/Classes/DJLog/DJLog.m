//
//  DJLog.m
//  DJLog
//
//  Created by chenyk on 16/5/12.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLog.h"
#import "DJLogNet.h"
#import "DJLogZip.h"
#import "DJLogFile.h"
#import "DJLogCommonData.h"
#import <CoreLocation/CoreLocation.h>
#import "DJLogCommonLib.h"

NSString *const DJLogDidUploadNotification = @"DJLogDidUploadNotification";
BOOL DeviceFirstSend  = NO;
BOOL DeviceFirstSending  = NO;
@interface DJLog()

/** 公共数据信息 */
@property (nonatomic, strong) DJLogCommonData *commonInfo;

/** 定时器 */
@property (nonatomic,strong)NSTimer * timer;
@property (nonatomic,strong)NSMutableArray * uploadFileArray;
@property (nonatomic,strong)NSMutableSet * uploadingSet;

/** 文件操作相关 */
/** 当前可写入的文件名称 */
@property (nonatomic, copy) NSString *currentFileName;
/** 串行队列，用于文件操作 */
@property (nonatomic, strong) dispatch_queue_t serialQueue;

@end


@implementation DJLog

static DJLog * sharedLog;

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Init

+ (void)startWithAppkey:(NSString *)appKey userId:(NSString *)userId idfa:(NSString *)idfa {
    [self startWithAppkey:appKey channelId:DJLOG_DefaultChannelId userId:userId idfa:idfa];
}

+ (void)startWithAppkey:(NSString *)appKey channelId:(NSString *)cid userId:(NSString *)userId idfa:(NSString *)idfa {
    [self sharedDJLogWith:appKey channelId:cid userId:userId idfa:idfa];
}

+ (instancetype)sharedDJLog {
    NSAssert(sharedLog, @"请先调用startWithAppkey:::函数初始化组件再使用");
    return sharedLog;
}

+ (instancetype)sharedDJLogWith:(NSString *)appKey channelId:(NSString *)cid userId:(NSString *)userId idfa:(NSString *)idfa {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLog = [[self alloc] initWith:appKey channelId:cid userId:userId idfa:idfa];
        [sharedLog timedExecution:nil];
        [DJLog deviceFirstEventUpload];
    });
    return sharedLog;
}

- (id)initWith:(NSString *)appKey channelId:(NSString *)cid userId:(NSString *)userId idfa:(NSString *)idfa {
    self = [super init];
    if (self) {
        // 初始化公共数据信息
        self.commonInfo.appid = appKey;
        self.commonInfo.channelid = cid;
        self.commonInfo.userid = userId;
        self.commonInfo.idfa = idfa;
        self.commonInfo.userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        // 初始化 timer
        self.timer = [NSTimer scheduledTimerWithTimeInterval:DJLOG_TIME_SECOND
                                                      target:self
                                                    selector:@selector(timedExecution:)
                                                    userInfo:nil
                                                     repeats:YES];
        self.uploadFileArray = [NSMutableArray array];
        self.uploadingSet = [NSMutableSet set];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(willTerminateCallBack:)
                                                   name:UIApplicationWillTerminateNotification
                                                 object:nil];
    }
    
    return self;
}

#pragma mark - Outer Method

+ (void)setAppVersion:(NSString *)appVersion {
    [DJLog sharedDJLog].commonInfo.version = appVersion;
}

+ (void)setLocation:(CLLocation *)location {
    [DJLog setLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
}

+ (void)setLatitude:(double)latitude longitude:(double)longitude {
    [DJLog sharedDJLog].commonInfo.lat = [NSString stringWithFormat:@"%f", latitude];
    [DJLog sharedDJLog].commonInfo.lon = [NSString stringWithFormat:@"%f", longitude];
}

+ (void)setUserId:(NSString *)uid {
    // 如果userid变化，意味着文件公共信息变化，这时需要重新创建文件。
    dispatch_async([DJLog sharedDJLog].serialQueue, ^{
        
        if (![uid isEqualToString:[DJLog sharedDJLog].commonInfo.userid]) {
            [DJLog sharedDJLog].commonInfo.userid = uid;
            [DJLog clickEvent:@"user_id_change" attributes:nil];
            
        }
    });
}

+ (void)setCityId:(NSString *)cityId
{
    if (!sharedLog) {
        return;
    }
    dispatch_async([DJLog sharedDJLog].serialQueue, ^{
        
        if (![cityId isEqualToString: [DJLog sharedDJLog].commonInfo.cityID]) {
            [DJLog sharedDJLog].commonInfo.cityID = cityId;
            
            static BOOL isfirst = true;
            if(!isfirst){
                [DJLog clickEvent:@"city_id_select_change" attributes:nil];
            }
            isfirst = NO;
            
        }
    });
}

+ (void)setCityIdGPS:(NSString *)cityIdGPS
{
    if (!sharedLog) {
        return;
    }
    dispatch_async([DJLog sharedDJLog].serialQueue, ^{
        
        if (![cityIdGPS isEqualToString: [DJLog sharedDJLog].commonInfo.cityIdGPS]) {
            [DJLog sharedDJLog].commonInfo.cityIdGPS = cityIdGPS;
            [[DJLog sharedDJLog] timeTicFilekAction];
           
            NSString* lastgpsid = [[NSUserDefaults standardUserDefaults] objectForKey:@"DJLog_LastGpsId"];
            if(lastgpsid == nil || ![lastgpsid isEqualToString:cityIdGPS] ){
                NSString* newgpsid = cityIdGPS;
                if(![newgpsid isKindOfClass:[NSString class]]){
                    newgpsid = @"";
                }
                [DJLog clickEvent:@"city_id_gps_change" attributes:nil];
                [[NSUserDefaults standardUserDefaults] setObject:newgpsid forKey:@"DJLog_LastGpsId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
               // [[DJLog sharedDJLog] timedExecution:nil];
            }
            
        }
    });
}
+ (void)setUserGroup:(NSString *)userGroup
{
    dispatch_async([DJLog sharedDJLog].serialQueue, ^{
        if (![userGroup isEqualToString:[DJLog sharedDJLog].commonInfo.userGroup]) {
            [DJLog sharedDJLog].commonInfo.userGroup = userGroup;
            [[DJLog sharedDJLog] timeTicFilekAction];
        }
    });
}

#pragma mark - Private Logic
//判断是否要触发强制上传
+(BOOL)isTrigerUpload:(NSString*)eventid{
    if(![eventid isKindOfClass:[NSString class]]){
        return NO;
    }
    if([eventid isEqualToString:@"city_id_gps_change"]){
        return YES;
    }else if([eventid isEqualToString:@"city_id_select_change"]){
        return YES;
    }else if([eventid isEqualToString:@"user_id_change"]){
        return YES;
    }
    return NO;
}
- (void)createNewFile {
    // 1、生成新文件名字
    self.currentFileName = nil;
    NSString *fileName = [DJLogFile newLogFileName];
    self.currentFileName = fileName;
    // 2、获取写文件需要的信息
    NSString *content = [self.commonInfo getFixCommonDataString];
    NSString *filePath = [[DJLogFile djLogDirectory] stringByAppendingPathComponent:fileName];
    
    // 3、 写文件操作
    BOOL createSuccess = [DJLogFile createFileAtPath:filePath content:content];
    if (!createSuccess) {
        DJLLog(@"%@文件创建失败", fileName);
    }
}

- (void)moveFile:(NSString *)fileName {
    NSString *fromPath = [[DJLogFile djLogDirectory] stringByAppendingPathComponent:fileName];
    NSString *toPath = [[DJLogFile djLogUploadDirectory] stringByAppendingPathComponent:fileName];
    [DJLogFile moveFile:fromPath toPath:toPath];
}

- (BOOL)writeDataToCurrentFilecontent:(NSString *)content {
    NSString *filePath = [[DJLogFile djLogDirectory] stringByAppendingPathComponent:self.currentFileName];
    BOOL writeSuccess = [DJLogFile writeDataToFileAtPath:filePath content:content];
    return writeSuccess;
}

- (void)moveAllFile {
    // 当前文件名清空
    self.currentFileName = nil;
    // 剪切文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *basePath = [DJLogFile djLogDirectory];
    NSDirectoryEnumerator *myDirectoryEnumerator = [fileManager enumeratorAtPath:basePath];  //basePath 为文件夹的路径
    NSString *file;
    while((file = [myDirectoryEnumerator nextObject]))     //遍历当前目录
    {
        if([[file pathExtension] isEqualToString:@"txt"])  //取得后缀名为.xml的文件名
        {
            [self moveFile:file];
        }
    }
}

/** 定时器触发时的文件操作 */
- (void)timeTicFilekAction {
    @synchronized (self) {
        // 1、如果有文件，move 到 upload 目录
        [self moveAllFile];
        // 2.压缩upload下的文件
        [DJLogZip zipLogFile];
    }
}

- (void)timedExecution:(id)userinfo {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 文件操作,耗时操作放入子线程
        [self timeTicFilekAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray * uploadFileArray = [DJLogFile allZipFileName];
            
            for (NSString * fileName in uploadFileArray) {
                if (![self.uploadFileArray containsObject:fileName]) {
                    [self.uploadFileArray addObject:fileName];
                }
            }
            if (0 == self.uploadFileArray.count) {
                [[NSNotificationCenter defaultCenter]postNotificationName:DJLogDidUploadNotification object:self];
            }
            [self uploadlog];

        });
    });
}

- (void)uploadlog
{
    if (self.uploadFileArray.count > 0) {
        
        if (![self.uploadingSet containsObject:[self.uploadFileArray firstObject]]) {
            [self.uploadingSet addObject:[self.uploadFileArray firstObject]];
            [self uploadLogWithFileName:[self.uploadFileArray firstObject]];
        }
    }
}
- (void)uploadLogWithFileName:(NSString*) fileName
{

    NSString * filePath = [[DJLogFile djLogUploadDirectory]stringByAppendingPathComponent:fileName];
    [DJLogNet djlogNetFilePostSdkVer:DJLOG_VERSION appId:sharedLog.commonInfo.appid zipFilePath:filePath callBack:^(id data, NSURLResponse *response, NSError *error) {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (self.uploadFileArray.count>0) {
            [self.uploadFileArray removeObjectAtIndex:0];
        }
        
        if (self.uploadFileArray.count == 0 && !error) {
            [[NSNotificationCenter defaultCenter]postNotificationName:DJLogDidUploadNotification object:self];
        }
        
        [self.uploadingSet removeObject:fileName];
        
        
        if ([result isEqualToString:@"1"]) {
       
            [DJLogFile deleteFileAtPath:filePath];
        }
        [self uploadlog];
        NSLog(@"日志上传状态--- %@",result);
    }];
}

//实时上传接口
- (void)uploadRealTimeLogWithPstr:(NSString*)pstr
{
    if (pstr) {
        __block NSString* blk_pstr = pstr;
        NSString* common_str = self.commonInfo.getFixCommonDataString;
        [DJLogNet djlogNetRealTimePostSdkVer:DJLOG_VERSION appId:sharedLog.commonInfo.appid pstr:pstr commonstr:common_str callBack:^(id data, NSURLResponse *response, NSError *error) {
           
                if([blk_pstr rangeOfString:@"device_first_open"].length > 0){
                     if(error!=nil){
                         DeviceFirstSending = NO;
                     }else{
                         DeviceFirstSending = NO;
                         DeviceFirstSend = YES;
                     }
                }
        }];
    }
}

#pragma mark - Event

+ (void)event:(NSString *)eventId {
    dispatch_async([DJLog sharedDJLog].serialQueue, ^{
        [self event:eventId attributes:nil];
    });
}

+ (void)nativeLoadEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    [self writeEvent:eventId eventType:@"native_load" attributes:attributes];
}

+ (void)clickEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    [self writeEvent:eventId eventType:@"click" attributes:attributes];
}

+ (void)htmlLoadEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSString * newEventId = [DJLogCommonLib handleSpecialStr:eventId];
    [self writeEvent:newEventId eventType:@"h5_load" attributes:attributes];
}

+ (void)errorEvent:(NSString *)errorContent attributes:(NSDictionary *)attributes {

    [self writeEvent:errorContent eventType:@"error" attributes:attributes];

}
+ (void)systemEvent:(NSString *)errorContent attributes:(NSDictionary *)attributes{
    [self writeEvent:errorContent eventType:@"system" attributes:attributes];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes {
    [self writeEvent:eventId eventType:@"click" attributes:attributes];
}

+ (void)writeEvent:(NSString *)eventId eventType:(NSString *)eventType attributes:(NSDictionary *)attributes {
    DJLog *djLog = [DJLog sharedDJLog];
    if (!djLog) {
        DJLLog(@"DJLLog组建未初始化，请调用startWithAppkey后再进行事件调用。");
        return;
    }

    if ([eventId isKindOfClass:[NSString class]]) {
        dispatch_async([DJLog sharedDJLog].serialQueue, ^{
            
            // 如果当前没有可写入文件，则先创建文件
            if (!djLog.currentFileName) {
                [djLog createNewFile];
            }
            // 去除特殊字符
            NSMutableString *cleanEventId = [NSMutableString stringWithString:eventId];
            [cleanEventId replaceOccurrencesOfString:@"\n" withString:@"^^" options:NSLiteralSearch range:NSMakeRange(0, cleanEventId.length)];
            [cleanEventId replaceOccurrencesOfString:@"#" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, cleanEventId.length)];
//            [cleanEventId replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, cleanEventId.length)];
            // 写入事件
          
            NSString *eventContent = [djLog.commonInfo getStringByEvent:cleanEventId eventType:eventType attributes:attributes];
            BOOL writeSuccess = [djLog writeDataToCurrentFilecontent:eventContent];
            if (!writeSuccess) {
                DJLLog(@"eventid:%@ 事件写入失败", eventId);
            }else{
                if([DJLog isTrigerUpload:cleanEventId]){
                    [sharedLog timedExecution:nil];
                }else{
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    [sharedLog timedExecution:nil];
                });
                }
            }
        });
       
        
    }
}

+ (void)realTimeEvent:(NSString *)eventId attributes:(NSDictionary *)attributes {
    NSString *eventContent = [[DJLog sharedDJLog].commonInfo getStringByEvent:eventId eventType:@"click" attributes:attributes];

    [[DJLog sharedDJLog] uploadRealTimeLogWithPstr:eventContent];
}

#pragma mark - 

- (void)willTerminateCallBack:(NSNotification *)notification {
    DJLLog(@"App willTerminate");
    // 处理文件
    [self moveAllFile];
}

#pragma mark - Property 

- (DJLogCommonData *)commonInfo {
    if (!_commonInfo) {
        _commonInfo = [DJLogCommonData new];
    }
    return _commonInfo;
}

- (dispatch_queue_t)serialQueue {
    if (!_serialQueue) {
        _serialQueue = dispatch_queue_create("DJLogfileOperationQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _serialQueue;
}
+ (NSString *)getDeviceId{
    NSString * device_id = [DJLog sharedDJLog].commonInfo.deviceId;
    if (device_id) {
        return device_id;
    }
    return @"-";
}

+ (void)forceUpload{
    [DJLog deviceFirstEventUpload];
    [[DJLog sharedDJLog] timedExecution:nil];
}

+ (void)deviceFirstEventUpload{
    if(!DeviceFirstSend&&!DeviceFirstSending){
        DeviceFirstSending = YES;
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [DJLog realTimeEvent:@"device_first_open" attributes:nil];
         });
    }
}
@end
