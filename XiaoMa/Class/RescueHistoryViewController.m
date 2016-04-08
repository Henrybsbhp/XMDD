//
//  RescueHistoryViewController.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescueHistoryViewController.h"
#import "RescueCommentsVC.h"
#import "GetRescueHistoryOp.h"
#import "HKRescueHistory.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "RescueCancelHostcarOp.h"
#import "HKTableViewCell.h"
#import "HKLoadingModel.h"
@interface RescueHistoryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) long long applyTime;
@property (nonatomic, assign) NSInteger applyType;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRemain;
@end

@implementation RescueHistoryViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescueHistoryViewController dealloc");
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.type == 1)
    {
        [MobClick beginLogPageView:@"rp705"];
    }
    else
    {
        [MobClick beginLogPageView:@"rp804"];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.type == 1)
    {
        [MobClick endLogPageView:@"rp705"];
    }
    else
    {
        [MobClick endLogPageView:@"rp804"];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isRemain = YES;
    if (self.type == 1) {
        self.navigationItem.title = @"救援记录";
    }else {
        self.navigationItem.title = @"协办记录";
    }
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        [self historyNetwork];
    }
}

#pragma mark - network
- (void)historyNetwork {
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = self.applyTime;
    op.type = self.type;
    @weakify(self);
    [[[[op rac_postRequest] initially:^{
        @strongify(self)
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        @strongify(self)
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescueHistoryOp *op) {
        @strongify(self)
        self.dataSourceArray = (NSMutableArray *)op.req_applysecueArray;
        if (self.dataSourceArray.count == 0) {
            if (self.type == 1)
            {
                [self.view showImageEmptyViewWithImageName:@"def_withoutRescueHistory" text:@"暂无救援记录" tapBlock:^{
                    [self historyNetwork];
                }];
            }
            else
            {
                [self.view showImageEmptyViewWithImageName:@"def_withoutAssistHistory" text:@"暂无协办记录" tapBlock:^{
                    [self historyNetwork];
                }];   
            }
        }
        
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:kDefErrorPormpt tapBlock:^{
            [self historyNetwork];
        }];
    }] ;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HKTableViewCell *cell;
    if (self.type == 1 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RescueHistoryViewController1" forIndexPath:indexPath];
    }else if (self.type == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"RescueHistoryViewController2" forIndexPath:indexPath];
    }
    
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(8, 0, 0, 0)];
    
    HKRescueHistory *history = self.dataSourceArray[indexPath.row];
    if (indexPath.row == self.dataSourceArray.count - 1) {
        self.applyTime = (long long)history.applyTime;
    }
    UILabel *plateLb = (UILabel *)[cell searchViewWithTag:1000];
    UILabel *stateLb = (UILabel *)[cell searchViewWithTag:1002];
    UILabel *timeLb = (UILabel *) [cell searchViewWithTag:1003];
    UILabel *titleLb = (UILabel *)[cell searchViewWithTag:1004];
    UIImageView *image = (UIImageView *)[cell searchViewWithTag:1005];
    UIButton *evaluationBtn = (UIButton *)[cell searchViewWithTag:1010];
    if (self.type ==2) {
        UILabel *tempTimeLb = (UILabel *)[cell searchViewWithTag:1009];
        tempTimeLb.text = [NSString stringWithFormat:@"预约时间: %@", [[NSDate dateWithUTS:history.appointTime] dateFormatForYYMMdd2]];
    }else {
        
    }
    
    titleLb.text = history.serviceName;
    timeLb.text = [[NSDate dateWithUTS:history.applyTime] dateFormatForYYMMdd2];
    
    evaluationBtn.layer.borderWidth = 1;
    evaluationBtn.layer.borderColor = [UIColor colorWithHex:@"#fe4a00" alpha:1].CGColor;
    evaluationBtn.layer.cornerRadius = 4;
    evaluationBtn.layer.masksToBounds = YES;
    plateLb.text = [NSString stringWithFormat:@"服务车辆: %@", history.licenceNumber];
    if (history.commentStatus  == HKCommentStatusNo) {
        
        [evaluationBtn setTitle:@"去评价" forState:UIControlStateNormal];
        if (history.rescueStatus == HKRescueStateCancel || history.rescueStatus == HKRescueStateProcessing) {
            evaluationBtn.hidden = YES;
        }
    }else{
        [evaluationBtn setTitle:@"已评价" forState:UIControlStateNormal];
        [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#bfbfbf" alpha:1.0] forState:UIControlStateNormal];
    }
    
    if (history.rescueStatus == HKRescueStateAlready) {
        stateLb.text = @"已申请";
        evaluationBtn.hidden = YES;
        if (self.type == 2) {
            evaluationBtn.hidden  = NO;
            evaluationBtn.layer.borderColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1.0].CGColor;
            evaluationBtn.titleLabel.textColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1.0];
            [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#bfbfbf" alpha:1.0] forState:UIControlStateNormal];
            [evaluationBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }else if (history.rescueStatus == HKRescueStateComplete){
        evaluationBtn.hidden = NO;
        stateLb.text = @"已完成";
        [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#fe4a00" alpha:1.0] forState:UIControlStateNormal];
    }else if (history.rescueStatus  == HKRescueStateCancel){
        stateLb.text = @"已取消";
        evaluationBtn.hidden = YES;
        
    }else {
        evaluationBtn.hidden = YES;
        stateLb.text = @"处理中";
    }
    
    if (history.type == HKRescueAnnual) {
        image.image = [UIImage imageNamed:@"commission_annual"];
    }else if (history.type  == HKRescueTrailer) {
        image.image = [UIImage imageNamed:@"rescue_trailer"];
    }else if (history.type  == HKRescuePumpPower){
        image.image = [UIImage imageNamed:@"pump_power"];
    }else {
        image.image = [UIImage imageNamed:@"rescue_tire"];
    }
    
    [RACObserve(history, commentStatus) subscribeNext:^(NSNumber *num) {
        if ([num integerValue] == 1) {
            [evaluationBtn setTitle:@"已评价" forState:UIControlStateNormal];
        }
    }];
    
    [RACObserve(history, rescueStatus) subscribeNext:^(NSNumber *num) {
        if ([num integerValue] == 4) {
            stateLb.text = @"已取消";
            evaluationBtn.hidden = YES;
            [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#fe4a00" alpha:1.0] forState:UIControlStateNormal];
        }
    }];
    @weakify(self)
    [[[evaluationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self)
        [x integerValue];
        evaluationBtn.enabled = NO;
        if (history.rescueStatus == HKRescueStateComplete) {
            if (history.commentStatus == HKCommentStatusNo)
            {
                [MobClick event:@"rp804_2"];
            }
            else
            {
                [MobClick event:@"rp804_3"];
            }
            evaluationBtn.enabled = YES;
            if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
                RescueCommentsVC *vc = [UIStoryboard vcWithId:@"RescueCommentsVC" inStoryboard:@"Rescue"];
                vc.history = history;
                vc.applyType = @(self.type);
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if (history.rescueStatus == HKRescueStateAlready && self.type == 2){
            [MobClick event:@"rp804_1"];
            evaluationBtn.enabled = YES;
            
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
                [alertVC dismiss];
            }];
            HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                RescueCancelHostcarOp *op = [RescueCancelHostcarOp operation];
                op.applyId = history.applyId;
                [[[[op rac_postRequest] initially:^{
                    [gToast showText:@"取消中..."];
                }] finally:^{
                    [gToast dismiss];
                }] subscribeNext:^(RescueCancelHostcarOp *op) {
                    if (op.rsp_code == 0) {
                        [gToast showText:@"取消成功"];
                        history.rescueStatus = HKRescueStateCancel;
                    }
                    
                } error:^(NSError *error) {
                    [gToast showText:@"取消失败, 请重试"];
                }] ;
                [alertVC dismiss];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您确定要取消本次协办服务吗？" ActionItems:@[cancel,confirm]];
            [alert show];
        }
    }];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.type == 1) {
        return 115;
    }else{
        return 130;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isRemain) {
        return;
    }
    NSInteger index =  indexPath.row + 1;
    
    if ([self.dataSourceArray count] > index) {
        return;
    }
    else
    {
        
        [self searchMoreHistory];
        
    }
    
    
}


#pragma mark - lazy
- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        _dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

#pragma mark - more
- (void)searchMoreHistory
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    
    op.applytime = self.applyTime;
    HKRescueHistory *his = [self.dataSourceArray lastObject];
    NSString *timeStr = [NSString stringWithFormat:@"%@", his.applyTime];
    op.applytime = [timeStr longLongValue];
    op.type = self.type;
    [[[op rac_postRequest] initially:^{
        
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        self.isLoading = YES;
    }] subscribeNext:^(GetRescueHistoryOp * op) {
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
        self.isLoading = NO;
        if(op.rsp_code == 0)
        {
            [self.tableView hideDefaultEmptyView];
            if (op.req_applysecueArray.count >= PageAmount)
            {
                self.isRemain = YES;
            }
            else
            {
                self.isRemain = NO;
            }
            if (!self.isRemain)
            {
                self.tableView.showBottomLoadingView = YES;
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"没有更多啦"];
            }
            
            NSMutableArray * tArray = [NSMutableArray arrayWithArray:self.dataSourceArray];
            [tArray addObjectsFromArray:op.req_applysecueArray];
            self.dataSourceArray = tArray;
            
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
        }
    } error:^(NSError *error) {
        self.isLoading = NO;
        self.tableView.showBottomLoadingView = YES;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
    }];
}



@end
