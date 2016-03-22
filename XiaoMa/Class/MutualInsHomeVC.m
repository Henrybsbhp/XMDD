//
//  MutualInsHomeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeVC.h"
#import "AutoGroupInfoVC.h"
#import "GroupIntroductionVC.h"
#import "MutualInsGrouponVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsAskClaimsVC.h"
#import "GetCooperationConfiOp.h"
#import "GetCooperationMyGroupOp.h"
#import "HKMutualGroup.h"
#import "HKTimer.h"
#import "MutualInsStore.h"
#import "DeleteMyGroupOp.h"
#import "MutualInsPicUpdateVC.h"
#import "UIView+JTLoadingView.h"

@interface MutualInsHomeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GetCooperationConfiOp *config;
@property (nonatomic, strong) MutualInsStore *minsStore;
@property (nonatomic, strong)NSMutableArray * myGroupArray;

@property (nonatomic, assign)NSTimeInterval leftTime;

@end

@implementation MutualInsHomeVC

-(void)dealloc
{
    DebugLog(@"MutualInsHomeVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMutualInsStore];
    self.tableView.hidden = YES;
    CKAsyncMainQueue(^{
        [self reloadIfNeeded];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupMutualInsStore
{
    self.minsStore = [MutualInsStore fetchOrCreateStore];
    @weakify(self);
    [self.minsStore subscribeWithTarget:self domain:kDomainMutualInsSimpleGroups receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        [self reloadFormSignal:evt.signal];
    }];
}

- (void)resetTableView
{
    if (![self.tableView isRefreshViewExists]) {
        @weakify(self);
        [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
            @strongify(self);
            [[self.minsStore reloadSimpleGroups] send];
        }];
    }
    self.tableView.hidden = NO;
}

#pragma mark - Reload
- (void)reloadFormSignal:(RACSignal *)signal
{
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else if (![self.view isActivityAnimating]) {
            self.tableView.hidden = YES;
            self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
    }] subscribeNext:^(id x) {

        @strongify(self);
        if (self.minsStore.simpleGroups) {
            self.myGroupArray = [NSMutableArray arrayWithArray:self.minsStore.simpleGroups.allObjects];
        }
        if ([self reloadIfNeeded]) {
            if ([self.tableView isRefreshViewExists]) {
                [self.tableView.refreshView endRefreshing];
            }
            else {
                [self.view stopActivityAnimation];
                [self resetTableView];
            }
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            [self.view stopActivityAnimation];
            [self.view showDefaultEmptyViewWithText:@"获取信息失败，点击重试" tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self reloadIfNeeded];
            }];
        }
    }];
}

- (BOOL)reloadIfNeeded
{
    @weakify(self);
    if (!self.config) {
        RACSignal *signal = [[[GetCooperationConfiOp operation] rac_postRequest] doNext:^(id x) {
            @strongify(self);
            self.config = x;
        }];
        [self reloadFormSignal:signal];
        return NO;
    }
    
    if (!self.myGroupArray) {
        [[self.minsStore reloadSimpleGroups] send];
        return NO;
    }

    [self.tableView reloadData];
    return YES;
}

#pragma mark - Utilitly
- (void)operationBtnAction:(id)opeBtn withGroup:(HKMutualGroup * )group withIndexPath:(NSIndexPath *)indexPath
{
    if (group.btnStatus == GroupBtnStatusInvite) {
        
        InviteByCodeVC * vc = [UIStoryboard vcWithId:@"InviteByCodeVC" inStoryboard:@"MutualInsJoin"];
        vc.groupId = group.groupId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (group.btnStatus == GroupBtnStatusDelete){
        
        //删除我的团操作 团长和团员调用新接口，入参不同
        DeleteMyGroupOp * op = [DeleteMyGroupOp operation];
        op.memberId = group.memberId;
        op.groupId = group.groupId;
        [[[op rac_postRequest] initially:^{
            [gToast showingWithText:@"删除中..."];
        }] subscribeNext:^(id x) {
            [gToast dismiss];
            [self.myGroupArray safetyRemoveObjectAtIndex:(indexPath.row - 4)];
            if (self.myGroupArray.count == 0) {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section], indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
//            [self.tableView reloadData];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 + (self.myGroupArray.count ? (self.myGroupArray.count + 1) : 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        return 60;
    }
    else if (indexPath.row == 3) {
        return 50;
    }
    else if (indexPath.row > 3) {
        return 161;
    }
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0 || indexPath.row == 1)
    {
        cell = [self groupCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 2) {
        cell = [self btnCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 3) {
        cell = [self sectionCellAtIndexPath:indexPath];
    }
    else{
        cell = [self myGroupCellCellAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
        vc.titleStr = @"自主团介绍";
        vc.groupType = MutualGroupTypeSelf;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1)
    {
        AutoGroupInfoVC * vc = [UIStoryboard vcWithId:@"AutoGroupInfoVC" inStoryboard:@"MutualInsJoin"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row > 3) {
        //我的团详情页面
        MutualInsGrouponVC *vc = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
        vc.group = [self.myGroupArray safetyObjectAtIndex:indexPath.row - 4];
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - About Cell
- (UITableViewCell *)groupCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupTypeCell" forIndexPath:indexPath];
    UIView *leftView = (UIView *)[cell.contentView viewWithTag:1001];
    UIImageView *logoImgV = (UIImageView *)[cell.contentView viewWithTag:1002];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *detailLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    
    if (indexPath.row == 0) {
        leftView.backgroundColor = HEXCOLOR(@"#FFBA36");
        logoImgV.image = [UIImage imageNamed:@"mutualIns_home_self"];
        titleLabel.text = self.config.rsp_selfgroupname;
        detailLabel.text = self.config.rsp_selfgroupdesc;
    }
    else {
        leftView.backgroundColor = HEXCOLOR(@"#38B3FF");
        logoImgV.image = [UIImage imageNamed:@"mutualIns_home_match"];
        titleLabel.text = self.config.rsp_autogroupname;
        detailLabel.text = self.config.rsp_autogroupdesc;
    }
    
    return cell;
}

- (UITableViewCell *)btnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BtnCell" forIndexPath:indexPath];
    UIButton *checkBtn = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *payBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    
    //我要核价
    [[[checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
    }];
    //我要理赔
    @weakify(self);
    [[[payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        MutualInsAskClaimsVC *vc = [UIStoryboard vcWithId:@"MutualInsAskClaimsVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }];
    
    return cell;
}

- (UITableViewCell *)sectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SectionCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)myGroupCellCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyGroupCell" forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *carIdLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    UIButton *opeBtn = (UIButton *)[cell.contentView viewWithTag:1005];
    
    HKMutualGroup * group = [self.myGroupArray safetyObjectAtIndex:indexPath.row - 4];
    
    nameLabel.text = group.groupName;
    carIdLabel.text = group.licenseNumber;
    statusLabel.text = group.statusDesc;
    
    if ([group.leftTime integerValue] != 0)
    {
        RACDisposable * disp = [[[HKTimer rac_timeCountDownWithOrigin:[group.leftTime integerValue] / 1000 andTimeTag:group.leftTimeTag] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * timeStr) {
            timeLabel.text = [NSString stringWithFormat:@"%@ \n%@", group.tip, timeStr];
        }];
        [[self rac_deallocDisposable] addDisposable:disp];
    }
    else if (group.contractperiod.length != 0)
    {
        timeLabel.text = [NSString stringWithFormat:@"%@ \n%@", group.tip, group.contractperiod];
    }
    else {
        timeLabel.text = @"";
    }
    
    opeBtn.hidden = !(group.btnStatus == GroupBtnStatusInvite || group.btnStatus == GroupBtnStatusDelete);
    
    if (group.btnStatus)
    {
        if (group.btnStatus == GroupBtnStatusInvite) {
            [opeBtn setTitle:@"邀请好友" forState:UIControlStateNormal];
            [opeBtn setBackgroundColor:HEXCOLOR(@"#18D06A")];
        }
        else if (group.btnStatus == GroupBtnStatusDelete){
            [opeBtn setTitle:@"删除" forState:UIControlStateNormal];
            [opeBtn setBackgroundColor:HEXCOLOR(@"#FF4E70")];
        }
        @weakify(self);
        [[[opeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            [self operationBtnAction:x withGroup:group withIndexPath:indexPath];
        }];
    }
    return cell;
}



@end
