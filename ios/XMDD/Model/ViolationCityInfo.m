//
//  ViolationCityInfo.m
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ViolationCityInfo.h"


@implementation ViolationCityInfo

+ (instancetype)cityWithJSONResponse:(NSDictionary *)rsp
{
    if (![rsp isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    ViolationCityInfo * city = [[ViolationCityInfo alloc] init];
    city.isViolationAvailable = [rsp boolParamForName:@"break_flag"];
    city.cityCode = [rsp objectForKey:@"citycode"];
    city.isEngineNum = [rsp boolParamForName:@"engine"];
    city.engineSuffixNum = [rsp integerParamForName:@"engineno"];
    city.isClassNum = [rsp boolParamForName:@"classa"];
    city.classSuffixNum = [rsp integerParamForName:@"classno"];
    return city;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init])
    {
        self.cityCode = [aDecoder decodeObjectForKey:@"cityCode"];
        self.isEngineNum = [aDecoder decodeBoolForKey:@"isEngineNum"];
        self.engineSuffixNum = [aDecoder decodeIntegerForKey:@"engineSuffixNum"];
        self.isClassNum = [aDecoder decodeBoolForKey:@"isClassNum"];
        self.classSuffixNum = [aDecoder decodeIntegerForKey:@"classSuffixNum"];
    }
    
    return  self;
}
//编码
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.cityCode forKey:@"cityCode"];
    [aCoder encodeBool:self.isEngineNum forKey:@"isEngineNum"];
    [aCoder encodeInteger:self.engineSuffixNum forKey:@"engineSuffixNum"];
    [aCoder encodeBool:self.isClassNum forKey:@"isClassNum"];
    [aCoder encodeInteger:self.classSuffixNum forKey:@"classSuffixNum"];
}


@end
