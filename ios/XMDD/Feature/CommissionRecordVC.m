//
//  CommissionRecordVC.m
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CommissionRecordVC.h"
#import "GetRescueHistoryOp.h"
#import "HKRescueHistory.h"

@interface CommissionRecordVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, assign) NSUInteger applyTime;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRemain;

@end

@implementation CommissionRecordVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"CommissionRecordVC is deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRemain = YES;
    
    [self requestForRescueData];
    
    @weakify(self)
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self)
        self.isRemain = YES;
        if (!self.isLoading) {
            [self requestForRescueData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Obtain data
// 请求数据
- (void)requestForRescueData
{
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = 0;
    op.type = 2;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        self.isLoading = YES;
        [self.view hideDefaultEmptyView];
        if (!self.datasource.count) {
            // 防止有数据的时候，下拉刷新导致页面会闪一下
            CGFloat reducingY = self.view.frame.size.height * 0.1056;
            [self.view hideDefaultEmptyView];
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            self.tableView.hidden = YES;
        }
        else
        {
            [self.tableView.refreshView beginRefreshing];
            self.tableView.hidden = NO;
        }
        
    }] subscribeNext:^(GetRescueHistoryOp *rop) {
        @strongify(self);
        self.isLoading = NO;
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        if (rop.rsp_applysecueArray.count > 0) {
            self.datasource = [self dataSourceWithResponsedArray:rop.rsp_applysecueArray];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        } else {
            self.tableView.hidden = YES;
            [self.view showImageEmptyViewWithImageName:@"def_withoutAssistHistory" text:@"暂无救援记录" tapBlock:^{
                @strongify(self);
                [self requestForRescueData];
            }];
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:kDefErrorPormpt tapBlock:^{
            @strongify(self);
            [self requestForRescueData];
        }];
    }];
}

// 获取分页数据
- (void)requestForMoreRescueData
{
    if ([self.tableView.bottomLoadingView isActivityAnimating]) {
        return;
    }
    
    GetRescueHistoryOp *op = [GetRescueHistoryOp operation];
    op.applytime = self.applyTime;
    op.type = 2;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        self.isLoading = YES;
        
    }] subscribeNext:^(GetRescueHistoryOp *rop) {
        
        @strongify(self);
        [self.tableView.bottomLoadingView stopActivityAnimation];
        self.isLoading = NO;
        if (rop.rsp_code == 0) {
            [self.tableView hideDefaultEmptyView];
            
            // 获取最后一次得到的时间戳
            HKRescueHistory *record = rop.rsp_applysecueArray.lastObject;
            self.applyTime = (long long)record.applyTime;
            
            if (rop.rsp_applysecueArray.count >= PageAmount) {
                self.isRemain = YES;
            } else {
                self.isRemain = NO;
            }
            
            if (!self.isRemain) {
                self.tableView.showBottomLoadingView = YES;
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"没有更多啦"];
            }
            
            CKList *moreRecource = [self dataSourceWithResponsedArray:rop.rsp_applysecueArray];
            [self.datasource addObjectsFromQueue:moreRecource];
            
            [self.tableView reloadData];
            
        } else {
            
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
        }
        
    } error:^(NSError *error) {
        
        @strongify(self);
        self.isLoading = NO;
        self.tableView.showBottomLoadingView = YES;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
        
    }];
}

- (CKList *)dataSourceWithResponsedArray:(NSArray *)responsedArray
{
    // 获取最后一次得到的时间戳
    HKRescueHistory *record = responsedArray.lastObject;
    self.applyTime = [record.applyTime integerValue];
    
    CKList *resource = [CKList list];
    for (HKRescueHistory *record in responsedArray) {
        [resource addObject:$([self setupRecordCellWithHistoryRecord:record]) forKey:nil];
    }
    return resource;
}

#pragma mark - The settings of the UITableViewCell
// Cell 的设定
- (CKDict *)setupRecordCellWithHistoryRecord:(HKRescueHistory *)historyRecord
{
    CKDict *recordCell = [CKDict dictWith:@{kCKItemKey: @"RecordCell", kCKCellID: @"RecordCell"}];
    
    @weakify(self);
    recordCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 170;
    });
    
    recordCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *timeLabel = (UILabel *)[cell.contentView searchViewWithTag:1001];
        UILabel *statusLabel = (UILabel *)[cell.contentView searchViewWithTag:1002];
        UILabel *carNumLabel = (UILabel *)[cell.contentView searchViewWithTag:1004];
        UILabel *preorderTimeLabel = (UILabel *)[cell.contentView searchViewWithTag:1005];
        UILabel *priceLabel = (UILabel *)[cell.contentView searchViewWithTag:1006];
        UIButton *executeButton = (UIButton *)[cell.contentView searchViewWithTag:1007];
        UIButton *cancelButton = (UIButton *)[cell.contentView searchViewWithTag:1008];
        
        UIColor *rightButtonColor;
        timeLabel.text = [[NSDate dateWithUTS:historyRecord.applyTime] dateFormatForYYYYMMddHHmm2];
        
        executeButton.layer.borderColor = HEXCOLOR(@"#FF7428").CGColor;
        executeButton.layer.borderWidth = 0.5;
        executeButton.layer.cornerRadius = 3;
        executeButton.layer.masksToBounds = YES;
        [executeButton setTitle:@"确认完成" forState:UIControlStateNormal];
        [executeButton setTitleColor:HEXCOLOR(@"#FF7428") forState:UIControlStateNormal];
        
        cancelButton.layer.borderColor = HEXCOLOR(@"#888888").CGColor;
        cancelButton.layer.borderWidth = 0.5;
        cancelButton.layer.cornerRadius = 3;
        cancelButton.layer.masksToBounds = YES;
        [cancelButton setTitle:@"取消订单" forState:UIControlStateNormal];
        [cancelButton setTitleColor:HEXCOLOR(@"#888888") forState:UIControlStateNormal];
        
        if (historyRecord.rescueStatus == HKCommissionWaitForPay) {
            // 待支付
            statusLabel.text = @"待支付";
            rightButtonColor = HEXCOLOR(@"#FF7428");
            executeButton.hidden = NO;
            [executeButton setTitle:@"待支付" forState:UIControlStateNormal];
            cancelButton.hidden = NO;
            
        } else if (historyRecord.rescueStatus == HKCommissionPaidAlready) {
            // 已支付
            statusLabel.text = @"已支付";
            rightButtonColor = HEXCOLOR(@"#FF7428");
            executeButton.hidden = NO;
            [executeButton setTitle:@"确认完成" forState:UIControlStateNormal];
            
        } else if (historyRecord.rescueStatus == HKCommissionCompleted) {
            // 已完成
            statusLabel.text = @"已完成";
            executeButton.hidden = NO;
            
            if (historyRecord.commentStatus == HKCommentStatusNo) {
                rightButtonColor = HEXCOLOR(@"#FF7428");
                [executeButton setTitle:@"去评价" forState:UIControlStateNormal];
            } else {
                rightButtonColor = HEXCOLOR(@"#888888");
                [executeButton setTitle:@"已评价" forState:UIControlStateNormal];
            }
            
        } else if (historyRecord.rescueStatus == HKCommissionCanceled) {
            // 已取消
            statusLabel.text = @"已取消";
            executeButton.hidden = YES;
        }
        
        carNumLabel.text = historyRecord.licenceNumber;
        preorderTimeLabel.text = [NSString stringWithFormat:@"预约时间：%@", historyRecord.appointTime.integerValue == 0 ? @"" : [[NSDate dateWithUTS:historyRecord.appointTime] dateFormatForYYMMdd2]];
        priceLabel.text = [NSString stringWithFormat:@"￥%.2f", [historyRecord.pay doubleValue]];
    });
    
    recordCell[kCKCellWillDisplay] = CKCellWillDisplay(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        
        if (!self.isRemain) {
            return;
        }
        
        if (self.isLoading) {
            return;
        }
        
        NSInteger index = indexPath.section + 1;
        
        if ([self.datasource count] > index) {
            return;
        } else {
            [self requestForMoreRescueData];
        }
    });
    
    return recordCell;
}

#pragma mark - UITableViewDelegata
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

@end
