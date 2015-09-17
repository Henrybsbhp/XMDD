//
//  DrivingLicenseThumbCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DrivingLicenseThumbCell.h"

@implementation DrivingLicenseThumbCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *contentView = self.contentView;
        contentView.layer.borderColor = [HEXCOLOR(@"#22a022") CGColor];
        contentView.layer.masksToBounds  = YES;
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageV.tag = 1001;
        [contentView addSubview:imageV];
        
        UIView *bottomV = [[UIView alloc] initWithFrame:CGRectZero];
        bottomV.tag = 1002;
        bottomV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [contentView addSubview:bottomV];
        
        UILabel *titleV = [[UILabel alloc] initWithFrame:CGRectZero];
        titleV.tag = 1003;
        titleV.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        titleV.backgroundColor = [UIColor clearColor];
        titleV.font = [UIFont systemFontOfSize:13];
        [bottomV addSubview:titleV];
        
        UIImageView *checkV = [[UIImageView alloc] initWithFrame:CGRectZero];
        checkV.tag = 1004;
        checkV.image = [UIImage imageNamed:@"insu_ok"];
        [contentView addSubview:checkV];
        
        UIButton *deleteB = [[UIButton alloc] initWithFrame:CGRectZero];
        deleteB.tag = 1005;
        [deleteB setImage:[UIImage imageNamed:@"insu_delete"] forState:UIControlStateNormal];
        [deleteB setImageEdgeInsets:UIEdgeInsetsMake(-8, 5, 0, 0)];
        [contentView addSubview:deleteB];
        
        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(contentView);
        }];
        
        [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.height.mas_equalTo(20);
            make.left.equalTo(contentView);
            make.right.equalTo(contentView);
            make.bottom.equalTo(contentView);
        }];
        
        [titleV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(bottomV).offset(5);
            make.right.equalTo(bottomV).offset(-10);
            make.top.equalTo(bottomV);
            make.bottom.equalTo(bottomV);
        }];
        
        [checkV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(bottomV.mas_right).offset(-5);
            make.centerY.equalTo(bottomV.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        [deleteB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(contentView);
            make.top.equalTo(contentView);
            make.size.mas_equalTo(CGSizeMake(30, 30));
        }];
    }
 
    return self;
}

@end
