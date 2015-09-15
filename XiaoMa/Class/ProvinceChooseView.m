//
//  ProvinceChooseView.m
//  XiaoMa
//
//  Created by jt on 15/9/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ProvinceChooseView.h"
#import "CollectionChooseVC.h"

@interface ProvinceChooseView ()

@end


@implementation ProvinceChooseView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _displayLb = [[UILabel alloc] init];
        _displayLb.font = [UIFont systemFontOfSize:17];
        [self addSubview:_displayLb];
        
        _staticImgV = [[UIImageView alloc] init];
        _staticImgV.image = [UIImage imageNamed:@"array_down"];
        [self addSubview:_staticImgV];
        
        [_staticImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.width.equalTo(@(9));
            make.height.equalTo(@(4));
            make.right.equalTo(self.mas_right).offset(-2);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [_displayLb mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(_staticImgV.mas_right).offset(-13);
        }];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
}


@end
