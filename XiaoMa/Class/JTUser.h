//
//  JTUser.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKMyCar.h"
#import "FavoriteModel.h"
#import "MyCarsModel.h"


@interface JTUser : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *avatarUrl;
/// 手机号码
@property (nonatomic, copy)NSString * phoneNumber;
///性别 （1-男 2-女）
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, strong) NSDate *birthday;
///车牌
@property (nonatomic, strong) NSString *numberPlate;
/// 爱车
@property (nonatomic, strong)NSArray * carArray;
/// 头像
//@property (nonatomic,strong)UIImage * avatar;

///洗车次数
@property (nonatomic, assign) NSInteger abcCarwashesCount;
///积分
@property (nonatomic, assign) NSInteger abcIntegral;
/// 可用洗车券
@property (nonatomic, strong)NSArray * validCarwashCouponArray;
/// 可用现金券
@property (nonatomic, strong)NSArray * validCashCouponArray;
/// 所有优惠劵
@property (nonatomic, strong)NSArray * carwashArray;

/// 收藏夹
@property (nonatomic, strong) FavoriteModel * favorites;

@property (nonatomic, strong)MyCarsModel * carModel;

@end
