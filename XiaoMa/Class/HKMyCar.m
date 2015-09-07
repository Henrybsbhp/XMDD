//
//  HKMyCar.m
//  XiaoMa
//
//  Created by jt on 15-4-17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKMyCar.h"
#import "NSDate+DateForText.h"
#import "NSString+Safe.h"

@implementation HKMyCar

- (instancetype)init
{
    self = [super init];
    if (self) {
        _editMask = HKCarEditableAll;
    }
    return self;
}

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
    NSInteger editable = [rsp integerParamForName:@"iseditable"];
    if (editable == 0) {
        car.editMask = HKCarEditableAll;
    }
    else if (editable == 1) {
        car.editMask = HKCarEditableDelete;
    }
    else if (editable == 2) {
        car.editMask = HKCarEditableNone;
    }
    else if (editable == 3) {
        car.editMask = HKCarEditableEdit;
    }
    
    car.licenceArea = [car.licencenumber safteySubstringToIndexIndex:1];
    car.licenceSuffix = [car.licencenumber safteySubstringFromIndex:1];
    return car;
}

- (NSDictionary *)jsonDictForCarInfo
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    self.licencenumber = [NSString stringWithFormat:@"%@%@",[NSString stringNotNullFrom:self.licenceArea],[NSString stringNotNullFrom:self.licenceSuffix]];
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
    car.editMask = _editMask;
    car.licenceArea = _licenceArea;
    car.licenceSuffix = _licenceSuffix;
    return car;
}

- (BOOL)isCarInfoCompleted
{
    if (self.carId && self.licencenumber.length > 0 && self.purchasedate && self.brand.length > 0 && self.model.length > 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isDifferentFromAnother:(HKMyCar *)another
{
    if (![self.carId isEqualToNumber:another.carId]) {
        return YES;
    }
    if (![self isEqualWithString1:self.licencenumber string2:another.licencenumber]) {
        return YES;
    }
    if (![self isEqualWithDate1:self.purchasedate date2:another.purchasedate]) {
        return YES;
    }
    if (![self isEqualWithString1:self.brand string2:another.brand]) {
        return YES;
    }
    if (![self isEqualWithString1:self.model string2:another.model]) {
        return YES;
    }
    if (self.price != another.price) {
        return YES;
    }
    if (self.odo != another.odo) {
        return YES;
    }
    if (self.status != another.status) {
        return YES;
    }
    if (![self isEqualWithString1:self.inscomp string2:another.inscomp]) {
        return YES;
    }
    if (![self isEqualWithString1:self.licenceurl string2:another.licenceurl]) {
        return YES;
    }
    if (![self isEqualWithDate1:self.insexipiredate date2:another.insexipiredate]) {
        return YES;
    }
    if (self.isDefault != another.isDefault) {
        return YES;
    }
    if (self.editMask != another.editMask) {
        return YES;
    }
    return NO;
}

- (NSString *)carSeriesDesc
{
    NSString *desc = self.brand;
    if (desc) {
        desc = [self.model hasPrefix:desc] ? self.model : [desc append:self.model];
    }
    else {
        desc = self.model;
    }
    return desc;
}

#pragma mark - Private
- (BOOL)isEqualWithDate1:(NSDate *)date1 date2:(NSDate *)date2
{
    if (!date1) {
        return !date2;
    }
    return [date1 isEqualToDate:date2];
}

- (BOOL)isEqualWithString1:(NSString *)str1 string2:(NSString *)str2
{
    if (!str1) {
        return str2.length == 0;
    }
    else if (!str2) {
        return str1.length == 0;
    }
    return [str1 isEqualToString:str2];
}
@end

