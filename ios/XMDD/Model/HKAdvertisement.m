//
//  HKAdvertisement.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKAdvertisement.h"

@implementation HKAdvertisement

+ (instancetype)adWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKAdvertisement * advertisement = [[HKAdvertisement alloc] init];
    advertisement.adId = [rsp numberParamForName:@"pid"];
    advertisement.adPic = rsp[@"pic"];
    advertisement.adDescription = rsp[@"desc"];
    advertisement.adLink = rsp[@"link"];
    advertisement.validStart = [NSDate dateWithD14Text:[NSString stringWithFormat:@"%@",rsp[@"validstart"]]];
    advertisement.validEnd = [NSDate dateWithD14Text:[NSString stringWithFormat:@"%@",rsp[@"validend"]]];
    advertisement.weight = [rsp integerParamForName:@"weight"];
    NSString *link = rsp[@"link"];
    advertisement.adLink = [link stringByReplacingOccurrencesOfString:@"jump=f" withString:@"jump=t"];
    return advertisement;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.adId = [aDecoder decodeObjectForKey:@"pid"];
        self.adPic = [aDecoder decodeObjectForKey:@"pic"];
        self.adDescription = [aDecoder decodeObjectForKey:@"desc"];
        self.adLink = [aDecoder decodeObjectForKey:@"link"];
        self.validStart = [NSDate dateWithD8Text:[aDecoder decodeObjectForKey:@"validstart"]];
        self.validEnd = [NSDate dateWithD8Text:[aDecoder decodeObjectForKey:@"validend"]];
        self.weight = [aDecoder decodeIntegerForKey:@"weight"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.adId forKey:@"pid"];
    [aCoder encodeObject:self.adPic forKey:@"pic"];
    [aCoder encodeObject:self.adDescription forKey:@"desc"];
    [aCoder encodeObject:self.adLink forKey:@"link"];
    [aCoder encodeObject:[self.validStart dateFormatForDT8] forKey:@"validstart"];
    [aCoder encodeObject:[self.validEnd dateFormatForDT8]forKey:@"validend"];
    [aCoder encodeFloat:self.weight forKey:@"jiage"];
}

@end
