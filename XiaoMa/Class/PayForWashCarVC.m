//
//  PayForWashCarVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PayForWashCarVC.h"
#import "XiaoMa.h"
#import <POP.h>
#import "UIView+Layer.h"
#import "NSDate+DateForText.h"
#import "UIView+Layer.h"
#import "UIView+Shake.h"
#import "CBAutoScrollLabel.h"
#import "NSString+Price.h"

#import "HKCoupon.h"
#import "HKMyCar.h"
#import "HKBankCard.h"
#import "MyCarStore.h"
#import "PaymentHelper.h"

#import "PaymentSuccessVC.h"
#import "ChooseCouponVC.h"
#import "ChooseBankCardVC.h"
#import "PickCarVC.h"
#import "EditCarVC.h"
#import "CarwashFreshmanGuideVC.h"

#import "GetUserCarOp.h"
#import "GetUserResourcesV2Op.h"
#import "SystemFastrateGetOp.h"
#import "CheckoutServiceOrderV4Op.h"
#import "OrderPaidSuccessOp.h"

#import "GainUserAwardOp.h"
#import "FMDeviceManager.h"

#import <NSObject+Notify.h>
#import "GetPayStatusOp.h"

#define CheckBoxCouponGroup @"CheckBoxCouponGroup"
#define CheckBoxPlatformGroup @"CheckBoxPlatformGroup"

@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *bottomScrollLb;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;

@property (nonatomic)BOOL isLoadingResourse;

@property (nonatomic,strong) MyCarStore *carStore;

@property (nonatomic,strong)CheckoutServiceOrderV4Op *checkoutServiceOrderV4Op;
@property (nonatomic,strong)GetUserResourcesV2Op * getUserResourcesV2Op;

///支付数据源
@property (nonatomic,strong)NSArray * paymentArray;

// 判断是否是通过支付app进入
@property (nonatomic,assign) BOOL isPaid;

@end

@implementation PayForWashCarVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"PayForWashCarVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBottomView];
    [self setupCarStore];
    
    self.selectCarwashCoupouArray = self.selectCarwashCoupouArray ? self.selectCarwashCoupouArray :[NSMutableArray array];
    self.selectCashCoupouArray = self.selectCashCoupouArray ? self.selectCashCoupouArray : [NSMutableArray array];
    ///一开始设置支付宝，保证可用资源获取失败的时候能够正常默认选择
    self.checkoutServiceOrderV4Op = [[CheckoutServiceOrderV4Op alloc] init];
    self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
    
    
    [self setupPaymentArray];
    [self requestGetUserResource:!self.isAutoCouponSelect];
    
    /// 是否自动选择指定的优惠劵。（场景：优惠劵-去使用进入本页面）
    if (!self.isAutoCouponSelect)
    {
        [self selectDefaultCoupon];
    }
    else
    {
        [self selectPayChannelIfAutoSelect];
    }
    
    self.isAutoCouponSelect = NO;
    
    [self setupNotification];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (self.needChooseResource)
    {
        [self requestGetUserResource:YES];
        self.needChooseResource = NO;
    }
}



#pragma mark - Setup

-(void)setupNotification
{
    @weakify(self)
    [self listenNotificationByName:NSStringFromClass([self class]) withNotifyBlock:^(NSNotification *note, id weakSelf) {
        if (!self.isPaid)
        {
            @strongify(self)
            [self checkPayment];
        }
    }];
}

- (void)setupPaymentArray
{
    
    if (self.getUserResourcesV2Op.rsp_czBankCreditCard.count)
    {
        if (gPhoneHelper.exsitWechat){
            self.paymentArray = @[@(PaymentChannelCZBCreditCard),@(PaymentChannelAlipay),@(PaymentChannelWechat)];
        }
        else{
            self.paymentArray = @[@(PaymentChannelCZBCreditCard),@(PaymentChannelAlipay)];
        }
    }
    else
    {
        if (gPhoneHelper.exsitWechat){
            self.paymentArray = @[@(PaymentChannelAlipay),@(PaymentChannelWechat),@(PaymentChannelCZBCreditCard)];
        }
        else{
            self.paymentArray = @[@(PaymentChannelAlipay),@(PaymentChannelCZBCreditCard),];
        }
    }
}



- (void)setupBottomView
{
    //label
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:1001];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"总计："
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr1];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%.2f", self.service.origprice]
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
    
    [self setupBottomLb];
}

- (void)setupBottomLb
{
    self.bottomScrollLb.textColor = [UIColor colorWithHex:@"#ff7428" alpha:1.0f];
    self.bottomScrollLb.textAlignment = NSTextAlignmentCenter;
    self.bottomScrollLb.font = [UIFont systemFontOfSize:12];
    self.bottomScrollLb.backgroundColor = [UIColor clearColor];
    self.bottomScrollLb.labelSpacing = 30;
    self.bottomScrollLb.scrollSpeed = 30;
    self.bottomScrollLb.fadeLength = 5.f;
    [self.bottomScrollLb observeApplicationNotifications];
    self.bottomScrollLb.text = @"0元洗车：支付成功后将获取x元加油代金券";
}


- (void)setupCarStore
{
    self.carStore = [MyCarStore fetchExistsStore];
    @weakify(self);
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {
        
        @strongify(self);
        [[evt signal] subscribeNext:^(id x) {
            @strongify(self);
            if (!self.defaultCar)
            {
                self.defaultCar = [self.carStore defalutInfoCompletelyCar];
            }
        }];
    }];
    [[self.carStore getAllCarsIfNeeded] send];
}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    [MobClick event:@"rp108-7"];
    if (!self.defaultCar) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        CKAfter(0.15    , ^{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell shake];
        });
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"前往添加" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提醒" ImageName:@"mins_bulb" Message:@"您尚未添加爱车，请先添加 " ActionItems:@[cancel,confirm]];
        [alert show];
        
        return;
    }
    
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#888888") clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
        [self requestCheckoutWithCouponType:self.couponType];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"支付确认" ImageName:@"mins_bulb" Message:@"请务必到店享受服务，且与店员确认服务商家与软件当前支付商家一致后再付款，付完不退款" ActionItems:@[cancel,confirm]];
    [alert show];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
            height = 70;
        else if (indexPath.row == 3)
            height = 32;
        else
            height = 24;
    }
    else
    {
        if (indexPath.row == 0)
            height = 40;
        else
            height = 50;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
        return  CGFLOAT_MIN;
    return 10;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    if (section == 0)
        count = 4;
    else if (section == 1)
        count = 3;
    else if (section == 2)
        count = self.paymentArray.count + 1;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            cell = [self shopTitleCellAtIndexPath:indexPath];
        else if (indexPath.row == 3)
            cell = [self carCellAtIndexPath:indexPath];
        else
            cell = [self shopItemCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0)
            cell = [self discountInfoCellAtIndexPath:indexPath];
        else
            cell = [self couponCellAtIndexPath:indexPath];
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0)
            cell = [self otherInfoCellAtIndexPath:indexPath];
        else
            cell = [self paymentPlatformACellAtIndexPath:indexPath];
    }
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
//    
//    if ((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0))
//    {
//        [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(-1, 0, 0, 0) forDirectionMask:CKViewBorderDirectionBottom] ;
//        [cell.contentView showBorderLineWithDirectionMask:CKViewBorderDirectionBottom];
//        [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:CKViewBorderDirectionBottom];
//    }
//    else
//    {
//        if (indexPath.section == 0)
//        {
//            if (indexPath.row != 3 || indexPath != 0)
//            {
//                return;
//            }
//        }
//        jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 8, 0, 8);
//        [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        if (indexPath.row == 3) {
            // 选择爱车
            [MobClick event:@"rp108_10"];
            PickCarVC *vc = [UIStoryboard vcWithId:@"PickCarVC" inStoryboard:@"Car"];
            vc.defaultCar = self.defaultCar;
            @weakify(self);
            [vc setFinishPickCar:^(MyCarListVModel *carModel, UIView * loadingView) {
                @strongify(self);
                self.defaultCar = carModel.selectedCar;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 1)
        {
            //点击查看洗车券
            [MobClick event:@"rp108_2"];
            ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
            vc.originVC = self.originVC;
            vc.type = CouponTypeCarWash;
            vc.selectedCouponArray = self.selectCarwashCoupouArray;
            vc.couponArray = self.getUserResourcesV2Op.validCarwashCouponArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp108_4"];
            ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
            vc.originVC = self.originVC;
            vc.type = CouponTypeCash;
            vc.selectedCouponArray = self.selectCashCoupouArray;
            vc.couponArray = self.getUserResourcesV2Op.validCashCouponArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
        ///取消支付宝，微信勾选
        [self.tableView reloadData];
    }
    else if (indexPath.section == 2) {
        
        PaymentChannelType payChannel = [[self.paymentArray safetyObjectAtIndex:indexPath.row - 1] integerValue];
        
        if (payChannel == PaymentChannelCZBCreditCard) {
            [MobClick event:@"rp108_12"];
            ChooseBankCardVC * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"ChooseBankCardVC"];
            vc.service = self.service;
            vc.shop = self.shop;
            vc.bankCards = self.getUserResourcesV2Op.rsp_czBankCreditCard;
            vc.carwashCouponArray = self.getUserResourcesV2Op.validCarwashCouponArray;
            vc.needRechooseCarwashCoupon = (!self.selectCarwashCoupouArray.count && !self.selectCashCoupouArray.count);
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            /// 如果是浙商，无法选择
            if (self.couponType == CouponTypeCZBankCarWash)
            {
                [gToast showText:@"您正在使用浙商优惠券，务必用浙商信用卡支付"];
                return;
            }
            
            self.checkoutServiceOrderV4Op.paychannel = payChannel;
            // 刷新支付平台section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)shopTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopTitleCell"];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    [logoV setImageByUrl:[self.shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    titleL.text = self.shop.shopName;
    addrL.text = self.shop.shopAddress;
    
    return cell;
}

- (UITableViewCell *)shopItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 1) {
        titleL.text = [NSString stringWithFormat:@"服务项目"];
        infoL.textColor = HEXCOLOR(@"#454545");
        infoL.text = self.service.serviceName;
    }
    else if (indexPath.row == 2) {
        titleL.text = [NSString stringWithFormat:@"项目价格"];
        infoL.textColor = HEXCOLOR(@"#ff7428");
        infoL.text = [NSString stringWithFormat:@"￥%.2f",self.service.origprice];
    }
    
    return cell;
}

- (UITableViewCell *)carCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CarCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];
    
    [[RACObserve(self, defaultCar) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(HKMyCar *car) {
        titleL.text = [NSString stringWithFormat:@"我的车辆"];
        infoL.textColor = HEXCOLOR(@"#454545");
        infoL.text = car.licencenumber ? car.licencenumber : @"";
    }];
    
    return cell;
}


- (UITableViewCell *)couponCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CouponCell"];
    
    UILabel *nameLb = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *couponLb = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:103];
    
    if (indexPath.row == 1) {
        nameLb.text = @"洗车券";

        if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
        {
            couponLb.hidden = NO;
            dateLb.hidden = NO;
            couponLb.text = [self calcCouponTitle:self.selectCarwashCoupouArray];
            dateLb.text = [self calcCouponValidDateString:self.selectCarwashCoupouArray];
        }
        else
        {
            couponLb.hidden = YES;
            dateLb.hidden = YES;
        }
    }
    else if (indexPath.row == 2) {
        nameLb.text = @"代金券";
        
        if (self.couponType == CouponTypeCash)
        {
            couponLb.hidden = NO;
            dateLb.hidden = NO;
            couponLb.text = [self calcCouponTitle:self.selectCashCoupouArray];
            dateLb.text = [self calcCouponValidDateString:self.selectCashCoupouArray];
        }
        else
        {
            couponLb.hidden = YES;
            dateLb.hidden = YES;
        }
    }
    
    return cell;
}

- (UITableViewCell *)paymentPlatformACellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIImageView *iconImgV,*tickImgV;
    UILabel *titleLb,*numberLb,*recommendLB;
    
    PaymentChannelType payChannel = [[self.paymentArray safetyObjectAtIndex:indexPath.row - 1] integerValue];
    if (payChannel == PaymentChannelCZBCreditCard)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PayPlatformCellB"];
        iconImgV = (UIImageView *)[cell searchViewWithTag:101];
        titleLb = (UILabel *)[cell searchViewWithTag:102];
        numberLb = (UILabel *)[cell searchViewWithTag:103];
        tickImgV = (UIImageView *)[cell searchViewWithTag:104];

        iconImgV.image = [UIImage imageNamed:@"cw_creditcard"];
        titleLb.text = @"信用卡支付";
        numberLb.text =  [NSString stringWithFormat:@"尾号:%@",[self.selectBankCard.cardNumber substringFromIndex:self.selectBankCard.cardNumber.length - 4]];
        numberLb.hidden = self.checkoutServiceOrderV4Op.paychannel != PaymentChannelCZBCreditCard;
        tickImgV.hidden = self.checkoutServiceOrderV4Op.paychannel != PaymentChannelCZBCreditCard;
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PayPlatformCell"];
        iconImgV = (UIImageView *)[cell searchViewWithTag:101];
        titleLb = (UILabel *)[cell searchViewWithTag:102];
        tickImgV = (UIImageView *)[cell searchViewWithTag:103];
        recommendLB = (UILabel *)[cell searchViewWithTag:104];
        recommendLB.cornerRadius = 3.0f;
        recommendLB.layer.masksToBounds = YES;
        
        if (payChannel == PaymentChannelAlipay) {
            iconImgV.image = [UIImage imageNamed:@"alipay_logo_66"];
            titleLb.text = @"支付宝支付";
            recommendLB.hidden = NO;
            tickImgV.hidden = self.checkoutServiceOrderV4Op.paychannel != PaymentChannelAlipay;
            if (self.couponType == CouponTypeCZBankCarWash)
            {
                titleLb.textColor = HEXCOLOR(@"#8888888");
            }
            else
            {
                titleLb.textColor = HEXCOLOR(@"#454545");
            }
        }
        else if (payChannel == PaymentChannelWechat) {
            iconImgV.image = [UIImage imageNamed:@"wechat_logo_66"];
            titleLb.text = @"微信支付";
            recommendLB.hidden = YES;
            tickImgV.hidden = self.checkoutServiceOrderV4Op.paychannel != PaymentChannelWechat;
            if (self.couponType == CouponTypeCZBankCarWash)
            {
                titleLb.textColor = HEXCOLOR(@"#8888888");
            }
            else
            {
                titleLb.textColor = HEXCOLOR(@"#454545");
            }
        }
    }

    return cell;
}



- (UITableViewCell *)discountInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DiscountInfoCell"];
    UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:202];
    
    [[RACObserve(self, isLoadingResourse) distinctUntilChanged] subscribeNext:^(NSNumber * number) {
        
        BOOL isloading = [number boolValue];
        indicator.animating = isloading;
        indicator.hidden = !isloading;
    }];
    return cell;
}

- (UITableViewCell *)otherInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - 网络请求及处理
- (void)requestGetUserResource:(BOOL)needAutoSelect
{
    CouponModel * couponModel = [[CouponModel alloc] init];
    [[[couponModel rac_getVaildResource:self.service.shopServiceType andShopId:self.shop.shopID] initially:^{
        
        self.isLoadingResourse = YES;
    }] subscribeNext:^(GetUserResourcesV2Op * op) {
        
        self.isLoadingResourse = NO;
        self.getUserResourcesV2Op = op;
        
        [self actionAfterGetUserResource:needAutoSelect];
       
        [self alertFreshmanGuide];
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
    }];
}


- (void)requestCheckoutWithCouponType:(CouponType)couponType
{
    NSMutableArray *coupons;
    HKBankCard * bandCard = [self.selectBankCard copy];
    if (couponType == CouponTypeCZBankCarWash || couponType == CouponTypeCarWash)
    {
        coupons = [NSMutableArray array];
        for (HKCoupon * c in self.selectCarwashCoupouArray) {
            [coupons addObject:c.couponId];
        }
    }
    else if (couponType == CouponTypeCash) {
        coupons = [NSMutableArray array];
        for (HKCoupon * c in self.selectCashCoupouArray) {
            [coupons addObject:c.couponId];
        }
    }
    self.checkoutServiceOrderV4Op.couponArray = coupons;
    self.checkoutServiceOrderV4Op.serviceid = self.service.serviceID;
    self.checkoutServiceOrderV4Op.licencenumber = self.defaultCar.licencenumber ? self.defaultCar.licencenumber : @"";
    self.checkoutServiceOrderV4Op.carMake = self.defaultCar.brand;
    self.checkoutServiceOrderV4Op.carModel = self.defaultCar.seriesModel.seriesname;
    self.checkoutServiceOrderV4Op.bankCardId = bandCard.cardID;
    
    FMDeviceManager_t *manager = [FMDeviceManager sharedManager];
    NSString *blackBox = manager->getDeviceInfo();
    self.checkoutServiceOrderV4Op.blackbox = blackBox;
    
    //如果不是原价支付，需要提供定位信息
    RACSignal *signal;
    if (couponType != CouponTypeNone) {
        signal = [[gMapHelper rac_getUserLocation] catch:^RACSignal *(NSError *error) {
            return [RACSignal return:nil];
        }];
    }
    else {
        signal = [RACSignal return:nil];
    }
    
    
    [[[signal flattenMap:^RACStream *(MAUserLocation *location) {
        
        self.checkoutServiceOrderV4Op.coordinate = location ? location.coordinate : gMapHelper.coordinate;
        return [self.checkoutServiceOrderV4Op rac_postRequest];
    }] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(CheckoutServiceOrderV4Op * op) {
        
        [self requestCommentlist];
        [self paySuccess:op];
        // 在这里获取交易号
        self.tradeno = op.rsp_tradeId;
    } error:^(NSError *error) {
        
        [self handerOrderError:error forOp:self.checkoutServiceOrderV4Op];
    }];
}

- (void)paySuccess:(CheckoutServiceOrderV4Op *)op
{
    if (op.rsp_price)
    {
        if (op.paychannel == PaymentChannelAlipay)
        {
            [gToast showText:@"订单生成成功,正在跳转到支付宝平台进行支付"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString * submitTime = [[NSDate date] dateFormatForDT8];
                NSString * info = [NSString stringWithFormat:@"%@-%@",self.service.serviceName,self.shop.shopName];
                [self requestAliPay:op.rsp_orderid andTradeId:op.rsp_tradeId andPrice:op.rsp_price
                     andProductName:info andDescription:info andTime:submitTime andGasCouponAmout:op.rsp_gasCouponAmount];
            });
        }
        else if (op.paychannel == PaymentChannelWechat)
        {
            [gToast showText:@"订单生成成功,正在跳转到微信平台进行支付"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                NSString * submitTime = [[NSDate date] dateFormatForDT8];
                NSString * info = [NSString stringWithFormat:@"%@-%@",self.service.serviceName,self.shop.shopName];
                [self requestWechatPay:op.rsp_orderid andTradeId:op.rsp_tradeId andPrice:op.rsp_price
                        andProductName:info andTime:submitTime andGasCouponAmout:op.rsp_gasCouponAmount];
            });
        }
        else {
            [gToast dismiss];
            [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
            PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            HKServiceOrder * order = [[HKServiceOrder alloc] init];
            order.orderid = op.rsp_orderid;
            order.shop = self.shop;
            order.serviceid = self.service.serviceID;
            order.servicename = self.service.serviceName;
            order.fee = op.rsp_price;
            order.gasCouponAmount =  op.rsp_gasCouponAmount;
            vc.order = order;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else
    {
        [gToast dismiss];
        [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        HKServiceOrder * order = [[HKServiceOrder alloc] init];
        order.orderid = op.rsp_orderid;
        order.shop = self.shop;
        order.serviceid = self.service.serviceID;
        order.servicename = self.service.serviceName;
        order.fee = op.rsp_price;
        order.gasCouponAmount = op.rsp_gasCouponAmount;
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (void)requestCommentlist
{
    if (gAppMgr.commentList.count)
        return;
    SystemFastrateGetOp * op = [SystemFastrateGetOp operation];
    [[op rac_postRequest] subscribeNext:^(SystemFastrateGetOp * op) {
        
        gAppMgr.commentList = op.rsp_commentlist;
    }];
}



- (void)requestGainWeeklyCoupon
{
    GainUserAwardOp * op = [GainUserAwardOp operation];
    op.req_province = gMapHelper.addrComponent.province;
    op.req_city = gMapHelper.addrComponent.city;
    op.req_district = gMapHelper.addrComponent.district;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"优惠劵获取中..."];
    }] subscribeNext:^(GainUserAwardOp * op) {
        
        [gToast dismiss];
        HKCoupon * coupon = [[HKCoupon alloc] init];
        coupon.couponId = op.rsp_couponId;
        
        [self.selectCarwashCoupouArray removeAllObjects];
        [self.selectCashCoupouArray removeAllObjects];
        
        [self.selectCashCoupouArray safetyAddObject:coupon];
        
        [self requestGetUserResource:NO];
    } error:^(NSError *error) {
        
        [gToast dismiss];
        if (error.code == 6153)
        {
            ///用户已领取
            return ;
        }
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"算了" color:HEXCOLOR(@"#888888") clickBlock:nil];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"再试一次" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [self requestGainWeeklyCoupon];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:error.domain ActionItems:@[cancel,confirm]];
        [alert show];

    }];
}

#pragma mark - 调用第三方支付
- (void)requestAliPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
             andPrice:(CGFloat)price andProductName:(NSString *)name andDescription:(NSString *)desc andTime:(NSString *)time andGasCouponAmout:(CGFloat)couponAmt

{
    self.isPaid = YES;
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    
    [helper resetForAlipayWithTradeNumber:tradeId productName:name productDescription:desc price:price];
    
    [[helper rac_startPay] subscribeNext:^(id x) {
        
        [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
        
        OrderPaidSuccessOp *iop = [[OrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 2;
        iop.req_tradeno = tradeId;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"洗车已通知服务器支付成功!");
        }];
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        vc.subtitle = [NSString stringWithFormat:@"我完成了%0.2f元洗车，赶快去告诉好友吧！",price];
        HKServiceOrder * order = [[HKServiceOrder alloc] init];
        order.orderid = orderId;
        order.serviceid = self.service.serviceID;
        order.servicename = self.service.serviceName;
        order.fee = price;
        order.shop = self.shop;
        order.gasCouponAmount = couponAmt;
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
    }];
}

- (void)requestWechatPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
                andPrice:(CGFloat)price andProductName:(NSString *)name
                 andTime:(NSString *)time andGasCouponAmout:(CGFloat)couponAmt
{
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    
    [helper resetForWeChatWithTradeNumber:tradeId productName:name price:price];
    [[helper rac_startPay] subscribeNext:^(NSString * info) {
        
        [self postCustomNotificationName:kNotifyRefreshMyCarwashOrders object:nil];
        
        OrderPaidSuccessOp *iop = [[OrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 2;
        iop.req_tradeno = tradeId;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"洗车已通知服务器支付成功!");
        }];
        // 支付成功。避免应用进入前台后重复请求
        self.isPaid = YES;
        PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
        vc.originVC = self.originVC;
        vc.subtitle = [NSString stringWithFormat:@"我完成了%0.2f元洗车，赶快去告诉好友吧！",price];
        HKServiceOrder * order = [[HKServiceOrder alloc] init];
        order.orderid = orderId;
        order.serviceid = self.service.serviceID;
        order.servicename = self.service.serviceName;
        order.shop = self.shop;
        order.fee = price;
        order.gasCouponAmount = couponAmt;
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        
    }];
}


#pragma mark - Utility
- (void)selectDefaultCoupon
{
    [self.selectCarwashCoupouArray removeAllObjects];
    [self.selectCashCoupouArray removeAllObjects];
    self.couponType = CouponTypeNone;
    if (self.getUserResourcesV2Op.validCarwashCouponArray.count)
    {
        HKCoupon * coupon = [self.getUserResourcesV2Op.validCarwashCouponArray safetyObjectAtIndex:0];
        if (coupon.conponType == CouponTypeCZBankCarWash){
            
            self.couponType = CouponTypeCZBankCarWash;
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
        }
        else{
            
            self.couponType = CouponTypeCarWash;
        }
        [self.selectCarwashCoupouArray addObject:coupon];
        
        if (self.getUserResourcesV2Op.rsp_czBankCreditCard.count){
            
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
        }
        else{
            
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
        }
        
        [self.tableView reloadData];
        [self refreshPriceLb];
        return;
    }
    if (self.getUserResourcesV2Op.validCashCouponArray.count)
    {
        CGFloat amount = 0;
        for (NSInteger i = 0 ; i < self.getUserResourcesV2Op.validCashCouponArray.count ; i++)
        {
            HKCoupon * coupon = [self.getUserResourcesV2Op.validCashCouponArray safetyObjectAtIndex:i];
            amount = amount + coupon.couponAmount;
            [self.selectCashCoupouArray addObject:coupon];
            if (amount >= self.service.origprice)
                break;
        }
        self.couponType = CouponTypeCash;
        [self.tableView reloadData];
        [self refreshPriceLb];
        return;
    }
    self.couponType = 0;
    [self tableViewReloadData];
}

- (void)selectPayChannelIfAutoSelect
{
    if (self.selectCarwashCoupouArray.count)
    {
        HKCoupon * coupon = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
        self.couponType = coupon.conponType;
        if (self.getUserResourcesV2Op.rsp_czBankCreditCard.count){
            
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
        }
        else{
            
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
        }
        [self.tableView reloadData];
        [self refreshPriceLb];
    }
    else if (self.selectCashCoupouArray.count)
    {
        HKCoupon * coupon = [self.selectCashCoupouArray safetyObjectAtIndex:0];
        self.couponType = coupon.conponType;
        if (coupon.couponAmount >= self.service.origprice)
        {
            [self.selectCashCoupouArray removeAllObjects];
            [self selectDefaultCoupon];
        }
        else
        {
            if (self.getUserResourcesV2Op.rsp_czBankCreditCard.count){
                
                self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
            }
            else{
                
                self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
            }
            [self tableViewReloadData];
            return;
        }
    }
}


- (void)autoSelectBankCard
{
    self.selectBankCard = nil;
    if (self.couponType == CouponTypeCZBankCarWash)
    {
        // 选中的是浙商券，判断浙商劵是否属于我的浙商卡集下
        HKCoupon * coupon = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
        for (HKBankCard * card in self.getUserResourcesV2Op.rsp_czBankCreditCard)
        {
            for (NSNumber * cid in card.couponIds)
            {
                if ([coupon.couponId isEqualToNumber:cid])
                {
                    self.selectBankCard = card;
                    return;
                }
            }
        }
    }
    else
    {
        // 判断是否有浙商卡，有的话，优先浙商卡支付
        if (self.getUserResourcesV2Op.rsp_czBankCreditCard.count)
        {
            HKBankCard * card = [self.getUserResourcesV2Op.rsp_czBankCreditCard safetyObjectAtIndex:0];
            self.selectBankCard = card;
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
        }
        else
        {
            self.selectBankCard = nil;
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
        }
    }
}

- (HKCoupon *)isContainCoupon:(HKCoupon *)c
{
    HKCoupon * coupon = [self.getUserResourcesV2Op.validCarwashCouponArray firstObjectByFilteringOperator:^BOOL(HKCoupon * obj) {
        return [c.couponId isEqualToNumber:obj.couponId];
    }];
    if (!coupon)
    {
        coupon = [self.getUserResourcesV2Op.validCashCouponArray firstObjectByFilteringOperator:^BOOL(HKCoupon * obj) {
            return [c.couponId isEqualToNumber:obj.couponId];
        }];
    }
    return coupon;
}


- (void)refreshPriceLb
{
    CGFloat serviceAmount = self.service.origprice;
    CGFloat discount = 0.0;
    CGFloat paymoney = serviceAmount;
    
    
    if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
    {
        HKCoupon * coupon = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
        paymoney = coupon.couponAmount;
        discount = serviceAmount - paymoney;
    }
    else if (self.couponType == CouponTypeCash)
    {
        for (NSInteger i = 0 ; i < self.selectCashCoupouArray.count ; i++)
        {
            HKCoupon * coupon = [self.selectCashCoupouArray safetyObjectAtIndex:i];
            discount = discount + coupon.couponAmount;
        }
        paymoney = serviceAmount - discount;
        
        paymoney = paymoney > 0 ? paymoney : 0.01f;
    }

    NSString * btnText = [NSString stringWithFormat:@"您%@需支付%.2f元，现在支付",
                          paymoney != serviceAmount ? @"只" : @"",
                          paymoney];
    [self.payBtn setTitle:btnText forState:UIControlStateNormal];
    
    CGFloat maxAmt = self.getUserResourcesV2Op.rsp_maxGasCouponAmt ? self.getUserResourcesV2Op.rsp_maxGasCouponAmt : 10.0f;
    CGFloat gainCouponAmt = MIN(MAX(paymoney, 1.0f), maxAmt);
    
    NSString * lbText = [NSString stringWithFormat:@"0元洗车:支付成功后将获取%@元加油代金券",[NSString formatForPrice:gainCouponAmt]];
    self.bottomScrollLb.text = lbText;
    
    /// 如果是活动日 || 新手
    if ((!self.getUserResourcesV2Op.rsp_carwashFlag || self.getUserResourcesV2Op.rsp_neverCarwashFlag)
        && paymoney >= 0 && self.service.shopServiceType == ShopServiceCarWash)
    {
        self.bottomScrollLb.hidden = NO;
        self.bottomViewHeightConstraint.constant = 84;
    }
    else
    {
        self.bottomScrollLb.hidden = YES;
        self.bottomViewHeightConstraint.constant = 62;
    }
}



- (void)tableViewReloadData
{
    [self.tableView reloadData];
    [self refreshPriceLb];
}

- (void)chooseResource
{
    [self selectDefaultCoupon];
    [self autoSelectBankCard];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}

/// 新手提示
- (void)alertFreshmanGuide
{
    // 新手 && 没领过周周礼券的
    if (self.getUserResourcesV2Op.rsp_neverCarwashFlag && !self.getUserResourcesV2Op.rsp_weeklyCouponGetFlag && self.service.shopServiceType == ShopServiceCarWash)
    {
        CarwashFreshmanGuideVC * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"CarwashFreshmanGuideVC"];
        CGFloat width = 265 * gAppMgr.deviceInfo.screenSize.width / 320;
        CGFloat height = 350 * gAppMgr.deviceInfo.screenSize.height / 568;
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(width, height) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.gainWeeklyCouponBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [MobClick event:@"rp108_13"];
            [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
                [self requestGainWeeklyCoupon];
            }];
            
        }];
        
        [[vc.whateverBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [MobClick event:@"rp108_14"];
            [sheet dismissAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
            }];
        }];
    }
}

- (void)actionAfterGetUserResource:(BOOL)needAutoSelect
{
    if (needAutoSelect)
    {
        [self selectDefaultCoupon];
    }
    else
    {
        //不需要自动选择（去使用进来），先检查一下是否在可用资源里面
        HKCoupon * c = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
        if (!c){
            
            c = [self.selectCashCoupouArray safetyObjectAtIndex:0];
        }
        // 可用资源是否包含去使用的券
        HKCoupon * isContain = [self isContainCoupon:c];
        self.couponType = isContain.conponType;
        if (!isContain)
        {
            [self selectDefaultCoupon];
        }
        else
        {
            [self replaceCoupon:isContain];
        }
    }
    [self autoSelectBankCard];
    [self setupPaymentArray];
    [self refreshPriceLb];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)handerOrderError:(NSError *)error forOp:(CheckoutServiceOrderV4Op *)op
{
    if (error.code == 615801) {
        [gToast dismiss];
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃支付" color:HEXCOLOR(@"#888888") clickBlock:^(id alertVC) {
            [MobClick event:@"rp108_8"];
        }];
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"原价支付" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
            [MobClick event:@"rp108_9"];
            [self requestCheckoutWithCouponType:CouponTypeNone];
        }];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您不在该商户服务范围内，请刷新或者到店后洗完车后再支付或者原价支付。" ActionItems:@[cancel,confirm]];
        [alert show];
        
    }
    else if (error.code == 5003 || error.code == 615805)
    {
        [self requestGetUserResource:YES];
        [gToast showError:error.domain];
    }
    else {
        [gToast showError:error.domain];
    }
}

/// 把优惠劵替换到selectArray，新手引导领取周周礼券coupon只有一个id，所以要替换一下
- (void)replaceCoupon:(HKCoupon *)coupon
{
    for (NSInteger index = 0 ; index < self.selectCarwashCoupouArray.count ; index++)
    {
        HKCoupon * c = [self.selectCarwashCoupouArray safetyObjectAtIndex:index];
        if ([c.couponId isEqualToNumber:coupon.couponId])
        {
            [self.selectCarwashCoupouArray safetyReplaceObjectAtIndex:index withObject:coupon];
            return;
        }
    }
    for (NSInteger index = 0 ; index < self.selectCashCoupouArray.count ; index++)
    {
        HKCoupon * c = [self.selectCashCoupouArray safetyObjectAtIndex:index];
        if ([c.couponId isEqualToNumber:coupon.couponId])
        {
            [self.selectCashCoupouArray safetyReplaceObjectAtIndex:index withObject:coupon];
            return;
        }
    }
}

- (void)setPaymentChannel:(PaymentChannelType)channel
{
    self.checkoutServiceOrderV4Op.paychannel = channel;
}
///获取优惠劵title（12元代金劵）
- (NSString *)calcCouponTitle:(NSArray *)couponArray
{
    if (couponArray.count == 0)
    {
        return @"";
    }
    else if (couponArray.count == 1)
    {
        HKCoupon * coupon = [couponArray safetyObjectAtIndex:0];
        return coupon.couponName;
    }
    else
    {
        CGFloat totalAmount = 0.0;
        for (HKCoupon * c in couponArray)
        {
            totalAmount = totalAmount + c.couponAmount;
        }
        NSString * string;
        if (totalAmount >= self.service.origprice)
        {
            string =  [NSString stringWithFormat:@"最高可使用%@元代金券",[NSString formatForPrice:totalAmount]];
        }
        else
        {
            totalAmount = self.service.origprice - 0.01;
            string =  [NSString stringWithFormat:@"%@元代金劵",[NSString formatForPrice:totalAmount]];
        }
        
        return string;
    }
}


///获取优惠劵的两头时间
- (NSString *)calcCouponValidDateString:(NSArray *)couponArray
{
    NSDate * earlierDate;
    NSDate * laterDate;
    for (HKCoupon * c in couponArray)
    {
        earlierDate = [c.validsince earlierDate:earlierDate];
        laterDate = [c.validthrough laterDate:laterDate];
    }
    NSString * string = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
    
    return string;
}

-(void)checkPayment
{
    @weakify(self)
    GetPayStatusOp *op = [[GetPayStatusOp alloc]init];
    if (self.tradeno.length != 0)
    {
        op.req_tradeno = self.tradeno;
        op.req_tradetype = @"2";
        
        [[[op rac_postRequest]initially:^{
            [gToast showingWithText:@"订单信息查询中"];
        }]subscribeNext:^(id x) {
            [gToast dismiss];
            @strongify(self)
            if (op.rsp_status)
            {
                PaymentSuccessVC *vc = [UIStoryboard vcWithId:@"PaymentSuccessVC" inStoryboard:@"Carwash"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }error:^(NSError *error) {
            [gToast showText:error.domain];
        }];
    }
}

@end
