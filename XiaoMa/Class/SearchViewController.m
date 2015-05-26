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
#import "GetShopByNameOp.h"

@interface SearchViewController ()

@property (weak, nonatomic)IBOutlet JTTableView *tableView;

@property (nonatomic,strong)UIImageView * searchBarBackgroundView;
@property (nonatomic,strong)IBOutlet UISearchBar * searchBar;

@property (nonatomic,strong)NSMutableArray * historyArray;

@property (nonatomic,strong)NSArray * resultArray;

@property (nonatomic)BOOL isSearching;

/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;
///列表下面是否还有商品
@property (nonatomic, assign) BOOL isRemain;
///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;

@property (nonatomic)CLLocationCoordinate2D coordinate;

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
    
    [self getSearchHistory];
    [self getUserLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIView * view = self.navigationController.navigationBar;
    [view addSubview:self.searchBarBackgroundView];
    
    [self.searchBar becomeFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [[searchBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
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
    self.searchBarBackgroundView.borderWidth = 1.0f;
    self.searchBarBackgroundView.borderColor = [UIColor lightGrayColor];
    self.searchBarBackgroundView.layer.cornerRadius = 4.0f;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, width - 120, 36)];
    self.searchBar.barStyle = UIBarStyleDefault;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"找店铺"];
    [self.searchBar setBackgroundColor:[UIColor clearColor]];
    
    UIView * subview = [self.searchBar.subviews safetyObjectAtIndex:0];
    for (UIView * subsubView in subview.subviews)
    {
        if ([subsubView isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subsubView removeFromSuperview];
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
    if (self.searchBar.text.length)
    {
        self.isSearching = YES;
        
        [self searchShops];
        
        for (NSString * keyword in self.historyArray)
        {
            if ([keyword isEqualToString:self.searchBar.text])
            {
                return;
            }
        }
        [self.historyArray insertObject:self.searchBar.text atIndex:0];
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
    NSString * searchInfo = self.searchBar.text;
    searchInfo = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    GetShopByNameOp * op = [GetShopByNameOp operation];
    op.shopName = searchInfo;
    op.longitude = self.coordinate.longitude;
    op.latitude = self.coordinate.latitude;
    op.pageno = self.currentPageIndex;
    op.orderby = 1;
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetShopByNameOp * op) {
        
        [self.searchBar resignFirstResponder];
        if (op.rsp_code == 0)
        {
            self.resultArray = op.rsp_shopArray;
            if (self.resultArray.count == 0)
            {
                self.tableView.showBottomLoadingView = YES;
                [self.tableView.bottomLoadingView showIndicatorTextWith:@"附近30公里内，没有您要找的商户"];
            }
            else
            {
                if (op.rsp_shopArray.count >= self.pageAmount)
                {
                    self.isRemain = YES;
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
            [SVProgressHUD showErrorWithStatus:@"获取失败"];
        }
    } error:^(NSError *error) {
        
        [self.searchBar becomeFirstResponder];
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
    GetShopByNameOp * op = [GetShopByNameOp operation];
    op.shopName = searchInfo;
    op.pageno = self.currentPageIndex+1;
    op.orderby = 1;
    
    [[[op rac_postRequest] initially:^{
        
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
    }] subscribeNext:^(GetShopByNameOp * op) {
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
        if(op.rsp_code == 0)
        {
            self.currentPageIndex ++;
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

- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName:[UIColor lightGrayColor],
                            NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", price1] attributes:attr1];
    
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                            NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" ￥%@", price2] attributes:attr2];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    [str appendAttributedString:attrStr1];
    [str appendAttributedString:attrStr2];
    return str;
}

#pragma mark - UITableView Delegate & DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isSearching)
    {
        return 185;
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 首末提示和清除记录
    if (self.isSearching)
    {
        return self.resultArray.count;
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
        
        JTShop * shop = [self.resultArray safetyObjectAtIndex:indexPath.row];
        
        UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
        JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
        UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
        UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
        UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
        
        RAC(logoV, image) = [gMediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0]
                                             withDefaultPic:@"cm_shop"];
        titleL.text = shop.shopName;
        ratingV.ratingValue = shop.shopRate;
        ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
        addrL.text = shop.shopAddress;
        
        double myLat = gMapHelper.coordinate.latitude;
        double myLng = gMapHelper.coordinate.longitude;
        double shopLat = shop.shopLatitude;
        double shopLng = shop.shopLongitude;
        NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
        distantL.text = disStr;
        //row 1
        UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
        UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
        UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
        
        JTShopService * service;
        for (JTShopService * s in shop.shopServiceArray)
        {
            if (s.shopServiceType == ShopServiceCarWash)
            {
                service = s;
                break;
            }
        }
        
        
        washTypeL.text = service.serviceName;
        NSArray * rates = service.chargeArray;
        ChargeContent * cc;
        for (ChargeContent * tcc in rates)
        {
            if (tcc.paymentChannelType == PaymentChannelABCIntegral )
            {
                cc = tcc;
                break;
            }
        }
        
        integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
        priceL.attributedText = [self priceStringWithOldPrice:@(service.origprice) curPrice:@(service.contractprice)];
        
        //row 2
        UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
        UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
        
        @weakify(self)
        [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:gMapHelper.coordinate andView:self.view];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
 
    [self.searchBar resignFirstResponder];
    
    if (self.isSearching)
    {
        JTShop * shop = [self.resultArray safetyObjectAtIndex:indexPath.row];
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
            [self cleanHistory];
            return;
        }
        NSString * content = [self.historyArray safetyObjectAtIndex:indexPath.row - 1];
        self.searchBar.text = content;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.resultArray.count-1 <= indexPath.row && self.isRemain)
    {
        [self searchMoreShops];
    }
}

#pragma mark - UISearchBar Delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self search];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.tableView.showBottomLoadingView = NO;
//    [self.tableView reloadData];
    
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

@end
