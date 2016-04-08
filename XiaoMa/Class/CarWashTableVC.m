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
#import "UIView+DefaultEmptyView.h"
#import "NSDate+DateForText.h"
#import "ADViewController.h"

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAdList) name:CarwashAdvertiseNotification object:nil];
    
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
                                        targetVC:self mobBaseEvent:@"rp102_6"];
    self.adctrl2 = [ADViewController vcWithADType:AdvertisementCarWash boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp102_6"];
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
            
        }
    }];
    
    [self.segHelper addItem:self.withheartBtn forGroupName:@"CarwashTabBar" withChangedBlock:^(id item, BOOL selected) {
        @strongify(self);
        UIButton * btn = item;
        btn.selected = selected;
        self.line2.hidden = !selected;
        self.withheartTableView.hidden = !selected;
        if (selected) {
            
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
                
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [alertVC dismiss];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_error" Message:@"城市定位失败,请重试" ActionItems:@[cancel]];
                [alert show];
                
            }
            default:
            {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [alertVC dismiss];
                }];
                HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_error" Message:@"定位失败，请重试" ActionItems:@[cancel]];
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
        signal = [gMapHelper rac_getUserLocation];
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
    ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
    vc.couponFordetailsDic = self.couponForWashDic;
    vc.hidesBottomBarWhenPushed = YES;
    vc.shop = [model.datasource safetyObjectAtIndex:indexPath.section];
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
    
    JTShopService * service = [serviceArray safetyObjectAtIndex:indexPath.row - 1];
    
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
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:HEXCOLOR(@"#18d06a") clickBlock:^(id alertVC) {
                [alertVC dismiss];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_error" Message:@"该店铺没有电话~" ActionItems:@[cancel]];
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
                                NSForegroundColorAttributeName:HEXCOLOR(@"#ff7428")};
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
