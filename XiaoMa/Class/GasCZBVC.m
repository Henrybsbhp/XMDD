//
//  GasCZBVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/26.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasCZBVC.h"
#import "GasCard.h"
#import "GasStore.h"
#import "BankStore.h"
#import "CKDatasource.h"
#import "NSString+Format.h"
#import "NSString+Split.h"
#import "NSString+RectSize.h"

#import "HKTableViewCell.h"
#import "GasReminderCell.h"
#import "GasPickAmountCell.h"
#import "PKYStepper.h"

#import "GasCardListVC.h"
#import "GasAddCardVC.h"
#import "MyBankVC.h"
#import "GasPayForCZBVC.h"

@interface GasCZBVC ()<RTLabelDelegate>
@property (nonatomic, strong) HKBankCard *curBankCard;
@property (nonatomic, strong) GasCard *curGasCard;
@property (nonatomic, strong) GasStore *gasStore;
@property (nonatomic, strong) BankStore *bankStore;
@end

@implementation GasCZBVC


- (instancetype)initWithTargetVC:(UIViewController *)vc tableView:(UITableView *)table
                    bottomButton:(UIButton *)btn bottomView:(UIView *)bottomView
{
    self = [super initWithTargetVC:vc tableView:table bottomButton:btn bottomView:bottomView];
    if (self) {
        [self setupDatasource];
        [self setupStore];
    }
    return self;
}


- (void)setupDatasource
{
    self.rechargeAmount = 500;
    
    CKDict *row1 = self.curBankCard ? [self pickBankCardItem] : [self addBankCardItem];
    CKDict *row2 = self.curGasCard ? [self pickGasCardItem] : [self addGasCardItem];
    self.datasource = $($(row1,row2,[self pickGasAmountItem],[self wantInvoiceItem]),
                        $([self gasReminderItem],[self serviceAgreementItem]));

}

- (void)setupStore
{
    //加油store
    self.gasStore = [GasStore fetchOrCreateStore];
    
    NSArray *domains = @[kDomainGasCards, kDomainCZBChargeConfig];
    @weakify(self);
    [self.gasStore subscribeWithTarget:self domainList:domains receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        [self reloadFromSignal:evt.signal];
    }];
    
    ///更新浙商银行卡信息
    [self.gasStore subscribeWithTarget:self domain:kDomainUpdateCZBCardInfo receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        RACSignal *signal = [[evt signal] doNext:^(id x) {
            @strongify(self);
            self.curBankCard = x;
        }];
        [self reloadFromSignal:signal];
    }];
    
    //银行store
    self.bankStore = [BankStore fetchOrCreateStore];

    [self.bankStore subscribeWithTarget:self domain:kDomainBankCards receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        [self reloadFromSignal:evt.signal];
    }];
}

#pragma mark - Reload
- (BOOL)reloadDataIfNeeded
{
    //浙商加油默认配置信息
    if (!self.gasStore.czbConfig) {
        [[self.gasStore getCZBChargeConfig] send];
        return NO;
    }
    
    //设置当前油卡
    if ([self.gasStore.gasCards count] > 0 && ![self.gasStore.gasCards objectForKey:self.curGasCard.gid]) {
        self.curGasCard = [self.gasStore.gasCards objectAtIndex:0];
    }
    else if ([self.gasStore.gasCards count] == 0) {
        self.curGasCard = nil;
    }

    //如果当前没有银行卡
    if ([self.bankStore.bankCards count] > 0 && ![self.bankStore.bankCards objectForKey:self.curBankCard.cardID]) {
        HKBankCard *bankCard = [self.bankStore.bankCards objectAtIndex:0];
        [[self.gasStore updateCZBCardInfoByCID:bankCard.cardID] send];
        return NO;
    }
    else if ([self.bankStore.bankCards count] == 0) {
        self.curBankCard = nil;
    }

    //设置银行卡数据源
    CKDict *row1 = self.datasource[0][0];
    if (self.curBankCard && ![row1[kCKItemKey] isEqualToString:@"BankCard"]) {
        [self.datasource[0] replaceObject:[self pickBankCardItem] withKey:nil atIndex:0];
    }
    else if (!self.curBankCard && ![row1[kCKItemKey] isEqualToString:@"AddCZBCard"]) {
        [self.datasource[0] replaceObject:[self addBankCardItem] withKey:nil atIndex:0];
    }
    
    //设置油卡数据源
    CKDict *row2 = self.datasource[0][1];
    if (self.curGasCard && ![row2[kCKItemKey] isEqualToString:@"GasCard"]) {
        [self.datasource[0] replaceObject:[self pickGasCardItem] withKey:nil atIndex:1];
    }
    else if (!self.curGasCard && ![row2[kCKItemKey] isEqualToString:@"AddGasCard"]) {
        [self.datasource[0] replaceObject:[self addGasCardItem] withKey:nil atIndex:1];
    }
    return YES;
}

- (void)reloadBottomButton
{
    CKDict *item = self.datasource[1][@"Agreement"];
    self.bottomBtn.enabled = [item[@"agree"] boolValue];
    
    NSString *title;
    float couponlimit = 0, discount = 0, percent = 0;

    if (self.curBankCard.gasInfo) {
        couponlimit = self.curBankCard.gasInfo.rsp_couponupplimit;
        percent = self.curBankCard.gasInfo.rsp_discountrate;
        couponlimit = MAX(0, self.curBankCard.gasInfo.rsp_couponupplimit - self.curBankCard.gasInfo.rsp_czbcouponedmoney);
    }
    discount = MIN(couponlimit, self.rechargeAmount * percent / 100.0);
    //生成文案
    if (discount > 0) {
        title = [NSString stringWithFormat:@"充值%@元，只需支付%@元，现在支付",
                 [NSString formatForRoundPrice:(self.rechargeAmount + discount)],
                 [NSString formatForRoundPrice:self.rechargeAmount]];
    }
    else {
        title = [NSString stringWithFormat:@"您需支付%@元，现在支付", [NSString formatForRoundPrice:self.rechargeAmount]];
    }

    [self.bottomBtn setTitle:title forState:UIControlStateNormal];
    [self.bottomBtn setTitle:title forState:UIControlStateDisabled];
}

#pragma mark - Action
- (void)actionPickBankCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        MyBankVC *vc = [UIStoryboard vcWithId:@"MyBankVC" inStoryboard:@"Bank"];
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

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
            [[self.gasStore updateCZBCardInfoByCID:card.gid] send];
        }];
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPay
{
    [MobClick event:@"rp501-18"];
    if (![LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        return;
    }
    if (!self.curBankCard) {
        [gToast showText:@"您需要先添加一张浙商汽车卡！" inView:self.targetVC.view];
        return;
    }
    else if (!self.curGasCard) {
        [gToast showText:@"您需要先添加一张油卡！" inView:self.targetVC.view];
        return;
    }
    else if (self.curBankCard.gasInfo.rsp_availablechargeamt == 0)
    {
        [gToast showText:@"您本月加油已达到最大限额！" inView:self.targetVC.view];
        return;
    }
    else if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
        GasPayForCZBVC *vc = [UIStoryboard vcWithId:@"GasPayForCZBVC" inStoryboard:@"Gas"];
        vc.bankCard = self.curBankCard;
        vc.gasCard = self.curGasCard;
        vc.chargeamt = self.rechargeAmount;
        vc.payTitle = [self.bottomBtn titleForState:UIControlStateNormal];
        vc.originVC = self.targetVC;
        [self.targetVC.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Cell
///选择银行卡
- (CKDict *)pickBankCardItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"BankCard"}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CGFloat width = self.tableView.frame.size.width - 82 - 10;
        NSString *text = [self.gasStore rechargeDescriptionForCZB:self.curBankCard];
        CGSize size = [text labelSizeWithWidth:width font:[UIFont systemFontOfSize:13]];
        CGFloat height = 70+10;
        return MAX(height+14, height+size.height);
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *cardnoL = (UILabel *)[cell.contentView viewWithTag:1003];
        UILabel *descL = (UILabel *)[cell.contentView viewWithTag:1006];
        
        NSString *cardno = self.curBankCard.cardNumber;
        if (cardno.length > 4) {
            cardno = [cardno substringFromIndex:cardno.length - 4 length:4];
        }
        cardnoL.text = [NSString stringWithFormat:@"尾号%@", cardno];
        descL.text = [self.gasStore rechargeDescriptionForCZB:self.curBankCard];
        
        [(HKTableViewCell *)cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    });
    
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501-19"];
        [self actionPickBankCard];
    });
    return item;
}

- (CKDict *)addBankCardItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"AddCZBCard"}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        @strongify(self);
        if (data[@"height"]) {
            return [data[@"height"] integerValue];
        }
        CGFloat width = self.tableView.frame.size.width - 34 - 10;
        NSString *text = [self.gasStore rechargeDescriptionForCZB:nil];
        CGSize size = [text labelSizeWithWidth:width font:[UIFont systemFontOfSize:13]];
        CGFloat height = 18+36+14+10;
        height = MAX(height+14, height+size.height);
        data[@"height"] = @(height);
        return height;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:1003];
        label.text = [self.gasStore rechargeDescriptionForCZB:nil];
        [(HKTableViewCell *)cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    });
    
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501-17"];
        [self actionPickBankCard];
        
    });
    
    return item;
}
///选择油卡
- (CKDict *)pickGasCardItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"GasCard"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 74;
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
        [MobClick event:@"rp501-15"];
        [self actionPickGasCard];
    });
    return item;
}

///添加油卡
- (CKDict *)addGasCardItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"AddGasCard"}];
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501-4"];
        [self actionAddGasCard];
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
        
        @strongify(self);
        CGFloat height = [data[@"height"] integerValue];
        if (height > 0) {
            return height;
        }
        GasPickAmountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PickGasAmount"];
        CKCellPrepareBlock prepare = data[kCKCellPrepare];
        prepare(data, cell, indexPath);
        cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 52);
        height = [cell cellHeight];
        data[@"height"] = @(height);
        return height;
    });

    //cell初始化
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        GasPickAmountCell *cell1 = (GasPickAmountCell *)cell;

        //没有充值描述
        cell1.richLabel.text = nil;
        
        if (!cell1.stepper.valueChangedCallback) {
            //值发生改变
            cell1.stepper.valueChangedCallback = ^(PKYStepper *stepper, float newValue) {
                @strongify(self);
                stepper.countLabel.text = [NSString stringWithFormat:@"%d元", (int)newValue];
                self.rechargeAmount = (int)newValue;
                [self reloadBottomButton];
            };
            //递增
            cell1.stepper.incrementCallback = ^float(PKYStepper *stepper, float newValue) {
                [MobClick event:@"rp501-7"];
                if (newValue > stepper.maximum) {
                    [gToast showText:@"充值金额已达本月最大限制，无法增加啦"];
                    return stepper.maximum;
                }
                return newValue;
            };
            //递减
            cell1.stepper.decrementCallback = ^float(PKYStepper *stepper, float newValue) {
                [MobClick event:@"rp501-5"];
                if (newValue < stepper.minimum) {
                    [gToast showText:@"充值金额不能小于100哦～"];
                    return stepper.minimum;
                }
                return newValue;
            };
        }
        if (!self.curBankCard.gasInfo) {
            cell1.stepper.maximum = self.gasStore.czbConfig.rsp_chargeupplimit ?
                [self.gasStore.czbConfig.rsp_chargeupplimit integerValue] : 1000;
        }
        else {
            cell1.stepper.maximum = self.curBankCard.gasInfo.rsp_availablechargeamt;
        }
        cell1.stepper.value = [PKYStepper fitValueForValue:self.rechargeAmount inValueList:cell1.stepper.valueList];
        [cell1.stepper setup];
        
        [cell1 addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    });
    
    return item;
}

///开发票
- (CKDict *)wantInvoiceItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"WantInvoiceCell",@"bill":@NO}];
    @weakify(self, item);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self, item);
        UIButton * invoiceBtn = (UIButton *)[cell searchViewWithTag:101];
        UILabel * tagLb = (UILabel *)[cell searchViewWithTag:103];
        
        [[[invoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             data[@"bill"] = @(![data[@"bill"] boolValue]);
             data.forceReload = !data.forceReload;
         }];
        
        [[RACObserve(item, forceReload) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            BOOL bill = [data[@"bill"] boolValue];
            tagLb.hidden = !bill;
            UIImage * image = bill ? [UIImage imageNamed:@"cw_box1"] : [UIImage imageNamed:@"cw_box"];
            [invoiceBtn setImage:image forState:UIControlStateNormal];
        }];
        
        [(HKTableViewCell *)cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
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
            CKCellPrepareBlock prepare = data[kCKCellPrepare];
            GasReminderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GasReminder"];
            prepare(data, cell, indexPath);
            cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 45);
            height = [cell cellHeight];
            data[@"height"] = @(height);
        }
        return height;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        GasReminderCell *cell1 = (GasReminderCell *)cell;
        cell1.richLabel.delegate = self;
        cell1.richLabel.text = [self.gasStore gasRemainder];
        
        [cell1 addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
        [cell1 addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
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
             [MobClick event:@"rp501-13"];
             item[@"agree"] = @(![item[@"agree"] boolValue]);
             item.forceReload = !item.forceReload;
             [self reloadBottomButton];
         }];
    });
    return item;
}



@end
