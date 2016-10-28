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
#import "CommissionPaymentStatusVC.h"
#import "RescueCancelHostcarOp.h"
#import "GetRescueOrCommissionDetailOp.h"
#import "RescueConfirmFinishOp.h"

@interface CommissionRecordVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic, assign) NSUInteger applyTime;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isRemain;

@property (nonatomic, strong) NSIndexPath *req_indexPath;
@property (nonatomic, strong) NSNumber *req_applyID;

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
    
    [self setupNavigationBar];
    
    self.isRemain = YES;
    
    [self requestForRescueData];
    
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.isRemain = YES;
        if (!self.isLoading) {
            [self requestForRescueData];
        }
    }];
    
    // 监听页面需不需要更新
    [self listenNotificationByName:kNotifyCommissionRecordVC withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self);
        [self requestForSpecificDataWithApplyID:self.req_applyID atIndexPath:self.req_indexPath];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
    [self.navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(actionBack)];
}

#pragma mark - Actions
/// 进入已支付 / 待支付页面
- (void)actionGoToPaidAlreadyVCWithHistoryRecord:(HKRescueHistory *)historyRecord
{
    CommissionPaymentStatusVC *vc = [UIStoryboard vcWithId:@"CommissionPaymentStatusVC" inStoryboard:@"Commission"];
    vc.vcType = historyRecord.rescueStatus;
    vc.applyID = historyRecord.applyId;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 进入评价 / 已评价页面
- (void)actionGoToRatingVCWithHistoryRecord:(HKRescueHistory *)historyRecord
{
    CommissionPaymentStatusVC *vc = [UIStoryboard vcWithId:@"CommissionPaymentStatusVC" inStoryboard:@"Commission"];
    vc.vcType = historyRecord.rescueStatus;
    vc.applyID = historyRecord.applyId;
    vc.commentStatus = historyRecord.commentStatus;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 取消协办
- (void)actionCancelCommissionWithHistoryRecord:(HKRescueHistory *)historyRecord
{
    RescueCancelHostcarOp *op = [RescueCancelHostcarOp operation];
    op.applyId = historyRecord.applyId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在取消中..."];
    }] subscribeNext:^(RescueCancelHostcarOp *rop) {
        @strongify(self);
        [gToast showSuccess:@"取消成功"];
        [self requestForSpecificDataWithApplyID:self.req_applyID atIndexPath:self.req_indexPath];
        
    } error:^(NSError *error) {
        [gToast showError:@"取消失败，请重试"];
    }];
}

/// 确认完成
- (void)actionConfirmFinishWithHistoryRecord:(HKRescueHistory *)historyRecord
{
    RescueConfirmFinishOp *op = [RescueConfirmFinishOp operation];
    op.req_applyID = historyRecord.applyId;
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在确认中..."];
        
    }] subscribeNext:^(RescueConfirmFinishOp *rop) {
        [gToast showSuccess:@"确认完成"];
        CommissionPaymentStatusVC *vc = [UIStoryboard vcWithId:@"CommissionPaymentStatusVC" inStoryboard:@"Commission"];
        vc.vcType = HKCommissionCompleted;
        vc.applyID = historyRecord.applyId;
        vc.commentStatus = 0;
        [self.router.navigationController pushViewController:vc animated:YES];
        [self postCustomNotificationName:kNotifyCommissionRecordVC object:nil];
        
    } error:^(NSError *error) {
        [gToast showError:@"确认失败，请重试"];
        
    }];
}

- (void)actionBack
{
    [MobClick event:@"wodexieban" attributes:@{@"navi" : @"back"}];
    [self.navigationController popViewControllerAnimated:YES];
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
        
        if (rop.rsp_applysecueArray.count >= PageAmount) {
            self.isRemain = YES;
        } else {
            self.isRemain = NO;
        }
        
        if (rop.rsp_applysecueArray.count > 0) {
            self.datasource = [self dataSourceWithResponsedArray:rop.rsp_applysecueArray];
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        } else {
            self.tableView.hidden = YES;
            [self.view showImageEmptyViewWithImageName:@"def_withoutAssistHistory" text:@"暂无代办记录" tapBlock:^{
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
            self.applyTime = record.applyTime.integerValue;
            
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

// 请求单行数据
- (void)requestForSpecificDataWithApplyID:(NSNumber *)applyID atIndexPath:(NSIndexPath *)indexPath
{
    GetRescueOrCommissionDetailOp *op = [GetRescueOrCommissionDetailOp operation];
    op.rsq_applyID = applyID;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"更新数据中..."];
    }] subscribeNext:^(GetRescueOrCommissionDetailOp *rop) {
        @strongify(self);
        [gToast dismiss];
        HKRescueHistory *record = [[HKRescueHistory alloc] init];
        record.type = rop.rsp_type;
        record.commentStatus = rop.rsp_commentStatus;
        record.rescueStatus = rop.rsp_rescueStatus;
        record.applyTime = @(rop.rsp_applyTime);
        record.serviceName = rop.rsp_serviceName;
        record.licenceNumber = rop.rsp_licenseNumber;
        record.applyId = @(rop.rsp_applyID);
        record.type = rop.rsp_type;
        record.appointTime = @(rop.rsp_appointTime);
        record.pay = @(rop.rsp_pay);
        
        CKDict *replaceData = [self setupRecordCellWithHistoryRecord:record];
        CKList *replaceList = $(replaceData);
        
        [self.datasource replaceObject:replaceList withKey:nil atIndex:indexPath.section];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        
    } error:^(NSError *error) {
        [gToast showError:@"数据请求失败"];
    }];
}

/// 把获取到的数据整合为一个 CKList
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
    
    recordCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        
        [MobClick event:@"wodexieban" attributes:@{@"chakanxiangqing" : @"chakanxiangqing"}];
        
        if (historyRecord.rescueStatus == HKCommissionPaidAlready || historyRecord.rescueStatus == HKCommissionWaitForPay) {
            [self actionGoToPaidAlreadyVCWithHistoryRecord:historyRecord];
        }
        
        if (historyRecord.rescueStatus == HKCommissionCompleted) {
            [self actionGoToRatingVCWithHistoryRecord:historyRecord];
        }
        
        self.req_indexPath = indexPath;
        self.req_applyID = historyRecord.applyId;
    });
    
    recordCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *timeLabel = (UILabel *)[cell.contentView searchViewWithTag:1001];
        UILabel *statusLabel = (UILabel *)[cell.contentView searchViewWithTag:1002];
        UILabel *carNumLabel = (UILabel *)[cell.contentView searchViewWithTag:1004];
        UILabel *preorderTimeLabel = (UILabel *)[cell.contentView searchViewWithTag:1005];
        UILabel *priceLabel = (UILabel *)[cell.contentView searchViewWithTag:1006];
        UIButton *executeButton = (UIButton *)[cell.contentView searchViewWithTag:1007];
        UIButton *cancelButton = (UIButton *)[cell.contentView searchViewWithTag:1008];
        
        UIColor *rightButtonColor;
        timeLabel.text = [[NSDate dateWithUTS:historyRecord.applyTime] dateFormatForYYYYMMddHHmm2];
        
        cancelButton.layer.borderColor = HEXCOLOR(@"#888888").CGColor;
        cancelButton.layer.borderWidth = 0.5;
        cancelButton.layer.cornerRadius = 3;
        cancelButton.layer.masksToBounds = YES;
        [cancelButton setTitle:@"取消订单" forState:UIControlStateNormal];
        [cancelButton setTitleColor:HEXCOLOR(@"#888888") forState:UIControlStateNormal];
        cancelButton.hidden = YES;
        
        // 待支付
        if (historyRecord.rescueStatus == HKCommissionWaitForPay) {
            statusLabel.text = @"待支付";
            rightButtonColor = HEXCOLOR(@"#FF7428");
            executeButton.hidden = NO;
            [executeButton setTitle:@"待支付" forState:UIControlStateNormal];
            cancelButton.hidden = NO;
            
            // 取消订单事件
            @weakify(self);
            [[[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                
                [MobClick event:@"wodexieban" attributes:@{@"quxiaodingdan" : @"quxiaodingdan"}];
                
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
                    [MobClick event:@"wodexieban" attributes:@{@"tanchuang_quxiaodingdan" : @"tanchuang_quxiao"}];
                }];
                
                @weakify(self);
                HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
                    @strongify(self);
                    [MobClick event:@"wodexieban" attributes:@{@"tanchuang_quxiaodingdan" : @"tanchuang_queren"}];
                    [self actionCancelCommissionWithHistoryRecord:historyRecord];
                }];
                
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"确定要取消本次协助吗" ActionItems:@[cancel, confirm]];
                [alert show];
                
                self.req_indexPath = indexPath;
                self.req_applyID = historyRecord.applyId;
            }];
            
            [[[executeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                [MobClick event:@"wodexieban" attributes:@{@"quzhifu" : @"quzhifu"}];
                [self actionGoToPaidAlreadyVCWithHistoryRecord:historyRecord];
            }];
            
        }
        
        // 已支付
        if (historyRecord.rescueStatus == HKCommissionPaidAlready) {
            statusLabel.text = @"已支付";
            rightButtonColor = HEXCOLOR(@"#FF7428");
            executeButton.hidden = NO;
            [executeButton setTitle:@"确认完成" forState:UIControlStateNormal];
            @weakify(self);
            [[[executeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                
                [MobClick event:@"wodexieban" attributes:@{@"querenwancheng" : @"querenwancheng"}];
                
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:^(id alertVC) {
                    [MobClick event:@"wodexieban" attributes:@{@"tanchuang_querenwancheng" : @"tanchuang_quxiao"}];
                }];
                
                @weakify(self);
                HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
                    @strongify(self);
                    [MobClick event:@"wodexieban" attributes:@{@"tanchuang_querenwancheng" : @"tanchuang_queren"}];
                    [self actionConfirmFinishWithHistoryRecord:historyRecord];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请务必在完成协办服务后再确认服务已完成" ActionItems:@[cancel, confirm]];
                [alert show];
                
                self.req_indexPath = indexPath;
                self.req_applyID = historyRecord.applyId;
            }];
            
        }
        
        // 已完成
        if (historyRecord.rescueStatus == HKCommissionCompleted) {
            statusLabel.text = @"已完成";
            executeButton.hidden = NO;
            
            if (historyRecord.commentStatus == HKCommentStatusNo) {
                rightButtonColor = HEXCOLOR(@"#FF7428");
                [executeButton setTitle:@"去评价" forState:UIControlStateNormal];
            } else {
                rightButtonColor = HEXCOLOR(@"#888888");
                [executeButton setTitle:@"已评价" forState:UIControlStateNormal];
            }
            
            @weakify(self);
            [[[executeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                [self actionGoToRatingVCWithHistoryRecord:historyRecord];
                self.req_indexPath = indexPath;
                self.req_applyID = historyRecord.applyId;
                
                if (historyRecord.commentStatus == HKCommentStatusNo) {
                    [MobClick event:@"wodexieban" attributes:@{@"qupingjia" : @"qupingjia"}];
                } else {
                    [MobClick event:@"wodexieban" attributes:@{@"yipingjia" : @"yipingjia"}];
                }
                
            }];
            
        }
        
        // 已取消
        if (historyRecord.rescueStatus == HKCommissionCanceled) {
            statusLabel.text = @"已取消";
            executeButton.hidden = YES;
        }
        
        executeButton.layer.borderColor = rightButtonColor.CGColor;
        executeButton.layer.borderWidth = 0.5;
        executeButton.layer.cornerRadius = 3;
        [executeButton setTitleColor:rightButtonColor forState:UIControlStateNormal];
        executeButton.layer.masksToBounds = YES;
        
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
