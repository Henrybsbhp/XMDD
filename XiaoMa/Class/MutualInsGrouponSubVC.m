//
//  MutualInsGrouponSubVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponSubVC.h"
#import "CKDatasource.h"
#import "NSString+RectSize.h"
#import "GetCooperationMemberDetailOp.h"
#import "NSString+Format.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "ApplyCooperationPremiumCalculateOp.h"
#import "HKTimer.h"

#import "MutualInsGrouponCarsCell.h"
#import "HKProgressView.h"
#import "PullDownAnimationButton.h"
#import "WaterWaveProgressView.h"

#import "CarListVC.h"
#import "MutualInsAlertVC.h"
#import "MutualInsGrouponMembersVC.h"
#import "MutualInsPicUpdateVC.h"
#import "MutualInsOrderInfoVC.h"
#import "MutualInsChooseVC.h"


@interface MutualInsGrouponSubVC ()
@property (nonatomic, strong) CKList *allItems;
@property (nonatomic, strong) CKList *datasource;

@property (nonatomic, assign) MutInsStatus status;
@end

@implementation MutualInsGrouponSubVC

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isExpanded = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reload
- (void)reloadDataWithStatus:(MutInsStatus)status
{
    self.status = status;
    CKList *datasource;
    if (status == MutInsStatusNeedDriveLicense || status == MutInsStatusNeedInsList) {
        datasource = $([self carsItem],[self splitLine1Item], [self arrowItem], [self descItem], [self timeItem],
                       [self buttonItem], [self bottomItem]);
    }
    else if (status == MutInsStatusUnderReview || status == MutInsStatusReviewFailed || status == MutInsStatusNeedQuote) {
        datasource = $([self carsItem],[self splitLine1Item], [self arrowItem], [self descItem], [self timeItem], [self bottomItem]);
    }
    else if (status == MutInsStatusNeedReviewAgain || status == MutInsStatusAccountingPrice || status == MutInsStatusPeopleNumberUment) {
        datasource = $([self carsItem],[self splitLine1Item], [self arrowItem], [self descItem], [self timeItem],
                       [self buttonItem], [self bottomItem]);
    }
    else if (status == MutInsStatusToBePaid) {
        
        datasource = $([self carsItem], [self splitLine2Item], [self arrowItem], [self waterWaveItem], [self descItem],
                       [self timeItem], [self buttonItem], [self bottomItem]);
    }
    else if (status == MutInsStatusPaidForSelf) {
        datasource = $([self carsItem], [self splitLine2Item], [self waterWaveItem], [self descItem], [self timeItem],
                       [self bottomItem]);
    }
    else {
        datasource = $([self carsItem], [self splitLine2Item], [self waterWaveItem], [self descItem], [self bottomItem]);
    }
    self.datasource = datasource;
    [self.tableView reloadData];

    //计算tableView总的打开时的高度和关闭时的高度
    NSInteger j = [datasource indexOfObjectForKey:@"Desc"];
    CGFloat height1 = 0, height2 = 0;
    for (NSInteger i = 0; i < j; i++) {
        CKDict *curitem = datasource[i];
        CKCellGetHeightBlock getHeight = curitem[kCKCellGetHeight];
        height1 += getHeight(curitem, [NSIndexPath indexPathForRow:i inSection:0]);
    }
    for (NSInteger i = j; i < [datasource count]; i++) {
        CKDict *curitem = datasource[i];
        CKCellGetHeightBlock getHeight = curitem[kCKCellGetHeight];
        height2 += getHeight(curitem, [NSIndexPath indexPathForRow:i inSection:0]);
    }
    self.expandedHeight = height1 + height2;
    self.closedHeight = height2;
}

#pragma mark - Action
- (void)actionGotoMembersVC
{
    MutualInsGrouponMembersVC *vc = [MutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponMembersVC"];
    vc.members = self.groupDetail.rsp_members;
    vc.title = self.title;
    [self.parentViewController.navigationController pushViewController:vc animated:YES];
}

- (void)actionShowMemberAlertView:(GetCooperationMemberDetailOp *)op
{
    MutualInsAlertVC *alert = [[MutualInsAlertVC alloc] init];
    alert.topTitle = op.rsp_licensenumber;
    alert.actionItems = @[[HKAlertActionItem itemWithTitle:@"确定"]];
    NSArray *items;
    if (op.rsp_sharemoney > 0) {
        items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:op.rsp_licensenumber
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:op.rsp_carbrand
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"互助资金" detailTitle:[NSString formatForRoundPrice2:op.rsp_sharemoney]
                                          detailColor:MutInsOrangeColor],
                  [MutualInsAlertVCItem itemWithTitle:@"所占比例" detailTitle:op.rsp_rate
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"目前可返" detailTitle:[NSString formatForRoundPrice2:op.rsp_returnmoney]
                                          detailColor:MutInsOrangeColor],
                  [MutualInsAlertVCItem itemWithTitle:@"出现次数" detailTitle:[NSString stringWithFormat:@"%d次", op.rsp_claimcount]
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"理赔金额" detailTitle:[NSString formatForRoundPrice2:op.rsp_claimamount]
                                          detailColor:MutInsOrangeColor]];
    }
    else {
        items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:op.rsp_licensenumber
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:op.rsp_carbrand
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"互助资金" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"所占比例" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"目前可返" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"出现次数" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"理赔金额" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor]];
    }
    alert.items = items;
    [alert showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
        [alertView dismiss];
    }];
}

- (void)actionImproveCarInfo {
    CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
    vc.title = @"选择爱车";
    vc.model.allowAutoChangeSelectedCar = YES;
    vc.model.disableEditingCar = YES; //不可修改
    vc.canJoin = YES; //用于控制爱车页面底部view
    @weakify(self);
    [vc setFinishPickActionForMutualIns:^(HKMyCar *car,UIView * loadingView) {
        @strongify(self);
        [self requestApplyJoinGroup:self.groupDetail.rsp_groupid andCarId:car.carId andLoadingView:loadingView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionImproveDrivingLicenseInfo {
    MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
    vc.originVC = self.parentViewController;
    vc.memberId = self.groupDetail.req_memberid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionImproveCoverageInfo {
    MutualInsChooseVC * vc = [UIStoryboard vcWithId:@"MutualInsChooseVC" inStoryboard:@"MutualInsJoin"];
    vc.memberId = self.groupDetail.req_memberid;
    vc.originVC = self.parentViewController;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCheckPrice {
    ApplyCooperationPremiumCalculateOp *op = [ApplyCooperationPremiumCalculateOp operation];
    op.req_groupid = self.groupDetail.rsp_groupid;
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在核价..."];
    }] subscribeNext:^(id x) {
        [gToast showSuccess:@"核价成功"];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (void)actionPay {
    MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
    vc.contractId = self.groupDetail.rsp_contractid;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Request
- (void)requestDetailInfoForMember:(NSNumber *)memberid
{
    GetCooperationMemberDetailOp *op = [GetCooperationMemberDetailOp operation];
    op.req_memberid = memberid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"获取信息..."];
    }] subscribeNext:^(GetCooperationMemberDetailOp *op) {
        @strongify(self);
        [gToast dismiss];
        [self actionShowMemberAlertView:op];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (void)requestApplyJoinGroup:(NSNumber *)groupId andCarId:(NSNumber *)carId andLoadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        [self.parentViewController.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain inView:view];
    }];
}

#pragma mark - CellItem
- (id)carsItem
{
    //如果没有成员，忽略
    if (self.groupDetail.rsp_members.count == 0) {
        return CKNULL;
    }
    NSArray *members = [self.groupDetail.rsp_members sortedArrayUsingComparator:^NSComparisonResult(MutualInsMemberInfo *obj1, MutualInsMemberInfo *obj2) {
        if ([obj1.memberid isEqual:self.groupDetail.req_memberid]) {
            return NSOrderedAscending;
        }
        else if ([obj2.memberid isEqual:self.groupDetail.req_memberid]) {
            return NSOrderedDescending;
        }
        else {
            return [obj1.memberid compare:obj2.memberid];
        }
    }];
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Cars"}];
    @weakify(self);
    item[@"members"] = members;
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 72;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        MutualInsGrouponCarsCell *cardsCell = (MutualInsGrouponCarsCell *)cell;
        [cardsCell setupWithCellBounds:CGRectMake(0, 0, self.tableView.frame.size.width, 72)];
        [cardsCell setCars:data[@"members"]];
        [cardsCell setCarDidSelectedBlock:^(MutualInsMemberInfo *info) {
            @strongify(self);
            if (!info) {
                [self actionGotoMembersVC];
            }
            else {
                [self requestDetailInfoForMember:info.memberid];
            }
        }];
    });
    return item;
}

- (CKDict *)splitLine1Item
{
    NSString *amount = [NSString stringWithFormat:@"共%d车", (int)[self.groupDetail.rsp_members count]];
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Line1", @"amount":amount}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 28;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        CKLine *lineV = [cell viewWithTag:1001];
        UIButton *amountB = [cell viewWithTag:1002];
        
        lineV.lineColor = MutInsLineColor;
        [amountB setTitle:[@" " append:item[@"amount"]] forState:UIControlStateNormal];
    });
    return item;
}

- (CKDict *)splitLine2Item
{
    NSString *amount = [NSString stringWithFormat:@"共%d车", (int)[self.groupDetail.rsp_members count]];
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Line2", @"time":self.groupDetail.rsp_timeperiod, @"amount":amount}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 36;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        CKLine *lineV = [cell viewWithTag:1001];
        UIButton *timeB = [cell viewWithTag:1002];
        UIButton *amountB = [cell viewWithTag:1003];
        
        lineV.lineColor = MutInsLineColor;
        
        timeB.hidden = [item[@"time"] length] == 0;
        [timeB setTitle:[@" " append:item[@"time"]] forState:UIControlStateNormal];
        [amountB setTitle:[@" " append:item[@"amount"]] forState:UIControlStateNormal];
    });
    return item;
}

- (CKDict *)arrowItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Arrow"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *arrowV = [cell viewWithTag:1001];
        arrowV.normalTextColor = MutInsTextLightGrayColor;
        arrowV.normalColor = MutInsBgColor;
        arrowV.titleArray = @[@"上传",@"审核",@"报价",@"支付"];
        arrowV.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.groupDetail.rsp_barstatus)];
    });
    return item;
}

- (CKDict *)waterWaveItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Wave"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 168;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        WaterWaveProgressView *waveV = [cell viewWithTag:1001];
        
        waveV.titleLable.text = @"资金池";
        waveV.subTitleLabel.text = [NSString stringWithFormat:@"%@/%@",
                                    self.groupDetail.rsp_presentpoolamt, self.groupDetail.rsp_totalpoolamt];
        [waveV startWave];
        [waveV showArcLightOnce];
        CGFloat progress = [self.groupDetail.rsp_presentpoolamt floatValue] / MAX(0.01, [self.groupDetail.rsp_totalpoolamt floatValue]);
        [waveV setProgress:progress withAnimation:YES];
        //cell被重用的时候停止动画
        [[cell rac_prepareForReuseSignal] subscribeNext:^(id x) {
            [waveV stopWave];
        }];
        
        [[RACObserve(self, shouldStopWaveView) takeUntilForCell:cell] subscribeNext:^(NSNumber *stop) {
            if ([stop boolValue]) {
                [waveV setProgress:0 withAnimation:NO];
            }
        }];
        
        [[RACObserve(self, isExpanded) takeUntilForCell:cell] subscribeNext:^(NSNumber *expanded) {
            if ([expanded boolValue]) {
                [waveV showArcLightOnce];
                [waveV setProgress:progress withAnimation:YES];
            }
        }];
    });
    return item;
}

- (CKDict *)descItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Desc",@"text":self.groupDetail.rsp_selfstatusdesc}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CGFloat width = self.tableView.frame.size.width - 40;
        CGSize size = [data[@"text"] labelSizeWithWidth:width font:[UIFont systemFontOfSize:15]];
        return MAX(25, ceil(size.height+10));
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *label = [cell viewWithTag:1001];
        label.text = data[@"text"];
    });
    return item;
}

- (CKDict *)timeItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Time"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 26;
    });
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIButton *timeB = [cell viewWithTag:1001];
        CKLine *leftL = [cell viewWithTag:1002];
        CKLine *rightL = [cell viewWithTag:1003];
        
        leftL.lineColor = MutInsGreenColor;
        rightL.lineColor = MutInsGreenColor;
        if (self.groupDetail.rsp_lefttime <= 0) {
            NSString *text = [HKTimer ddhhmmFormatWithTimeInterval:0];
            text = [NSString stringWithFormat:@" %@%@", self.groupDetail.rsp_timetip, text];
            [timeB setTitle:text forState:UIControlStateNormal];
        }
        else {
            [[[HKTimer rac_startWithOrigin:self.groupDetail.rsp_lefttime/1000 andTimeTag:self.groupDetail.tempTimetag]
              takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber *interval) {
                NSString *text = [HKTimer ddhhmmFormatWithTimeInterval:[interval doubleValue]];
                text = [NSString stringWithFormat:@" %@%@", self.groupDetail.rsp_timetip, text];
                [timeB setTitle:text forState:UIControlStateNormal];
            }];
         }
     });
    return item;
}

- (CKDict *)buttonItem
{
    NSString *key = @"Button1";
    if (self.groupDetail.rsp_pricebuttonflag > 0) {
        key = @"Button2";
    }
    CKDict *item = [CKDict dictWith:@{kCKItemKey:key}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIButton *button1 = [cell viewWithTag:1001];
        UIButton *button2 = [cell viewWithTag:1002];
        
        [button1 setTitle:self.groupDetail.rsp_buttonname forState:UIControlStateNormal];
        [[[button1 rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             MutInsStatus status = self.status;
             if (status == MutInsStatusNeedCar) {
                 [self actionImproveCarInfo];
             }
             else if (status == MutInsStatusNeedDriveLicense) {
                 [self actionImproveDrivingLicenseInfo];
             }
             else if (status == MutInsStatusNeedInsList) {
                 [self actionImproveCoverageInfo];
             }
             else if (status == MutInsStatusAccountingPrice) {
                 [self actionCheckPrice];
             }
             else if (status == MutInsStatusToBePaid) {
                 [self actionPay];
             }
        }];
        
        [[[button2 rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionCheckPrice];
        }];
    });
    return item;
}

- (CKDict *)bottomItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Bottom"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    @weakify(self);
    item[kCKCellPrepare]= CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        PullDownAnimationButton *arrowV = [cell viewWithTag:1001];
        UIImageView *edgeV = [cell viewWithTag:1002];
        
        [arrowV setPulled:self.isExpanded withAnimation:NO];
        
        [[[RACObserve(self, isExpanded) takeUntilForCell:cell] skip:1] subscribeNext:^(id x) {
            @strongify(self);
            CKAfter(0.2, ^{
                [arrowV setPulled:self.isExpanded withAnimation:YES];
            });
        }];

        [[[arrowV rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(PullDownAnimationButton *btn) {
             @strongify(self);
             BOOL expanded = !self.isExpanded;
             self.isExpanded = expanded;
             if (self.shouldExpandedOrClosed) {
                 self.shouldExpandedOrClosed(expanded);
             }
        }];

        if (!edgeV.image) {
            edgeV.image = [[UIImage imageNamed:@"mins_edge"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 8, 1)];
        }
    });
    return item;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [self.datasource objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight]) {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [self.datasource objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKItemKey]];
    if (item[kCKCellPrepare]) {
        ((CKCellPrepareBlock)item[kCKCellPrepare])(item, cell, indexPath);
    }
    if ([cell isKindOfClass:[HKTableViewCell class]]) {
        HKTableViewCell *hkcell = (HKTableViewCell *)cell;
        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentVerticalLeft insets:UIEdgeInsetsZero];
        [hkcell addOrUpdateBorderLineWithAlignment:CKLineAlignmentVerticalRight insets:UIEdgeInsetsZero];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [self.datasource objectAtIndex:indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}


@end
