//
//  MutualInsVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/11/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsVC.h"
#import "ADViewController.h"
#import "NSString+RectSize.h"
#import "GetGroupJoinedInfoOp.h"
#import "GetCalculateBaseInfoOp.h"
#import "RTLabel.h"
#import "MutualInsConstants.h"
#import "MutInsSystemGroupListVC.h"
#import "MutualInsAskForCompensationVC.h"
#import "MutualInsStore.h"
#import "GroupIntroductionVC.h"
#import "HKPopoverView.h"
#import "MutInsCalculateVC.h"
#import "MutualInsCarListModel.h"
#import "MutualInsPicUpdateVC.h"
#import "MutualInsOrderInfoVC.h"
#import "MutualInsAdModel.h"
#import "MutualInsGroupDetailVC.h"
#import "MutualInsTipsInfoExtendedView.h"
#import "SJMarqueeLabelView.h"
#import "MutInsCalculatePageVC.h"

@interface MutualInsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

/// 菜单视图
@property (nonatomic, weak) HKPopoverView *popoverMenu;
/// 菜单数据源
@property (nonatomic, strong) CKList *menuItems;
/// 菜单是否打开
@property (nonatomic)BOOL isMenuOpen;

/// 判断是否有团有车
@property (nonatomic) BOOL isEmptyGroup;
///数据源
@property (nonatomic, strong) CKList *dataSource;
/// 获取到的数据，需要处理
@property (nonatomic, copy) NSArray *fetchedDataSource;

@property (nonatomic, strong) MutualInsStore *minsStore;

@property (strong, nonatomic) MutualInsAdModel *adModel;

@property (nonatomic, copy) NSArray *totalTipsArray;

@property (nonatomic, copy) NSString *bottomTips;

@end

@implementation MutualInsVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupRefreshView];
    
    [self setItemList];
    [self setupMutualInsStore];
    
    if (!gAppMgr.myUser)
    {
        /// 获取描述信息
        [self fetchDescriptionDataWhenNotLogined];
    }
    else
    {
        /// 获取团列表
        [[self.minsStore reloadSimpleGroups] send];
    }
    
    /// 获取广告信息
//    [self.adModel getSystemPromotion];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
    self.isMenuOpen = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Actions

- (void)actionGoToGroupIntroductionVC
{
    GroupIntroductionVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"GroupIntroductionVC"];
    vc.groupType = MutualGroupTypeSystem;
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionBack
{
    [MobClick event:@"huzhushouye" attributes:@{@"navi" : @"back"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)compensationButtonClicked:(id)sender
{
    [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"woyaobuchang"}];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        MutualInsAskForCompensationVC *vc = [UIStoryboard vcWithId:@"MutualInsAskForCompensationVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (IBAction)joinButtonClicked:(id)sender
{
    [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"jiaruhuzhu"}];
    [self actionGoToGroupIntroductionVC];
}

- (IBAction)actionShowOrHideMenu:(id)sender
{
    [MobClick event:@"huzhushouye" attributes:@{@"navi" : @"caidan"}];
    
    if (self.popoverMenu.isActivated) {
        [self.popoverMenu dismissWithAnimated:YES];
        return;
    }
    
    NSArray *items = [self.menuItems.allObjects arrayByMappingOperator:^id(CKDict *obj) {
        return [HKPopoverViewItem itemWithTitle:obj[@"title"] imageName:obj[@"img"]];
    }];
    HKPopoverView *popover = [[HKPopoverView alloc] initWithMaxWithContentSize:CGSizeMake(148, 245) items:items];
    @weakify(self);
    [popover setDidSelectedBlock:^(NSUInteger index) {
        @strongify(self);
        CKDict *dict = self.menuItems[index];
        CKCellSelectedBlock block = dict[kCKCellSelected];
        if (block) {
            block(dict, [NSIndexPath indexPathForRow:index inSection:0]);
        }
    }];
    
    [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                        inView:self.navigationController.view dismissTargetView:self.view animated:YES];
    self.popoverMenu = popover;
}

- (void)actionGotoCalculateVC
{
    MutInsCalculatePageVC *vc = [UIStoryboard vcWithId:@"MutInsCalculatePageVC" inStoryboard:@"MutualInsJoin"];
    vc.sensorChannel = @"apphzsy";
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoSystemGroupListVC
{
    MutInsSystemGroupListVC *vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutInsSystemGroupListVC"];
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoUpdateInfoVC:(HKMyCar *)car andMemberId:(NSNumber *)memberId
{
    MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
    vc.curCar = car;
    vc.memberId = memberId;
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoPayVC:(NSNumber *)contractId
{
    MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
    vc.contractId = contractId;
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoGroupDetailVC:(MutualInsCarListModel *)dict
{
    MutualInsGroupDetailVC *vc = [[MutualInsGroupDetailVC alloc] init];
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kMutInsGroupID] = dict.groupID;
    vc.router.userInfo[kMutInsGroupName] = dict.groupName;
    vc.router.userInfo[kMutInsMemberID] = dict.memberID;
    [self.router.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Setups
/// 下拉刷新设置
- (void)setupRefreshView
{
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        
        if (!gAppMgr.myUser)
        {
            /// 获取描述信息
            [self fetchDescriptionDataWhenNotLogined];
        }
        else
        {
            /// 获取团列表
            [[self.minsStore reloadSimpleGroups] send];
        }
    }];
}

- (void)setupMutualInsStore
{
    @weakify(self);
    self.minsStore = [MutualInsStore fetchOrCreateStore];
    [self.minsStore subscribeWithTarget:self domain:kDomainMutualInsSimpleGroups receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        [self reloadFormSignal:evt.signal];
    }];
}

- (void)setItemList
{
    self.menuItems = $([self menuCalculateButton],
                       [self menuPlanButton],
                       [self menuRegistButton],
                       [self menuHelpButton],
                       [self menuPhoneButton]);
}


#pragma mark - Menu List
- (id)menuCalculateButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey : @"calculate", @"title" : @"费用试算", @"img" : @"mutualIns_calculateGreen"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"caidan" : @"feiyongshisuan"}];
        [self actionGotoCalculateVC];
    });
    
    return dict;
}

- (id)menuPlanButton
{
    if (!self.minsStore.rsp_getGroupJoinedInfoOp.isShowPlanBtn) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"plan",@"title":@"内测计划",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"caidan" : @"zizhutuan"}];
        GroupIntroductionVC * vc = [UIStoryboard vcWithId:@"GroupIntroductionVC" inStoryboard:@"MutualInsJoin"];
        vc.groupType = MutualGroupTypeSelf;
        
        vc.router.userInfo = [[CKDict alloc] init];
        vc.router.userInfo[kOriginRoute] = self.router;
        
        [self.router.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuRegistButton
{
    if (!self.minsStore.rsp_getGroupJoinedInfoOp.isShowRegistBtn) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"regist",@"title":@"内测登记",@"img":@"mec_edit"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"caidan" : @"zizhutuanshenqing"}];
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        NSString * urlStr;
#if XMDDEnvironment==0
        urlStr = @"http://dev01.xiaomadada.com/paaweb/general/neice1035/input?token=";
#elif XMDDEnvironment==1
        urlStr = @"http://dev.xiaomadada.com/paaweb/general/neice1035/input?token=";
#else
        urlStr = @"http://www.xiaomadada.com/paaweb/general/neice1035/input?token=";
#endif
        
        vc.url = [urlStr append:gNetworkMgr.token];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuHelpButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"help",@"title":@"使用帮助",@"img":@"mins_question"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"huzhushouye" attributes:@{@"caidan" : @"bangzhu"}];
        
        if ([gStoreMgr.configStore.systemConfig boolParamForName:@"shenceflag"])
        {
        [SensorAnalyticsInstance track:@"event_huzhushouye_shiyongbangzhu"];
        }
        @strongify(self);
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self;
        
        NSString * urlStr;
#if XMDDEnvironment==0
        urlStr = @"http://xiaomadada.com/xmdd-web/xmdd-app/qa.html";
#elif XMDDEnvironment==1
        urlStr = @"http://xiaomadada.com/xmdd-web/xmdd-app/qa.html";
#else
        urlStr = @"http://xiaomadada.com/xmdd-web/xmdd-app/qa.html";
#endif
        
        vc.url = urlStr;
        [self.navigationController pushViewController:vc animated:YES];
    });
    return dict;
}

- (id)menuPhoneButton
{
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"phone",@"title":@"联系客服",@"img":@"mins_phone"}];
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"huzhushouye" attributes:@{@"caidan" : @"kefu"}];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [gPhoneHelper makePhone:@"4007111111"];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"如有任何疑问，可拨打客服电话: 4007-111-111" ActionItems:@[cancel,confirm]];
        [alert show];
    });
    return dict;
}


#pragma mark - Obtain data
- (void)reloadFormSignal:(RACSignal *)signal
{
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        [self.view hideDefaultEmptyView];
        if (!self.dataSource.count) {
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
        [self.view bringSubviewToFront:self.bottomView];
        
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        
        if (self.minsStore.carList.count)
        {
            self.isEmptyGroup = NO;
            self.fetchedDataSource = self.minsStore.carList;
            [self setDataSource];
        }
        else
        {
            self.isEmptyGroup = YES;
            self.dataSource = $($([self setupMutualInsTipsCell]));
            [self.dataSource addObject:$(CKJoin([self getCouponInfoWithData:self.minsStore.couponDict sourceDict:nil])) forKey:nil];
            [self.tableView reloadData];
        }
        
        [self setItemList];
        self.totalTipsArray = @[@(self.minsStore.totalMemberCnt), self.minsStore.totalPoolAmt ?: @"", @(self.minsStore.totalClaimCnt), self.minsStore.totalClaimAmt ?: @""];
        self.bottomTips = self.minsStore.openGroupTips;
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = NO;
        
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        @weakify(self);
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.minsStore reloadSimpleGroups] send];
        }];
        [self.view bringSubviewToFront:self.bottomView];
    }];
}

- (void)fetchDescriptionDataWhenNotLogined
{
    GetCalculateBaseInfoOp * op = [[GetCalculateBaseInfoOp alloc] init];
    
    @weakify(self)
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        [self.view hideDefaultEmptyView];
        if (!self.dataSource.count) {
            // 防止有数据的时候，下拉刷新导致页面会闪一下
            CGFloat reducingY = self.view.frame.size.height * 0.1056;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            self.tableView.hidden = YES;
        }
        else
        {
            [self.tableView.refreshView beginRefreshing];
            self.tableView.hidden = NO;
        }
        
    }] subscribeNext:^(GetCalculateBaseInfoOp * rop) {
        
        @strongify(self);
        NSDictionary *dict = @{@"insurancelist" : rop.insuranceList,
                               @"couponlist" : rop.couponList,
                               @"activitylist" : rop.activityList,
                               };
        self.totalTipsArray = @[@(rop.totalMemberCnt), rop.totalPoolAmt, @(rop.totalClaimCnt), rop.totalClaimAmt];
        self.bottomTips = rop.openGroupTips;
        self.dataSource = $($([self setupMutualInsTipsCell]));
        [self.dataSource addObject:$(CKJoin([self getCouponInfoWithData:dict sourceDict:nil])) forKey:nil];
        [self.tableView reloadData];
        
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        @weakify(self);
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [self fetchDescriptionDataWhenNotLogined];
        }];
    }];
}


/// 获取到数据后设置数据源
- (void)setDataSource
{
    CKList *dataSource = $($([self setupMutualInsTipsCell]));
    
    for (MutualInsCarListModel *dict in self.fetchedDataSource) {
        
        CKDict *normalStatusCell = [self setupNormalStatusCellWithDict:dict];
        
        CKDict *statusButtonCell = [self setupStatusButtonCellWithDict:dict];
        
        CKDict *groupInfoCell = [self setupGroupInfoCellWithDict:dict];
        
        NSMutableArray *extentedInfoArray = [NSMutableArray new];
        for (NSDictionary *secDict in dict.extendInfo) {
            [extentedInfoArray addObject:[self setupExtendedInfoCellWithDict:secDict sourceDict:dict]];
        }
        
        if (dict.status == XMGroupWithNoCar) {
            // 团长无车
            [dataSource addObject:$(groupInfoCell, CKJoin(extentedInfoArray)) forKey:nil];
            
            
        } else if (dict.status == XMGroupFailed|| (dict.status == XMInReview && dict.numberCnt.integerValue < 1)) {
            // 未参团 / 入团失败 / 审核中（有车无团）
            [dataSource addObject:$(normalStatusCell, CKJoin([self getCouponInfoWithData:dict.couponList sourceDict:dict])) forKey:nil];
            
        } else if (dict.status == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 审核失败（无团）
            CKList *group = $(statusButtonCell, CKJoin([self getCouponInfoWithData:dict.couponList sourceDict:dict]));
            [dataSource addObject:group forKey:nil];
            
        } else if (dict.status == XMWaitingForPay || dict.status == XMDataImcompleteV1 || dict.status == XMDataImcompleteV2 || (dict.status == XMReviewFailed && dict.numberCnt.integerValue > 0)) {
            // 待支付 / 待完善资料 / 审核失败（有团）
            [dataSource addObject:$(statusButtonCell, groupInfoCell, CKJoin(extentedInfoArray)) forKey:nil];
        } else {
            // 保障中 / 互助中 / 支付完成 / 审核中（有车有团）
            [dataSource addObject:$(normalStatusCell, groupInfoCell, CKJoin(extentedInfoArray)) forKey:nil];
        }
    }
    
    self.dataSource = dataSource;
    [self.tableView reloadData];
}

#pragma mark - The settings of Cells
- (CKDict *)setupMutualInsTipsCell
{
    CKDict *mutualInsTipsCell = [CKDict dictWith:@{kCKItemKey: @"MutualInsTipsCell", kCKCellID: @"MutualInsTipsCell"}];
    mutualInsTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 220;
    });
    mutualInsTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIView *view = [cell.contentView viewWithTag:1001];
        if (!view) {
            MutualInsTipsInfoExtendedView *extView = [[MutualInsTipsInfoExtendedView alloc] initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 220)];
            extView.tag = 1001;
            extView.peopleSumString = [NSString stringWithFormat:@"%ld", (long)[self.totalTipsArray[0] integerValue]];
            extView.moneySumString = [NSString stringWithFormat:@"%@", self.totalTipsArray[1]];
            extView.countingString = [NSString stringWithFormat:@"%ld", (long)[self.totalTipsArray[2] integerValue]];
            extView.claimSumString = [NSString stringWithFormat:@"%@", self.totalTipsArray[3]];
            extView.bottomTipsString = self.bottomTips;
            [extView setBottomButtonClicked:^{
                [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"xitongtuan"}];
                [self actionGotoSystemGroupListVC];
            }];
            [extView showInfo];
            extView.hidden = NO;
            [cell.contentView addSubview:extView];
        }
    });
    
    return mutualInsTipsCell;
}

///设置「互助费用试算」Cell
- (CKDict *)setupCalculateCell
{
    @weakify(self)
    CKDict *calculateCell = [CKDict dictWith:@{kCKItemKey: @"calculateCell", kCKCellID: @"CalculateCell"}];
    calculateCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 49;
    });
    
    calculateCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self)
        [self actionGotoCalculateVC];
    });
    
    calculateCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return calculateCell;
}

/// 设置带有品牌车 logo 和车牌号信息的 Cell
- (CKDict *)setupNormalStatusCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *normalStatusCell = [CKDict dictWith:@{kCKItemKey: @"normalStatusCell", kCKCellID: @"NormalStatusCell"}];
    normalStatusCell[@"dict"] = dict;
    normalStatusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        MutualInsCarListModel *dataModel = data[@"dict"];
        CGSize tipsSize = [dataModel.tip labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 font:[UIFont systemFontOfSize:13]];
        
        CGFloat height = tipsSize.height + 88;
        
        return MAX(height, 105);
    });
    
    normalStatusCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"dianjicheliang"}];
        @strongify(self);
        
        // 有车无团「未参团」状态
        if (dict.status == XMGroupFailed) {
            
            [self actionGoToGroupIntroductionVC];
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue > 0) {
            // 有车有团审核中状态
            /// 进入「团详情」页面
            [self actionGotoGroupDetailVC:data[@"dict"]];
            
        } else {
            // 「保障中」等状态
            // 进入「团详情」页面
            [self actionGotoGroupDetailVC:data[@"dict"]];
            
        }
    });
    
    normalStatusCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:103];
        UIView *statusContainerView = (UIView *)[cell.contentView viewWithTag:104];
        
        statusContainerView.layer.cornerRadius = 12;
        statusContainerView.layer.borderWidth = 0.5;
        statusContainerView.layer.borderColor = HEXCOLOR(@"#FF7428").CGColor;
        statusContainerView.layer.masksToBounds = YES;
        
        MutualInsCarListModel *dictModel = data[@"dict"];
        
        [brandImageView setImageByUrl:dict.brandLogo withType:ImageURLTypeMedium defImage:@"mins_def" errorImage:@"mins_def"];
        carNumLabel.text = dictModel.licenseNum;
        statusLabel.text = dictModel.statusDesc;
        statusLabel.numberOfLines = 0;
        tipsLabel.font = [UIFont systemFontOfSize:13];
        tipsLabel.textColor = HEXCOLOR(@"#888888");
        tipsLabel.text = dictModel.tip;
        tipsLabel.numberOfLines = 0;
        CGSize tipsSize = [dictModel.tip labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 font:[UIFont systemFontOfSize:13]];
        CGSize singleSize = [dictModel.tip sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        CGFloat numberOfText = ceil(tipsSize.height / singleSize.height);
        if (numberOfText > 1) {
            tipsLabel.textAlignment = NSTextAlignmentLeft;
        }
    });
    
    return normalStatusCell;
}

// 设置带有品牌车 logo 和车牌号信息的 Cell（带有 Button）
- (CKDict *)setupStatusButtonCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *statusWithButtonCell = [CKDict dictWith:@{kCKItemKey: @"tatusWithButtonCell", kCKCellID: @"StatusWithButtonCell"}];
    statusWithButtonCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize tipsSize = [dict.tip labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 font:[UIFont systemFontOfSize:13]];
        
        CGFloat height = tipsSize.height + 148;
        
        return MAX(height, 165);
    });
    
    statusWithButtonCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        if (dict.status == XMReviewFailed) {
            [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"chongxinshangchuan"}];
            // 进入「重新上传资料」页面
            @strongify(self);
            
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = dict.userCarID;
            car.licencenumber = dict.licenseNum;
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        } else if (dict.status == XMWaitingForPay) {
            // 进入「订单详情」页面
            @strongify(self);
            [self actionGotoPayVC:dict.contractID];
        } else {
            [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"wanshanziliao"}];
            // 进入「完善资料」页面
            
            @strongify(self);
            
            HKMyCar * car;
            if (dict.userCarID && dict.licenseNum) {
                car = [[HKMyCar alloc] init];
                car.carId = dict.userCarID;
                car.licencenumber = dict.licenseNum;
            }
            
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        }
    });
    
    statusWithButtonCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:103];
        UIView *statusContainerView = (UIView *)[cell.contentView viewWithTag:104];
        UIButton *bottomButton = (UIButton *)[cell.contentView viewWithTag:105];
        
        statusContainerView.layer.cornerRadius = 12;
        statusContainerView.layer.borderWidth = 0.5;
        statusContainerView.layer.borderColor = HEXCOLOR(@"#FF7428").CGColor;
        statusContainerView.layer.masksToBounds = YES;
        
        [brandImageView setImageByUrl:dict.brandLogo withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
        carNumLabel.text = dict.licenseNum;
        statusLabel.text = dict.statusDesc;
        tipsLabel.font = [UIFont systemFontOfSize:13];
        tipsLabel.textColor = HEXCOLOR(@"#888888");
        tipsLabel.numberOfLines = 0;
        tipsLabel.text = dict.tip;
        CGSize tipsSize = [dict.tip labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 font:[UIFont systemFontOfSize:13]];
        CGSize singleSize = [dict.tip sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
        CGFloat numberOfText = ceil(tipsSize.height / singleSize.height);
        if (numberOfText > 1) {
            tipsLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        if (dict.status == XMReviewFailed) {
            [bottomButton setTitle:@"重新上传资料" forState:UIControlStateNormal];
            @weakify(self);
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                
                 [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"chongxinshangchuan"}];
                HKMyCar * car = [[HKMyCar alloc] init];
                car.carId = dict.userCarID;
                car.licencenumber = dict.licenseNum;
                [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            }];
            
        } else if (dict.status == XMWaitingForPay) {
            
            [bottomButton setTitle:@"前去支付" forState:UIControlStateNormal];
            @weakify(self);
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"qianquzhifu"}];
                @strongify(self);
                
                [self actionGotoPayVC:dict.contractID];
            }];
            
        } else {
            
            [bottomButton setTitle:@"完善资料" forState:UIControlStateNormal];
            @weakify(self);
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                @strongify(self);
                
                [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"wanshanziliao"}];
                HKMyCar * car;
                if (dict.userCarID && dict.licenseNum)
                {
                    car = [[HKMyCar alloc] init];
                    car.carId = dict.userCarID;
                    car.licencenumber = dict.licenseNum;
                }
                [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            }];
        }
    });
    
    return statusWithButtonCell;
}

/// 设置显示团名，人数信息的 Cell
- (CKDict *)setupGroupInfoCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *groupInfoCell = [CKDict dictWith:@{kCKItemKey: @"groupInfoCell", kCKCellID: @"GroupInfoCell"}];
    groupInfoCell[@"dict"] = dict;
    groupInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 55;
    });
    
    groupInfoCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        // 进入团详情页面
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"jinrutuanxiangqing"}];
        [self actionGotoGroupDetailVC:data[@"dict"]];
    });
    
    groupInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *numCntLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        titleLabel.text = dict.groupName;
        numCntLabel.text = [NSString stringWithFormat:@"%ld", (long)dict.numberCnt.integerValue];
    });
    
    return groupInfoCell;
}

/// 设置显示时间等其他信息的 Cell
- (CKDict *)setupExtendedInfoCellWithDict:(NSDictionary *)dict sourceDict:(MutualInsCarListModel *)sourceDict
{
    CKDict *extendedInfoCell = [CKDict dictWith:@{kCKItemKey: @"extendedInfoCell", kCKCellID: @"ExtendedInfoCell"}];
    extendedInfoCell[@"dict"] = sourceDict;
    @weakify(self);
    extendedInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *titleString = [NSString stringWithFormat:@"%@", dict.allKeys.firstObject];
        NSString *contentString = [NSString stringWithFormat:@"%@", dict.allValues.firstObject];
        
        CGSize titleSize = [titleString labelSizeWithWidth:130 font:[UIFont systemFontOfSize:13]];
        CGSize contentSize = [contentString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 - 132 font:[UIFont systemFontOfSize:13]];
        
        CGFloat height = titleSize.height + 10;
        CGFloat height2 = contentSize.height + 10;
        
        return MAX(height, height2);
    });
    
    extendedInfoCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        // 进入团详情页面
        @strongify(self);
        
        [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"jinrutuanxiangqing"}];
        [self actionGotoGroupDetailVC:data[@"dict"]];
    });
    
    extendedInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        titleLabel.numberOfLines = 0;
        contentLabel.numberOfLines = 0;
        
        titleLabel.text = [NSString stringWithFormat:@"%@", dict.allKeys.firstObject];
        contentLabel.text = [NSString stringWithFormat:@"%@", dict.allValues.firstObject];
    });
    
    return extendedInfoCell;
}

/// 优惠信息的 Header，如：「加入互助后即享」
- (CKDict *)setupTipsHeaderCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *tipsHeaderCell = [CKDict dictWith:@{kCKItemKey: @"tipsHeaderCell", kCKCellID: @"TipsHeaderCell"}];
    tipsHeaderCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    
    tipsHeaderCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        
        // 有车无团「未参团」状态
        if (dict.status == XMGroupFailed) {

            [self actionGoToGroupIntroductionVC];
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = dict.userCarID;
            car.licencenumber = dict.licenseNum;
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGoToGroupIntroductionVC];
        }
    });
    
    tipsHeaderCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return tipsHeaderCell;
}

/// 优惠信息的标题，如：「保障，福利，活动」等
- (CKDict *)setupTipsTitleCellWithText:(NSString *)title withDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *tipsTitleCell = [CKDict dictWith:@{kCKItemKey: @"tipsTitleCell", kCKCellID: @"TipsTitleCell"}];
    tipsTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
    });
    
    tipsTitleCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"wodehuzhu" : @"fuli"}];
        // 有车无团「未参团」状态
        if (dict.status == XMGroupFailed) {
            
            [self actionGoToGroupIntroductionVC];
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = dict.userCarID;
            car.licencenumber = dict.licenseNum;
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGoToGroupIntroductionVC];
        }
    });
    
    tipsTitleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        if ([title isEqualToString:@"保障"]) {
            UIImage *image = [UIImage imageNamed:@"mins_ensure"];
            imageView.image = image;
        } else if ([title isEqualToString:@"福利"]) {
            UIImage *image = [UIImage imageNamed:@"mins_benefit"];
            imageView.image = image;
        } else {
            UIImage *image = [UIImage imageNamed:@"mins_activity"];
            imageView.image = image;
        }
        
        titleLabel.text = title;
    });
    
    return tipsTitleCell;
}

/// 设置显示优惠信息的双 Label Cell
- (CKDict *)setupTipsCellWithCouponList:(NSArray *)couponList withDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 22;
    });
    
    tipsCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        // 有车无团「未参团」状态
        if (dict.status == XMGroupFailed) {
            
            [self actionGoToGroupIntroductionVC];
            
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = dict.userCarID;
            car.licencenumber = dict.licenseNum;
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGoToGroupIntroductionVC];
        }
    });
    
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *firstImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UIImageView *secondImageView = (UIImageView *)[cell.contentView viewWithTag:103];
        UILabel *firstTipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *secondTipsLabel = (UILabel *)[cell.contentView viewWithTag:104];
        NSString *firstString = couponList[0];
        if (firstString.length > 0) {
            firstImageView.hidden = NO;
            firstTipsLabel.text = firstString;
        }
        
        if (couponList.count > 1) {
            NSString *secondString = couponList[1];
            secondImageView.hidden = NO;
            secondTipsLabel.text = secondString;
        } else {
            secondImageView.hidden = YES;
            secondTipsLabel.text = @"";
        }
    });
    
    return tipsCell;
}

/// 设置显示优惠信息的单 Label Cell
- (CKDict *)setupSingleTipsCellWithCouponString:(NSString *)couponString withDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *singleTipsCell = [CKDict dictWith:@{kCKItemKey: @"singleTipsCell", kCKCellID: @"SingleTipsCell"}];
    singleTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [couponString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 93 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 22);
        
        return height;
    });
    
    singleTipsCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        
        // 有车无团「未参团」状态
        if (dict.status == XMGroupFailed) {
            
            [self actionGoToGroupIntroductionVC];
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = dict.userCarID;
            car.licencenumber = dict.licenseNum;
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGoToGroupIntroductionVC];
        }
    });
    
    singleTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        tipsLabel.numberOfLines = 0;
        tipsLabel.text = couponString;
    });
    
    return singleTipsCell;
}

/// 作为一个给底部留白的 Cell，防止 Cell 的底部留白不够
- (CKDict *)setupBlankCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"blankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 15;
    });
    
    blankCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        // 有车无团「未参团」状态
        if (dict.status == XMGroupFailed) {
            
            [self actionGoToGroupIntroductionVC];
        } else if (dict.status == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            HKMyCar * car = [[HKMyCar alloc] init];
            car.carId = dict.userCarID;
            car.licencenumber = dict.licenseNum;
            
            [self actionGotoUpdateInfoVC:car andMemberId:dict.memberID];
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGoToGroupIntroductionVC];
        }
    });
    
    blankCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return blankCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *cellList = self.dataSource[section];
    return cellList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return CGFLOAT_MIN;
    } else {
        return 5;
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 35;
    } else {
        return 5;
    }
    
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 49;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 35)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, containerView.frame.size.width - 34, containerView.frame.size.height)];
        UILabel *noGroupsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        noGroupsLabel.text = @"暂未加入任何互助团";
        noGroupsLabel.textColor = HEXCOLOR(@"#18D06A");
        noGroupsLabel.font = [UIFont systemFontOfSize:13];
        [containerView addSubview:noGroupsLabel];
        [noGroupsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(containerView).offset(-17);
            make.centerY.equalTo(containerView);
        }];
        
        noGroupsLabel.hidden = self.isEmptyGroup ? NO : YES;
        
        label.text = @"我的互助";
        label.textColor = HEXCOLOR(@"#888888");
        label.font = [UIFont systemFontOfSize:13];
        [containerView addSubview:label];
        
        return containerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

#pragma mark - Utilities



/// 把一个 Array 分成另一个嵌套 mutableArray，该 mutableArray 里面有各个以 2 个为一组的子 mutableArray，这个方法主要配合显示双 Label 的优惠信息 Cell 使用。
- (NSMutableArray *)splitArrayIntoDoubleNewArray:(NSArray *)array
{
    // Create our array of arrays
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    // Loop through all of the elements using a for loop
    for (int a = 0; a < array.count / 2 + 1; a++) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (a * 2 < array.count) {
            id obj = [array objectAtIndex:a * 2];
            [tempArray addObject:obj];
        }
        
        if (a * 2 + 1 < array.count) {
            id obj2 = [array objectAtIndex:a * 2 + 1];
            [tempArray addObject:obj2];
        }
        
        [newArray addObject:tempArray];
    }
    
    return newArray;
}

/// 生成带有行高的 NSAttributedString
- (NSAttributedString *)generateAttributedStringWithLineSpacing:(NSString *)string
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 6.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}

/// 拼接优惠信息 Cell 的方法
- (NSMutableArray *)getCouponInfoWithData:(NSDictionary *)data sourceDict:(MutualInsCarListModel *)dict
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSArray *insuranceList = data[@"insurancelist"];
    CKDict *blankCell = [self setupBlankCellWithDict:dict];
    if (insuranceList.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:insuranceList];
        CKDict *tipsHeaderCell = [self setupTipsHeaderCellWithDict:dict];
        CKDict *insuranceTitleCell = [self setupTipsTitleCellWithText:@"保障" withDict:dict];
        [tempArray addObject:tipsHeaderCell];
        [tempArray addObject:insuranceTitleCell];
        for (NSArray *array in newArray) {
            CKDict *insuranceCell;
            if (array.count == 2) {
                insuranceCell = [self setupTipsCellWithCouponList:array withDict:dict];
            } else {
                NSString *string = array[0];
                insuranceCell = [self setupSingleTipsCellWithCouponString:string withDict:dict];
            }
            [tempArray addObject:insuranceCell];
        }
    }
    
    NSArray *couponList = data[@"couponlist"];
    if (couponList.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:couponList];
        CKDict *couponTitleCell = [self setupTipsTitleCellWithText:@"福利" withDict:dict];
        [tempArray addObject:couponTitleCell];
        for (NSArray *array in newArray) {
            CKDict *couponCell;
            if (array.count == 2) {
                couponCell = [self setupTipsCellWithCouponList:array withDict:dict];
            } else {
                NSString *string = array[0];
                couponCell = [self setupSingleTipsCellWithCouponString:string withDict:dict];
            }
            [tempArray addObject:couponCell];
        }
    }
    
    NSArray *activityList = data[@"activitylist"];
    if (activityList.count > 0) {
        CKDict *activityCell = [self setupTipsTitleCellWithText:@"活动" withDict:dict];
        [tempArray addObject:activityCell];
        for (NSString *string in activityList) {
            CKDict *activityCell = [self setupSingleTipsCellWithCouponString:string withDict:dict];
            [tempArray addObject:activityCell];
        }
    }
    
    [tempArray addObject:blankCell];
    
    return tempArray;
}

-(MutualInsAdModel *)adModel
{
    if (!_adModel)
    {
        _adModel = [[MutualInsAdModel alloc]init];
    }
    return _adModel;
}

@end
