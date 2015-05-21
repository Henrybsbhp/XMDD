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

@implementation MyCarsModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _carsArray = [[NSArray alloc] init];
        [[self rac_requestData] subscribeNext:^(id x) {
            
        }];
    }
    return self;
}

- (RACSignal *)rac_requestData
{
    return [[[[GetUserCarOp operation] rac_postRequest] doNext:^(id x) {
        
        /// inject side effect
        NSLog(@"We are in");
    }] map:^id(GetUserCarOp * op) {
        
        // 这里需要对新返回的数据进行处理
        _carsArray = op.rsp_carArray;
        return _carsArray;
    }];
}

- (RACSignal *)rac_addCars:(HKMyCar *)car
{
    AddCarOp * op = [[AddCarOp alloc] init];
    op.req_car = car;
    
    return [[op rac_postRequest] doNext:^(AddCarOp * addOp) {
        
        // 找一下，是否已经有相应的商品了
        HKMyCar * c = [self getCarWithID:addOp.rsp_carId];
        car.carId = addOp.rsp_carId;
        
        // 如果没有，则加入汽车列表
        if (c == nil) {
            _carsArray = [_carsArray arrayByAddingObject:car];
            
            [self updateModelWithData:_carsArray];
            [self setNeedUpdateModel]; // 由于添加购物车，并无详细产品信息，因此需要设置为需要更新
        }
        else
        {
            c = car;
        }
    }];
}

- (RACSignal *)rac_updateCars:(HKMyCar *)car
{
    UpdateCarOp * op = [[UpdateCarOp alloc] init];
    op.req_car = car;
    
    return [[op rac_postRequest] doNext:^(UpdateCarOp * addOp) {
        
        // 找一下，是否已经有相应的商品了
        HKMyCar * c = [self getCarWithID:car.carId];
        
        // 如果没有，则加入汽车列表
        if (c == nil) {
            _carsArray = [_carsArray arrayByAddingObject:car];
            
            [self updateModelWithData:_carsArray];
            [self setNeedUpdateModel]; // 由于添加购物车，并无详细产品信息，因此需要设置为需要更新
        }
        else
        {
            c = car;
        }
    }];
}

- (RACSignal *)rac_removeCar:(NSNumber *)carId
{
    DeleteCarOp * op = [DeleteCarOp operation];
    op.req_carid = carId;
    
    return [[op rac_postRequest] doNext:^(DeleteCarOp * removeOp) {
        
        // 修改现有的Array
        _carsArray = [_carsArray arrayByFilteringOperator:^BOOL(HKMyCar * car) {
            return ![car.carId isEqualToNumber:carId];
        }];
        
        [self updateModelWithData:_carsArray];
    }];
}

- (HKMyCar *) getCarWithID: (NSNumber *) carId
{
    return [_carsArray firstObjectByFilteringOperator:^BOOL(HKMyCar * car){
        
        return [car.carId isEqualToNumber:carId];
    }];
}


- (HKMyCar *)getDefaultCar
{
    for (HKMyCar * car in self.carsArray)
    {
        if (car.isDefault)
        {
            return car;
        }
    }
    if (self.carsArray.count)
    {
        return [self.carsArray safetyObjectAtIndex:0];
    }
    else
    {
        return nil;
    }
}
@end
