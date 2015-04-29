//
//  HKSMSModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKSMSModel.h"
#import "GetTokenOp.h"


#define kMaxVcodeInterval        60       //短信60秒冷却时间

@implementation HKSMSModel
///获取短信验证码 如果获取短信验证码接口返回成功，每隔1秒发送剩余冷却时间(sendNext:NSNumber*:剩余冷却时间)
- (RACSignal *)rac_getVcodeWithType:(NSInteger)type phone:(NSString *)phone
{
    RACSignal *signal;
    //获取本地的token，如果本地没有token，则重新下载新token
    NSString *token = gNetworkMgr.token;
    @weakify(self);
    if (token.length == 0) {
        signal = [[self rac_getTokenWithAccount:phone] map:^id(GetTokenOp *rspOp) {
            return rspOp.rsp_token;
        }];
    } else {
        signal = [RACSignal return:token];
    }
    //获取验证码
    signal = [signal flattenMap:^RACStream *(NSString *token) {
        GetVcodeOp *op = [GetVcodeOp new];
        op.req_phone = phone;
        op.req_token = token;
        op.req_type = type;
        return [op rac_postRequest];
    }];
    //如果返回token失效错误，则重新获取新token，并重试一遍
    signal = [signal catch:^RACSignal *(NSError *error) {
        if (error.code == 3002) {
            @strongify(self);
            return [[self rac_getTokenWithAccount:phone] flattenMap:^RACStream *(GetTokenOp *tokenOp) {
                GetVcodeOp *op = [GetVcodeOp new];
                op.req_phone = phone;
                op.req_token = tokenOp.rsp_token;
                op.req_type = type;
                return [op rac_postRequest];
            }];
        }
        return [RACSignal error:error];
    }];
    //获取短信验证码成功后，更新本地token
    signal = [[signal doNext:^(GetVcodeOp *rspOp) {
        gNetworkMgr.token = rspOp.req_token;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
    
    return signal;
}


- (RACSignal *)rac_handleVcodeButtonClick:(UIButton *)btn withVcodeType:(NSInteger)type phone:(NSString *)phone
{
    NSString *originTitle = [btn titleForState:UIControlStateNormal];
    RACSubject *subject = [RACSubject subject];
    [[[[self rac_getVcodeWithType:type phone:phone] initially:^{
        [btn setTitle:@"正在获取..." forState:UIControlStateDisabled];
        btn.enabled = NO;
    }] flattenMap:^RACStream *(id value) {
        [subject sendNext:value];
        [subject sendCompleted];
        return [self rac_timeCountDown:kMaxVcodeInterval];
    }] subscribeNext:^(id x) {
        NSString *title = [NSString stringWithFormat:@"%d秒", [x intValue]];
        [btn setTitle:title forState:UIControlStateDisabled];
    } error:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        [btn setTitle:originTitle forState:UIControlStateNormal];
        btn.enabled = YES;
    }];
    return subject;
}

- (RACSignal *)rac_timeCountDown:(NSTimeInterval)time
{
    __block int count = time;
    return [[[[[RACSignal interval:1 onScheduler:[RACScheduler scheduler]]
              startWith:[NSDate date]] map:^id(id value) {
        
        return @(count--);
    }] take:time+1] deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark - Private
///获取token
- (RACSignal *)rac_getTokenWithAccount:(NSString *)account
{
    GetTokenOp *op = [GetTokenOp new];
    op.req_phone = account;
    return [op rac_postRequest];
}

@end
