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

- (RACSignal *)rac_getBindCZBVcodeWithCardno:(NSString *)cardno phone:(NSString *)phone;
- (RACSignal *)rac_getUnbindCZBVcode;
- (RACSignal *)rac_getUnionCardVcodeWithTokenID:(NSString *)tokenID andTradeNo:(NSString *)tradeNO;


///获取短信验证码 如果获取短信验证码接口返回成功，每隔1秒发送剩余冷却时间(sendNext:NSNumber*:剩余冷却时间)
- (RACSignal *)rac_getSystemVcodeWithType:(HKVcodeType)type phone:(NSString *)phone;
- (RACSignal *)rac_getVcodeWithType:(HKVcodeType)type fromSignal:(RACSignal *)signal;

- (void)setupWithTargetVC:(UIViewController *)targetVC mobEvents:(NSArray *)events;
///对获取验证码按钮进行倒计时
- (BOOL)countDownIfNeededWithVcodeType:(HKVcodeType)type;
- (RACSignal *)rac_startGetVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal;
/// 30秒等待时间
- (RACSignal *)rac_startGetVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal andPhone:(NSString *)phone;
/// 60秒等待时间
- (RACSignal *)rac_startGetLongIntervalVcodeWithFetchVcodeSignal:(RACSignal *)vcodeSignal andPhone:(NSString *)phone;

@end
