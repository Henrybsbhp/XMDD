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
    car.carId = [rsp numberParamForName:@"carid"];
    car.licencenumber= [[rsp stringParamForName:@"licencenumber"] uppercaseString];
    car.purchasedate = [NSDate dateWithD8Text:[rsp stringParamForName:@"purchasedate"]];
    car.brand = [rsp stringParamForName:@"make"];
    car.model = [rsp stringParamForName:@"model"];
    car.price = [rsp floatParamForName:@"price"];
    car.odo = [rsp integerParamForName:@"odo"];
    car.inscomp = [rsp stringParamForName:@"inscomp"];
    car.status = [rsp integerParamForName:@"status"];
    car.insexipiredate = [NSDate dateWithD8Text:[rsp stringParamForName:@"insexipiredate"]];
    car.licenceurl = [rsp stringParamForName:@"licenceurl"];
    car.isDefault = [rsp integerParamForName:@"isdefault"] == 1;
    return car;
}

- (NSDictionary *)jsonDictForCarInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict safetySetObject:[self.licencenumber uppercaseString] forKey:@"licencenumber"];
    [dict safetySetObject:[self.purchasedate dateFormatForDT8] forKey:@"purchasedate"];
    [dict safetySetObject:self.brand forKey:@"make"];
    [dict safetySetObject:self.model forKey:@"model"];
    [dict safetySetObject:[NSString stringWithFormat:@"%.2f", self.price] forKey:@"price"];
    [dict safetySetObject:@(self.odo) forKey:@"odo"];
    [dict safetySetObject:self.inscomp forKey:@"inscomp"];
    [dict safetySetObject:[self.insexipiredate dateFormatForDT8] forKey:@"insexipiredate"];
    [dict safetySetObject:self.licenceurl forKey:@"licenceurl"];
    [dict safetySetObject:@(self.isDefault ? 1 : 2) forKey:@"isdefault"];
    return dict;
}

- (id)copyWithZone:(NSZone *)zone
{
    HKMyCar *car = [[HKMyCar allocWithZone:zone] init];
    car.carId = _carId;
    car.licencenumber = _licencenumber;
    car.licenceurl = _licenceurl;
    car.purchasedate = _purchasedate;
    car.brand = _brand;
    car.model = _model;
    car.price = _price;
    car.odo = _odo;
    car.inscomp = _inscomp;
    car.insexipiredate = _insexipiredate;
    car.isDefault = _isDefault;
    car.status  =_status;
    return car;
}

- (BOOL)isCarInfoCompleted
{
    if (self.carId && self.licencenumber.length > 0 && self.purchasedate && self.brand.length > 0 && self.model.length > 0) {
        return YES;
    }
    return NO;
}
@end
