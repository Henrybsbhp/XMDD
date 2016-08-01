//
//  AddCarInfoOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface AddCarOp : BaseOp

@property (nonatomic,strong) HKMyCar *req_car;

@property (nonatomic,strong) NSNumber *rsp_carId;

@end
