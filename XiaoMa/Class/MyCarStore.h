//
//  MyCarStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/28.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "UserStore.h"
#import "HKMyCar.h"
#import "JTQueue.h"

@interface MyCarStore : UserStore
@property (nonatomic, strong) JTQueue *cars;

- (CKEvent *)getAllCarsIfNeeded;
- (CKEvent *)getAllCars;
- (CKEvent *)addCar:(HKMyCar *)car;
- (CKEvent *)updateCar:(HKMyCar *)car;
- (CKEvent *)removeCar:(NSNumber *)carId;
- (CKEvent *)getDefaultCar;

- (HKMyCar *)carByID:(NSNumber *)carId;
- (HKMyCar *)defalutCar;
- (HKMyCar *)defalutInfoCompletelyCar;
- (NSArray *)allCars;

+ (NSString *)verifiedLicenseNumberFrom:(NSString *)licenseNumber;
@end
