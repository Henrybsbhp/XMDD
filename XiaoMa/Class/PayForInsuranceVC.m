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
#import "InsuranceResultVC.h"
#import "PaymentHelper.h"
#import "InsuranceOrderPaidSuccessOp.h"

#define CheckBoxDiscountGroup @"CheckBoxDiscountGroup"
#define CheckBoxPlatformGroup @"CheckBoxPlatformGroup"

@interface PayForInsuranceVC ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@property (nonatomic,strong) CKSegmentHelper *checkBoxHelper;
@property (nonatomic)BOOL isLoadingResourse;

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
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
    UILabel *label = (UILabel *)[self.bottomView viewWithTag:1001];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:@"总计："
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr1];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%.2f", self.insOrder.policy.premium]
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],
                                                                                NSForegroundColorAttributeName:HEXCOLOR(@"#fb4209")}];
    [str appendAttributedString:attrStr2];
    label.attributedText = str;
}

#pragma mark - Action
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
            [self postCustomNotificationName:kNotifyRefreshInsuranceOrders object:nil];
            InsuranceResultVC *resultVC = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"InsuranceResultVC"];
            resultVC.originVC = self.originVC;
            resultVC.orderID = self.insOrder.orderid;
            [resultVC setResultType:PaySuccess];
            [self.navigationController pushViewController:resultVC animated:YES];
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
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    NSString * info = [NSString stringWithFormat:@"保险订单: %@",self.insOrder.licencenumber];
    NSString *text;
    switch (op.req_paychannel) {
        case PaymentChannelAlipay: {
            text = @"订单生成成功,正在跳转到支付宝平台进行支付";
            [helper resetForAlipayWithTradeNumber:op.rsp_tradeno productName:info productDescription:info price:op.rsp_total];
        } break;
        case PaymentChannelWechat: {
            text = @"订单生成成功,正在跳转到微信平台进行支付";
            [helper resetForWeChatWithTradeNumber:op.rsp_tradeno productName:info price:op.rsp_total];
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
        [self postCustomNotificationName:kNotifyRefreshInsuranceOrders object:nil];
        InsuranceResultVC *resultVC = [insuranceStoryboard instantiateViewControllerWithIdentifier:@"InsuranceResultVC"];
        [resultVC setResultType:PaySuccess];
        resultVC.originVC = self.originVC;
        resultVC.orderID = self.insOrder.orderid;
        [self.navigationController pushViewController:resultVC animated:YES];
        
        InsuranceOrderPaidSuccessOp *iop = [[InsuranceOrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 1;
        iop.req_tradeno = op.rsp_tradeno;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"已通知服务器支付成功!");
        }];
    } error:^(NSError *error) {
        
        [gToast showError:@"订单支付失败"];
    }];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            height = 76;
        }
        else if (indexPath.row == 3){
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
        count = 4;
    }
    else if (section == 1) {
        
        count = 3 - (self.insOrder.iscontainActivity ? 0 : 1);
    }
    else if (section == 2) {
        count = 4 - (gPhoneHelper.exsitWechat ? 0:1);
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    
    if ((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0))
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
    
    [logoV setImageByUrl:self.insOrder.picUrl withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
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
        titleL.text = [NSString stringWithFormat:@"保险期限"];
        infoL.textColor = HEXCOLOR(@"#fb4209");
        infoL.text = self.insOrder.validperiod;
    }
    else if (indexPath.row == 3) {
        titleL.text = [NSString stringWithFormat:@"共计保费"];
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
    
    if (self.insOrder.iscontainActivity)
    {
        if (indexPath.row == 1) {
            
            label.text = self.insOrder.activityTag;
            tagLb.text = self.insOrder.activityName;
            // TODO @fq
            tagLb.cornerRadius = 3.0f;
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
//            [MobClick event:@"rp108-1"];
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
        
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        [self refreshPriceLb];
    }];
    
    return cell;
}

- (UITableViewCell *)paymentPlatformCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIImageView *iconV;
    UILabel *titleLb,*noteLb;
    UIButton *boxB;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellA"];
    iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    titleLb = (UILabel *)[cell.contentView viewWithTag:1002];
    noteLb = (UILabel *)[cell.contentView viewWithTag:1004];
    boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    
    
    if (indexPath.row == 1) {
        iconV.image = [UIImage imageNamed:@"cw_alipay"];
        titleLb.text = @"支付宝支付";
        noteLb.text = @"推荐支付宝用户使用";
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
            iconV.image = [UIImage imageNamed:@"cw_creditcard"];
            titleLb.text = @"银联支付";
            noteLb.text = @"推荐银联卡用户使用";
        }
    }
    else if (indexPath.row == 3) {
        iconV.image = [UIImage imageNamed:@"cw_creditcard"];
        titleLb.text = @"银联支付";
        noteLb.text = @"推荐银联卡用户使用";
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
    
    tagLb.hidden = YES;
    
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
