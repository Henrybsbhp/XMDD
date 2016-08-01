//
//  UploadFileOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UploadFileOp.h"
#import "Xmdd.h"
#import <RACAFNetworking.h>
#import "NSString+MD5.h"

@interface UploadFileOp ()
@property (nonatomic, strong) NSArray *fileArray;
@property (nonatomic, copy) NSData *(^fileDataBlock)(id file);
@property (nonatomic, copy) void (^progressBlock)(NSUInteger , long long , long long);
@end
@implementation UploadFileOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/fileupload";
    [self increaseRequistIDs];
    NSString *token = self.token ? self.token : @"";
    NSString *srcsig = [NSString stringWithFormat:@"id=%u&token=%@&type=%d", self.req_id, token, (int)self.req_fileType];
    NSString *sig = [srcsig md5];
    NSDictionary *params = @{@"id": @(self.req_id),
                             @"token": token,
                             @"type": @(self.req_fileType),
                             @"sign": sig};
    
    NSString *url;
    if (!self.req_uploadUrl) {
        NSString * serverStr = (!gAppMgr.isSwitchToFormalSurrounding ) ? ApiBaseUrl : ApiFormalUrl;
        url = [serverStr append:self.req_method];
    }
    else {
        url = self.req_uploadUrl;
    }
    

    RACSignal *signal;
    @weakify(self);
    if (self.req_fileDataArray) {
        signal = [RACSignal return:self.req_fileDataArray];
    }
    else if (self.fileArray) {
        RACScheduler *scd  =[RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
        signal = [RACSignal startEagerlyWithScheduler:scd block:^(id<RACSubscriber> subscriber) {
            @strongify(self);
            NSArray *dataArray = [self.fileArray arrayByMappingOperator:self.fileDataBlock];
            self.req_fileDataArray = dataArray;
            [subscriber sendNext:dataArray];
            [subscriber sendCompleted];
        }];
    }
    
    signal = [signal flattenMap:^RACStream *(NSArray *dataArray) {
        NSError *error;
        NSMutableURLRequest *req = [gNetworkMgr.mediaClient.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

            for (NSData *data in dataArray) {
                [formData appendPartWithFileData:data name:self.req_fileExtType
                                        fileName:@"fileType" mimeType:@"application/octet-stream"];
            }
        } error:&error];
        if (error) {
            DebugLog(@"%@ Request = %@", kErrPrefix, url);
            return [RACSignal error:error];
        }
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        [op setUploadProgressBlock:self.progressBlock];
        return [gNetworkMgr.mediaClient rac_enqueueHTTPRequestOperation:op];
    }];
    
    signal = [signal catch:^RACSignal *(NSError *error) {
        
        NSError *err = [NSError errorWithDomain:kDefErrorPormpt code:error.code userInfo:error.userInfo];
        return [RACSignal error:err];
    }];
    
    signal = [[[signal map:^id(RACTuple *tuple) {
        NSData *data = tuple.second;
        NSDictionary *dict;
        if (data) {
            dict = [data jsonObject];
            self.rsp_urlArray = dict[@"url"];
            self.rsp_idArray = dict[@"lid"];
        }
        DebugLog(@"%@ Upload file success:%@ \ndata={%@}", kRspPrefix, url, dict);
        return self;
    }] doError:^(NSError *error) {
        
        DebugLog(@"%@ Upload file error:%@,%@", kErrPrefix, url, error);
    }] replay];
    
    return signal;
}

- (void)setFileArray:(NSArray *)files withGetDataBlock:(NSData*(^)(id))block
{
    _fileArray = files;
    _fileDataBlock = block;
}

- (void)setProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block
{
    self.progressBlock = block;
}

@end
