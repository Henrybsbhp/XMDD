//
//  HKInsurace.h
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 险种
@interface SubInsurace : NSObject

///险种名称
@property (nonatomic,copy)NSString * coveragerName;

///险种金额
@property (nonatomic, strong) NSString *coveragerValue;

///保险金额
@property (nonatomic)CGFloat sum;

///保险费用
@property (nonatomic)CGFloat fee;

@end


@interface HKInsurace : NSObject

@property (nonatomic,copy)NSString * insuraceName;

/// 保险总价
@property (nonatomic)CGFloat premium;
/// 保险内容<SubInsurace>
@property (nonatomic)NSArray * subInsuraceArray;

+ (instancetype)insuraceWithJSONResponse:(NSDictionary *)rsp;

@end
