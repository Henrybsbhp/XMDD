//
//  HKSMSModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XiaoMa.h"
#import "GetVcodeOp.h"

@interface HKSMSModel : NSObject

///获取短信验证码 如果获取短信验证码接口返回成功，每隔1秒发送剩余冷却时间(sendNext:NSNumber*:剩余冷却时间)
- (RACSignal *)rac_getVcodeWithType:(NSInteger)type phone:(NSString *)phone;
- (RACSignal *)rac_handleVcodeButtonClick:(UIButton *)btn withVcodeType:(NSInteger)type phone:(NSString *)phone;

@end
