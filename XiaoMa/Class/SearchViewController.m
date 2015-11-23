//
//  SearchViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-4.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SearchViewController.h"
#import "JTTableView.h"
#import "JTShop.h"
#import "ShopDetailVC.h"
#import "JTRatingView.h"
#import "DistanceCalcHelper.h"
#import "GetShopByNameV2Op.h"
#import "UIView+Layer.h"

@interface SearchViewController ()

@property (weak, nonatomic)IBOutlet JTTableView *tableView;

@property (nonatomic,strong)UIImageView * searchBarBackgroundView;
@property (nonatomic,strong)IBOutlet UISearchBar * searchBar;

@property (nonatomic,strong)NSMutableArray * historyArray;

@property (nonatomic,strong)NSArray * resultArray;

@property (nonatomic)BOOL isSearching;
@property (nonatomic)BOOL isLoading;

/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;
///列表下面是否还有商品
@property (nonatomic, assign) BOOL isRemain;
///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;

@property (nonatomic)CLLocationCoordinate2D coordinate;

@property (nonatomic)BOOL firstAppear;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupSearchBar];
    [self setupTableView];
    
    self.isRemain = YES;
    self.pageAmount = PageAmount;
    self.currentPageIndex = 1;
//
    [self getSearchHistory];
    [self getUserLocation];
    
    self.firstAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp103"];
    
    UIView * view = self.navigationController.navigationBar;
    [view addSubview:self.searchBarBackgroundView];
    
    if (self.firstAppear)
    {
        self.firstAppear = NO;
        [self.searchBar becomeFirstResponder];
    }
    else
    {
        [self.searchBar resignFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp103"];
    
    [self.searchBarBackgroundView removeFromSuperview];
}

- (void)dealloc
{
    DebugLog(@"SearchViewController dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
- (void)setupNavigationBar
{
    
    UIButton * searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
    searchBtn.cornerRadius = 5.0f;
    [searchBtn setBackgroundColor:[UIColor colorWithHex:@"#15ac1f" alpha:1.0f]];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    @weakify(self)
    [[searchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp103-1"];
        @strongify(self)
        [self search];
    }];
    UIBarButtonItem *searchBtnItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchBtnItem;
}

- (void)setupSearchBar
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    self.searchBarBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 4, width - 120, 36)];
//    self.searchBarBackgroundView.image = [UIImage imageNamed:@"Navi_Search2"];
    self.searchBarBackgroundView.borderWidth = 0.5f;
    self.searchBarBackgroundView.borderColor = [UIColor colorWithHex:@"#dadada" alpha:1.0f];
    self.searchBarBackgroundView.layer.cornerRadius = 4.0f;
    self.searchBarBackgroundView.backgroundColor = [UIColor clearColor];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, width - 120, 36)];
    self.searchBar.barStyle = UIBarStyleDefault;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"找商户"];
    [self.searchBar setBackgroundColor:[UIColor clearColor]];
    
    UIView * subview = [self.searchBar.subviews safetyObjectAtIndex:0];
    for (UIView * subsubView in subview.subviews)
    {
        if ([subsubView isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subsubView removeFromSuperview];
        }
    }
    
    if ([self.searchBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)])
    {
//        [self.searchBar setBackgroundImage:[UIImage imageNamed:@"Navi_Search2"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    else
    {
//        [self.searchBar setBackgroundImage:[UIImage imageNamed:@"Navi_Search_iOS6"]];
        [self.searchBar setTranslucent:YES];
        for (UIView * subview in self.searchBar.subviews)
        {
            if ([subview isKindOfClass:[UISegmentedControl class]])
            {
                UISegmentedControl * ctrl = (UISegmentedControl *)subview;
                [ctrl setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
                ctrl.hidden = YES;
            }
        }
    }
    
//    UIImage *image = [UIImage imageNamed:@"Search"];
//    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
//    UITextField * searchField = [self.searchBar valueForKey:@"_searchField"];
//    searchField.textColor = [UIColor clearColor];
//    searchField.backgroundColor = [UIColor clearColor];
//    searchField.clearButtonaaaMode = UITextFieldViewModeNever;
    //修改placeholder文字颜色
//    [searchField setValue:[UIColor lightTextColor] forKeyPath:@"_placeholderLabel.textColor"];
//    searchField.leftView = imageView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(defaultViewTap)];
    self.searchBarBackgroundView.userInteractionEnabled = YES;
    [self.searchBarBackgroundView addGestureRecognizer:tap];
    
    [self.searchBarBackgroundView addSubview:self.searchBar];
}

- (void)setupTableView
{
    self.tableView.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
    self.tableView.showBottomLoadingView = NO;
}

- (void)defaultViewTap
{
    [self.searchBar becomeFirstResponder];
}

#pragma mark - Action
- (void)navigationBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)search
{
    NSString * searchInfo = self.searchBar.text;
    searchInfo = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchInfo.length)
    {
        self.isSearching = YES;
        
        if (!self.isLoading)
        {
            [self searchShops];
        }
        
        for (NSString * keyword in self.historyArray)
        {
            if ([keyword isEqualToString:searchInfo])
            {
                return;
            }
        }
        [self.historyArray insertObject:searchInfo atIndex:0];
        if(self.historyArray.count > 15)
        {
            [self.historyArray removeLastObject];
        }
        [gAppMgr saveInfo:self.historyArray forKey:SearchHistory];
    }
}

- (void)cancelSearch
{
    UIBarButtonItem *searchBtn =
    [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStyleDone target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = searchBtn;
    
    self.isSearching = NO;
    [self.searchBar becomeFirstResponder];
}

- (void)getSearchHistory
{
    self.historyArray = [NSMutableArray arrayWithArray:[gAppMgr loadSearchHistory]];
    [self.tableView reloadData];
}

- (void)cleanHistory
{
    [self.historyArray removeAllObjects];
    [gAppMgr cleanSearchHistory];
    [self.tableView reloadData];
}

#pragma mark - Utility
- (void)searchShops
{
    self.currentPageIndex = 1;
    NSString * searchInfo = self.searchBar.text;
    searchInfo = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    GetShopByNameV2Op * op = [GetShopByNameV2Op operation];
    op.shopName = searchInfo;
    op.longitude = self.coordinate.longitude;
    op.latitude = self.coordinate.latitude;
    op.pageno = self.currentPageIndex;
    op.orderby = 1;
    
    [self.tableView hideDefaultEmptyView];
    self.isLoading = YES;
    
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetShopByNameV2Op * op) {
        
        self.isLoading = NO;
        [self.searchBar resignFirstResponder];
        if (op.rsp_code == 0)
        {
            self.isSearching = YES;
            self.currentPageIndex = self.currentPageIndex + 1;
            
            self.resultArray = op.rsp_shopArray;
            if (self.resultArray.count == 0)
            {
                self.tableView.showBottomLoadingView = YES;
                [self.tableView.bottomLoadingView hideIndicatorText];
                [self.tableView showDefaultEmptyViewWithText:@"附近没有您要找的商户"];
            }
            else
            {
                [self.tableView hideDefaultEmptyView];
                if (op.rsp_shopArray.count >= self.pageAmount)
                {
                    self.isRemain = YES;
                    [self.tableView.bottomLoadingView hideIndicatorText];
                }
                else
                {
                    self.isRemain = NO;
                    self.tableView.showBottomLoadingView = YES;
                    [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
                }
            }
            [self.tableView reloadData];
        }
        else
        {
            [gToast showError:@"获取失败"];
        }
    } error:^(NSError *error) {
        
        self.isLoading = NO;
        self.resultArray = nil;
        @weakify(self);
        [self.tableView showDefaultEmptyViewWithText:error.domain tapBlock:^{
            
            @strongify(self);
            [self searchShops];
        }];
        [self.tableView reloadData];
    }];

}

- (void)searchMoreShops
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    
    NSString * searchInfo = self.searchBar.text;
    searchInfo = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    GetShopByNameV2Op * op = [GetShopByNameV2Op operation];
    op.longitude = self.coordinate.longitude;
    op.latitude = self.coordinate.latitude;
    op.shopName = searchInfo;
    op.pageno = self.currentPageIndex;
    op.orderby = 1;
    
    [[[op rac_postRequest] initially:^{
        
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
        self.isLoading = YES;
    }] subscribeNext:^(GetShopByNameV2Op * op) {
        
        self.currentPageIndex = self.currentPageIndex + 1;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        self.isLoading = NO;
        if(op.rsp_code == 0)
        {
            [self.tableView hideDefaultEmptyView];
            if (op.rsp_shopArray.count >= self.pageAmount)
            {
                self.isRemain = YES;
            }
            else
            {
                self.isRemain = NO;
            }
            if (!self.isRemain)
            {
                self.tableView.showBottomLoadingView = YES;
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
            }
            
            NSMutableArray * tArray = [NSMutableArray arrayWithArray:self.resultArray];
            [tArray addObjectsFromArray:op.rsp_shopArray];
            self.resultArray = [NSArray arrayWithArray:tArray];
            [self.tableView reloadData];
        }
        else
        {
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
        }
    } error:^(NSError *error) {
        self.isLoading = NO;
        self.tableView.showBottomLoadingView = YES;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"获取失败，再拉拉看"];
        
    }];
}

- (void)getUserLocation
{
    [[[[gMapHelper rac_getUserLocation] take:1] initially:^{
        
    }] subscribeNext:^(MAUserLocation *userLocation) {
        
        self.coordinate = userLocation.location.coordinate;
    }];
}

-(BOOL)isBetween:(NSString *)openHourStr and:(NSString *)closeHourStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate * nowDate = [NSDate date];
    NSString * transStr = [formatter stringFromDate:nowDate];
    NSDate * transDate = [formatter dateFromString:transStr];
    
    NSDate * beginDate = [formatter dateFromString:openHourStr];
    NSDate * endDate = [formatter dateFromString:closeHourStr];
    
    return (transDate == [transDate earlierDate:beginDate]) || (transDate == [transDate laterDate:endDate]) ? NO : YES;
}

- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
        NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
        if (price1) {
            NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                    NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                    NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
            NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:
                                            [NSString stringWithFormat:@"￥%.2f", [price1 floatValue]] attributes:attr1];
            [str appendAttributedString:attrStr1];
        }
        
        if (price2) {
            NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                    NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
            NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:
                                            [NSString stringWithFormat:@" ￥%.2f", [price2 floatValue]] attributes:attr2];
            [str appendAttributedString:attrStr2];
        }
        return str;
}

#pragma mark - UITableView Delegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)
    {
        CGFloat height = 0.0;
        JTShop *shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
        NSInteger serviceAmount = shop.shopServiceArray.count;
        NSInteger sectionAmount = 1 + serviceAmount + 1;
        
        if(indexPath.row == 0)
        {
            height = 84.0f;
        }
        else if (indexPath.row == sectionAmount - 1)
        {
            height = 42.0f;
        }
        else
        {
            height = 42.0f;
        }
        return height;
    }
    else
    {
        if (indexPath.row == 0 || indexPath.row == self.historyArray.count+1)
        {
            return 40;
        }
        else
        {
            return 50;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.isSearching)
    {
        return 8.0f;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isSearching)
    {
        return self.resultArray.count;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 首末提示和清除记录
    if (self.isSearching)
    {
        NSInteger num = 0;
        JTShop *shop = [self.resultArray safetyObjectAtIndex:section];
        num = 1 + shop.shopServiceArray.count + 1;
        return num;
    }
    else
    {
        return self.historyArray.count + 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)
    {
        UITableViewCell * cell;
        
        JTShop *shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
        NSInteger serviceAmount = shop.shopServiceArray.count;
        NSInteger sectionAmount = 1 + serviceAmount + 1;
        
        if(indexPath.row == 0)
        {
            cell = [self tableView:tableView shopTitleCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == sectionAmount - 1)
        {
            cell = [self tableView:tableView shopNavigationCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self tableView:tableView shopServiceCellAtIndexPath:indexPath];
        }
        
        return cell;
    }
    else
    {
        if(indexPath.row == 0)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeadCell" forIndexPath:indexPath];
            cell.backgroundColor = [UIColor colorWithHex:@"#f4f4f4" alpha:1.0f];
            return cell;
        }
        else if (indexPath.row == self.historyArray.count + 1)
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CleanCell" forIndexPath:indexPath];
            UILabel * lb = (UILabel *)[cell searchViewWithTag:20301];
            lb.text = self.historyArray.count ? @"清空搜索历史":@"无搜索记录";
            return cell;
        }
        else
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PrepareSearchCell" forIndexPath:indexPath];
            
            UILabel * lb = (UILabel *)[cell searchViewWithTag:101];
            lb.text = [NSString stringWithFormat:@"%@",self.historyArray[indexPath.row-1]];
            
            UIImageView * line = (UIImageView *)[cell searchViewWithTag:102];
            line.hidden = indexPath.row == self.historyArray.count;
            return cell;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    [self.searchBar resignFirstResponder];
    
    if (self.isSearching)
    {
        [MobClick event:@"rp201-3"];
        JTShop * shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
        ShopDetailVC * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"ShopDetailVC"];
        vc.shop = shop;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if (indexPath.row == 0)
        {
            /// 第一条是静态文案
            return;
        }
        if (indexPath.row == self.historyArray.count + 1)
        {
            [MobClick event:@"rp103-2"];
            [self cleanHistory];
            return;
        }
        [MobClick event:@"rp103-3"];
        NSString * content = [self.historyArray safetyObjectAtIndex:indexPath.row - 1];
        self.searchBar.text = content;
        [self search];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isRemain) {
        return;
    }
    JTShop * shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
    NSInteger count = shop.shopServiceArray.count + 2;
    NSInteger index =  indexPath.section + 1;
    if ([self.resultArray count] > index) {
        return;
    }
    else
    {
        if (count) {
            NSInteger index =  indexPath.row + 1;
            if (count > index)
            {
                return;
            }
        }
    }
    [self searchMoreShops];
}

#pragma mark - UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [MobClick event:@"rp103-4"];
    [self search];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.tableView.showBottomLoadingView = NO;
    [self.tableView hideDefaultEmptyView];
    if (!self.searchBar.text.length)
    {
        self.isSearching = NO;
        [self.tableView reloadData];
        self.tableView.showBottomLoadingView = NO;
    }
    
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.isSearching)
    {
        //        self.isSearching = NO;
        //        self.jtTableView.showBottomLoadingView = NO;
        //        [self.jtTableView reloadData];
        if (searchText.length == 0)
        {
            self.isSearching = NO;
            [self.tableView reloadData];
            [self.tableView hideDefaultEmptyView];
            self.tableView.showBottomLoadingView = NO;
        }
    }
    
    //    UITextField * searchField = [self.searchBar valueForKey:@"_searchField"];
    
    //    for (UIView * subview in searchField.subviews)
    //    {
    //        if ([subview isKindOfClass:[UIButton class]])
    //        {
    //            subview.hidden = YES;
    //        }
    //    }
}

#pragma mark - Utility
- (UITableViewCell *)tableView:(UITableView *)tableView shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    
    JTShop *shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
    
    //row 0  缩略图、名称、评分、地址、距离、营业状况等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1007];
    UILabel *commentNumL = (UILabel *)[cell.contentView viewWithTag:1008];
    
    [logoV setImageByUrl:[shop.picArray safetyObjectAtIndex:0]
                withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    
    titleL.text = shop.shopName;
    ratingV.ratingValue = shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
    addrL.text = shop.shopAddress;
    if (shop.ratenumber)
    {
        commentNumL.text = [NSString stringWithFormat:@"%ld", (long)shop.ratenumber];
    }
    else
    {
        commentNumL.text = [NSString stringWithFormat:@"暂无"];
    }
    
    [statusL makeCornerRadius:3];
    statusL.font = [UIFont boldSystemFontOfSize:11];
    if ([self isBetween:shop.openHour and:shop.closeHour]) {
        statusL.text = @"营业中";
        statusL.backgroundColor = [UIColor colorWithHex:@"#1bb745" alpha:1.0f];
    }
    else {
        statusL.text = @"已休息";
        statusL.backgroundColor = [UIColor colorWithHex:@"#b6b6b6" alpha:1.0f];
    }
    
    double myLat = gMapHelper.coordinate.latitude;
    double myLng = gMapHelper.coordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
    
    JTShop *shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
    
    //row 1 洗车服务与价格
    UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
    
    JTShopService * service = [shop.shopServiceArray safetyObjectAtIndex:indexPath.row - 1];
    
    washTypeL.text = service.serviceName;
    
    ChargeContent * cc = [service.chargeArray firstObjectByFilteringOperator:^BOOL(ChargeContent * tcc) {
        return tcc.paymentChannelType == PaymentChannelABCIntegral;
    }];
    
    integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
    priceL.attributedText = [self priceStringWithOldPrice:nil curPrice:@(service.origprice)];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopNavigationCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationCell" forIndexPath:indexPath];
    
    JTShop *shop = [self.resultArray safetyObjectAtIndex:indexPath.section];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {

        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:gMapHelper.coordinate andView:self.tabBarController.view];
    }];
    
    [[[phoneB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        if (shop.shopPhone.length == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:@"该店铺没有电话~" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
            [av show];
            return ;
        }
        
        NSString * info = [NSString stringWithFormat:@"%@",shop.shopPhone];
        [gPhoneHelper makePhone:shop.shopPhone andInfo:info];
    }];
    
    return cell;
}





@end
