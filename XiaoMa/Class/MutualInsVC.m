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

@interface MutualInsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *adVC;

@property (nonatomic, weak) HKPopoverView *popoverMenu;
@property (nonatomic, strong) CKList *menuItems;

/// 判断是否有团有车
@property (nonatomic) BOOL isEmptyGroup;

///数据源
@property (nonatomic, strong) CKList *dataSource;
///获取到的数据，需要处理
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
    
    [self setupTableViewADView];
    [self setupRefreshView];
    
    [self setItemList];
    [self setupMutualInsStore];
    
    CKAsyncMainQueue(^{
        
        [[self.minsStore reloadSimpleGroups] send];
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.popoverMenu dismissWithAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)compensationButtonClicked:(id)sender
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0006"}];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self])
    {
        MutualInsAskForCompensationVC *vc = [UIStoryboard vcWithId:@"MutualInsAskForCompensationVC" inStoryboard:@"MutualInsClaims"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

- (IBAction)joinButtonClicked:(id)sender
{
    MutInsSystemGroupListVC * vc = [UIStoryboard vcWithId:@"MutInsSystemGroupListVC" inStoryboard:@"Temp"];
    
    vc.router.userInfo = [[CKDict alloc] init];
    vc.router.userInfo[kOriginRoute] = self.router;
    
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionShowOrHideMenu:(id)sender
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shouye" : @"shouye0001"}];
    
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

#pragma mark - Setups
- (void)setupTableViewADView
{
    UIView *adContainer = [[UIView alloc] initWithFrame:CGRectZero];
    adContainer.backgroundColor = kBackgroundColor;
    
    self.adVC = [ADViewController vcWithMutualADType:AdvertisementHomePage boundsWidth:self.view.frame.size.width targetVC:self mobBaseEvent:nil mobBaseEventDict:nil];
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
    self.minsStore = [MutualInsStore fetchOrCreateStore];
    @weakify(self);
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
        vc.originVC = self;
        vc.groupType = MutualGroupTypeSelf;
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
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
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else if (![self.view isActivityAnimating]) {
            self.tableView.hidden = YES;
            
            self.view.indicatorPoistionY = self.view.frame.size.height * 0.1056;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        }
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.fetchedDataSource = self.minsStore.carList;
        
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = NO;
        self.isEmptyGroup = NO;
        
        [self setItemList];
        [self setDataSource];

    } error:^(NSError *error) {
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        else {
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
                @strongify(self);
                [[self.minsStore reloadSimpleGroups] send];
            }];
        }
    }];
}


- (NSMutableArray *)getCouponInfoWithData:(NSDictionary *)data
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSArray *insuranceList = data[@"insurancelist"];
    if (insuranceList.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:insuranceList];
        CKDict *tipsHeaderCell = [self setupTipsHeaderCell];
        CKDict *insuranceTitleCell = [self setupTipsTitleCellWithText:@"保障"];
        [tempArray addObject:tipsHeaderCell];
        [tempArray addObject:insuranceTitleCell];
        for (NSArray *array in newArray) {
            CKDict *insuranceCell = [self setupTipsCellWithCouponList:array];
            [tempArray addObject:insuranceCell];
        }
    }
    
    NSArray *couponList = data[@"couponlist"];
    if (data.count > 0) {
        NSMutableArray *newArray = [self splitArrayIntoDoubleNewArray:couponList];
        CKDict *couponTitleCell = [self setupTipsTitleCellWithText:@"福利"];
        [tempArray addObject:couponTitleCell];
        for (NSArray *array in newArray) {
            CKDict *couponCell = [self setupTipsCellWithCouponList:array];
            [tempArray addObject:couponCell];
        }
    }
    
    NSArray *activityList = data[@"activitylist"];
    if (activityList.count > 0) {
        CKDict *activityCell = [self setupTipsTitleCellWithText:@"活动"];
        [tempArray addObject:activityCell];
        for (NSString *string in activityList) {
            CKDict *activityCell = [self setupSingleTipsCellWithCouponString:string];
            [tempArray addObject:activityCell];
        }
    }
    
    return tempArray;
}

- (void)setDataSource
{
    self.dataSource = [CKList list];
    NSMutableArray *dataArray = [NSMutableArray new];
    
    CKDict *caculateCell = [self setupCalculateCell];
    CKList *caculateList = $(caculateCell);
    [dataArray addObject:caculateList];
    
    // 增加底部留白的空白 Cell
    CKDict *blankCell = [self setupBlankCell];
    
    for (NSDictionary *dict in self.fetchedDataSource) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        NSDictionary *couponDict = dict[@"couponlist"];
        
        CKDict *normalStatusCell = [self setupNormalStatusCellWithDict:dict];
        
        CKDict *statusButtonCell = [self setupStatusButtonCellWithDict:dict];
        
        CKDict *groupInfoCell = [self setupGroupInfoCellWithDict:dict];
        
        if (status.integerValue == -1) {
            // 有团无车
            
            CKList *noCarsGroup = $(groupInfoCell);
            [dataArray addObject:noCarsGroup];
            
        } else if (status.integerValue == 0 || status.integerValue == 3) {
            // 未参团 / 入团失败 / 审核中
            
            NSArray *blankArray = @[blankCell];
            CKList *joiningGroup = $(normalStatusCell);
            [joiningGroup addObjectsFromArray:[self getCouponInfoWithData:couponDict]];
            [joiningGroup addObjectsFromArray:blankArray];
            [dataArray addObject:joiningGroup];
            
        } else if (status.integerValue == 21 && numberCnt.integerValue == 0) {
            // 审核失败（无人）
            
            NSArray *blankArray = @[blankCell];
            CKList *reviewFailed = $(statusButtonCell);
            [reviewFailed addObjectsFromArray:[self getCouponInfoWithData:couponDict]];
            [reviewFailed addObjectsFromArray:blankArray];
            [dataArray addObject:reviewFailed];
            
        } else if (status.integerValue == 5 || status.integerValue == 1 || status.integerValue == 2 || (status.integerValue == 21 && numberCnt.integerValue > 0)) {
            // 待支付 / 待完善资料 / 审核失败（有人）
            
            CKList *pendingList = $(statusButtonCell, groupInfoCell);
            [dataArray addObject:pendingList];
            
        } else {
            // 保障中 / 互助中 / 支付完成
            
            CKList *normalStyle = $(normalStatusCell, groupInfoCell);
            [dataArray addObject:normalStyle];
        }
    }
    
    self.dataSource = [CKList listWithArray:dataArray];
    
    [self.tableView reloadData];
}

#pragma mark - The settings of Cells
- (CKDict *)setupCalculateCell
{
    CKDict *calculateCell = [CKDict dictWith:@{kCKItemKey: @"calculateCell", kCKCellID: @"CalculateCell"}];
    calculateCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 49;
    });
    
    calculateCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        MutInsCalculateVC * vc = [UIStoryboard vcWithId:@"MutInsCalculateVC" inStoryboard:@"Temp"];
        [self.navigationController pushViewController:vc animated:YES];
    });
    
    calculateCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return calculateCell;
}

- (CKDict *)setupNormalStatusCellWithDict:(NSDictionary *)dict
{
    CKDict *normalStatusCell = [CKDict dictWith:@{kCKItemKey: @"normalStatusCell", kCKCellID: @"NormalStatusCell"}];
    normalStatusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 105;
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
        
        [brandImageView setImageByUrl:dict[@"brandlogo"] withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
        carNumLabel.text = dict[@"licensenum"];
        statusLabel.text = dict[@"statusdesc"];
        tipsLabel.font = [UIFont systemFontOfSize:13];
        tipsLabel.textColor = HEXCOLOR(@"#888888");
        tipsLabel.text = dict[@"tip"];
    });
    
    return normalStatusCell;
}

- (CKDict *)setupStatusButtonCellWithDict:(NSDictionary *)dict
{
    CKDict *statusWithButtonCell = [CKDict dictWith:@{kCKItemKey: @"tatusWithButtonCell", kCKCellID: @"StatusWithButtonCell"}];
    statusWithButtonCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 165;
    });
    
    statusWithButtonCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
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
        
        [brandImageView setImageByUrl:dict[@"brandlogo"] withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
        carNumLabel.text = dict[@"licensenum"];
        statusLabel.text = dict[@"statusdesc"];
        tipsLabel.font = [UIFont systemFontOfSize:13];
        tipsLabel.textColor = HEXCOLOR(@"#888888");
        tipsLabel.text = dict[@"tip"];
        
        NSNumber *status = dict[@"status"];
        if (status.integerValue == 21) {
            [bottomButton setTitle:@"重新上传资料" forState:UIControlStateNormal];
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                
                
            }];
            
        } else if (status.integerValue == 5) {
            
            [bottomButton setTitle:@"前去支付" forState:UIControlStateNormal];
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                
                
            }];
            
        } else {
            
            [bottomButton setTitle:@"完善资料" forState:UIControlStateNormal];
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                
                
            }];
        }
    });
    
    return statusWithButtonCell;
}

- (CKDict *)setupGroupInfoCellWithDict:(NSDictionary *)dict
{
    CKDict *groupInfoCell = [CKDict dictWith:@{kCKItemKey: @"groupInfoCell", kCKCellID: @"GroupInfoCell"}];
    groupInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 117;
    });
    
    groupInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UILabel *numCntLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *startTimeLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *endTimeLabel = (UILabel *)[cell.contentView viewWithTag:103];
        
        NSNumber *numberCnt = dict[@"numbercnt"];
        titleLabel.text = dict[@"groupname"];
        numCntLabel.text = [NSString stringWithFormat:@"%ld", (long)numberCnt.integerValue];
        startTimeLabel.text = dict[@"insstarttime"];
        endTimeLabel.text = dict[@"insendtime"];
    });
    
    return groupInfoCell;
}

- (CKDict *)setupTipsHeaderCell
{
    CKDict *tipsHeaderCell = [CKDict dictWith:@{kCKItemKey: @"tipsHeaderCell", kCKCellID: @"TipsHeaderCell"}];
    tipsHeaderCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    
    tipsHeaderCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return tipsHeaderCell;
}

- (CKDict *)setupTipsTitleCellWithText:(NSString *)title
{
    CKDict *tipsTitleCell = [CKDict dictWith:@{kCKItemKey: @"tipsTitleCell", kCKCellID: @"TipsTitleCell"}];
    tipsTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
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

- (CKDict *)setupTipsCellWithCouponList:(NSArray *)couponList
{
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 22;
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

- (CKDict *)setupSingleTipsCellWithCouponString:(NSString *)couponString
{
    CKDict *singleTipsCell = [CKDict dictWith:@{kCKItemKey: @"singleTipsCell", kCKCellID: @"SingleTipsCell"}];
    singleTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [couponString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 93 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 22);
        
        return height;
    });
    
    singleTipsCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        tipsLabel.text = couponString;
        
        if (gAppMgr.deviceInfo.screenSize.height >= 667) {
            [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(cell).offset(38);
            }];
        }
    });
    
    return singleTipsCell;
}

- (CKDict *)setupBlankCell
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"blankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 15;
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
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalculateCell"];
        return cell;
    }
    
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

#pragma mark - Utilities
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

@end
