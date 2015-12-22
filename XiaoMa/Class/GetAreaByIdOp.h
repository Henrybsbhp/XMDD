//
//  GetAreaByIdOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetAreaByIdOp : BaseOp

@property (nonatomic, assign) long long req_updateTime;
///1省信息，2市信息，3区信息
@property (nonatomic, assign) NSInteger req_type;
@property (nonatomic, strong) NSNumber *req_areaId;

@property (nonatomic, strong)NSArray *rsp_areaArray;
@property (nonatomic, assign)long long rsp_maxTime;

@end
