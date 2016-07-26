//
//  MutualInsGroupMyDetailCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"

@interface MutualInsGroupMyDetailCell : HKTableViewCell

@property (nonatomic, strong) UILabel *feeLabel;
@property (nonatomic, strong) UILabel *feeDescLabel;
@property (nonatomic, strong) NSArray *priceTuples;
@property (nonatomic, strong) NSArray *timeTuples;
@property (nonatomic, strong) UILabel *descLabel;

+ (CGFloat)heightWithTimeTupleCount:(NSInteger)count andDesc:(NSString *)desc;

@end
