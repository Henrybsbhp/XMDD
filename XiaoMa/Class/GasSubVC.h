//
//  GasSubVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKDatasource.h"
#import "RTLabel.h"

@interface GasSubVC : NSObject <UITableViewDataSource, UITableViewDelegate, RTLabelDelegate>
@property (nonatomic, weak, readonly) UIViewController *targetVC;
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UIButton *bottomBtn;
@property (nonatomic, weak, readonly) UIView *bottomView;

@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, assign) float rechargeAmount;

#pragma mark - Override
- (instancetype)initWithTargetVC:(UIViewController *)vc tableView:(UITableView *)table
                    bottomButton:(UIButton *)btn bottomView:(UIView *)bottomView;
//重新请求数据源
- (void)reloadData;
//判断当前是否需要重新加载数据源，如果需要刷新，将会调用'refreshViewWithForce:'方法
- (BOOL)reloadDataIfNeeded;
//支付
- (void)actionPay;
//刷新底部支付按钮
- (void)reloadBottomButton;

#pragma mark - Public
- (void)refreshViewWithForce:(BOOL)force;
- (void)reloadFromSignal:(RACSignal *)signal;

@end
