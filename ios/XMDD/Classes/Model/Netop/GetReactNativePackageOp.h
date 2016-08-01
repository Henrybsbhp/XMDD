//
//  GetReactNativePackageOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/5/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetReactNativePackageOp : BaseOp
@property (nonatomic, strong) NSString *req_rctversion;
@property (nonatomic, strong) NSString *req_appversion;
@property (nonatomic, strong) NSNumber *req_timetag;
@property (nonatomic, strong) NSString *req_projectname;
@property (nonatomic, strong) NSString *req_buildtype;

@property (nonatomic, strong) NSString *rsp_rctversion;
@property (nonatomic, strong) NSString *rsp_minappversion;
@property (nonatomic, strong) NSString *rsp_patchurl;
@property (nonatomic, strong) NSString *rsp_patchsign;
@property (nonatomic, strong) NSString *rsp_jssummary;


@end
