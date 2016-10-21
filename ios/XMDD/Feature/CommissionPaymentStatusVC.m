//
//  CommissionPaymentStatusVC.m
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CommissionPaymentStatusVC.h"
#import "CommissionPaymentVM.h"
#import "CommissionPaymentSuccessVM.h"
#import "CommissionRatingVM.h"

@interface CommissionPaymentStatusVC ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *callServiceBarButton;

/// tableView 底部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

/// 协办支付 VM
@property (nonatomic, strong) CommissionPaymentVM *commissionPaymentVM;
/// 协办支付成功 VM
@property (nonatomic, strong) CommissionPaymentSuccessVM *commissionPaymentSuccessVM;
/// 协办评价 VM
@property (nonatomic, strong) CommissionRatingVM *commissionRatingVM;

@end

@implementation CommissionPaymentStatusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bottomView.hidden = YES;
    self.tableViewBottomConstraint.constant = 0;
    [self.callServiceBarButton setTitle:@""];
    self.callServiceBarButton.enabled = NO;
    [self.commissionRatingVM initialSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)actionCallServiceBarButton:(id)sender
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"客服电话：4007-111-111" ActionItems:@[cancel, confirm]];
    [alert show];
}

#pragma mark - Lazy instantiation
- (CommissionPaymentVM *)commissionPaymentVM
{
    if (!_commissionPaymentVM) {
        _commissionPaymentVM = [[CommissionPaymentVM alloc] initWithTableView:self.tableView andTargetVC:self];
    }
    
    return _commissionPaymentVM;
}

- (CommissionPaymentSuccessVM *)commissionPaymentSuccessVM
{
    if (!_commissionPaymentSuccessVM) {
        _commissionPaymentSuccessVM = [[CommissionPaymentSuccessVM alloc] initWithTableView:self.tableView andTargetVC:self];
    }
    
    return _commissionPaymentSuccessVM;
}

- (CommissionRatingVM *)commissionRatingVM
{
    if (!_commissionRatingVM) {
        _commissionRatingVM = [[CommissionRatingVM alloc] initWithTableView:self.tableView andTargetVC:self];
    }
    
    return _commissionRatingVM;
}

@end
