//
//  MyCarStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"
#import "HKMyCar.h"

@interface MyCarStore : HKUserStore

- (CKStoreEvent *)getAllCarsIfNeeded;
- (CKStoreEvent *)getAllCars;
- (CKStoreEvent *)addCar:(HKMyCar *)car;
- (CKStoreEvent *)updateCar:(HKMyCar *)car;
- (CKStoreEvent *)removeCarByID:(NSNumber *)carId;
- (CKStoreEvent *)getDefaultCar;

- (HKMyCar *)carByID:(NSNumber *)carId;
- (HKMyCar *)defalutCar;
- (NSArray *)allCars;

+ (NSString *)verifiedLicenseNumberFrom:(NSString *)licenseNumber;


@end
