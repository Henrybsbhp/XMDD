//
//  ConfigStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ConfigStore.h"
#import "RACSignal+Extension.h"
#import <AMapLocationKit/AMapLocationKit.h>

@implementation ConfigStore

- (void)loadDefaultSystemConfig {
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    self.systemConfig = [userdef objectForKey:@"$config.system"];
}

- (RACSignal *)fetchSystemConfig {
    GetSystemConfigInfoOp *op = [GetSystemConfigInfoOp operation];
    op.req_type = 0;
     return [[[[[gMapHelper rac_getReGeocodeIfNeededWithAccuracy:kCLLocationAccuracyKilometer] ignoreError]
              doNext:^(RACTuple *tuple) {
                  
                  AMapLocationReGeocode *reGeocode = tuple.second;
                  op.req_province = reGeocode.province;
                  op.req_city = reGeocode.city;
                  op.req_area = reGeocode.district;
              }] then:^RACSignal *{
                  
                  return [op rac_postRequest];
            }] doNext:^(GetSystemConfigInfoOp *op) {
                
                NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
                [userdef setObject:op.rsp_configInfo forKey:@"$config.system"];
                self.systemConfig = op.rsp_configInfo;
            }];
}

- (NSString *)maintenanceDesc {
    return self.systemConfig[@"bydesc"];
}

@end
