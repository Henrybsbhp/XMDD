//
//  JTUser.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKMyCar.h"
#import "CouponModel.h"


@interface JTUser : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *avatarUrl;
/// 手机号码
@property (nonatomic, copy)NSString * phoneNumber;
///性别 （1-男 2-女）
@property (nonatomic, assign)NSInteger sex;
@property (nonatomic, strong)NSDate *birthday;
///车牌
@property (nonatomic, strong)NSString *numberPlate;
/// 爱车
@property (nonatomic, strong)NSArray * carArray;
/// 头像
//@property (nonatomic,strong)UIImage * avatar;

#pragma mark - Status
///有新消息
@property (nonatomic, assign) BOOL hasNewMsg;

@end
