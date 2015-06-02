//
//  DownloadOp.m
//  HappyTrain
//
//  Created by jt on 14-11-18.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "DownloadOp.h"
#import <RACAFNetworking.h>

@implementation DownloadOp

- (RACSignal *)rac_getRequest
{
    // http://{host:port}/mservice/fileDownload?uri={}&vcode={}
    
//    NSMutableDictionary *dict = [self addSecurityParamsFrom:nil];
//    
//    NSString *path = [NSString stringWithFormat:@"/fileDownload?uri=%@&vcode=%@",self.req_uri, dict[@"vcode"]];
//    NSString *strURL = [kFileServerBaseURLString append:path];
//    self.rsp_url = strURL;
    if (!self.req_uri) {
        //避免空信号，对应问题7303   FQ
        return [RACSignal empty];
    }
    
    NSURL *reqURL = [NSURL URLWithString:self.req_uri];
    NSURLRequest *req = [NSURLRequest requestWithURL:reqURL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    
    RACSignal *sig = [[[[[gNetworkMgr.mediaClient rac_enqueueHTTPRequestOperation:op] map:^id(RACTuple *tuple) {
        
        self.rsp_data = tuple.second;
        return self;
    }] doNext:^(id x) {
        
        DebugLog(@"Download file success:%@", self.req_uri);
    }] doError:^(NSError *error) {
        
        DebugLog(@"Download file error:%@,%@", self.req_uri, [error description]);
    }] replay];
    
    op.customObject = self;
    self.af_operation = op;
    self.rac_curSignal = sig;
    
    return sig;
}

+ (instancetype)firstDownloadOpInClientForReqURI:(NSString *)req_uri
{
    return [[self allCurrentClassOpsInClient:gNetworkMgr.mediaClient] firstObjectByFilteringOperator:^BOOL(DownloadOp *op) {
        
        return [op.req_uri equalByCaseInsensitive:req_uri];
    }];
}

@end
