//
//  RCTAppManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/20.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTAppManager.h"

@implementation RCTAppManager

RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(setAppManagerKeyPath:(NSString *)keyPath withValue:(id)value)
{
    [gAppMgr setValue:value forKeyPath:keyPath];
}

@end
