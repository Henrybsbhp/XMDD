//
//  BaseOp.h
//  HappyTrain
//
//  Created by jt on 14-10-29.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+AddParams.h"
#import <AFNetworking.h>
#import "XiaoMa.h"

@protocol BaseOpDelegate <NSObject>

@optional

- (RACSignal *)rac_postRequest;
- (RACSignal *)rac_getRequest;
- (NSError *)mapError:(NSError *)error;
- (BOOL)shouldHandleDefaultError;
- (instancetype)parseResponseObject:(id)rspObj;
///模拟接口返回 JSON对象 或 NSError
- (id)returnSimulateResponse;
@end

@interface BaseOp : NSObject<BaseOpDelegate>

@property (nonatomic, weak) AFHTTPRequestOperation *af_operation;

///是否需要token的标志
@property (nonatomic)BOOL isNeedToken;
///对应 method
@property (nonatomic, strong) NSString *req_method;
///对应 id
@property (nonatomic, assign) uint32_t req_id;
@property (nonatomic, assign) uint32_t req_vid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *skey;
@property (nonatomic, strong , readonly) NSString *vkey;
@property (nonatomic, copy) NSString * sign;
///模拟数据回执
@property (nonatomic, assign) BOOL simulateResponse;
///模拟数据回执的延迟
@property (nonatomic, assign) NSTimeInterval simulateResponseDelay;

/// 响应code
@property (nonatomic, assign) NSInteger rsp_statusCode;
/// 响应错误
@property (nonatomic, assign) NSError *rsp_error;
/// 业务code
@property (nonatomic, assign) NSInteger rsp_code;
/// 附加提示语
@property (nonatomic, strong) NSString *rsp_prompt;
/// 是否有新消息
@property (nonatomic, assign) BOOL rsp_hasNewMsg;

@property (nonatomic, weak) RACSignal *rac_curSignal;

- (RACSignal *)rac_invokeWithRPCClient:(AFHTTPRequestOperationManager *)manager params:(id)params security:(BOOL)security;

+ (instancetype)operation;

+ (void)cancelAllCurrentClassOpsInClient:(AFHTTPRequestOperationManager *)client;

+ (NSArray *)allCurrentClassOpsInClient:(AFHTTPRequestOperationManager *)client;


@end
