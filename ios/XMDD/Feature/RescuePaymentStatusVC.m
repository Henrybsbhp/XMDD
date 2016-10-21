//
//  RescuePaymentStatusVC.m
//  XMDD
//
//  Created by St.Jimmy on 18/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RescuePaymentStatusVC.h"
#import "UPApplePayHelper.h"
#import "RescuePaymentVM.h"
#import "RescuingStatusVM.h"
#import "RescueRatingVM.h"
#import "GetRescueOrCommissionDetailOp.h"

@interface RescuePaymentStatusVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *callServiceBarButton;

/// tableView 底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

/// 救援支付 VM
@property (nonatomic, strong) RescuePaymentVM *rescuePaymentVM;
/// 救援支付成功调度 / 救援中 VM
@property (nonatomic, strong) RescuingStatusVM *rescuingStatusVM;
/// 救援评价 VM
@property (nonatomic, strong) RescueRatingVM *rescueRatingVM;

@end

@implementation RescuePaymentStatusVC

- (void)dealloc
{
    DebugLog(@"RescuePaymentStatusVC is deallocated");
}

- (void)viewDidLoad
{
    if (self.vcType == RescueVCTypeControl || self.vcType == RescueVCTypeRating) {
        self.callServiceBarButton.title = @"";
        self.callServiceBarButton.enabled = NO;
        self.tableViewBottomConstraint.constant = 0;
        self.bottomView.hidden = YES;
    }
    
    if (self.vcType == RescueVCTypeRescuing) {
        [self.bottomButton setTitle:@"确认救援完成" forState:UIControlStateNormal];
        self.bottomButton.enabled = NO;
    }
    
    [self requestForRescueDetailData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Obtain data
- (void)requestForRescueDetailData
{
    GetRescueOrCommissionDetailOp *op = [GetRescueOrCommissionDetailOp operation];
    op.rsq_applyID = self.applyID;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        // 防止有数据的时候，下拉刷新导致页面会闪一下
        CGFloat reducingY = self.view.frame.size.height * 0.1056;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
        self.tableView.hidden = YES;
    }] subscribeNext:^(GetRescueOrCommissionDetailOp *rop) {
        @strongify(self);
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
        
        // 救援调度 / 救援中
        if (self.vcType == RescueVCTypeControl || self.vcType == RescueVCTypeRescuing) {
            self.rescuingStatusVM.vcType = self.vcType;
            self.rescuingStatusVM.rescueDetialOp = rop;
            self.rescuingStatusVM.applyID = self.applyID;
            if (self.vcType == RescueVCTypeRescuing) {
                self.rescuingStatusVM.confirmButton = self.bottomButton;
            }
            [self.rescuingStatusVM initialSetup];
        }
        
        // 救援完成 / 评价
        if (self.vcType == RescueVCTypeRating) {
            self.rescueRatingVM.vcType = self.vcType;
            self.rescueRatingVM.rescueDetialOp = rop;
            self.rescueRatingVM.applyID = self.applyID;
            [self.rescueRatingVM initialSetup];
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_withoutAssistHistory" text:@"暂无救援记录" tapBlock:^{
            @strongify(self);
            [self requestForRescueDetailData];
        }];
    }];
}

#pragma mark - Actions
- (IBAction)actionCallService:(id)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"客服电话：4007-111-111" ActionItems:@[cancel, confirm]];
    [alert show];
}

#pragma mark - Lazy instantiation
- (RescuePaymentVM *)rescuePaymentVM
{
    if (!_rescuePaymentVM) {
        _rescuePaymentVM = [[RescuePaymentVM alloc] initWithTableView:self.tableView andTargetVC:self];
    }
    
    return _rescuePaymentVM;
}

- (RescuingStatusVM *)rescuingStatusVM
{
    if (!_rescuingStatusVM) {
        _rescuingStatusVM = [[RescuingStatusVM alloc] initWithTableView:self.tableView andTargetVC:self];
    }
    
    return _rescuingStatusVM;
}

- (RescueRatingVM *)rescueRatingVM
{
    if (!_rescueRatingVM) {
        _rescueRatingVM = [[RescueRatingVM alloc] initWithTableView:self.tableView andTargetVC:self];
    }
    
    return _rescueRatingVM;
}

@end
