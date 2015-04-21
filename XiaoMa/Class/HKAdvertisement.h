//
//  HKAdvertisement.h
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAdvertisement : NSObject<NSCoding>

///广告图片
@property (nonatomic,copy)NSString * adPic;

///文字描述
@property (nonatomic,copy)NSString * adDescription;

///链接地址
@property (nonatomic,copy)NSString * adLink;

///有效时间开始
@property (nonatomic,strong)NSDate * validStart;

///有效时间结束
@property (nonatomic,strong)NSDate * validEnd;

///权重，值越大，则越靠前
@property (nonatomic)NSInteger weight;

+ (instancetype)adWithJSONResponse:(NSDictionary *)rsp;

@end
