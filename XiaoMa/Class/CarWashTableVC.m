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
#import "WebVC.h"
#import "HKAdvertisement.h"
#import "UIView+DefaultEmptyView.h"



@interface CarWashTableVC ()<SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (nonatomic, strong) SYPaginatorView *adView;
@property (nonatomic, strong) RACDisposable *rac_adDisposable;
@property (nonatomic, strong) NSArray *adList;

@property (nonatomic)CLLocationCoordinate2D  userCoordinate;

///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;
@end

@implementation CarWashTableVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.forbidAD)
        [MobClick beginLogPageView:@"rp201"];
    else
        [MobClick beginLogPageView:@"rp102"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.forbidAD)
        [MobClick endLogPageView:@"rp201"];
    else
        [MobClick endLogPageView:@"rp102"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAdList) name:CarwashAdvertiseNotification object:nil];
    
    CKAsyncMainQueue(^{
        [self setupSearchView];
        [self setupTableView];
        [self reloadAdList];
        [self.loadingModel loadDataForTheFirstTime];
    });
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
    [self.searchField resignFirstResponder];
    self.searchField.enabled = NO;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] init];
    [self.searchView addGestureRecognizer:tap];

    @weakify(self)
    [[tap rac_gestureSignal] subscribeNext:^(id x) {
        if (self.forbidAD)
            [MobClick event:@"rp201-2"];
        else
            [MobClick event:@"rp102-2"];
        @strongify(self)
        SearchViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [[self.searchField rac_newTextChannel] subscribeNext:^(id x) {

    }];
    
    [[self.searchField rac_textSignal] subscribeNext:^(id x) {
        
    }];
}

- (void)reloadAdList
{
    if (self.forbidAD) {
        self.adList = nil;
        [self refreshAdView];
        return;
    }

    @weakify(self);
    [[gAdMgr rac_fetchAdListByType:AdvertisementCarWash] subscribeNext:^(NSArray *ads) {
        
        @strongify(self);
        self.adList = ads;
        [self refreshAdView];
    }];
}

- (void)refreshAdView
{
    if (self.adList.count > 0) {
        CGFloat width = CGRectGetWidth(self.view.frame);
        CGFloat height = 360.0f/1242.0f*width;
        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), height+45);
        if (!self.adView) {
            SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 45, width, height)];
            adView.delegate = self;
            adView.dataSource = self;
            adView.pageGapWidth = 0;
            self.adView = adView;
        }
        [self.headerView addSubview:self.adView];
        [self.adView reloadDataRemovingCurrentPage:YES];
        self.adView.currentPageIndex = 0;
        self.adView.pageControl.hidden = self.adList.count <= 1;
        
        //重置广告滚动的定时器
        [self.rac_adDisposable dispose];
        @weakify(self);
        self.rac_adDisposable = [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {
            
            @strongify(self);
            NSInteger index = [self.adView currentPageIndex] + 1;
            if (index >= self.adList.count) {
                index = 0;
            }
            [self.adView setCurrentPageIndex:index animated:YES];
        }];
    }
    else {
        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 45);
        [self.adView removeFromSuperview];
        
        //清理广告的定时器
        [self.rac_adDisposable dispose];
        [[self rac_deallocDisposable] removeDisposable:self.rac_adDisposable];
    }
    if (self.loadingModel.datasource.count > 0) {
        [self.tableView setTableHeaderView:self.headerView];
    }
}


- (void)setupTableView
{
    self.tableView.showBottomLoadingView = YES;
    self.tableView.contentInset = UIEdgeInsetsZero;
}


#pragma mark - Action
- (IBAction)actionMap:(id)sender
{
    if (self.forbidAD) {
        [MobClick event:@"rp201-1"];
    }
    else {
        [MobClick event:@"rp102-1"];
    }
    NearbyShopsViewController * nearbyShopView = [carWashStoryboard instantiateViewControllerWithIdentifier:@"NearbyShopsViewController"];
    nearbyShopView.type = self.type;
    nearbyShopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearbyShopView animated:YES];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKDatasourceLoadingType)type
{
    return @"暂无商铺";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    //定位失败
    if (error.customTag == 1) {
        return @"定位失败";
    }
    return @"获取商铺失败，点击重试";
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingFailWithType:(HKDatasourceLoadingType)type error:(NSError *)error
{
    //定位失败
    if (error.customTag == 1) {
        switch (error.code) {
            case kCLErrorDenied:
            {
                if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
                {
                    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开,然后重启应用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
                    
                    [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                        
                        if ([x integerValue] == 1)
                        {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    [av show];
                }
                else
                {
                    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开，然后重启应用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                    
                    [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                        
                        [self.navigationController popViewControllerAnimated:YES];
                    }];
                    
                    [av show];
                }
                break;
            }
            case LocationFail:
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"城市定位失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
                [av show];
            }
            default:
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"定位失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
                [av show];
                break;
            }
        }
    }
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKDatasourceLoadingType)type
{
    if (type != HKDatasourceLoadingTypeLoadMore) {
        self.currentPageIndex = 0;
    }
    
    @weakify(self);
    return [[[gMapHelper rac_getUserLocation] catch:^RACSignal *(NSError *error) {
        
        NSError *mappedError = [NSError errorWithDomain:@"" code:error.code userInfo:nil];
        mappedError.customTag = 1;
        return [RACSignal error:mappedError];
    }] flattenMap:^RACStream *(MAUserLocation *userLocation) {
        
        @strongify(self)
        self.userCoordinate = userLocation.coordinate;
        GetShopByDistanceOp * getShopByDistanceOp = [GetShopByDistanceOp new];
        getShopByDistanceOp.longitude = userLocation.coordinate.longitude;
        getShopByDistanceOp.latitude = userLocation.coordinate.latitude;
        getShopByDistanceOp.pageno = self.currentPageIndex+1;
        return [[getShopByDistanceOp rac_postRequest] map:^id(GetShopByDistanceOp *op) {
            
            self.currentPageIndex = self.currentPageIndex+1;
            return op.rsp_shopArray;
        }];
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKDatasourceLoadingType)type
{
    [self.tableView reloadData];
    if (model.datasource.count == 0) {
        self.tableView.tableHeaderView = nil;
    }
    else if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = self.headerView;
    }
}

#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return gAdMgr.carwashAdvertiseArray.count;
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
    UIImageView *imgV = (UIImageView *)[pageView searchViewWithTag:1001];
    HKAdvertisement * ad = [gAdMgr.carwashAdvertiseArray safetyObjectAtIndex:pageIndex];
    [[gMediaMgr rac_getPictureForUrl:ad.adPic withType:ImageURLTypeMedium defaultPic:@"hp_bottom" errorPic:@"hp_bottom"]
     subscribeNext:^(id x) {
        imgV.image = x;
    }];
    
    UITapGestureRecognizer * gesture = imgV.customObject;
    if (!gesture)
    {
        UITapGestureRecognizer *ge = [[UITapGestureRecognizer alloc] init];
        [imgV addGestureRecognizer:ge];
        imgV.userInteractionEnabled = YES;
        imgV.customObject = ge;
    }
    gesture = imgV.customObject;
    
    @weakify(self)
    [[[gesture rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        NSString * eventstr = [NSString stringWithFormat:@"rp102-6_%ld", pageIndex];
        [MobClick event:eventstr];
        @strongify(self)
        if (ad.adLink.length)
        {
            WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
            vc.url = ad.adLink;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];

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

    return self.loadingModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    //row 0  缩略图、名称、评分、地址、距离等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];

    
    [[[gMediaMgr rac_getPictureForUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defaultPic:@"cm_shop" errorPic:@"cm_shop"] takeUntilForCell:cell] subscribeNext:^(UIImage * image) {
        logoV.image = image;
    }];
    
    titleL.text = shop.shopName;
    ratingV.ratingValue = shop.shopRate;
    ratingL.text = [NSString stringWithFormat:@"%.1f分", shop.shopRate];
    addrL.text = shop.shopAddress;
    
    double myLat = self.userCoordinate.latitude;
    double myLng = self.userCoordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;

    //row 1 洗车服务与价格
    UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
    
    
    JTShopService * service = [shop.shopServiceArray firstObjectByFilteringOperator:^BOOL(JTShopService * s) {
        return s.shopServiceType == ShopServiceCarWash;
    }];

    washTypeL.text = service.serviceName;

    ChargeContent * cc = [service.chargeArray firstObjectByFilteringOperator:^BOOL(ChargeContent * tcc) {
        return tcc.paymentChannelType == PaymentChannelABCIntegral;
    }];
    
    integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
    priceL.attributedText = [self priceStringWithOldPrice:nil curPrice:@(service.origprice)];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    @weakify(self)
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        if (self.forbidAD) {
            [MobClick event:@"rp201-4"];
        }
        else {
            [MobClick event:@"rp102-4"];
        }
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userCoordinate andView:self.view];
    }];
    
    [[[phoneB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        if (self.forbidAD) {
            [MobClick event:@"rp201-5"];
        }
        else {
            [MobClick event:@"rp102-5"];
        }
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
    
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nest:NO promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.forbidAD)
        [MobClick event:@"rp201-3"];
    else
        [MobClick event:@"rp102-3"];
    ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Utility
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

@end
