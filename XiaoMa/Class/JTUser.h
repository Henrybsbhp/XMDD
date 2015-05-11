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
@property (nonatomic, assign) NSInteger carwashTicketsCount;
@property (nonatomic, assign) NSInteger abcCarwashesCount;
@property (nonatomic, assign) NSInteger abcIntegral;
/// 手机号码
@property (nonatomic, copy)NSString * phoneNumber;
///性别 （1-男 2-女）
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSString *numberPlate;

@property (nonatomic, strong)NSArray * carArray;

@property (nonatomic, strong)NSArray * couponArray;

@property (nonatomic,strong)UIImage * avatar;


- (HKMyCar *)getDefaultCar;

- (RACSignal *)rac_requestGetUserCar;

@end
