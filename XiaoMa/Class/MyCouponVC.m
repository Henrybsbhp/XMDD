//
//  MyCouponVC.m
//  XiaoMa
//
//  Created by Yawei Liu on 15/5/8.
//  Copyright (c) 2015年 Hangzhou Huika Tech.. All rights reserved.
//

#import "MyCouponVC.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "GetUserCouponOp.h"
#import "HKCoupon.h"
#import "JTTableView.h"
#import "ShareUserCouponOp.h"
#import "SocialShareViewController.h"
#import "DownloadOp.h"
#import "NSDate+DateForText.h"
#import "UsedCouponVModel.h"
#import "UnusedCouponVModel.h"

@interface MyCouponVC ()

@property (weak, nonatomic) IBOutlet JTTableView *usedTableView;
@property (weak, nonatomic) IBOutlet JTTableView *unusedTableView;
@property (nonatomic, strong) UsedCouponVModel *usedModel;
@property (nonatomic, strong) UnusedCouponVModel *unusedModel;


@end

@implementation MyCouponVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usedModel = [[UsedCouponVModel alloc] initWithTableView:self.usedTableView];
    self.unusedModel = [[UnusedCouponVModel alloc] initWithTableView:self.unusedTableView];
    [self.unusedModel reloadData];
    [self.usedModel reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Action
- (IBAction)actionGetMore:(id)sender
{
}

- (IBAction)actionSegmentChanged:(id)sender
{
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex == 0) {
        self.usedTableView.hidden = YES;
        [self.unusedTableView reloadData];
    }
    else {
        self.usedTableView.hidden = NO;
        [self.usedTableView reloadData];
    }
}

@end
