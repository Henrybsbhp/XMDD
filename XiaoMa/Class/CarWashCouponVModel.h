//
//  CarWashCouponVModel.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTTableView.h"
#import "HKLoadingModel.h"
#import "GetCouponByTypeNewV2Op.h"

@interface CarWashCouponVModel : NSObject <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, weak, readonly) UIViewController *targetVC;

- (id)initWithTableView:(JTTableView *)tableView withType:(CouponNewType)couponNewType;
- (void)resetWithTargetVC:(UIViewController *)targetVC;

@end
