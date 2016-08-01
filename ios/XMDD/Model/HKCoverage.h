//
//  HKCoverage.h
//  XiaoMa
//
//  Created by jt on 15/7/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 枚举值可用作id
 */
typedef enum : NSUInteger {
    InsuranceCompulsory = 14,//交强险
    InsuranceTravelTax = 15, //车船税
    InsuranceCarDamage = 1,//车辆损失险
    InsuranceThirdPartyLiability = 2,//第三方责任险
    InsuranceCarSeatInsuranceOfDriver = 3,//车上人员座位险（司机）
    InsuranceCarSeatInsuranceOfPassenger =4,//车上人员座位险（乘客）
    InsuranceWholeCarStolen = 5,//全车盗抢险
    InsuranceSeparateGlassBreakage =6,//玻璃单独破碎险
    InsuranceSpontaneousLossRisk =7,//自燃损失险
    InsuranceWaterLoss = 8,//涉水损失险
    InsuranceExcludingDeductible4CarDamage = 9,//车损险不计免赔
    InsuranceExcludingDeductible4ThirdPartyLiability = 10,//第三者责任险不计免赔
    InsuranceExcludingDeductible4CarSeatInsuranceOfDriver = 11,//车上责任险（司机）不计免赔
    InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger = 12,//车上责任险（乘客）不计免赔
    InsuranceExcludingDeductible4WholeCarStolen =13,//全车盗抢险不计免赔
    InsuranceCarBodyScratches = 16,//车身划痕损失险
    InsuranceExcludingDeductible4CarBodyScratches =17,//车身划痕损失险不计免赔
    //自燃损失险不计免赔
    InsuranceExcludingDeductible4SpontaneousLossRisk =18,
} InsuranceCategory;

typedef enum : NSUInteger {
    InsuranceTypeCompulsion,//强制险
    InsuranceTypeBase,//基本险
    InsuranceTypeAdditional,//附加险
    InsuranceTypeContractualTerms//特约条款
} InsuranceType;

typedef enum : NSUInteger {
    InsuranceCompulsoryDiscount = 1,//交强
    InsuranceTravelTaxDiscount,//车船
    InsuranceBusinessDiscount//商业
} InsuranceDiscountType;

@interface HKCoverage : NSObject

@property (nonatomic,strong)NSNumber * insId;

@property (nonatomic,copy)NSString * insName;

@property (nonatomic,strong)NSNumber * numOfSeat;

@property (nonatomic)InsuranceCategory insCategory;

@property (nonatomic)InsuranceDiscountType discountType;

/**
 *  是否包含不计免赔
 */
@property (nonatomic,strong)HKCoverage * excludingDeductibleCoverage;

/**
 *  相关参数,<NSDictory>
 */
@property (nonatomic,strong)NSArray * params;
@property (nonatomic, assign) NSUInteger defParamIndex;


- (instancetype)initWithCategory:(InsuranceCategory)category;

- (NSString *)coverageAmountDesc;

@end
