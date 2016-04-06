//
//  GasNormalVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/26.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasNormalVC.h"
#import "GasCard.h"
#import "NSString+Split.h"
#import "GetGaschargeConfigOp.h"
#import "GasStore.h"
#import "NSString+Format.h"

#import "GasReminderCell.h"
#import "GasPickAmountCell.h"
#import "PKYStepper.h"

#import "GasCardListVC.h"
#import "GasAddCardVC.h"
#import "PayForGasViewController.h"

@interface GasNormalVC ()

@property (nonatomic, strong) GasStore *gasStore;

@end

@implementation GasNormalVC

- (instancetype)initWithTargetVC:(UIViewController *)vc tableView:(UITableView *)table
                    bottomButton:(UIButton *)btn bottomView:(UIView *)bottomView
{
    self = [super initWithTargetVC:vc tableView:table bottomButton:btn bottomView:bottomView];
    if (self) {
        [self setupDatasource];
        [self setupGasStore];
    }
    return self;
}

- (void)setupDatasource
{
    self.normalRechargeAmount = 500;
    
    CKDict *row1 = self.curGasCard ? [self pickGasCardItem] : [self addGasCardItem];
    self.datasource = $($(row1,[self chargePackagesItem],[self pickGasAmountItem],[self wantInvoiceItem]),
                        $([self gasReminderItem],[self serviceAgreementItem]));
}

- (void)setupGasStore
{
    self.gasStore = [GasStore fetchOrCreateStore];
    NSArray *domains = @[kDomainGasCards, kDomainChargeConfig];
    @weakify(self);
    [self.gasStore subscribeWithTarget:self domainList:domains receiver:^(GasStore *store, CKEvent *evt) {
        @strongify(self);
        [self reloadFromSignal:evt.signal];
    }];
    
    //获取当前油卡普通加油信息
    [self.gasStore subscribeWithTarget:self domain:kDomainUpadteGasCardInfo receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        RACSignal *signal = [evt.signal doNext:^(id x) {
            @strongify(self);
            self.curGasCard = x;
        }];
        [self reloadFromSignal:signal];
    }];
}

#pragma Getter
- (float)rechargeAmount {
    return [self isRechargeForInstalment] ? self.instalmentRechargeAmount : self.normalRechargeAmount;
}

#pragma mark - Reload
- (void)reloadData {
    [[self.gasStore getAllGasCards] send];
}

- (BOOL)reloadDataIfNeeded
{
    //设置当前油卡
    if ([self.gasStore.gasCards count] > 0 && ![self.gasStore.gasCards objectForKey:self.curGasCard.gid]) {
        GasCard *card = [self.gasStore.gasCards objectAtIndex:0];
        [[self.gasStore updateCardInfoByGID:card.gid] send];
        return NO;
    }
    else if ([self.gasStore.gasCards count] == 0) {
        self.curGasCard = nil;
    }
    
    //油卡配置信息
    if (!self.gasStore.config) {
        [[self.gasStore getChargeConfig] send];
        return NO;
    }
    if (!self.curChargePkg) {
        self.curChargePkg = [self.gasStore.chargePackages objectAtIndex:0];
        self.instalmentRechargeAmount = [[self.curChargePkg.valueList safetyObjectAtIndex:0] integerValue];
    }

    CKDict *row1 = self.datasource[0][0];
    if (self.curGasCard && ![row1[kCKItemKey] isEqualToString:@"GasCard"]) {
        [self.datasource[0] replaceObject:[self pickGasCardItem] withKey:nil atIndex:0];
    }
    else if (!self.curGasCard && ![row1[kCKItemKey] isEqualToString:@"AddGasCard"]) {
        [self.datasource[0] replaceObject:[self addGasCardItem] withKey:nil atIndex:0];
    }
    return YES;
}

- (void)reloadBottomButton
{
    CKDict *item = self.datasource[1][@"Agreement"];
    self.bottomBtn.enabled = [item[@"agree"] boolValue];
    
    NSString *title;
    float paymoney = 0, discount = 0;
    //分期加油
    if ([self isRechargeForInstalment]) {
        float total = self.rechargeAmount * self.curChargePkg.month;
        discount = total * (1 - [self.curChargePkg.discount floatValue]/100.0);
        paymoney = total - discount;
    }
    //普通加油
    else {
        float couponlimit = self.gasStore.config ? self.gasStore.config.rsp_couponupplimit : 1000;
        float percent = self.gasStore.config ? self.gasStore.config.rsp_discountrate : 2;
        paymoney = self.rechargeAmount;
        if (self.curGasCard) {
            discount = MIN([self.curGasCard.couponedmoney integerValue], paymoney * percent / 100.0);
        }
        else {
            discount = MIN(couponlimit, paymoney) * percent / 100.0;
        }
        paymoney = paymoney - discount;
    }
    
    //生成文案
    if (discount > 0) {
        title = [NSString stringWithFormat:@"已优惠%@元，您只需支付%@元，现在支付",
                 [NSString formatForRoundPrice:discount], [NSString formatForRoundPrice:paymoney]];
    }
    else {
        title = [NSString stringWithFormat:@"您需支付%@元，现在支付", [NSString formatForRoundPrice:paymoney]];
    }
    [self.bottomBtn setTitle:title forState:UIControlStateNormal];
    [self.bottomBtn setTitle:title forState:UIControlStateDisabled];
}

#pragma mark - Action
- (void)actionAddGasCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPickGasCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        GasCardListVC *vc = [UIStoryboard vcWithId:@"GasCardListVC" inStoryboard:@"Gas"];
        [vc setSelectedBlock:^(GasCard *card) {
            [[self.gasStore updateCardInfoByGID:card.gid] send];
        }];
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPay
{
    [MobClick event:@"rp501_14"];
    if (![LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        return;
    }
    if (!self.curGasCard) {
        [gToast showText:@"您需要先添加一张油卡！" inView:self.targetVC.view];
        return;
    }
    else if ([self.curChargePkg.pkgid isEqual:@0] &&
             self.curGasCard.availablechargeamt &&
             ![self.curGasCard.availablechargeamt integerValue]) {
        [gToast showText:@"您本月加油已达到最大限额！" inView:self.targetVC.view];
        return;
    }
    if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        
        PayForGasViewController * vc = [gasStoryboard instantiateViewControllerWithIdentifier:@"PayForGasViewController"];
        vc.originVC = self.targetVC;
        vc.gasNormalVC = self;
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Public
- (BOOL)isRechargeForInstalment {
    return [self isRechargeForInstalment];
}


- (BOOL)needInvoice {
    return self.datasource[0][@"WantInvoiceCell"][@"bill"];
}

#pragma mark - Cell
///选择油卡
- (CKDict *)pickGasCardItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"GasCard"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 60;
    });
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
        UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
        UILabel *cardnoL = (UILabel *)[cell.contentView viewWithTag:1003];
        
        logoV.image = [UIImage imageNamed:self.curGasCard.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
        titleL.text = self.curGasCard.cardtype == 2 ? @"中石油" : @"中石化";
        cardnoL.text = [self.curGasCard.gascardno splitByStep:4 replacement:@" "];
    });

    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501_15"];
        [self actionPickGasCard];
    });
    return item;
}

///添加油卡
- (CKDict *)addGasCardItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"AddGasCard"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 60;
    });
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501_4"];
        [self actionAddGasCard];
    });
    return item;
}

///分期加油套餐
- (CKDict *)chargePackagesItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"ChargePkgs"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 75;
    });
    
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        @strongify(self);
        for (NSInteger i = 0; i < self.gasStore.chargePackages.count; i++) {
            GasChargePackage *pkg = [self.gasStore.chargePackages objectAtIndex:i];
            NSInteger tag = i + 2001;
            UIView *itemView = [cell.contentView viewWithTag:tag];
            UILabel *titleL = [cell.contentView viewWithTag:tag*10+1];
            UILabel *discountL = [cell.contentView viewWithTag:tag*10+2];
            
            titleL.text = pkg.month == 1 ? @"快速充值" : [NSString stringWithFormat:@"分%d个月充值", pkg.month];
            discountL.text = [NSString stringWithFormat:@"%@折", pkg.discount];
            
            if ([self.curChargePkg.pkgid isEqual:pkg.pkgid]) {
                itemView.layer.borderWidth = 2;
                itemView.layer.borderColor = [kDefTintColor CGColor];
                discountL.backgroundColor = kDefTintColor;
                discountL.textColor = [UIColor whiteColor];
                titleL.textColor = kDefTintColor;
            }
            else {
                itemView.layer.borderWidth = 1;
                itemView.layer.borderColor = [kLightLineColor CGColor];
                discountL.backgroundColor = kLightLineColor;
                discountL.textColor = kGrayTextColor;
                titleL.textColor = kGrayTextColor;
            }
        }

        for (int i = 0; i < self.gasStore.chargePackages.count; i++) {
            
            GasChargePackage *pkg = self.gasStore.chargePackages[i];
            UIButton *bgBtn = [cell.contentView viewWithTag:(i+2001)*10+3];
            [[[bgBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
             subscribeNext:^(id x) {
                 @strongify(self);
                 self.curChargePkg = pkg;
                 [self refreshViewWithForce:YES];
             }];
        }
    });
    
    return item;
}

///选择充值金额
- (CKDict *)pickGasAmountItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"PickGasAmount"}];
    @weakify(self);
    //cell高度
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        GasPickAmountCell *cell = data[@"cell"];
        if (!cell) {
            CGFloat width = [UIScreen mainScreen].bounds.size.width;
            cell = [[GasPickAmountCell alloc] initWithFrame:CGRectMake(0, 0, width, 52)];
            data[@"cell"] = cell;
        }
        CKCellPrepareBlock prepare = data[kCKCellPrepare];
        prepare(data, cell, indexPath);
        return [cell cellHeight];
    });

    //cell初始化
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        @strongify(self);
        GasPickAmountCell *cell1 = (GasPickAmountCell *)cell;

        cell1.stepper.titleLabel.text = [self stepperTitleWithValue:[self fitRechargeAmountWithValue:self.rechargeAmount]];
        @weakify(cell1);
        //递减
        [[[cell1.stepper.leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(cell1, self);
             [MobClick event:@"rp501_5"];
             float oldValue = self.rechargeAmount;
             float value = [self decrementRechargeAmountWithValue:oldValue];
             cell1.stepper.titleLabel.text = [self stepperTitleWithValue:[self fitRechargeAmountWithValue:value]];
             cell1.richLabel.text = [self rechargeDescription];
             [self showToastIfNeededWithOldRechargeAmount:oldValue andNewRechargeAmount:value];
             [self reloadBottomButton];
        }];
        //递增
        [[[cell1.stepper.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(cell1, self);
             [MobClick event:@"rp501_7"];
             float oldValue = self.rechargeAmount;
             float value = [self incrementRechargeAmountWithValue:oldValue];
             cell1.stepper.titleLabel.text = [self stepperTitleWithValue:[self fitRechargeAmountWithValue:value]];
             cell1.richLabel.text = [self rechargeDescription];
             [self showToastIfNeededWithOldRechargeAmount:oldValue andNewRechargeAmount:value];
             [self reloadBottomButton];
         }];
        
        //充值提示
        cell1.richLabel.text = [self rechargeDescription];

        [cell1 addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    });
    
    return item;
}

///开发票
- (CKDict *)wantInvoiceItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"WantInvoiceCell",@"bill":@NO}];
    @weakify(item, self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        @strongify(item, self);
        UIButton * invoiceBtn = [cell viewWithTag:101];
        UILabel * tagLb = [cell viewWithTag:103];
        [[[invoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             data[@"bill"] = @(![data[@"bill"] boolValue]);
             data.forceReload = !data.forceReload;
        }];

        [[RACObserve(item, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {

            BOOL bill = [data[@"bill"] boolValue];
            tagLb.hidden = !bill;
            UIImage * image = bill ? [UIImage imageNamed:@"checkbox_selected"] : [UIImage imageNamed:@"checkbox_normal"];
            [invoiceBtn setImage:image forState:UIControlStateNormal];
        }];
    });
    return item;
}

///加油充值说明
- (CKDict *)gasReminderItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"GasReminder"}];
    
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {

        @strongify(self);
        CGFloat height = [data[@"height"] integerValue];
        if (height == 0) {
            GasReminderCell *cell = data[@"cell"];
            if (!cell) {
                cell = [[GasReminderCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 45)];
                data[@"cell"] = cell;
            }
            CKCellPrepareBlock prepare = data[kCKCellPrepare];
            prepare(data, cell, indexPath);
            height = [cell cellHeight];
            data[@"height"] = @(height);
        }
        return height;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        GasReminderCell *cell1 = (GasReminderCell *)cell;
        cell1.richLabel.delegate = self;
        cell1.richLabel.text = [self gasRemainder];
    });
    return item;
}

///服务协议
- (CKDict *)serviceAgreementItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Agreement", @"agree":@YES}];
    
    @weakify(item, self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(item, self);
        UIButton *checkBox = [cell.contentView viewWithTag:1001];
        UIButton *btn = [cell.contentView viewWithTag:1002];
        
        [[RACObserve(item, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {
            @strongify(item);
            checkBox.selected = [item[@"agree"] boolValue];
        }];
        
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(item, self);
             [MobClick event:@"rp501_13"];
             item[@"agree"] = @(![item[@"agree"] boolValue]);
             item.forceReload = !item.forceReload;
             [self reloadBottomButton];
         }];
    });
    return item;
}

#pragma mark - Abount Recharge Amount
- (NSString *)rechargeDescription {
    if ([self isRechargeForInstalment]) {
        return [self rechargeDescriptionForFqjy:self.curChargePkg];
    }
    return [self rechargeDescriptionForNormal:self.curGasCard];
}

///分期加油充值说明
- (NSString *)rechargeDescriptionForFqjy:(GasChargePackage *)pkg
{
    int amount = self.instalmentRechargeAmount;
    float coupon = amount * pkg.month * (1-[pkg.discount floatValue]/100.0);
    return [NSString stringWithFormat:
            @"<font size=12 color='#888888'>充值即享<font color='#ff0000'>%@折</font>，每月充值%d元，能省%@元</font>",
            pkg.discount, amount, [NSString formatForFloorPrice:coupon]];
}


///普通加油充值说明
- (NSString *)rechargeDescriptionForNormal:(GasCard *)card
{
    if (card && card.desc) {
        return card.desc;
    }
    return @"<font size=12 color='#888888'>充值即享<font color='#ff0000'>98折</font>，每月优惠限额1000元，超出部分不予奖励。每月最多充值2000元。</font>";
}


- (NSString *)stepperTitleWithValue:(float)value {
    return [NSString stringWithFormat:@"%d元", (int)value];
}

- (void)showToastIfNeededWithOldRechargeAmount:(float)amount1 andNewRechargeAmount:(float)amount2 {
    //分期
    if ([self isRechargeForInstalment]) {
        NSArray *valueList = self.gasStore.config.rsp_supportamt;
        if (![self isEqualForValue1:amount1 andValue2:amount2]) {
            return;
        }
        if ([self isEqualForValue1:amount1 andValue2:[[valueList lastObject] floatValue]]) {
            [gToast showText:@"充值金额已达每月最大限制，无法增加啦"];
        }
        else if ([self isEqualForValue1:amount1 andValue2:[[valueList safetyObjectAtIndex:0] floatValue]]) {
            [gToast showText:[NSString stringWithFormat:@"充值金额不能小于%d哦～", (int)[[valueList safetyObjectAtIndex:0] floatValue]]];
        }
    }
    //普通
    else {
        if (amount2 > [self maxRechargeAmount]) {
            [gToast showText:@"充值金额已达本月最大限制，无法增加啦"];
        }
        else if (amount2 < 100) {
            [gToast showText:[NSString stringWithFormat:@"充值金额不能小于%d哦～", 100]];
        }
    }
}

- (float)maxRechargeAmount {
    float maximum = 1000;
    if (!self.curGasCard && self.gasStore.config.rsp_chargeupplimit) {
        maximum = [self.gasStore.config.rsp_chargeupplimit floatValue];
    }
    else if (self.curGasCard.availablechargeamt) {
        maximum = [self.curGasCard.availablechargeamt integerValue];
    }
    return maximum;
}

- (float)fitRechargeAmountWithValue:(float)value {
    if ([self isRechargeForInstalment]) {
        self.instalmentRechargeAmount = [self fitRechargeAmountWithValue:value inValueList:self.gasStore.config.rsp_supportamt];
        return self.instalmentRechargeAmount;
    }
    float minimum = 100;
    float maximum = [self maxRechargeAmount];
    self.normalRechargeAmount = MAX(minimum, MIN(maximum, value));
    return self.normalRechargeAmount;
}


- (float)fitRechargeAmountWithValue:(float)value inValueList:(NSArray *)valueList {
    float fitValue = [valueList[0] floatValue];
    for (NSInteger i = 1; i < valueList.count; i++) {
        float curValue = [valueList[i] floatValue];
        if (fabs(curValue - value) < fabs(fitValue - value)) {
            fitValue = curValue;
        }
    }
    return fitValue;
}


- (float)incrementRechargeAmountWithValue:(float)value {
    if ([self isRechargeForInstalment]) {
        return [self incrementRechargeAmountWithValue:value inValueList:self.gasStore.config.rsp_supportamt];
    }
    return value + 100;
}


- (float)incrementRechargeAmountWithValue:(float)value inValueList:(NSArray *)valueList {
    float newValue = value;
    NSInteger count = valueList.count;
    for (NSInteger i = 0; i < count; i++) {
        newValue = [valueList[i] floatValue];
        if (value < newValue) {
            break;
        }
        else if ([self isEqualForValue1:value andValue2:newValue]) {
            newValue = [valueList[MIN(count-1, i+1)] floatValue];
            break;
        }
    }
    return newValue;
}


- (float)decrementRechargeAmountWithValue:(float)value {
    if ([self isRechargeForInstalment]) {
        return [self decrementRechargeAmountWithValue:value inValueList:self.gasStore.config.rsp_supportamt];
    }
    return value - 100;
}


- (float)decrementRechargeAmountWithValue:(float)value inValueList:(NSArray *)valueList {
    float newValue = value;
    NSInteger count = valueList.count;
    for (NSInteger i = count-1; i >= 0; i--) {
        newValue = [valueList[i] floatValue];
        if (value > newValue) {
            break;
        }
        else if ([self isEqualForValue1:value andValue2:newValue]) {
            newValue = [valueList[MAX(0, i-1)] floatValue];
            break;
        }
    }
    return newValue;
}


- (BOOL)isEqualForValue1:(float)value1 andValue2:(float)value2
{
    if (fabs(value1 - value2) < 0.01) {
        return YES;
    }
    return NO;
}
#pragma mark - Abount Gas Remainder
///充值提醒
- (NSString *)gasRemainder {
    NSString *text = @"<font size=12 color='#888888'>充值成功后，须至相应加油站圈存后方能使用。</font>";
    NSString *link = [self isRechargeForInstalment] ? kInstalmentGasNoticeUrl : kAddGasNoticeUrl;
    NSString *agreement = @"《充值服务说明》";
    text = [NSString stringWithFormat:@"%@<font size=12 color='#888888'>更多充值说明，\
            点击查看<font color='#009cff'><a href='%@'>%@</a></font></font>",
            text, link, agreement];
    return text;
}
@end
