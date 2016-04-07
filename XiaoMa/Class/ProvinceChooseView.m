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
        _displayLb = [[UILabel alloc] initWithFrame:CGRectZero];
        _displayLb.font = [UIFont systemFontOfSize:17];
        _displayLb.textColor = HEXCOLOR(@"#18D06A");
        _displayLb.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_displayLb];
        
        _staticImgV = [[UIImageView alloc] init];
        _staticImgV.image = [UIImage imageNamed:@"mec_arrow"];
        [self addSubview:_staticImgV];
        
        @weakify(self);
        [_staticImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            
            @strongify(self);
            make.width.equalTo(@(11));
            make.height.equalTo(@(5));
            make.right.equalTo(self.mas_right).offset(-8);
            make.centerY.equalTo(self.mas_centerY);
        }];

        [_displayLb mas_makeConstraints:^(MASConstraintMaker *make) {
           
            @strongify(self);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.left.equalTo(self).offset(8);
            make.right.equalTo(self.staticImgV.mas_left).offset(-5);
        }];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
}


@end
