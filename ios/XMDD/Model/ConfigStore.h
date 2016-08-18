//
//  ConfigStore.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKBaseStore.h"
#import "HKAddressComponent.h"
#import <AMapLocationKit/AMapLocationKit.h>
#import "GetSystemConfigInfoOp.h"

@interface ConfigStore : CKBaseStore
@property (nonatomic, strong) NSDictionary *systemConfig;

- (void)loadDefaultSystemConfig;
- (RACSignal *)fetchSystemConfig;

- (NSString *)maintenanceDesc;


@end
