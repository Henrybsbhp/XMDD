//
//  GetMutualInsListOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "HKMutualInsList.h"

@interface GetMutualInsListOp : BaseOp

@property (nonatomic, copy) NSString * req_version;

@property (nonatomic, strong) NSNumber * req_memberId;

@property (nonatomic, strong) HKMutualInsList * rsp_insModel;

@end
