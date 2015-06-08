//
//  MyCarsModel.m
//  XiaoMa
//
//  Created by jt on 15-5-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyCarsModel.h"
#import "GetUserCarOp.h"
#import "DeleteCarOp.h"
#import "AddCarOp.h"
#import "UpdateCarOp.h"
#import "CKSegmentHelper.h"

@interface MyCarsModel ()
@property (nonatomic, strong) CKSegmentHelper *segHelper;
@end
@implementation MyCarsModel

#pragma mark - Override
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[self rac_fetchData] subscribeNext:^(id x) {
            
        }];
    }
    
    return self;
}
- (JTQueue *)carCache
{
    return self.cache;
}

- (NSArray *)carArray
{
    return [[self carCache] allObjects];
}

- (RACSignal *)rac_requestData
{
    return [[[GetUserCarOp operation] rac_postRequest] map:^id(GetUserCarOp *op) {
        JTQueue *queue = [[JTQueue alloc] init];
        for (HKMyCar *car in op.rsp_carArray) {
            [queue addObject:car forKey:car.carId];
        }
        return queue;
    }];
}

- (RACSignal *)rac_addCar:(HKMyCar *)car
{
    AddCarOp * op = [[AddCarOp alloc] init];
    op.req_car = car;
    
    return [[op rac_postRequest] doNext:^(AddCarOp * addOp) {
        car.carId = addOp.rsp_carId;
        [[self carCache] addObject:car forKey:car.carId];
        [self setDefaultCarIfNeeded:car];
        [self updateCache:[self carCache] refreshTime:NO];
    }];
}

- (RACSignal *)rac_updateCar:(HKMyCar *)car
{
    UpdateCarOp * op = [[UpdateCarOp alloc] init];
    op.req_car = car;
    
    return [[op rac_postRequest] doNext:^(UpdateCarOp * addOp) {
        [[self carCache] addObject:car forKey:car.carId];
        [self setDefaultCarIfNeeded:car];
        [self updateCache:[self carCache] refreshTime:NO];
    }];
}

- (RACSignal *)rac_removeCarByID:(NSNumber *)carId
{
    DeleteCarOp * op = [DeleteCarOp operation];
    op.req_carid = carId;
    
    return [[op rac_postRequest] doNext:^(DeleteCarOp * removeOp) {

        [[self carCache] removeObjectForKey:carId];
        [self updateCache:[self carCache] refreshTime:NO];
    }];
}

- (HKMyCar *)getCarByID:(NSNumber *)carId
{
    return [self.carArray firstObjectByFilteringOperator:^BOOL(HKMyCar *car) {
        return [car.carId isEqualToNumber:carId];
    }];
}

- (RACSignal *)rac_getDefaultCar
{
    @weakify(self);
    return [[self rac_fetchDataIfNeeded] map:^(id x) {
        @strongify(self);
        return [self getDefalutCar];
    }];
}

- (HKMyCar *)getDefalutCar
{
    NSArray *cars = self.carArray;
    HKMyCar *defCar = [cars firstObjectByFilteringOperator:^BOOL(HKMyCar *car) {
        return car.isDefault;
    }];
    if (!defCar && cars.count > 0) {
        defCar = [cars safetyObjectAtIndex:0];
    }
    return defCar;
}

- (void)setDefaultCarIfNeeded:(HKMyCar *)car
{
    if (car.isDefault) {
        for (HKMyCar *curCar in [self carArray]) {
            if (![curCar isEqual:car]) {
                curCar.isDefault = NO;
            }
        }
    }
}

+ (NSString *)verifiedLicenseNumberFrom:(NSString *)licenseNumber
{
    NSString *pattern = @"^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵黔粵青藏川宁琼使][a-z][a-z0-9]{5}[警港澳领学]{0,1}$";
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *rst = [regexp firstMatchInString:licenseNumber options:0 range:NSMakeRange(0, [licenseNumber length])];
    if (!rst) {
        return nil;
    }
    return [licenseNumber uppercaseString];
}

@end
