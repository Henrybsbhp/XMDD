//
//  GasVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasVC.h"
#import "GasTabView.h"
#import "ADViewController.h"
#import "UIView+DefaultEmptyView.h"
#import "HKTableViewCell.h"
#import "UIView+JTLoadingView.h"
#import "NSString+RectSize.h"
#import "NSString+Split.h"
#import "CBAutoScrollLabel.h"
#import "NSString+Format.h"
#import "GasNormalVC.h"

#import "GasPickAmountCell.h"
#import "GasReminderCell.h"

#import "MyBankVC.h"
#import "GasCardListVC.h"
#import "GasAddCardVC.h"
#import "GasPayForCZBVC.h"
#import "GasRecordVC.h"
#import "GasPaymentResultVC.h"
#import "PayForGasViewController.h"
#import "PaymentSuccessVC.h"


@interface GasVC ()<UITableViewDataSource, UITableViewDelegate, RTLabelDelegate>
@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) GasTabView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GasNormalVM *normalModel;
@property (nonatomic, strong) GasCZBVM *czbModel;
@property (nonatomic, weak) GasBaseVM *curModel;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, strong) CKSegmentHelper *chargePkgHelper;
///是否同意协议(Default is YES)
@property (nonatomic, assign) BOOL isAcceptedAgreement;

@property (nonatomic,strong) CBAutoScrollLabel *roundLb;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UIImageView *notifyImg;
@end

@implementation GasVC

- (void)dealloc
{
    DebugLog(@"GasVC Dealloc");
    self.czbModel.cachedEvent = nil;
    self.normalModel.cachedEvent = nil;
}

-(UIImageView *)notifyImg
{
    if (!_notifyImg)
    {
        _notifyImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 28, 28)];
        _notifyImg.image = [UIImage imageNamed:@"gas_notify"];
        _notifyImg.contentMode=UIViewContentModeCenter;
        _notifyImg.backgroundColor=[UIColor whiteColor];
    }
    return _notifyImg;
}

-(UIView *)backgroundView
{
    if (!_backgroundView)
    {
        _backgroundView=[[UIView alloc]init];
        _backgroundView.backgroundColor=[UIColor whiteColor];
        
    }
    return _backgroundView;
}

-(CBAutoScrollLabel *)roundLb
{
    if (!_roundLb)
    {
        _roundLb=[[CBAutoScrollLabel alloc]init];
        _roundLb.textColor=[UIColor whiteColor];
        _roundLb.font=[UIFont systemFontOfSize:12];
        _roundLb.backgroundColor = [UIColor clearColor];
        _roundLb.labelSpacing = 30;
        _roundLb.scrollSpeed = 30;
        _roundLb.fadeLength = 5.f;
        [_roundLb observeApplicationNotifications];
    }
    return _roundLb;
}

- (NSString *)appendSpace:(NSString *)note andWidth:(CGFloat)w
{
    NSString * spaceNote = note;
    for (;;)
    {
        CGSize size = [spaceNote sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)];
        if (size.width > w)
            return spaceNote;
        spaceNote = [spaceNote append:@" "];
    }
}

- (void)awakeFromNib
{
    self.normalModel = [[GasNormalVM alloc] init];
    self.czbModel = [[GasCZBVM alloc] init];
    self.curModel = self.normalModel;
    _tabViewSelectedIndex = 0;
    _isAcceptedAgreement = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.roundLb refreshLabels];
    
    //IOS 8.1.3下面有RTLabel消失的bug，需要重新刷一下页面
    if (IOSVersionGreaterThanOrEqualTo(@"8.1.3") && !IOSVersionGreaterThanOrEqualTo(@"8.4")) {
        [self.tableView reloadData];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeaderView];
    [self setupADView];
    [self setupBottomView];
    [self setupStore];
    [self setupSignals];
    [self refreshViews];
    [self requestGasAnnnounce];
    CKAsyncMainQueue(^{
        [self.curModel reloadWithForce:YES];        
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setTabViewSelectedIndex:(NSInteger)tabViewSelectedIndex
{
    _tabViewSelectedIndex = tabViewSelectedIndex;
    self.headerView.selectedIndex = tabViewSelectedIndex;
}

- (void)setupHeaderView
{
    NSInteger index = self.tabViewSelectedIndex;
    _curModel = index == 0 ? self.normalModel : self.czbModel;
    self.headerView = [[GasTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44) selectedIndex:index];
    self.tableView.tableHeaderView = self.headerView;
    @weakify(self);
    [self.headerView setTabBlock:^(NSInteger index) {
        @strongify(self);
        if (index ==0) {
            [MobClick event:@"rp501_2"];
        }
        else {
            [MobClick event:@"rp501_3"];
        }
        
        self.curModel = index == 0 ? self.normalModel : self.czbModel;
        if (![self.curModel reloadWithForce:NO]) {
            [self refreshViews];
        }
    }];
    
    
}

- (void)setupADView
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementGas boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp501_1"];
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        if (ads.count > 0) {
            GasTabView *headerView = self.headerView;
            
            if ([headerView.subviews containsObject:self.adctrl.adView])
            {
                return;
            }
            CGFloat height = floor(self.adctrl.adView.frame.size.height);
            CGFloat originHeight = floor(headerView.frame.size.height);
            headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, height+originHeight);
            [headerView addSubview:self.adctrl.adView];
            [self.adctrl.adView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(headerView);
                make.right.equalTo(headerView);
                make.top.equalTo(headerView);
                make.height.mas_equalTo(height);
            }];
            self.tableView.tableHeaderView = self.headerView;
        }
    }];
}

- (void)setupRoundLbView:(NSString *)note
{
    if (note.length)
    {
        GasTabView *headerView = self.headerView;
        
        if ([headerView.subviews containsObject:self.backgroundView])
        {
            return;
        }
        
        CGFloat originHeight = floor(headerView.frame.size.height);
        headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 28+originHeight);
        
        CGFloat width = self.view.frame.size.width;
        NSString * p = [self appendSpace:note andWidth:width];
        self.roundLb.text = p;
        self.roundLb.textColor=[UIColor grayColor];
        UIView *upLine = [UIView new];
        upLine.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.7];
        UIView *downLine = [UIView new];
        downLine.backgroundColor=[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:0.7];
        
        
        [self.backgroundView addSubview:self.roundLb];
        [self.backgroundView addSubview:self.notifyImg];
        [self.backgroundView addSubview:upLine];
        [self.backgroundView addSubview:downLine];
        
        [headerView addSubview:self.backgroundView];
        
        [upLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_top);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        [downLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.backgroundView.mas_bottom);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
        [self.roundLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(28);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(upLine.mas_bottom);
            make.height.mas_equalTo(28);
        }];
        [self.notifyImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.top.mas_equalTo(upLine.mas_bottom);
            make.height.width.mas_equalTo(28);
        }];
        [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headerView.mas_left);
            make.right.mas_equalTo(headerView.mas_right);
            make.bottom.mas_equalTo(headerView.mas_bottom).offset(-44);
            make.height.mas_equalTo(28);
        }];
        
        self.tableView.tableHeaderView = self.headerView;
    }
}

- (void)setupBottomView
{
    UIImage *bg1 = [[UIImage imageNamed:@"gas_btn_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage *bg2 = [[UIImage imageNamed:@"gas_btn_bg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.bottomBtn setBackgroundImage:bg1 forState:UIControlStateNormal];
    [self.bottomBtn setBackgroundImage:bg2 forState:UIControlStateDisabled];
    self.bottomBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.bottomBtn.titleLabel.minimumScaleFactor = 0.7;
}

- (void)setupSignals
{
    RACSignal *sig1 = RACObserve(self, curModel);
    RACSignal *sig2 = [[RACObserve(self.normalModel, isLoadSuccess) distinctUntilChanged]
                       merge:[RACObserve(self.normalModel, isLoading) distinctUntilChanged]];
    RACSignal *sig3 = [[RACObserve(self.czbModel, isLoadSuccess) distinctUntilChanged]
                       merge:[RACObserve(self.czbModel, isLoading) distinctUntilChanged]];
    RACSignal *sig4 = [RACObserve(self, isAcceptedAgreement) distinctUntilChanged];
    @weakify(self);
    [[[RACSignal merge:@[sig1,sig2,sig3]] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        BOOL success = self.curModel.isLoadSuccess;
        BOOL loading = self.curModel.isLoading;
        self.bottomView.hidden = !success || loading;
        self.tableView.tableFooterView.hidden = !success || loading;
        self.tableView.scrollEnabled = success && !loading;
    }];
    
    [sig4 subscribeNext:^(id x) {
        @strongify(self);
        self.bottomBtn.enabled = self.isAcceptedAgreement;
    }];
}

- (void)setupStore
{
    @weakify(self);
    [[GasCardStore fetchExistsStore] subscribeEventsWithTarget:self receiver:^(HKStore *store, HKStoreEvent *evt) {
        @strongify(self);
        [evt callIfNeededForCode:kGasVCReloadDirectly object:nil target:self selector:@selector(refreshViews)];
        [evt callIfNeededForCode:kGasVCReloadWithEvent object:nil target:self selector:@selector(reloadData:)];
        [evt callIfNeededForCode:kGasConsumeEventForModel object:self.curModel target:self.curModel selector:@selector(consumeEvent:)];
    }];
}
#pragma mark - request
- (void)requestGasAnnnounce
{
    GetGaschargeConfigOp * op = [GetGaschargeConfigOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetGaschargeConfigOp * op) {
        
        [self setupRoundLbView:op.rsp_tip];
    }];
}

#pragma mark - refresh
- (void)refreshViews
{
    self.datasource = [self.curModel datasource];
    [self.curModel.segHelper removeAllItemsForGroupName:@"Pay"];
    [self.curModel.segHelper removeAllItemsForGroupName:@"ChargePkg"];
    [self.tableView reloadData];
    [self refrshLoadingView];
    [self refreshBottomView];
}

- (void)refreshBottomView
{
    NSString *title;
    NSInteger couponlimit;
    CGFloat percent = 0, discount = 0, paymoney = self.curModel.rechargeAmount;
    
    if ([self.curModel isEqual:self.normalModel]) {
        GasNormalVM *model = (GasNormalVM *)self.curModel;
        //分期加油
        if (model.curChargePackage.pkgid) {
            paymoney = paymoney * model.curChargePackage.month;
            discount = paymoney * (1 - [model.curChargePackage.discount floatValue]/100.0);
        }
        else {
            couponlimit = model.configOp ? model.configOp.rsp_couponupplimit : 1000;
            percent = model.configOp ? model.configOp.rsp_discountrate : 2;
            if (model.curGasCard) {
                discount = MIN([model.curGasCard.couponedmoney integerValue], paymoney * percent / 100.0);
            }
            else {
                discount = MIN(couponlimit, paymoney) * percent / 100.0;
            }
        }

        paymoney = paymoney - discount;
        if (discount > 0) {
            title = [NSString stringWithFormat:@"已优惠%@元，您只需支付%@元，现在支付",
                     [NSString formatForRoundPrice:discount], [NSString formatForRoundPrice:paymoney]];
        }
        else {
            title = [NSString stringWithFormat:@"您需支付%@元，现在支付", [NSString formatForRoundPrice:paymoney]];
        }
    }
    else {
        GasCZBVM *model = (GasCZBVM *)self.curModel;
        if (model.curBankCard.gasInfo) {
            couponlimit = model.curBankCard.gasInfo.rsp_couponupplimit;
            percent = model.curBankCard.gasInfo.rsp_discountrate;
            couponlimit = MAX(0, model.curBankCard.gasInfo.rsp_couponupplimit - model.curBankCard.gasInfo.rsp_czbcouponedmoney);
        }
        discount = MIN(couponlimit, paymoney * percent / 100.0);
        if (discount > 0) {
            title = [NSString stringWithFormat:@"充值%@元，只需支付%@元，现在支付",
                     [NSString formatForRoundPrice:(paymoney + discount)],
                     [NSString formatForRoundPrice:paymoney]];
        }
        else {
            title = [NSString stringWithFormat:@"您需支付%@元，现在支付", [NSString formatForRoundPrice:paymoney]];
        }
    }
    
    [self.bottomBtn setTitle:title forState:UIControlStateNormal];
    [self.bottomBtn setTitle:title forState:UIControlStateDisabled];
}

- (void)refrshLoadingView
{
    CGFloat y = self.tableView.center.y;
    y = y + self.headerView.frame.size.height/2;
    if (self.curModel.isLoading) {
        [self.view hideDefaultEmptyView];
        self.view.indicatorPoistionY = y;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }
    else if (!self.curModel.isLoadSuccess) {
        [self.view stopActivityAnimation];
        y = y - self.view.frame.size.height/2;
        @weakify(self);
        [self.view showDefaultEmptyViewWithText:@"刷新失败，点击重试" centerOffset:y tapBlock:^{
            @strongify(self);
            [self.curModel reloadWithForce:YES];
        }];
    }
    else {
        [self.view stopActivityAnimation];
        [self.view hideDefaultEmptyView];
    }
}

- (void)reloadData:(HKStoreEvent *)event
{
    @weakify(self);
    GasBaseVM *model = self.curModel;
    [[[event signal] initially:^{
        
        @strongify(self);
        model.isLoading = YES;
        [self refreshViews];
    }] subscribeError:^(NSError *error) {
        
        @strongify(self);
        model.isLoadSuccess = NO;
        model.isLoading = NO;
        [self refreshViews];
    } completed:^{
        
        @strongify(self);
        model.isLoadSuccess = YES;
        model.isLoading = NO;
        [self refreshViews];
    }];
}

#pragma mark - Action
- (IBAction)actionGotoRechargeRecords:(id)sender
{
    [MobClick event:@"rp501_16"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasRecordVC *vc = [UIStoryboard vcWithId:@"GasRecordVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)actionPay:(id)sender
{
    if ([self.curModel isEqual:self.czbModel]) {
        [MobClick event:@"rp501_18"];
    }
    else {
        [MobClick event:@"rp501_14"];
    }
    
    if (![LoginViewModel loginIfNeededForTargetViewController:self]) {
        return;
    }
    
    //浙商支付
    if ([self.curModel isEqual:self.czbModel]) {
        GasCZBVM *model = (GasCZBVM *)self.curModel;
        if (!model.curBankCard) {
            [gToast showText:@"您需要先添加一张浙商汽车卡！" inView:self.view];
            return;
        }
        else if (!self.curModel.curGasCard) {
            [gToast showText:@"您需要先添加一张油卡！" inView:self.view];
            return;
        }
        else if (self.curModel.curBankCard.gasInfo.rsp_availablechargeamt == 0)
        {
            [gToast showText:@"您本月加油已达到最大限额！" inView:self.view];
            return;
        }
        else if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            GasPayForCZBVC *vc = [UIStoryboard vcWithId:@"GasPayForCZBVC" inStoryboard:@"Gas"];
            vc.bankCard = model.curBankCard;
            vc.gasCard = model.curGasCard;
            vc.chargeamt = model.rechargeAmount;
            vc.payTitle = [self.bottomBtn titleForState:UIControlStateNormal];
            vc.originVC = self;
            vc.model = model;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    //普通支付
    else {
        if (!self.curModel.curGasCard) {
            [gToast showText:@"您需要先添加一张油卡！" inView:self.view];
            return;
        }
        else if (!self.normalModel.curChargePackage.pkgid &&
                 self.curModel.curGasCard.availablechargeamt &&
                 ![self.curModel.curGasCard.availablechargeamt integerValue])
        {
            [gToast showText:@"您本月加油已达到最大限额！" inView:self.view];
            return;
        }
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            
            PayForGasViewController * vc = [gasStoryboard instantiateViewControllerWithIdentifier:@"PayForGasViewController"];
            vc.originVC = self;
            if ([self.curModel isKindOfClass:[GasNormalVM class]])
            {
                vc.model = (GasNormalVM *)self.curModel;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)actionAgreement:(id)sender
{
    [MobClick event:@"rp501_12"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"油卡充值服务协议";
    vc.url = kGasLicenseUrl;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionAddGasCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPickGasCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasCardListVC *vc = [UIStoryboard vcWithId:@"GasCardListVC" inStoryboard:@"Gas"];
        vc.model = self.curModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionPickBankCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        MyBankVC *vc = [UIStoryboard vcWithId:@"MyBankVC" inStoryboard:@"Bank"];
        vc.selectedCardReveicer = self.curModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionBack:(id)sender
{
    NSArray * viewcontrollers = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontrollers safetyObjectAtIndex:viewcontrollers.count - 2];
    if ([vc isKindOfClass:[PaymentSuccessVC class]])
    {
        [self.tabBarController setSelectedIndex:0];
        UIViewController * firstTabVC = [self.tabBarController.viewControllers safetyObjectAtIndex:0];
        [self.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:firstTabVC];
        
        [self.navigationController popToRootViewControllerAnimated:YES];

        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource safetyObjectAtIndex:section] count];
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 1) {
//        return @"选择支付方式";
//    }
//    return nil;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45;
    NSNumber *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSInteger tag = [data integerValue];
    if (tag == 1) {
        return self.view.frame.size.height;
    }
    else if (tag == 10001) {    //选择加油卡
        height = 74;
    }
    else if (tag == 10002) {    //添加加油卡
        height = 68;
    }
    else if (tag == 100031) {   //分期选择
        height = 75;
    }
    else if (tag == 10003) {    //充值金额
        GasPickAmountCell *cell = [self pickGasAmountCellAtIndexPath:indexPath];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 52);
        height = [cell cellHeight];
    }
    else if (tag == 10004) {    // 我要开发票
        height = 44;
    }
    else if (tag == 10005) { //选择银行卡
        CGFloat width = tableView.frame.size.width - 82 - 10;
        CGSize size = [[self.curModel bankFavorableDesc] labelSizeWithWidth:width font:[UIFont systemFontOfSize:13]];
        height = 70+10;
        height = MAX(height+14, height+size.height);
    }
    else if (tag == 10006) {    //添加浙商卡
        CGFloat width = tableView.frame.size.width - 34 - 10;
        CGSize size = [[self.curModel bankFavorableDesc] labelSizeWithWidth:width font:[UIFont systemFontOfSize:13]];
        height = 18+36+14+10;
        height = MAX(height+14, height+size.height);
    }
    else if (tag == 20001) {    //充值说明
        GasReminderCell *cell = [self gasReminderCellAtIndexPath:indexPath];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 45);
        height = [cell cellHeight];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = [[[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row] integerValue];
    UITableViewCell *cell;
    if (tag == 10001) {
        cell = [self gasCardCellAtIndexPath:indexPath];
    }
    else if (tag == 10002) {
        cell = [self addGasCardCellAtIndexPath:indexPath];
    }
    else if (tag == 100031) {
        cell = [self chargePkgsCellAtIndexPath:indexPath];
    }
    else if (tag == 10003) {
        cell = [self pickGasAmountCellAtIndexPath:indexPath];
    }
    else if (tag == 10004) {
        cell = [self wantInvoiceCellAtIndexPath:indexPath];
    }
    else if (tag == 10005) {
        cell = [self pickBankCardCellAtIndexPath:indexPath];
    }
    else if (tag == 10006) {
        cell = [self addCZBCardCellAtIndexPath:indexPath];
    }
    else if (tag == 20001)
    {
        cell = [self gasReminderCellAtIndexPath:indexPath];
    }
    else if (tag == 30001) {
        cell = [self agreementCellAtIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DefCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DefCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger tag = [[[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row] integerValue];
    if (tag == 10004) {
        [cell setNeedsLayout];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger tag = [[[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row] integerValue];
    if (tag == 10001) {
        [MobClick event:@"rp501_15"];
        [self actionPickGasCard];
    }
    else if (tag == 10002) {
        [MobClick event:@"rp501_4"];
        [self actionAddGasCard];
    }
    else if (tag == 10005 || tag == 10006) {
        if (tag == 10005) {
            [MobClick event:@"rp501_19"];
        }
        else {
            [MobClick event:@"rp501_17"];
        }
        [self actionPickBankCard];
    }
    else if (tag == 10004)
    {
        self.curModel.needInvoice = !self.curModel.needInvoice;
    }
}

#pragma mark - About Cell
///添加油卡
- (HKTableViewCell *)addGasCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"AddGasCard"
                                                                                    forIndexPath:indexPath];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    return cell;
}

///添加浙商卡
- (HKTableViewCell *)addCZBCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"AddCZBCard"
                                                                                    forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1003];
    label.text = [self.curModel bankFavorableDesc];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    return cell;
}

///选择加油卡
- (HKTableViewCell *)gasCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"GasCard"
                                                                                    forIndexPath:indexPath];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *cardnoL = (UILabel *)[cell.contentView viewWithTag:1003];
    
    logoV.image = [UIImage imageNamed:self.curModel.curGasCard.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    titleL.text = self.curModel.curGasCard.cardtype == 2 ? @"中石油" : @"中石化";
    cardnoL.text = [self.curModel.curGasCard.gascardno splitByStep:4 replacement:@" "];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    return cell;
}

///选择银行卡
- (HKTableViewCell *)pickBankCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"BankCard"
                                                                                    forIndexPath:indexPath];
    UILabel *cardnoL = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *descL = (UILabel *)[cell.contentView viewWithTag:1006];
    
    NSString *cardno = [(GasCZBVM *)self.curModel curBankCard].cardNumber;
    if (cardno.length > 4) {
        cardno = [cardno substringFromIndex:cardno.length - 4 length:4];
    }
    cardnoL.text = [NSString stringWithFormat:@"尾号%@", cardno];
    descL.text = [self.curModel bankFavorableDesc];
    
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    return cell;
}

///选择分期月份
- (UITableViewCell *)chargePkgsCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ChargePkgs"];

    for (NSInteger i = 0; i < self.normalModel.chargePackages.count; i++) {

        GasChargePackage *pkg = self.normalModel.chargePackages[i];
        NSInteger tag = i + 2001;
        UIView *itemView = [cell.contentView viewWithTag:tag];
        UILabel *titleL = [cell.contentView viewWithTag:tag*10+1];
        UILabel *discountL = [cell.contentView viewWithTag:tag*10+2];

        titleL.text = pkg.month == 1 ? @"快速充值" : [NSString stringWithFormat:@"分%d个月充值", pkg.month];
        discountL.text = [NSString stringWithFormat:@"%@折", pkg.discount];
        
        if ([self.normalModel.curChargePackage isEqual:pkg]) {
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
    
    @weakify(self);
    for (int i = 0; i < self.normalModel.chargePackages.count; i++) {
        GasChargePackage *pkg = self.normalModel.chargePackages[i];
        UIButton *bgBtn = [cell.contentView viewWithTag:(i+2001)*10+3];
        [[[bgBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             self.normalModel.curChargePackage = pkg;
             [self.tableView reloadData];
             if (i == 1)
             {
                 [MobClick event:@"rp501_21"];
             }
             else if (i == 2)
             {
                 [MobClick event:@"rp501_22"];
             }
        }];
    }
    
    return cell;
}

- (GasPickAmountCell *)pickGasAmountCellAtIndexPath:(NSIndexPath *)indexPath
{
    GasPickAmountCell *cell = (GasPickAmountCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PickGasAmount"];
    cell.richLabel.text = [self.curModel rechargeFavorableDesc];
    
    [self setupStepper:cell.stepper forPickGasAmountCell:cell];
    @weakify(cell);
    //递增
    [[[cell.stepper.incrementButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(cell);
        float oldValue = cell.stepper.value;
        float newValue = oldValue;
        if (cell.stepper.valueList.count > 0) {
            newValue = [PKYStepper incrementValue:oldValue inValueList:cell.stepper.valueList];
            //提示已经达到最大限额
            if ([PKYStepper isEqualForValue1:oldValue andValue2:newValue]) {
                [gToast showText:@"充值金额已达每月最大限制，无法增加啦"];
            }
        }
        else {
            newValue = MIN(cell.stepper.maximum, oldValue + cell.stepper.stepInterval);
            //提示已经达到最大限额
            if (oldValue > newValue || [PKYStepper isEqualForValue1:oldValue andValue2:newValue]) {
                [gToast showText:@"充值金额已达本月最大限制，无法增加啦"];
            }
        }
        cell.stepper.value = newValue;
        [cell.stepper setup];
    }];
    
    //递减
    [[[cell.stepper.decrementButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(cell);
        float oldValue = cell.stepper.value;
        float newValue = oldValue;
        if (cell.stepper.valueList.count > 0) {
            newValue = [PKYStepper decrementValue:oldValue inValueList:cell.stepper.valueList];
            //提示已经达到最小限额
            if ([PKYStepper isEqualForValue1:oldValue andValue2:newValue]) {
                [gToast showText:[NSString stringWithFormat:@"充值金额不能小于%d哦～", (int)newValue]];
            }
        }
        else {
            newValue = MAX(cell.stepper.minimum, oldValue - cell.stepper.stepInterval);
            //提示已经达到最大限额
            if ([PKYStepper isEqualForValue1:oldValue andValue2:newValue]) {
                [gToast showText:[NSString stringWithFormat:@"充值金额不能小于%d哦～", (int)newValue]];
            }
        }
        cell.stepper.value = newValue;
        [cell.stepper setup];
    }];

    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    return cell;
}

- (void)setupStepper:(PKYStepper *)stepper forPickGasAmountCell:(GasPickAmountCell *)cell
{
    stepper.valueList = nil;
    stepper.allowValueList = NO;
    if ([self.curModel isEqual:self.normalModel]) {
        stepper.valueList = self.normalModel.curChargePackage.pkgid ? self.normalModel.configOp.rsp_supportamt : nil;
        stepper.allowValueList = self.normalModel.curChargePackage.pkgid;
        if (!self.curModel.curGasCard) {
            // 有说明请求成功
            stepper.maximum = self.normalModel.configOp.rsp_chargeupplimit ? [self.normalModel.configOp.rsp_chargeupplimit integerValue] : 1000;
        }
        else {
            stepper.maximum = [self.curModel.curGasCard.availablechargeamt integerValue];
        }
    }
    else {
        GasCZBVM *model = (GasCZBVM *)self.curModel;
        if (!model.curBankCard.gasInfo) {
            stepper.maximum = model.defCouponInfo.rsp_chargeupplimit ? [model.defCouponInfo.rsp_chargeupplimit integerValue] : 1000;
        }
        else {
            stepper.maximum = model.curBankCard.gasInfo.rsp_availablechargeamt;
        }
    }
    
    @weakify(self);
    if (!stepper.valueChangedCallback) {
        stepper.valueChangedCallback = ^(PKYStepper *stepper, float newValue) {
            @strongify(self);
            stepper.countLabel.text = [NSString stringWithFormat:@"%d元", (int)newValue];
            if (stepper.allowValueList) {
                self.normalModel.instalmentRechargeAmount = (int)newValue;
            }
            else if ([self.curModel isKindOfClass:[GasNormalVM class]]) {
                self.normalModel.normalRechargeAmount = (int)newValue;
            }
            else {
                self.curModel.rechargeAmount = (int)newValue;
            }
            cell.richLabel.text = [self.curModel rechargeFavorableDesc];
            [self refreshBottomView];
        };
    }
    
    cell.stepper.value = self.curModel.rechargeAmount;
    [cell.stepper setup];
}

- (GasReminderCell *)gasReminderCellAtIndexPath:(NSIndexPath *)indexPath
{
    GasReminderCell *cell = (GasReminderCell *)[self.tableView dequeueReusableCellWithIdentifier:@"GasReminder"];
    cell.richLabel.delegate = self;
    cell.richLabel.text = [self.curModel gasRemainder];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    return cell;
}

- (HKTableViewCell *)wantInvoiceCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"WantInvoiceCell"];
    UIButton * invoiceBtn = (UIButton *)[cell searchViewWithTag:101];
    UILabel * tagLb = (UILabel *)[cell searchViewWithTag:103];
    
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    
    @weakify(self)
    [[[invoiceBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self)
        self.curModel.needInvoice = !self.curModel.needInvoice;
    }];
    
    
    [[RACObserve(self.curModel, needInvoice) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSNumber * num) {
        
        tagLb.hidden = ![num integerValue];
        UIImage * image = [num integerValue] ? [UIImage imageNamed:@"cw_box1"] : [UIImage imageNamed:@"cw_box"];
        [invoiceBtn setImage:image forState:UIControlStateNormal];
    }];
    
    return cell;
}

- (HKTableViewCell *)paymentPlatformCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *item = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSInteger tag = [item integerValue];
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PaymentPlatform"];
    UIImageView *iconV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *subTitleL = (UILabel *)[cell.contentView viewWithTag:1004];
    UIButton *boxB = (UIButton *)[cell.contentView viewWithTag:1003];
    UILabel *recommendLB = (UILabel *)[cell.contentView viewWithTag:1005];
    recommendLB.cornerRadius = 3.0f;
    recommendLB.layer.masksToBounds = YES;
    
    if (tag == 20001) {
        iconV.image = [UIImage imageNamed:@"pm_alipay"];
        titleL.text = @"支付宝支付";
        subTitleL.text = @"推荐支付宝用户使用";
        recommendLB.hidden = NO;
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
    }
    else if (tag == 20002) {
        iconV.image = [UIImage imageNamed:@"pm_wechat"];
        titleL.text = @"微信支付";
        subTitleL.text = @"推荐微信用户使用";
        recommendLB.hidden = YES;
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
        
        
    }
    else if (tag == 20003) {
        iconV.image = [UIImage imageNamed:@"pm_uppay"];
        titleL.text = @"银联支付";
        subTitleL.text = @"推荐银联用户使用";
        recommendLB.hidden = YES;
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
    }
    item.customObject = boxB;
    @weakify(self);
    [self.curModel.segHelper addItem:item forGroupName:@"Pay" withChangedBlock:^(NSNumber *item, BOOL selected) {
        @strongify(self);
        UIButton *boxB = item.customObject;
        boxB.selected = selected;
        boxB.userInteractionEnabled = !selected;
        if (selected) {
            NSInteger tag = [item integerValue];
            if (tag == 20001) {
                [MobClick event:@"rp501_9"];
            }
            else if (tag == 20002) {
                [MobClick event:@"rp501_10"];
            }
            else if (tag == 20003){
                [MobClick event:@"rp501_11"];
            }
            self.curModel.paymentPlatform = [item integerValue] - 20000;
        }
    }];
    
    [[[boxB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        [self.curModel.segHelper selectItem:item forGroupName:@"Pay"];
    }];
    
    if (tag - self.curModel.paymentPlatform == 20000) {
        CKAsyncMainQueue(^{
            [self.curModel.segHelper selectItem:item forGroupName:@"Pay"];
        });
    }
    UIEdgeInsets bottomInsets = tag == 20003 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 12, 0, 0);
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:bottomInsets];
    return cell;
}

- (UITableViewCell *)agreementCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Agreement" forIndexPath:indexPath];
    UIButton *checkBox = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1002];
    
    [[RACObserve(self, isAcceptedAgreement) takeUntilForCell:cell] subscribeNext:^(NSNumber *x) {
        
        BOOL isAcceptedAgreement = [x boolValue];
        checkBox.selected = isAcceptedAgreement;
    }];
    
    @weakify(self);
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
     subscribeNext:^(id x) {
         [MobClick event:@"rp501_13"];
         @strongify(self);
         self.isAcceptedAgreement = !self.isAcceptedAgreement;
     }];
    return cell;
}
#pragma mark - RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [MobClick event:@"rp501_8"];
    [gAppMgr.navModel pushToViewControllerByUrl:[url absoluteString]];
}

@end
