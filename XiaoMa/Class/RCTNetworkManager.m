//
//  RCTNetworkManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTNetworkManager.h"
#import "ReactNativeOp.h"
#import "UploadFileOp.h"

@implementation RCTNetworkManager

RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(postApi:(NSDictionary *)args
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter) {
    ReactNativeOp *op = [ReactNativeOp operation];
    op.req_method = args[@"method"];
    [[[op rac_invokeWithRPCClient:gNetworkMgr.apiManager params:args[@"params"] security:[args[@"security"] boolValue]] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSDictionary *rsp) {
        resolver(rsp);
    } error:^(NSError *error) {
        rejecter([NSString stringWithInteger:error.code], error.domain, error);
    }];
}


RCT_EXPORT_METHOD(uploadImage:(NSString *)localurl
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter) {
    UploadFileOp *op = [UploadFileOp operation];
    op.req_fileExtType = [localurl pathExtension];
    op.req_fileDataArray = @[[NSData dataWithContentsOfURL:[NSURL URLWithString:localurl]]];
    [[op rac_postRequest] subscribeNext:^(UploadFileOp *op) {
        NSMutableDictionary *rsp = [NSMutableDictionary dictionary];
        [rsp safetySetObject:[op.rsp_urlArray safetyObjectAtIndex:0] forKey:@"url"];
        [rsp safetySetObject:[op.rsp_idArray safetyObjectAtIndex:0] forKey:@"lid"];
        resolver(rsp);
    } error:^(NSError *error) {
        rejecter([NSString stringWithInteger:error.code], error.domain, error);
    }];
}

@end
