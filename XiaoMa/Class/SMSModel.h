//
//  SMSManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKDatasource.h"

typedef enum : NSInteger
{
    HKVcodeTypeLogin = 1,
    HKVcodeTypeBindCZB,
    HKVcodeTypeUnbindCZB,
    HKVcodeTypeCZBGasCharge
}HKVcodeType;

@interface SMSModel : NSObject
@property (nonatomic, assign, readonly) HKVcodeType vcodeType;

- (instancetype)initWithVcodeType:(HKVcodeType)type;

//登录倒计时剩余时间
@property (nonatomic, assign) NSInteger remainTime;
//正在获取验证码
@property (nonatomic, assign) BOOL isGettingVcode;
//获取验证码失败的错误提示
@property (nonatomic, strong) NSString *errorMessage;
//需要更新当前状态
@property (nonatomic, assign) BOOL needUpdateStatus;

//开始获取登录验证码
- (void)startGetLoginVcodeWithPhone:(NSString *)phone;
//如果验证码还在冷却，则开始倒计时
- (void)timeCountdownIfNeeded;
- (NSString *)titleForCurrentStatus;
//当前能否获取验证码
- (BOOL)canGetVcode;

@end
