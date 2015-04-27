//
//  GetInsuranceCalculatorOp.h
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetInsuranceCalculatorOp : BaseOp

///城市
@property (nonatomic,copy)NSString * req_city;

///车牌
@property (nonatomic,copy)NSString * req_licencenumber;

///是否上牌
@property (nonatomic)BOOL req_registered;

///购置价格
@property (nonatomic)CGFloat req_purchaseprice;

///购置日期
@property (nonatomic,strong)NSDate * req_purchasedate;

@property (nonatomic,strong)NSString * req_phone;

@property (nonatomic,strong)NSArray * rsp_insuraceArray;

@end
