//
//  MyCarStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarStore.h"
#import "GetUserCarOp.h"
#import "AddCarOp.h"
#import "UpdateCarOp.h"
#import "DeleteCarOp.h"

@implementation MyCarStore

- (HKStoreEvent *)getAllCars
{
    RACSignal *sig = [[[[GetUserCarOp operation] rac_postRequest] map:^id(GetUserCarOp *op) {
        JTQueue *cache = [[JTQueue alloc] init];
        for (NSInteger index = 0; index < op.rsp_carArray.count; index++) {
            HKMyCar *car = op.rsp_carArray[index];
            car.tintColorType = [self carTintColorTypeAtIndex:index];
            [cache addObject:car forKey:car.carId];
        }
        self.cache = cache;
        [self updateTimetagForKey:nil];
        return op.rsp_carArray;
    }] replayLast];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventReload object:nil];
}

- (HKStoreEvent *)getAllCarsIfNeeded
{
    if ([self needUpdateTimetagForKey:nil]) {
        return [self getAllCars];
    }
    return [HKStoreEvent eventWithSignal:[RACSignal return:[self.cache allObjects]] code:kHKStoreEventReload object:nil];
}

- (HKStoreEvent *)addCar:(HKMyCar *)car
{
    AddCarOp * op = [[AddCarOp alloc] init];
    op.req_car = car;
    RACSignal *sig = [[[op rac_postRequest] map:^(AddCarOp * addOp) {
        car.carId = addOp.rsp_carId;
        car.tintColorType = [self carTintColorTypeAtIndex:self.cache.count];
        [self.cache addObject:car forKey:car.carId];
        [self setDefaultCarIfNeeded:car];
        return car;
    }] replayLast];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventAdd object:nil];
}

- (HKStoreEvent *)updateCar:(HKMyCar *)car
{
    UpdateCarOp * op = [[UpdateCarOp alloc] init];
    op.req_car = car;
    RACSignal *sig = [[[op rac_postRequest] doNext:^(UpdateCarOp * addOp) {
        [self.cache addObject:car forKey:car.carId];
        [self setDefaultCarIfNeeded:car];
    }] replayLast];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventUpdate object:nil];
}

- (HKStoreEvent *)removeCarByID:(NSNumber *)carId
{
    DeleteCarOp * op = [DeleteCarOp operation];
    op.req_carid = carId;
    RACSignal *sig = [[[op rac_postRequest] doNext:^(DeleteCarOp * removeOp) {
        [self.cache removeObjectForKey:carId];
    }] replayLast];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventDelete object:nil];
}

- (HKStoreEvent *)getDefaultCar
{
    @weakify(self);
    RACSignal *sig = [[[self getAllCarsIfNeeded].signal map:^(id x) {
        @strongify(self);
        return [self defalutCar];
    }] replayLast];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventGet object:nil];
}

- (HKMyCar *)carByID:(NSNumber *)carId
{
    return [self.cache.allObjects firstObjectByFilteringOperator:^BOOL(HKMyCar *car) {
        return [car.carId isEqualToNumber:carId];
    }];
}

- (HKMyCar *)defalutCar
{
    NSArray *cars = self.cache.allObjects;
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
    NSArray *cars = self.cache.allObjects;
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
    return self.cache.allObjects;
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
        for (HKMyCar *curCar in self.cache.allObjects) {
            if (![curCar isEqual:car]) {
                curCar.isDefault = NO;
            }
        }
    }
}

- (HKCarTintColorType)carTintColorTypeAtIndex:(NSInteger)index
{
    HKCarTintColorType color = index % 5 + 1;
    HKMyCar *prevCar = [self.cache objectAtIndex:index-1];
    HKMyCar *nextCar = [self.cache objectAtIndex:index+1];
    if (color == prevCar.tintColorType || color == nextCar.tintColorType) {
        color = nextCar.tintColorType % 5 + 1;
    }
    return color;
}

@end
