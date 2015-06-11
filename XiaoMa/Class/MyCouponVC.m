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
#import "WebVC.h"

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
    
    [MobClick beginLogPageView:@"rp304"];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"rp304"];
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
}

#pragma mark - Action
- (IBAction)actionGetMore:(id)sender
{
    [MobClick event:@"rp304-6"];
    WebVC *vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
    vc.url = @"http://www.xiaomadada.com/apphtml/couponpkg.html";
    [self.navigationController pushViewController:vc animated:YES];
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
