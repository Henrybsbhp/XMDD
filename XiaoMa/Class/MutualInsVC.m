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
#import "MutInsSystemGroupListVC.h"
#import "MutualInsAskForCompensationVC.h"
#import "MutualInsStore.h"
#import "GroupIntroductionVC.h"
#import "HKPopoverView.h"
#import "MutInsCalculateVC.h"
#import "MutualInsCarListModel.h"
#import "MutualInsPicUpdateVC.h"
#import "MutualInsOrderInfoVC.h"

typedef NS_ENUM(NSInteger, statusValues) {
    /// 未参团 / 参团失败
    XMGroupFailed        = 0,
    
    /// 团长无车
    XMGroupWithNoCar     = -1,
    
    /// 资料代完善
    XMDataImcompleteV1   = 1,
    
    /// 资料代完善
    XMDataImcompleteV2   = 2,
    
    /// 审核中
    XMInReview           = 3,
    
    /// 待支付
    XMWaitingForPay      = 5,
    
    /// 支付成功
    XMPaySuccessed       = 6,
    
    /// 互助中
    XMInMutual           = 7,
    
    /// 保障中
    XMInEnsure           = 8,
    
    /// 已过期
    XMOverdue            = 10,
    
    /// 重新上传资料
    XMReuploadData       = 20,
    
    /// 审核失败
    XMReviewFailed       = 21
};

@interface MutualInsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *adVC;

@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) CKList *menuItems;

/// 判断是否有团有车
@property (nonatomic) BOOL isEmptyGroup;

///数据源
@property (nonatomic, strong) CKList *dataSource;
/// 获取到的数据，需要处理
@property (nonatomic, copy) NSArray *fetchedDataSource;

@property (nonatomic, strong) MutualInsStore *minsStore;

@property (nonatomic)BOOL isMenuOpen;


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
    // Do any additional setup after loading the view.
    
    [self setupNavigationBar];
    [self setupTableViewADView];
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
- (void)actionBack
{
    [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye1"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)compensationButtonClicked:(id)sender
{
    [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye6"}];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        MutualInsAskForCompensationVC *vc = [UIStoryboard vcWithId:@"MutualInsAskForCompensationVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (IBAction)joinButtonClicked:(id)sender
{
    [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye7"}];
    [self actionGotoSystemGroupListVC];
}

- (IBAction)actionShowOrHideMenu:(id)sender
{
    [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye2"}];
    
    if (self.isMenuOpen && self.popoverMenu) {
        [self.popoverMenu dismissWithAnimated:YES];
        self.isMenuOpen = NO;
    }
    else if (!self.isMenuOpen && !self.popoverMenu) {
        
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
        
        [popover showAtAnchorPoint:CGPointMake(self.navigationController.view.frame.size.width-33, 60)
                            inView:self.navigationController.view dismissTargetView:self.view animated:YES];
        self.popoverMenu = popover;
        self.isMenuOpen = YES;
    }
}

- (void)actionGotoCalculateVC
{
    MutInsCalculateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutInsCalculateVC"];
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoSystemGroupListVC
{
    MutInsSystemGroupListVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutInsSystemGroupListVC"];
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoUpdateInfoVC:(HKMyCar *)car
{
    MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
    vc.curCar = car;
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoPayVC
{
    MutualInsOrderInfoVC * vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
//    vc.contractId = self.groupDetail.rsp_contractid;
//    vc.group = self.group;
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoGroupDetailVC
{
    
}

#pragma mark - Setups
/// 设置顶部广告页
- (void)setupTableViewADView
{
    UIView *adContainer = [[UIView alloc] initWithFrame:CGRectZero];
    adContainer.backgroundColor = kBackgroundColor;
    
    self.adVC = [ADViewController vcWithMutualADType:AdvertisementMutualInsTop boundsWidth:self.view.frame.size.width targetVC:self mobBaseEvent:@"huzhushouye" mobBaseEventDict:@{@"huzhushouye" : @"huzhushouye3"}];
    CGFloat height = floor(self.adVC.adView.frame.size.height);
    adContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
    [self.tableView addSubview:adContainer];
    [adContainer addSubview:self.adVC.adView];
    [self.adVC.adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adContainer);
        make.right.equalTo(adContainer);
        make.top.equalTo(adContainer);
        make.height.mas_equalTo(height);
    }];
    
    self.tableView.tableHeaderView = adContainer;
    
    [self.adVC reloadDataWithForce:YES completed:nil];
}


/// 下拉刷新设置
- (void)setupRefreshView
{
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [[self.minsStore reloadSimpleGroups] send];
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
    self.menuItems = $([self menuPlanButton],
                       [self menuRegistButton],
                       [self menuHelpButton],
                       [self menuPhoneButton]);
}


#pragma mark - Menu List
- (id)menuPlanButton
{
    if (!self.minsStore.rsp_getGroupJoinedInfoOp.isShowPlanBtn) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"plan",@"title":@"内测计划",@"img":@"mins_person"}];
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
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
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0012"}];
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
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0013"}];
        
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
            self.dataSource = $($([self setupCalculateCell]));
            [self.dataSource addObject:$(CKJoin([self getCouponInfoWithData:self.minsStore.couponDict sourceDict:nil])) forKey:nil];
            [self.tableView reloadData];
        }
        [self setItemList];
        
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = NO;
        
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = NO;
        
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        @weakify(self);
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.minsStore reloadSimpleGroups] send];
        }];
    }];
}

- (void)fetchDescriptionDataWhenNotLogined
{
    GetCalculateBaseInfoOp * op = [[GetCalculateBaseInfoOp alloc] init];
    
    @weakify(self)
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
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
        self.dataSource = $($([self setupCalculateCell]));
        [self.dataSource addObject:$(CKJoin([self getCouponInfoWithData:dict sourceDict:nil])) forKey:nil];
        [self.tableView reloadData];
        
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        self.tableView.hidden = NO;
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
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
    CKList *dataSource = $($([self setupCalculateCell]));
    
    for (MutualInsCarListModel *dict in self.fetchedDataSource) {
    
        CKDict *normalStatusCell = [self setupNormalStatusCellWithDict:dict];
        
        CKDict *statusButtonCell = [self setupStatusButtonCellWithDict:dict];

        CKDict *groupInfoCell = [self setupGroupInfoCellWithDict:dict];

        NSMutableArray *extentedInfoArray = [NSMutableArray new];
        for (NSDictionary *secDict in dict.extendInfo) {
            [extentedInfoArray addObject:[self setupExtendedInfoCellWithDict:secDict sourceDict:dict]];
        }
        
        if (dict.status.integerValue == XMGroupWithNoCar) {
            // 团长无车
            [dataSource addObject:$(groupInfoCell, CKJoin(extentedInfoArray)) forKey:nil];
            

        } else if (dict.status.integerValue == XMGroupFailed|| (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1)) {
            // 未参团 / 入团失败 / 审核中（有车无团）
            [dataSource addObject:$(normalStatusCell, CKJoin([self getCouponInfoWithData:dict.couponList sourceDict:dict])) forKey:nil];
            
        } else if (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 审核失败（无团）
            CKList *group = $(statusButtonCell, CKJoin([self getCouponInfoWithData:dict.couponList sourceDict:dict]));
            [dataSource addObject:group forKey:nil];
            
        } else if (dict.status.integerValue == XMWaitingForPay || dict.status.integerValue == XMDataImcompleteV1 || dict.status.integerValue == XMDataImcompleteV2 || (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue > 0)) {
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

///设置「互助费用试算」Cell
- (CKDict *)setupCalculateCell
{
    @weakify(self)
    CKDict *calculateCell = [CKDict dictWith:@{kCKItemKey: @"calculateCell", kCKCellID: @"CalculateCell"}];
    calculateCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 49;
    });
    
    calculateCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye4"}];
        
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
    normalStatusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 105;
    });
    
    normalStatusCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye8"}];
        @strongify(self);
        
        // 有车无团「未参团」状态
        if (dict.status.integerValue == XMGroupFailed) {
            
            [self actionGotoSystemGroupListVC];
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue > 0) {
            // 有车有团审核中状态
            /// 进入「团详情」页面
            
            
        } else {
            // 「保障中」等状态
            // 进入「团详情」页面
            
            
        }
    });
    
    normalStatusCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:101];
        RTLabel *tipsLabel = (RTLabel *)[cell.contentView viewWithTag:102];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:103];
        UIView *statusContainerView = (UIView *)[cell.contentView viewWithTag:104];
        
        statusContainerView.layer.cornerRadius = 12;
        statusContainerView.layer.borderWidth = 0.5;
        statusContainerView.layer.borderColor = HEXCOLOR(@"#FF7428").CGColor;
        statusContainerView.layer.masksToBounds = YES;
        
        [brandImageView setImageByUrl:dict.brandLogo withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
        carNumLabel.text = dict.licenseNum;
        statusLabel.text = dict.statusDesc;
        tipsLabel.font = [UIFont systemFontOfSize:13];
        tipsLabel.textColor = HEXCOLOR(@"#888888");
        tipsLabel.text = dict.tip;
    });
    
    return normalStatusCell;
}

// 设置带有品牌车 logo 和车牌号信息的 Cell（带有 Button）
- (CKDict *)setupStatusButtonCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *statusWithButtonCell = [CKDict dictWith:@{kCKItemKey: @"tatusWithButtonCell", kCKCellID: @"StatusWithButtonCell"}];
    statusWithButtonCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 165;
    });
    
    statusWithButtonCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        if (dict.status.integerValue == XMReuploadData || dict.status.integerValue == XMReviewFailed) {
            [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye11"}];
            // 进入「重新上传资料」页面
                
            
            
        } else if (dict.status.integerValue == XMWaitingForPay) {
            // 进入「订单详情」页面
            
            
        } else {
            [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye9"}];
            // 进入「完善资料」页面
                
            
        }
    });
    
    statusWithButtonCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:101];
        RTLabel *tipsLabel = (RTLabel *)[cell.contentView viewWithTag:102];
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
        tipsLabel.text = dict.tip;
        
        if (dict.status.integerValue == XMReuploadData || dict.status.integerValue == XMReviewFailed) {
            [bottomButton setTitle:@"重新上传资料" forState:UIControlStateNormal];
            @weakify(self);
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye11"}];
                @strongify(self);
                
                HKMyCar * car = [[HKMyCar alloc] init];
                car.carId = dict.userCarID;
                car.licencenumber = dict.licenseNum;
                [self actionGotoUpdateInfoVC:car];
            }];
            
        } else if (dict.status.integerValue == XMWaitingForPay) {
            
            [bottomButton setTitle:@"前去支付" forState:UIControlStateNormal];
            @weakify(self);
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye12"}];
                @strongify(self);
                
                [self actionGotoPayVC];
            }];
            
        } else {
            
            [bottomButton setTitle:@"完善资料" forState:UIControlStateNormal];
            @weakify(self);
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye9"}];
                @strongify(self);
                
                HKMyCar * car;
                if (dict.userCarID && dict.licenseNum)
                {
                    car = [[HKMyCar alloc] init];
                    car.carId = dict.userCarID;
                    car.licencenumber = dict.licenseNum;
                }
                [self actionGotoUpdateInfoVC:car];
            }];
        }
    });
    
    return statusWithButtonCell;
}

/// 设置显示团名，时间，人数信息的 Cell
- (CKDict *)setupGroupInfoCellWithDict:(MutualInsCarListModel *)dict
{
    @weakify(self);
    CKDict *groupInfoCell = [CKDict dictWith:@{kCKItemKey: @"groupInfoCell", kCKCellID: @"GroupInfoCell"}];
    groupInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 55;
    });
    
    groupInfoCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        // 进入团详情页面
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye10"}];
        [self actionGotoGroupDetailVC];
    });
    
    groupInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *numCntLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        titleLabel.text = dict.groupName;
        numCntLabel.text = [NSString stringWithFormat:@"%ld", (long)dict.numberCnt.integerValue];
    });
    
    return groupInfoCell;
}

- (CKDict *)setupExtendedInfoCellWithDict:(NSDictionary *)dict sourceDict:(MutualInsCarListModel *)sourceDict
{
    CKDict *extendedInfoCell = [CKDict dictWith:@{kCKItemKey: @"extendedInfoCell", kCKCellID: @"ExtendedInfoCell"}];
    @weakify(self);
    extendedInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *titleString = [NSString stringWithFormat:@"%@", dict.allKeys.firstObject];
        NSString *contentString = [NSString stringWithFormat:@"%@", dict.allValues.firstObject];
        
        CGSize titleSize = [titleString labelSizeWithWidth:130 font:[UIFont systemFontOfSize:13]];
        CGSize contentSize = [contentString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 34 - 198 font:[UIFont systemFontOfSize:13]];
        
        CGFloat height = titleSize.height + 10;
        CGFloat height2 = contentSize.height + 10;
        
        return MAX(height, height2);
    });
    
    extendedInfoCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        // 进入团详情页面
        @strongify(self);
        [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye10"}];
        [self actionGotoGroupDetailVC];
    });
    
    extendedInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
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
        [MobClick event:@"huzhushouye" attributes:@{@"huzhushouye" : @"huzhushouye5"}];
        @strongify(self);
        
        // 有车无团「未参团」状态
        if (dict.status.integerValue == XMGroupFailed) {
            
            [self actionGotoSystemGroupListVC];
            
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGotoSystemGroupListVC];
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
        // 有车无团「未参团」状态
        if (dict.status.integerValue == XMGroupFailed) {
            
            [self actionGotoSystemGroupListVC];
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGotoSystemGroupListVC];
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
        if (dict.status.integerValue == XMGroupFailed) {
            
            [self actionGotoSystemGroupListVC];
            
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGotoSystemGroupListVC];
        }
    });
    
    tipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *firstImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UIImageView *secondImageView = (UIImageView *)[cell.contentView viewWithTag:103];
        UIView *separator = (UIView *)[cell.contentView viewWithTag:106];
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
        
        // 如果用户机型是 iPhone 6 或以上屏幕大小的设备，更改一下 imageView 和 label 的约束
        if (gAppMgr.deviceInfo.screenSize.height >= 667) {
            [firstImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(cell).offset(38);
            }];
            
            [firstTipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(separator).offset(0);
            }];
            
            [secondImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(separator).offset(32);
            }];
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
        if (dict.status.integerValue == XMGroupFailed) {
            
            [self actionGotoSystemGroupListVC];
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGotoSystemGroupListVC];
        }
    });
    
    singleTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        tipsLabel.text = couponString;
        
        // 如果用户机型是 iPhone 6 或以上屏幕大小的设备，更改一下 imageView 的约束
        if (gAppMgr.deviceInfo.screenSize.height >= 667) {
            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(cell).offset(38);
            }];
        }
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
        if (dict.status.integerValue == XMGroupFailed) {
            
            [self actionGotoSystemGroupListVC];
        } else if (dict.status.integerValue == XMInReview && dict.numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (dict.status.integerValue == XMReviewFailed && dict.numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            [self actionGotoSystemGroupListVC];
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
    if (section == 0) {
        return 1;
    } else {
        CKList *cellList = self.dataSource[section];
        NSArray *countArray = [cellList allObjects];
        return countArray.count;
    }
    return 1;
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
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 49;
    }
    
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
            CKDict *insuranceCell = [self setupTipsCellWithCouponList:array withDict:dict];
            [tempArray addObject:insuranceCell];
        }
    }
    
    NSArray *couponList = data[@"couponlist"];
    if (data.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:couponList];
        CKDict *couponTitleCell = [self setupTipsTitleCellWithText:@"福利" withDict:dict];
        [tempArray addObject:couponTitleCell];
        for (NSArray *array in newArray) {
            CKDict *couponCell = [self setupTipsCellWithCouponList:array withDict:dict];
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


@end
