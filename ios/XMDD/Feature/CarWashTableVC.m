//
//  CarWashTableVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashTableVC.h"
#import <Masonry.h>
#import "Xmdd.h"
#import "JTRatingView.h"
#import "UIView+Layer.h"
#import "DistanceCalcHelper.h"
#import "BaseMapViewController.h"
#import "CarWashNavigationViewController.h"
#import "JTTableView.h"
#import "GetShopByDistanceV2Op.h"
#import "NearbyShopsViewController.h"
#import "SearchViewController.h"
#import "UIView+DefaultEmptyView.h"
#import "NSDate+DateForText.h"
#import "ADViewController.h"
#import "ShopDetailViewController.h"

@interface CarWashTableVC ()

@property (nonatomic,strong)MAUserLocation *userLocation;
@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) ADViewController *adctrl2;
@property (nonatomic, strong) CKSegmentHelper *segHelper;
@property (weak, nonatomic) IBOutlet UIButton *carwashBtn;
@property (weak, nonatomic) IBOutlet UIButton *withheartBtn;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
- (IBAction)tabBarAtion:(id)sender;

@end

@implementation CarWashTableVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.carwashLoadingModel = [[HKLoadingModel alloc] initWithTargetView:self.carwashTableView delegate:self];
    self.withheartLoadingModel = [[HKLoadingModel alloc] initWithTargetView:self.withheartTableView delegate:self];
    self.carwashLoadingModel.isSectionLoadMore = YES;
    self.withheartLoadingModel.isSectionLoadMore = YES;
    
    CKAsyncMainQueue(^{
        [self setupTableView];
        [self setupADView];
        [self reloadAdList];
        [self setSegmentView];
        [self.carwashLoadingModel loadDataForTheFirstTime];
        [self.withheartLoadingModel loadDataForTheFirstTime];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.carwashTableView.delegate = nil;
    self.carwashTableView.dataSource = nil;
    self.withheartTableView.delegate = nil;
    self.withheartTableView.dataSource = nil;
    DebugLog(@"CarWashTableVC Dealloc");
}

- (void)setupADView
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementCarWash boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp102_6" mobBaseEventDict:nil];
    self.adctrl2 = [ADViewController vcWithADType:AdvertisementCarWash boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp102_6" mobBaseEventDict:nil];
}

- (void)reloadAdList
{
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        [self refreshAdView1];
    }];
    
    [self.adctrl2 reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        if (ads.count > 0) {
            CGRect frame = self.adctrl.adView.frame;
            self.carwashHeaderView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, CGRectGetHeight(frame));
            self.adctrl.adView.frame = frame;
            [self.carwashHeaderView addSubview:self.adctrl.adView];
        }
        else {
            self.carwashHeaderView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, CGFLOAT_MIN);
            [self.adctrl.adView removeFromSuperview];
        }
        [self.carwashTableView setTableHeaderView:self.carwashHeaderView];
        [self refreshAdView2];
    }];
}

- (void)refreshAdView1
{
    if (self.adctrl.adList.count > 0) {
        CGRect frame = self.adctrl.adView.frame;
        self.carwashHeaderView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, CGRectGetHeight(frame));
        self.adctrl.adView.frame = frame;
        [self.carwashHeaderView addSubview:self.adctrl.adView];
    }
    else {
        self.carwashHeaderView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, CGFLOAT_MIN);
        [self.adctrl.adView removeFromSuperview];
    }
    [self.carwashTableView setTableHeaderView:self.carwashHeaderView];
}

- (void)refreshAdView2
{
    if (self.adctrl2.adList.count > 0) {
        CGRect frame = self.adctrl2.adView.frame;
        self.withHeartHeaderView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, CGRectGetHeight(frame));
        self.adctrl2.adView.frame = frame;
        [self.withHeartHeaderView addSubview:self.adctrl2.adView];
    }
    else {
        self.withHeartHeaderView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, CGFLOAT_MIN);
        [self.adctrl2.adView removeFromSuperview];
    }
    [self.withheartTableView setTableHeaderView:self.withHeartHeaderView];
}

- (void)setSegmentView
{
    self.segHelper = [[CKSegmentHelper alloc] init];
    @weakify(self)
    [self.segHelper addItem:self.carwashBtn forGroupName:@"CarwashTabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.line1.hidden = !selected;
        self.carwashTableView.hidden = !selected;
        if (selected) {
            self.serviceType = ShopServiceCarWash;
        }
    }];
    
    [self.segHelper addItem:self.withheartBtn forGroupName:@"CarwashTabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.line2.hidden = !selected;
        self.withheartTableView.hidden = !selected;
        if (selected) {
            self.serviceType = ShopServiceCarwashWithHeart;
        }
    }];
    //默认显示普洗
    if (self.serviceType == ShopServiceCarwashWithHeart)
    {
        [self.segHelper selectItem:self.withheartBtn];
    }
    else
    {
        [self.segHelper selectItem:self.carwashBtn];
    }
    
}

- (void)setupTableView
{
    self.carwashTableView.showBottomLoadingView = YES;
    self.carwashTableView.contentInset = UIEdgeInsetsZero;
    self.withheartTableView.showBottomLoadingView = YES;
    self.withheartTableView.contentInset = UIEdgeInsetsZero;
}


#pragma mark - Action
- (IBAction)tabBarAtion:(id)sender {
    [self.segHelper selectItem:sender];
}

- (IBAction)actionMap:(id)sender
{
    [MobClick event:@"rp102_1"];
    NearbyShopsViewController * nearbyShopView = [carWashStoryboard instantiateViewControllerWithIdentifier:@"NearbyShopsViewController"];
    nearbyShopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearbyShopView animated:YES];
}

- (IBAction)searchAction:(id)sender {
    SearchViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - HKLoadingModelDelegate

-(NSDictionary *)loadingModel:(HKLoadingModel *)model blankImagePromptingWithType:(HKLoadingTypeMask)type
{
    return @{@"title":@"暂无商铺",@"image":@"def_withoutShop"};
}

-(NSDictionary *)loadingModel:(HKLoadingModel *)model errorImagePromptingWithType:(HKLoadingTypeMask)type error:(NSError *)error
{
    //定位失败
    if (error.customTag == 1) {
        return @{@"title":@"定位失败",@"image":@"def_withoutShop"};
    }
    return @{@"title":@"获取商铺失败，点击重试",@"image":@"def_failConnect"};
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
                
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"城市定位失败,请重试" ActionItems:@[cancel]];
                [alert show];
                
            }
            default:
            {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"定位失败，请重试" ActionItems:@[cancel]];
                [alert show];
                
                break;
            }
        }
    }
}

- (RACSignal *)loadingModel:(HKLoadingModel *)model loadingDataSignalWithType:(HKLoadingTypeMask)type
{
    if (type != HKLoadingTypeLoadMore) {
        model.currentPageIndex = 0;
    }
    
    @weakify(self);
    RACSignal * signal;
    if (!self.userLocation || model.currentPageIndex == 0)
    {
        signal = [gMapHelper rac_getUserLocationWithAccuracy:kCLLocationAccuracyHundredMeters];
    }
    else
    {
        signal = [RACSignal return:self.userLocation];
    }
    
    return [[signal catch:^RACSignal *(NSError *error) {
        
        NSError *mappedError = [NSError errorWithDomain:@"" code:error.code userInfo:nil];
        mappedError.customTag = 1;
        return [RACSignal error:mappedError];
    }] flattenMap:^RACStream *(MAUserLocation *userLocation) {
        
        @strongify(self)
        ShopServiceType service =  model == self.carwashLoadingModel ? ShopServiceCarWash : ShopServiceCarwashWithHeart;
        self.userLocation = userLocation;
        GetShopByDistanceV2Op * getShopByDistanceOp = [GetShopByDistanceV2Op new];
        getShopByDistanceOp.longitude = userLocation.coordinate.longitude;
        getShopByDistanceOp.latitude = userLocation.coordinate.latitude;
        getShopByDistanceOp.pageno = model.currentPageIndex+1;
        getShopByDistanceOp.serviceType =  service;
        return [[getShopByDistanceOp rac_postRequest] map:^id(GetShopByDistanceV2Op *op) {
            
//            [self filterShopServiceByType:service andArray:op.rsp_shopArray];
            model.currentPageIndex = model.currentPageIndex+1;
            return op.rsp_shopArray;
        }];
    }];
}

- (void)loadingModel:(HKLoadingModel *)model didLoadingSuccessWithType:(HKLoadingTypeMask)type
{
    UITableView * tableView = model == self.carwashLoadingModel ? self.carwashTableView : self.withheartTableView;
    [tableView reloadData];

//    if (tableView.tableHeaderView != self.headerView) {
//        tableView.tableHeaderView = self.headerView;
//    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKLoadingModel * model = [self modelForTableView:tableView];
    ShopServiceType type = model == self.carwashLoadingModel ? ShopServiceCarWash : ShopServiceCarwashWithHeart;
    CGFloat height = 0.0;
    JTShop *shop = [model.datasource safetyObjectAtIndex:indexPath.section];
    NSArray * serviceArray = [self filterShopServiceByType:type andArray:shop.shopServiceArray];
    NSInteger serviceAmount = serviceArray.count;
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
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    HKLoadingModel * model = [self modelForTableView:tableView];
    return model.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    HKLoadingModel * model = [self modelForTableView:tableView];
    ShopServiceType type = model == self.carwashLoadingModel ? ShopServiceCarWash : ShopServiceCarwashWithHeart;
    JTShop *shop = [model.datasource safetyObjectAtIndex:section];
    NSArray * serviceArray = [self filterShopServiceByType:type andArray:shop.shopServiceArray];
    NSInteger num = 1 + serviceArray.count + 1;
    return num;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell;
    
    HKLoadingModel * model = [self modelForTableView:tableView];
    ShopServiceType type = model == self.carwashLoadingModel ? ShopServiceCarWash : ShopServiceCarwashWithHeart;
    JTShop *shop = [model.datasource safetyObjectAtIndex:indexPath.section];
    NSArray * serviceArray = [self filterShopServiceByType:type andArray:shop.shopServiceArray];
    NSInteger serviceAmount = serviceArray.count;
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
        cell = [self tableView:tableView shopServiceCellAtIndexPath:indexPath andShopService:serviceArray];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKLoadingModel * model = [self modelForTableView:tableView];
    ShopServiceType type = model == self.carwashLoadingModel ? ShopServiceCarWash : ShopServiceCarwashWithHeart;
    JTShop *shop = [model.datasource safetyObjectAtIndex:indexPath.section];
    NSArray * serviceArray = [self filterShopServiceByType:type andArray:shop.shopServiceArray];
    NSInteger count = serviceArray.count + 2;
    if ([tableView isKindOfClass:[JTTableView class]])
    {
        JTTableView * jtTableView = (JTTableView *)tableView;
        [model loadMoreDataIfNeededWithIndexPath:indexPath nestItemCount:count promptView:jtTableView.bottomLoadingView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp102_3"];
    HKLoadingModel * model = [self modelForTableView:tableView];
    
    ShopDetailViewController *vc = [[ShopDetailViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.coupon = self.couponForWashDic;
    vc.shop = [model.datasource safetyObjectAtIndex:indexPath.section];
    vc.serviceType = self.serviceType;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Utility
- (UITableViewCell *)tableView:(UITableView *)tableView shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    
    HKLoadingModel * model = [self modelForTableView:tableView];
    JTShop *shop = [model.datasource safetyObjectAtIndex:indexPath.section];
    
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
    
    if (shop.ratenumber >= 10000)
    {
        commentNumL.text = [NSString stringWithFormat:@"%ld万", (long)(shop.ratenumber / 10000)];
    }
    else if (shop.ratenumber > 0)
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
            statusL.backgroundColor = kDefTintColor;
        }
        else {
            statusL.text = @"已休息";
            statusL.backgroundColor = HEXCOLOR(@"#cfdbd3");
        }
    }
    
    double myLat = self.userLocation.coordinate.latitude;
    double myLng = self.userLocation.coordinate.longitude;
    double shopLat = shop.shopLatitude;
    double shopLng = shop.shopLongitude;
    NSString * disStr = [DistanceCalcHelper getDistanceStrLatA:myLat lngA:myLng latB:shopLat lngB:shopLng];
    distantL.text = disStr;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopServiceCellAtIndexPath:(NSIndexPath *)indexPath andShopService:(NSArray *)serviceArray
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceCell" forIndexPath:indexPath];
    
    //row 1 洗车服务与价格
    UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
    UILabel *originalPriceLabel = (UILabel *)[cell.contentView viewWithTag:2004];
    
    JTShopService * service = [serviceArray safetyObjectAtIndex:indexPath.row - 1];
    
    washTypeL.text = service.serviceName;
    
    ChargeContent * cc = [service.chargeArray firstObjectByFilteringOperator:^BOOL(ChargeContent * tcc) {
        return tcc.paymentChannelType == PaymentChannelABCIntegral;
    }];
    
    NSAttributedString *originalPrice = [self priceStringWithOldPrice:@(service.oldOriginPrice) curPrice:nil];
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"原价" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    
    [titleString appendAttributedString:originalPrice];
    
    originalPriceLabel.hidden = service.oldOriginPrice <= service.origprice ? YES : NO;
    
    integralL.text = [NSString stringWithFormat:@"%.0f分",cc.amount];
    priceL.attributedText = [self priceStringWithOldPrice:nil curPrice:@(service.origprice)];
    originalPriceLabel.attributedText = titleString;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView shopNavigationCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"NavigationCell" forIndexPath:indexPath];
    
    HKLoadingModel * model = [self modelForTableView:tableView];
    JTShop *shop = [model.datasource safetyObjectAtIndex:indexPath.section];
    
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    
    @weakify(self)
    [[[guideB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        [MobClick event:@"rp102_4"];
        
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userLocation.coordinate andView:self.tabBarController.view];
    }];
    
    [[[phoneB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp102_5"];
        if (shop.shopPhone.length == 0)
        {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该店铺没有电话~" ActionItems:@[cancel]];
            [alert show];
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
                                NSForegroundColorAttributeName:kOrangeColor};
        NSString * p = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:[price2 floatValue]]];
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:p attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}

- (HKLoadingModel *)modelForTableView:(UITableView *)tableView
{
    HKLoadingModel * model;
    if (tableView == self.carwashTableView)
    {
        model = self.carwashLoadingModel;
    }
    else
    {
        model = self.withheartLoadingModel;
    }
    return model;
}


- (NSArray *)filterShopServiceByType:(ShopServiceType)type andArray:(NSArray * )array
{
    NSArray * serviceArray = [array arrayByFilteringOperator:^BOOL(JTShopService  * service) {
            
        return service.shopServiceType == type;
    }];
        
    return serviceArray;
}

@end
