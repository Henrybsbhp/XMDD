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
@property (nonatomic,copy)NSString * city;

///车牌
@property (nonatomic,copy)NSString * licencenumber;

///是否上牌
@property (nonatomic)BOOL registered;

///购置价格
@property (nonatomic)CGFloat purchaseprice;

///购置日期
@property (nonatomic,strong)NSDate * purchasedate;

@property (nonatomic,strong)NSString * phone;

@property (nonatomic,strong)NSArray * rsp_insuraceArray;

@end
