//
//  MyCouponVC.m
//  XiaoMa
//
//  Created by Yawei Liu on 15/5/8.
//  Copyright (c) 2015年 Hangzhou Huika Tech.. All rights reserved.
//

#import "MyCouponVC.h"
#import "UIBarButtonItem+CustomStyle.h"
#import "JTTableView.h"
#import "ShareUserCouponOp.h"
#import "DownloadOp.h"
#import "NSDate+DateForText.h"
#import "CarWashCouponVModel.h"
#import "UnusedCouponVModel.h"

@interface MyCouponVC ()

@property (weak, nonatomic) IBOutlet JTTableView *carwashTableView;
@property (weak, nonatomic) IBOutlet JTTableView *gasTableView;
@property (weak, nonatomic) IBOutlet JTTableView *insuranceTableView;
@property (weak, nonatomic) IBOutlet JTTableView *othersTableView;
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIButton *carwashBtn;
@property (weak, nonatomic) IBOutlet UIView *carwashline;
@property (weak, nonatomic) IBOutlet UIButton *gasBtn;
@property (weak, nonatomic) IBOutlet UIView *gasLine;
@property (weak, nonatomic) IBOutlet UIButton *insuranceBtn;
@property (weak, nonatomic) IBOutlet UIView *insuranceline;
@property (weak, nonatomic) IBOutlet UIButton *othersBtn;
@property (weak, nonatomic) IBOutlet UIView *othersline;
@property (nonatomic, strong) CKSegmentHelper *segHelper;


@property (nonatomic, strong) CarWashCouponVModel *carWashModel;
@property (nonatomic, strong) CarWashCouponVModel *gasModel;
@property (nonatomic, strong) CarWashCouponVModel *insuranceModel;
@property (nonatomic, strong) CarWashCouponVModel *othersModel;


@end

@implementation MyCouponVC

- (void)dealloc
{
    DebugLog(@"MyCouponVC dealloc!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self setSegmentView];
    
    if (self.jumpType == CouponNewTypeGas) {
        [self.segHelper selectItem:self.gasBtn];
    }
    else if (self.jumpType == CouponNewTypeInsurance) {
        [self.segHelper selectItem:self.insuranceBtn];
    }
    else if (self.jumpType == CouponNewTypeOthers) {
        [self.segHelper selectItem:self.othersBtn];
    }
    else {
        [self.segHelper selectItem:self.carwashBtn];
    }
    
    self.carWashModel = [[CarWashCouponVModel alloc] initWithTableView:self.carwashTableView withType:CouponNewTypeCarWash];
    [self.carWashModel resetWithTargetVC:self];
    
    self.gasModel = [[CarWashCouponVModel alloc] initWithTableView:self.gasTableView withType:CouponNewTypeGas];
    [self.gasModel resetWithTargetVC:self];
    
    self.insuranceModel = [[CarWashCouponVModel alloc] initWithTableView:self.insuranceTableView withType:CouponNewTypeInsurance];
    [self.insuranceModel resetWithTargetVC:self];
    
    self.othersModel = [[CarWashCouponVModel alloc] initWithTableView:self.othersTableView withType:CouponNewTypeOthers];
    [self.othersModel resetWithTargetVC:self];
    
    [self.carWashModel.loadingModel loadDataForTheFirstTime];
    [self.gasModel.loadingModel loadDataForTheFirstTime];
    [self.insuranceModel.loadingModel loadDataForTheFirstTime];
    [self.othersModel.loadingModel loadDataForTheFirstTime];
    
    @weakify(self);
    [self listenNotificationByName:kNotifyRefreshMyCouponList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self);
        [self.carWashModel.loadingModel reloadData];
    }];
}

- (void)setSegmentView
{
    self.segHelper = [[CKSegmentHelper alloc] init];
    @weakify(self)
    [self.segHelper addItem:self.carwashBtn forGroupName:@"TabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.carwashline.hidden = !selected;
        self.carwashTableView.hidden = !selected;
        if (selected) {
            [MobClick event:@"rp304_1"];
        }
    }];
    
    [self.segHelper addItem:self.gasBtn forGroupName:@"TabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.gasLine.hidden = !selected;
        self.gasTableView.hidden = !selected;
        if (selected) {
            [MobClick event:@"rp304_1"];
        }
    }];
    
    [self.segHelper addItem:self.insuranceBtn forGroupName:@"TabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.insuranceline.hidden = !selected;
        self.insuranceTableView.hidden = !selected;
        if (selected) {
            [MobClick event:@"rp304_2"];
        }
    }];
    
    [self.segHelper addItem:self.othersBtn forGroupName:@"TabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.othersline.hidden = !selected;
        self.othersTableView.hidden = !selected;
        if (selected) {
            [MobClick event:@"rp304_3"];
        }
    }];
    
}


#pragma mark - Action
- (IBAction)actionTabBar:(id)sender
{
    [self.segHelper selectItem:sender];
}

- (IBAction)actionGetMore:(id)sender
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = kGetMoreCouponUrl;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)getMoreAction:(id)sender {
    [MobClick event:@"rp304_6"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = ADDEFINEWEB;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
