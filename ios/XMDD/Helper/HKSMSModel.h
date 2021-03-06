//
//  HKSMSModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Xmdd.h"
#import "GetVcodeOp.h"
#import "VCodeInputField.h"
#import "GetVoiceVCodeOp.h"

typedef enum : NSInteger
{
    HKVcodeTypeLogin = 1,
    HKVcodeTypeResetPwd = 2,
    HKVcodeTypeRegist = 3,
    HKVcodeTypeBindCZB,
    HKVcodeTypeUnbindCZB,
    HKVcodeTypeCZBGasCharge,
    HKVcodeTypeUPay
}HKVcodeType;

@interface HKSMSModel : NSObject
@property (nonatomic, strong) UIButton *getVcodeButton;
@property (nonatomic, strong) VCodeInputField *inputVcodeField;
@property (nonatomic, strong) UITextField *phoneField;


///获取银联卡vcode
- (RACSignal *)rac_getUnionCardVcodeWithTokenID:(NSString *)tokenID andTradeNo:(NSString *)tradeNO;

/// 60秒等待时间
- (RACSignal *)rac_startGetLongIntervalVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal andPhone:(NSString *)phone;


- (void)setupWithTargetVC:(UIViewController *)targetVC mobEvents:(NSArray *)events;

///获取短信验证码 如果获取短信验证码接口返回成功，每隔1秒发送剩余冷却时间(sendNext:NSNumber*:剩余冷却时间)
- (RACSignal *)rac_getSystemVcodeWithType:(HKVcodeType)type phone:(NSString *)phone;

///对获取验证码按钮进行倒计时
- (BOOL)countDownIfNeededWithVcodeType:(HKVcodeType)type;

/// 30秒等待时间
- (RACSignal *)rac_startGetVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal;
- (RACSignal *)rac_startGetVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal andPhone:(NSString *)phone;


@end
