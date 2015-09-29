//
//  InsuranceCalcHelper.m
//  XiaoMa
//
//  Created by jt on 15/7/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceCalcHelper.h"

#define NumberOfSeat 4

@implementation InsuranceCalcHelper

// 这里的参数不要随便改，请参考保险估算文档
- (CGFloat)calcInsurancePrice:(HKCoverage *)converage
{
    CGFloat price = 0.0;
    CGFloat discountRate = [[gAppMgr.discountRateDict objectForKey:@(converage.discountType)] floatValue];
    discountRate = (discountRate > 0 && discountRate <= 100) ? discountRate : 100 ;
    discountRate = discountRate / 100;
    switch (converage.insCategory) {
        case InsuranceCompulsory:{
            price = 950;
            break;
        }
            
        case InsuranceTravelTax:{
            price = 360;
            break;
        }
            
        case InsuranceCarDamage:{
            price = self.carPrice * 0.0128 + 539;
            break;
        }
            
        case InsuranceThirdPartyLiability:{
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    price = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            break;
        }
            
        case InsuranceCarSeatInsuranceOfDriver:{
            CGFloat amount = 0.0f;
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    amount = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            price = amount * 1 * 0.0041;
            break;
        }
            
        case InsuranceCarSeatInsuranceOfPassenger:{
            CGFloat amount = 0.0;
            NSInteger numberOfSeat = 1;
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    amount = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            
            for (NSDictionary * dict in converage.params2)
            {
                if (dict.customTag)
                {
                    numberOfSeat = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            
            
            price = amount * numberOfSeat * 0.0026;
            break;
        }
            
        case InsuranceWholeCarStolen:{
            price = self.carPrice * 0.928 * 0.0041 + 120;
            break;
        }
            
        case InsuranceSeparateGlassBreakage:{
            CGFloat ratio = 0.0f;
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    ratio = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            price = self.carPrice * ratio;
            break;
        }
        case InsuranceSpontaneousLossRisk:{
            price = self.carPrice * 0.928 * 0.0018;
            break;
        }
        case InsuranceWaterLoss:{
            price = (self.carPrice * 0.0128 + 539) * 0.05;
            break;
        }
        case InsuranceExcludingDeductible4CarDamage:{
            price = (self.carPrice * 0.0128 + 539) * 0.15;
            break;
        }
        case InsuranceExcludingDeductible4ThirdPartyLiability:{
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    price = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            price = price * 0.15;
            break;
        }
        case InsuranceExcludingDeductible4CarSeatInsuranceOfDriver:{
            CGFloat amount = 0.0f;
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    amount = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            price = (amount * 1 * 0.0041) * 0.15;
            break;
        }
        case InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger:{
            CGFloat amount = 0.0;
            NSInteger numberOfSeat = 1;
            for (NSDictionary * dict in converage.params)
            {
                if (dict.customTag)
                {
                    amount = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            for (NSDictionary * dict in converage.params2)
            {
                if (dict.customTag)
                {
                    numberOfSeat = [[dict objectForKey:@"value"] floatValue];
                    break;
                }
            }
            
            price = (amount * numberOfSeat * 0.0026) * 0.15;
            break;
        }
        case InsuranceExcludingDeductible4WholeCarStolen:{
            price = (self.carPrice * 0.928 * 0.0041 + 120) * 0.2;
            break;
        }
        default:
            price = 0;
            break;
    }
    
    CGFloat p = price * discountRate;
    //必须四舍五入
    CGFloat roundPrice = round(p*100)/100;
    return roundPrice;
}

@end
