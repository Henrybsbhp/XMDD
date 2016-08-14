//
//  Shop.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+AddParams.h"
#import "Constants.h"
#import "CKList.h"

typedef enum : NSUInteger {
    ShopVacationTypeService,
    ShopVacationTypeVacation,
} ShopVacationType;

@interface ChargeContent : NSObject
///支付渠道
@property (nonatomic)PaymentChannelType paymentChannelType;
///支付额
@property (nonatomic) double amount;

+ (instancetype)chargeContentWithJSONResponse:(NSDictionary *)rsp;

@end

@interface JTShopService : NSObject<CKItemDelegate>
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
@property (nonatomic) double contractprice;
///原价
@property (nonatomic) double origprice;
/// 原始原价
@property (nonatomic) double oldOriginPrice;

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
///评价
@property (nonatomic, copy) NSString *serviceName;

+ (instancetype)shopCommentWithJSONResponse:(NSDictionary *)rsp;

@end

@interface JTShop : NSObject<CKItemDelegate>
///商户id
@property (nonatomic,strong)NSNumber * shopID;
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
///评价数
@property (nonatomic)NSInteger commentNumber;
///洗车服务[JTShopService]
@property (nonatomic,strong)NSArray * shopServiceArray;
///保养服务[JTShopService]
@property (nonatomic,strong)NSArray * maintenanceServiceArray;
///美容服务[JTShopService]
@property (nonatomic,strong)NSArray * beautyServiceArray;
///保养商户评级
@property (nonatomic, assign) NSInteger maintenanceRateNumber;
///美容商户评级
@property (nonatomic, assign) NSInteger beautyRateNumber;
///保养评论数量
@property (nonatomic, assign) NSInteger maintenanceCommentNumber;
///美容评论数量
@property (nonatomic, assign) NSInteger beautyCommentNumber;
///允许使用农行卡
@property (nonatomic)BOOL allowABC;
///商户服务[JTShopComment]
@property (nonatomic,strong)NSArray * shopCommentArray;
///公报
@property (nonatomic,copy)NSString * announcement;
///该商户洗车服务总评价数量
@property (nonatomic)NSInteger ratenumber;
//是否休假，1:是。0：营业
@property (nonatomic,strong)NSNumber *isVacation;

+ (instancetype)shopWithJSONResponse:(NSDictionary *)rsp;
///是否正在营业时段
- (BOOL)isInBusinessHours;
///营业中，已休息，暂停营业
- (NSString *)descForBusinessStatus;
- (NSArray *)filterShopServiceByType:(ShopServiceType)type;

@end
