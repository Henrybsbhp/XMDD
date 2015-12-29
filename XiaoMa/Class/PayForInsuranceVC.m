//
//  PayForInsuranceVC.m
//  XiaoMa
//
//  Created by jt on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PayForInsuranceVC.h"
#import "UIView+Layer.h"
#import "HKCoupon.h"
#import "XiaoMa.h"
#import "GetInscouponOp.h"
#import "ChooseCarwashTicketVC.h"
#import "InsuranceOrderPayOp.h"
#import "PaymentHelper.h"
#import "OrderPaidSuccessOp.h"
#import "HKCellData.h"
#import "TTTAttributedLabel.h"
#import "InsPayResultVC.h"
#import "DetailWebVC.h"
#import "NSString+Format.h"
#import "InsuranceStore.h"
//#import "InsPayFaildVC.h"

#define CheckBoxDiscountGroup @"CheckBoxDiscountGroup"
#define CheckBoxPlatformGroup @"CheckBoxPlatformGroup"

@interface PayForInsuranceVC ()<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (nonatomic,strong) CKSegmentHelper *checkBoxHelper;
@property (nonatomic)BOOL isLoadingResourse;
@property (nonatomic, strong) HKCellData *licenseData;

/////支付平台，（section == 2）
//@property (nonatomic)PaymentPlatform platform;
@end

@implementation PayForInsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCheckBoxHelper];
    [self setupBottomView];
    
    self.selectInsuranceCoupouArray = [NSMutableArray array];
    
    self.isLoadingResourse = YES;
    [self reloadData];
    [self requestGetUserInsCoupon];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"rp326"];
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"rp326"];
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    /**
     *  保单支付页面返回事件
     */
    [MobClick event:@"1006-1"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"PayForInsuranceVC dealloc");
}

- (void)setupCheckBoxHelper
{
    self.checkBoxHelper = [CKSegmentHelper new];
}

- (void)setupBottomView
{
    //line
    [self.bottomView setBorderColor:kDefLineColor];
    [self.bottomView showBorderLineWithDirectionMask:CKViewBorderDirectionTop];
    [self.bottomView layoutBorderLineIfNeeded];
    
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
- (void)reloadData
{
    self.licenseData = [HKCellData dataWithCellID:@"LicenseCell" tag:nil];
    self.licenseData.customInfo[@"check"] = @YES;
    
    NSMutableString *license = [NSMutableString stringWithString:@"我已阅读并同意小马达达《保险服务协议》"];
    
    self.licenseData.customInfo[@"range1"] = [NSValue valueWithRange:NSMakeRange(license.length - 8, 8)];
    self.licenseData.customInfo[@"url1"] = [NSURL URLWithString:kServiceLicenseUrl];
    if (self.insOrder.licenseUrl.length > 0) {
        NSString *license2 = self.insOrder.licenseName;
        [license appendFormat:@"及%@", license2];
        self.licenseData.customInfo[@"range2"] = [NSValue valueWithRange:NSMakeRange(license.length-license2.length, license2.length)];
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
- (IBAction)actionCallCenter:(id)sender
{
    /**
     *  咨询点击事件
     */
    [MobClick event:@"1006-2"];
    NSString * number = @"4007111111";
    [gPhoneHelper makePhone:number andInfo:@"咨询电话: 4007-111-111"];
}

- (void)gotoPaidFailVC
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"您的保险订单支付失败，请重新支付！" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    [alert show];
//    InsPayFaildVC *vc = [UIStoryboard vcWithId:@"InsPayFaildVC" inStoryboard:@"Insurance"];
//    vc.insOrder = self.insOrder;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)gotoPaidSuccessVC
{
    InsPayResultVC *resultVC = [UIStoryboard vcWithId:@"InsPayResultVC" inStoryboard:@"Insurance"];
    resultVC.insModel = self.insModel;
    resultVC.insOrder = self.insOrder;
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (IBAction)actionPay:(id)sender {
    [MobClick event:@"rp326-6"];
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
    
    PaymentChannelType channel = [self getCurrentPaymentChannel];
    if (channel == 0)
    {
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择支付方式" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        [av show];
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

- (PaymentChannelType)getCurrentPaymentChannel
{
    NSArray * array = [[self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup] sortedArrayUsingComparator:^NSComparisonResult(UIButton * obj1, UIButton * obj2) {
        
        NSIndexPath * path1 = (NSIndexPath *)obj1.customObject;
        NSIndexPath * path2 = (NSIndexPath *)obj2.customObject;
        return path1.row > path2.row;
    }];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        BOOL s = btn.selected;
        if (s == YES)
        {
            if (i == 0)
            {
                return PaymentChannelAlipay;
            }
            else if (i == 1)
            {
                if (gPhoneHelper.exsitWechat)
                    return PaymentChannelWechat;
                else
                    return PaymentChannelUPpay;
            }
            else if (i == 2)
            {
                return PaymentChannelUPpay;
            }
        }
    }
    return 0;
}

- (void)getCurrentCoupon:(InsuranceOrderPayOp *)op
{
    NSArray * array = [[self.checkBoxHelper itemsForGroupName:CheckBoxDiscountGroup] sortedArrayUsingComparator:^NSComparisonResult(UIButton * obj1, UIButton * obj2) {
        
        NSIndexPath * path1 = (NSIndexPath *)obj1.customObject;
        NSIndexPath * path2 = (NSIndexPath *)obj2.customObject;
        return path1.row > path2.row;
    }];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        BOOL s = btn.selected;
        if (s == YES)
        {
            if (i == 1)
            {
                if (self.insOrder.iscontainActivity)
                {
                    op.req_cid = nil;
                    op.req_type = self.insOrder.activityType;
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
                    op.req_type = 0;
                }
            }
            else if (i == 2)
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
                op.req_type = 0;
            }
            return;
        }
    }
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
        //刷新保险订单
        [[[InsuranceStore fetchExistsStore] getInsOrderByID:self.insOrder.orderid] sendAndIgnoreError];
        
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            height = 66;
        }
        else if (indexPath.row == 5){
            height = 30;
        }
        else
        {
            height = 26;
        }
    }
    if (indexPath.section != 0){
        if (indexPath.row == 0){
            height = 30;
        }
        else{
            height = 50;
        }
    }
    if (indexPath.section == 3) {
        height = self.licenseData.heightBlock(tableView);
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return  CGFLOAT_MIN;
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
        if (indexPath.row == 0)
        {
            cell = [self discountTitleCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self discountCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0)
        {
            cell = [self paymentPlatformTitleCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self paymentPlatformCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 3) {
        cell = [self licenseCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![cell isKindOfClass:[JTTableViewCell class]]) {
        return;
    }
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    
    if ((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0) || (indexPath.section == 0 && indexPath.row == 5))
    {
        [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(-1, 0, 0, 0) forDirectionMask:CKViewBorderDirectionBottom];
        [cell.contentView showBorderLineWithDirectionMask:CKViewBorderDirectionBottom];
        [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:CKViewBorderDirectionBottom];
    }
    else
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row != 3 || indexPath != 0)
            {
                return;
            }
        }
        jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 8, 0, 8);
        [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 1)
        {
            [MobClick event:@"rp326-1"];
            if (!self.insOrder.iscontainActivity)
            {
                [self jumpToChooseCouponVC];
            }
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp326-2"];
            [self jumpToChooseCouponVC];
        }
        
        ///取消支付宝，微信勾选
        [self.tableView reloadData];
    }
}

#pragma mark - TableViewCell
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
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *statusLb = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *tagLb = (UILabel *)[cell.contentView viewWithTag:1006];
    UIView *tagBg = (UIView *)[cell.contentView viewWithTag:1007];
    
    if (self.insOrder.iscontainActivity)
    {
        if (indexPath.row == 1) {
            
            label.text = self.insOrder.activityTag;
            tagLb.text = self.insOrder.activityName;
            [tagBg makeCornerRadius:3.0f];
            tagLb.hidden = !self.insOrder.activityName.length;
            tagBg.hidden = !self.insOrder.activityName.length;
            arrow.hidden = NO;
            
            NSDate * earlierDate;
            NSDate * laterDate;
            dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
            
            if (self.isSelectActivity)
            {
                statusLb.text = @"已选中";
                statusLb.textColor = HEXCOLOR(@"#fb4209");
                statusLb.hidden = NO;
            }
            else
            {
                statusLb.text = @"未使用";
                statusLb.textColor = HEXCOLOR(@"#aaaaaa");
                statusLb.hidden = YES;
            }
        }
        else
        {
            cell = [self setupInsuranceCouponForCell:cell];
        }
        
        if ((self.isSelectActivity && indexPath.row == 1) ||
            (self.couponType == CouponTypeInsurance && indexPath.row == 2))
        {
            [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
            boxB.selected = YES;
        }
        else
        {
            boxB.selected = NO;
        }
    }
    else
    {
        cell = [self setupInsuranceCouponForCell:cell];
        
        if ((self.couponType == CouponTypeInsurance && indexPath.row == 1))
        {
            [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
            boxB.selected = YES;
        }
        else
        {
            boxB.selected = NO;
        }
    }
    

    
    
    // checkBox 点击处理
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxDiscountGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                [self.checkBoxHelper removeItem:btn forGroupName:CheckBoxDiscountGroup];
                break;
            }
        }
    }
    @weakify(self);
    boxB.customObject = indexPath;
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxDiscountGroup withChangedBlock:^(id item, BOOL selected) {
        
        @strongify(self);
        boxB.selected = selected;
        
        if (self.insOrder.iscontainActivity)
        {
            if (indexPath.row == 1) {
                
                if (self.isSelectActivity)
                {
                    statusLb.text = @"已选中";
                    statusLb.textColor = HEXCOLOR(@"#fb4209");
                    statusLb.hidden = NO;
                }
                else
                {
                    statusLb.text = @"未使用";
                    statusLb.textColor = HEXCOLOR(@"#aaaaaa");
                    statusLb.hidden = YES;
                }
            }
            else
            {
                if (self.couponType == CouponTypeInsurance)
                {
                    statusLb.text = @"已选中";
                    statusLb.textColor = HEXCOLOR(@"#fb4209");
                    statusLb.hidden = NO;
                }
                else
                {
                    statusLb.text = @"未使用";
                    statusLb.textColor = HEXCOLOR(@"#aaaaaa");
                    statusLb.hidden = YES;
                }
            }
        }
        else
        {
            if (self.couponType == CouponTypeInsurance)
            {
                statusLb.text = @"已选中";
                statusLb.textColor = HEXCOLOR(@"#fb4209");
                statusLb.hidden = NO;
            }
            else
            {
                statusLb.text = @"未使用";
                statusLb.textColor = HEXCOLOR(@"#aaaaaa");
                statusLb.hidden = YES;
            }
        }

    }];
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        if (indexPath.row == 2)
        {
            if (!self.selectInsuranceCoupouArray.count)
            {
                [self jumpToChooseCouponVC];
                [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
            }
            else
            {
                if (self.couponType == CouponTypeInsurance)
                {
                    self.couponType = 0;
                    [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxDiscountGroup];
                }
                else
                {
                    HKCoupon * c = [self.selectInsuranceCoupouArray safetyObjectAtIndex:0];
                    self.couponType = c.conponType;
                    self.isSelectActivity = NO;
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
                }
            }
            
        }
        else if (indexPath.row == 1)
        {
            if (self.insOrder.iscontainActivity)
            {
                if (self.isSelectActivity)
                {
                    self.isSelectActivity = NO;
                    self.couponType = 0;
                    [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxDiscountGroup];
                }
                else
                {
                    self.isSelectActivity = YES;
                    self.couponType = 0;
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
                }
            }
            else
            {
                if (!self.selectInsuranceCoupouArray.count)
                {
                    [self jumpToChooseCouponVC];
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
                }
                else
                {
                    if (self.couponType == CouponTypeInsurance)
                    {
                        self.couponType = 0;
                        [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxDiscountGroup];
                    }
                    else
                    {
                        HKCoupon * c = [self.selectInsuranceCoupouArray safetyObjectAtIndex:0];
                        self.couponType = c.conponType;
                        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxDiscountGroup];
                    }
                }
            }
        }
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [self refreshPriceLb];
    }];
    
    return cell;
}

- (UITableViewCell *)paymentPlatformCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIImageView *iconV;
    UILabel *titleLb,*noteLb,*recommendLB;
    UIButton *boxB;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellA"];
    iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    titleLb = (UILabel *)[cell.contentView viewWithTag:1002];
    noteLb = (UILabel *)[cell.contentView viewWithTag:1004];
    boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    recommendLB = (UILabel *)[cell.contentView viewWithTag:1005];
    recommendLB.cornerRadius = 3.0f;
    recommendLB.layer.masksToBounds = YES;
    
    
    if (indexPath.row == 1) {
        iconV.image = [UIImage imageNamed:@"cw_alipay"];
        titleLb.text = @"支付宝支付";
        noteLb.text = @"推荐支付宝用户使用";
        recommendLB.hidden = NO;
    }
    else if (indexPath.row == 2) {
        if (gPhoneHelper.exsitWechat)
        {
            iconV.image = [UIImage imageNamed:@"cw_wechat"];
            titleLb.text = @"微信支付";
            noteLb.text = @"推荐微信用户使用";
        }
        else
        {
            iconV.image = [UIImage imageNamed:@"ins_uppay"];
            titleLb.text = @"银联支付";
            noteLb.text = @"推荐银联卡用户使用";
        }
        recommendLB.hidden = YES;
    }
    else if (indexPath.row == 3) {
        iconV.image = [UIImage imageNamed:@"ins_uppay"];
        titleLb.text = @"银联支付";
        noteLb.text = @"推荐银联卡用户使用";
        recommendLB.hidden = YES;
    }
    
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup];
    UIButton * removeBtn;
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                [self.checkBoxHelper removeItem:btn forGroupName:CheckBoxPlatformGroup];
                removeBtn = btn;
                break;
            }
        }
    }
    @weakify(self);
    boxB.customObject = indexPath;
    boxB.selected = removeBtn.selected;
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxPlatformGroup withChangedBlock:^(id item, BOOL selected) {
        
    }];
    
    @weakify(boxB)
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        
        NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup];
        [array enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
            
            obj.selected = NO;
        }];
        
        @strongify(boxB)
        boxB.selected = YES;
        if (indexPath.row == 1){
            [MobClick event:@"rp326-3"];
        }
        else if (indexPath.row == 2){
            if (gPhoneHelper.exsitWechat) {
                [MobClick event:@"rp326-4"];
            }
            else {
                [MobClick event:@"rp326-5"];
            }
        }
        else{
            [MobClick event:@"rp326-5"];
        }
    }];

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

    //选择框
    @weakify(checkB);
    [[[checkB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         
         @strongify(checkB);
         BOOL checked = ![data.customInfo[@"check"] boolValue];
         data.customInfo[@"check"] = @(checked);
         checkB.selected = checked;
         self.payBtn.enabled = checked;
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
- (void)requestGetUserInsCoupon
{
    [[gAppMgr.myUser.couponModel rac_getVaildInsuranceCoupon:self.insOrder.orderid] subscribeNext:^(GetInscouponOp * op) {
        
        self.isLoadingResourse = NO;
        
        [self selectDefaultCoupon];
        
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
    if (gAppMgr.myUser.couponModel.validInsuranceCouponArray.count)
    {
        for (NSInteger i = 0 ; i < gAppMgr.myUser.couponModel.validInsuranceCouponArray.count ; i++)
        {
            HKCoupon * coupon = [gAppMgr.myUser.couponModel.validInsuranceCouponArray safetyObjectAtIndex:i];
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
    [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxDiscountGroup];
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

- (UITableViewCell *)setupInsuranceCouponForCell:(UITableViewCell * )cell
{
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *statusLb = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *tagLb = (UILabel *)[cell.contentView viewWithTag:1006];
    UIView *tagBg = (UIView *)[cell.contentView viewWithTag:1007];
    
    tagLb.hidden = YES;
    tagBg.hidden = YES;
    
    label.text = [NSString stringWithFormat:@"保险代金券：%ld张", (long)gAppMgr.myUser.couponModel.validInsuranceCouponArray.count];
    arrow.hidden = NO;
    
    NSDate * earlierDate;
    NSDate * laterDate;
    for (HKCoupon * c in gAppMgr.myUser.couponModel.validInsuranceCouponArray)
    {
        earlierDate = [c.validsince earlierDate:earlierDate];
        laterDate = [c.validthrough laterDate:laterDate];
    }
    dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
    
    if (self.couponType == CouponTypeInsurance)
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
    return cell;
}

- (void)jumpToChooseCouponVC
{
    ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
    vc.type = CouponTypeInsurance;
    vc.selectedCouponArray = self.selectInsuranceCoupouArray;
    vc.couponArray = gAppMgr.myUser.couponModel.validInsuranceCouponArray;
    vc.numberLimit = 1;
    vc.upperLimit = self.insOrder.totoalpay;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
