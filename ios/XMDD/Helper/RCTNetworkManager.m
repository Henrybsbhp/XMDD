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
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <AssetsLibrary/AssetsLibrary.h>

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
    
    NSURL *url = [NSURL URLWithString:localurl];
    [[[self rac_getImageDataWithURL:url] flattenMap:^RACStream *(NSData *data) {
        UploadFileOp *op = [UploadFileOp operation];
        op.req_fileExtType = [localurl pathExtension];
        op.req_fileDataArray = @[data];
        return [op rac_postRequest];
    }] subscribeNext:^(UploadFileOp *op) {
        NSMutableDictionary *rsp = [NSMutableDictionary dictionary];
        [rsp safetySetObject:[op.rsp_urlArray safetyObjectAtIndex:0] forKey:@"url"];
        [rsp safetySetObject:[op.rsp_idArray safetyObjectAtIndex:0] forKey:@"lid"];
        resolver(rsp);
    } error:^(NSError *error) {
        rejecter([NSString stringWithInteger:error.code], error.domain, error);
    }];
}

- (RACSignal *)rac_getImageDataWithURL:(NSURL *)url {
    RACScheduler *scd = [RACScheduler schedulerWithPriority:RACSchedulerPriorityHigh];
    return [RACSignal startEagerlyWithScheduler:scd block:^(id<RACSubscriber> subscriber) {
        
        if ([url.scheme isEqualToString:@"assets-library"]) {
            [self getImageDataForAssetsLibrary:url withSubscriber:subscriber];
        } else {
            [subscriber sendNext:[NSData dataWithContentsOfURL:url]];
            [subscriber sendCompleted];
        }
    }];
}

- (void)getImageDataForAssetsLibrary:(NSURL *)url withSubscriber:(id<RACSubscriber>)subscriber {
    ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        [subscriber sendNext:[NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES]];
        [subscriber sendCompleted];
    } failureBlock:^(NSError *error) {
        [subscriber sendNext:nil];
        [subscriber sendCompleted];
    }];
}

@end