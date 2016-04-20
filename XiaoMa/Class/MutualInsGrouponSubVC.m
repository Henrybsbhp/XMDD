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
#import "HKTimer.h"
#import "NSString+Format.h"

#import "GetCooperationMemberDetailOp.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "ApplyCooperationPremiumCalculateOp.h"
#import "CheckCooperationPremiumOp.h"


#import "MutualInsGrouponCarsCell.h"
#import "HKProgressView.h"
#import "PullDownAnimationButton.h"
#import "WaterWaveProgressView.h"
#import "MutualInsStore.h"

#import "HKImageAlertVC.h"
#import "PickCarVC.h"
#import "MutualInsAlertVC.h"
#import "MutualInsGrouponMembersVC.h"
#import "MutualInsPicUpdateVC.h"
#import "MutualInsOrderInfoVC.h"
#import "EstimatedPriceVC.h"
#import "EditCarVC.h"


@interface MutualInsGrouponSubVC ()
@property (nonatomic, strong) CKList *allItems;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) NSArray *sortedMembers;
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
    self.sortedMembers = [self sortAndFilterMembers:self.groupDetail.rsp_members];
    CKList *datasource;
    if (status == MutInsStatusNeedCar || status == MutInsStatusNeedDriveLicense || status == MutInsStatusNeedInsList ||
        status == MutInsStatusUnderReview || status == MutInsStatusNeedReviewAgain || status == MutInsStatusReviewFailed ||
        status == MutInsStatusNeedQuote || status == MutInsStatusAccountingPrice || status == MutInsStatusPeopleNumberUment) {
        
        datasource = $([self carsItem],[self splitLineItem], [self arrowItem], [self waterWaveItem], [self descItem],
                       [self timeItem], [self buttonItem], [self bottomItem]);
    }
    else if (status == MutInsStatusToBePaid) {
        
        datasource = $([self carsItem], [self splitLineItem], [self arrowItem], [self waterWaveItem], [self descItem],
                       [self timeItem], [self buttonItem], [self bottomItem]);
    }
    else if (status == MutInsStatusPaidForSelf || status == MutInsStatusPaidForAll ||
             status == MutInsStatusGettedAgreement || status == MutInsStatusAgreementTakingEffect) {
        datasource = $([self carsItem], [self splitLineItem], [self arrowItem], [self waterWaveItem], [self descItem],
                       [self timeItem], [self buttonItem], [self bottomItem]);
    }
    else {
        datasource = $([self carsItem], [self splitLineItem], [self arrowItem], [self waterWaveItem], [self descItem],
                       [self timeItem], [self buttonItem], [self bottomItem]);
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
- (void)actionGotoMembersVCWithMembers:(NSArray *)members
{
    MutualInsGrouponMembersVC *vc = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponMembersVC"];
    vc.members = members;
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
        items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:op.rsp_phone
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:op.rsp_carbrand.length > 0 ? op.rsp_carbrand : @"暂无"
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
        items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:op.rsp_phone
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:op.rsp_carbrand.length > 0 ? op.rsp_carbrand : @"暂无"
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
    [alert show];
}

- (void)actionImproveCarInfo {
    [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0005"}];
    PickCarVC *vc = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
    vc.isShowBottomView = YES;
    @weakify(self);
    [vc setFinishPickCar:^(MyCarListVModel *carModel, UIView * loadingView) {
        @strongify(self);
        //爱车页面入团按钮委托实现
        [self requestApplyJoinGroup:self.groupDetail.rsp_groupid andCarModel:carModel andLoadingView:loadingView];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionImproveDrivingLicenseInfo {
    [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0005"}];
    MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
    vc.originVC = self.parentViewController;
    vc.memberId = self.groupDetail.req_memberid;
    vc.groupId = self.groupDetail.req_groupid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionImproveCoverageInfo {
    [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0005"}];
    EstimatedPriceVC * vc = [UIStoryboard vcWithId:@"EstimatedPriceVC" inStoryboard:@"MutualInsJoin"];
    vc.memberId = self.groupDetail.req_memberid;
    vc.groupId = self.groupDetail.req_groupid;
    vc.groupName = self.groupDetail.rsp_groupname;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCheckPrice {
    CheckCooperationPremiumOp *op = [CheckCooperationPremiumOp operation];
    op.req_groupid = self.groupDetail.req_groupid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在核价..."];
    }] subscribeNext:^(CheckCooperationPremiumOp *op) {
        
        @strongify(self);
        //存在审核中的车辆,需要提示弹框
        if (op.rsp_licensenumbers.count > 0) {
            [gToast dismiss];
            NSString *msg = [self messageForUnderReviewLicenseNumbers:op.rsp_licensenumbers];
            [self showAlertForRequestPremiumCalculateWithMessage:msg];
        }
        //存在未审核的车辆,需要提示弹框
        else if (op.rsp_inprocesslisnums.count > 0) {
            [gToast dismiss];
            NSString *msg = [self messageForNotBeginReviewLicenseNumbers:op.rsp_inprocesslisnums];
            [self showAlertForRequestPremiumCalculateWithMessage:msg];
        }
        //否则就直接报价
        else {
            [self requestPremiumCalculate];
        }
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

- (void)actionPay {
    [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0011"}];
    MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
    vc.contractId = self.groupDetail.rsp_contractid;
    vc.group = self.group;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Alert
- (NSString *)messageForUnderReviewLicenseNumbers:(NSArray *)licenseNumbers
{
    NSArray *subNumbers = [licenseNumbers subarrayToIndex:MIN(2, licenseNumbers.count-1)];
    NSString *strNumbers = [subNumbers componentsJoinedByString:@"、"];
    if (subNumbers.count < 3) {
        return [NSString stringWithFormat:@"您的团中，%@的车还在审核中，若您执意报价，审核中的车辆将无法加入本团，是否继续报价？", strNumbers];
    }
    else {
        return [NSString stringWithFormat:@"您的团中，%@等%d辆车还在审核中，若您执意报价，审核中的车辆将无法加入本团，是否继续报价？",
                strNumbers, (int)licenseNumbers.count];
    }
}

- (NSString *)messageForNotBeginReviewLicenseNumbers:(NSArray *)licenseNumbers
{
    NSArray *subNumbers = [licenseNumbers subarrayToIndex:MIN(2, licenseNumbers.count-1)];
    NSString *strNumbers = [subNumbers componentsJoinedByString:@"、"];
    if (subNumbers.count < 3) {
        return [NSString stringWithFormat:@"您的团中，%@的车还未提交审核，若您执意报价，未审核的车辆将无法加入本团，是否继续报价？", strNumbers];
    }
    else {
        return [NSString stringWithFormat:@"您的团中，%@等%d辆车还未提交审核，若您执意报价，未审核的车辆将无法加入本团，是否继续报价？",
                strNumbers, (int)licenseNumbers.count];
    }
}

- (void)showAlertForRequestPremiumCalculateWithMessage:(NSString *)msg
{
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"温馨提示";
    alert.imageName = @"mins_bulb";
    alert.message = msg;
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"再等一下" color:MutInsTextGrayColor clickBlock:nil];
    @weakify(self);
    HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"直接报价" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        @strongify(self);
        [self requestPremiumCalculate];
    }];
    alert.actionItems = @[cancel, improve];
    [alert show];
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

- (void)requestApplyJoinGroup:(NSNumber *)groupId andCarModel:(MyCarListVModel *)carModel andLoadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carModel.selectedCar.carId;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = rop.req_groupid;
        [self.parentViewController.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
        if (error.code == 6115804) {
            [gToast dismissInView:view];
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = error.domain;
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
            @weakify(self);
            HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                carModel.originVC = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
                vc.originCar = carModel.selectedCar;
                vc.model = carModel;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            alert.actionItems = @[cancel, improve];
            [alert show];
        }
        else {
            [gToast showError:error.domain inView:view];
        }
    }];
}

- (void)requestPremiumCalculate
{
    ApplyCooperationPremiumCalculateOp *op = [ApplyCooperationPremiumCalculateOp operation];
    op.req_groupid = self.groupDetail.rsp_groupid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在核价..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast showSuccess:@"核价成功"];
        MutualInsStore *store = [MutualInsStore fetchExistsStore];
        [[store reloadSimpleGroups] sendAndIgnoreError];
        [[store reloadDetailGroupByMemberID:self.groupDetail.req_memberid andGroupID:self.groupDetail.rsp_groupid] sendAndIgnoreError];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - Util
- (NSArray *)sortAndFilterMembers:(NSArray *)members
{
    NSMutableArray *newMembers = [NSMutableArray array];
    for (MutualInsMemberInfo *member in members) {
        if (member.showflag) {
            [newMembers addObject:member];
        }
    }
    return  [newMembers sortedArrayUsingComparator:^NSComparisonResult(MutualInsMemberInfo *obj1, MutualInsMemberInfo *obj2) {
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
}


#pragma mark - CellItem
- (id)carsItem
{
    NSArray *members = self.sortedMembers;
    //如果没有成员，忽略
    if (members.count == 0) {
        return CKNULL;
    }

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
                [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0003"}];
                [self actionGotoMembersVCWithMembers:data[@"members"]];
            }
            else {
                [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0004"}];
                [self requestDetailInfoForMember:info.memberid];
            }
        }];
    });
    return item;
}

- (id)splitLineItem
{
    if (self.groupDetail.rsp_timeperiod.length == 0) {
        return [self splitLine1Item];
    }
    return [self splitLine2Item];
}

- (id)splitLine1Item
{
    if (self.sortedMembers.count == 0) {
        return CKNULL;
    }
    NSString *amount = [NSString stringWithFormat:@"共%d车", (int)[self.sortedMembers count]];
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

- (id)splitLine2Item
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Line2", @"time":self.groupDetail.rsp_timeperiod,
                                      @"amount":@([self.sortedMembers count])}];
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
        
        NSString *strAmount = [NSString stringWithFormat:@"共%@车", data[@"amount"]];
        [amountB setTitle:[@" " append:strAmount] forState:UIControlStateNormal];
        amountB.hidden = [data[@"amount"] integerValue] == 0;
    });
    return item;
}

- (id)arrowItem
{
    NSInteger index = [self indexOfProgressViewForBarStatus:self.groupDetail.rsp_barstatus];
    if (index == 0) {
        return CKNULL;
    }
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Arrow"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *arrowV = [cell viewWithTag:1001];
        arrowV.normalTextColor = MutInsTextLightGrayColor;
        arrowV.normalColor = MutInsBgColor;
        arrowV.titleArray = @[@"上传",@"审核",@"支付"];
        NSInteger index = [self indexOfProgressViewForBarStatus:self.groupDetail.rsp_barstatus];
        arrowV.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, index)];
    });
    return item;
}


- (NSInteger)indexOfProgressViewForBarStatus:(int)status
{
    if (status == 3) {
        return 0;
    }
    if (status > 3) {
        return status - 1;
    }
    return status;
}


- (id)waterWaveItem
{
    if (self.groupDetail.rsp_totalpoolamt == 0) {
        return CKNULL;
    }
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Wave"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 168;
    });
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        WaterWaveProgressView *waveV = [cell viewWithTag:1001];
        
        waveV.titleLable.text = @"资金池";
        waveV.subTitleLabel.text = [NSString stringWithFormat:@"%@/%@",
                                    [NSString formatForRoundPrice2:self.groupDetail.rsp_presentpoolamt],
                                    [NSString formatForRoundPrice2:self.groupDetail.rsp_totalpoolamt]];
        [waveV startWave];
        [waveV showArcLightOnce];
        CGFloat progress = self.groupDetail.rsp_presentpoolamt / MAX(0.01, self.groupDetail.rsp_totalpoolamt);
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

- (id)timeItem
{
    if (self.groupDetail.rsp_lefttime == 0) {
        return CKNULL;
    }
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
                NSString *text = [HKTimer ddhhmmssFormatWithTimeInterval:[interval doubleValue]];
                text = [NSString stringWithFormat:@" %@%@", self.groupDetail.rsp_timetip, text];
                [timeB setTitle:text forState:UIControlStateNormal];
            }];
         }
     });
    return item;
}

- (id)buttonItem
{
    if (self.groupDetail.rsp_buttonname.length == 0 && self.groupDetail.rsp_pricebuttonflag == 0) {
        return CKNULL;
    }
    NSString *key = @"Button1";
    if (self.groupDetail.rsp_buttonname.length > 0 && self.groupDetail.rsp_pricebuttonflag > 0) {
        key = @"Button2";
    }
    
    CKDict *item = [CKDict dictWith:@{kCKItemKey:key}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIButton *imporveButton;
        UIButton *priceButton;
        if (self.groupDetail.rsp_buttonname.length > 0 && self.groupDetail.rsp_pricebuttonflag > 0) {
            imporveButton = [cell viewWithTag:1001];
            priceButton = [cell viewWithTag:1002];
        }
        else if (self.groupDetail.rsp_pricebuttonflag > 0) {
            priceButton = [cell viewWithTag:1001];
        }
        else if (self.groupDetail.rsp_buttonname.length > 0) {
            imporveButton = [cell viewWithTag:1001];
        }
        
        [imporveButton setTitle:self.groupDetail.rsp_buttonname forState:UIControlStateNormal];
        [[[imporveButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             MutInsStatus status = self.status;
             if (status == MutInsStatusNeedCar) {
                 [self actionImproveCarInfo];
             }
             else if (status == MutInsStatusNeedDriveLicense || status == MutInsStatusNeedReviewAgain ||
                      status == MutInsStatusGroupExpired) {
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
        
        [priceButton setTitle:self.groupDetail.rsp_pricebuttonname forState:UIControlStateNormal];
        [[[priceButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
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
             if (!expanded) {
                 [MobClick event:@"xiaomahuzhu" attributes:@{@"tuanxiangqing":@"tuanxiangqing0006"}];
             }
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
