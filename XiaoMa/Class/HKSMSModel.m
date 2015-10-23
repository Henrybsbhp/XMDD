//
//  HKSMSModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKSMSModel.h"
#import "GetTokenOp.h"
#import "GetBindCZBVcodeOp.h"
#import "GetUnbindBankcardVcodeOp.h"

///短信60秒冷却时间
#define kMaxVcodeInterval        60
/// 手机号码长度（11位）
#define kPhoneNumberLength      11

static NSTimeInterval s_coolingTimeForCZBGasCharge = 0;
static NSTimeInterval s_coolingTimeForUnbindCZB = 0;
static NSTimeInterval s_coolingTimeForBindCZB = 0;
static NSTimeInterval s_coolingTimeForLogin = 0;

@interface HKSMSModel ()<UITextFieldDelegate>

@end
@implementation HKSMSModel

///获取绑定浙商银行卡的短信验证码
- (RACSignal *)rac_getBindCZBVcodeWithCardno:(NSString *)cardno phone:(NSString *)phone
{
    GetBindCZBVcodeOp *op = [GetBindCZBVcodeOp operation];
    op.req_bankcardno = cardno;
    op.req_phone = phone;
    return [[[[op rac_postRequest] doError:^(NSError *error) {
        if (error.code == 616103) {
            s_coolingTimeForBindCZB = [[NSDate date] timeIntervalSince1970];
        }
    }] doNext:^(id x) {
        s_coolingTimeForBindCZB = [[NSDate date] timeIntervalSince1970];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

///获取解绑浙商银行卡的短信验证码
- (RACSignal *)rac_getUnbindCZBVcode
{
    GetUnbindBankcardVcodeOp *op = [GetUnbindBankcardVcodeOp operation];
    RACSignal *signal = [op rac_postRequest];
    return [[signal doNext:^(id x) {
        s_coolingTimeForUnbindCZB = [[NSDate date] timeIntervalSince1970];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)rac_getVcodeWithType:(HKVcodeType)type fromSignal:(RACSignal *)signal
{
    return [[signal doNext:^(id x) {
        NSTimeInterval timetag = [[NSDate date] timeIntervalSince1970];
        switch (type) {
            case HKVcodeTypeLogin:
                s_coolingTimeForLogin = timetag;
                break;
            case HKVcodeTypeBindCZB:
                s_coolingTimeForBindCZB = timetag;
                break;
            case HKVcodeTypeUnbindCZB:
                s_coolingTimeForUnbindCZB = timetag;
                break;
            case HKVcodeTypeCZBGasCharge:
                s_coolingTimeForCZBGasCharge = timetag;
                break;
            case HKVcodeTypeRegist:
                s_coolingTimeForLogin = timetag;
                break;
            case HKVcodeTypeResetPwd:
                s_coolingTimeForLogin = timetag;
                break;
            default:
                break;
        }
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

///获取短信验证码 如果获取短信验证码接口返回成功，每隔1秒发送剩余冷却时间(sendNext:NSNumber*:剩余冷却时间)
- (RACSignal *)rac_getSystemVcodeWithType:(HKVcodeType)type phone:(NSString *)phone
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
        s_coolingTimeForLogin = [[NSDate date] timeIntervalSince1970];
    }];
    //切换到主线程接收next
    signal = [signal deliverOn:[RACScheduler mainThreadScheduler]];
    
    return signal;
}

- (BOOL)countDownIfNeededWithVcodeType:(HKVcodeType)type
{
    UIButton *vbtn = self.getVcodeButton;
    NSTimeInterval coolingTime = s_coolingTimeForLogin;
    if (type == HKVcodeTypeBindCZB) {
        coolingTime = s_coolingTimeForBindCZB;
    }
    else if (type == HKVcodeTypeUnbindCZB) {
        coolingTime = s_coolingTimeForUnbindCZB;
    }
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - coolingTime;
    if (interval < kMaxVcodeInterval) {
        NSString *originTitle = [vbtn titleForState:UIControlStateNormal];
        vbtn.enabled = NO;
        @weakify(self);
        [[self rac_timeCountDown:kMaxVcodeInterval - interval] subscribeNext:^(id x) {
            NSString *title = [NSString stringWithFormat:@"剩余%d秒", [x intValue]];
            [vbtn setTitle:title forState:UIControlStateDisabled];
            [vbtn setTitle:title forState:UIControlStateNormal];
        } completed:^{
            @strongify(self);
            [vbtn setTitle:originTitle forState:UIControlStateNormal];
            if (self.phoneField) {
                vbtn.enabled = [self.phoneField.text length] == 11 ? YES : NO;
            }
            else {
                vbtn.enabled = YES;
            }
        }];
        return NO;
    }
    return YES;
}

- (RACSignal *)rac_startGetVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal
{
    UIButton *btn = self.getVcodeButton;
    VCodeInputField *field = self.inputVcodeField;
    
    NSString *originTitle = [btn titleForState:UIControlStateNormal];
    RACSubject *subject = [RACSubject subject];
    @weakify(self);
    [[[[vcodeSignal initially:^{
        [btn setTitle:@"正在获取..." forState:UIControlStateDisabled];
        [btn setTitle:@"正在获取..." forState:UIControlStateNormal];
        btn.enabled = NO;
    }] flattenMap:^RACStream *(id value) {
        [subject sendNext:value];
        [subject sendCompleted];
        [field showRightViewAfterInterval:kVCodePromptInteval];
        return [self rac_timeCountDown:kMaxVcodeInterval];
    }] finally:^{
        @strongify(self);
        if (self.phoneField) {
            btn.enabled = [self.phoneField.text length] == 11 ? YES : NO;
        }
        else {
            btn.enabled = YES;
        }
    }] subscribeNext:^(id x) {
        NSString *title = [NSString stringWithFormat:@"剩余%d秒", [x intValue]];
        [btn setTitle:title forState:UIControlStateDisabled];
        [btn setTitle:title forState:UIControlStateNormal];
    } error:^(NSError *error) {
        [subject sendError:error];
        [btn setTitle:originTitle forState:UIControlStateNormal];
    } completed:^{
        [btn setTitle:originTitle forState:UIControlStateNormal];
    }];
    return subject;
}

- (void)setupWithTargetVC:(UIViewController *)targetVC mobEvents:(NSArray *)events
{
    VCodeInputField *field = self.inputVcodeField;
    UITextField *adField = self.phoneField;
    @weakify(targetVC);
    @weakify(field);
    [[[field.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      takeUntil:[targetVC rac_signalForSelector:@selector(didReceiveMemoryWarning)]] subscribeNext:^(id x) {
        @strongify(field);
        @strongify(targetVC);
        [MobClick event:[events safetyObjectAtIndex:0]];
        //        [targetVC.view endEditing:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"验证码将以语音的形式通知到您，请注意接听电话。"
                                                       delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
            NSInteger index = [number integerValue];
            //否
            if (index == 0) {
                [MobClick event:[events safetyObjectAtIndex:1]];
            }
            //“是”,将请求服务器发出一个语音验证码的请求
            else {
                [MobClick event:[events safetyObjectAtIndex:2]];
                [self getVoiceVcodeWithVcodeInputField:field account:adField.text targetVC:targetVC];
            }
        }];
        [alert show];
    }];
}

- (RACSignal *)rac_timeCountDown:(NSTimeInterval)time
{
    __block int count = time;
    return [[[[[RACSignal interval:1 onScheduler:[RACScheduler scheduler]]
              startWith:[NSDate date]] map:^id(id value) {
        
        return @(count--);
    }] take:time+1] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)getVoiceVcodeWithVcodeInputField:(VCodeInputField *)field account:(NSString *)account targetVC:(UIViewController *)targetVC
{
    GetVoiceVCodeOp *op = [GetVoiceVCodeOp operation];
    op.req_phone = account;
    op.req_token = [gAppMgr.tokenPool tokenForAccount:account];
    [[[[op rac_postRequest] initially:^{
        [gToast showingWithText:nil inView:targetVC.view];
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
