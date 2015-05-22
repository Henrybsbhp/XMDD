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
    advertisement.adPic = rsp[@"pic"];
    advertisement.adDescription = rsp[@"desc"];
    advertisement.adLink = rsp[@"link"];
    advertisement.validStart = [NSDate dateWithD14Text:[NSString stringWithFormat:@"%@",rsp[@"validstart"]]];
    advertisement.validEnd = [NSDate dateWithD14Text:[NSString stringWithFormat:@"%@",rsp[@"validend"]]];
    advertisement.weight = [rsp integerParamForName:@"weight"];
    return advertisement;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
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
    [aCoder encodeObject:self.adPic forKey:@"pic"];
    [aCoder encodeObject:self.adDescription forKey:@"desc"];
    [aCoder encodeObject:self.adLink forKey:@"link"];
    [aCoder encodeObject:[self.validStart dateFormatForDT8] forKey:@"shangpinxq"];
    [aCoder encodeObject:[self.validEnd dateFormatForDT8]forKey:@"guige"];
    [aCoder encodeFloat:self.weight forKey:@"jiage"];
}

@end
