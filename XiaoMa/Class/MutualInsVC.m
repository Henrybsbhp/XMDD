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
#import "SystemGroupListVC.h"

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

/// 显示内测计划按钮（返回参数）   0: 不显示  1: 显示
@property (nonatomic, strong) NSNumber *showPlanBtn;
/// 显示内测登记按钮（返回参数）   0: 不显示  1: 显示
@property (nonatomic, strong) NSNumber *showRegistBtn;

@property (nonatomic) BOOL isEmptyGroup;

/// 本地数据源
@property (nonatomic, strong) CKList *dataSource;

/// 从远端获取到的数据
@property (nonatomic, copy) NSArray *fetchedDataSource;

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
    
    if (!gAppMgr.myUser) {
        [self fetchDescriptionDataWhenNotLogined];
    } else {
        [self fetchAllData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)compensationButtonClicked:(id)sender
{
    
}

- (IBAction)joinButtonClicked:(id)sender
{
    
}

- (IBAction)moreBarButtonClicked:(id)sender
{
    
}

#pragma mark - First Setups
/// 下拉刷新设置
- (void)setupRefreshView
{
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self fetchAllData];
    }];
}

/// 设置顶部广告页
- (void)setupTableViewADView
{
    UIView *adContainer = [[UIView alloc] initWithFrame:CGRectZero];
    adContainer.backgroundColor = [UIColor colorWithHex:@"#F7F7F8" alpha:1.0f];
    
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

#pragma mark - Obtain data
/// 获取数据
- (void)fetchAllData
{
    GetGroupJoinedInfoOp *op = [[GetGroupJoinedInfoOp alloc] init];
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        if (!self.fetchedDataSource.count) {
            // 防止有数据的时候，下拉刷新导致页面会闪一下
            CGFloat reducingY = self.view.frame.size.height * 0.1056;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            self.tableView.hidden = YES;
        }
        
    }] subscribeNext:^(GetGroupJoinedInfoOp *rop) {
        @strongify(self);
        self.showPlanBtn = rop.showPlanBtn;
        self.showRegistBtn = rop.showRegistBtn;
        
        // 如果没有 list 的话，则视为没有团，直接显示优惠信息
        if (rop.carList.count > 0) {
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
            self.tableView.hidden = NO;
            self.isEmptyGroup = NO;
            self.fetchedDataSource = rop.carList;
            [self setDataSource];
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
            self.tableView.hidden = NO;
            
        } else {
            
            self.isEmptyGroup = YES;
            CKDict *blankCell = [self setupBlankCellWithDict:nil];
            self.dataSource = $($([self setupCalculateCell]));
            [self.dataSource addObject:$(CKJoin([self getCouponInfoWithData:rop.couponList sourceDict:nil]), blankCell) forKey:nil];
            [self.tableView reloadData];
            
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        self.tableView.hidden = YES;
        CGFloat reducingY = self.view.frame.size.height * 0.03;
        [self.view showDefaultEmptyViewWithText:@"请求数据失败，请点击重试" centerOffset:reducingY tapBlock:^{
            [self.view hideDefaultEmptyView];
            [self  fetchAllData];
        }];
    }];
}

/// 当没有登录的时候显示优惠信息的方法
- (void)fetchDescriptionDataWhenNotLogined
{
    @weakify(self);
    GetCalculateBaseInfoOp *infoOp = [[GetCalculateBaseInfoOp alloc] init];
    [[[infoOp rac_postRequest] initially:^{
        
        @strongify(self);
        if (!self.dataSource.count) {
            // 防止有数据的时候，下拉刷新导致页面会闪一下
            CGFloat reducingY = self.view.frame.size.height * 0.1056;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            self.tableView.hidden = YES;
        }
        
    }] subscribeNext:^(GetCalculateBaseInfoOp *rop) {
        @strongify(self);
        NSDictionary *dict = @{@"insurancelist" : rop.insuranceList,
                               @"couponlist" : rop.couponList,
                               @"activitylist" : rop.activityList,
                               };
        CKList *cellList = [CKList list];
        CKDict *blankCell = [self setupBlankCellWithDict:nil];
        NSArray *blankArray = @[blankCell];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempArray = [self getCouponInfoWithData:dict sourceDict:nil];
        CKDict *caculateCell = [self setupCalculateCell];
        CKList *caculateList = $(caculateCell);
        [dataArray addObject:caculateList];
        [cellList addObjectsFromArray:tempArray];
        [cellList addObjectsFromArray:blankArray];
        [dataArray addObject:cellList];
        self.dataSource = [CKList listWithArray:dataArray];
        [self.tableView reloadData];
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = NO;
        
    } error:^(NSError *error) {
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        self.tableView.hidden = YES;
        [self.view showDefaultEmptyViewWithText:@"请求数据失败，请点击重试" tapBlock:^{
            [self.view hideDefaultEmptyView];
            [self  fetchAllData];
        }];
    }];
}

/// 拼接优惠信息 Cell 的方法
- (NSMutableArray *)getCouponInfoWithData:(NSDictionary *)data sourceDict:(NSDictionary *)dict
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSArray *insuranceList = data[@"insurancelist"];
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
    
    return tempArray;
}

/// 获取到数据后设置数据源
- (void)setDataSource
{
    CKList *dataSource = $($([self setupCalculateCell]));
    
    for (NSDictionary *dict in self.fetchedDataSource) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        NSDictionary *couponDict = dict[@"couponlist"];
        
        // 增加底部留白的空白 Cell
        CKDict *blankCell = [self setupBlankCellWithDict:dict];
        
        CKDict *normalStatusCell = [self setupNormalStatusCellWithDict:dict];
        
        CKDict *statusButtonCell = [self setupStatusButtonCellWithDict:dict];
        
        CKDict *groupInfoCell = [self setupGroupInfoCellWithDict:dict];
        
        if (status.integerValue == XMGroupWithNoCar) {
            // 团长无车
            [dataSource addObject:$(groupInfoCell) forKey:nil];
            
        } else if ((status.integerValue == XMGroupFailed && numberCnt.integerValue > 0)|| (status.integerValue == XMInReview && numberCnt.integerValue < 1)) {
            // 未参团 / 入团失败 / 审核中（有车无团）
            [dataSource addObject:$(normalStatusCell, CKJoin([self getCouponInfoWithData:couponDict sourceDict:dict]), blankCell) forKey:nil];
            
        } else if (status.integerValue == XMReviewFailed && numberCnt.integerValue == 0) {
            // 审核失败（无团）
            CKList *group = $(statusButtonCell, CKJoin([self getCouponInfoWithData:couponDict sourceDict:dict]), blankCell);
            [dataSource addObject:group forKey:nil];
            
        } else if (status.integerValue == XMWaitingForPay || status.integerValue == XMDataImcompleteV1 || status.integerValue == XMDataImcompleteV2 || (status.integerValue == XMReviewFailed && numberCnt.integerValue > 0)) {
            // 待支付 / 待完善资料 / 审核失败（有团）
            [dataSource addObject:$(statusButtonCell, groupInfoCell) forKey:nil];
        } else {
            // 保障中 / 互助中 / 支付完成 / 审核中（有车有团）
            [dataSource addObject:$(normalStatusCell, groupInfoCell) forKey:nil];
        }
    }
    
    self.dataSource = dataSource;
    [self.tableView reloadData];
}

#pragma mark - The settings of Cells

///设置「互助费用试算」Cell
- (CKDict *)setupCalculateCell
{
    CKDict *calculateCell = [CKDict dictWith:@{kCKItemKey: @"calculateCell", kCKCellID: @"CalculateCell"}];
    calculateCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 49;
    });
    
    calculateCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
    });
    
    calculateCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return calculateCell;
}

/// 设置带有品牌车 logo 和车牌号信息的 Cell
- (CKDict *)setupNormalStatusCellWithDict:(NSDictionary *)dict
{
    CKDict *normalStatusCell = [CKDict dictWith:@{kCKItemKey: @"normalStatusCell", kCKCellID: @"NormalStatusCell"}];
    normalStatusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 105;
    });
    
    normalStatusCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        
        // 有车无团「未参团」状态
        if (status.integerValue == XMGroupFailed) {
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (status.integerValue == XMInReview && numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
        } else if (status.integerValue == XMInReview && numberCnt.integerValue > 0) {
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
        
        [brandImageView setImageByUrl:dict[@"brandlogo"] withType:ImageURLTypeMedium defImage:@"avatar_default" errorImage:@"avatar_default"];
        carNumLabel.text = dict[@"licensenum"];
        statusLabel.text = dict[@"statusdesc"];
        tipsLabel.font = [UIFont systemFontOfSize:13];
        tipsLabel.textColor = HEXCOLOR(@"#888888");
        tipsLabel.text = dict[@"tip"];
    });
    
    return normalStatusCell;
}

// 设置带有品牌车 logo 和车牌号信息的 Cell（带有 Button）
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
        if (status.integerValue == XMReuploadData) {
            [bottomButton setTitle:@"重新上传资料" forState:UIControlStateNormal];
            [[[bottomButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                
                
            }];
            
        } else if (status.integerValue == XMWaitingForPay) {
            
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

/// 设置显示团名，时间，人数信息的 Cell
- (CKDict *)setupGroupInfoCellWithDict:(NSDictionary *)dict
{
    CKDict *groupInfoCell = [CKDict dictWith:@{kCKItemKey: @"groupInfoCell", kCKCellID: @"GroupInfoCell"}];
    groupInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 117;
    });
    
    groupInfoCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        // 进入团详情页面
        
        
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

/// 优惠信息的 Header，如：「加入互助后即享」
- (CKDict *)setupTipsHeaderCellWithDict:(NSDictionary *)dict
{
    CKDict *tipsHeaderCell = [CKDict dictWith:@{kCKItemKey: @"tipsHeaderCell", kCKCellID: @"TipsHeaderCell"}];
    tipsHeaderCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 35;
    });
    
    tipsHeaderCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        
        // 有车无团「未参团」状态
        if (status.integerValue == XMGroupFailed) {
            
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (status.integerValue == XMInReview && numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (status.integerValue == XMReviewFailed && numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    });
    
    tipsHeaderCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
    });
    
    return tipsHeaderCell;
}

/// 优惠信息的标题，如：「保障，福利，活动」等
- (CKDict *)setupTipsTitleCellWithText:(NSString *)title withDict:(NSDictionary *)dict
{
    CKDict *tipsTitleCell = [CKDict dictWith:@{kCKItemKey: @"tipsTitleCell", kCKCellID: @"TipsTitleCell"}];
    tipsTitleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
    });
    
    tipsTitleCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        
        // 有车无团「未参团」状态
        if (status.integerValue == XMGroupFailed) {
            
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (status.integerValue == XMInReview && numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (status.integerValue == XMReviewFailed && numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
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
- (CKDict *)setupTipsCellWithCouponList:(NSArray *)couponList withDict:(NSDictionary *)dict
{
    CKDict *tipsCell = [CKDict dictWith:@{kCKItemKey: @"tipsCell", kCKCellID: @"TipsCell"}];
    tipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 22;
    });
    
    tipsCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        
        // 有车无团「未参团」状态
        if (status.integerValue == XMGroupFailed) {
            
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (status.integerValue == XMInReview && numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (status.integerValue == XMReviewFailed && numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
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
- (CKDict *)setupSingleTipsCellWithCouponString:(NSString *)couponString withDict:(NSDictionary *)dict
{
    CKDict *singleTipsCell = [CKDict dictWith:@{kCKItemKey: @"singleTipsCell", kCKCellID: @"SingleTipsCell"}];
    singleTipsCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGSize size = [couponString labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 93 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 22);
        
        return height;
    });
    
    singleTipsCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        
        // 有车无团「未参团」状态
        if (status.integerValue == XMGroupFailed) {
            
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (status.integerValue == XMInReview && numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (status.integerValue == XMReviewFailed && numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
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
- (CKDict *)setupBlankCellWithDict:(NSDictionary *)dict
{
    CKDict *blankCell = [CKDict dictWith:@{kCKItemKey: @"blankCell", kCKCellID: @"BlankCell"}];
    blankCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 15;
    });
    
    blankCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        NSNumber *status = dict[@"status"];
        NSNumber *numberCnt = dict[@"numbercnt"];
        
        // 有车无团「未参团」状态
        if (status.integerValue == XMGroupFailed) {
            
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        } else if (status.integerValue == XMInReview && numberCnt.integerValue < 1) {
            // 有车无团「审核中」状态
            [gToast showText:@"车辆审核中，请耐心等待审核结果"];
            
        } else if (status.integerValue == XMReviewFailed && numberCnt.integerValue == 0) {
            // 有车无团「审核失败」状态
            // 进入「重新上传资料」页面
            
            
        } else {
            
            // 无车无团「未参团」状态
            SystemGroupListVC * vc = [UIStoryboard vcWithId:@"SystemGroupListVC" inStoryboard:@"MutualInsJoin"];
            vc.originVC = self;
            [self.navigationController pushViewController:vc animated:YES];
            
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

@end
