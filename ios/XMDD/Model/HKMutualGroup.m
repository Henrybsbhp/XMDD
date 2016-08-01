//
//  HKMutualGroup.m
//  XiaoMa
//
//  Created by jt on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKMutualGroup.h"

@implementation HKMutualGroup

- (NSString *)identify
{
    return [NSString stringWithFormat:@"%@_%@", self.groupId, self.memberId];
}

@end


@implementation HKMutualCar

@end