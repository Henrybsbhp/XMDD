//
//  MutualInsGrouponCardCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"
#import "MutualInsMemberInfo.h"

@interface MutualInsGrouponCarsCell : HKTableViewCell

@property (nonatomic, strong, readonly) NSArray *cars;
@property (nonatomic, copy) void(^carDidSelectedBlock)(MutualInsMemberInfo *selectCar);

- (void)setupWithCellBounds:(CGRect)bounds;
- (void)setCars:(NSArray *)cars;

@end

