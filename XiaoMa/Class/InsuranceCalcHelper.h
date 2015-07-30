//
//  InsuranceCalcHelper.h
//  XiaoMa
//
//  Created by jt on 15/7/30.
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
} InsuranceName;

typedef enum : NSUInteger {
    InsuranceTypeCompulsion,//强制险
    InsuranceTypeBase,//基本险
    InsuranceTypeAdditional,//附加险
    InsuranceTypeContractualTerms//特约条款
} InsuranceType;

@interface InsuranceCalcHelper : NSObject

/**
 *  车价
 */
@property (nonatomic)CGFloat carPrice;

/**
 *  车座数量
 */
@property (nonatomic)NSInteger numOfSeat;

/**
 *  是否进口车
 */
@property (nonatomic)BOOL isImportedCard;




@end
