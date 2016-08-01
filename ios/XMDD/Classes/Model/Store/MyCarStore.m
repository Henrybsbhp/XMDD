//
//  MyCarStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/28.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "MyCarStore.h"
#import "GetUserCarOp.h"
#import "AddCarOp.h"
#import "UpdateCarOp.h"
#import "DeleteCarOp.h"

@implementation MyCarStore

- (void)reloadForUserChanged:(JTUser *)user
{
    self.cars = nil;
    if (user) {
        [[self getAllCars] send];
    }
}

- (CKEvent *)getAllCars
{
    CKEvent *event = [[[[[GetUserCarOp operation] rac_postRequest] map:^id(GetUserCarOp *op) {
        JTQueue *cache = [[JTQueue alloc] init];
        for (NSInteger index = 0; index < op.rsp_carArray.count; index++) {
            HKMyCar *car = op.rsp_carArray[index];
            car.tintColorType = [self carTintColorTypeAtIndex:index];
            [cache addObject:car forKey:car.carId];
        }
        self.cars = cache;
        self.defaultTip = op.rsp_tip;
        [self updateTimetagForKey:nil];
        return op.rsp_carArray;
    }] replayLast] eventWithName:@"getAllCars"];
    
    return [self inlineEvent:event forDomain:@"cars"];
}

- (CKEvent *)getAllCarsIfNeeded
{
    if ([self needUpdateTimetagForKey:nil]) {
        return [self getAllCars];
    }
    CKEvent *event = [[RACSignal return:[self.cars allObjects]] eventWithName:@"getAllCarsIfNeeded"];
    return [self inlineEvent:event forDomain:@"cars"];
}

- (CKEvent *)addCar:(HKMyCar *)car
{
    AddCarOp * op = [AddCarOp operation];
    op.req_car = car;
    CKEvent *event = [[[[op rac_postRequest] map:^(AddCarOp * addOp) {
        car.carId = addOp.rsp_carId;
        car.tintColorType = [self carTintColorTypeAtIndex:self.cars.count];
        [self.cars addObject:car forKey:car.carId];
        [self setDefaultCarIfNeeded:car];
        return car;
    }] replayLast] eventWithName:@"addCar" object:car.carId];
    
    return [self inlineEvent:event forDomain:@"cars"];
}

- (CKEvent *)updateCar:(HKMyCar *)car
{
    UpdateCarOp * op = [UpdateCarOp operation];
    op.req_car = car;
    CKEvent *event = [[[[op rac_postRequest] doNext:^(UpdateCarOp * addOp) {
        [self.cars addObject:car forKey:car.carId];
        [self setDefaultCarIfNeeded:car];
    }] replayLast] eventWithName:@"updateCar" object:car.carId];
    
    return [self inlineEvent:event forDomainList:@[@"cars", @"car"]];
}

- (CKEvent *)removeCar:(NSNumber *)carId
{
    DeleteCarOp * op = [DeleteCarOp operation];
    op.req_carid = carId;
    CKEvent *event = [[[[op rac_postRequest] doNext:^(DeleteCarOp * removeOp) {
        [self.cars removeObjectForKey:carId];
    }] replayLast] eventWithName:@"removeCar"];
    
    return [self inlineEvent:event forDomain:@"cars"];
}

- (CKEvent *)getDefaultCar
{
    @weakify(self);
    return [[self getAllCarsIfNeeded] mapSignal:^RACSignal *(RACSignal *signal) {
        return [[signal map:^id(id value) {
            @strongify(self);
            return [self defalutCar];
        }] replayLast];
    }];
}

#pragma mark - Method
- (HKMyCar *)carByID:(NSNumber *)carId
{
    return [self.cars.allObjects firstObjectByFilteringOperator:^BOOL(HKMyCar *car) {
        return [car.carId isEqualToNumber:carId];
    }];
}

- (HKMyCar *)defalutCar
{
    NSArray *cars = self.cars.allObjects;
    HKMyCar *defCar = [cars firstObjectByFilteringOperator:^BOOL(HKMyCar *car) {
        return car.isDefault;
    }];
    if (!defCar && cars.count > 0) {
        defCar = [cars safetyObjectAtIndex:0];
    }
    return defCar;
}

- (HKMyCar *)defalutInfoCompletelyCar
{
    NSArray *cars = self.cars.allObjects;
    HKMyCar *defCar = [cars firstObjectByFilteringOperator:^BOOL(HKMyCar *car) {
        return car.isDefault && [car isCarInfoCompletedForCarWash];
    }];
    if (!defCar && cars.count > 0) {
        for (HKMyCar *car in cars) {
            if ([car isCarInfoCompletedForCarWash]) {
                return car;
            }
        }
    }
    return defCar;
}

- (NSArray *)allCars
{
    return self.cars.allObjects;
}

+ (NSString *)verifiedLicenseNumberFrom:(NSString *)licenseNumber
{
    NSString *pattern = @"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵黔粤粵青藏川宁琼使][a-z][a-z0-9]{5}[警港澳领学]{0,1}$";
    //    NSString *pattern = @"^[a-z][a-z0-9]{5}[警港澳领学]{0,1}$";
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *rst = [regexp firstMatchInString:licenseNumber options:0 range:NSMakeRange(0, [licenseNumber length])];
    if (!rst) {
        return nil;
    }
    return [licenseNumber uppercaseString];
}
#pragma mark - Utility
- (void)setDefaultCarIfNeeded:(HKMyCar *)car
{
    if (car.isDefault) {
        for (HKMyCar *curCar in self.cars.allObjects) {
            if (![curCar isEqual:car]) {
                curCar.isDefault = NO;
            }
        }
    }
}

- (HKCarTintColorType)carTintColorTypeAtIndex:(NSInteger)index
{
    HKCarTintColorType color = index % 5 + 1;
    HKMyCar *prevCar = [self.cars objectAtIndex:index-1];
    HKMyCar *nextCar = [self.cars objectAtIndex:index+1];
    if (color == prevCar.tintColorType || color == nextCar.tintColorType) {
        color = nextCar.tintColorType % 5 + 1;
    }
    return color;
}

@end
