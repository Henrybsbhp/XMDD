//
//  Shop.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+AddParams.h"



@interface ChargeContent : NSObject
///支付渠道
@property (nonatomic)PaymentChannelType paymentChannelType;
///支付额
@property (nonatomic)CGFloat amount;

+ (instancetype)chargeContentWithJSONResponse:(NSDictionary *)rsp;

@end

@interface JTShopService : NSObject
///服务id
@property (nonatomic,strong)NSNumber * serviceID;
///服务姓名
@property (nonatomic,copy)NSString * serviceName;
///服务描述
@property (nonatomic,copy)NSString * serviceDescription;
///服务类型
@property (nonatomic)ShopServiceType  shopServiceType;
///服务收费[ChargeContent]
@property (nonatomic,strong)NSArray * chargeArray;
///合约价
@property (nonatomic)CGFloat contractprice;
///原价
@property (nonatomic)CGFloat origprice;

+ (instancetype)shopServiceWithJSONResponse:(NSDictionary *)rsp;

@end

@interface JTShopComment : NSObject
///昵称
@property (nonatomic, strong) NSString *nickname;
///头像URL
@property (nonatomic, strong) NSString *avatarUrl;
///评分
@property (nonatomic) NSInteger rate;
///评价
@property (nonatomic, strong) NSString *comment;
///评价时间
@property (nonatomic, strong) NSDate *time;

+ (instancetype)shopCommentWithJSONResponse:(NSDictionary *)rsp;

@end

@interface JTShop : NSObject
///商户id
@property (nonatomic,copy)NSString * shopID;
///商户名称
@property (nonatomic,copy)NSString * shopName;
///商户图片
@property (nonatomic,strong)NSArray * picArray;
///商户评级
@property (nonatomic)CGFloat shopRate;
///地址
@property (nonatomic,copy)NSString * shopAddress;
///精度
@property (nonatomic)double shopLongitude;
///纬度
@property (nonatomic)double shopLatitude;
///电话
@property (nonatomic,copy)NSString * shopPhone;
///开门时间
@property (nonatomic,copy)NSString * openHour;
///关门时间
@property (nonatomic,copy)NSString * closeHour;
///已完成单数
@property (nonatomic)NSInteger txnumber;
///商户服务[JTShopService]
@property (nonatomic,strong)NSArray * shopServiceArray;
///允许使用农行卡
@property (nonatomic)BOOL allowABC;
///商户服务[JTShopComment]
@property (nonatomic,strong)NSArray * shopCommentArray;

+ (instancetype)shopWithJSONResponse:(NSDictionary *)rsp;
@end
