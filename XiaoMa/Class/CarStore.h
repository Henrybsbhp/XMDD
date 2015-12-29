//
//  MyCarStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"
#import "HKMyCar.h"

@interface CarStore : HKUserStore

- (HKStoreEvent *)getAllCarsIfNeeded;
- (HKStoreEvent *)getAllCars;
- (HKStoreEvent *)addCar:(HKMyCar *)car;
- (HKStoreEvent *)updateCar:(HKMyCar *)car;
- (HKStoreEvent *)removeCarByID:(NSNumber *)carId;
- (HKStoreEvent *)getDefaultCar;

- (HKMyCar *)carByID:(NSNumber *)carId;
- (HKMyCar *)defalutCar;
- (HKMyCar *)defalutInfoCompletelyCar;
- (NSArray *)allCars;

+ (NSString *)verifiedLicenseNumberFrom:(NSString *)licenseNumber;


@end
