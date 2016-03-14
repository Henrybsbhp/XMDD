//
//  MutualInsGrouponCardCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"

@interface MutualInsGrouponCarsCell : HKTableViewCell

///每个cars元素都为NSDictionary，@{@"title":@"浙A12345",@"img":@"http://xxxx.png"}
@property (nonatomic, strong, readonly) NSArray *cars;
@property (nonatomic, copy) void(^carDidSelectedBlock)(NSDictionary *selectCar);

- (void)setupWithCellBounds:(CGRect)bounds;
- (void)setCars:(NSArray *)cars;

@end

