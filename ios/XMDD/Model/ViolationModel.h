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

@property (nonatomic,strong)ViolationCityInfo * cityInfo;


///违章记录数
@property (nonatomic)NSInteger violationCount;
///总扣分数
@property (nonatomic)NSInteger violationTotalfen;
///总罚款
@property (nonatomic)NSInteger violationTotalmoney;
///违章记录
@property (nonatomic,strong)NSArray * violationArray;

@property (nonatomic,strong)NSDate * queryDate;

///违章可处理个数
@property (nonatomic,copy)NSString * violationAvailableTip;

/// 通过车牌信息获取城市信息
- (RACSignal *)rac_getCityInfoByLincenseNumber;

/// 获取车辆违章信息
- (RACSignal *)rac_requestUserViolation;

/// 获取车辆本地违章信息
- (RACSignal *)rac_getLocalUserViolation;


@end
