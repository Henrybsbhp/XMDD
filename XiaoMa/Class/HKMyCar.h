//
//  HKMyCar.h
//  XiaoMa
//
//  Created by jt on 15-4-17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+AddParams.h"

typedef enum : NSInteger
{
    HKCarEditableNone = 0,
    HKCarEditableEdit = 0x01,
    HKCarEditableDelete = 0x02,
    HKCarEditableAll = 0xff
}HKCarEditableMask;

typedef enum : NSInteger
{
    HKCarTintColorTypeUnknow = 0,
    HKCarTintColorTypeCyan,
    HKCarTintColorTypeYellow,
    HKCarTintColorTypeRed,
    HKCarTintColorTypeBlue,
    HKCarTintColorTypeGreen
}HKCarTintColorType;



@interface HKMyCar : NSObject<NSCopying>

///车id
@property (nonatomic,copy)NSNumber *carId;

///车牌区域 浙
@property (nonatomic,copy)NSString * licenceArea;
///车牌后缀 AB2345
@property (nonatomic,copy)NSString * licenceSuffix;
///车牌号码 浙AB2345
@property (nonatomic,copy)NSString * licencenumber;

///购买日期
@property (nonatomic,strong)NSDate * purchasedate;

///车辆品牌
@property (nonatomic,copy)NSString * brand;

///车辆型号
@property (nonatomic,copy)NSString * model;

///购买价格 单位：万元
@property (nonatomic)CGFloat price;

///行驶里程
@property (nonatomic)NSInteger odo;

///行驶证审核状态(1待审核,2审核通过,3审核失败,0无图片)
@property (nonatomic, assign) NSInteger status;

///保险公司
@property (nonatomic,copy)NSString * inscomp;

///行驶证url
@property (nonatomic, strong) NSString *licenceurl;

///保险到期日
@property (nonatomic,strong)NSDate * insexipiredate;

///是否为默认车辆
@property (nonatomic)BOOL isDefault;

@property (nonatomic, assign) HKCarTintColorType tintColorType;

@property (nonatomic, assign) HKCarEditableMask editMask;

+ (instancetype)carWithJSONResponse:(NSDictionary *)rsp;
- (NSDictionary *)jsonDictForCarInfo;
- (BOOL)isCarInfoCompleted;
- (BOOL)isDifferentFromAnother:(HKMyCar *)another;
- (NSString *)carSeriesDesc;
- (UIColor *)tintColor;
+ (UIColor *)tintColorForColorType:(HKCarTintColorType)colorType;

@end
