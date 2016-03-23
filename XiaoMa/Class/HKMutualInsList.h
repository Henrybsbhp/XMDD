//
//  HKMutualInsList.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKMutualInsList : NSObject

//保险列表
@property (nonatomic, strong) NSArray * insList;
//三者险大于此值显示优惠文案
@property (nonatomic, copy) NSString * minthirdSum;
//三者险优惠文案
@property (nonatomic, copy) NSString * thirdsumTip;
//座位险大于此值显示优惠文案
@property (nonatomic, copy) NSString * minseatSum;
//座位险优惠文案
@property (nonatomic, copy) NSString * seatsumTip;
//新车购置价
@property (nonatomic, assign) CGFloat purchasePrice;
//提醒文案
@property (nonatomic, copy) NSString * remindTip;
//小马达达折扣
@property (nonatomic, assign) NSInteger xmddDiscount;

@end
