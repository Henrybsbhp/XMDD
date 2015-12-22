//
//  InsuranceVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/16.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsuranceVM.h"

@implementation InsuranceVM

- (id)copyWithZone:(NSZone *)zone
{
    InsuranceVM *model = [[InsuranceVM allocWithZone:zone] init];
    model.licenseNumber = _licenseNumber;
    model.premiumId = _premiumId;
    model.realName = _realName;
    model.numOfSeat = _numOfSeat;
    model.inscomp = _inscomp;
    model.inscompname = _inscompname;
    model.originVC = _originVC;
    return model;
}


@end
