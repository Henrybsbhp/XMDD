//
//  PayForGasViewController.m
//  XiaoMa
//
//  Created by jt on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "PayForGasViewController.h"
#import "UIView+Layer.h"
#import "GasPaymentResultVC.h"
#import "HKTableViewCell.h"
#import "ChooseCarwashTicketVC.h"
#import "GetUserResourcesGaschargeOp.h"

@interface PayForGasViewController ()

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// 是否正在获取可用资源
@property (nonatomic)BOOL isLoadingResourse;

@property (nonatomic,strong)NSArray * datasource;
///支付数据源
@property (nonatomic,strong)NSArray * paymentArray;
/// 加油优惠券
@property (nonatomic,strong)NSArray * gasCoupon;
///支付渠道
@property (nonatomic)PaymentChannelType  paychannel;

@end

@implementation PayForGasViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"PayForGasViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupUI];
    
    [self setupData];
    [self setupDatasource];
    [self refreshBottomView];
    
    [self requestGetGasResource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp508"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp508"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup
- (void)setupNavigationBar
{
    self.navigationItem.title = @"支付确认";
    
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupUI
{
    self.payTitle = @"油卡充值";
    self.paySubTitle = @"普通充值";
    [[self.payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        /**
         *  支付确定点击事件
         */
        [MobClick event:@"rp508-6"];
        [self actionPay:nil];
    }];
}

- (void)setupData
{
    self.paychannel = PaymentChannelAlipay;
    self.selectGasCoupouArray = [NSMutableArray array];
}

- (void)setupDatasource
{
    NSDictionary * dict0_0 = @{@"cellname":@"PayTitleCell"};
    
    NSDictionary * dict0_1 = @{@"title":@"充值卡号",@"value":self.model.curGasCard.gascardno,
                               @"cellname":@"InfoItemCell"};
    
    
    NSDictionary * dict0_2 = @{@"title":@"充值金额",@"value":[NSString stringWithFormat:@"￥ %@",@(self.model.rechargeAmount)],
                               @"cellname":@"InfoItemCell"};
    
    if (!self.gasCoupon)
    {
        self.gasCoupon = [NSArray array];
    }
    
    NSDictionary * dict1_0 = @{@"cellname":@"CouponHeadCell"};
    
    NSDictionary * dict1_1 = @{@"title":@"加油优惠劵",
                               @"value":@(self.rechargeAmount),
                               @"array":self.gasCoupon,
                               @"isSelect":@(self.couponType),
                               @"cellname":@"CouponCell"};
    
    NSDictionary * dict2_0 = @{@"cellname":@"PaymentPlatformHeadCell"};
    
    NSDictionary * dict2_1 = @{@"title":@"支付宝支付",@"subtitle":@"推荐支付宝用户使用",
                               @"payment":@(PaymentChannelAlipay),@"recommend":@(YES),
                               @"cellname":@"PaymentPlatformCell",@"icon":@"cw_alipay"};
    
    NSDictionary * dict2_2 = @{@"title":@"微信支付",@"subtitle":@"推荐微信用户使用",
                               @"payment":@(PaymentChannelWechat),@"recommend":@(NO),
                               @"cellname":@"PaymentPlatformCell",@"icon":@"cw_wechat"};
    
    NSDictionary * dict2_3 = @{@"title":@"银联支付",@"subtitle":@"推荐银联用户使用",
                               @"payment":@(PaymentChannelUPpay),@"recommend":@(NO),
                               @"cellname":@"PaymentPlatformCell",@"icon":@"pm_uppay"};
    
    self.paymentArray = gPhoneHelper.exsitWechat ? @[dict2_1,dict2_2,dict2_3] : @[dict2_1,dict2_3];
    NSMutableArray * tArray = [NSMutableArray arrayWithObject:dict2_0];
    [tArray addObjectsFromArray:self.paymentArray];
    self.datasource = @[@[dict0_0,dict0_1,dict0_2],@[dict1_0,dict1_1],tArray];
}


#pragma mark - Utilitly
- (void)requestGetGasResource
{
    GetUserResourcesGaschargeOp * op = [GetUserResourcesGaschargeOp operation];
    
    [[[op rac_postRequest] initially:^{
        
        self.isLoadingResourse = YES;
    }] subscribeNext:^(GetUserResourcesGaschargeOp * op) {
        
        self.isLoadingResourse = NO;
        self.gasCoupon = op.rsp_couponArray;
        
        [self setupDatasource];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
    }];
}


- (void)refreshBottomView
{
    HKCoupon * coupon = [self.selectGasCoupouArray safetyObjectAtIndex:0];
    
    NSString *title;
    NSInteger couponlimit, discount = 0;
    NSUInteger rechargeAmount = self.model.rechargeAmount;
    CGFloat systemPercent = 0;
    NSInteger paymoney = rechargeAmount;
    
    couponlimit = self.model.configOp ? self.model.configOp.rsp_couponupplimit : 1000;
    systemPercent = self.model.configOp ? self.model.configOp.rsp_discountrate : 2;
    
    /// 系统额度
    if (self.model.curGasCard)
    {
        discount = MIN([self.model.curGasCard.couponedmoney integerValue], rechargeAmount * systemPercent / 100.0);
    }
    else
    {
        discount = MIN(couponlimit, rechargeAmount) * systemPercent / 100.0;
    }
    
    if (self.couponType == CouponTypeGasNormal ||
        self.couponType == CouponTypeGasReduceWithThreshold ||
        self.couponType == CouponTypeGasDiscount)
    {
        if (coupon.couponPercent < 100)
        {
            // 优惠劵有折扣优惠，直接乘
            discount = rechargeAmount - rechargeAmount * coupon.couponPercent / 100;
        }
        else
        {
            /// 选择了优惠券，优惠劵没折扣优惠  = 原先系统额度 + 优惠劵面额 （ps：优惠劵打折力度和优惠劵面额一般只存在一个）
            discount = discount + coupon.couponAmount;
        }
    }
    
    paymoney = paymoney - discount;
    
    if (discount > 0) {
        title = [NSString stringWithFormat:@"已优惠%ld元，您只需支付%ld元，现在支付", (long)discount, (long)paymoney];
    }
    else {
        title = [NSString stringWithFormat:@"您需支付%ld元，现在支付", (long)paymoney];
    }
    
    [self.payBtn setTitle:title forState:UIControlStateNormal];
    [self.payBtn setTitle:title forState:UIControlStateDisabled];
}

- (void)jumpToChooseCouponVC
{
    ChooseCarwashTicketVC *vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"ChooseCarwashTicketVC"];
    vc.originVC = self;
    vc.type = CouponTypeGasNormal; /// 加油券类型的用普通代替
    vc.selectedCouponArray = self.selectGasCoupouArray;
    vc.couponArray = self.gasCoupon;
    vc.payAmount = (CGFloat)self.model.rechargeAmount;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    if (self.couponType == CouponTypeGasNormal ||
        self.couponType == CouponTypeGasReduceWithThreshold ||
        self.couponType == CouponTypeGasDiscount)
    {
        self.model.coupon = [self.selectGasCoupouArray safetyObjectAtIndex:0];
    }
    else
    {
        self.model.coupon = nil;
    }
    
    self.model.paymentPlatform = self.paychannel;
    @weakify(self)
    [self.model startPayInTargetVC:self completed:^(GasCard *card, GascardChargeOp *paidop) {
        
        @strongify(self);
        GasPaymentResultVC *vc = [UIStoryboard vcWithId:@"GasPaymentResultVC" inStoryboard:@"Gas"];
        vc.originVC = self.originVC;
        vc.drawingStatus = DrawingBoardViewStatusSuccess;
        vc.gasCard = card;
        vc.paidMoney = paidop.rsp_total;
        vc.couponMoney = paidop.rsp_couponmoney;
        vc.chargeMoney = paidop.req_amount;
        [vc setDismissBlock:^(DrawingBoardViewStatus status) {
            @strongify(self);
            //更新信息，充值默认500
            self.model.rechargeAmount = 500;
            [self.model.cardStore sendEvent:[self.model.cardStore updateCardInfoByGID:card.gid]];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - Network


#pragma mark - Tableview data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = [[self.datasource safetyObjectAtIndex:section] count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    
    NSDictionary * dict = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSString * cellName = dict[@"cellname"];

    if ([cellName isEqualToString:@"PayTitleCell"])
    {
        height = 64;
    }
    else if ([cellName isEqualToString:@"InfoItemCell"])
    {
        height = 26;
        if (indexPath.row == 2)
        {
            height = 30;
        }
    }
    else if ([cellName isEqualToString:@"CouponHeadCell"])
    {
        height = 30;
    }
    else if ([cellName isEqualToString:@"CouponCell"])
    {
        height = 50;
    }
    else if ([cellName isEqualToString:@"PaymentPlatformHeadCell"])
    {
        height = 30;
    }
    else if ([cellName isEqualToString:@"PaymentPlatformCell"])
    {
        height = 50;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  CGFLOAT_MIN;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSDictionary * dict = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSString * cellName = dict[@"cellname"];
    
    if ([cellName isEqualToString:@"PayTitleCell"])
    {
        cell = [self payTitleCellAtIndexPath:indexPath];
    }
    else if ([cellName isEqualToString:@"InfoItemCell"])
    {
        cell = [self infoItemCellAtIndexPath:indexPath];
    }
    else if ([cellName isEqualToString:@"CouponHeadCell"])
    {
        cell = [self couponHeadCellAtIndexPath:indexPath];
    }
    else if ([cellName isEqualToString:@"CouponCell"])
    {
        cell = [self couponInfoCellAtIndexPath:indexPath];
    }
    else if ([cellName isEqualToString:@"PaymentPlatformHeadCell"])
    {
        cell = [self paymentPlatformHeadCellAtIndexPath:indexPath];
    }
    else if ([cellName isEqualToString:@"PaymentPlatformCell"])
    {
        cell = [self paymentPlatformCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSString * cellName = dict[@"cellname"];
    if ([cellName isEqualToString:@"CouponCell"])
    {
        [MobClick event:@"rp508-2"];
        [self jumpToChooseCouponVC];
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)payTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PayTitleCell"];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UIView * logoBg = (UIView *)[cell searchViewWithTag:101];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
//    [logoV makeCornerRadius:5.0f];
    
    logoBg.borderWidth = 0.5f;
    logoBg.borderColor = [UIColor lightGrayColor];
    [logoBg makeCornerRadius:5.0f];
    
    titleL.text = self.payTitle;
    addrL.text = self.paySubTitle;
    logoV.image = [UIImage imageNamed:self.model.curGasCard.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];

    return cell;
}

- (UITableViewCell *)infoItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];

    NSArray * array = [self.datasource safetyObjectAtIndex:indexPath.section];
    NSDictionary * dict = [array safetyObjectAtIndex:indexPath.row];
    titleL.text =  dict[@"title"];
    infoL.text = dict[@"value"];
    
    if (indexPath.row == array.count - 1)
    {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
        infoL.textColor = [UIColor colorWithHex:@"#ff5a00" alpha:1.0f];
    }
    else
    {
        infoL.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
    }
    
    return cell;
}

- (UITableViewCell *)couponHeadCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CouponHeadCell"];
    UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:202];
    
    [[RACObserve(self, isLoadingResourse) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
        
        indicator.animating = [num integerValue];
        indicator.hidden = ![num integerValue];
    }];
    

    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];

    
    return cell;
}

- (UITableViewCell *)couponInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CouponInfoCell"];
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *statusLb = (UILabel *)[cell.contentView viewWithTag:1005];
    
    NSArray * array = [self.datasource safetyObjectAtIndex:indexPath.section];
    NSDictionary * dict = [array safetyObjectAtIndex:indexPath.row];
    NSArray * gasCoupon = dict[@"array"];
    
    label.text = [NSString stringWithFormat:@"加油优惠劵：%ld张", (long)gasCoupon.count];
    arrow.hidden = NO;
    
    NSDate * earlierDate;
    NSDate * laterDate;
    for (HKCoupon * c in gasCoupon)
    {
        earlierDate = [c.validsince earlierDate:earlierDate];
        laterDate = [c.validthrough laterDate:laterDate];
    }
    dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
    
    @weakify(self)
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [MobClick event:@"rp508-1"];
        @strongify(self)
        if (!self.selectGasCoupouArray.count)
        {
            [self jumpToChooseCouponVC];
        }
        else
        {
            if (self.couponType == CouponTypeGasNormal ||
                    self.couponType == CouponTypeGasReduceWithThreshold ||
                    self.couponType == CouponTypeGasDiscount)
            {
                self.couponType = 0;
            }
            else
            {
                HKCoupon * coupon = [self.selectGasCoupouArray safetyObjectAtIndex:0];
                self.couponType = coupon.conponType;
            }
        }
    }];

    
    [[RACObserve(self, couponType) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
        
        BOOL flag = NO;
        CouponType coupon = (CouponType)[num integerValue];
        if (coupon == CouponTypeGasNormal ||
            coupon == CouponTypeGasReduceWithThreshold ||
            coupon == CouponTypeGasDiscount)
        {
            flag = YES;
        }
        
        if (flag)
        {
            statusLb.text = @"已选中";
            statusLb.textColor = HEXCOLOR(@"#fb4209");
            statusLb.hidden = NO;
            boxB.selected = YES;
        }
        else
        {
            statusLb.text = @"未使用";
            statusLb.textColor = HEXCOLOR(@"#aaaaaa");
            statusLb.hidden = YES;
            boxB.selected = NO;
        }
        
        [self refreshBottomView];
            
    }];
    
    if (indexPath.row == array.count - 1)
    {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    }
    return cell;
}

- (UITableViewCell *)paymentPlatformHeadCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformHeadCell"];
    
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    
    return cell;
}

- (UITableViewCell *)paymentPlatformCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCell"];
    
    UIImageView *iconV = (UIImageView *)[cell searchViewWithTag:1001];
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:1002];
    UILabel * noteLb = (UILabel *)[cell searchViewWithTag:1004];
    UIButton * boxB = (UIButton *)[cell searchViewWithTag:1003];
    UILabel * recommendLB = (UILabel *)[cell searchViewWithTag:1005];
    [recommendLB makeCornerRadius:3.0f];
    
    NSArray * array = [self.datasource safetyObjectAtIndex:indexPath.section];
    NSDictionary * dict = [array safetyObjectAtIndex:indexPath.row];
    
    titleLb.text = dict[@"title"];
    noteLb.text = dict[@"subtitle"];
    iconV.image = [UIImage imageNamed:dict[@"icon"]];
    recommendLB.hidden = ![dict[@"recommend"] boolValue];
    PaymentChannelType tt = (PaymentChannelType)[dict[@"payment"] integerValue];
    
    [[RACObserve(self, paychannel) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
        
        PaymentChannelType type = (PaymentChannelType)[num integerValue];
        boxB.selected = type == tt;
    }];
    
    @weakify(self)
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        if (tt == PaymentChannelAlipay) {
            [MobClick event:@"rp508-3"];
        }
        else if (tt == PaymentChannelWechat) {
            [MobClick event:@"rp508-4"];
        }
        else {
            [MobClick event:@"rp508-5"];
        }
        @strongify(self)
        self.paychannel = tt;
    }];
    
    if (indexPath.row == array.count - 1)
    {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    }
    else
    {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 8, 0, 8)];
    }
    
    return cell;
}

@end
