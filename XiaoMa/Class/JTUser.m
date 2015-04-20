//
//  JTUser.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTUser.h"
#import "XiaoMa.h"

@implementation JTUser

- (HKMyCar *)getDefaultCar
{
    for (HKMyCar * car in self.carArray)
    {
        if (car.isDefault)
        {
            return car;
        }
    }
    if (self.carArray.count)
    {
        return [self.carArray safetyObjectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

@end

