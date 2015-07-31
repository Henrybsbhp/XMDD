//
//  InsuranceCalcHelper.m
//  XiaoMa
//
//  Created by jt on 15/7/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceCalcHelper.h"

@implementation InsuranceCalcHelper

- (CGFloat)calcInsurancePrice:(HKCoverage *)converage
{
    CGFloat price = 0;
    switch (converage.insCategory) {
        case InsuranceCompulsory:
            
            break;
        case InsuranceTravelTax:
            
            break;
        case InsuranceCarDamage:
            
            break;
        case InsuranceThirdPartyLiability:
            
            break;
        case InsuranceCarSeatInsuranceOfDriver:
            
            break;
        case InsuranceCarSeatInsuranceOfPassenger:
            
            break;
        case InsuranceWholeCarStolen:
            
            break;
        case InsuranceSeparateGlassBreakage:
            
            break;
        case InsuranceSpontaneousLossRisk:
            
            break;
        case InsuranceWaterLoss:
            
            break;
        case InsuranceExcludingDeductible4CarDamage:
            
            break;
        case InsuranceExcludingDeductible4ThirdPartyLiability:
            
            break;
        case InsuranceExcludingDeductible4CarSeatInsuranceOfDriver:
            
            break;
        case InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger:
            
            break;
        case InsuranceExcludingDeductible4WholeCarStolen:
            
            break;
            
        default:
            break;
    }
}

@end
