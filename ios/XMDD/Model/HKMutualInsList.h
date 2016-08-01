//
//  HKMutualInsList.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKMutualInsList : NSObject

//预估费用
@property (nonatomic, assign) CGFloat premiumprice;
//优惠金额
@property (nonatomic, assign) CGFloat couponMoney;
//优惠列表
@property (nonatomic, strong) NSArray *couponList;
//提醒文案
@property (nonatomic, copy) NSString *remindTip;
//会员费
@property (nonatomic, assign) CGFloat memberFee;
//预估费用备注
@property (nonatomic, strong) NSArray *noteList;

@end
