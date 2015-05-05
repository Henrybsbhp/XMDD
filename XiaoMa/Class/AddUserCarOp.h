//
//  AddUserCarOp.h
//  XiaoMa
//
//  Created by jt on 15-4-30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKMyCar.h"

@interface AddUserCarOp : BaseOp

@property (nonatomic)HKMyCar * car;

@property (nonatomic,strong)NSString * rsp_carid;

@end
