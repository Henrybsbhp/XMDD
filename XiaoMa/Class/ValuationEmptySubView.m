//
//  ValuationEmptySubView.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ValuationEmptySubView.h"

@interface ValuationEmptySubView ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *contentArray;

@end

@implementation ValuationEmptySubView

- (void)dealloc
{
    DebugLog(@"ValuationEmptySubView dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEmptyView];
}

- (void)setEmptyView
{
    UIButton * addCarButton = [[UIButton alloc] init];
    [addCarButton setImage:[UIImage imageNamed:@"illegal_add_300"] forState:UIControlStateNormal];
    @weakify(self);
    [[addCarButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (self.addCarClickBlock) {
            self.addCarClickBlock();
        }
    }];
    [self.view addSubview:addCarButton];
    
    UILabel * label = [[UILabel alloc] init];
    label.text = @"点击添加您需要评估的车辆";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = kDefTintColor;
    [self.view addSubview:label];
    
    [addCarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY).offset(-20);
        make.width.mas_equalTo(47);
        make.height.mas_equalTo(47);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(addCarButton.mas_bottom).offset(20);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

@end
