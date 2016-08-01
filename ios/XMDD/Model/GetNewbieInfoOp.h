//
//  GetNewbieInfoOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetNewbieInfoOp : BaseOp

@property (nonatomic, strong) NSString *req_province;
@property (nonatomic, strong) NSString *req_city;

///0：未洗过车。1：洗过车
@property (nonatomic, assign) NSInteger rsp_washcarflag;
///0：不是活动日。1：是活动日
@property (nonatomic, assign) NSInteger rsp_activitydayflag;
///0:不弹起，1：弹起
@property (nonatomic, assign) NSInteger rsp_jumpwinflag;
@property (nonatomic, strong) NSString *rsp_url;
@property (nonatomic, strong) NSString *rsp_pic;

@end
