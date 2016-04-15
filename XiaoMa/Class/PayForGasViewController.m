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
#import "ChooseCouponVC.h"
#import "NSString+Format.h"
#import "NSString+Split.h"
#import "GasStore.h"
#import "PaymentHelper.h"
#import "GetUserResourcesGaschargeOp.h"
#import "GascardChargeByStagesOp.h"
#import "OrderPaidSuccessOp.h"
#import "CancelGaschargeOp.h"
#import "FMDeviceManager.h"
#import "CKDatasource.h"
#import "GetPayStatusOp.h"

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
@property (nonatomic,strong)NSArray * gasCouponArray;
///支付渠道
@property (nonatomic)PaymentChannelType  paychannel;

///订单号
@property (nonatomic,strong) NSString *tradeID;
// 判断是否是通过支付app进入
@property (nonatomic,assign) BOOL isPaid;

@property (nonatomic,strong) GascardChargeOp *op;

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
    
    [self setupNotification];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)setupNavigationBar
{
    self.navigationItem.title = @"支付确认";
    
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupUI
{
    //分期加油
    if ([self.gasNormalVC isRechargeForInstalment]) {
        self.payTitle = [NSString stringWithFormat:@"%@折分期加油", self.gasNormalVC.curChargePkg.discount];
        self.paySubTitle = [NSString stringWithFormat:@"分%d个月充，每月充值%d元",
                            self.gasNormalVC.curChargePkg.month, (int)self.gasNormalVC.rechargeAmount];
    }
    else {
        self.payTitle = @"油卡充值";
        self.paySubTitle = @"普通充值";
    }
    self.payBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [[self.payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        //支付确定点击事件
        [MobClick event:@"rp508_6"];
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
    
    NSDictionary * dict0_1 = @{@"title":@"充值卡号",@"value":
                                   [self.gasNormalVC.curGasCard.gascardno splitByStep:4 replacement:@" "] ,
                               @"cellname":@"InfoItemCell"};
    
    int amount = (int)self.gasNormalVC.rechargeAmount;
    if ([self.gasNormalVC isRechargeForInstalment]) {
        amount = (int)(amount * self.gasNormalVC.curChargePkg.month);
    }
    NSDictionary * dict0_2 = @{@"title":@"充值金额",@"value":[NSString stringWithFormat:@"￥ %d",amount],
                               @"cellname":@"InfoItemCell"};
    
    if (!self.gasCouponArray)
    {
        self.gasCouponArray = [NSArray array];
    }
    
    NSDictionary * dict1_0 = @{@"cellname":@"CouponHeadCell"};
    
    NSDictionary * dict1_1 = @{@"title":@"加油优惠劵",
                               @"value":@(self.gasNormalVC.rechargeAmount),
                               @"array":self.gasCouponArray,
                               @"isSelect":@(self.couponType),
                               @"cellname":@"CouponCell"};
    
    NSDictionary * dict2_0 = @{@"cellname":@"PaymentPlatformHeadCell"};
    
    NSDictionary * dict2_1 = @{@"title":@"支付宝支付",@"subtitle":@"推荐支付宝用户使用",
                               @"payment":@(PaymentChannelAlipay),@"recommend":@(YES),
                               @"cellname":@"PaymentPlatformCell",@"icon":@"alipay_logo_66"};
    
    NSDictionary * dict2_2 = @{@"title":@"微信支付",@"subtitle":@"推荐微信用户使用",
                               @"payment":@(PaymentChannelWechat),@"recommend":@(NO),
                               @"cellname":@"PaymentPlatformCell",@"icon":@"wechat_logo_66"};
    
    NSDictionary * dict2_3 = @{@"title":@"银联支付",@"subtitle":@"推荐银联用户使用",
                               @"payment":@(PaymentChannelUPpay),@"recommend":@(NO),
                               @"cellname":@"PaymentPlatformCell",@"icon":@"uppay_logo_66"};
    
    self.paymentArray = gPhoneHelper.exsitWechat ? @[dict2_1,dict2_2,dict2_3] : @[dict2_1,dict2_3];
    NSMutableArray * tArray = [NSMutableArray arrayWithObject:dict2_0];
    [tArray addObjectsFromArray:self.paymentArray];
    self.datasource = @[@[dict0_0,dict0_1,dict0_2],@[dict1_0,dict1_1],tArray];
}


#pragma mark - Utilitly
- (void)requestGetGasResource
{
    GetUserResourcesGaschargeOp * op = [GetUserResourcesGaschargeOp operation];
    op.req_fqjyflag = [self.gasNormalVC isRechargeForInstalment] > 0 ? 1 : 0;
    
    [[[op rac_postRequest] initially:^{
        
        self.isLoadingResourse = YES;
    }] subscribeNext:^(GetUserResourcesGaschargeOp * op) {
        
        self.isLoadingResourse = NO;
        self.gasCouponArray = op.rsp_couponArray;
        
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
    NSUInteger rechargeAmount = self.gasNormalVC.rechargeAmount;
    CGFloat couponlimit, discount = 0;
    CGFloat systemPercent = 0;
    CGFloat paymoney = (CGFloat)rechargeAmount;

    GasStore *store = [GasStore fetchExistsStore];
    couponlimit = store.config.rsp_couponupplimit ? store.config.rsp_couponupplimit : 1000;
    systemPercent = store.config ? store.config.rsp_discountrate : 2;
    
    ///分期付款
    if (self.gasNormalVC.curChargePkg.pkgid) {
        paymoney = rechargeAmount * self.gasNormalVC.curChargePkg.month;
        discount = paymoney * (1-[self.gasNormalVC.curChargePkg.discount floatValue]/100.0);
    }
    /// 系统额度
    else if (self.gasNormalVC.curGasCard) {
        discount = MIN([self.gasNormalVC.curGasCard.couponedmoney integerValue], rechargeAmount * systemPercent / 100.0);
    }
    else
    {
        discount = MIN(couponlimit, rechargeAmount) * systemPercent / 100.0;
    }
    
    if ([self isGasCouponType:self.couponType])
    {
        if (coupon.couponPercent < 100)
        {
            // 优惠劵有折扣优惠，直接乘
            discount = paymoney - paymoney * coupon.couponPercent / 100;
        }
        else
        {
            /// 选择了优惠券，优惠劵没折扣优惠  = 原先系统额度 + 优惠劵面额 （ps：优惠劵打折力度和优惠劵面额只存在一个）
            discount = discount + coupon.couponAmount;
        }
    }
    
    paymoney = paymoney - discount;

    if (discount > 0) {
        title = [NSString stringWithFormat:@"已优惠%@元，您只需支付%@元，现在支付", [NSString formatForRoundPrice:discount],[NSString formatForRoundPrice:paymoney]];
    }
    else {
        title = [NSString stringWithFormat:@"您需支付%@元，现在支付",[NSString formatForRoundPrice:paymoney]];
    }
    
    [self.payBtn setTitle:title forState:UIControlStateNormal];
    [self.payBtn setTitle:title forState:UIControlStateDisabled];
}

- (void)jumpToChooseCouponVC
{
     ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
    vc.originVC = self;
    vc.type = CouponTypeGasNormal; /// 加油券类型的用普通代替
    vc.selectedCouponArray = self.selectGasCoupouArray;
    vc.couponArray = self.gasCouponArray;
    vc.payAmount = self.gasNormalVC.rechargeAmount;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (IBAction)actionPay:(id)sender
{
    GasCard *card = self.gasNormalVC.curGasCard;
    GascardChargeOp *op;
    HKCoupon *coupon = [self isGasCouponType:self.couponType] ? [self.selectGasCoupouArray safetyObjectAtIndex:0] : nil;
    //分期支付
    if ([self.gasNormalVC isRechargeForInstalment]) {
        GascardChargeByStagesOp *fqop = [GascardChargeByStagesOp operation];
        fqop.req_cardid = card.gid;
        fqop.req_pkgid = self.gasNormalVC.curChargePkg.pkgid;
        fqop.req_permonthamt = (int)self.gasNormalVC.rechargeAmount;
        op = fqop;
    }
    else {
        op = [GascardChargeOp operation];
        op.req_gid = card.gid;
        op.req_amount = (int)self.gasNormalVC.rechargeAmount;
    }
    self.op = op;
    op.req_gid = card.gid;
    op.req_paychannel = self.paychannel;
    op.req_bill = [self.gasNormalVC needInvoice];
    op.req_cid = coupon.couponId ? coupon.couponId : @0;
    NSString *blackBox = [FMDeviceManager sharedManager]->getDeviceInfo();
    op.req_blackbox = blackBox;
    [self startPayWithChargeOp:op gasCard:card];
}

#pragma mark - Abount Pay
- (void)startPayWithChargeOp:(GascardChargeOp *)op gasCard:(GasCard *)card {
    
    @weakify(self, op);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(GascardChargeOp *op) {
        
        self.tradeID = nil;
        @strongify(self);
        if (![self callPaymentHelperWithPayOp:op gasCard:card]) {
            [gToast dismiss];
            [self cancelOrderWithTradeNumber:op.rsp_tradeid cardID:op.req_gid];
            [self pushToPaymentResultWithPaidOp:op andGasCard:card];
        }
    } error:^(NSError *error) {
        
        @strongify(op);
        [gToast showError:error.domain];
        //加油到达上限（如果遇到该错误，客户端提醒用户后，需再调用一次查询卡的充值信息）
        if (error.code == 618602) {
            [[[GasStore fetchExistsStore] updateCardInfoByGID:op.req_gid] sendAndIgnoreError];
        }
    }];
}

- (BOOL)callPaymentHelperWithPayOp:(GascardChargeOp *)paidop gasCard:(GasCard *)card {
    
    self.tradeID = paidop.rsp_tradeid;
    if (paidop.rsp_total == 0) {
        return NO;
    }
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    NSString * info = [NSString stringWithFormat:@"%@充值－%@油卡充值",
                       [self.gasNormalVC isRechargeForInstalment] ? @"分期" : @"普通",
                       card.cardtype == 2 ? @"中石油" : @"中石化"];
    NSString *text;
    switch (paidop.req_paychannel) {
        case PaymentChannelAlipay: {
            self.isPaid = YES;
            text = @"订单生成成功,正在跳转到支付宝平台进行支付";
            [helper resetForAlipayWithTradeNumber:paidop.rsp_tradeid productName:info productDescription:info price:paidop.rsp_total];
        } break;
        case PaymentChannelWechat: {
            text = @"订单生成成功,正在跳转到微信平台进行支付";
            [helper resetForWeChatWithTradeNumber:paidop.rsp_tradeid productName:info price:paidop.rsp_total];
        } break;
        case PaymentChannelUPpay: {
            text = @"订单生成成功,正在跳转到银联平台进行支付";
            [helper resetForUPPayWithTradeNumber:paidop.rsp_tradeid targetVC:self];
        } break;
        default:
            return NO;
    }
    [gToast showText:text];
    __block BOOL paidSuccess = NO;
    @weakify(self);
    [[helper rac_startPay] subscribeNext:^(id x) {
        
        @strongify(self);
        OrderPaidSuccessOp *op = [OrderPaidSuccessOp operation];
        op.req_notifytype = 3;
        op.req_tradeno = paidop.rsp_tradeid;
        [[op rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"已通知服务器支付成功!");
        }];
        // 支付成功
        self.isPaid = YES;
        paidSuccess = YES;
        [[GasStore fetchOrCreateStore] saverecentlyUsedGasCardID:paidop.req_gid];
        [self pushToPaymentResultWithPaidOp:paidop andGasCard:card];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self cancelOrderWithTradeNumber:paidop.rsp_tradeid cardID:card.gid];
    } completed:^{
        
        if (!paidSuccess) {
            @strongify(self);
            [self cancelOrderWithTradeNumber:paidop.rsp_tradeid cardID:card.gid];
        }
    }];
    return YES;
}

- (void)cancelOrderWithTradeNumber:(NSString *)tdno cardID:(NSNumber *)gid
{
    CKEvent *event = [[[GasStore fetchExistsStore] updateCardInfoByGID:gid] mapSignal:^RACSignal *(RACSignal *signal) {
        CancelGaschargeOp *op = [CancelGaschargeOp operation];
        op.req_tradeid = tdno;
        return [[op rac_postRequest] flattenMap:^RACStream *(id value) {
            return signal;
        }];
    }];
    [event send];
}

#pragma mark - Util

-(void)checkPayment
{
    @weakify(self)
    GetPayStatusOp *op = [[GetPayStatusOp alloc]init];
    if (self.tradeID.length != 0)
    {
        op.req_tradeno = self.tradeID;
        op.req_tradetype = [self.gasNormalVC isRechargeForInstalment] ? @"4" : @"3";
        
        [[[op rac_postRequest]initially:^{
            [gToast showingWithText:@"订单信息查询中"];
        }]subscribeNext:^(id x) {
            [gToast dismiss];
            @strongify(self)
            if (op.rsp_status)
            {
                [self pushToPaymentResultWithPaidOp:self.op andGasCard:self.gasNormalVC.curGasCard];
            }
        }error:^(NSError *error) {
            [gToast showText:error.domain];
        }];
    }
}

- (void)selectedCouponCell {
    [MobClick event:@"rp508_1"];
    [self jumpToChooseCouponVC];
}

- (void)selectedPaymentCellWithInfo:(NSDictionary *)dict {
    PaymentChannelType tt = (PaymentChannelType)[dict[@"payment"] integerValue];
    if (tt == PaymentChannelAlipay) {
        [MobClick event:@"rp508_3"];
    }
    else if (tt == PaymentChannelWechat) {
        [MobClick event:@"rp508_4"];
    }
    else {
        [MobClick event:@"rp508_5"];
    }
    self.paychannel = tt;
   
}

- (void)pushToPaymentResultWithPaidOp:(GascardChargeOp *)paidop andGasCard:(GasCard *)card {
    //分期加油
    if ([paidop isKindOfClass:[GascardChargeByStagesOp class]]) {
        NSString *url = kGasOrderPaidUrl;
#if DEBUG
        url = kDevGasOrderPaidUrl;
#endif
        NSString *status = paidop.rsp_code == 0 ? @"S" : @"F";
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        vc.originVC = self.originVC;
        vc.url = [NSString stringWithFormat:@"%@?fr=APP&token=%@&tradeno=%@&tradetype=FQJY&status=%@",
                  url, gNetworkMgr.token, paidop.rsp_tradeid, status];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //普通加油
    else {
        GasPaymentResultVC *vc = [UIStoryboard vcWithId:@"GasPaymentResultVC" inStoryboard:@"Gas"];
        vc.originVC = self.originVC;
        vc.drawingStatus = DrawingBoardViewStatusSuccess;
        vc.gasCard = card;
        vc.paidMoney = paidop.rsp_total;
        vc.couponMoney = paidop.rsp_couponmoney;
        vc.chargeMoney = paidop.req_amount;
        @weakify(self);
        [vc setDismissBlock:^(DrawingBoardViewStatus status) {
            @strongify(self);
            //更新信息，充值默认500
            self.gasNormalVC.normalRechargeAmount = 500;
            [[[GasStore fetchExistsStore] updateCardInfoByGID:paidop.req_gid] send];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)isGasCouponType:(CouponType)coupon
{
    if (coupon == CouponTypeGasNormal ||
        coupon == CouponTypeGasReduceWithThreshold ||
        coupon == CouponTypeGasDiscount ||
        coupon == CouponTypeGasFqjy1 ||
        coupon == CouponTypeGasFqjy2) {
        return YES;
    }
    return NO;
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
        height = 41;
    }
    else if ([cellName isEqualToString:@"CouponCell"])
    {
        height = 50;
    }
    else if ([cellName isEqualToString:@"PaymentPlatformHeadCell"])
    {
        height = 41;
    }
    else if ([cellName isEqualToString:@"PaymentPlatformCell"])
    {
        height = 50;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 9;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * dict = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSString * cellName = dict[@"cellname"];
    if ([cellName isEqualToString:@"CouponCell"]) {
        [self selectedCouponCell];
    }
    if ([cellName isEqualToString:@"PaymentPlatformCell"]) {
        [self selectedPaymentCellWithInfo:dict];
    }
}

#pragma mark - TableViewCell
- (UITableViewCell *)payTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PayTitleCell"];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    titleL.text = self.payTitle;
    addrL.text = self.paySubTitle;
    logoV.image = [UIImage imageNamed:self.gasNormalVC.curGasCard.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];

    return cell;
}

- (UITableViewCell *)infoItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];

    NSArray * array = [self.datasource safetyObjectAtIndex:indexPath.section];
    NSDictionary * dict = [array safetyObjectAtIndex:indexPath.row];
    titleL.text =  dict[@"title"];
    infoL.text = dict[@"value"];
    
    if (indexPath.row == array.count - 1) {
        infoL.textColor = [UIColor colorWithHex:@"#ff5a00" alpha:1.0f];
    }
    else {
        infoL.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
    }
    
    return cell;
}

- (UITableViewCell *)couponHeadCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CouponHeadCell"];
    UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:202];
    
    [[RACObserve(self, isLoadingResourse) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
        
        indicator.animating = [num integerValue];
        indicator.hidden = ![num integerValue];
    }];

    return cell;
}

- (UITableViewCell *)couponInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CouponInfoCell"];
    UILabel *label = [cell viewWithTag:1001];
    UILabel *detailLabel = [cell viewWithTag:1002];
    UILabel *dateLabel = [cell viewWithTag:1003];
    
    label.text = @"加油优惠券";
    
    @weakify(self);
    [[RACObserve(self, couponType) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
        
        @strongify(self);
        BOOL flag = [self isGasCouponType:[num integerValue]];
        if (flag && self.selectGasCoupouArray.count > 0) {
            dateLabel.text = [self calcCouponValidDateString:self.selectGasCoupouArray];
            HKCoupon *coupon = [self.selectGasCoupouArray safetyObjectAtIndex:0];
            detailLabel.text = coupon.couponName;
        }
        else {
            dateLabel.text = nil;
            detailLabel.text = nil;
        }
        [self refreshBottomView];
    }];

    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 16, 0, 0)];
    return cell;
}

- (UITableViewCell *)paymentPlatformHeadCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformHeadCell"];
    return cell;
}

- (UITableViewCell *)paymentPlatformCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCell"];
    
    UIImageView *iconV = (UIImageView *)[cell searchViewWithTag:1001];
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:1002];
    UILabel * noteLb = (UILabel *)[cell searchViewWithTag:1004];
    UIButton * checkedB = (UIButton *)[cell searchViewWithTag:1003];
    UILabel * recommendLB = (UILabel *)[cell searchViewWithTag:1005];
    [recommendLB makeCornerRadius:3.0f];
    
    NSArray * array = [self.datasource safetyObjectAtIndex:indexPath.section];
    NSDictionary * dict = [array safetyObjectAtIndex:indexPath.row];
    
    titleLb.text = dict[@"title"];
    noteLb.text = dict[@"subtitle"];
    iconV.image = [UIImage imageNamed:dict[@"icon"]];
    recommendLB.hidden = ![dict[@"recommend"] boolValue];
    PaymentChannelType tt = (PaymentChannelType)[dict[@"payment"] integerValue];
    
    [[RACObserve(self, paychannel) takeUntilForCell:cell] subscribeNext:^(NSNumber * num) {
        
        PaymentChannelType type = (PaymentChannelType)[num integerValue];
        checkedB.hidden = type != tt;
    }];
    
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 16, 0, 0)];
    
    return cell;
}

@end
