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
                break;
            }
                
            case InsuranceTravelTax:{
                self.insName = @"车船税";
                break;
            }
                
            case InsuranceCarDamage:{
                self.insName = @"车辆损失险";
                self.isContainExcludingDeductible = @(1);
                self.customObject = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarDamage];
                break;
            }
                
            case InsuranceThirdPartyLiability:{
                self.insName = @"第三方责任险";
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
                self.insName = @"司机座位责任险";
                NSDictionary * d = @{@"key":@"1万元",@"value":@(10000)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"2万元",@"value":@(20000)},
                                @{@"key":@"3万元",@"value":@(30000)},
                                @{@"key":@"4万元",@"value":@(40000)},
                                @{@"key":@"5万元",@"value":@(50000)},
                                @{@"key":@"10万元",@"value":@(100000)},
                                @{@"key":@"20万元",@"value":@(200000)}
                                ];
                self.isContainExcludingDeductible = @(1);
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfDriver];
                subCoverage.params = self.params;
                self.customObject = subCoverage;
                
                break;
            }
                
            case InsuranceCarSeatInsuranceOfPassenger:{
                self.insName = @"乘客座位责任险 ";
                NSDictionary * d = @{@"key":@"1万元",@"value":@(10000)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"2万元",@"value":@(20000)},
                                @{@"key":@"3万元",@"value":@(30000)},
                                @{@"key":@"4万元",@"value":@(40000)},
                                @{@"key":@"5万元",@"value":@(50000)},
                                @{@"key":@"10万元",@"value":@(100000)},
                                @{@"key":@"20万元",@"value":@(200000)}
                                ];
                self.isContainExcludingDeductible = @(1);
                HKCoverage * subCoverage = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger];
                subCoverage.params = self.params;
                self.customObject = subCoverage;
                
                break;
            }
                
            case InsuranceWholeCarStolen:{
                self.insName = @"全车盗抢险";
                self.isContainExcludingDeductible = @(1);
                self.customObject = [[HKCoverage alloc] initWithCategory:InsuranceExcludingDeductible4WholeCarStolen];
                break;
            }
                
            case InsuranceSeparateGlassBreakage:{
                self.insName = @"玻璃单独破碎险";
                NSDictionary * d = @{@"key":@"国产",@"value":@(0.0021)};
                d.customFlag = YES;
                self.params = @[d,
                                @{@"key":@"进口",@"value":@(0.0036)}
                                ];
                break;
            }
            case InsuranceSpontaneousLossRisk:{
                self.insName = @"自燃损失险";
                break;
            }
            case InsuranceWaterLoss:{
                self.insName = @"涉水损失险";
                break;
            }
            case InsuranceExcludingDeductible4CarDamage:{
                self.insName = @"车损险不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4ThirdPartyLiability:{
                self.insName = @"第三者责任险不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4CarSeatInsuranceOfDriver:{
                self.insName = @"司机座位责任险 不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger:{
                self.insName = @"乘客座位责任险 不计免赔";
                break;
            }
            case InsuranceExcludingDeductible4WholeCarStolen:{
                self.insName = @"全车盗抢险不计免赔";
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
