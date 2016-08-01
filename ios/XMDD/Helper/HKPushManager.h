//
//  HKPushManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PushManager.h"
#import "BindDeviceTokenOp.h"

@interface HKPushManager : PushManager
@property (nonatomic, readonly) BindDeviceTokenOp *bindOp;
- (void)autoBindDeviceTokenInBackground;
@end
