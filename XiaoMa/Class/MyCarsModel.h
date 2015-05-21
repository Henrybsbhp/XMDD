//
//  MyCarsModel.h
//  XiaoMa
//
//  Created by jt on 15-5-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseModel.h"
#import "HKMyCar.h"

@interface MyCarsModel : BaseModel

@property (nonatomic, readonly, getter=getFavoritesArray) NSArray * carsArray;


- (RACSignal *)rac_addCars: (HKMyCar *) car;
- (RACSignal *)rac_updateCars:(HKMyCar *)car;
- (RACSignal *)rac_removeCar: (NSNumber *) carId;
- (HKMyCar *) getCarWithID: (NSNumber *) carId;

- (HKMyCar *)getDefaultCar;

@end
