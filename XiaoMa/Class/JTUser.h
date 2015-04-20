//
//  JTUser.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKMyCar.h"


@interface JTUser : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic) NSInteger carwashTicketsCount;
@property (nonatomic) NSInteger abcCarwashTimesCount;
@property (nonatomic) NSInteger abcIntegral;
@property (nonatomic, strong) NSString *numberPlate;

@property (nonatomic, strong)NSArray * carArray;

@property (nonatomic, strong)NSArray * couponArray;


- (HKMyCar *)getDefaultCar;

@end
