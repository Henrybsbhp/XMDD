//
//  HKViolation.m
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "HKViolation.h"

@implementation HKViolation

+ (instancetype)violationWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKViolation * violation = [HKViolation new];
    violation.violationDate = [NSDate dateWithUTS:rsp[@"date"]];
    violation.violationArea = rsp[@"area"];
    violation.violationAct = rsp[@"act"];
    violation.violationCode= rsp[@"code"];
    violation.violationScore = rsp[@"fen"];
    violation.violationMoney = rsp[@"money"];
    violation.ishandled = [rsp boolParamForName:@"money"];
    return violation;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init])
    {
        self.violationDate = [aDecoder decodeObjectForKey:@"violationDate"];
        self.violationArea = [aDecoder decodeObjectForKey:@"violationArea"];
        self.violationAct = [aDecoder decodeObjectForKey:@"violationAct"];
        self.violationCode = [aDecoder decodeObjectForKey:@"violationCode"];
        self.violationScore = [aDecoder decodeObjectForKey:@"violationScore"];
        self.violationMoney = [aDecoder decodeObjectForKey:@"violationMoney"];
        self.ishandled = [aDecoder decodeBoolForKey:@"ishandled"];
    }
    
    return  self;
}
//编码
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.violationDate forKey:@"violationDate"];
    [aCoder encodeObject:self.violationArea forKey:@"violationArea"];
    [aCoder encodeObject:self.violationAct forKey:@"violationAct"];
    [aCoder encodeObject:self.violationCode forKey:@"violationCode"];
    [aCoder encodeObject:self.violationScore forKey:@"violationScore"];
    [aCoder encodeObject:self.violationMoney forKey:@"violationMoney"];
    [aCoder encodeBool:self.ishandled forKey:@"ishandled"];
}



@end
