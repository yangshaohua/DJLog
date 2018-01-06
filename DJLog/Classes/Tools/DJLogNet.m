//
//  DJLogNet.m
//  DJLog
//
//  Created by chenyk on 16/5/13.
//  Copyright © 2016年 chenyk. All rights reserved.
//

#import "DJLogNet.h"
#import "DJLogFile.h"
#import "DJLogConstants.h"


@implementation DJLogNet



//+(void)djLogNetPostWithPath:(NSString*)path parmas:(id)params callBack:(DJLogNetBlock)callBack
//{
//    
//    NSDictionary * dic = @{@"sdkVer":@"6.6.6",@"appId":@"1",@"uploadTime":@"123456789"};
//    
//    NSString * filePath = [[DJLogFile djLogUploadDirectory] stringByAppendingPathComponent:@"1.zip"];
//    
//    NSData *myData = [NSData dataWithContentsOfFile:filePath];
//    
//    NSURLRequest *request = [self createRequest:dic withData:myData];
//    
//    
//    NSLog(@"++++++%@", [NSThread currentThread]);
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"============%@", [NSThread currentThread]);
//            
//            NSLog(@"%@",params);
//            callBack(data,response,error);
//        });
//        
//        
//    }];
//    //开始请求
//    [task resume];
//}


+ (void)djlogNetFilePostSdkVer:(NSString *)sdkVer appId:(NSString *)appId zipFilePath:(NSString *)zipFilePath callBack:(DJLogNetBlock)callBack{
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setValue: sdkVer forKey:DJLOG_SDKVER];
    [dic setValue:appId forKey:DJLOG_APPID];
    [dic setValue: [NSNumber numberWithLongLong:(long long)[[NSDate date] timeIntervalSince1970]] forKey: DJLOG_UPLOADTIME];


    
    NSData *fileData = nil;
    if ([zipFilePath hasSuffix:DJLOG_ZIP_SUFFIX]) {
        fileData = [NSData dataWithContentsOfFile:zipFilePath];
    }
    NSURLRequest *request = [self createRequest:dic withData:fileData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callBack(data,response,error);
        });
    }];
    //开始请求
    [task resume];
    
}

+ (void)djlogNetRealTimePostSdkVer:(NSString *)sdkVer appId:(NSString *)appId pstr:(NSString *)pstr commonstr:(NSString *)commonstr callBack:(DJLogNetBlock)callBack
{
    NSURL *url = [NSURL URLWithString:DJLOG_URL_PStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString* newpstr = pstr;
    NSString* newcommonstr = commonstr;
    NSMutableCharacterSet* charset = [NSMutableCharacterSet alphanumericCharacterSet];
    [charset addCharactersInString:@"_"];
    if(pstr&&[pstr length] > 0){
       newpstr =  [pstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
       newpstr = [newpstr stringByAddingPercentEncodingWithAllowedCharacters:charset];
    }
    
    
    if(commonstr&&[commonstr length] > 0){
        newcommonstr =  [commonstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        newcommonstr =  [commonstr stringByReplacingOccurrencesOfString:DJLOG_FixCommonMarkKey withString:@""];
        newcommonstr = [newcommonstr stringByAddingPercentEncodingWithAllowedCharacters:charset];
        
    }
    NSString  * postStr = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%lld&%@=%@&%@=%@",DJLOG_SDKVER,sdkVer,DJLOG_APPID,appId,DJLOG_UPLOADTIME,(long long)[[NSDate date] timeIntervalSince1970],DJLOG_PSTR,newpstr,DJLOG_COMMONSTR,newcommonstr];

    NSData * requestData = [postStr dataUsingEncoding:NSUTF8StringEncoding];
    [request  setHTTPBody:requestData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) { 
            callBack(data,response,error);
    }];
    //开始请求
    [task resume];
}


+(NSURLRequest *)createRequest:(NSDictionary *)postKeys withData:(NSData *)data
{
    //create the URL POST Request to tumblr
    NSURL *URL = [NSURL URLWithString:DJLOG_URL_FILE];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    //Add the header info
    NSString *stringBoundary = @"0xKhTmLbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //create the body
    NSMutableData *postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //add key values from the NSDictionary object
    NSEnumerator *keys = [postKeys keyEnumerator];
    int i;
    for (i = 0; i < [postKeys count]; i++) {
        NSString *tempKey = [keys nextObject];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@",[postKeys objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (data) {
        //add data field and file data
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",DJLOG_ZIPFILE,@"log.zip"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[NSData dataWithData:data]];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //add the body to the post
    [request setHTTPBody:postBody];
    
    return request;
}

@end
