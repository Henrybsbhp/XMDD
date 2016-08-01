//
//  UploadLogOp.m
//  XiaoMa
//
//  Created by jt on 15-5-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UploadLogOp.h"
#import "Xmdd.h"
#import <RACAFNetworking.h>

@interface UploadLogOp()

@property (nonatomic, strong) NSArray *fileArray;
@property (nonatomic, copy) NSData *(^fileDataBlock)(id file);

@end

@implementation UploadLogOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/fileupload";
    NSString *url = LogUploadUrl;
    
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
        NSMutableURLRequest *req = [gNetworkMgr.logClient.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            
            for (NSData *data in dataArray) {
                [formData appendPartWithFileData:data name:self.req_fileType
                                        fileName:self.req_fileName mimeType:@"application/octet-stream"];
            }
        } error:&error];
        if (error) {
            DebugLog(@"%@ Request = %@", kErrPrefix, url);
            return [RACSignal error:error];
        }
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
        return [gNetworkMgr.logClient rac_enqueueHTTPRequestOperation:op];
    }];
    
    signal = [[[signal map:^id(RACTuple *tuple) {
        NSData *data = tuple.second;
        NSDictionary *dict;
        if (data) {
            dict = [data jsonObject];
            self.rsp_urlArray = dict[@"url"];
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

@end
