//
//  HKCouponPkg.h
//  XiaoMa
//
//  Created by jt on 15-5-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKCouponPkg : NSObject

///礼包名字
@property (nonatomic,copy)NSString * pkgName;

@property (nonatomic,strong)NSArray * couponsArray;

+ (instancetype)couponPkgWithJSONResponse:(NSDictionary *)rsp;

@end
