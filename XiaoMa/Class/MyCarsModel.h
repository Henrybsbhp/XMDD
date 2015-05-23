//
//  MyCarsModel.h
//  XiaoMa
//
//  Created by jt on 15-5-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CacheModel.h"
#import "HKMyCar.h"
#import "JTQueue.h"

///CacheData为JTQueue对象
@interface MyCarsModel : CacheModel


- (RACSignal *)rac_addCar:(HKMyCar *)car;
- (RACSignal *)rac_updateCar:(HKMyCar *)car;
- (RACSignal *)rac_removeCarByID:(NSNumber *)carId;
- (HKMyCar *) getCarByID:(NSNumber *)carId;

- (RACSignal *)rac_getDefaultCar;
- (HKMyCar *)getDefalutCar;
- (NSArray *)carArray;

@end
