//
//  MutualInsGroupMemberCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewCell.h"

@interface MutualInsGroupMemberCell : HKTableViewCell

@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *tipButton;
@property (nonatomic, strong) NSArray *extendInfoList;

+ (CGFloat)heightWithExtendInfoCount:(NSInteger)count;

@end
