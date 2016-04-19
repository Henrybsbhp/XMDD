//
//  MutualInsHomeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/3.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsHomeVC.h"
#import "SystemGroupListVC.h"
#import "GroupIntroductionVC.h"
#import "MutualInsGrouponVC.h"
#import "InviteByCodeVC.h"
#import "MutualInsAskClaimsVC.h"
#import "GetCooperationConfiOp.h"
#import "GetCooperationMyGroupOp.h"
#import "HKMutualGroup.h"
#import "HKTimer.h"
#import "MutualInsStore.h"
#import "MutualInsPicUpdateVC.h"
#import "UIView+JTLoadingView.h"
#import "UIView+RoundedCorner.h"
#import "DeleteCooperationGroupOp.h"
#import "AddCloseAnimationButton.h"
#import "HKPopoverView.h"
#import "EditCarVC.h"

@interface MutualInsHomeVC ()

@property (nonatomic, strong) AddCloseAnimationButton *menuButton;
@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) CKList *menuItems;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GetCooperationConfiOp *config;
@property (nonatomic, strong) MutualInsStore *minsStore;
@property (nonatomic, strong) NSMutableArray * myGroupArray;
@property (nonatomic, strong) NSMutableArray * myCarArray;

@property (nonatomic, assign) NSTimeInterval leftTime;

@end

@implementation MutualInsHomeVC

-(void)dealloc
{
    DebugLog(@"MutualInsHomeVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self setItemList];
    [self setupMutualInsStore];
    self.tableView.hidden = YES;
    CKAsyncMainQueue(^{
        [self reloadIfNeeded];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar {
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    AddCloseAnimationButton *button = [[AddCloseAnimationButton alloc] initWithFrame:CGRectMake(0, 0, 35, 40)];
    [button addTarget:self action:@selector(actionShowOrHideMenu:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.menuButton = button;
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:container]];
}

- (void)setItemList
{
    self.menuItems = $([self menuPlanButton],
                       [self menuRegistButton],
                       [self menuHelpButton],
                       [self menuPhoneButton]);
}

- (id)menuPlanButton
{
    if (!self.minsStore.rsp_mygroupOp.isShowPlanButton) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"plan",@"title":@"内测计划",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self;
        vc.titleStr = @"自组团介绍";
        vc.groupType = MutualGroupTypeSelf;
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuRegistButton
{
    if (!self.minsStore.rsp_mygroupOp.isShowRegistButton) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"regist",@"title":@"内测登记",@"img":@"mec_edit"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        vc.url = @"http://www.baidu.com";
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuHelpButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"help",@"title":@"使用帮助",@"img":@"questionMark_300"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        vc.url = @"http://www.baidu.com";
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuPhoneButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"phone",@"title":@"联系客服",@"img":@"mins_phone"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSString * number = @"4007111111";
        [gPhoneHelper makePhone:number andInfo:@"如有任何疑问，可拨打客服电话: 4007-111-111"];
    });
    return dict;
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

#pragma mark - Action
- (void)actionShowOrHideMenu:(id)sender {
    BOOL closing = self.menuButton.closing;
    [self.menuButton setClosing:!closing WithAnimation:YES];
    if (closing && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
    }
    else if (!closing && !self.popoverMenu) {
        
        NSArray *items = [self.menuItems.allObjects arrayByMappingOperator:^id(CKDict *obj) {
            return [HKPopoverViewItem itemWithTitle:obj[@"title"] imageName:obj[@"img"]];
        }];
        HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 200) items:items];
        @weakify(self);
        [popover setDidSelectedBlock:^(NSUInteger index) {
            @strongify(self);
            CKDict *dict = self.menuItems[index];
            CKCellSelectedBlock block = dict[kCKCellSelected];
            if (block) {
                block(dict, [NSIndexPath indexPathForRow:index inSection:0]);
            }
        }];
        
        [popover setDidDismissedBlock:^(BOOL animated) {
            @strongify(self);
            [self.menuButton setClosing:NO WithAnimation:animated];
        }];
        [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                            inView:self.navigationController.view dismissTargetView:self.view animated:YES];
        self.popoverMenu = popover;
    }
}

- (void)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        if (self.minsStore.unMutuanlCarList) {
            self.myCarArray = [NSMutableArray arrayWithArray:self.minsStore.unMutuanlCarList.allObjects];
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
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
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
    
    if (gAppMgr.myUser && !self.myGroupArray) {
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
        @weakify(self);
        DeleteCooperationGroupOp * op = [DeleteCooperationGroupOp operation];
        op.req_memberid = @0;
        op.req_groupid = @256;
        [[[op rac_postRequest] initially:^{
            [gToast showingWithText:@"删除中..."];
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [gToast dismiss];
            [self.myGroupArray safetyRemoveObjectAtIndex:(indexPath.row - 3)];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
    else if (group.btnStatus == GroupBtnStatusUpdate) {
        
        //完善资料
        MutualInsPicUpdateVC * vc = [UIStoryboard vcWithId:@"MutualInsPicUpdateVC" inStoryboard:@"MutualInsJoin"];
        vc.memberId = group.memberId;
        vc.groupId = group.groupId;
        vc.groupName = group.groupName;
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int groupCount = 0;
    for (HKMutualGroup * group in self.myGroupArray) {
        if (group.memberId != 0) {
            groupCount ++;
        }
    }
    if (groupCount + self.myCarArray.count >= 5) {
        return 3 + self.myGroupArray.count + self.myCarArray.count;
    }
    return 4 + self.myGroupArray.count + self.myCarArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 123;
    }
    else if (indexPath.row == 1) {
        return 60;
    }
    else if (indexPath.row == 2) {
        return 50;
    }
    else if (indexPath.row > 2 && indexPath.row < (3 + self.myGroupArray.count)) {
        return 161;
    }
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0)
    {
        cell = [self helpCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 1) {
        cell = [self btnCellAtIndexPath:indexPath];
    }
    else if (indexPath.row == 2) {
        cell = [self sectionCellAtIndexPath:indexPath];
    }
    else if (indexPath.row > 2 && indexPath.row < (3 + self.myGroupArray.count)) {
        cell = [self myGroupCellAtIndexPath:indexPath];
    }
    else if (indexPath.row >= (3 + self.myGroupArray.count) && indexPath.row < (3 + self.myGroupArray.count + self.myCarArray.count)){
        cell = [self myCarCellAtIndexPath:indexPath];
    }
    else {
        cell = [self addCarCellAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        vc.url = @"http://www.baidu.com";
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row > 2 && indexPath.row < (3 + self.myGroupArray.count)) {
        //我的团详情页面
        MutualInsGrouponVC *vc = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
        vc.routeInfo = [CKDict dictWith:@{}];
        vc.group = [self.myGroupArray safetyObjectAtIndex:indexPath.row - 3];
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row >= (3 + self.myGroupArray.count) && indexPath.row < (3 + self.myGroupArray.count + self.myCarArray.count)){
        //团列表
        SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self;
        vc.originCar = [self.myCarArray safetyObjectAtIndex:(indexPath.row - (3 + self.myGroupArray.count))];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == (3 + self.myGroupArray.count + self.myCarArray.count)){
        //添加爱车
        @weakify(self);
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
            [vc.model setFinishBlock:^(HKMyCar *car) {
                
                @strongify(self);
                CKEvent *evt = [self.minsStore reloadSimpleGroups];
                [self reloadFormSignal:evt.signal];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - About Cell
- (UITableViewCell *)helpCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HelpCell"];
    UILabel *titleLabel = [cell.contentView viewWithTag:1001];
    UILabel *descLabel = [cell.contentView viewWithTag:1002];
    UIButton *feeButton = [cell.contentView viewWithTag:1003];
    
    titleLabel.text = self.config.rsp_selfgroupname;
    descLabel.text = self.config.rsp_selfgroupdesc;
    [feeButton setCornerRadius:5 withBorderColor:HEXCOLOR(@"#18D06A") borderWidth:0.5];
    [[[feeButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        //费用估算
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        vc.url = @"http://www.baidu.com";
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return cell;
}

- (UITableViewCell *)btnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BtnCell" forIndexPath:indexPath];
    UIButton *payButton = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *joinButton = (UIButton *)[cell.contentView viewWithTag:1002];
    
    [payButton setCornerRadius:5 withBackgroundColor:HEXCOLOR(@"#FF4E70")];
    [joinButton setCornerRadius:5 withBackgroundColor:HEXCOLOR(@"#18D06A")];
    
    //我要赔
    @weakify(self);
    [[[payButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        MutualInsAskClaimsVC *vc = [UIStoryboard vcWithId:@"MutualInsAskClaimsVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }];
    //去入团
    [[[joinButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    return cell;
}

- (UITableViewCell *)sectionCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"SectionCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)myGroupCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyGroupCell" forIndexPath:indexPath];
    
    UILabel *nameLabel = [cell.contentView viewWithTag:1001];
    UILabel *carIdLabel = [cell.contentView viewWithTag:1002];
    UILabel *statusLabel = [cell.contentView viewWithTag:1003];
    UILabel *timeLabel = [cell.contentView viewWithTag:1004];
    UIButton *opeBtn = [cell.contentView viewWithTag:1005];
    
    HKMutualGroup * group = [self.myGroupArray safetyObjectAtIndex:indexPath.row - 3];
    
    nameLabel.text = group.groupName;
    carIdLabel.text = group.licenseNumber;
    statusLabel.text = group.statusDesc;
    
    if ([group.leftTime integerValue] != 0)
    {
        @weakify(self);
        RACDisposable * disp = [[[HKTimer rac_timeCountDownWithOrigin:[group.leftTime integerValue] / 1000 andTimeTag:group.leftTimeTag] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * timeStr) {
            
            @strongify(self);
            if (![timeStr isEqualToString:@"end"]) {
                timeLabel.text = [NSString stringWithFormat:@"%@ \n%@", group.tip, timeStr];
            }
            else {
                [disp dispose];
                [[self.minsStore reloadSimpleGroups] send];
            }
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
    
    opeBtn.hidden = !(group.btnStatus == GroupBtnStatusInvite || group.btnStatus == GroupBtnStatusDelete || group.btnStatus == GroupBtnStatusUpdate);
    
    if (group.btnStatus)
    {
        if (group.btnStatus == GroupBtnStatusInvite) {
            [opeBtn setTitle:@"邀请好友" forState:UIControlStateNormal];
            [opeBtn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#18D06A")];
        }
        else if (group.btnStatus == GroupBtnStatusDelete){
            [opeBtn setTitle:@"删除" forState:UIControlStateNormal];
            [opeBtn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#FF4E70")];
        }
        else if (group.btnStatus == GroupBtnStatusUpdate) {
            [opeBtn setTitle:@"完善资料" forState:UIControlStateNormal];
            [opeBtn setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#18D06A")];
        }
        @weakify(self);
        [[[opeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            NSIndexPath * cellPath = [self.tableView indexPathForCell:cell];
            [self operationBtnAction:x withGroup:group withIndexPath:cellPath];
        }];
    }
    return cell;
}

- (UITableViewCell *)myCarCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"MyCarCell" forIndexPath:indexPath];
    
    UIImageView *brandImageView = [cell.contentView viewWithTag:1001];
    UILabel *licensenumLabel = [cell.contentView viewWithTag:1002];
    UIButton *joinGroup = [cell.contentView viewWithTag:1003];
    UILabel *mutualPrice = [cell.contentView viewWithTag:1004];
    UILabel *couponPrice = [cell.contentView viewWithTag:1005];

    HKMutualCar * myCar = [self.myCarArray safetyObjectAtIndex:indexPath.row - 3 - self.myGroupArray.count];
    
    [brandImageView setImageByUrl:myCar.brandLogo withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
    licensenumLabel.text = myCar.licenseNum;
    [joinGroup setCornerRadius:5 withBorderColor:HEXCOLOR(@"#18D06A") borderWidth:0.5];
    @weakify(self);
    [[[joinGroup rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        //团列表
        SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
        vc.originVC = self;
        vc.originCar = [self.myCarArray safetyObjectAtIndex:(indexPath.row - (3 + self.myGroupArray.count))];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    mutualPrice.text = myCar.premiumPrice;
    couponPrice.text = [NSString stringWithFormat:@"%@", myCar.couponMoney];
    
    return cell;
}

- (UITableViewCell *)addCarCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddCarCell" forIndexPath:indexPath];
    return cell;
}

@end
