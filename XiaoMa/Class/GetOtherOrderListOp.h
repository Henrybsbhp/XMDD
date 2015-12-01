//
//  GetOtherOrderListOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKOtherOrder.h"

@interface GetOtherOrderListOp : BaseOp

@property (nonatomic, assign) long long req_payedtime;

@property (nonatomic, strong) NSArray *rsp_orders;

@end
