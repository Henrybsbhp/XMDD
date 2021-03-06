//
//  NetworkManager.h
//  XiaoMa
//
//  Created by jt on 15-4-10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "Xmdd.h"

@class BaseOp;

@interface NetworkManager : NSObject

#pragma mark- 全局网络参数
@property (nonatomic, strong) NSString *skey;       //密码
@property (nonatomic, strong) NSString *token;      //会话令牌
@property (nonatomic, strong) NSString * bindingMobile;
@property (nonatomic, strong, readonly) NSString *apiServer;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *baseManager;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *apiManager;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *longtimeManager;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *reactManager;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *mediaClient;
@property (nonatomic, strong, readonly) AFHTTPRequestOperationManager *logClient;

///是否开启模拟数据回执 (Default is NO)
@property (nonatomic, assign) BOOL simulateResponse;
///模拟接口回执的默认延迟 (default is 1s)
@property (nonatomic, assign) NSTimeInterval simulateResponseDelay;

@property (nonatomic, copy) RACSignal *(^catchErrorHandler)(BaseOp *op, NSError *error);

+ (instancetype)sharedManager;

/// 调用错误处理（触发catchErrorHandler）
- (void)handleError:(NSError *)error forOp:(BaseOp *)op;

@end
