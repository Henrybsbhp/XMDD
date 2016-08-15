//
//  ShopListVC.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKTableViewController.h"
#import "JTTableView.h"
#import "HKCoupon.h"

extern const NSString *kCarMaintenanceShopListVCID;
extern const NSString *kCarBeautyShopListVCID;

@interface ShopListVC : HKTableViewController
@property (nonatomic, assign) ShopServiceType serviceType;
@property (nonatomic, strong) HKCoupon *coupon;
@property (nonatomic, strong) JTTableView *tableView;

- (void)actionSearch:(id)sender;
- (void)actionMap:(id)sender; 


@end
