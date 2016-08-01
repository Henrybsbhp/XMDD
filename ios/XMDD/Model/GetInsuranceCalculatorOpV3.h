//
//  GetInsuranceCalculatorOpV3.h
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "HKInsurance.h"

@interface GetInsuranceCalculatorOpV3 : BaseOp

///城市
@property (nonatomic,copy) NSString * req_city;

///车牌
@property (nonatomic,copy) NSString * req_licencenumber;

///是否上牌
@property (nonatomic,assign) NSInteger req_registered;

///购置价格
@property (nonatomic,strong) NSString *req_purchaseprice;

///购置日期
@property (nonatomic,strong) NSDate * req_purchasedate;

@property (nonatomic,strong) NSArray * rsp_insuraceArray;
@property (nonatomic,strong) NSString * rsp_calculatorID;

@end
