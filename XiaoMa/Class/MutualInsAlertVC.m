//
//  MutualInsAlertView.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsAlertVC.h"
#import "CKLine.h"
#import "MutualInsConstants.h"

#define kTitleViewHeight    47
#define kContentViewWidth   286
#define kContentTitleMargin  12
#define kContentTitlePadding 6
#define kContentTitleHeight  15

@interface MutualInsAlertVC ()

@end

@implementation MutualInsAlertVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWithActionHandler:(void (^)(NSInteger, id alertVC))handler
{
    UIView *contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentViewWidth, kTitleViewHeight)];
    
    UIView *titleV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kContentViewWidth, kTitleViewHeight)];
    [contentV addSubview:titleV];

    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kContentViewWidth, kTitleViewHeight)];
    titleL.textColor = [UIColor darkTextColor];
    titleL.font = [UIFont systemFontOfSize:16];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.text = self.topTitle;
    [contentV addSubview:titleL];
    
    CKLine *topLine = [[CKLine alloc] initWithFrame:CGRectMake(0, kTitleViewHeight, kContentViewWidth, 1)];
    topLine.lineColor = MutInsLineColor;
    topLine.lineAlignment = CKLineAlignmentHorizontalTop;
    [contentV addSubview:topLine];

    CGFloat height = (kContentTitleHeight+kContentTitlePadding)*self.items.count + 2*kContentTitleMargin - kContentTitlePadding;
    UIView *titleContainerV = [[UIView alloc] initWithFrame:CGRectMake(0, kTitleViewHeight, kContentViewWidth, height)];
    [contentV addSubview:titleContainerV];

    [self addItemViewsInContainerView:titleContainerV];
    
    [contentV bringSubviewToFront:topLine];
    
    contentV.frame = CGRectMake(0, 0, kContentViewWidth, kTitleViewHeight+height);
    self.contentView = contentV;
    [super showWithActionHandler:handler];
}

- (void)addItemViewsInContainerView:(UIView *)containerV
{
    id upponView = containerV;
    for (NSInteger i=0; i<self.items.count; i++) {
        MutualInsAlertVCItem *item = self.items[i];
        UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectZero];
        leftL.textColor = MutInsTextGrayColor;
        leftL.font = [UIFont systemFontOfSize:13];
        leftL.text = item.title;
        [containerV addSubview:leftL];
        
        UILabel *rightL = [[UILabel alloc] initWithFrame:CGRectZero];
        rightL.textColor = item.detailTitleColor;
        rightL.font = [UIFont systemFontOfSize:13];
        rightL.textAlignment = NSTextAlignmentRight;
        rightL.text = item.detailTitle;
        [containerV addSubview:rightL];
        
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(containerV).offset(14);
            make.top.equalTo(upponView).offset(i==0 ? kContentTitleMargin : kContentTitlePadding);
            make.height.mas_equalTo(kContentTitleHeight);
        }];
        
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(containerV).offset(-14);
            make.left.equalTo(leftL.mas_right).offset(8).priority(MASLayoutPriorityDefaultMedium);
            make.height.mas_equalTo(kContentTitleHeight);
            make.baseline.equalTo(leftL.mas_baseline);
        }];
        upponView = leftL.mas_bottom;
    }

    UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectZero];
    leftL.textColor = MutInsTextGrayColor;
    leftL.font = [UIFont systemFontOfSize:13];
    
}

@end

@implementation MutualInsAlertVCItem

+ (instancetype)itemWithTitle:(NSString *)title detailTitle:(NSString *)detailTitle detailColor:(UIColor *)detailColor
{
    MutualInsAlertVCItem *item = [[MutualInsAlertVCItem alloc] init];
    item.title = title;
    item.detailTitle = detailTitle;
    item.detailTitleColor = detailColor;
    return item;
}

@end
