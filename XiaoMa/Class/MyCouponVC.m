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
    
    [MobClick beginEvent:@"rp304"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endEvent:@"rp304"];
}

#pragma mark - Action
- (IBAction)actionGetMore:(id)sender
{
    [MobClick event:@"rp304-6"];
}

- (IBAction)actionSegmentChanged:(id)sender
{
    UISegmentedControl *segment = sender;
    if (segment.selectedSegmentIndex == 0) {
        [MobClick event:@"rp304-1"];
        self.usedTableView.hidden = YES;
        [self.unusedTableView reloadData];
    }
    else {
        [MobClick event:@"rp304-2"];
        self.usedTableView.hidden = NO;
        [self.usedTableView reloadData];
    }
}

@end
