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
#import "DeleteMyGroupOp.h"
#import "MutualInsPicUpdateVC.h"

@interface MutualInsHomeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)NSString * autoGroupName;
@property (nonatomic, strong)NSString * autoGroupdesc;
@property (nonatomic, strong)NSString * selfGroupName;
@property (nonatomic, strong)NSString * selfGroupdesc;

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
    [self setupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupTableView
{
    self.tableView.hidden = YES;
    [self.tableView.refreshView addTarget:self action:@selector(requestMyGourpInfo) forControlEvents:UIControlEventValueChanged];
    
    [self requestConfigInfo];
    [self requestMyGourpInfo];
}

#pragma mark - Utilitly
- (void)requestConfigInfo
{
    GetCooperationConfiOp * op = [GetCooperationConfiOp operation];
    [[[op rac_postRequest] initially:^{
        self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetCooperationConfiOp * op)  {
        
        self.autoGroupName = op.rsp_autogroupname;
        self.autoGroupdesc = op.rsp_autogroupdesc;
        self.selfGroupName = op.rsp_selfgroupname;
        self.selfGroupdesc = op.rsp_selfgroupdesc;
        
        [self.tableView reloadData];
        
        [self requestMyGourpInfo];
    } error:^(NSError *error) {
        
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        @weakify(self);
        [self.view showDefaultEmptyViewWithText:@"小马互助首页获取失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [self.view hideDefaultEmptyView];
            [self requestConfigInfo];
        }];
    }];
}

- (void)requestMyGourpInfo
{
    if (gAppMgr.myUser) {
        
        GetCooperationMyGroupOp * op = [[GetCooperationMyGroupOp alloc] init];
        @weakify(self);
        [[op rac_postRequest] subscribeNext:^(GetCooperationMyGroupOp * rop) {
            
            @strongify(self);
            self.tableView.hidden = NO;
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
            
            self.myGroupArray = [[NSMutableArray alloc] initWithArray:rop.rsp_groupArray];
            [self.tableView reloadData];
        }error:^(NSError *error) {
            
            self.tableView.hidden = YES;
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
            [gToast showError:error.domain];
        }];
    }
    else {
        self.tableView.hidden = NO;
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
    }
}


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
        HKMutualGroup * group = [self.myGroupArray safetyObjectAtIndex:indexPath.row - 4];
        vc.group = group;
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
        titleLabel.text = self.selfGroupName;
        detailLabel.text = self.selfGroupdesc;
    }
    else {
        leftView.backgroundColor = HEXCOLOR(@"#38B3FF");
        logoImgV.image = [UIImage imageNamed:@"mutualIns_home_match"];
        titleLabel.text = self.autoGroupName;
        detailLabel.text = self.autoGroupdesc;
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
