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
#import "HKRescueHistory.h"

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

- (void)dealloc
{
    DebugLog(@"CommissionPaymentStatusVC is deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /// tableView 的 contentInset 的 top 属性设置为 -34，不然在 Grouped 风格的 tableView 下会出现顶端留白。
    self.tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0);
    
    // 救援调度 / 救援中
    if (self.vcType == HKCommissionPaidAlready || self.vcType == HKCommissionCompleted) {
        self.bottomView.hidden = YES;
        self.tableViewBottomConstraint.constant = 0;
        [self.callServiceBarButton setTitle:@""];
        self.callServiceBarButton.enabled = NO;
    }
    
    if (self.vcType == HKCommissionWaitForPay) {
        self.bottomView.hidden = YES;
    }
    
    [self requestForRescueDetailData];
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
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"协办电话：4007-111-111" ActionItems:@[cancel, confirm]];
    [alert show];
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
        
        // 协办已支付
        if (self.vcType == HKCommissionPaidAlready) {
            self.commissionPaymentSuccessVM.vcType = self.vcType;
            self.commissionPaymentSuccessVM.commissionDetailOp = rop;
            self.commissionPaymentSuccessVM.isEnterFromHomePage = self.isEnterFromHomePage;
            self.commissionPaymentSuccessVM.applyID = self.applyID;
            self.commissionPaymentSuccessVM.confirmButton = self.bottomButton;
            [self.commissionPaymentSuccessVM initialSetup];
        }
        
        // 协办完成 / 评价
        if (self.vcType == HKCommissionCompleted) {
            self.commissionRatingVM.vcType = self.vcType;
            self.commissionRatingVM.commissionDetailOp = rop;
            self.commissionRatingVM.applyID = self.applyID;
            self.commissionRatingVM.commentStatus = self.commentStatus;
            [self.commissionRatingVM initialSetup];
        }
        
        if (self.vcType == HKCommissionWaitForPay) {
            self.bottomView.hidden = NO;
            self.commissionPaymentVM.vcType = self.vcType;
            self.commissionPaymentVM.isEnterFromHomePage = self.isEnterFromHomePage;
            self.commissionPaymentVM.commissionDetailOp = rop;
            self.commissionPaymentVM.applyID = self.applyID;
            self.commissionPaymentVM.confirmButton = self.bottomButton;
            [self.commissionPaymentVM initialSetup];
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        self.bottomView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_withoutAssistHistory" text:@"暂无协办记录" tapBlock:^{
            @strongify(self);
            [self requestForRescueDetailData];
        }];
    }];
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
