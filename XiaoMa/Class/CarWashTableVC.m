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
#import "UIView+Layer.h"
#import "ShopDetailVC.h"
#import "JTShop.h"
#import "DistanceCalcHelper.h"
#import "BaseMapViewController.h"
#import "CarWashNavigationViewController.h"
#import "JTTableView.h"
#import "GetShopByDistanceV2Op.h"
#import "NearbyShopsViewController.h"
#import "SearchViewController.h"
#import "WebVC.h"
#import "UIView+DefaultEmptyView.h"
#import "NSDate+DateForText.h"
#import "ADViewController.h"


@interface CarWashTableVC ()
@property (nonatomic)CLLocationCoordinate2D  userCoordinate;
@property (nonatomic, strong) ADViewController *adctrl;
///当前页码索引
@property (nonatomic, assign) NSUInteger currentPageIndex;
@end

@implementation CarWashTableVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp102"];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp102"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    //    self.tableView.tableHeaderView = nil;
    //    self.tableView.tableFooterView = nil;
    self.loadingModel = [[HKLoadingModel alloc] initWithTargetView:self.tableView delegate:self];
    self.loadingModel.isSectionLoadMore = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAdList) name:CarwashAdvertiseNotification object:nil];
    
    CKAsyncMainQueue(^{
        [self setupSearchView];
        [self setupTableView];
        [self setupADView];
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
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
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

- (void)setupADView
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementCarWash boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp102-6"];
}

- (void)reloadAdList
{
    if (self.forbidAD) {
        [self refreshAdView];
        return;
    }
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        [self refreshAdView];
    }];
}

- (void)refreshAdView
{
    if (!self.forbidAD && self.adctrl.adList.count > 0) {
        CGRect frame = self.adctrl.adView.frame;
        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(frame)+45);
        frame.origin.y = 45;
        self.adctrl.adView.frame = frame;
        [self.headerView addSubview:self.adctrl.adView];
    }
    else {
        self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 45);
        [self.adctrl.adView removeFromSuperview];
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
    [MobClick event:@"rp102-1"];
    NearbyShopsViewController * nearbyShopView = [carWashStoryboard instantiateViewControllerWithIdentifier:@"NearbyShopsViewController"];
    nearbyShopView.type = self.type;
    nearbyShopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearbyShopView animated:YES];
}

#pragma mark - HKLoadingModelDelegate
- (NSString *)loadingModel:(HKLoadingModel *)model blankPromptingWithType:(HKLoadingTypeMask)type
{
    return @"暂无商铺";
}

- (NSString *)loadingModel:(HKLoadingModel *)model errorPromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    //定位失败
    if (error.customTag == 1) {
        return @"定位失败";
    }
    return @"获取商铺失败，点击重试";
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingFailWithType:(HKLoadingTypeMask)type error:(NSError *)error
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

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
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
        GetShopByDistanceV2Op * getShopByDistanceOp = [GetShopByDistanceV2Op new];
        getShopByDistanceOp.longitude = userLocation.coordinate.longitude;
        getShopByDistanceOp.latitude = userLocation.coordinate.latitude;
        getShopByDistanceOp.pageno = self.currentPageIndex+1;
        return [[getShopByDistanceOp rac_postRequest] map:^id(GetShopByDistanceV2Op *op) {
            
            self.currentPageIndex = self.currentPageIndex+1;
            return op.rsp_shopArray;
        }];
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    [self.tableView reloadData];
    if (model.datasource.count == 0) {
        self.tableView.tableHeaderView = nil;
    }
    else if (!self.tableView.tableHeaderView) {
        self.tableView.tableHeaderView = self.headerView;
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 8.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.loadingModel.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger num = 0;
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:section];
    num = 1 + shop.shopServiceArray.count + 1;
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell;
    
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSInteger mask = indexPath.row == 0 ? CKViewBorderDirectionBottom : CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    //    [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:mask];
    //    [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(0, 0, 8, 0) forDirectionMask:mask];
    //    [cell.contentView showBorderLineWithDirectionMask:mask];
    
    JTShop * shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    NSInteger count = shop.shopServiceArray.count + 2;
    [self.loadingModel loadMoreDataIfNeededWithIndexPath:indexPath nestItemCount:count promptView:self.tableView.bottomLoadingView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp102-3"];
    ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
    vc.couponFordetailsDic = self.couponForWashDic;
    vc.hidesBottomBarWhenPushed = YES;
    vc.shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Utility
- (UITableViewCell *)tableView:(UITableView *)tableView shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    
    //row 0  缩略图、名称、评分、地址、距离、营业状况等
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    UILabel *statusL = (UILabel *)[cell.contentView viewWithTag:1007];
    UILabel *commentNumL = (UILabel *)[cell.contentView viewWithTag:1008];
    UIImageView *statusImg=(UIImageView *)[cell.contentView viewWithTag:1009];
    
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
    
    if([shop.isVacation integerValue] == ShopVacationTypeVacation)//isVacation==1表示正在休假
    {
        statusL.hidden = YES;
        statusImg.hidden = NO;
    }
    else
    {
        statusL.hidden = NO;
        statusImg.hidden = YES ;
        
        if ([self isBetween:shop.openHour and:shop.closeHour]) {
            statusL.text = @"营业中";
            statusL.backgroundColor = [UIColor colorWithHex:@"#1bb745" alpha:1.0f];
        }
        else {
            statusL.text = @"已休息";
            statusL.backgroundColor = [UIColor colorWithHex:@"#b6b6b6" alpha:1.0f];
        }
    }
    
    double myLat = self.userCoordinate.latitude;
    double myLng = self.userCoordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopServiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
    
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    
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
    
    JTShop *shop = [self.loadingModel.datasource safetyObjectAtIndex:indexPath.section];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    @weakify(self)
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [MobClick event:@"rp102-4"];
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userCoordinate andView:self.tabBarController.view];
    }];
    
    [[[phoneB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp102-5"];
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
        NSString * p = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:[price1 floatValue]]];
        NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:p attributes:attr1];
        [str appendAttributedString:attrStr1];
    }
    
    if (price2) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
        NSString * p = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:[price2 floatValue]]];
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:p attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}

@end
