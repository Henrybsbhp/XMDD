//
//  GetReactNativePackageOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetReactNativePackageOp : BaseOp
@property (nonatomic, strong) NSString *req_version;
@property (nonatomic, strong) NSString *req_appversion;

@property (nonatomic, strong) NSString *rsp_version;
@property (nonatomic, strong) NSString *rsp_minappversion;
@property (nonatomic, strong) NSString *rsp_patchurl;
@property (nonatomic, strong) NSArray *rsp_desc;
@end
