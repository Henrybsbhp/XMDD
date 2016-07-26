//
//  MutualInsGroupFundCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientView.h"

@interface MutualInsGroupFundCell : UITableViewCell

@property (nonatomic, strong) GradientView *progressView;
@property (nonatomic, strong) NSArray *tupleInfoList;
@property (nonatomic, strong) UILabel *descLabel;

+ (CGFloat)heightWithTupleInfoCount:(NSInteger)count andDesc:(NSString *)desc;

@end
