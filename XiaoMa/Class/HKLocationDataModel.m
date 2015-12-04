//
//  HKLocationPicker.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "HKLocationDataModel.h"

@implementation HKLocationDataModel


@end

@implementation HKAreaInfoModel

+ (instancetype)areaWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKAreaInfoModel *area  = [HKAreaInfoModel new];
    area.infoId = [rsp integerParamForName:@"id"];
    area.infoName = [rsp stringParamForName:@"name"];
    area.infoCode = [rsp stringParamForName:@"code"];
    return area;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.infoId = [decoder decodeIntegerForKey:@"id"];
        self.infoName = [decoder decodeObjectForKey:@"name"];
        self.infoCode = [decoder decodeObjectForKey:@"code"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.infoId forKey:@"id"];
    [encoder encodeObject:self.infoName forKey:@"name"];
    [encoder encodeObject:self.infoCode forKey:@"code"];
}

@end
