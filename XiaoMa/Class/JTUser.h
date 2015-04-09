//
//  JTUser.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    PaymentTypeCarwashTicket = 0,
    PaymentTypeABCBankCarwashTimes,
    PaymentTypeABCBankIntegral
}PaymentType;

@interface JTUser : NSObject
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *avatarUrl;
@property (nonatomic, strong) NSNumber *carwashTicketsCount;
@property (nonatomic, strong) NSNumber *abcCarwashTimesCount;
@property (nonatomic, strong) NSNumber *abcIntegral;
@property (nonatomic, strong) NSString *numberPlate;

///(listof RACTuple(paymentType, value))
- (NSArray *)paymentTypes;

@end
