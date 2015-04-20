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
    return [[[self rac_getTokenWithAccount:phone] flattenMap:^RACStream *(GetTokenOp *tokenOp) {
        GetVcodeOp *op = [GetVcodeOp new];
        op.req_phone = phone;
        op.req_token = tokenOp.rsp_token;
        op.req_type = type;
        return [op rac_postRequest];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
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
