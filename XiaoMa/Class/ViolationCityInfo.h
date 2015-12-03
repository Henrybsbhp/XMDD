//
//  ViolationCityInfo.h
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViolationProvinceInfo : NSObject<NSCoding>

@property (nonatomic,strong)NSNumber * pid;

@property (nonatomic,copy)NSString * province;

@property (nonatomic,copy)NSString * province_code;

@property (nonatomic,strong)NSArray * cityArray;

+ (instancetype)provinceWithJSONResponse:(NSDictionary *)rsp;

@end


@interface ViolationCityInfo : NSObject<NSCoding>

@property (nonatomic,copy)NSString * pCode;

@property (nonatomic,copy)NSString * cityCode;
@property (nonatomic,copy)NSString * cityName;

@property (nonatomic)BOOL isEngineNum;
@property (nonatomic)NSInteger engineSuffixNum;

@property (nonatomic)BOOL isClassNum;
@property (nonatomic)NSInteger classSuffixNum;

+ (instancetype)cityWithJSONResponse:(NSDictionary *)rsp;

@end
