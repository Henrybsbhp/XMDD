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
#import "HKLoadingModel.h"
#import "UIView+DefaultEmptyView.h"
#import "UIView+JTLoadingView.h"
#import "rescueCancelHostcar.h"
#import "HKTableViewCell.h"
@interface RescureHistoryViewController ()<UITableViewDelegate, UITableViewDataSource, HKLoadingModelDelegate>

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@property (nonatomic, strong) HKTableViewCell *cell;
@property (strong, nonatomic) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) long long applyTime;
@property (nonatomic, assign) NSInteger applyType;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) NSUInteger pageAmount;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRemain;
@property (nonatomic, assign) NSInteger isLog;
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
    if (self.type == 1 ) {
       self.cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHistoryViewController1" forIndexPath:indexPath];
    }else if (self.type == 2){
        self.cell = [tableView dequeueReusableCellWithIdentifier:@"RescureHistoryViewController2" forIndexPath:indexPath];
    }
    
    [self.cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(8, 0, 0, 0)];

    HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
    if (indexPath.row == self.dataSourceArray.count - 1) {
        self.isRemain = YES;
        self.applyTime = [hostory.applyTime doubleValue];
     }
    UILabel *plateLb = (UILabel *)[self.cell searchViewWithTag:1000];
    UILabel *stateLb = (UILabel *)[self.cell searchViewWithTag:1002];
    UILabel *timeLb = (UILabel *)[self.cell searchViewWithTag:1003];
    UILabel *titleLb = (UILabel *)[self.cell searchViewWithTag:1004];
    UIImageView *image = (UIImageView *)[self.cell searchViewWithTag:1005];
    UIButton *evaluationBtn = (UIButton *)[self.cell searchViewWithTag:1010];
    if (self.type ==2) {
        UILabel *tempTimeLb = (UILabel *)[self.cell searchViewWithTag:1009];
        tempTimeLb.text = hostory.appointTime;
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
    }else if ([hostory.rescueStatus integerValue] == 4){
        stateLb.text = @"已取消";
        evaluationBtn.hidden = YES;
        
    }else if ([hostory.rescueStatus integerValue] == 5){
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
        self.isLog = [num integerValue];
        if (self.isLog == 1) {
            [evaluationBtn setTitle:@"已评价" forState:UIControlStateNormal];
        }
    }];
    
    [[evaluationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]  subscribeNext:^(id x) {
        
        HKRescueHistory *hostory = self.dataSourceArray[indexPath.row];
      
        if ([hostory.rescueStatus integerValue] != 2 && [hostory.rescueStatus integerValue] != 4 && [hostory.rescueStatus integerValue] != 5) {
            
            RescurecCommentsVC *vc = [UIStoryboard vcWithId:@"RescurecCommentsVC" inStoryboard:@"Rescue"];
            vc.history = hostory;
            if ([hostory.commentStatus isEqual:@(1)]) {
                vc.isLog = 1;
            }
            vc.applyType = @(self.applyType);
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([hostory.rescueStatus integerValue] == 2 && self.type == 2){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要本次协办服务吗？" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
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
                            [self historyNetwork];
                        }
                        
                    } error:^(NSError *error) {
                        [gToast showText:@"取消失败, 请重试"];
                    }] ;
                }
                
            }];
          
            
        }
        
        
    }];
    return self.cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isRemain) {
        return;
    }
    
    //HKRescueHistory * rescue = [self.dataSourceArray safetyObjectAtIndex:indexPath.row];
    NSInteger count = self.dataSourceArray.count + 2;
    NSInteger index =  indexPath.section + 1;
    if ([self.dataSourceArray count] > index) {
        return;
    }
    else
    {
        if (count) {
            NSInteger index =  indexPath.row + 1;
            if (count > index)
            {
                return;
            }
        }
    }
    
    [self searchMoreShops];
}


#pragma mark - lazy
- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        self.dataSourceArray = [[NSMutableArray alloc] init];
    }
    return _dataSourceArray;
}

- (void)searchMoreShops
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    NSLog(@"-2-------%lld--------", self.applyTime);

    op.applytime = self.applyTime;
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
