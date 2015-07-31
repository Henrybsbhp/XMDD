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
 *  是否进口车
 */
@property (nonatomic)BOOL isImportedCar;

- (CGFloat)calcInsurancePrice:(HKCoverage *)converage;

@end
