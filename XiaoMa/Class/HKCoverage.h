//
//  HKCoverage.h
//  XiaoMa
//
//  Created by jt on 15/7/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    InsuranceCompulsory = 1101,//交强险
    InsuranceTravelTax = 1102, //车船税
    InsuranceCarDamage,//车辆损失险
    InsuranceThirdPartyLiability,//第三方责任险
    InsuranceCarSeatInsuranceOfDriver,//车上人员座位险（司机）
    InsuranceCarSeatInsuranceOfPassenger,//车上人员座位险（乘客）
    InsuranceWholeCarStolen,//全车盗抢险
    InsuranceSeparateGlassBreakage,//玻璃单独破碎险
    InsuranceSpontaneousLossRisk,//自燃损失险
    InsuranceWaterLoss,//涉水损失险
    InsuranceExcludingDeductible4CarDamage,//车损险不计免赔
    InsuranceExcludingDeductible4ThirdPartyLiability,//第三者责任险不计免赔
    InsuranceExcludingDeductible4CarSeatInsuranceOfDriver,//车上责任险（司机）不计免赔
    InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger,//车上责任险（乘客）不计免赔
    InsuranceExcludingDeductible4WholeCarStolen//全车盗抢险不计免赔
} InsuranceCategory;

typedef enum : NSUInteger {
    InsuranceTypeCompulsion,//强制险
    InsuranceTypeBase,//基本险
    InsuranceTypeAdditional,//附加险
    InsuranceTypeContractualTerms//特约条款
} InsuranceType;

@interface HKCoverage : NSObject

@property (nonatomic,copy)NSString * coverageName;

@property (nonatomic)InsuranceCategory insCategory;

/**
 *  是否包含不计免赔
 */
@property (nonatomic)BOOL isContainExcludingDeductible;

/**
 *  相关参数,<NSDictory>
 */
@property (nonatomic)NSArray * params;

@end
