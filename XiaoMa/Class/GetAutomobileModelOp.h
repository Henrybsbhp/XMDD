//
//  GetAutomobileModelOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetAutomobileModelOp : BaseOp
@property (nonatomic, strong) NSNumber *req_brandid;
@property (nonatomic, strong) NSArray *rsp_seriesList;
@end
