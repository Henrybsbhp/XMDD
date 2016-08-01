//
//  RCTLoginManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTLoginManager.h"
#import "HKLoadingModel.h"

@implementation RCTLoginManager

RCT_EXPORT_MODULE()


RCT_EXPORT_METHOD(logout) {
    [HKLoginModel logout];
}

@end
