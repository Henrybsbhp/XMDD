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
#import "ChooseCarwashTicketVC.h"
#import "ChooseBankCardVC.h"
#import "CarListVC.h"
#import "EditCarVC.h"
#import "CarwashFreshmanGuideVC.h"

#import "GetUserCarOp.h"
#import "GetUserResourcesV2Op.h"
#import "SystemFastrateGetOp.h"
#import "CheckoutServiceOrderV4Op.h"
#import "OrderPaidSuccessOp.h"

#import "GainUserAwardOp.h"
#import "FMDeviceManager.h"


#define CheckBoxCouponGroup @"CheckBoxCouponGroup"
#define CheckBoxPlatformGroup @"CheckBoxPlatformGroup"


@interface PayForWashCarVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *bottomScrollLb;
@property (nonatomic,strong)UIView * drawerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;

@property (nonatomic,strong) CKSegmentHelper *checkBoxHelper;
@property (nonatomic)BOOL isLoadingResourse;

@property (nonatomic,strong) MyCarStore *carStore;

@property (nonatomic,strong)CheckoutServiceOrderV4Op *checkoutServiceOrderV4Op;
@property (nonatomic,strong)GetUserResourcesV2Op * getUserResourcesV2Op;

///支付数据源
@property (nonatomic,strong)NSArray * paymentArray;

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
    
    [self setupCheckBoxHelper];
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
- (void)setupPaymentArray
{
    if (gAppMgr.myUser.couponModel.validCZBankCreditCard.count)
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


- (void)setupCheckBoxHelper
{
    self.checkBoxHelper = [CKSegmentHelper new];
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
    self.bottomScrollLb.textColor = [UIColor colorWithHex:@"#FF5A00" alpha:1.0f];
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
        
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:@"您尚未添加爱车，请先添加 " delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往添加", nil];
        [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
            
            NSInteger index =[number integerValue];
            if (index == 1)
            {
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
        [av show];
        return;
    }
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"支付确认" message:@"请务必到店享受服务，且与店员确认服务商家与软件当前支付商家一致后再付款，付完不退款" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
        
        NSInteger index =[number integerValue];
        if (index == 1)
        {
            [self requestCheckoutWithCouponType:self.couponType];
        }
    }];
    [av show];
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
            height = 36;
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
        count = 3;
    }
    else if (section == 2) {
        count = self.paymentArray.count + 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [self shopTitleCellAtIndexPath:indexPath];
        }
        else if (indexPath.row == 3) {
            cell = [self carCellAtIndexPath:indexPath];
        }
        else {
            cell = [self shopItemCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0)
        {
            cell = [self DiscountInfoCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self paymentTypeCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0)
        {
            cell = [self OtherInfoCellAtIndexPath:indexPath];
        }
        else
        {
            cell = [self paymentPlatformACellAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    
    if ((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && indexPath.row == 0))
    {
        [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(-1, 0, 0, 0) forDirectionMask:CKViewBorderDirectionBottom] ;
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
    if (indexPath.section == 0){
        if (indexPath.row == 3) {
            
            [MobClick event:@"rp108_10"];//车牌
            CarListVC *vc = [UIStoryboard vcWithId:@"CarListVC" inStoryboard:@"Car"];
            vc.title = @"选择爱车";
            vc.model.allowAutoChangeSelectedCar = YES;
            vc.model.disableEditingCar = YES;
            vc.model.currentCar = self.defaultCar;
            vc.model.originVC = self;
            [vc.model setFinishBlock:^(HKMyCar *curSelectedCar) {
                self.defaultCar = curSelectedCar;
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 1)
        {
            //点击查看洗车券
            [MobClick event:@"rp108_2"];
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
            vc.originVC = self.originVC;
            vc.type = CouponTypeCarWash;
            vc.selectedCouponArray = self.selectCarwashCoupouArray;
            vc.couponArray = self.getUserResourcesV2Op.validCarwashCouponArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (indexPath.row == 2)
        {
            [MobClick event:@"rp108_4"];
            ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
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
            vc.bankCards = gAppMgr.myUser.couponModel.validCZBankCreditCard;
            vc.carwashCouponArray = self.getUserResourcesV2Op.validCarwashCouponArray;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (payChannel == PaymentChannelAlipay)
        {
            /// 如果是浙商，无法选择
            if (self.couponType == CouponTypeCZBankCarWash)
            {
                return;
            }
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if (payChannel == PaymentChannelWechat)
        {
            /// 如果是浙商，无法选择
            if (self.couponType == CouponTypeCZBankCarWash)
            {
                return;
            }
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelWechat;
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
    logoV.cornerRadius = 5.0f;
    logoV.layer.masksToBounds = YES;
    
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
        infoL.textColor = HEXCOLOR(@"#505050");
        infoL.text = self.service.serviceName;
    }
    else if (indexPath.row == 2) {
        titleL.text = [NSString stringWithFormat:@"项目价格"];
        infoL.textColor = HEXCOLOR(@"#fb4209");
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
        infoL.textColor = HEXCOLOR(@"#505050");
        infoL.text = car.licencenumber ? car.licencenumber : @"";
    }];
    
    return cell;
}


- (UITableViewCell *)paymentTypeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentTypeCell"];
    
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1001];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1002];
    UIImageView *arrow = (UIImageView *)[cell.contentView viewWithTag:1003];
    UILabel *dateLb = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *statusLb = (UILabel *)[cell.contentView viewWithTag:1005];
    
    if (indexPath.row == 1) {
        label.text = [NSString stringWithFormat:@"洗车券：%ld张", (long)self.getUserResourcesV2Op.validCarwashCouponArray.count];
        arrow.hidden = NO;
        
        NSDate * earlierDate;
        NSDate * laterDate;
        for (HKCoupon * c in self.getUserResourcesV2Op.validCarwashCouponArray)
        {
            earlierDate = [c.validsince earlierDate:earlierDate];
            laterDate = [c.validthrough laterDate:laterDate];
        }
        dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
        
        if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
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
    else if (indexPath.row == 2) {
        label.text = [NSString stringWithFormat:@"代金券：%ld张", (long)self.getUserResourcesV2Op.validCashCouponArray.count];
        arrow.hidden = NO;
        
        NSDate * earlierDate;
        NSDate * laterDate;
        for (HKCoupon * c in self.getUserResourcesV2Op.validCashCouponArray)
        {
            earlierDate = [c.validsince earlierDate:earlierDate];
            laterDate = [c.validthrough laterDate:laterDate];
        }
        dateLb.text = [NSString stringWithFormat:@"有效期：%@ - %@",earlierDate ? [earlierDate dateFormatForYYMMdd2] : @"",laterDate ? [laterDate dateFormatForYYMMdd2] : @""];
        
        if (self.couponType == CouponTypeCash)
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
    
    if ((self.couponType == CouponTypeCarWash && indexPath.row == 1) ||
        (self.couponType == CouponTypeCZBankCarWash && indexPath.row == 1) ||
        (self.couponType == CouponTypeCash && indexPath.row == 2))
    {
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
        boxB.selected = YES;
    }
    else
    {
        boxB.selected = NO;
    }
    
    // checkBox 点击处理
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxCouponGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                [self.checkBoxHelper removeItem:btn forGroupName:CheckBoxCouponGroup];
                break;
            }
        }
    }
    @weakify(self);
    boxB.customObject = indexPath;
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxCouponGroup withChangedBlock:^(id item, BOOL selected) {
        
        @strongify(self);
        boxB.selected = selected;
        if ((self.couponType == CouponTypeCarWash && indexPath.row == 1) ||
            (self.couponType == CouponTypeCZBankCarWash && indexPath.row == 1) ||
            (self.couponType == CouponTypeCash && indexPath.row == 2))
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
    }];
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        if (indexPath.row == 1)
        {
            [MobClick event:@"rp108_1"];
            if (!self.selectCarwashCoupouArray.count)
            {
                ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                vc.selectedCouponArray = self.selectCarwashCoupouArray;
                vc.type = CouponTypeCarWash;//@fq
                vc.couponArray = self.getUserResourcesV2Op.validCarwashCouponArray;
                [self.navigationController pushViewController:vc animated:YES];
                [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
            }
            else
            {
                if (self.couponType == CouponTypeCarWash || self.couponType == CouponTypeCZBankCarWash)
                {
                    self.couponType = 0;
                    [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxCouponGroup];
                }
                else
                {
                    HKCoupon * c = [self.selectCarwashCoupouArray safetyObjectAtIndex:0];
                    self.couponType = c.conponType;
                    if (self.couponType == CouponTypeCZBankCarWash){
                        self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
                    }
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
                }
            }
            
        }
        else if (indexPath.row == 2)
        {
            NSLog(@"click checkbox2");
            [MobClick event:@"rp108_3"];
            if (!self.selectCashCoupouArray.count)
            {
                ChooseCarwashTicketVC *vc = [UIStoryboard vcWithId:@"ChooseCarwashTicketVC" inStoryboard:@"Carwash"];
                vc.originVC = self.originVC;
                vc.selectedCouponArray = self.selectCashCoupouArray;
                vc.type = CouponTypeCash;
                vc.couponArray = self.getUserResourcesV2Op.validCashCouponArray;
                [self.navigationController pushViewController:vc animated:YES];
                [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
            }
            else
            {
                if (self.couponType == CouponTypeCash)
                {
                    self.couponType = 0;
                    [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxCouponGroup];
                }
                else
                {
                    self.couponType = CouponTypeCash;
                    [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxCouponGroup];
                }
                
            }
        }
        
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
        [self refreshPriceLb];
    }];
    
    return cell;
}

- (UITableViewCell *)paymentPlatformACellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    UIImageView *iconV,*drawerIV;
    UILabel *titleLb,*noteLb,*numberLb,*recommendLB;
    UIButton *boxB;
    UIView * drawerV;
    
    
    PaymentChannelType payChannel = [[self.paymentArray safetyObjectAtIndex:indexPath.row - 1] integerValue];
    if (payChannel == PaymentChannelCZBCreditCard)
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellB"];
        iconV = (UIImageView *)[cell searchViewWithTag:1001];
        titleLb = (UILabel *)[cell searchViewWithTag:1002];
        noteLb = (UILabel *)[cell searchViewWithTag:1004];
        drawerV = (UIView *)[cell searchViewWithTag:104];
        boxB = (UIButton *)[cell searchViewWithTag:20401];
        drawerIV = (UIImageView *)[cell  searchViewWithTag:20402];
        numberLb = (UILabel *)[cell searchViewWithTag:20403];
        self.drawerView = drawerV;
        drawerIV.image = [UIImage imageNamed:@"mini_card"];
        numberLb.text = [self.selectBankCard.cardNumber substringFromIndex:self.selectBankCard.cardNumber.length - 4];
        if (!gAppMgr.myUser.couponModel.validCZBankCreditCard.count)
        {
            [boxB setImage:[UIImage imageNamed:@"cw_box2"] forState:UIControlStateNormal];
            [boxB setImage:[UIImage imageNamed:@"cw_box3"] forState:UIControlStateSelected];
            [boxB setImage:[UIImage imageNamed:@"cw_box3"] forState:UIControlStateHighlighted];
            drawerIV.hidden = YES;
        }
        else
        {
            [boxB setImage:[UIImage imageNamed:@"cw_box4"] forState:UIControlStateNormal];
            [boxB setImage:[UIImage imageNamed:@"cw_box5"] forState:UIControlStateSelected];
            [boxB setImage:[UIImage imageNamed:@"cw_box5"] forState:UIControlStateHighlighted];
            drawerIV.hidden = NO;
        }
    }
    else
    {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatformCellA"];
        iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
        titleLb = (UILabel *)[cell.contentView viewWithTag:1002];
        noteLb = (UILabel *)[cell.contentView viewWithTag:1004];
        boxB = (UIButton *)[cell.contentView viewWithTag:1003];
        recommendLB = (UILabel *)[cell.contentView viewWithTag:1005];
        recommendLB.cornerRadius = 3.0f;
        recommendLB.layer.masksToBounds = YES;
        //        boxB.selected = NO;
    }
    
    if (payChannel == PaymentChannelCZBCreditCard) {
        iconV.image = [UIImage imageNamed:@"cw_creditcard"];
        titleLb.text = @"信用卡支付";
        noteLb.text = @"推荐浙商银行汽车卡用户使用";
        recommendLB.hidden = YES;
        titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
        boxB.enabled = gAppMgr.myUser.couponModel.validCZBankCreditCard.count;
    }
    else if (payChannel == PaymentChannelAlipay) {
        iconV.image = [UIImage imageNamed:@"cw_alipay"];
        titleLb.text = @"支付宝支付";
        noteLb.text = @"推荐支付宝用户使用";
        recommendLB.hidden = NO;
        if (self.couponType == CouponTypeCZBankCarWash)
        {
            titleLb.textColor = [UIColor lightGrayColor];
            boxB.enabled = NO;
        }
        else
        {
            titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
            boxB.enabled = YES;
        }
    }
    else if (payChannel == PaymentChannelWechat) {
        iconV.image = [UIImage imageNamed:@"cw_wechat"];
        titleLb.text = @"微信支付";
        noteLb.text = @"推荐微信用户使用";
        recommendLB.hidden = YES;
        if (self.couponType == CouponTypeCZBankCarWash)
        {
            titleLb.textColor = [UIColor lightGrayColor];
            boxB.enabled = NO;
        }
        else
        {
            titleLb.textColor = [UIColor colorWithHex:@"#323232" alpha:1.0f];
            boxB.enabled = YES;
        }
    }
    NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup];
    for (NSInteger i = 0 ; i < array.count ; i++)
    {
        UIButton * btn = [array safetyObjectAtIndex:i];
        if ([btn.customObject isKindOfClass:[NSIndexPath class]])
        {
            NSIndexPath * path = (NSIndexPath *)btn.customObject;
            if (path.section == indexPath.section && path.row == indexPath.row)
            {
                [self.checkBoxHelper removeItem:btn forGroupName:CheckBoxPlatformGroup];
                break;
            }
        }
    }
    @weakify(self);
    boxB.customObject = indexPath;
    [self.checkBoxHelper addItem:boxB forGroupName:CheckBoxPlatformGroup withChangedBlock:^(id item, BOOL selected) {
        
        boxB.selected = selected;
    }];
    
    @weakify(boxB)
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxPlatformGroup];
        NSArray * array = [self.checkBoxHelper itemsForGroupName:CheckBoxPlatformGroup];
        [array enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL *stop) {
            
            obj.selected = NO;
        }];
        
        @strongify(boxB)
        boxB.selected = YES;
        if (payChannel == PaymentChannelCZBCreditCard)
        {
            [MobClick event:@"rp108_11"];
            [self popBankCardNumberAnimation:YES];
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
        }
        else if (payChannel == PaymentChannelAlipay)
        {
            [MobClick event:@"rp108_5"];
            [self popBankCardNumberAnimation:NO];
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
        }
        else if (payChannel == PaymentChannelWechat)
        {
            [MobClick event:@"rp108_6"];
            [self popBankCardNumberAnimation:NO];
            self.checkoutServiceOrderV4Op.paychannel = PaymentChannelWechat;
        }
    }];
    
    if ((payChannel == PaymentChannelCZBCreditCard && self.checkoutServiceOrderV4Op.paychannel == PaymentChannelCZBCreditCard) ||
        (payChannel == PaymentChannelAlipay && self.checkoutServiceOrderV4Op.paychannel == PaymentChannelAlipay)||
        (payChannel == PaymentChannelWechat && self.checkoutServiceOrderV4Op.paychannel == PaymentChannelWechat))
    {
        if (payChannel == PaymentChannelCZBCreditCard){
            
            [self popBankCardNumberAnimation:YES];
        }
        else{
            
            [self popBankCardNumberAnimation:NO];
        }
        
        [self.checkBoxHelper selectItem:boxB forGroupName:CheckBoxPlatformGroup];
        boxB.selected = YES;
    }
    else
    {
        boxB.selected = NO;
    }
    return cell;
}



- (UITableViewCell *)DiscountInfoCellAtIndexPath:(NSIndexPath *)indexPath
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

- (UITableViewCell *)OtherInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"OtherInfoCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - 网络请求及处理
- (void)requestGetUserResource:(BOOL)needAutoSelect
{
    [[[gAppMgr.myUser.couponModel rac_getVaildResource:self.service.shopServiceType andShopId:self.shop.shopID] initially:^{
        
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
    
    //支付方式
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
            PaymentChannelType paychannel = [[self.paymentArray safetyObjectAtIndex:i] integerValue];
            if (paychannel == PaymentChannelCZBCreditCard)
            {
                self.checkoutServiceOrderV4Op.paychannel = PaymentChannelCZBCreditCard;
            }
            else if (paychannel == PaymentChannelAlipay)
            {
                self.checkoutServiceOrderV4Op.paychannel = PaymentChannelAlipay;
                bandCard = nil;
                //                self.selectBankCard.cardID = nil;
            }
            else if (paychannel == PaymentChannelWechat)
            {
                self.checkoutServiceOrderV4Op.paychannel = PaymentChannelWechat;
                bandCard = nil;
                //                self.selectBankCard.cardID = nil;
            }
        }
    }
    
    self.checkoutServiceOrderV4Op.serviceid = self.service.serviceID;
    self.checkoutServiceOrderV4Op.licencenumber = self.defaultCar.licencenumber ? self.defaultCar.licencenumber : @"";
    self.checkoutServiceOrderV4Op.carMake = self.defaultCar.brand;
    self.checkoutServiceOrderV4Op.carModel = self.defaultCar.seriesModel.seriesname;
    //    self.checkoutServiceOrderV4Op.bankCardId = self.selectBankCard.cardID;
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
        
        
    } error:^(NSError *error) {
        
        [self handerOrderError:error forOp:self.checkoutServiceOrderV4Op];
    }];
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
        UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:error.domain delegate:nil cancelButtonTitle:@"算了" otherButtonTitles:@"再试一次", nil];
        [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
            
            NSInteger index = [number integerValue];
            if (index == 1)
            {
                [self requestGainWeeklyCoupon];
            }
        }];
        [av show];
    }];
}

#pragma mark - 调用第三方支付
- (void)requestAliPay:(NSNumber *)orderId andTradeId:(NSString *)tradeId
             andPrice:(CGFloat)price andProductName:(NSString *)name andDescription:(NSString *)desc andTime:(NSString *)time andGasCouponAmout:(CGFloat)couponAmt

{
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
        
        if (gAppMgr.myUser.couponModel.validCZBankCreditCard.count){
            
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
        if (gAppMgr.myUser.couponModel.validCZBankCreditCard.count){
            
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
            if (gAppMgr.myUser.couponModel.validCZBankCreditCard.count){
                
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
        for (HKBankCard * card in gAppMgr.myUser.couponModel.validCZBankCreditCard)
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
        if (gAppMgr.myUser.couponModel.validCZBankCreditCard.count)
        {
            HKBankCard * card = [gAppMgr.myUser.couponModel.validCZBankCreditCard safetyObjectAtIndex:0];
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

    
    NSString * btnText = [NSString stringWithFormat:@"您只需支付%.2f元，现在支付",paymoney];
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
        self.bottomViewHeightConstraint.constant = 72;
    }
    else
    {
        self.bottomScrollLb.hidden = YES;
        self.bottomViewHeightConstraint.constant = 50;
    }
}



- (void)tableViewReloadData
{
    [self.checkBoxHelper cancelSelectedForGroupName:CheckBoxCouponGroup];
    [self.tableView reloadData];
    [self refreshPriceLb];
}

- (void)popBankCardNumberAnimation:(BOOL)flag
{
    if (flag)
    {
        POPSpringAnimation * anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        
        CGFloat centerX = self.view.frame.size.width - 45;
        CGFloat centerY = 25;
        
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
        anim.springBounciness = 16;
        anim.springSpeed = 6;
        //    anim.dynamicsTension = 100;
        anim.dynamicsMass = 2;
        [self.drawerView pop_addAnimation:anim forKey:@"center"];
    }
    else
    {
        POPSpringAnimation * anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        
        CGFloat centerX = self.view.frame.size.width + 5;
        CGFloat centerY = 25;
        
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, centerY)];
        anim.springBounciness = 16;
        anim.springSpeed = 6;
        //    anim.dynamicsTension = 100;
        anim.dynamicsMass = 2;
        [self.drawerView pop_addAnimation:anim forKey:@"center"];
    }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"您不在该商户服务范围内，请刷新或者到店后洗完车后再支付或者原价支付。"
                                                       delegate:nil cancelButtonTitle:@"放弃支付" otherButtonTitles:@"原价支付", nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
            //放弃支付
            if ([number integerValue] == 0) {
                [MobClick event:@"rp108_8"];
            }
            else if ([number integerValue] == 1) {
                [MobClick event:@"rp108_9"];
                [self requestCheckoutWithCouponType:CouponTypeNone];
            }
        }];
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

@end
