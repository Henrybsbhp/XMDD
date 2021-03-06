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

#import "GetInscouponOp.h"
#import "InsuranceOrderPayOp.h"
#import "OrderPaidSuccessOp.h"

#import "ChooseCouponVC.h"
#import "InsPayResultVC.h"
#import "InsLicensePopVC.h"
#import "DetailWebVC.h"
#import "CouponModel.h"
#import "UPApplePayHelper.h"


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

@property (nonatomic,strong)CKList * datasource;

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
    
    self.paymentChannel = PaymentChannelUPpay;
    
    [self setupBottomView];
    
    [self reloadLicenseData];
    [self setupDatasource];
    [self requestGetUserInsCoupon];
}



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
                                                       withConstraints:CGSizeMake(self.view.frame.size.width-60, 10000)
                                                limitedToNumberOfLines:0];
        return MAX(40, ceil(size.height+24));
    }];
    
    [self.tableView reloadData];
}

- (NSDictionary *)getPaymentChannelInfo:(PaymentChannelType)type
{
    if (type == PaymentChannelAlipay)
    {
        NSDictionary * alipay = @{@"title":@"支付宝支付",@"subtitle":@"推荐支付宝用户使用",
                                  @"payment":@(PaymentChannelAlipay),@"recommend":@(NO),
                                  @"cellname":@"PaymentPlatformCell",@"icon":@"alipay_logo_66",@"uppayrecommend":@(NO)};
        return alipay;
    }
    else if (type == PaymentChannelWechat)
    {
        
        NSDictionary * wechat = @{@"title":@"微信支付",@"subtitle":@"推荐微信用户使用",
                                  @"payment":@(PaymentChannelWechat),@"recommend":@(NO),
                                  @"cellname":@"PaymentPlatformCell",@"icon":@"wechat_logo_66",@"uppayrecommend":@(NO)};
        return wechat;
    }
    else if (type == PaymentChannelUPpay)
    {
        NSDictionary * uppay = @{@"title":@"银联在线支付",@"subtitle":@"推荐银联用户使用",
                                 @"payment":@(PaymentChannelUPpay),@"recommend":@(YES),
                                 @"cellname":@"PaymentPlatformCell",@"icon":@"uppay_logo_66",@"uppayrecommend":@(NO)};
        return uppay;
    }
    else
    {
        NSDictionary * appleypay = @{@"title":@"Apple Pay",@"subtitle":@"推荐Apple Pay用户使用",
                                     @"payment":@(PaymentChannelApplePay),@"recommend":@(NO),
                                     @"cellname":@"PaymentPlatformCell",@"icon":@"apple_pay_logo_66",@"uppayrecommend":@(YES)};
        return appleypay;
    }
}

- (void)setupDatasource
{
    CKDict * insTitleCell = [self setupInsTitleCell];
    
    CKList * list0 = $(insTitleCell);
    if (self.insOrder.licencenumber.length)
    {
        [list0 addObject: [self setupInsItemCell:@{@"title":@"投保车辆",@"content":self.insOrder.licencenumber,@"color": HEXCOLOR(@"#505050")}] forKey:nil];
    }
    if (self.insOrder.validperiod.length)
    {
        [list0 addObject:[self setupInsItemCell:@{@"title":@"商业险期限",@"content":self.insOrder.validperiod,@"color": HEXCOLOR(@"#505050")}] forKey:nil];
    }
    if (self.insOrder.fvalidperiod.length)
    {
        [list0 addObject:[self setupInsItemCell:@{@"title":@"交强险期限",@"content":self.insOrder.fvalidperiod,@"color": HEXCOLOR(@"#505050")}] forKey:nil];
    }
    if (self.insOrder.forcetaxfee > 0)
    {
        [list0 addObject:[self setupInsItemCell:@{@"title":@"交强险/车船税",@"content":[NSString stringWithFormat:@"￥%.2f", self.insOrder.forcetaxfee],@"color": HEXCOLOR(@"#fb4209")}] forKey:nil];
    }
    if (self.insOrder.totoalpay > 0)
    {
        [list0 addObject:[self setupInsItemCell:@{@"title":@"商业险保费",@"content":[NSString stringWithFormat:@"￥%.2f",self.insOrder.totoalpay],@"color": HEXCOLOR(@"#fb4209")}] forKey:nil];
    }
    
    CKDict * discountTitleCell = [self setupDiscountTitleCell];
    CKDict * activeCell = [self setupActiveCell];
    CKDict * couponCell = [self setupCouponCell];
    
    CKDict * paymentTitleCell = [self setupPaymentPlatformTitleCell];
    CKDict * uppayCell = [self setupPaymentPlatformCell:[self getPaymentChannelInfo:PaymentChannelUPpay]];
    CKDict * applepayCell = [self setupPaymentPlatformCell:[self getPaymentChannelInfo:PaymentChannelApplePay]];
    CKDict * alipayCell = [self setupPaymentPlatformCell:[self getPaymentChannelInfo:PaymentChannelAlipay]];
    CKDict * wechatCell = [self setupPaymentPlatformCell:[self getPaymentChannelInfo:PaymentChannelWechat]];
    
    CKDict * linsenceCell = [self setupLinsenceCell];
    
    
    
    
    CKList * list1 = [CKList list];
    [list1 addObject:discountTitleCell forKey:nil];
    if (self.insOrder.iscontainActivity)
    {
        [list1 addObject:activeCell forKey:nil];
    }
    [list1 addObject:couponCell forKey:nil];
    
    CKList * list2 = [CKList list];
    [list2 addObject:paymentTitleCell forKey:nil];
    [list2 addObject:uppayCell forKey:nil];
    if ([UPApplePayHelper isApplePayAvailable])
        [list2 addObject:applepayCell forKey:nil];
    [list2 addObject:alipayCell forKey:nil];
    if (gPhoneHelper.exsitWechat)
        [list2 addObject:wechatCell forKey:nil];
    
    CKList * list3 = $(linsenceCell);
    
    self.datasource = $(list0,list1,list2,list3);
}

- (CKDict *)setupInsTitleCell
{
    @weakify(self);
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"InsuranceTitleCell", kCKCellID: @"InsuranceTitleCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 55;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
        logoV.cornerRadius = 5.0f;
        logoV.layer.masksToBounds = YES;
        
        [logoV setImageByUrl:self.insOrder.picUrl withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
        titleL.text = self.insOrder.inscomp;
    });
    
    return cell;
}

/// 保险信息
- (CKDict *)setupInsItemCell:(NSDictionary *)dict
{
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"InsuranceItemCell", kCKCellID: @"InsuranceItemCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        CKList * firstSection = [self.datasource objectAtIndex:indexPath.section];

        if (indexPath.row == 0)
        {
            return 55;
        }
        if (indexPath.row == firstSection.count)
        {
            return 23;
        }

        return 30;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel *infoL = (UILabel *)[cell.contentView viewWithTag:1002];
        
        titleL.text = dict[@"title"];
        infoL.textColor = dict[@"color"];
        infoL.text = dict[@"content"];
    });
    
    return cell;
}


- (CKDict *)setupDiscountTitleCell
{
    @weakify(self);
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"DiscountInfoCell", kCKCellID: @"DiscountInfoCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 40;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UIActivityIndicatorView * indicator = (UIActivityIndicatorView *)[cell searchViewWithTag:202];
        indicator.animating = self.isLoadingResourse;
        indicator.hidden = !self.isLoadingResourse;
    });
    
    return cell;
}

- (CKDict *)setupActiveCell
{
    @weakify(self);
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"DiscountCell", kCKCellID: @"DiscountCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 50;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
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
        ///取消支付宝，微信勾选
        [self.tableView reloadData];
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *tagLb = (UILabel *)[cell.contentView viewWithTag:20201];
        UIView *tagBg = (UIView *)[cell.contentView viewWithTag:102];
        UIImageView * squareView = (UIImageView *)[cell searchViewWithTag:103];
        label.text = self.insOrder.activityTag;
        tagLb.text = self.insOrder.activityName;
        [tagBg makeCornerRadius:3.0f];
        tagLb.hidden = !self.insOrder.activityName.length;
        tagBg.hidden = !self.insOrder.activityName.length;
        
        [[RACObserve(self, isSelectActivity) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * number) {
            
            squareView.hidden = ![number integerValue];
            [self refreshPriceLb];
        }];
        
        [tagLb mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(cell.contentView);
        }];
    });
    
    return cell;
}

- (CKDict *)setupCouponCell
{
    @weakify(self);
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"CouponCell", kCKCellID: @"CouponCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 50;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        [MobClick event:@"baoxianzhifuqueren" attributes:@{@"zhifuqueren":@"zhifuqueren5"}];

        [self jumpToChooseCouponVC];
        ///取消支付宝，微信勾选
        [self.tableView reloadData];
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *nameLb = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *couponLb = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:103];
        
        @strongify(self)
        nameLb.text = @"保险优惠券";
        
        if (self.couponType == CouponTypeInsurance || self.couponType == CouponTypeInsuranceDiscount)
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
    });
    
    return cell;
}

- (CKDict *)setupPaymentPlatformTitleCell
{
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"OtherInfoCell", kCKCellID: @"OtherInfoCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 40;
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    });
    
    return cell;
}

- (CKDict *)setupPaymentPlatformCell:(NSDictionary *)dict
{
    @weakify(self);
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"PayPlatformCell", kCKCellID: @"PayPlatformCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 50;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self)
        PaymentChannelType tt = (PaymentChannelType)[dict[@"payment"] integerValue];
        self.paymentChannel = tt;
        
        if (tt == PaymentChannelUPpay)
        {
            [MobClick event:@"baoxianzhifuqueren" attributes:@{@"zhifuqueren":@"zhifuqueren6"}];
        }
        else if (tt == PaymentChannelApplePay)
        {
            [MobClick event:@"baoxianzhifuqueren" attributes:@{@"zhifuqueren":@"zhifuqueren7"}];
        }
        else if (tt == PaymentChannelAlipay)
        {
            [MobClick event:@"baoxianzhifuqueren" attributes:@{@"zhifuqueren":@"zhifuqueren8"}];
        }
        else
        {
            [MobClick event:@"baoxianzhifuqueren" attributes:@{@"zhifuqueren":@"zhifuqueren9"}];
        }
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UIImageView *iconV = (UIImageView *)[cell searchViewWithTag:1001];
        UILabel * titleLb = (UILabel *)[cell searchViewWithTag:1002];
        UIButton * checkedB = (UIButton *)[cell searchViewWithTag:1003];
        UILabel * recommendLB = (UILabel *)[cell searchViewWithTag:1005];
        UIImageView * uppayIcon = [cell viewWithTag:1006];
        
        recommendLB.cornerRadius = 3.0f;
        recommendLB.layer.masksToBounds = YES;
        
        titleLb.text = dict[@"title"];
        iconV.image = [UIImage imageNamed:dict[@"icon"]];
        recommendLB.hidden = ![dict[@"recommend"] boolValue];
        uppayIcon.hidden = ![dict[@"uppayrecommend"] boolValue];
        PaymentChannelType tt = (PaymentChannelType)[dict[@"payment"] integerValue];
        
        [[RACObserve(self, paymentChannel) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
            
            PaymentChannelType type = (PaymentChannelType)[num integerValue];
            checkedB.hidden = type != tt;
        }];
    });
    
    return cell;
}

- (CKDict *)setupLinsenceCell
{
    @weakify(self);
    CKDict *cell = [CKDict dictWith:@{kCKItemKey: @"LicenseCell", kCKCellID: @"LicenseCell"}];
    cell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        CGFloat height = self.licenseData.heightBlock(nil);
        return height;
    });
    
    cell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        
    });
    
    cell[kCKCellPrepare] = CKCellPrepare(^(CKDict *dict, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        
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
                 [self.payBtn setBackgroundColor:kOrangeColor];
             else
                 [self.payBtn setBackgroundColor:kLightTextColor];
         }];
        
        //文字和协议链接
        if (!data.customInfo[@"setup"]) {
            data.customInfo[@"setup"] = @YES;
            richL.delegate = self;
            richL.attributedText = data.object;
            [richL setLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                       NSForegroundColorAttributeName: HEXCOLOR(@"#007aff")}];
            [richL setActiveLinkAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                             NSForegroundColorAttributeName: kGrayTextColor}];
            [richL addLinkToURL:data.customInfo[@"url1"] withRange:[data.customInfo[@"range1"] rangeValue]];
            if (data.customInfo[@"range2"]) {
                [richL addLinkToURL:data.customInfo[@"url2"] withRange:[data.customInfo[@"range2"] rangeValue]];
            }
        }
    });
    
    return cell;
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
    
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    switch (op.req_paychannel) {
        case PaymentChannelAlipay: {
            [helper resetForAlipayWithTradeNumber:op.rsp_tradeno alipayInfo:op.rsp_payInfoModel.alipayInfo];
        } break;
        case PaymentChannelWechat: {
            [helper resetForWeChatWithTradeNumber:op.rsp_tradeno andPayInfoModel:op.rsp_payInfoModel.wechatInfo andTradeType:TradeTypeIns];
        } break;
        case PaymentChannelUPpay: {
            [helper resetForUPPayWithTradeNumber:op.rsp_tradeno andPayInfoModel:op.rsp_payInfoModel andTotalFee:op.rsp_total targetVC:self];
        } break;
        case PaymentChannelApplePay: {
            [helper resetForUPApplePayWithTradeNumber:op.rsp_tradeno targetVC:self];
        } break;
        default:
            return NO;
    }
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
        
//        @strongify(self);
//        [self gotoPaidFailVC];
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
        
        [gToast dismiss];
        
        if (![self callPaymentHelperWithPayOp:op]) {
            
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
    
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray * rowArray = [self.datasource objectAtIndex:section];
    NSInteger num = rowArray.count;
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 49;
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
    
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
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
    return [[InsLicensePopVC rac_showInView:self.navigationController.view withLicenseUrl:url title:title andLicensePopVCType:InsLicensePopVCTypeNormal] doNext:^(id x) {
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
                self.couponType = coupon.conponType;
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
    if (self.couponType == CouponTypeInsurance || self.couponType == CouponTypeInsuranceDiscount)
    {
        HKCoupon * coupon = [self.selectInsuranceCoupouArray safetyObjectAtIndex:0];
        amount = amount * coupon.couponPercent / 100 - coupon.couponAmount;
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
    
    if (self.couponType == CouponTypeInsurance || self.couponType == CouponTypeInsuranceDiscount)
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
