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

RCT_EXPORT_METHOD(openURL:(NSURL *)URL
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    BOOL opened = [[UIApplication sharedApplication] openURL:URL];
    if (opened) {
        resolve(nil);
    } else {
        reject(@"EUNSPECIFIED", [NSString stringWithFormat:@"Unable to open URL: %@", URL], nil);
    }
}

@end
