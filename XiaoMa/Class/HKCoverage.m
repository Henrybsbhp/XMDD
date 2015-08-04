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
        switch (category) {
            case InsuranceCompulsory:{
                self.coverageName = @"交强险";
                break;
            }
                
            case InsuranceTravelTax:{
                self.coverageName = @"车船税";
                break;
            }
                
            case InsuranceCarDamage:{
                self.coverageName = @"车辆损失险";
                self.isContainExcludingDeductible = @(1);
                self.customObject = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarDamage];
                break;
            }
                
            case InsuranceThirdPartyLiability:{
                self.coverageName = @"第三方责任险";
                NSDictionary * d = @{@"key":@"5万元",@"value":@(673)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"10万元",@"value":@(972)},
                                @{@"key":@"15万元",@"value":@(1108)},
                                @{@"key":@"20万元",@"value":@(1204)},
                                @{@"key":@"30万元",@"value":@(1359)},
                                @{@"key":@"50万元",@"value":@(1631)},
                                @{@"key":@"100万元",@"value":@(2186)},
                                @{@"key":@"150万元",@"value":@(2686)},
                                @{@"key":@"200万元",@"value":@(3185)},
                                @{@"key":@"250万元",@"value":@(3685)},
                                @{@"key":@"300万元",@"value":@(4184)},
                                @{@"key":@"350万元",@"value":@(4684)},
                                @{@"key":@"400万元",@"value":@(5183)},
                                @{@"key":@"450万元",@"value":@(5683)},
                                @{@"key":@"500万元",@"value":@(6182)},
                                @{@"key":@"550万元",@"value":@(6682)},
                                @{@"key":@"600万元",@"value":@(7181)},
                                @{@"key":@"650万元",@"value":@(7681)},
                                @{@"key":@"700万元",@"value":@(8180)},
                                @{@"key":@"750万元",@"value":@(8680)},
                                @{@"key":@"800万元",@"value":@(9179)},
                                @{@"key":@"850万元",@"value":@(9679)},
                                @{@"key":@"900万元",@"value":@(10178)},
                                @{@"key":@"950万元",@"value":@(10678)},
                                @{@"key":@"1000万元",@"value":@(11177)}
                                ];
                self.isContainExcludingDeductible = @(1);
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4ThirdPartyLiability];
                subCoverage.params = self.params;
                self.customObject = subCoverage;
                break;
            }
                
            case InsuranceCarSeatInsuranceOfDriver:{
                self.coverageName = @"车上人员座位险(司机)";
                NSDictionary * d = @{@"key":@"1 万元/座",@"value":@(10000)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"2 万元/座",@"value":@(20000)},
                                @{@"key":@"3 万元/座",@"value":@(30000)},
                                @{@"key":@"4 万元/座",@"value":@(40000)},
                                @{@"key":@"5 万元/座",@"value":@(50000)},
                                @{@"key":@"10 万元/座",@"value":@(100000)},
                                @{@"key":@"20 万元/座",@"value":@(200000)}
                                ];
                self.isContainExcludingDeductible = @(1);
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfDriver];
                subCoverage.params = self.params;
                self.customObject = subCoverage;
                
                break;
            }
                
            case InsuranceCarSeatInsuranceOfPassenger:{
                self.coverageName = @"车上人员座位险(乘客)";
                NSDictionary * d = @{@"key":@"1 万元/座",@"value":@(10000)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"2 万元/座",@"value":@(20000)},
                                @{@"key":@"3 万元/座",@"value":@(30000)},
                                @{@"key":@"4 万元/座",@"value":@(40000)},
                                @{@"key":@"5 万元/座",@"value":@(50000)},
                                @{@"key":@"10 万元/座",@"value":@(100000)},
                                @{@"key":@"20 万元/座",@"value":@(200000)}
                                ];
                self.isContainExcludingDeductible = @(1);
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger];
                subCoverage.params = self.params;
                self.customObject = subCoverage;
                
                break;
            }
                
            case InsuranceWholeCarStolen:{
                self.coverageName = @"全车盗抢险";
                self.isContainExcludingDeductible = @(1);
                self.customObject = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4WholeCarStolen];
                break;
            }
                
            case InsuranceSeparateGlassBreakage:{
                self.coverageName = @"玻璃单独破碎险";
                NSDictionary * d = @{@"key":@"国产",@"value":@(0.0021)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"进口",@"value":@(0.0036)}
                                ];
                break;
            }
            case InsuranceSpontaneousLossRisk:{
                self.coverageName = @"自燃损失险";
                break;
            }
            case InsuranceWaterLoss:{
                self.coverageName = @"涉水损失险";
                break;
            }
            case InsuranceExcludingDeductible4CarDamage:{
                self.coverageName = @"车损险不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4ThirdPartyLiability:{
                self.coverageName = @"第三者责任险不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4CarSeatInsuranceOfDriver:{
                self.coverageName = @"车上责任险(司机)不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger:{
                self.coverageName = @"车上责任险(乘客)不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4WholeCarStolen:{
                self.coverageName = @"全车盗抢险不计免赔";
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
