//
//  GasVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasVC.h"
#import "HorizontalScrollTabView.h"
#import "ADViewController.h"
#import "NSString+RectSize.h"
#import "CBAutoScrollLabel.h"
#import "NSString+Format.h"
#import "NSString+Split.h"
#import "GasStore.h"
#import "LoginViewModel.h"
#import "GasPickAmountCell.h"
#import "GasReminderCell.h"
#import "GasRecordVC.h"
#import "GasAddCardVC.h"
#import "GasCardListVC.h"
#import "PayForGasViewController.h"
#import "PaymentSuccessVC.h"

@interface GasVC () <RTLabelDelegate>
@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CBAutoScrollLabel *roundLb;

@property (nonatomic, strong) GasStore *gasStore;
@end

@implementation GasVC

- (void)dealloc {
    DebugLog(@"GasVC Dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    [self setupADView];
    [self setupRoundLabel];
    [self setupBottomView];
    [self setupGasStore];
    [self setupDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.roundLb refreshLabels];
    //IOS 8.1.3下面有RTLabel消失的bug，需要重新刷一下页面
    if (IOSVersionGreaterThanOrEqualTo(@"8.1") && !IOSVersionGreaterThanOrEqualTo(@"8.4")) {
        [self.tableView reloadData];
    }
}

- (void)setupTableView {
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CGFLOAT_MIN)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setupADView {
    if (!self.adctrl) {
        self.adctrl = [ADViewController vcWithADType:AdvertisementGas boundsWidth:self.view.bounds.size.width
                                            targetVC:self mobBaseEvent:@"jiayoushouye" mobBaseKey:@"jiayouguanggao"];
    }
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        UIView *header = self.headerView;
        if (ads.count == 0 || [self.headerView.subviews containsObject:ctrl.adView]) {
            return;
        }
        CGFloat height = floor(ctrl.adView.frame.size.height);
        CGFloat originHeight = floor(header.frame.size.height);
        header.frame = CGRectMake(0, 0, self.view.frame.size.width, height+originHeight);
        [header addSubview:ctrl.adView];
        [ctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            if (header)
            {
                make.left.equalTo(header);
                make.right.equalTo(header);
                make.top.equalTo(header);
                make.height.mas_equalTo(height);
            }
        }];
        self.tableView.tableHeaderView = header;
    }];
}

- (void)setupRoundLabel {
    [[[GetGaschargeConfigOp operation] rac_postRequest] subscribeNext:^(GetGaschargeConfigOp * op) {
        
        NSString *note = op.rsp_tip;
        UIView *headerView = self.headerView;
        if (note.length == 0 || [headerView.subviews containsObject:self.roundLb]) {
            return;
        }
        
        CGFloat originHeight = floor(headerView.frame.size.height);
        headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 28+originHeight);
        
        _roundLb = [[CBAutoScrollLabel alloc] initWithFrame:CGRectZero];
        _roundLb.textColor = [UIColor whiteColor];
        _roundLb.font = [UIFont systemFontOfSize:12];
        _roundLb.backgroundColor = [UIColor clearColor];
        _roundLb.labelSpacing = 30;
        _roundLb.scrollSpeed = 30;
        _roundLb.fadeLength = 5.f;
        _roundLb.textColor = kGrayTextColor;
        _roundLb.text = [self appendSpace:note andWidth:ScreenWidth];
        [headerView addSubview:_roundLb];
        [_roundLb observeApplicationNotifications];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        imageView.image = [UIImage imageNamed:@"gas_notify_300"];
        imageView.contentMode=UIViewContentModeCenter;
        imageView.backgroundColor=[UIColor whiteColor];
        [headerView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView);
            make.bottom.equalTo(headerView);
            make.height.width.mas_equalTo(28);
        }];
        
        [self.roundLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(imageView.mas_right);
            make.right.equalTo(headerView);
            make.bottom.equalTo(headerView);
            make.height.mas_equalTo(28);
        }];
        self.tableView.tableHeaderView = headerView;
    }];
}

- (void)setupBottomView {
    UIImage *bg1 = [[UIImage imageNamed:@"btn_bg_orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage *bg2 = [[UIImage imageNamed:@"btn_bg_orange_disable"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.bottomBtn setBackgroundImage:bg1 forState:UIControlStateNormal];
    [self.bottomBtn setBackgroundImage:bg2 forState:UIControlStateDisabled];
    self.bottomBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bottomBtn.titleLabel.minimumScaleFactor = 0.7;
}

- (void)setupGasStore {
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

- (void)setupDatasource {
    self.normalRechargeAmount = 500;
    
    CKDict *row1 = self.curGasCard ? [self pickGasCardItem] : [self addGasCardItem];
    self.datasource = $($(row1,[self chargePackagesItem],[self pickGasAmountItem],[self wantInvoiceItem]),
                         $([self gasReminderItem],[self serviceAgreementItem]));
    [[self.gasStore getAllGasCards] send];
}

#pragma mark - Reload
- (void)reloadFromSignal:(RACSignal *)signal {
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        self.bottomView.hidden = YES;
        self.tableView.hidden = YES;
        CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self reloadDataIfNeeded];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"刷新失败，点击重试" tapBlock:^{
            @strongify(self);
            [self.view hideDefaultEmptyView];
            [[self.gasStore getAllGasCards] send];
            [self setupADView];
            [self setupRoundLabel];
        }];
    }];
}

- (BOOL)reloadDataIfNeeded {
    //设置当前油卡
    if ([self.gasStore.gasCards count] > 0 && ![self.gasStore.gasCards objectForKey:self.curGasCard.gid]) {
        GasCard *card = [self.gasStore.gasCards objectForKey:[self.gasStore recentlyUsedGasCardKey]];
        if (!card) {
            card = [self.gasStore.gasCards objectAtIndex:0];
        }
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
    [self refreshViews];
    return YES;
}

- (void)refreshViews {
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    self.bottomView.hidden = NO;
    [self refreshBottomButton];
}

- (void)refreshBottomButton {
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
- (IBAction)actionGotoRechargeRecords:(id)sender {
    [MobClick event:@"jiayoushouye" attributes:@{@"navi":@"jiayoujilu"}];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasRecordVC *vc = [UIStoryboard vcWithId:@"GasRecordVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)actionStartPay:(id)sender {
    [MobClick event:@"jiayoushouye" attributes:@{@"zhifu":@"zhifu"}];
    if (![LoginViewModel loginIfNeededForTargetViewController:self]) {
        return;
    }
    if (!self.curGasCard) {
        [gToast showText:@"您需要先添加一张油卡！" inView:self.view];
        return;
    }
    else if ([self.curChargePkg.pkgid isEqual:@0] &&
             self.curGasCard.availablechargeamt &&
             ![self.curGasCard.availablechargeamt integerValue]) {
        [gToast showText:@"您本月加油已达到最大限额！" inView:self.view];
        return;
    }
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        PayForGasViewController * vc = [gasStoryboard instantiateViewControllerWithIdentifier:@"PayForGasViewController"];
        vc.originVC = self;
        vc.gasVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)actionAgreement:(id)sender
{
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"油卡充值服务协议";
    vc.url = kGasLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)actionBack:(id)sender
{
    [MobClick event:@"jiayoushouye" attributes:@{@"navi":@"back"}];
    
    NSArray * viewcontrollers = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontrollers safetyObjectAtIndex:viewcontrollers.count - 2];
    if ([vc isKindOfClass:[PaymentSuccessVC class]]) {
        [self.tabBarController setSelectedIndex:0];
        UIViewController * firstTabVC = [self.tabBarController.viewControllers safetyObjectAtIndex:0];
        [self.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:firstTabVC];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)actionAddGasCard {
    [MobClick event:@"jiayoushouye" attributes:@{@"youka":@"tianjiayouka"}];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPickGasCard {
    [MobClick event:@"jiayoushouye" attributes:@{@"youka":@"dianjiyouka"}];
    
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasCardListVC *vc = [UIStoryboard vcWithId:@"GasCardListVC" inStoryboard:@"Gas"];
        vc.selectedGasCardID = self.curGasCard.gid;
        [vc setSelectedBlock:^(GasCard *card) {
            [[self.gasStore updateCardInfoByGID:card.gid] send];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionShowInvoiceAlert {
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"拨打" color:kYelloColor clickBlock:^(id alertVC) {
        [gPhoneHelper makePhone:@"4007111111"];
    }];
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"由于充值业务更新，中石油卡暂不支持开具发票服务。如有疑问请咨询客服：4007-111-111" ActionItems:@[cancel,confirm]];
    [alert show];
}

#pragma mark - Utility
- (NSString *)appendSpace:(NSString *)note andWidth:(CGFloat)w {
    NSString * spaceNote = note;
    for (NSInteger i = 0;i< 1000;i++)
    {
        CGSize size = [spaceNote labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:13]];
        if (size.width > w)
            return spaceNote;
        spaceNote = [spaceNote append:@" "];
    }
    return spaceNote;
}

- (float)rechargeAmount {
    return [self isRechargeForInstalment] ? self.instalmentRechargeAmount : self.normalRechargeAmount;
}

- (BOOL)isRechargeForInstalment {
    return [self.curChargePkg.pkgid integerValue] > 0;
}

- (BOOL)needInvoice {
    if (self.curGasCard.cardtype == 2) {
        return NO;
    }
    return [self.datasource[0][@"WantInvoiceCell"][@"bill"] boolValue];
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
            
            titleL.text = pkg.month == 1 ? @"快速到账" : [NSString stringWithFormat:@"分%d个月充", pkg.month];
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
                 [self refreshViews];
                 
                 NSString * umentValue;
                 if (pkg.month == 1){
                     umentValue = @"kuaisudaozhang";
                 }
                 else if (pkg.month == 7){
                     umentValue = @"bannian";
                 }
                 else{
                     umentValue = @"yinian";
                 }
                 [MobClick event:@"jiayoushouye" attributes:@{@"daozhang":umentValue}];
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
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, GasPickAmountCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        cell.stepper.titleLabel.text = [self stepperTitleWithValue:[self fitRechargeAmountWithValue:self.rechargeAmount]];
        @weakify(cell);
        //递减
        [[[cell.stepper.leftButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(cell, self);
             [MobClick event:@"jiayoushouye" attributes:@{@"jine":@"jian"}];
             float oldValue = self.rechargeAmount;
             float value = [self decrementRechargeAmountWithValue:oldValue];
             cell.stepper.titleLabel.text = [self stepperTitleWithValue:[self fitRechargeAmountWithValue:value]];
             cell.richLabel.text = [self rechargeDescription];
             [self showToastIfNeededWithOldRechargeAmount:oldValue andNewRechargeAmount:value];
             [self refreshBottomButton];
         }];
        //递增
        [[[cell.stepper.rightButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(cell, self);
             
             [MobClick event:@"jiayoushouye" attributes:@{@"jine":@"jia"}];
             float oldValue = self.rechargeAmount;
             float value = [self incrementRechargeAmountWithValue:oldValue];
             cell.stepper.titleLabel.text = [self stepperTitleWithValue:[self fitRechargeAmountWithValue:value]];
             cell.richLabel.text = [self rechargeDescription];
             [self showToastIfNeededWithOldRechargeAmount:oldValue andNewRechargeAmount:value];
             [self refreshBottomButton];
         }];
        

        //充值提示
        cell.richLabel.text = [self rechargeDescription];
        
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    });
    
    return item;
}

///开发票
- (CKDict *)wantInvoiceItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"WantInvoiceCell",@"bill":@NO}];
    item[@"title"] = [[NSAttributedString alloc] initWithString:@"中石油不支持开发票"
                                                     attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                                  NSForegroundColorAttributeName: kOrangeColor}];
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {

        @strongify(self);
        UIButton *invoiceBtn = [cell viewWithTag:101];
        UILabel *tagLb = [cell viewWithTag:103];
        UIView *tipBtnContainer = [cell viewWithTag:104];
        UIButton *tipBtn = [cell viewWithTag:1041];
        
        tipBtnContainer.hidden = self.curGasCard.cardtype != 2;
        [tipBtn setAttributedTitle:data[@"title"] forState:UIControlStateNormal];
        [[[tipBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionShowInvoiceAlert];
         }];
        
        [[[invoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             
             [MobClick event:@"jiayoushouye" attributes:@{@"kaifapiao":@"kaifapiao"}];
             data[@"bill"] = @(![data[@"bill"] boolValue]);
             data.forceReload = !data.forceReload;
         }];
        
        @weakify(data);
        [[RACObserve(data, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {
            @strongify(data);
            BOOL bill = [data[@"bill"] boolValue];
            tagLb.hidden = !bill;
            UIImage * image = bill ? [UIImage imageNamed:@"checkbox_selected"] : [UIImage imageNamed:@"checkbox_normal_301"];
            [invoiceBtn setImage:image forState:UIControlStateNormal];
        }];
    });
    return item;
}

///加油充值说明
- (CKDict *)gasReminderItem
{
    CKDict *item = [CKDict dictWith:@{kCKItemKey:@"GasReminder"}];
    
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        CGFloat height = [data[@"height"] integerValue];
        if (height == 0) {
            GasReminderCell *cell = data[@"cell"];
            if (!cell) {
                cell = [[GasReminderCell alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
                data[@"cell"] = cell;
            }
            CKCellPrepareBlock prepare = data[kCKCellPrepare];
            prepare(data, cell, indexPath);
            height = [cell cellHeight];
            data[@"height"] = @(height);
        }
        return height;
    });
    
    @weakify(self);
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, GasReminderCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        cell.richLabel.delegate = self;
        cell.richLabel.text = [self gasRemainder];
        [cell setNeedsLayout];
        CKAsyncMainQueue(^{
            NSLog(@"richFrame=%@", NSStringFromCGRect(cell.richLabel.frame));
        });
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
             item[@"agree"] = @(![item[@"agree"] boolValue]);
             item.forceReload = !item.forceReload;
             [self refreshBottomButton];
         }];
    });
    return item;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url {
    [gAppMgr.navModel pushToViewControllerByUrl:[url absoluteString]];
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
    if (card && card.desc.length > 0) {
        return card.desc;
    }
    if (self.gasStore.config.rsp_desc) {
        return self.gasStore.config.rsp_desc;
    }
    return @"<font size=12 color='#888888'>充值即享<font color='#ff0000'>98折</font>，每月优惠限额1000元，超出部分不予奖励。每月最多充值1000元。</font>";
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
    text = [NSString stringWithFormat:@"%@<font size=12 color='#888888'>更多充值说明，点击查看<font color='#009cff'><a href='%@'>%@</a></font></font>",
            text, link, agreement];
    return text;
}
@end
