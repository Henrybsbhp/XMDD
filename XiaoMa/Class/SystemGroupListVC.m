//
//  AutoGroupInfoVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SystemGroupListVC.h"
#import "PickCarVC.h"
#import "GetCooperationAutoGroupOp.h"
#import "NSMutableDictionary+AddParams.h"
#import "UIView+JTLoadingView.h"
#import "MutualInsPicUpdateVC.h"
#import "ApplyCooperationGroupJoinOp.h"
#import "HKTimer.h"
#import "GroupIntroductionVC.h"
#import "UIView+RoundedCorner.h"
#import "NSString+RectSize.h"
#import "HKImageAlertVC.h"
#import "EditCarVC.h"

typedef NS_ENUM(NSInteger, GroupButtonState) {
    GroupButtonStateNotStart   = 1,
    GroupButtonStateSignUp     = 2,
    GroupButtonStateEndSign    = 3,
    GroupButtonStateBeingGroup = 4,
    GroupButtonStateTimeOut    = 5
};

///平台团列表
@interface SystemGroupListVC ()

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (nonatomic,strong)NSArray *autoGroupArray;

@end

@implementation SystemGroupListVC

-(void)dealloc
{
    DebugLog(@"SystemGroupListVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setRightBtnItem];
    [self setupTableView];
    [self loadFirstTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setRightBtnItem {
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"新手必点" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(actionHelp)];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupTableView {
    self.tableView.hidden = YES;
    [self.tableView.refreshView addTarget:self action:@selector(requestAutoGroupArray) forControlEvents:UIControlEventValueChanged];
}

- (void)loadFirstTime
{
    self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
    [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    
    @weakify(self);
    [[RACObserve(gAppMgr, myUser) distinctUntilChanged] subscribeNext:^(id x) {
        
        @strongify(self);
        [self requestAutoGroupArray];
    }];
}

- (void)actionHelp
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"新手必点";
    vc.url = @"http://www.baidu.com";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionBack:(id)sender
{
    if (self.originVC) {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [super actionBack:sender];
    }
}

#pragma mark - Utilitly
- (void)requestAutoGroupArray
{
    //有两个接口，根据登录状态调整接口参数
    GetCooperationAutoGroupOp * op = [[GetCooperationAutoGroupOp alloc] init];
    op.city = gMapHelper.addrComponent.city;
    op.province = gMapHelper.addrComponent.province;
    op.district = gMapHelper.addrComponent.district;
    @weakify(self);
    [[[op rac_postRequest] deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(GetCooperationAutoGroupOp * rop) {
         
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        self.autoGroupArray = rop.rsp_autoGroupArray;
        if (self.autoGroupArray.count)
        {
            for (int i = 0; i < self.autoGroupArray.count; i ++) {
                NSTimeInterval timeTag = [[NSDate date] timeIntervalSince1970];
                [self.autoGroupArray[i] setCustomObject:@(timeTag)];
            }
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView showDefaultEmptyViewWithText:@"马上推出，敬请期待"];
        }
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
    } error:^(NSError *error) {
        
        @strongify(self);
        self.tableView.hidden = NO;
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        
        [self.tableView showImageEmptyViewWithImageName:@"def_failConnect" text:@"列表请求失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestAutoGroupArray];
        }];
    }];
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.autoGroupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:section];
    if ([groupInfo stringParamForName:@"tip"].length == 0) {
        return 4;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 15;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //由于倒计时可能不存在，所以根据tip设置section中共有几行
    NSDictionary * dic = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    NSInteger numberOfRow = [dic stringParamForName:@"tip"].length == 0 ? 4 : 5;
    NSString * groupTips = [dic stringParamForName:@"grouprestrict"];
    NSString * memberTips = [dic stringParamForName:@"memberrestrict"];
    
    if (indexPath.row == 0) {
        return 42;
    }
    else if (indexPath.row == numberOfRow - 1) {
        return 50;
    }
    else if (indexPath.row == 1){
        CGFloat height = [groupTips labelSizeWithWidth:(self.tableView.frame.size.width - 66) font:[UIFont systemFontOfSize:12]].height;
        return height + 9;
    }
    else if (indexPath.row == 2){
        CGFloat height = [memberTips labelSizeWithWidth:(self.tableView.frame.size.width - 66) font:[UIFont systemFontOfSize:12]].height;
        return height + 9;
    }
    return 23;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self headerCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
        cell = [self footerCellAtIndexPath:indexPath];
    }
    else {
        cell = [self infoCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UIView * backgroundView = [cell searchViewWithTag:100];
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:101];
    UILabel * tagLb = (UILabel *)[cell searchViewWithTag:102];
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    
    [backgroundView setCornerRadius:3 withBackgroundColor:[UIColor whiteColor]];
    
    titleLb.text = [groupInfo stringParamForName:@"name"];
    tagLb.text = [NSString stringWithFormat:@"已有%ld入团",[groupInfo integerParamForName:@"membercnt"]];
    
    if ([groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateNotStart || [groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateEndSign) {
        tagLb.textColor = HEXCOLOR(@"#454545");
    }
    else {
        tagLb.textColor = HEXCOLOR(@"#18D06A");
    }
    return cell;
}

- (UITableViewCell *)infoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    if (indexPath.row == 1)
    {
        infoLabel.text = [groupInfo stringParamForName:@"grouprestrict"];
    }
    else if (indexPath.row == 2)
    {
        infoLabel.text = [groupInfo stringParamForName:@"memberrestrict"];
    }
    else
    {
        NSTimeInterval leftTime = [groupInfo integerParamForName:@"lefttime"] / 1000;
        @weakify(self);
        RACDisposable * disp = [[[HKTimer rac_timeCountDownWithOrigin:leftTime andTimeTag:[groupInfo.customObject doubleValue]] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * timeStr) {
            
            @strongify(self);
            if (![timeStr isEqualToString:@"end"]) {
                infoLabel.text = [NSString stringWithFormat:@"%@ %@", [groupInfo stringParamForName:@"tip"], timeStr];
            }
            else {
                [disp dispose];
                [self requestAutoGroupArray];
            }
            
        }];
        [[self rac_deallocDisposable] addDisposable:disp];
    }
    return cell;
}

- (UITableViewCell *)footerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"FooterCell" forIndexPath:indexPath];
    UIView *lineView = [cell.contentView viewWithTag:100];
    UIView *backgroundView = [cell.contentView viewWithTag:101];
    [lineView setCornerRadius:5 withBackgroundColor:HEXCOLOR(@"#EAEAEA")];
    [backgroundView setCornerRadius:5 withBackgroundColor:[UIColor whiteColor]];
    
    UILabel *tagLabel = [cell.contentView viewWithTag:1001];
    UIButton * btn = [cell.contentView viewWithTag:1002];
    UILabel *stateLabel = [cell.contentView viewWithTag:1003];
    
    NSDictionary * groupInfo = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    
    NSNumber * groupid = groupInfo[@"groupid"];
    NSString *groupname = groupInfo[@"name"];
    tagLabel.text = [NSString stringWithFormat:@"  %@  ", [groupInfo stringParamForName:@"grouptag"]];
    
    if ([groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateNotStart) {
        
        btn.hidden = NO;
        stateLabel.hidden = YES;
        
        [tagLabel setCornerRadius:12 withBorderColor:HEXCOLOR(@"#888888") borderWidth:0.8];
        tagLabel.textColor = HEXCOLOR(@"#888888");
        
        [btn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#dedfe0")];
        [btn setTitle:@"报名未开始" forState:UIControlStateNormal];
    }
    else if ([groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateSignUp) {
        
        btn.hidden = NO;
        stateLabel.hidden = YES;
        
        [tagLabel setCornerRadius:12 withBorderColor:HEXCOLOR(@"#ff7428") borderWidth:0.8];
        tagLabel.textColor = HEXCOLOR(@"#ff7428");
        
        [btn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#18D06A")];
        if ([groupInfo boolParamForName:@"ingroup"]) {
            [btn setTitle:@"已加入" forState:UIControlStateNormal];
        }
        else {
            [btn setTitle:@"申请加入" forState:UIControlStateNormal];
        }
    }
    else if ([groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateEndSign) {
        
        btn.hidden = NO;
        stateLabel.hidden = YES;
        
        [tagLabel setCornerRadius:12 withBorderColor:HEXCOLOR(@"#888888") borderWidth:0.8];
        tagLabel.textColor = HEXCOLOR(@"#888888");
        
        [btn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#dedfe0")];
        if ([groupInfo boolParamForName:@"ingroup"]) {
            [btn setTitle:@"已加入" forState:UIControlStateNormal];
        }
        else {
            [btn setTitle:@"报名已截止" forState:UIControlStateNormal];
        }
    }
    else if ([groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateBeingGroup) {
        
        btn.hidden = YES;
        stateLabel.hidden = NO;
        
        [tagLabel setCornerRadius:12 withBorderColor:HEXCOLOR(@"#ff7428") borderWidth:0.8];
        tagLabel.textColor = HEXCOLOR(@"#ff7428");
        
        stateLabel.text = @"开团中";
    }
    else {
        btn.hidden = YES;
        stateLabel.hidden = NO;
        
        [tagLabel setCornerRadius:12 withBorderColor:HEXCOLOR(@"#888888") borderWidth:0.8];
        tagLabel.textColor = HEXCOLOR(@"#888888");
        
        stateLabel.text = @"已过期";
    }
    
    @weakify(self);
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        if ([groupInfo integerParamForName:@"groupstatus"] == GroupButtonStateSignUp && ![groupInfo boolParamForName:@"ingroup"]) {
            [self joinSystemGroupWithGroupID:groupid groupName:groupname];
        }
        else {
            [self jumpToGroupDetail:indexPath];
        }
        
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self jumpToGroupDetail:indexPath];
}

#pragma mark - PushToNext
- (void)jumpToGroupDetail:(NSIndexPath *)indexPath
{
    //单个团介绍
    GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
    vc.originVC = self.originVC;
    vc.titleStr = @"平台团介绍";
    vc.groupType = MutualGroupTypeSystem;
    NSDictionary * dic = [self.autoGroupArray safetyObjectAtIndex:indexPath.section];
    vc.titleStr = [dic stringParamForName:@"name"] ?: @"平台团介绍";
    //团介绍页底部按钮标题
    if ([dic integerParamForName:@"groupstatus"] == GroupButtonStateNotStart) {
        vc.btnType = BtnTypeNotStart;
    }
    else if ([dic integerParamForName:@"groupstatus"] == GroupButtonStateSignUp) {
        if ([dic boolParamForName:@"ingroup"]) {
            vc.btnType = BtnTypeAlready;
        }
        
        else {
            vc.btnType = BtnTypeJoinNow;
        }
    }
    else {
        vc.btnType = BtnTypeHidden;
    }

    vc.groupId = [dic numberParamForName:@"groupid"];
    vc.groupName = dic[@"name"];
    vc.originCar = self.originCar;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)joinSystemGroupWithGroupID:(NSNumber *)groupid groupName:(NSString *)groupname
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        
        PickCarVC *vc = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
        vc.isShowBottomView = YES;
        @weakify(self);
        [vc setFinishPickCar:^(MyCarListVModel *carModel, UIView * loadingView) {
            @strongify(self);
            //爱车页面入团按钮委托实现
            [self requestApplyJoinGroupWithID:groupid groupName:groupname carModel:carModel loadingView:loadingView];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)requestApplyJoinGroupWithID:(NSNumber *)groupId groupName:(NSString *)groupName
                           carModel:(MyCarListVModel *)carModel loadingView:(UIView *)view
{
    ApplyCooperationGroupJoinOp * op = [[ApplyCooperationGroupJoinOp alloc] init];
    op.req_groupid = groupId;
    op.req_carid = carModel.selectedCar.carId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"申请加入中..." inView:view];
    }] subscribeNext:^(ApplyCooperationGroupJoinOp * rop) {
        
        @strongify(self);
        [gToast dismissInView:view];
        
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = rop.rsp_memberid;
        vc.groupId = rop.req_groupid;
        vc.groupName = groupName;
        vc.originVC = self.originVC;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        if (error.code == 6115804) {
            [gToast dismissInView:view];
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = error.domain;
//            @rocky
//            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
//
//            }];
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
            HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"立即完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                carModel.originVC = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"]; //返回选车页面
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

@end
