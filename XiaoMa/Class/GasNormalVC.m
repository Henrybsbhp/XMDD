//
//  GasNormalVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/26.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasNormalVC.h"
#import "CKDatasource.h"
#import "GasCard.h"
#import "NSString+Split.h"
#import "GetGaschargeConfigOp.h"
#import "GasNormalVM.h"
#import "GasStore.h"

#import "HKTableViewCell.h"
#import "GasReminderCell.h"
#import "GasPickAmountCell.h"
#import "PKYStepper.h"

#import "GasCardListVC.h"
#import "GasAddCardVC.h"

@interface GasNormalVC ()<RTLabelDelegate>
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) CKList *normalDatasource;
@property (nonatomic, strong) CKList *loadingDatasource;

@property (nonatomic, strong) GasCard *curGasCard;
@property (nonatomic, strong) GasChargePackage *curChargePkg;
@property (nonatomic, strong) GasStore *gasStore;
@property (nonatomic, assign) float rechargeAmount;

///是否同意协议(Default is YES)
@property (nonatomic, strong) GasNormalVM *model;

@end

@implementation GasNormalVC

- (void)dealloc
{
    
}

- (instancetype)initWithTargetVC:(UIViewController *)vc tableView:(UITableView *)table bottomButton:(UIButton *)btn
{
    self = [super init];
    if (self) {
        _tableView = table;
        _bottomBtn = btn;
        _targetVC = vc;
        _model = [[GasNormalVM alloc] init];
        [self setupDatasource];
        [self setupGasStore];
    }
    return self;
}

- (void)setupDatasource
{
    self.rechargeAmount = 500;
    
    CKDict *row1 = self.curGasCard ? [self pickGasCardItem] : [self addGasCardItem];
    self.normalDatasource = $($(row1,[self chargePackagesItem],[self pickGasAmountItem],[self wantInvoiceItem]),
                              $([self gasReminderItem],[self serviceAgreementItem]));
    
    self.loadingDatasource = $($([self loadingItem]));
    
    self.datasource = self.normalDatasource;
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

#pragma mark - Reload
- (void)reloadFromSignal:(RACSignal *)signal
{
    CKDict *blankItem = self.loadingDatasource[0][@"Loading"];
    __block BOOL triggered = NO;
    @weakify(self);
    [[signal initially:^{

        @strongify(self);
        //如果没在刷新
        if (![blankItem[@"loading"] boolValue]) {
            blankItem[@"loading"] = @YES;
            self.datasource = self.loadingDatasource;
            [self reloadTableView];
            self.bottomBtn.superview.hidden = YES;
        }
    }] subscribeNext:^(id x) {

        @strongify(self);
        triggered = YES;
        if ([self reloadDataIfNeeded]) {
            //如果需要重新加载，停止刷新
            blankItem[@"loading"] = @NO;
            blankItem[@"error"] = @NO;
            blankItem.forceReload = !blankItem.forceReload;
            self.bottomBtn.superview.hidden = NO;
        }
    } error:^(NSError *error) {

        @strongify(self);
        triggered = YES;
        blankItem[@"loading"] = @NO;
        blankItem[@"error"] = @YES;
        blankItem.forceReload = !blankItem.forceReload;
        self.bottomBtn.superview.hidden = NO;
    } completed:^{

        @strongify(self);
        //如果没有触发任何事件，表示该信号需要被忽略
        if (!triggered && [self reloadDataIfNeeded]) {
            //如果需要重新加载，停止刷新
            blankItem[@"loading"] = @NO;
            blankItem[@"error"] = @NO;
            blankItem.forceReload = !blankItem.forceReload;
            self.bottomBtn.superview.hidden = NO;
        }
    }];
}

- (BOOL)reloadDataIfNeeded
{
    if (![self isEqual:self.tableView.delegate]) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    //如果当前没有加油
    if (!self.curGasCard || ![self.gasStore.gasCards objectForKey:self.curGasCard.gid]) {
        [[self.gasStore updateCardInfoByGID:[[self.gasStore.gasCards objectAtIndex:0] gid]] send];
        return NO;
    }
    if (!self.gasStore.config) {
        [[self.gasStore getChargeConfig] send];
        return NO;
    }
    if (!self.curChargePkg) {
        self.curChargePkg = [self.gasStore.chargePackages objectAtIndex:0];
    }

    CKDict *row1 = self.normalDatasource[0][0];
    if (self.curGasCard && ![row1[kCKItemKey] isEqualToString:@"GasCard"]) {
        [self.normalDatasource[0] replaceObject:[self pickGasCardItem] withKey:nil atIndex:0];
    }
    else if (!self.curGasCard && ![row1[kCKItemKey] isEqualToString:@"AddGasCard"]) {
        [self.normalDatasource[0] replaceObject:[self addGasCardItem] withKey:nil atIndex:0];
    }
    self.datasource = self.normalDatasource;
    [self reloadTableView];
    return YES;
}

- (void)reloadTableView
{
    if ([self isEqual:self.tableView.delegate]) {
        CKAsyncMainQueue(^{
            [self.tableView reloadData];
        });
    }
}

- (void)reloadBottomButton
{
    CKDict *item = self.datasource[1][@"Agreement"];
    self.bottomBtn.enabled = [item[@"agree"] boolValue];
}

#pragma mark - Cell
///空白刷新（包括刷新失败）
- (CKDict *)loadingItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"Loading"}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        return self.tableView.frame.size.height - self.tableView.tableHeaderView.frame.size.height + self.bottomBtn.superview.frame.size.height;
    });
    
    item[kCKCellWillDisplay] = CKCellWillDisplay(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        if ([data[@"loading"] boolValue]) {
            [cell.contentView hideDefaultEmptyView];
            [cell.contentView startActivityAnimationWithType:GifActivityIndicatorType];
        }
        if ([data[@"error"] boolValue]) {
            [cell.contentView stopActivityAnimation];
            [cell.contentView showDefaultEmptyViewWithText:@"刷新失败，点击重试" tapBlock:^{
                [[[GasStore fetchExistsStore] getAllGasCards] send];
            }];
        }
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
        [(HKTableViewCell *)cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom
                                                             insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    });

    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501-15"];
        if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
            GasCardListVC *vc = [UIStoryboard vcWithId:@"GasCardListVC" inStoryboard:@"Gas"];
            [self.targetVC.navigationController pushViewController:vc animated:YES];
        }
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
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        [(HKTableViewCell *)cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom
                                                             insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    });
    @weakify(self);
    item[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [MobClick event:@"rp501-15"];
        if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC]) {
            GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
            [self.targetVC.navigationController pushViewController:vc animated:YES];
        }
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
                itemView.layer.borderColor = [HEXCOLOR(@"#20ab2a") CGColor];
                discountL.backgroundColor = HEXCOLOR(@"#20ab2a");
                discountL.textColor = [UIColor whiteColor];
            }
            else {
                itemView.layer.borderWidth = 0.5;
                itemView.layer.borderColor = [HEXCOLOR(@"#d7d7d7") CGColor];
                discountL.backgroundColor = HEXCOLOR(@"#d7d7d7");
                discountL.textColor = HEXCOLOR(@"#888888");
            }
        }

        for (int i = 0; i < self.gasStore.chargePackages.count; i++) {
            
            GasChargePackage *pkg = self.gasStore.chargePackages[i];
            UIButton *bgBtn = [cell.contentView viewWithTag:(i+2001)*10+3];
            [[[bgBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
             subscribeNext:^(id x) {
                 @strongify(self);
                 self.curChargePkg = pkg;
                 [self reloadTableView];
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
        
        @strongify(self);
        GasPickAmountCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PickGasAmount"];
        CKCellPrepareBlock prepare = data[kCKCellPrepare];
        prepare(data, cell, indexPath);
        cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 52);
        return [cell cellHeight];
    });

    //cell初始化
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        @strongify(self);
        GasPickAmountCell *cell1 = (GasPickAmountCell *)cell;
        BOOL fqjy = [self.curChargePkg.pkgid integerValue] > 0;
        //充值描述
        cell1.richLabel.text = fqjy ? [self.gasStore rechargeDescriptionForFqjy:self.curChargePkg] :
            [self.gasStore rechargeDescriptionForNormal:self.curGasCard];

        if (!cell1.stepper.valueChangedCallback) {
            //值发生改变
            cell1.stepper.valueChangedCallback = ^(PKYStepper *stepper, float newValue) {
                @strongify(self);
                stepper.countLabel.text = [NSString stringWithFormat:@"%d元", (int)newValue];
                self.model.rechargeAmount = (int)newValue;
                [self reloadBottomButton];
            };
            //递增
            cell1.stepper.incrementCallback = ^float(PKYStepper *stepper, float newValue) {
                [MobClick event:@"rp501-7"];
                if (stepper.allowValueList && stepper.valueList.count > 0) {
                    float maxValue = [[stepper.valueList lastObject] floatValue];
                    if (newValue >= maxValue && stepper.value >= maxValue) {
                        [gToast showText:@"充值金额已达本月最大限制，无法增加啦"];
                        return [[stepper.valueList lastObject] floatValue];
                    }
                }
                else if (newValue > stepper.maximum) {
                    [gToast showText:@"充值金额已达本月最大限制，无法增加啦"];
                    return stepper.maximum;
                }
                return newValue;
            };
            //递减
            cell1.stepper.decrementCallback = ^float(PKYStepper *stepper, float newValue) {
                [MobClick event:@"rp501-5"];
                if (stepper.allowValueList && stepper.valueList.count > 0) {
                    float minValue = [stepper.valueList[0] floatValue];
                    if (newValue <= minValue && stepper.value <= minValue) {
                        [gToast showText:[NSString stringWithFormat:@"充值金额不能小于%d哦～", (int)minValue]];
                        return [stepper.valueList[0] floatValue];
                    }
                }
                else if (newValue < stepper.minimum) {
                    [gToast showText:@"充值金额不能小于100哦～"];
                    return stepper.minimum;
                }
                return newValue;
            };
        }
        if (!self.curGasCard) {
            // 有说明请求成功
            cell1.stepper.maximum = self.gasStore.config.rsp_chargeupplimit ?
            [self.gasStore.config.rsp_chargeupplimit integerValue] : 1000;
        }
        else {
            cell1.stepper.maximum = [self.curGasCard.availablechargeamt integerValue];
        }
        cell1.stepper.valueList = self.gasStore.config.rsp_supportamt;
        cell1.stepper.allowValueList = [self.curChargePkg.pkgid integerValue] > 0;
        cell1.stepper.value = self.rechargeAmount;
        [cell1.stepper setup];
        
        [cell1 addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    });
    
    return item;
}

///开发票
- (CKDict *)wantInvoiceItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"WantInvoiceCell",@"bill":@NO}];
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton * invoiceBtn = (UIButton *)[cell searchViewWithTag:101];
        UILabel * tagLb = (UILabel *)[cell searchViewWithTag:103];
        
        [[[invoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             data[@"bill"] = @(![data[@"bill"] boolValue]);
             data.forceReload = !data.forceReload;
        }];

        @weakify(data);
        [[RACObserve(data, forceReload) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(data);
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
        CKCellPrepareBlock prepare = data[kCKCellPrepare];
        GasReminderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GasReminder"];
        prepare(data, cell, indexPath);
        cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 45);
        return [cell cellHeight];
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        GasReminderCell *cell1 = (GasReminderCell *)[self.tableView dequeueReusableCellWithIdentifier:@"GasReminder"];
        cell1.richLabel.delegate = self;
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

#pragma mark - RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [MobClick event:@"rp501-8"];
    [gAppMgr.navModel pushToViewControllerByUrl:[url absoluteString]];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.datasource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.datasource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 8;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellGetHeight]) {
        return ((CKCellGetHeightBlock)item[kCKCellGetHeight])(item, indexPath);
    }
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKItemKey]];
    if (item[kCKCellPrepare]) {
        ((CKCellPrepareBlock)item[kCKCellPrepare])(item, cell, indexPath);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    if (item[kCKCellWillDisplay]) {
        ((CKCellWillDisplayBlock)item[kCKCellWillDisplay])(item, cell, indexPath);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (item[kCKCellSelected]) {
        ((CKCellSelectedBlock)item[kCKCellSelected])(item, indexPath);
    }
}

@end
