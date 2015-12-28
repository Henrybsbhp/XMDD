//
//  CarWashTableVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKLoadingModel.h"

@class HKCoupon;

@interface CarWashTableVC : UIViewController<UITableViewDataSource, UITableViewDelegate, HKLoadingModelDelegate>

@property (nonatomic)NSInteger type;
@property (strong, nonatomic) IBOutlet JTTableView *carwashTableView;
@property (strong, nonatomic) IBOutlet JTTableView *withheartTableView;
@property (weak, nonatomic) IBOutlet UIView *carwashHeaderView;
@property (weak, nonatomic) IBOutlet UIView *withHeartHeaderView;
@property (nonatomic, strong) HKLoadingModel *carwashLoadingModel;
@property (nonatomic, strong) HKLoadingModel *withheartLoadingModel;

@property (nonatomic, strong)HKCoupon * couponForWashDic;

@end
