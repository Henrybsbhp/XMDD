//
//  MyBankCardListModel.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyBankCardListModel : NSObject

/// 银行卡号
@property (nonatomic, copy) NSString *cardNo;

/// 卡归属银行名
@property (nonatomic, copy) NSString *issueBank;

/// 快捷支付 tokenID
@property (nonatomic, copy) NSString *tokenID;

/// 卡的类型
@property (nonatomic, copy) NSString *cardType;

/// 浙商汽车卡标识
@property (nonatomic, assign) NSInteger czbFlag;

/// 银行卡绑定手机
@property (nonatomic, copy) NSString *bindPhone;

/// 银行卡 logo
@property (nonatomic, copy) NSString *bankLogo;

/// 银行卡下面的信息提示
@property (nonatomic, copy) NSString *bankTips;

+ (instancetype)listWithJSONResponse:(NSDictionary *)rsp;

@end
