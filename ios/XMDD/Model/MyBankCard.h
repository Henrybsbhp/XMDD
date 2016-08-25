//
//  MyBankCardListModel.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetCZBGaschargeInfoOp.h"

@interface MyBankCard : NSObject<NSCopying>

/// 银行卡号
@property (nonatomic, copy) NSString *cardNo;

/// 卡归属银行名
@property (nonatomic, copy) NSString *issueBank;

/// 快捷支付 tokenID
@property (nonatomic, copy) NSString *tokenID;

/// 卡的类型
@property (nonatomic, copy) NSString *cardTypeName;

/// 浙商汽车卡标示 1：浙商汽车卡。2:银联支付卡
@property (nonatomic) NSInteger cardType;

/// 浙商汽车卡标识
@property (nonatomic, assign) NSInteger czbFlag;

/// 银行卡绑定手机
@property (nonatomic, copy) NSString *bindPhone;

/// 银行卡 logo
@property (nonatomic, copy) NSString *bankLogo;

/// 银行卡下面的信息提示
@property (nonatomic, copy) NSString *bankTips;

///支付时候，改变手机地址
@property (nonatomic, copy) NSString *changephoneurl;

@property (nonatomic, strong) NSArray  *couponIds;
///加油信息
@property (nonatomic, strong) GetCZBGaschargeInfoOp *gasInfo;

+ (instancetype)bankInfoWithJSONResponse:(NSDictionary *)rsp;

@end
