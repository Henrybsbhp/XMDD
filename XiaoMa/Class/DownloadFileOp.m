//
//  DownloadFileOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "DownloadFileOp.h"

@implementation DownloadFileOp

- (RACSignal *)rac_getRequest
{
    RACSubject *subject = [RACSubject subject];
    if (!self.req_url || !self.req_savePath) {
        [subject sendError:[NSError errorWithDomain:@"请求参数错误" code:-1 userInfo:nil]];
    }
    NSString *urlstr = self.req_url ? self.req_url : @"";
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:urlstr]];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    [op setOutputStream:[NSOutputStream outputStreamToFileAtPath:self.req_savePath append:self.req_appendData]];
    
    @weakify(self);
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @strongify(self);
        self.rsp_statusCode = operation.response.statusCode;
        self.rsp_code = 0;
        [subject sendNext:self];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        @strongify(self);
        self.rsp_prompt = error.domain;
        self.rsp_code = error.code;
        self.rsp_statusCode = error.code;
        [subject sendError:[NSError errorWithDomain:error.domain code:error.code userInfo:nil]];
    }];
    
    [gNetworkMgr.mediaClient.operationQueue addOperation:op];
    return subject;
}

@end
