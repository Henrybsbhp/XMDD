//
//  MutualInsGroupMySimpleHeaderCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutualInsGroupMySimpleHeaderCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *tipButton;
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, assign) BOOL isTail;

+ (CGFloat)heightWithDesc:(NSString *)desc isTail:(BOOL)isTail;

@end
