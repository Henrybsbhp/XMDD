//
//  GasPickAmountCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKTableViewCell.h"
#import "PKYStepper.h"
#import "RTLabel.h"

@interface GasPickAmountCell : HKTableViewCell
@property (nonatomic, strong) PKYStepper *stepper;
@property (nonatomic, strong) RTLabel *richLabel;
- (CGFloat)cellHeight;

@end
