//
//  IllegalModel.h
//  XiaoMa
//
//  Created by jt on 15/11/24.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViolationCityInfo.h"

@interface ViolationModel : NSObject<NSCoding>


///车牌号码
@property (nonatomic,copy)NSString * licencenumber;
///发动机号
@property (nonatomic,copy)NSString * engineno;
///车架号
@property (nonatomic,copy)NSString * classno;
///爱车信息id
@property (nonatomic,strong)NSNumber * cid;


///违章记录数
@property (nonatomic)NSInteger violationCount;
///总扣分数
@property (nonatomic)NSInteger violationTotalfen;
///总罚款
@property (nonatomic)NSInteger violationTotalmoney;
///违章记录
@property (nonatomic,strong)NSArray * violationArray;

@property (nonatomic,strong)NSDate * queryDate;

@property (nonatomic,strong)ViolationCityInfo * cityInfo;


- (RACSignal *)rac_requestUserViolation;

- (RACSignal *)rac_getLocalUserViolation;


@end
