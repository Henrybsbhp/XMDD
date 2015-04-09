//
//  Shop.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTShopService : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *oldPrice;
@property (nonatomic, strong) NSNumber *curPrice;
@property (nonatomic, strong) NSNumber *abcIntegral;
@property (nonatomic, strong) NSString *intro;
@end

@interface JTShopComment : NSObject
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *content;
@end

@interface JTShop : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *logoUrl;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *openTime;
@property (nonatomic, strong) NSString *closeTime;
@property (nonatomic, strong) NSNumber *distance;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSArray *services;
@property (nonatomic, strong) NSArray *comments;
///允许使用优惠券
@property (nonatomic, strong) NSNumber *allowTicket;
///允许使用农行卡
@property (nonatomic, strong) NSNumber *allowABC;
@end
