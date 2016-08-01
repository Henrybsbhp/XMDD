//
//  CarListSubVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CarListSubVC.h"
#import "NSString+Format.h"

@interface CarListSubVC ()

@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) NSArray *contentArray;

@end

@implementation CarListSubVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDataSource];
    
    [self setCarSubView];
}

- (void)setDataSource
{
    self.titleArray = @[@"品牌车系", @"具体车型", @"购车时间",
                        @"行驶城市", @"车架号码", @"发动机号",
                        @"整车价格", @"当前里程"];
    NSString *brandAndSeries = [NSString stringWithFormat:@"%@ %@", self.car.brand, self.car.seriesModel.seriesname];
    NSString *modelName = [NSString stringWithFormat:@"%@", self.car.detailModel.modelname];
    NSString *purchaseDate = [NSString stringWithFormat:@"%@", [self.car.purchasedate dateFormatForYYMM] ?: @""];
    NSString *cityName = self.car.cityName ? self.car.cityName : @"";
    NSString *classNo = self.car.classno ? self.car.classno : @"";
    NSString *engineNo = self.car.engineno ? self.car.engineno : @"";
    NSString *priceStr = [NSString stringWithFormat:@"%@万元", [NSString formatForRoundPrice:self.car.price]];
    NSString *odoStr = [NSString stringWithFormat:@"%@万公里", [NSString formatForRoundPrice:self.car.odo/10000.00]];
    
    self.contentArray = @[brandAndSeries, modelName, purchaseDate,
                          cityName, classNo, engineNo,
                          priceStr, odoStr];
}

- (void)setCarSubView
{
    for (int i = 0; i < self.titleArray.count; i ++) {
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = self.titleArray[i];
        titleLabel.textColor = kGrayTextColor;
        titleLabel.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:titleLabel];
        
        UILabel *contentLabel = [UILabel new];
        contentLabel.text = self.contentArray[i];
        contentLabel.textColor = kDarkTextColor;
        contentLabel.font = [UIFont systemFontOfSize:15];
        contentLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:contentLabel];
        
        
        CGFloat top = 20 * (2 * i + 1);
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(top);
            make.left.equalTo(self.view).offset(20);
            make.width.mas_equalTo(66);
        }];
        [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel);
            make.left.equalTo(titleLabel.mas_right);
            make.right.equalTo(self.view).offset(-20);
        }];
    }
}

@end
