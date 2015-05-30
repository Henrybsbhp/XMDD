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



@interface CarWashTableVC ()<SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) SYPaginatorView *adView;

@property (nonatomic, strong) NSArray *datasource;

@property (strong, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic)CLLocationCoordinate2D  userCoordinate;

/// 每页数量
@property (nonatomic, assign) NSUInteger pageAmount;
///列表下面是否还有商户
@property (nonatomic, assign) BOOL isRemain;
///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;
@end

@implementation CarWashTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRemain = YES;
    self.pageAmount = PageAmount;
    self.currentPageIndex = 1;
    
    [self setupSearchView];
    [self setupADView];
    [self setupTableView];
    
    [self requestCarWashShopList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAdView) name:CarwashAdvertiseNotification object:nil];
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
        
        @strongify(self)
        SearchViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[self.searchField rac_newTextChannel] subscribeNext:^(id x) {
        

    }];
    
    [[self.searchField rac_textSignal] subscribeNext:^(id x) {
        
    }];
}

- (void)setupADView
{
    if (gAdMgr.carwashAdvertiseArray.count <= 0) {
        return;
    }
    
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

    [self refreshAdView];
    
    @weakify(self);
    RACDisposable *dis = [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {

        @strongify(self);
        NSInteger index = [self.adView currentPageIndex] + 1;
        if (index >= gAdMgr.carwashAdvertiseArray.count) {
            index = 0;
        }
        [self.adView setCurrentPageIndex:index animated:YES];
    }];
    [[self rac_deallocDisposable] addDisposable:dis];
}

- (void)refreshAdView
{
    BOOL flag = gAdMgr.carwashAdvertiseArray.count;
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = 360.0f/1242.0f*width;
    if (flag)
    {
        self.adView.hidden = NO;
        
        [self.adView reloadData];
        self.adView.currentPageIndex = 0;
    }
    else
    {
        self.adView.hidden = YES;
    }
    CGRect rect = self.headerView.frame;
    rect.size.height = flag ? height + 45 : 45;
    self.headerView.frame = rect;
    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:self.headerView];
    [self.tableView endUpdates];
}


- (void)setupTableView
{
    self.tableView.showBottomLoadingView = YES;
}

- (void)reloadDataWithText:(NSString *)text error:(NSError *)error
{
    if (error) {
        self.datasource = nil;
        text = text ? text : error.domain;
        [self.tableView setTableHeaderView:nil];
    }
    else {
        self.tableView.tableHeaderView = self.headerView;
    }

    [self.tableView reloadData];
    if (self.datasource.count == 0) {
        NSLog(@"frame = %@", NSStringFromCGRect(self.tableView.frame));
        [self.tableView showDefaultEmptyViewWithText:text];
    }
    else {
        [self.tableView hideDefaultEmptyView];
    }
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
    [[gMediaMgr rac_getPictureForUrl:ad.adPic withType:ImageURLTypeThumbnail defaultPic:@"hp_bottom" errorPic:@"hp_bottom"]
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
    [[[gesture rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        if (ad.adLink.length)
        {
            WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
            vc.title = @"洗车广告";
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

    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    JTShop *shop = [self.datasource safetyObjectAtIndex:indexPath.row];
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
    ratingV.ratingValue = (NSInteger)shop.shopRate;
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
    priceL.attributedText = [self priceStringWithOldPrice:@(service.origprice) curPrice:@(service.contractprice)];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    @weakify(self)
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userCoordinate andView:self.view];
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
        
        [gToast showingWithText:@"加载中…" ];
    }] subscribeNext:^(MAUserLocation *userLocation) {
    
        @strongify(self)
        self.userCoordinate = userLocation.coordinate;
        GetShopByDistanceOp * getShopByDistanceOp = [GetShopByDistanceOp new];
        getShopByDistanceOp.longitude = userLocation.coordinate.longitude;
        getShopByDistanceOp.latitude = userLocation.coordinate.latitude;
        getShopByDistanceOp.pageno = self.currentPageIndex;
        [[[getShopByDistanceOp rac_postRequest] initially:^{
            
            [gToast showingWithText:@"加载中…"];
            
        }] subscribeNext:^(GetShopByDistanceOp * op) {
            
            @strongify(self);
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
                [self reloadDataWithText:@"暂无商铺" error:nil];
            }
        } error:^(NSError *error) {
            
            [gToast showError:@"获取商店列表失败"];
        }];
    } error:^(NSError *error) {
        
        @strongify(self);
        [SVProgressHUD dismiss];
        [self reloadDataWithText:@"定位失败" error:error];
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
    getShopByDistanceOp.longitude = self.userCoordinate.longitude;
    getShopByDistanceOp.latitude = self.userCoordinate.latitude;
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
        [self reloadDataWithText:@"暂无商铺" error:nil];
        
    } error:^(NSError *error) {
        
        [gToast showError:@"获取商户列表失败"];
    }];
}



@end
