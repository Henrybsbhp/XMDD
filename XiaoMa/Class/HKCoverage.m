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
                NSDictionary * d = @{@"key":@"50万",@"value":@(1631)};
                d.customTag = YES;
                self.params = @[@{@"key":@"5万",@"value":@(673)},
                                @{@"key":@"10万",@"value":@(972)},
                                @{@"key":@"15万",@"value":@(1108)},
                                @{@"key":@"20万",@"value":@(1204)},
                                @{@"key":@"30万",@"value":@(1359)},
                                d,
                                @{@"key":@"100万",@"value":@(2186)},
                                @{@"key":@"150万",@"value":@(2686)},
                                @{@"key":@"200万",@"value":@(3185)},
                                @{@"key":@"250万",@"value":@(3685)},
                                @{@"key":@"300万",@"value":@(4184)},
                                @{@"key":@"350万",@"value":@(4684)},
                                @{@"key":@"400万",@"value":@(5183)},
                                @{@"key":@"450万",@"value":@(5683)},
                                @{@"key":@"500万",@"value":@(6182)},
                                @{@"key":@"550万",@"value":@(6682)},
                                @{@"key":@"600万",@"value":@(7181)},
                                @{@"key":@"650万",@"value":@(7681)},
                                @{@"key":@"700万",@"value":@(8180)},
                                @{@"key":@"750万",@"value":@(8680)},
                                @{@"key":@"800万",@"value":@(9179)},
                                @{@"key":@"850万",@"value":@(9679)},
                                @{@"key":@"900万",@"value":@(10178)},
                                @{@"key":@"950万",@"value":@(10678)},
                                @{@"key":@"1000万",@"value":@(11177)}
                                ];
                
                self.discountType = InsuranceBusinessDiscount;
                
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4ThirdPartyLiability];
                subCoverage.params = self.params;
                self.excludingDeductibleCoverage = subCoverage;
                break;
            }
                
            case InsuranceCarSeatInsuranceOfDriver:{
                self.insName = @"司机座位责任险";
                NSDictionary * d = @{@"key":@"1万",@"value":@(10000)};
                d.customTag = YES;
                self.params = @[d,
                                @{@"key":@"2万",@"value":@(20000)},
                                @{@"key":@"3万",@"value":@(30000)},
                                @{@"key":@"4万",@"value":@(40000)},
                                @{@"key":@"5万",@"value":@(50000)},
                                @{@"key":@"10万",@"value":@(100000)},
                                @{@"key":@"20万",@"value":@(200000)}
                                ];
                self.discountType = InsuranceBusinessDiscount;
                
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfDriver];
                subCoverage.params = self.params;
                self.excludingDeductibleCoverage = subCoverage;
                
                break;
            }
                
            case InsuranceCarSeatInsuranceOfPassenger:{
                self.insName = @"乘客座位责任险";
                NSDictionary * d = @{@"key":@"1万/座",@"value":@(10000)};
                d.customTag = YES;
                self.params = @[d,
                                @{@"key":@"2万/座",@"value":@(20000)},
                                @{@"key":@"3万/座",@"value":@(30000)},
                                @{@"key":@"4万/座",@"value":@(40000)},
                                @{@"key":@"5万/座",@"value":@(50000)},
                                @{@"key":@"10万/座",@"value":@(100000)},
                                @{@"key":@"20万/座",@"value":@(200000)}
                                ];
                
                NSDictionary * d2 = @{@"key":@"4座",@"value":@(4)};
                d2.customTag = YES;
                self.params2 = @[@{@"key":@"1座",@"value":@(1)},
                                @{@"key":@"2座",@"value":@(2)},
                                @{@"key":@"3座",@"value":@(3)},
                                d2,
                                @{@"key":@"5座",@"value":@(5)},
                                @{@"key":@"6座",@"value":@(6)}
                                ];
                self.discountType = InsuranceBusinessDiscount;
                
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger];
                subCoverage.params = self.params;
                subCoverage.params2 = self.params2;
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
                NSDictionary * d = @{@"key":@"国产",@"value":@(0.0021)};
                d.customTag = YES;
                self.params = @[d,
                                @{@"key":@"进口",@"value":@(0.0036)}
                                ];
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceSpontaneousLossRisk:{
                self.insName = @"自燃损失险";
                self.discountType = InsuranceBusinessDiscount;
                break;
            }
            case InsuranceWaterLoss:{
                self.insName = @"涉水损失险";
                self.discountType = InsuranceBusinessDiscount;
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
            default:{
                break;
            }
        }
    }
    return self;
}

@end
