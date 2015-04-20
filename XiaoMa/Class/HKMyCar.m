//
//  HKMyCar.m
//  XiaoMa
//
//  Created by jt on 15-4-17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKMyCar.h"
#import "NSDate+DateForText.h"

@implementation HKMyCar

+ (instancetype)carWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKMyCar * car = [[HKMyCar alloc] init];
    car.licencenumber= rsp[@"licencenumber"];
    car.purchasedate = [NSDate dateWithD8Text:[NSString stringWithFormat:@"%@",rsp[@"purchasedate"]]];;
    car.brand = rsp[@"make"];
    car.model = rsp[@"model"];
    car.price = [rsp floatParamForName:@"price"];
    car.odo = [rsp integerParamForName:@"odo"];
    car.inscomp = rsp[@"valid"];
    car.insexipiredate = [NSDate dateWithD8Text:[NSString stringWithFormat:@"%@",rsp[@"insexipiredate"]]];
    car.isDefault = [rsp boolParamForName:@"isdefault"];
    return car;
}


@end
