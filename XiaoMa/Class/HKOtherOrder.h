//
//  HKOtherOrder.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKOtherOrder : NSObject

@property (nonatomic, strong) NSString *prodLogo;
@property (nonatomic, strong) NSString *prodName;
@property (nonatomic, strong) NSString *prodDesc;
@property (nonatomic, strong) NSString *originPrice;
@property (nonatomic, strong) NSString *couponPrice;
@property (nonatomic, assign) CGFloat fee;
@property (nonatomic, assign) long long payedTime;
@property (nonatomic, strong) NSString *tradeType;
@property (nonatomic, strong) NSString *payDesc;
@property (nonatomic, assign) NSInteger oId;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;

@end
