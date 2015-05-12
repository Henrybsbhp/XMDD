//
//  CarWashTableVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashTableVC.h"
#import <Masonry.h>
#import "XiaoMa.h"
#import "JTRatingView.h"
#import "SYPaginator.h"
#import "UIView+Layer.h"
#import "ShopDetailVC.h"
#import "JTShop.h"
#import "DistanceCalcHelper.h"
#import "BaseMapViewController.h"
#import "CarWashNavigationViewController.h"
#import "JTTableView.h"
#import "GetShopByDistanceOp.h"
#import "NearbyShopsViewController.h"
#import "SearchViewController.h"


@interface CarWashTableVC ()<SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) SYPaginatorView *adView;

@property (nonatomic, strong) NSArray *datasource;

@property (strong, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic)CLLocationCoordinate2D  userCoordinate;

/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;
///列表下面是否还有商品
@property (nonatomic, assign) BOOL isRemain;
///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;
@end

@implementation CarWashTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRemain = YES;
    self.pageAmount = 10;
    self.currentPageIndex = 1;
    
    [self setupSearchView];
    [self setupADView];
    [self setupTableView];
    
    [self requestCarWashShopList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"CarWashTableVC Dealloc");
}

#pragma mark - Setup UI
- (void)setupSearchView
{
    UIImage *bg = [UIImage imageNamed:@"nb_search_bg"];
    bg = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.searchField.background = bg;
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imgV.image = [UIImage imageNamed:@"nb_search"];
    imgV.contentMode = UIViewContentModeCenter;
    self.searchField.leftView = imgV;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    
    [[self.searchField rac_newTextChannel] subscribeNext:^(id x) {
        
        SearchViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[self.searchField rac_textSignal] subscribeNext:^(id x) {
        
    }];
}

- (void)setupADView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = 360.0f/1242.0f*width;
    SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.delegate = self;
    adView.dataSource = self;
    adView.pageGapWidth = 0;
    [self.headerView addSubview:adView];
    self.adView = adView;
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView);
        make.right.equalTo(self.headerView);
        make.top.equalTo(self.searchView.mas_bottom);
        make.height.mas_equalTo(height);
    }];
    self.adView.currentPageIndex = 0;
    
    CGRect rect = self.headerView.frame;
    rect.size.height += height;
    self.headerView.frame = rect;
}


- (void)setupTableView
{
    self.tableView.showBottomLoadingView = YES;
}

#pragma mark - Action
- (IBAction)actionMap:(id)sender
{
    NearbyShopsViewController * nearbyShopView = [carWashStoryboard instantiateViewControllerWithIdentifier:@"NearbyShopsViewController"];
    nearbyShopView.type = self.type;
    nearbyShopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearbyShopView animated:YES];
}


#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return 3;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    if (!pageView) {
        pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        imgV.tag = 1001;
        [pageView addSubview:imgV];
    }
    UIImageView *imgV = (UIImageView *)[pageView viewWithTag:1001];
    imgV.image = [UIImage imageNamed:@"tmp_ad1"];
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    JTShop *shop = [self.datasource safetyObjectAtIndex:indexPath.row];
    //row 0
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    
    RAC(logoV, image) = [gMediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0]
                                        withDefaultPic:@"tmp_ad"];
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
        [gPhoneHelper navigationRedirectThireMap:shop andUserLocation:self.userCoordinate andView:self.view];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger mask = indexPath.row == 0 ? CKViewBorderDirectionBottom : CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:mask];
    [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(0, 0, 8, 0) forDirectionMask:mask];
    [cell.contentView showBorderLineWithDirectionMask:mask];
    
    if (self.datasource.count-1 <= indexPath.row && self.isRemain)
    {
        [self requestMoreCarWashShopList];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.shop = [self.datasource safetyObjectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Utility
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


- (void)requestCarWashShopList
{
    @weakify(self)
    [[[[gMapHelper rac_getUserLocation] take:1] initially:^{
        
        [SVProgressHUD showWithStatus:@"Loading"];
    }] subscribeNext:^(MAUserLocation *userLocation) {
    
        @strongify(self)
        self.userCoordinate = userLocation.coordinate;
        GetShopByDistanceOp * getShopByDistanceOp = [GetShopByDistanceOp new];
        getShopByDistanceOp.longitude = userLocation.coordinate.longitude;
        getShopByDistanceOp.latitude = userLocation.coordinate.latitude;
        getShopByDistanceOp.pageno = self.currentPageIndex;
        [[[getShopByDistanceOp rac_postRequest] initially:^{
            
            [SVProgressHUD showWithStatus:@"Loading"];
            
        }] subscribeNext:^(GetShopByDistanceOp * op) {
            
            [SVProgressHUD dismiss];
            self.datasource = op.rsp_shopArray;
            if (self.datasource.count == 0)
            {
                
            }
            else
            {
                if (self.datasource.count >= self.pageAmount)
                {
                    self.isRemain = YES;
                }
                else
                {
                    self.isRemain = NO;
                }
                if (!self.isRemain)
                {
                    [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
                }
                [self.tableView reloadData];
            }
        } error:^(NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:@"error"];
        }];
    } error:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"定位失败"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (void)requestMoreCarWashShopList
{
    if ([self.tableView.bottomLoadingView isActivityAnimating])
    {
        return;
    }
    
    GetShopByDistanceOp * getShopByDistanceOp = [GetShopByDistanceOp new];
    getShopByDistanceOp.longitude = 120.189234;
    getShopByDistanceOp.latitude = 30.254189;
    getShopByDistanceOp.pageno = self.currentPageIndex + 1;
    [[[getShopByDistanceOp rac_postRequest] initially:^{
        
        [self.tableView.bottomLoadingView hideIndicatorText];
        [self.tableView.bottomLoadingView startActivityAnimationWithType:MONActivityIndicatorType];
    }] subscribeNext:^(GetShopByDistanceOp * op) {
        
        [self.tableView.bottomLoadingView stopActivityAnimation];
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
            [self.tableView.bottomLoadingView showIndicatorTextWith:@"已经到底了"];
        }
        NSMutableArray * tArray = [NSMutableArray arrayWithArray:self.datasource];
        [tArray addObjectsFromArray:op.rsp_shopArray];
        self.datasource = [NSArray arrayWithArray:tArray];
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        [SVProgressHUD showErrorWithStatus:@"error"];
    }];
}

@end
