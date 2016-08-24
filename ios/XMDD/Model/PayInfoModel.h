//
//  PayInfoModel.h
//  XiaoMa
//
//  Created by fuqi on 16/6/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyBankCard.h"

@interface WechatPayInfo : NSObject

@property (nonatomic,strong)NSDictionary * payInfo;

@end

@interface PayInfoModel : NSObject

@property (nonatomic, copy) NSString * alipayInfo;
@property (strong, nonatomic) WechatPayInfo * wechatInfo;
@property (strong, nonatomic) NSArray<MyBankCard *> *bankListInfo;
@property (strong, nonatomic) NSString *unionPayDesc;

+ (instancetype)payInfoWithJSONResponse:(NSDictionary *)rsp;

@end
