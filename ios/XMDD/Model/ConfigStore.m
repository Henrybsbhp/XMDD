//
//  ConfigStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ConfigStore.h"
#import "RACSignal+Extension.h"

@implementation ConfigStore

- (void)loadDefaultSystemConfig {
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    GetSystemConfigInfoOp *op = [GetSystemConfigInfoOp operation];
    self.systemConfig = [op parseResponseObject:[userdef objectForKey:@"$config.system"]];
}

- (RACSignal *)fetchSystemConfig {
     return [[[[[gMapHelper rac_getUserLocationAndInvertGeoInfoWithAccuracy:kCLLocationAccuracyKilometer]
                take:1] ignoreError] then:^RACSignal *{
         
        GetSystemConfigInfoOp *op = [GetSystemConfigInfoOp operation];
        op.req_province = gMapHelper.addrComponent.province;
        op.req_city = gMapHelper.addrComponent.city;
        op.req_area = gMapHelper.addrComponent.district;
        op.req_type = 0;
        return [op rac_postRequest];
    }] doNext:^(GetSystemConfigInfoOp *op) {
        
        NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
        [userdef setObject:op.dict forKey:@"$config.system"];
        self.systemConfig = op;
    }];
}

@end
