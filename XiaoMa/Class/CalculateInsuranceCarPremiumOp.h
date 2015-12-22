//
//  CalculateInsuranceCarPremiumOp.h
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface CalculateInsuranceCarPremiumOp : BaseOp

///核保记录ID
@property (nonatomic,strong)NSNumber * carPremiumId;

///核保记录ID
@property (nonatomic,copy)NSString * inslist;

@end
