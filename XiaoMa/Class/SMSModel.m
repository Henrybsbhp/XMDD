//
//  SMSManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SMSModel.h"
#import "GetTokenOp.h"
#import "GetBindCZBVcodeOp.h"
#import "GetUnbindBankcardVcodeOp.h"
#import "GetVcodeOp.h"

///短信60秒冷却时间
#define kMaxVcodeInterval        60
/// 手机号码长度（11位）
#define kPhoneNumberLength      11

static NSTimeInterval s_coolingTimeForCZBGasCharge = 0;
static NSTimeInterval s_coolingTimeForUnbindCZB = 0;
static NSTimeInterval s_coolingTimeForBindCZB = 0;
static NSTimeInterval s_coolingTimeForLogin = 0;

@interface SMSModel ()
@property (nonatomic, strong) RACDisposable *timeCountdownDisposable;
@end

@implementation SMSModel

- (instancetype)initWithVcodeType:(HKVcodeType)type
{
    self = [super init];
    if (self) {
        _vcodeType = type;
    }
    return self;
}

//开始获取登录验证码
- (void)startGetLoginVcodeWithPhone:(NSString *)phone
{
    @weakify(self);
    [[[[self rac_getLoginVcodeWithPhone:phone] initially:^{
        @strongify(self);
        self.isGettingVcode = YES;
        self.needUpdateStatus = !self.needUpdateStatus;
    }] finally:^{
        @strongify(self);
        self.isGettingVcode = NO;
        self.needUpdateStatus = !self.needUpdateStatus;
    }] subscribeNext:^(id x) {
        @strongify(self);
        s_coolingTimeForLogin = [[NSDate date] timeIntervalSince1970];
        self.remainTime = kMaxVcodeInterval;
    } error:^(NSError *error) {
        @strongify(self);
        self.errorMessage = error.domain;
    }];
}

- (NSString *)titleForCurrentStatus
{
    if (self.isGettingVcode) {
        return @"正在获取验证码";
    }
    else if (self.remainTime > 0) {
        return [NSString stringWithFormat:@"剩余%d秒", (int)self.remainTime];
    }
    return @"点击获取验证码";
}

- (BOOL)canGetVcode
{
    if (self.isGettingVcode) {
        return NO;
    }
    else if (self.remainTime > 0) {
        return NO;
    }
    else return YES;
}

- (void)timeCountdownIfNeeded
{
    //先关闭上次的倒计时
    [self.timeCountdownDisposable dispose];
    
    NSTimeInterval coolingTime = s_coolingTimeForLogin;
    HKVcodeType type = self.vcodeType;
    if (type == HKVcodeTypeBindCZB) {
        coolingTime = s_coolingTimeForBindCZB;
    }
    else if (type == HKVcodeTypeUnbindCZB) {
        coolingTime = s_coolingTimeForUnbindCZB;
    }
    else if (type == HKVcodeTypeCZBGasCharge) {
        coolingTime = s_coolingTimeForCZBGasCharge;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - coolingTime;
    if (interval < kMaxVcodeInterval) {
        NSTimeInterval count = kMaxVcodeInterval - interval;
        @weakify(self);
        [[[self rac_timeCountDown:count] initially:^{
            @strongify(self);
            self.remainTime = ceil(count);
            self.needUpdateStatus = YES;
        }] subscribeNext:^(id x) {
            @strongify(self);
            self.remainTime = MAX(0, self.remainTime - 1);
            self.needUpdateStatus = self.needUpdateStatus;
        } completed:^{
            @strongify(self);
            self.remainTime = 0;
            self.needUpdateStatus = !self.needUpdateStatus;
        }];
    }
}

#pragma mark - Private
- (RACSignal *)rac_timeCountDown:(NSTimeInterval)time
{
    __block int count = time;
    return [[[[[RACSignal interval:1 onScheduler:[RACScheduler scheduler]]
               startWith:[NSDate date]] map:^id(id value) {
        
        return @(count--);
    }] take:time+1] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)rac_getLoginVcodeWithPhone:(NSString *)phone
{
    //获取本地的token，如果本地没有token，则重新下载新token
    RACSignal *signal = [[self rac_getTokenWithAccount:phone] map:^id(GetTokenOp *rspOp) {
        
        return rspOp.rsp_token;
    }];
    //获取验证码
    signal = [signal flattenMap:^RACStream *(NSString *token) {
        GetVcodeOp *op = [GetVcodeOp new];
        op.req_phone = phone;
        op.req_token = token;
        op.req_type = HKVcodeTypeLogin;
        return [op rac_postRequest];
    }];
    @weakify(self);
    //如果返回token失效错误，则重新获取新token，并重试一遍
    signal = [signal catch:^RACSignal *(NSError *error) {
        if (error.code == 3002) {
            @strongify(self);
            return [[self rac_getTokenWithAccount:phone] flattenMap:^RACStream *(GetTokenOp *tokenOp) {
                GetVcodeOp *op = [GetVcodeOp new];
                op.req_phone = phone;
                op.req_token = tokenOp.rsp_token;
                op.req_type = HKVcodeTypeLogin;
                return [op rac_postRequest];
            }];
        }
        return [RACSignal error:error];
    }];
    //获取短信验证码成功后，更新本地token
    signal = [signal doNext:^(GetVcodeOp *op) {
        [gAppMgr.tokenPool setToken:op.req_token forAccount:op.req_phone ];
    }];
    //切换到主线程接收next
    signal = [signal deliverOn:[RACScheduler mainThreadScheduler]];
    
    return signal;
}

///获取token
- (RACSignal *)rac_getTokenWithAccount:(NSString *)account
{
    GetTokenOp *op = [GetTokenOp new];
    op.req_phone = account;
    return [op rac_postRequest];
}

@end
