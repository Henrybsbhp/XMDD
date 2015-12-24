//
//  InsuranceVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsuranceVM.h"
#import "HKCoverage.h"

@implementation InsuranceVM

- (id)copyWithZone:(NSZone *)zone
{
    InsuranceVM *model = [[InsuranceVM allocWithZone:zone] init];
    model.simpleCar = _simpleCar;
    model.realName = _realName;
    model.numOfSeat = _numOfSeat;
    model.inscomp = _inscomp;
    model.inscompname = _inscompname;
    model.originVC = _originVC;
    return model;
}

- (NSArray *)createCoveragesList
{
    HKCoverage * coverage1 = [[HKCoverage alloc] initWithCategory:InsuranceCompulsory];
    HKCoverage * coverage2 = [[HKCoverage alloc] initWithCategory:InsuranceTravelTax];
    HKCoverage * coverage3 = [[HKCoverage alloc] initWithCategory:InsuranceCarDamage];
    HKCoverage * coverage4 = [[HKCoverage alloc] initWithCategory:InsuranceThirdPartyLiability];
    HKCoverage * coverage5 = [[HKCoverage alloc] initWithCategory:InsuranceCarSeatInsuranceOfDriver];
    HKCoverage * coverage6 = [[HKCoverage alloc] initWithCategory:InsuranceCarSeatInsuranceOfPassenger];
    HKCoverage * coverage7 = [[HKCoverage alloc] initWithCategory:InsuranceWholeCarStolen];
    HKCoverage * coverage8 = [[HKCoverage alloc] initWithCategory:InsuranceSeparateGlassBreakage];
    HKCoverage * coverage9 = [[HKCoverage alloc] initWithCategory:InsuranceSpontaneousLossRisk];
    HKCoverage * coverage10 = [[HKCoverage alloc] initWithCategory:InsuranceWaterLoss];
    HKCoverage * coverage11 = [[HKCoverage alloc] initWithCategory:InsuranceCarBodyScratches];
    
    return @[@[coverage1,coverage2,coverage3,coverage4,coverage5,coverage6,coverage7],
             @[coverage8,coverage9,coverage10,coverage11]];
}
@end
