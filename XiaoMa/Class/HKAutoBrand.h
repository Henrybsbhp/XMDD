//
//  HKAutoBrand.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAutoBrand : NSObject

@property (nonatomic, strong) NSNumber *brandid;
@property (nonatomic, strong) NSString *name;
///品牌首字母
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, assign) long long timetag;

+ (instancetype)autoBrandWithJSONResponse:(NSDictionary *)rsp;

@end
