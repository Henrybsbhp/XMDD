//
//  ViolationCityInfo.h
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViolationCityInfo : NSObject<NSCoding>

@property (nonatomic)BOOL isViolationAvailable;

@property (nonatomic,copy)NSString * cityCode;

@property (nonatomic)BOOL isEngineNum;
@property (nonatomic)NSInteger engineSuffixNum;

@property (nonatomic)BOOL isClassNum;
@property (nonatomic)NSInteger classSuffixNum;

+ (instancetype)cityWithJSONResponse:(NSDictionary *)rsp;

@end
