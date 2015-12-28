//
//  HKRescueNoLogin.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/15.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    HKRescueNoLoginTrailer = 1,//拖车
    HKRescueNoLoginPumpPower,//换胎
    HKRescueNoLogintire//泵电
} HKRescueTypeNoLogin;

@interface HKRescueNoLogin : NSObject
@property (nonatomic, copy)   NSString  * serviceName;//服务名称
@property (nonatomic ,copy)   NSString  * rescueDesc;//服务描述
@property (nonatomic, strong) NSNumber  * rescueID;//救援服务id
@property (nonatomic, copy)   NSString  * amount;//jine
@property (nonatomic, assign) HKRescueTypeNoLogin   type;//救援类型
@end
