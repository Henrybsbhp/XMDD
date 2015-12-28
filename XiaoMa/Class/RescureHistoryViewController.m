//
//  RescureHistoryViewController.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "RescureHistoryViewController.h"
#import "RescurecCommentsVC.h"
#import "GetRescueHistoryOp.h"
#import "HKRescueHistory.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "rescueCancelHostcar.h"
#import "HKTableViewCell.h"
@interface RescureHistoryViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) long long applyTime;
@property (nonatomic, assign) NSInteger applyType;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRemain;
@end

@implementation RescureHistoryViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"RescureHistoryViewController dealloc");
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isRemain = YES;
    if (self.type == 1) {
        self.navigationItem.title = @"救援记录";
    }else {
        self.navigationItem.title = @"协办记录";
    }
    [self historyNetwork];
}

#pragma mark - network
- (void)historyNetwork {
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = self.applyTime;
    op.type = self.type;
    [[[[op rac_postRequest] initially:^{
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(GetRescueHistoryOp *op) {
        self.dataSourceArray = (NSMutableArray *)op.req_applysecueArray;
        if (self.dataSourceArray.count == 0) {
            if (self.type == 1) {
                [self.view showDefaultEmptyViewWithText:@"暂无救援记录" tapBlock:^{
                    [self historyNetwork];
                }];
                
            }else {
                [self.view showDefaultEmptyViewWithText:@"暂无协办记录" tapBlock:^{
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHistoryViewController1" forIndexPath:indexPath];
    }else if (self.type == 2){
        cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHistoryViewController2" forIndexPath:indexPath];
    }
    
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(8, 0, 0, 0)];
    
    HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
    if (indexPath.row == self.dataSourceArray.count - 1) {
        self.applyTime = (long long)hostory.applyTime;
    }
    UILabel *plateLb = (UILabel *)[cell searchViewWithTag:1000];
    UILabel *stateLb = (UILabel *)[cell searchViewWithTag:1002];
    UILabel *timeLb = (UILabel *) [cell searchViewWithTag:1003];
    UILabel *titleLb = (UILabel *)[cell searchViewWithTag:1004];
    UIImageView *image = (UIImageView *)[cell searchViewWithTag:1005];
    UIButton *evaluationBtn = (UIButton *)[cell searchViewWithTag:1010];
    if (self.type ==2) {
        UILabel *tempTimeLb = (UILabel *)[cell searchViewWithTag:1009];
        NSString *timeStr = [NSString stringWithFormat:@"%@", hostory.appointTime];
        NSString *tempStr = [timeStr substringToIndex:10];
        tempTimeLb.text = [NSString stringWithFormat:@"预约时间: %@", [[NSDate dateWithTimeIntervalSince1970:[tempStr intValue]] dateFormatForYYMMdd2]];
    }
    evaluationBtn.layer.borderWidth = 1;
    evaluationBtn.layer.borderColor = [UIColor colorWithHex:@"#fe4a00" alpha:1].CGColor;
    evaluationBtn.layer.cornerRadius = 4;
    evaluationBtn.layer.masksToBounds = YES;
    plateLb.text = [NSString stringWithFormat:@"服务车辆: %@", hostory.licenceNumber];
    if ([hostory.commentStatus integerValue] == 0) {
        
        [evaluationBtn setTitle:@"去评价" forState:UIControlStateNormal];
        if ([hostory.rescueStatus integerValue] == 4 || [hostory.rescueStatus integerValue] == 5) {
            evaluationBtn.hidden = YES;
        }
    }else if ([hostory.commentStatus integerValue]== 1){
        [evaluationBtn setTitle:@"已评价" forState:UIControlStateNormal];
        [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#bfbfbf" alpha:1.0] forState:UIControlStateNormal];
    }
    
    if ([hostory.rescueStatus integerValue] == 2) {
        stateLb.text = @"已申请";
        evaluationBtn.hidden = YES;
        if (self.type == 2) {
            evaluationBtn.hidden  = NO;
            evaluationBtn.layer.borderColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1.0].CGColor;
            evaluationBtn.titleLabel.textColor = [UIColor colorWithHex:@"#bfbfbf" alpha:1.0];
            [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#bfbfbf" alpha:1.0] forState:UIControlStateNormal];
            [evaluationBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }else if ([hostory.rescueStatus integerValue] == 3){
        evaluationBtn.hidden = NO;
        stateLb.text = @"已完成";
        [evaluationBtn setTitleColor:[UIColor colorWithHex:@"#fe4a00" alpha:1.0] forState:UIControlStateNormal];
    }else if ([hostory.rescueStatus integerValue] == 4){
        stateLb.text = @"已取消";
        evaluationBtn.hidden = YES;
        
    }else {
        evaluationBtn.hidden = YES;
        stateLb.text = @"处理中";
    }
    if (self.type == 2) {
        image.image = [UIImage imageNamed:@"commission_annual"];
    }else if ([hostory.type integerValue] == 1) {
        image.image = [UIImage imageNamed:@"rescue_trailer"];
    }else if ([hostory.type integerValue] == 2){
        image.image = [UIImage imageNamed:@"pump_power"];
    }else {
        image.image = [UIImage imageNamed:@"rescue_tire"];
    }
    
    titleLb.text = hostory.serviceName;
    NSString *timeStr = [NSString stringWithFormat:@"%@", hostory.applyTime];
    NSString *tempStr = [timeStr substringToIndex:10];
    timeLb.text = [[NSDate dateWithTimeIntervalSince1970:[tempStr intValue]] dateFormatForYYYYMMddHHmm2];
    
    [RACObserve(hostory, commentStatus) subscribeNext:^(NSNumber *num) {
        if ([num integerValue] == 1) {
            [evaluationBtn setTitle:@"已评价" forState:UIControlStateNormal];
        }
    }];
    
    [RACObserve(hostory, rescueStatus) subscribeNext:^(NSNumber *num) {
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
        if ([hostory.rescueStatus integerValue] != 2 && [hostory.rescueStatus integerValue] != 4 && [hostory.rescueStatus integerValue] != 5) {
            evaluationBtn.enabled = YES;
            RescurecCommentsVC *vc = [UIStoryboard vcWithId:@"RescurecCommentsVC" inStoryboard:@"Rescue"];
            vc.history = hostory;
            vc.applyType = @(self.type);
            [self.navigationController pushViewController:vc animated:YES];
            
            /**
             *  协办已申请
             */
        }else if ([hostory.rescueStatus isEqual:@(2)] && self.type == 2){
            evaluationBtn.enabled = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要取消本次协办服务吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            
            [alert show];
            [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *n) {
                NSInteger i = [n integerValue];
                if (i == 1)
                {
                    rescueCancelHostcar *op = [rescueCancelHostcar operation];
                    op.applyId = hostory.applyId;
                    [[[[op rac_postRequest] initially:^{
                        [gToast showText:@"取消中..."];
                    }] finally:^{
                        [gToast dismiss];
                    }] subscribeNext:^(rescueCancelHostcar *op) {
                        if (op.rsp_code == 0) {
                            [gToast showText:@"取消成功"];
                            hostory.rescueStatus = @(4);
                        }
                        
                    } error:^(NSError *error) {
                        [gToast showText:@"取消失败, 请重试"];
                    }] ;
                }
                
            }];
            
            
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
