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
    signal = [[self rac_getTokenWithAccount:phone] map:^id(GetTokenOp *rspOp) {
        
        return rspOp.rsp_token;
    }];
    //获取验证码
    signal = [signal flattenMap:^RACStream *(NSString *token) {
        GetVcodeOp *op = [GetVcodeOp new];
        op.req_phone = phone;
        op.req_token = token;
        op.req_type = type;
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
                op.req_type = type;
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


- (RACSignal *)rac_handleVcodeButtonClick:(UIButton *)btn vcodeInputField:(VCodeInputField *)field
                            withVcodeType:(NSInteger)type phone:(NSString *)phone
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
        NSString *title = [NSString stringWithFormat:@"剩余%d秒", [x intValue]];
        [btn setTitle:title forState:UIControlStateDisabled];
        [field showRightViewAfterInterval:kVCodePromptInteval];
    } error:^(NSError *error) {
        btn.enabled = YES;
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

#pragma mark - VcodeInputField
- (void)setupVCodeInputField:(VCodeInputField *)field accountField:(UITextField *)adField forTargetVC:(UIViewController *)targetVC
{
    @weakify(field);
    [[[field.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      takeUntil:[targetVC rac_signalForSelector:@selector(didReceiveMemoryWarning)]] subscribeNext:^(id x) {
        @strongify(field);
//        [targetVC.view endEditing:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"验证码将以语音的形式通知到您,请注意接听电话。是否现在发送语音验证码?"
                                                       delegate:nil cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
            NSInteger index = [number integerValue];
            //“是”,将请求服务器发出一个语音验证码的请求
            if (index == 1) {
                [self getVoiceVCodeWithVCodeInputField:field account:adField.text targetVC:targetVC];
            }
        }];
        [alert show];
    }];
}

- (void)getVoiceVCodeWithVCodeInputField:(VCodeInputField *)field account:(NSString *)account targetVC:(UIViewController *)targetVC
{
    GetVoiceVCodeOp *op = [GetVoiceVCodeOp operation];
    op.req_phone = account;
    op.req_token = [gAppMgr.tokenPool tokenForAccount:account];
    [[[[op rac_postRequest] initially:^{
        [gToast showText:nil inView:targetVC.view];
    }] finally:^{
    }] subscribeNext:^(id x) {
        [gToast dismissInView:targetVC.view];
        [field hideRightView];
    } error:^(NSError *error) {
        [gToast showError:error.domain inView:targetVC.view];
    }];
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
