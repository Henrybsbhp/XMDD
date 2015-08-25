//
//  InsuranceCalcHelper.h
//  XiaoMa
//
//  Created by jt on 15/7/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKCoverage.h"

@interface InsuranceCalcHelper : NSObject

@property (nonatomic)CGFloat carPrice;

/**
 *  折扣率<NSNumber(险种id)，NSNumber（折扣率）>
 */
@property (nonatomic,strong)NSDictionary * discountRateDict;



/**
 *  险种价格计算
 *
 *  @param converage 险种
 *
 *  @return 险种价格
 */
- (CGFloat)calcInsurancePrice:(HKCoverage *)converage;

@end
