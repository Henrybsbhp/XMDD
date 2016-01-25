//
//  GetSystemJSPatchOp.h
//  XiaoMa
//
//  Created by jt on 16/1/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetSystemJSPatchOp : BaseOp

@property (nonatomic,copy)NSString * phoneNumber;
@property (nonatomic,copy)NSString * version;
@property (nonatomic,copy)NSString * province;
@property (nonatomic,copy)NSString * city;
@property (nonatomic,copy)NSString * district;

@property (nonatomic,copy)NSString * rsp_jspatchUrl;


@end
