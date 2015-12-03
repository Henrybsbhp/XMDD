//
//  HKViolation.h
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKViolation : NSObject<NSCoding>


///违章时间
@property (nonatomic,strong)NSDate * violationDate;

///违章地点
@property (nonatomic,copy)NSString * violationArea;

///违章行为
@property (nonatomic,copy)NSString * violationAct;

///违章代码
@property (nonatomic,copy)NSString * violationCode;

///违章扣分
@property (nonatomic,copy)NSString * violationScore;

///违章罚款
@property (nonatomic,copy)NSString * violationMoney;

///是否处理
@property (nonatomic)BOOL ishandled;

+ (instancetype)violationWithJSONResponse:(NSDictionary *)rsp;

@end
