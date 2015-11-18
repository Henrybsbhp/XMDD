//
//  PaymentCenterViewController.m
//  XiaoMa
//
//  Created by jt on 15/11/16.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "PaymentCenterViewController.h"
#import "DetailWebVC.h"
#import "HKBankCard.h"
#import "PaymentHelper.h"

#import "GetGeneralOrderdetailOp.h"
#import "GetGeneralUnionpayTradenoOp.h"
#import "OrderPaidSuccessOp.h"
#import "GetGeneralActivityLefttimeOp.h"

#import <POP.h>


@interface PaymentCenterViewController()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomBtn;

@property (nonatomic,strong)GetGeneralOrderdetailOp * getGeneralOrderdetailOp;

@property (nonatomic,strong)NSArray * paymentArray;
///支付渠道
@property (nonatomic)PaymentChannelType  paychannel;
@end


@implementation PaymentCenterViewController

- (void)dealloc
{
    DebugLog(@"PaymentCenterViewController dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.paychannel = PaymentChannelAlipay;
    
    [self setupUI];
    [self requestOrderDetail];
}

- (void)setupUI
{
    [self setupPayBtn];
    [self setupNavigationBar];
}

- (void)setupNavigationBar
{
    self.navigationItem.title = @"支付确认";
    
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;

}

- (void)setupPayBtn
{
    @weakify(self)
    [[self.payBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        GetGeneralActivityLefttimeOp * lefttimeOp = [[GetGeneralActivityLefttimeOp alloc] init];
        lefttimeOp.tradeType = self.tradeType;
        [[[lefttimeOp rac_postRequest] initially:^{
            
            [gToast showingWithText:@"支付信息获取中..."];
        }] subscribeNext:^(GetGeneralActivityLefttimeOp * rop) {
            
            [gToast dismiss];
            if (rop.rsp_lefttime)
            {
                @strongify(self)
                [self actionPay];
            }
            else
            {
                [gToast showError:@"该活动已结束"];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } error:^(NSError *error) {
            
            [gToast showError:@"该活动已结束"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

- (void)requestOrderDetail
{
    GetGeneralOrderdetailOp * op = [[GetGeneralOrderdetailOp alloc] init];
    self.getGeneralOrderdetailOp = op;
    op.tradeNo = self.tradeNo;
    op.tradeType = self.tradeType;
    [[[op rac_postRequest]  initially:^{
        
        [gToast showingWithText:@"获取订单信息中..." inView:self.view];
        self.tableView.hidden = YES;
        self.bottomBtn.hidden = YES;
    }] subscribeNext:^(GetGeneralOrderdetailOp * rop) {
        
        [self handlePaymentArray];
        [gToast dismissInView:self.view];
        self.bottomBtn.hidden = NO;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        
        NSString * bottomTitle = [NSString stringWithFormat:@"您只需支付%@元，现在支付",[NSString formatForPrice:self.getGeneralOrderdetailOp.rsp_fee]];
        [self.payBtn setTitle:bottomTitle forState:UIControlStateNormal];
        
    } error:^(NSError *error) {
        
        self.tableView.hidden = YES;
        self.bottomBtn.hidden = YES;
        [gToast dismissInView:self.view];
        
        @weakify(self)
        [self.view showDefaultEmptyViewWithText:@"订单信息获取失败，点击重试" centerOffset:0 tapBlock:^{
            
            @strongify(self)
            [self.view hideDefaultEmptyView];
            [self requestOrderDetail];
        }];
    }];
}


- (void)actionBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionPay
{
    [self.paymentArray enumerateObjectsUsingBlock:^(NSMutableDictionary *d, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton * btn = [d objectForKey:@"btn"];
        if (btn && [btn isKindOfClass:[UIButton class]])
        {
            if (btn.selected)
            {
                self.paychannel = [[d objectForKey:@"paymentType"] integerValue];
                *stop = YES;
            }
        }
    }];
    NSString * tradeno = self.getGeneralOrderdetailOp.tradeNo;
//    NSString * tradetype = self.getGeneralOrderdetailOp.tradeType;
    CGFloat fee = self.getGeneralOrderdetailOp.rsp_fee;
    NSString * productName = self.getGeneralOrderdetailOp.rsp_prodname;
    NSString * submitTime = [[NSDate date] dateFormatForDT8];
    // 如果是银联支付需要请求服务器得到银联流水号
    if (self.getGeneralOrderdetailOp.rsp_fee)
    {
        if (self.paychannel == PaymentChannelUPpay)
        {
            [self requestGetUppayTradenoWithTradeNo:tradeno];
        }
        else if (self.paychannel == PaymentChannelAlipay)
        {
            [self requestAliPay:nil andTradeId:tradeno andPrice:fee andProductName:productName andDescription:productName andTime:submitTime];
        }
        else if (self.paychannel == PaymentChannelWechat)
        {
            [self requestWechatPay:nil andTradeId:tradeno andPrice:fee andProductName:productName andTime:submitTime];
        }
    }
    else
    {
        @weakify(self)
        [self dismissViewControllerAnimated:YES completion:^{
            
            @strongify(self)
            [self actionPaySuccess];
        }];
    }
}

- (void)actionPaySuccess
{
    if (self.originVc && [self.originVc isKindOfClass:[UINavigationController class]])
    {
        UINavigationController * naviVc = (UINavigationController *)self.originVc;
        NSArray * viewControllers = naviVc.viewControllers;
        UIViewController * lastVc = [viewControllers safetyObjectAtIndex:viewControllers.count - 1];
        if ([lastVc isKindOfClass:[DetailWebVC class]])
        {
            NSString * url = [NSString stringWithFormat:@"%@?token=%@&tradeno=%@&tradetype=%@&status=%@",
                              PayCenterNotifyUrl,gNetworkMgr.token,self.tradeNo,self.tradeType,@"S"];
            DetailWebVC * detailWebVc = (DetailWebVC *)lastVc;
            [detailWebVc requestUrl:url];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 44;
    if (indexPath.section == 0){
        
        height = 110;
    }
    else
    {
        if (indexPath.row == 0)
        {
            height = 35;
        }
        else
        {
            height = 44;
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
        count = 1;
    }
    else
    {
        count = self.paymentArray.count + 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [self tableView:tableView orderTitleCellForRowAtIndexPath:indexPath];
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell = [self tableView:tableView paymentTitleCellForRowAtIndexPath:indexPath];
        }
        else
        {
            cell = [self tableView:tableView paymentCellForRowAtIndexPath:indexPath];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView orderTitleCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OrderTitleCell"];
    UIImageView * imageView = (UIImageView *)[cell searchViewWithTag:1001];
    UILabel * titleLb = (UILabel *)[cell searchViewWithTag:1002];
    UILabel * subTilteLb = (UILabel *)[cell searchViewWithTag:1003];
    UILabel * originLb = (UILabel *)[cell searchViewWithTag:1004];
    UILabel * couponLb = (UILabel *)[cell searchViewWithTag:1005];
    UILabel * feeLb = (UILabel *)[cell searchViewWithTag:1006];
    
    [imageView setImageByUrl:self.getGeneralOrderdetailOp.rsp_prodlogo withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    titleLb.text = self.getGeneralOrderdetailOp.rsp_prodname;
    subTilteLb.text = self.getGeneralOrderdetailOp.rsp_proddesc;
    
    if (self.getGeneralOrderdetailOp.rsp_originprice)
    {
        NSString * origin = [NSString stringWithFormat:@"原价￥%@",[NSString formatForPrice:self.getGeneralOrderdetailOp.rsp_originprice]];
        originLb.attributedText = [self attributeDeleteLine:origin];
    }
    originLb.hidden = !self.getGeneralOrderdetailOp.rsp_originprice;
    
    if (self.getGeneralOrderdetailOp.rsp_originprice)
    {
        NSString * couponStr = [NSString stringWithFormat:@"帮你省了%@",[NSString formatForPrice:self.getGeneralOrderdetailOp.rsp_couponprice]];
        couponLb.text = couponStr;
    }
    couponLb.hidden = !self.getGeneralOrderdetailOp.rsp_originprice;
    
    feeLb.attributedText = [self priceStringWithPrice:self.getGeneralOrderdetailOp.rsp_fee];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView paymentTitleCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherInfoCell"];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView paymentCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIImageView *iconV;
    UILabel *titleLb,*noteLb;
    UIButton *boxB;
    
    NSMutableDictionary * dict = [self.paymentArray safetyObjectAtIndex:indexPath.row -1];
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellA"];
    iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    titleLb = (UILabel *)[cell.contentView viewWithTag:1002];
    noteLb = (UILabel *)[cell.contentView viewWithTag:1004];
    boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    
    [boxB setImage:[UIImage imageNamed:@"cw_box2"] forState:UIControlStateNormal];
    [boxB setImage:[UIImage imageNamed:@"cw_box3"] forState:UIControlStateSelected];
    [boxB setImage:[UIImage imageNamed:@"cw_box3"] forState:UIControlStateHighlighted];
    
    iconV.image = [UIImage imageNamed:dict[@"logo"]];
    titleLb.text = dict[@"title"];
    noteLb.text = dict[@"subTitle"];
    
    
    UIButton * btn = [dict objectForKey:@"btn"];
    if (!btn)
    {
        boxB.customObject = indexPath;
        [dict safetySetObject:boxB forKey:@"btn"];
    }
    else
    {
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                btn = boxB;
            }
        }
    }
    
    boxB.selected = [dict[@"paymentType"] integerValue] == self.paychannel;
    
    @weakify(boxB)
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        [self.paymentArray enumerateObjectsUsingBlock:^(NSMutableDictionary *d, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIButton * btn = [d objectForKey:@"btn"];
            if (btn && [btn isKindOfClass:[UIButton class]])
            {
                btn.selected = NO;
            }
        }];
        
        @strongify(boxB)
        boxB.selected = YES;
    }];
    
    return cell;
}


#pragma mark - Utilitly
- (NSAttributedString *)attributeDeleteLine:(NSString *)oStr
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:oStr attributes:attr1];
    [str appendAttributedString:attrStr1];
    
    return str;
}

- (NSAttributedString *)priceStringWithPrice:(CGFloat)price
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
    NSString * p = [NSString stringWithFormat:@"实付"];
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:p attributes:attr1];
    [str appendAttributedString:attrStr1];
    
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                            NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
    NSString * p2 = [NSString stringWithFormat:@"￥%@", [NSString formatForPrice:price]];
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:p2 attributes:attr2];
    
    [str appendAttributedString:attrStr2];
    return str;
}

- (void)handlePaymentArray
{
    NSMutableArray * tArray = [NSMutableArray array];
    
    for (NSNumber * paychannel in self.getGeneralOrderdetailOp.rsp_paychannels)
    {
        NSString * paychannelStr = [NSString stringWithFormat:@"%@",paychannel];
        if ([paychannelStr isEqualToString:@"2"])
        {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                          @{@"paymentType":@(PaymentChannelAlipay),
                                            @"title":@"支付宝支付",
                                            @"subTitle":@"推荐支付宝用户使用",
                                            @"logo":@"cw_alipay"}];
            [tArray safetyAddObject:dict];
        }
        else if ([paychannelStr isEqualToString:@"3"])
        {
            if (gPhoneHelper.exsitWechat)
            {
                NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                              @{@"paymentType":@(PaymentChannelWechat),
                                                @"title":@"微信支付",
                                                @"subTitle":@"推荐微信用户使用",
                                                @"logo":@"cw_wechat"}];
                [tArray safetyAddObject:dict];
            }
        }
        else if ([paychannelStr isEqualToString:@"7"])
        {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                          @{@"paymentType":@(PaymentChannelXMDDCreditCard),
                                            @"title":@"浙商支付",
                                            @"subTitle":@"推荐浙商信用卡用户使用",
                                            @"logo":@"cw_creditcard"}];
            [tArray safetyInsertObject:dict atIndex:0];
        }
        else if ([paychannelStr isEqualToString:@"8"])
        {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:
                                          @{@"paymentType":@(PaymentChannelUPpay),
                                            @"title":@"银联支付",
                                            @"subTitle":@"推荐银联用户使用",
                                            @"logo":@"ins_uppay"}];
            [tArray safetyAddObject:dict];
        }
    }
    self.paymentArray = [NSArray arrayWithArray:tArray];
}



- (void)requestAliPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
             andPrice:(CGFloat)price andProductName:(NSString *)name andDescription:(NSString *)desc andTime:(NSString *)time
{
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    [helper resetForAlipayWithTradeNumber:tradeId productName:name productDescription:desc price:price];
    
    [[helper rac_startPay] subscribeNext:^(id x) {
        
        OrderPaidSuccessOp *iop = [[OrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 4;
        iop.req_tradeno = tradeId;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"通用订单通知服务器支付成功!");
        }];
        
        @weakify(self)
        [self dismissViewControllerAnimated:YES completion:^{
            
            @strongify(self)
            [self actionPaySuccess];
        }];
        
    } error:^(NSError *error) {
        
        [gToast showError:@"订单支付失败"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)requestWechatPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
                andPrice:(CGFloat)price andProductName:(NSString *)name
                 andTime:(NSString *)time
{
    PaymentHelper *helper = [[PaymentHelper alloc] init];
    [helper resetForWeChatWithTradeNumber:tradeId productName:name price:price];
    [[helper rac_startPay] subscribeNext:^(NSString * info) {
        
        OrderPaidSuccessOp *iop = [[OrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 4;
        iop.req_tradeno = tradeId;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"通用订单通知服务器支付成功!");
        }];
        
        @weakify(self)
        [self dismissViewControllerAnimated:YES completion:^{
            
            @strongify(self)
            [self actionPaySuccess];
        }];
        
    } error:^(NSError *error) {
        
        [gToast showError:@"订单支付失败"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)requestGetUppayTradenoWithTradeNo:(NSString *)tradeId
{
    GetGeneralUnionpayTradenoOp * op = [[GetGeneralUnionpayTradenoOp alloc] init];
    op.tradeNo = self.tradeNo;
    op.tradeType = self.tradeType;
    [[[op rac_postRequest] flattenMap:^RACStream *(GetGeneralUnionpayTradenoOp * rop) {
        
        PaymentHelper *helper = [[PaymentHelper alloc] init];
        [helper resetForUPPayWithTradeNumber:rop.rsp_uniontradeno targetVC:self];
        return [helper rac_startPay];
    }] subscribeNext:^(NSString * uppayTradeNo) {
        
        OrderPaidSuccessOp *iop = [[OrderPaidSuccessOp alloc] init];
        iop.req_notifytype = 4;
        iop.req_tradeno = tradeId;
        [[iop rac_postRequest] subscribeNext:^(id x) {
            DebugLog(@"通用订单通知服务器支付成功!");
        }];
        
        @weakify(self)
        [self dismissViewControllerAnimated:YES completion:^{
            
            @strongify(self)
            [self actionPaySuccess];
        }];
    } error:^(NSError *error) {
        
        [gToast showError:@"订单支付失败"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}


@end
