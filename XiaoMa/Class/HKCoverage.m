//
//  HKCoverage.m
//  XiaoMa
//
//  Created by jt on 15/7/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKCoverage.h"

@implementation HKCoverage

- (instancetype)initWithCategory:(InsuranceCategory)category
{
    self = [super init];
    if (self)
    {
        self.insCategory = category;
        self.insId = @(category);
        switch (category) {
            case InsuranceCompulsory:{
                self.insName = @"交强险";
                self.discountType = InsuranceCompulsoryDiscount;
                break;
            }
                
            case InsuranceTravelTax:{
                self.insName = @"车船税";
                self.discountType = InsuranceTravelTaxDiscount;
                break;
            }
                
            case InsuranceCarDamage:{
                self.insName = @"车辆损失险";
                self.discountType = InsuranceBusinessDiscount;
                
                self.excludingDeductibleCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarDamage];
                break;
            }
                
            case InsuranceThirdPartyLiability:{
                self.insName = @"第三方责任险";
                self.params = @[@{@"key":@"5万",@"value":@(5)},
                                @{@"key":@"10万",@"value":@(10)},
                                @{@"key":@"15万",@"value":@(15)},
                                @{@"key":@"20万",@"value":@(20)},
                                @{@"key":@"30万",@"value":@(30)},
                                @{@"key":@"50万",@"value":@(50)},
                                @{@"key":@"100万",@"value":@(100)},
                                @{@"key":@"150万",@"value":@(150)},
                                @{@"key":@"200万",@"value":@(200)},
                                @{@"key":@"250万",@"value":@(250)},
                                @{@"key":@"300万",@"value":@(300)},
                                @{@"key":@"350万",@"value":@(350)},
                                @{@"key":@"400万",@"value":@(400)},
                                @{@"key":@"450万",@"value":@(450)},
                                @{@"key":@"500万",@"value":@(500)},
                                @{@"key":@"550万",@"value":@(550)},
                                @{@"key":@"600万",@"value":@(600)},
                                @{@"key":@"650万",@"value":@(650)},
                                @{@"key":@"700万",@"value":@(700)},
                                @{@"key":@"750万",@"value":@(750)},
                                @{@"key":@"800万",@"value":@(800)},
                                @{@"key":@"850万",@"value":@(850)},
                                @{@"key":@"900万",@"value":@(900)},
                                @{@"key":@"950万",@"value":@(950)},
                                @{@"key":@"1000万",@"value":@(1000)}];
                self.defParamIndex = 5;
                self.discountType = InsuranceBusinessDiscount;
                
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4ThirdPartyLiability];
                subCoverage.params = self.params;
                self.excludingDeductibleCoverage = subCoverage;
                break;
            }
                
            case InsuranceCarSeatInsuranceOfDriver:{
                self.insName = @"司机座位责任险";
                self.params = @[@{@"key":@"1万",@"value":@(1)},
                                @{@"key":@"2万",@"value":@(2)},
                                @{@"key":@"3万",@"value":@(3)},
                                @{@"key":@"4万",@"value":@(4)},
                                @{@"key":@"5万",@"value":@(5)},
                                @{@"key":@"10万",@"value":@(10)},
                                @{@"key":@"20万",@"value":@(20)}
                                ];
                self.defParamIndex = 0;
                self.discountType = InsuranceBusinessDiscount;
                
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfDriver];
                subCoverage.params = self.params;
                self.excludingDeductibleCoverage = subCoverage;
                
                break;
            }
                
            case InsuranceCarSeatInsuranceOfPassenger:{
                self.insName = @"乘客座位责任险";
                self.params = @[@{@"key":@"1万/座",@"value":@(1)},
                                @{@"key":@"2万/座",@"value":@(2)},
                                @{@"key":@"3万/座",@"value":@(3)},
                                @{@"key":@"4万/座",@"value":@(4)},
                                @{@"key":@"5万/座",@"value":@(5)},
                                @{@"key":@"10万/座",@"value":@(10)},
                                @{@"key":@"20万/座",@"value":@(20)}
                                ];
                self.defParamIndex = 0;
                self.discountType = InsuranceBusinessDiscount;
                
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger];
                subCoverage.params = self.params;
                self.excludingDeductibleCoverage= subCoverage;
                
                break;
            }
                
            case InsuranceWholeCarStolen:{
                self.insName = @"全车盗抢险";
                self.discountType = InsuranceBusinessDiscount;
                
                self.excludingDeductibleCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4WholeCarStolen];
                break;
            }
                
            case InsuranceSeparateGlassBreakage:{
                self.insName = @"玻璃单独破碎险";
                self.params = @[@{@"key":@"国产",@"value":@(1)},
                                @{@"key":@"进口",@"value":@(2)}
                                ];
                self.defParamIndex = 0;
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceSpontaneousLossRisk:{
                self.insName = @"自燃损失险";
                self.discountType = InsuranceBusinessDiscount;
                
                self.excludingDeductibleCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4SpontaneousLossRisk];
                break;
            }
            case InsuranceWaterLoss:{
                self.insName = @"涉水损失险";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceCarBodyScratches:{
                self.insName = @"车身划痕损失险";
    
                self.params = @[@{@"key":@"2千",@"value":@(0.2)},
                                @{@"key":@"5千",@"value":@(0.5)}];
                self.defParamIndex = 0;
                self.discountType = InsuranceBusinessDiscount;
                
                self.excludingDeductibleCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarBodyScratches];
                break;
            }
            case InsuranceExcludingDeductible4CarDamage:{
                self.insName = @"车损险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceExcludingDeductible4ThirdPartyLiability:{
                self.insName = @"第三者责任险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceExcludingDeductible4CarSeatInsuranceOfDriver:{
                self.insName = @"司机座位责任险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger:{
                self.insName = @"乘客座位责任险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceExcludingDeductible4WholeCarStolen:{
                self.insName = @"全车盗抢险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceExcludingDeductible4CarBodyScratches:{
                self.insName = @"车身划痕损失险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceExcludingDeductible4SpontaneousLossRisk:{
                self.insName = @"自燃损失险不计免赔";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            default:{
                break;
            }
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[HKCoverage class]]) {
        return [self.insId isEqual:[(HKCoverage *)object insId]];
    }
    return NO;
}

- (NSString *)coverageAmountDesc
{
    NSDictionary *param = [self.params firstObjectByFilteringOperator:^BOOL(NSDictionary *obj) {
        return obj.customTag;
    }];
    if (self.numOfSeat) {
        return [NSString stringWithFormat:@"%@ %@座", param[@"key"], self.numOfSeat];
    }
    return param[@"key"];
}

@end
