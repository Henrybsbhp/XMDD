//
//  GetPicListOp.h
//  XiaoMa
//
//  Created by RockyYe on 16/5/30.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetPicListOp : BaseOp

@property (strong, nonatomic) NSNumber *req_claimid;

@property (strong, nonatomic) NSArray *rsp_localelist;

@property (strong, nonatomic) NSArray *rsp_carlosslist;

@property (strong, nonatomic) NSArray *rsp_carinfolist;

@property (strong, nonatomic) NSArray *rsp_idphotolist;

@property (strong, nonatomic) NSString *rsp_canaddflag;

@property (strong, nonatomic) NSNumber *rsp_firstswitch;

@end
