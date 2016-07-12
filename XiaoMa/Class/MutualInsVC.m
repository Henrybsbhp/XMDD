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

@interface MutualInsVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, strong) ADViewController *adVC;

/// 显示内测计划按钮（返回参数）   0: 不显示  1: 显示
@property (nonatomic, strong) NSNumber *showPlanBtn;
/// 显示内测登记按钮（返回参数）   0: 不显示  1: 显示
@property (nonatomic, strong) NSNumber *showRegistBtn;

@property (nonatomic) BOOL isEmptyGroup;

@property (nonatomic, strong) CKList *dataSource;
@property (nonatomic, copy) NSArray *fetchedDataSource;

@end

@implementation MutualInsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupTableViewADView];
    [self setupRefreshView];
    [self fetchAllData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bottomView.hidden = YES;
}

#pragma mark - Actions
- (IBAction)compensationButtonClicked:(id)sender
{
    
}

- (IBAction)joinButtonClicked:(id)sender
{
    MutInsSystemGroupListVC * vc = [UIStoryboard vcWithId:@"MutInsSystemGroupListVC" inStoryboard:@"Temp"];
    [self.navigationController pushViewController:vc animated:YES];
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
    
    UIImage *image = [UIImage imageNamed:@"Horizontaline"];
    UIImageView *separator = [[UIImageView alloc] initWithImage:image];
    separator.frame = CGRectZero;
    [adContainer addSubview:separator];
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adContainer);
        make.right.equalTo(adContainer);
        make.bottom.equalTo(adContainer);
        make.height.mas_equalTo(1);
    }];
    
    self.tableView.tableHeaderView = adContainer;
    
    [self.adVC reloadDataWithForce:YES completed:nil];
}

#pragma mark - Obtain data
- (void)fetchAllData
{
    GetGroupJoinedInfoOp *op = [[GetGroupJoinedInfoOp alloc] init];
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        if (!self.fetchedDataSource.count)
        {
            // 防止有数据的时候，下拉刷新导致页面会闪一下
            CGFloat reducingY = self.view.frame.size.height * 0.1056;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            self.tableView.hidden = YES;
        }
        
    }] subscribeNext:^(GetGroupJoinedInfoOp *rop) {
        @strongify(self);
        self.showPlanBtn = rop.showPlanBtn;
        self.showRegistBtn = rop.showRegistBtn;
        if (rop.carList.count > 0) {
            [self.view stopActivityAnimation];
            [self.tableView.refreshView endRefreshing];
            self.tableView.hidden = NO;
            self.bottomView.hidden = NO;
            self.isEmptyGroup = NO;
            self.fetchedDataSource = rop.carList;
            [self setDataSource];
            
        } else {
            self.isEmptyGroup = YES;
            [self fetchDescriptionDataWhenNoGroups];
        }
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self.view stopActivityAnimation];
        self.tableView.hidden = YES;
        [self.view showDefaultEmptyViewWithText:@"请求数据失败，请点击重试" tapBlock:^{
            [self.view hideDefaultEmptyView];
            [self  fetchAllData];
        }];
    }];
}

- (void)fetchDescriptionDataWhenNoGroups
{
    @weakify(self);
    GetCalculateBaseInfoOp *infoOp = [[GetCalculateBaseInfoOp alloc] init];
    [[[infoOp rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetCalculateBaseInfoOp *rop) {
        @strongify(self);
        NSDictionary *dict = @{@"insurancelist" : rop.insuranceList,
                               @"couponlist" : rop.couponList,
                               @"activitylist" : rop.activityList,
                               };
        CKList *cellList = [CKList list];
        CKDict *blankCell = [self setupBlankCell];
        NSArray *blankArray = @[blankCell];
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        NSMutableArray *tempArray = [self getCouponInfoWithData:dict];
        [cellList addObjectsFromArray:tempArray];
        [cellList addObjectsFromArray:blankArray];
        [dataArray addObject:cellList];
        self.dataSource = [CKList listWithArray:dataArray];
        [self.tableView reloadData];
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        
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
        } else if (status.integerValue == 5) {
            [bottomButton setTitle:@"前去支付" forState:UIControlStateNormal];
        } else {
            [bottomButton setTitle:@"完善资料" forState:UIControlStateNormal];
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
        UILabel *tipsLabel = (UILabel *)[cell.contentView viewWithTag:101];
        
        tipsLabel.text = couponString;
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
    CKDict *item = [self.dataSource objectAtIndex:indexPath.row];
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
    
    //Print the results
    NSLog(@"THE NEW ARRAY IS: %@", newArray);
    
    return newArray;
}

@end
