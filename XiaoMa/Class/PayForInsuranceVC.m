//
//  PayForInsuranceVC.m
//  XiaoMa
//
//  Created by jt on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PayForInsuranceVC.h"

#import "PaymentHelper.h"
#import "HKCellData.h"
#import "TTTAttributedLabel.h"
#import "NSString+Format.h"
#import "InsuranceStore.h"
#import "UIView+Layer.h"
#import "HKCoupon.h"
#import "XiaoMa.h"

#import "GetInscouponOp.h"
#import "InsuranceOrderPayOp.h"
#import "OrderPaidSuccessOp.h"

#import "ChooseCouponVC.h"
#import "InsPayResultVC.h"
#import "InsLicensePopVC.h"
#import "DetailWebVC.h"
#import "CouponModel.h"




#define CheckBoxDiscountGroup @"CheckBoxDiscountGroup"
#define CheckBoxPlatformGroup @"CheckBoxPlatformGroup"

@interface PayForInsuranceVC ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (nonatomic)BOOL isLoadingResourse;
@property (nonatomic, assign) BOOL isLicenseChecked;
@property (nonatomic, strong) HKCellData *licenseData;

@property (nonatomic,strong)NSArray * validInsuranceCouponArray;

@property (nonatomic)PaymentChannelType paymentChannel;
@end

@implementation PayForInsuranceVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"PayForInsuranceVC dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupBottomView];
    
    [self reloadLicenseData];
    [self requestGetUserInsCoupon];
}


#pragma mark - Setup
- (void)setupBottomView
{
    //label
    CGFloat total = self.insOrder.totoalpay + self.insOrder.forcetaxfee;
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:1001];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"总计："
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr1];
    NSString *strfee = [NSString stringWithFormat:@"￥%@", [NSString formatForRoundPrice2:total]];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:strfee
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
}

#pragma mark - Datasource
- (void)reloadLicenseData
{
    self.licenseData = [HKCellData dataWithCellID:@"LicenseCell" tag:nil];
    self.licenseData.customInfo[@"check"] = @YES;
    
    NSMutableString *license = [NSMutableString stringWithString:@"我已阅读并同意小马达达《保险服务协议》"];
    
    self.licenseData.customInfo[@"range1"] = [NSValue valueWithRange:NSMakeRange(license.length - 8, 8)];
    self.licenseData.customInfo[@"url1"] = [NSURL URLWithString:kInsuranceLicenseUrl];
    if (self.insOrder.licenseUrl.length > 0) {
        NSString *license2 = self.insOrder.licenseName;
        [license appendFormat:@"和《%@》", license2];
        self.licenseData.customInfo[@"range2"] = [NSValue valueWithRange:NSMakeRange(license.length-license2.length-2, license2.length+2)];
        self.licenseData.customInfo[@"url2"] = [NSURL URLWithString:self.insOrder.licenseUrl];
    }
    
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.lineSpacing = 5;
    NSAttributedString *attstr = [[NSAttributedString alloc] initWithString:license
                                                                 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                                                              NSForegroundColorAttributeName: HEXCOLOR(@"#9a9a9a"),
                                                                              NSParagraphStyleAttributeName: ps}];
    self.licenseData.object = attstr;
    
    [self.licenseData setHeightBlock:^CGFloat(UITableView *tableView) {
        CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:attstr
                                                       withConstraints:CGSizeMake(tableView.frame.size.width-60, 10000)
                                                limitedToNumberOfLines:0];
        return MAX(40, ceil(size.height+24));
    }];

    [self.tableView reloadData];
}
#pragma mark - Action
- (void)actionBack:(id)sender
{
    [MobClick event:@"rp1006_1"];
    [self.insModel popToOrderVCForNav:self.navigationController withInsOrderID:self.insOrder.orderid];
}

- (IBAction)actionCallCenter:(id)sender
{
    [MobClick event:@"1006_2"];
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"咨询电话: 4007-111-111"];
}

- (IBAction)actionPay:(id)sender {
    
    [MobClick event:@"rp326_6"];
    @weakify(self);
    [[self rac_openLicenseVCWithUrl:self.insOrder.licenseUrl title:self.insOrder.licenseName]
     subscribeNext:^(id x) {
         @strongify(self);
         [self requestInsOrderPay];
     }];
}

- (void)gotoPaidFailVC
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"知道了" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"您的保险订单支付失败，请重新支付！" ActionItems:@[cancel]];
    [alert show];
    
}

- (void)gotoPaidSuccessVC
{
    InsPayResultVC *resultVC = [UIStoryboard vcWithId:@"InsPayResultVC" inStoryboard:@"Insurance"];
    resultVC.insModel = self.insModel;
    resultVC.insOrder = self.insOrder;
    [self.navigationController pushViewController:resultVC animated:YES];
}


- (BOOL)callPaymentHelperWithPayOp:(InsuranceOrderPayOp *)op
{
    if (op.rsp_total == 0) {
        return NO;
    }
    
    CGFloat price = op.rsp_total;
#if DEBUG
    price = 0.01;
#endif
    
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    NSString * info = [NSString stringWithFormat:@"%@-%@的保险订单支付",self.insOrder.inscomp,self.insOrder.licencenumber];
    NSString *text;
    switch (op.req_paychannel) {
        case PaymentChannelAlipay: {
            text = @"订单生成成功,正在跳转到支付宝平台进行支付";
            [helper resetForAlipayWithTradeNumber:op.rsp_tradeno productName:info productDescription:info price:price];
        } break;
        case PaymentChannelWechat: {
            text = @"订单生成成功,正在跳转到微信平台进行支付";
            [helper resetForWeChatWithTradeNumber:op.rsp_tradeno productName:info price:price];
        } break;
        case PaymentChannelUPpay: {
            text = @"订单生成成功,正在跳转到银联平台进行支付";
            [helper resetForUPPayWithTradeNumber:op.rsp_tradeno targetVC:self];
        } break;
        default:
            return NO;
    }
    [gToast showText:text];
    @weakify(self);
    [[helper rac_startPay] subscribeNext:^(id x) {
        
        @strongify(self);
        InsuranceStore *store = [InsuranceStore fetchExistsStore];
        //刷新保险订单
        [[store getInsOrderByID:self.insOrder.orderid] sendAndIgnoreError];
        //刷新保险车辆列表
        [[store getInsSimpleCars] sendAndIgnoreError];
        
        [self gotoPaidSuccessVC];

        OrderPaidSuccessOp *iop = [[OrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 1;
        iop.req_tradeno = op.rsp_tradeno;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"已通知服务器支付成功!");
        }];
    } error:^(NSError *error) {

        @strongify(self);
        [self gotoPaidFailVC];
    }];
    return YES;
}

#pragma mark - Request
- (void)requestInsOrderPay
{
    InsuranceOrderPayOp * op = [InsuranceOrderPayOp operation];
    op.req_orderid = self.insOrder.orderid;
    
    if (self.isSelectActivity)
    {
        op.req_cid = nil;
        op.req_type = self.isSelectActivity;
    }
    else
    {
        if (!self.couponType)
        {
            op.req_cid = nil;
        }
        else
        {
            HKCoupon * c = [self.selectInsuranceCoupouArray safetyObjectAtIndex:0];
            op.req_cid = c.couponId;
        }
    }
    
    PaymentChannelType channel = self.paymentChannel;
    if (channel == 0)
    {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"请选择支付方式" ActionItems:@[cancel]];
        [alert show];
        return;
    }
    op.req_paychannel = channel;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"订单生成中..."];
    }] subscribeNext:^(InsuranceOrderPayOp * op) {
        
        @strongify(self);
        if (![self callPaymentHelperWithPayOp:op]) {
            
            [gToast dismiss];
            InsuranceStore *store = [InsuranceStore fetchExistsStore];
            //刷新保险订单
            [[store getInsOrderByID:self.insOrder.orderid] sendAndIgnoreError];
            //刷新保险车辆列表
            [[store getInsSimpleCars] sendAndIgnoreError];
            
            [self gotoPaidSuccessVC];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 0;
    if (section == 0) {
        count = 6;
    }
    else if (section == 1) {
        
        count = 3 - (self.insOrder.iscontainActivity ? 0 : 1);
    }
    else if (section == 2) {
        count = 4 - (gPhoneHelper.exsitWechat ? 0:1);
    }
    else if (section == 3) {
        return 1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0){
        if (indexPath.row == 0)
            height = 55;
        else if (indexPath.row == 5)
            height = 30;
        else
            height = 23;
    }
    else if (indexPath.section == 3) {
        height = self.licenseData.heightBlock(tableView);
    }
    else{
        if (indexPath.row == 0)
            height = 40;
        else
            height = 50;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
   return  CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
        return CGFLOAT_MIN;
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self insTitleCellAtIndexPath:indexPath];
        }
        else {
            cell = [self insItemCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0){
            cell = [self discountTitleCellAtIndexPath:indexPath];
        }
        else{
            cell = [self discountCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0){
            cell = [self paymentPlatformTitleCellAtIndexPath:indexPath];
        }
        else{
            cell = [self paymentPlatformCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 3) {
        cell = [self licenseCellAtIndexPath:indexPath];
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 1)
        {
            [MobClick event:@"rp326_1"];
            if (!self.insOrder.iscontainActivity)
            {
                [self jumpToChooseCouponVC];
            }
            else
            {
                if (self.isSelectActivity)
                {
                    self.isSelectActivity = NO;
                }
                else
                {
                    self.isSelectActivity = YES;
                    [self.selectInsuranceCoupouArray removeAllObjects];
                    self.couponType = 0;
                }
            }
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp326_2"];
            [self jumpToChooseCouponVC];
        }
        
        ///取消支付宝，微信勾选
        [self.tableView reloadData];
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 1) {
           self.paymentChannel = PaymentChannelAlipay;
        }
        else if (indexPath.row == 2) {
            if (gPhoneHelper.exsitWechat)
            {
                self.paymentChannel = PaymentChannelWechat;
            }
            else
            {
                self.paymentChannel = PaymentChannelUPpay;
            }
        }
        else if (indexPath.row == 3) {
            self.paymentChannel = PaymentChannelUPpay;
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - About Cell
- (UITableViewCell *)insTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InsuranceTitleCell"];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    logoV.cornerRadius = 5.0f;
    logoV.layer.masksToBounds = YES;
    
    [logoV setImageByUrl:self.insOrder.picUrl withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    titleL.text = self.insOrder.inscomp;
    
    return cell;
}

- (UITableViewCell *)insItemCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InsuranceItemCell"];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];
    
    if (indexPath.row == 1) {
        titleL.text = [NSString stringWithFormat:@"投保车辆"];
        infoL.textColor = HEXCOLOR(@"#505050");
        infoL.text = self.insOrder.licencenumber;
    }
    else if (indexPath.row == 2) {
        titleL.text = [NSString stringWithFormat:@"商业险期限"];
        infoL.textColor = HEXCOLOR(@"#505050");
        infoL.text = self.insOrder.validperiod;
    }
    else if (indexPath.row == 3) {
        titleL.text = [NSString stringWithFormat:@"交强险期限"];
        infoL.textColor = HEXCOLOR(@"#505050");
        infoL.text = self.insOrder.fvalidperiod;
    }
    else if (indexPath.row == 4) {
        titleL.text = @"交强险/车船税";
        infoL.textColor = HEXCOLOR(@"#fb4209");
        infoL.text = [NSString stringWithFormat:@"￥%.2f", self.insOrder.forcetaxfee];
    }
    else if (indexPath.row == 5) {
        titleL.text = [NSString stringWithFormat:@"商业险保费"];
        infoL.textColor = HEXCOLOR(@"#fb4209");
        infoL.text = [NSString stringWithFormat:@"￥%.2f",self.insOrder.totoalpay];
    }
    
    return cell;
}

- (UITableViewCell *)discountCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DiscountCell"];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *tagLb = (UILabel *)[cell.contentView viewWithTag:20201];
    UIView *tagBg = (UIView *)[cell.contentView viewWithTag:102];
    UIImageView * squareView = (UIImageView *)[cell searchViewWithTag:103];
    
    if (self.insOrder.iscontainActivity)
    {
        if (indexPath.row == 1) {
            
            label.text = self.insOrder.activityTag;
            tagLb.text = self.insOrder.activityName;
            [tagBg makeCornerRadius:3.0f];
            tagLb.hidden = !self.insOrder.activityName.length;
            tagBg.hidden = !self.insOrder.activityName.length;
            
            [[RACObserve(self, isSelectActivity) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
                
                squareView.hidden = ![number integerValue];
            }];
            
            [tagLb mas_remakeConstraints:^(MASConstraintMaker *make) {
               
                make.centerY.equalTo(cell.contentView);
            }];
        }
        else
        {
            cell = [self setupInsuranceCouponForCell];
        }
    }
    else
    {
        cell = [self setupInsuranceCouponForCell];
    }
    
    return cell;
}

- (UITableViewCell *)paymentPlatformCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PayPlatformCell"];
    UIImageView *iconImgV,*tickImgV;
    UILabel *titleLb,*recommendLB;
    iconImgV = (UIImageView *)[cell searchViewWithTag:101];
    titleLb = (UILabel *)[cell searchViewWithTag:102];
    tickImgV = (UIImageView *)[cell searchViewWithTag:103];
    recommendLB = (UILabel *)[cell searchViewWithTag:104];
    recommendLB.cornerRadius = 3.0f;
    recommendLB.layer.masksToBounds = YES;
    
    
    if (indexPath.row == 1) {
        iconImgV.image = [UIImage imageNamed:@"cw_alipay"];
        titleLb.text = @"支付宝支付";
        recommendLB.hidden = NO;
        tickImgV.hidden = self.paymentChannel != PaymentChannelAlipay;
    }
    else if (indexPath.row == 2) {
        if (gPhoneHelper.exsitWechat)
        {
            iconImgV.image = [UIImage imageNamed:@"cw_wechat"];
            titleLb.text = @"微信支付";
            tickImgV.hidden = self.paymentChannel != PaymentChannelWechat;
        }
        else
        {
            iconImgV.image = [UIImage imageNamed:@"ins_uppay"];
            titleLb.text = @"银联支付";
            tickImgV.hidden = self.paymentChannel != PaymentChannelUPpay;
        }
        recommendLB.hidden = YES;
    }
    else if (indexPath.row == 3) {
        iconImgV.image = [UIImage imageNamed:@"ins_uppay"];
        titleLb.text = @"银联支付";
        recommendLB.hidden = YES;
        tickImgV.hidden = self.paymentChannel != PaymentChannelUPpay;
    }

    return cell;
}



- (UITableViewCell *)discountTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DiscountInfoCell"];
    UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:202];
    indicator.animating = self.isLoadingResourse;
    indicator.hidden = !self.isLoadingResourse;
    return cell;
}

- (UITableViewCell *)paymentPlatformTitleCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)licenseCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LicenseCell"];
    UIButton *checkB = [cell viewWithTag:1001];
    TTTAttributedLabel *richL = [cell viewWithTag:1002];
    
    HKCellData *data = self.licenseData;
    
    BOOL checked = [data.customInfo[@"check"] boolValue];
    checkB.selected = checked;
    //选择框
    @weakify(checkB);
    [[[checkB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(checkB);
         BOOL checked = ![data.customInfo[@"check"] boolValue];
         data.customInfo[@"check"] = @(checked);
         checkB.selected = checked;
         self.payBtn.enabled = checked;
         if (checked)
             [self.payBtn setBackgroundColor:HEXCOLOR(@"#ff7428")];
         else
             [self.payBtn setBackgroundColor:HEXCOLOR(@"#dbdbdb")];
    }];

    //文字和协议链接
    if (!data.customInfo[@"setup"]) {
        data.customInfo[@"setup"] = @YES;
        richL.delegate = self;
        richL.attributedText = data.object;
        [richL setLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                   NSForegroundColorAttributeName: HEXCOLOR(@"#007aff")}];
        [richL setActiveLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                         NSForegroundColorAttributeName: HEXCOLOR(@"#888888")}];
        [richL addLinkToURL:data.customInfo[@"url1"] withRange:[data.customInfo[@"range1"] rangeValue]];
        if (data.customInfo[@"range2"]) {
            [richL addLinkToURL:data.customInfo[@"url2"] withRange:[data.customInfo[@"range2"] rangeValue]];
        }
    }
    
    return cell;
}

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url = [url absoluteString];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Utility
- (RACSignal *)rac_openLicenseVCWithUrl:(NSString *)url title:(NSString *)title
{
    if (self.isLicenseChecked || url.length == 0) {
        return [RACSubject return:@YES];
    }
    @weakify(self);
    return [[InsLicensePopVC rac_showInView:self.navigationController.view withLicenseUrl:url title:title] doNext:^(id x) {
        @strongify(self);
        self.isLicenseChecked = YES;
    }];
}


- (void)requestGetUserInsCoupon
{
    
    CouponModel * couponModel = [[CouponModel alloc] init];
    [[couponModel rac_getVaildInsuranceCoupon:self.insOrder.orderid] subscribeNext:^(GetInscouponOp * op) {
        
        self.validInsuranceCouponArray = op.rsp_inscouponsArray;
        [self selectDefaultCoupon];
        
        self.isLoadingResourse = NO;
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    } error:^(NSError *error) {
        
        self.isLoadingResourse = NO;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

- (void)selectDefaultCoupon
{
    [self.selectInsuranceCoupouArray removeAllObjects];
    self.couponType = CouponTypeNone;
    if (self.insOrder.iscontainActivity)
    {
        self.couponType = 0;
        self.isSelectActivity = YES;
        [self tableViewReloadData];
        return;
    }
    if (self.validInsuranceCouponArray.count)
    {
        for (NSInteger i = 0 ; i < self.validInsuranceCouponArray.count ; i++)
        {
            HKCoupon * coupon = [self.validInsuranceCouponArray safetyObjectAtIndex:i];
            if (coupon.couponAmount < self.insOrder.totoalpay)
            {
                    [self.selectInsuranceCoupouArray addObject:coupon];
                    self.couponType = CouponTypeInsurance;
                    self.isSelectActivity = NO;
                    break;
            }
        }
        [self tableViewReloadData];
        return;
    }
    [self.tableView reloadData];
    [self refreshPriceLb];
}

- (void)tableViewReloadData
{
    [self.tableView reloadData];
    [self refreshPriceLb];
}

- (void)refreshPriceLb
{
    CGFloat amount = self.insOrder.totoalpay;
    if (self.couponType == CouponTypeInsurance)
    {
        HKCoupon * coupon = [self.selectInsuranceCoupouArray safetyObjectAtIndex:0];
        amount = amount - coupon.couponAmount;
    }
    else if (self.isSelectActivity == YES)
    {
        if (self.insOrder.activityType == DiscountTypeMinus)
        {
            amount = amount - self.insOrder.activityAmount;
        }
        else if (self.insOrder.activityType == DiscountTypeDiscount)
        {
            amount = amount - self.insOrder.activityAmount;
        }
    }
    amount += self.insOrder.forcetaxfee;
    NSString * btnText = [NSString stringWithFormat:@"您只需支付%.2f元，现在支付",amount];
    [self.payBtn setTitle:btnText forState:UIControlStateNormal];
}

- (UITableViewCell *)setupInsuranceCouponForCell
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CouponCell"];
    
    UILabel *nameLb = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *couponLb = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:103];

    
    nameLb.text = @"保险代金券";
    
    if (self.couponType == CouponTypeInsurance)
    {
        couponLb.hidden = NO;
        dateLb.hidden = NO;
        couponLb.text = [self calcCouponTitle:self.selectInsuranceCoupouArray];
        dateLb.text = [self calcCouponValidDateString:self.selectInsuranceCoupouArray];
    }
    else
    {
        couponLb.hidden = YES;
        dateLb.hidden = YES;
    }
    return cell;
}

- (void)jumpToChooseCouponVC
{
    ChooseCouponVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"ChooseCouponVC"];
    vc.type = CouponTypeInsurance;
    vc.selectedCouponArray = self.selectInsuranceCoupouArray;
    vc.couponArray = self.validInsuranceCouponArray;
    vc.numberLimit = 1;
    vc.upperLimit = self.insOrder.totoalpay;
    [self.navigationController pushViewController:vc animated:YES];
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
        NSString * string =  [NSString stringWithFormat:@"%@元代金劵",[NSString formatForPrice:totalAmount]];
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


#pragma mark - Lazy 
- (NSMutableArray *)selectInsuranceCoupouArray
{
    if (!_selectInsuranceCoupouArray)
        _selectInsuranceCoupouArray = [NSMutableArray array];
    return _selectInsuranceCoupouArray;
}
@end
