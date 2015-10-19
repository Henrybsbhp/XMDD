//
//  GasVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasVC.h"
#import "GasNormalVM.h"
#import "GasCZBVM.h"
#import "GasTabView.h"
#import "ADViewController.h"
#import "UIView+DefaultEmptyView.h"
#import "HKTableViewCell.h"
#import "UIView+JTLoadingView.h"
#import "NSString+RectSize.h"

#import "GasPickAmountCell.h"
#import "GasReminderCell.h"

#import "GasCardListVC.h"
#import "GasAddCardVC.h"
#import "GasPayForCZBVC.h"
#import "WebVC.h"

@interface GasVC ()<UITableViewDataSource, UITableViewDelegate, RTLabelDelegate>
@property (nonatomic, strong) ADViewController *adctrl;
@property (nonatomic, strong) GasTabView *headerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreementBox;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GasNormalVM *normalModel;
@property (nonatomic, strong) GasCZBVM *czbModel;
@property (nonatomic, assign) GasBaseVM *curModel;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, assign) BOOL isAcceptedAgreement;
@end

@implementation GasVC

- (void)awakeFromNib
{
    self.normalModel = [[GasNormalVM alloc] init];
    self.czbModel = [[GasCZBVM alloc] init];
    self.curModel = self.normalModel;
    _isAcceptedAgreement = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CKAsyncMainQueue(^{
        [self setupHeaderView];
        [self setupADView];
        [self setupBottomView];
        [self setupSignals];
        [self reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
}

- (void)setupHeaderView
{
    self.headerView = [[GasTabView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tableView.tableHeaderView = self.headerView;
    @weakify(self);
    [self.headerView setTabBlock:^(NSInteger index) {
        @strongify(self);
        self.curModel = index == 0 ? self.normalModel : self.czbModel;
        [self reloadData];
    }];
}

- (void)setupADView
{
    self.adctrl = [ADViewController vcWithADType:AdvertisementGas boundsWidth:self.view.bounds.size.width
                                        targetVC:self mobBaseEvent:@"rp102-6"];
    @weakify(self);
    [self.adctrl reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        @strongify(self);
        if (ads.count > 0) {
            GasTabView *headerView = self.headerView;
            CGFloat height = floor(self.adctrl.adView.frame.size.height);
            headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
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

- (void)setupBottomView
{
    UIImage *bg1 = [[UIImage imageNamed:@"gas_btn_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIImage *bg2 = [[UIImage imageNamed:@"gas_btn_bg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.bottomBtn setBackgroundImage:bg1 forState:UIControlStateNormal];
    [self.bottomBtn setBackgroundImage:bg2 forState:UIControlStateDisabled];
}

- (void)setupSignals
{
    RACSignal *sig1 = RACObserve(self, curModel);
    RACSignal *sig2 = [RACObserve(self.normalModel, isLoadSuccess) distinctUntilChanged];
    RACSignal *sig3 = [RACObserve(self.czbModel, isLoadSuccess) distinctUntilChanged];
    RACSignal *sig4 = [RACObserve(self, isAcceptedAgreement) distinctUntilChanged];
    @weakify(self);
    [[[RACSignal merge:@[sig1,sig2,sig3]] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        @strongify(self);
        BOOL success = self.curModel.isLoadSuccess;
        self.bottomView.hidden = !success;
        self.tableView.tableFooterView.hidden = !success;
        self.tableView.scrollEnabled = success;
    }];
    
    [sig4 subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.agreementBox.selected = self.isAcceptedAgreement;
        self.bottomBtn.enabled = self.isAcceptedAgreement;
    }];
}

#pragma mark - reoadData
- (void)reloadData
{
    self.datasource = [self.curModel datasource];
    NSNumber *item = [[self.datasource safetyObjectAtIndex:1] safetyObjectAtIndex:0];
    NSLog(@"item = %@", [item customInfo]);
    [self.curModel.segHelper removeAllItemsForGroupName:@"Pay"];
    NSLog(@"item = %@", [item customInfo]);
    [self.tableView reloadData];
    [self refrshLoadingView];
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
        }];
    }
    else {
        [self.view stopActivityAnimation];
        [self.view hideDefaultEmptyView];
    }
}
#pragma mark - Action
- (IBAction)actionGotoRechargeRecords:(id)sender
{
}

- (IBAction)actionPay:(id)sender
{
    //浙商支付
    if ([self.curModel isEqual:self.czbModel]) {
        if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
            GasPayForCZBVC *vc = [UIStoryboard vcWithId:@"GasPayForCZBVC" inStoryboard:@"Gas"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (IBAction)actionCheckAgreement:(id)sender
{
    self.isAcceptedAgreement = !self.isAcceptedAgreement;
}

- (IBAction)actionAgreement:(id)sender
{
    WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
    vc.title = @"油卡充值服务协议";
    vc.url = @"http://www.xiaomadada.com/apphtml/license.html";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionAddGasCard
{
    GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionPickGasCard
{
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        GasCardListVC *vc = [UIStoryboard vcWithId:@"GasCardListVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)actionAddBankCard
{
    
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
        return 32;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"选择支付方式";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 45;
    NSNumber *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    NSInteger tag = [data integerValue];
    if (tag == 1) {
        return self.view.frame.size.height;
    }
    else if (tag == 10001) {    //添加加油卡
        height = 74;
    }
    else if (tag == 10002) {    //选择加油卡
        height = 68;
    }
    else if (tag == 10003) {    //充值金额
        GasPickAmountCell *cell = [self pickGasAmountCellAtIndexPath:indexPath];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 52);
        height = [cell cellHeight];
    }
    else if (tag == 10004) {    //提醒
        GasReminderCell *cell = [self gasReminderCellAtIndexPath:indexPath];
        cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 45);
        height = [cell cellHeight];
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
    else if (tag == 10003) {
        cell = [self pickGasAmountCellAtIndexPath:indexPath];
    }
    else if (tag == 10004) {
        cell = [self gasReminderCellAtIndexPath:indexPath];
    }
    else if (tag == 10005) {
        cell = [self pickBankCardCellAtIndexPath:indexPath];
    }
    else if (tag == 10006) {
        cell = [self addCZBCardCellAtIndexPath:indexPath];
    }
    else if (tag > 20000) {
        cell = [self paymentPlatformCellAtIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger tag = [[[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row] integerValue];
    if (tag == 10001) {
        [self actionPickGasCard];
    }
    else if (tag == 10002) {
        [self actionAddGasCard];
    }
    else if (tag == 10006) {
        [self actionAddBankCard];
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
    
    logoV.image = [UIImage imageNamed:self.curModel.curGasCard.cardtype == 1 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    titleL.text = self.curModel.curGasCard.cardtype == 1 ? @"中石油" : @"中石化";
    cardnoL.text = [self.curModel.curGasCard prettyCardNumber];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    return cell;
}

///选择银行卡
- (HKTableViewCell *)pickBankCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"BankCard"
                                                                                    forIndexPath:indexPath];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 12, 0, 0)];
    UILabel *descL = (UILabel *)[cell.contentView viewWithTag:1006];
    descL.text = [self.curModel bankFavorableDesc];
    return cell;
}

- (GasPickAmountCell *)pickGasAmountCellAtIndexPath:(NSIndexPath *)indexPath
{
    GasPickAmountCell *cell = (GasPickAmountCell *)[self.tableView dequeueReusableCellWithIdentifier:@"PickGasAmount"];
    cell.richLabel.text = [self.curModel rechargeFavorableDesc];
    if (!cell.stepper.valueChangedCallback) {
        @weakify(self);
        cell.stepper.valueChangedCallback = ^(PKYStepper *stepper, float newValue) {
            @strongify(self);
            stepper.countLabel.text = [NSString stringWithFormat:@"%d", (int)newValue];
            self.curModel.rechargeAmount = (int)newValue;
        };
        [cell.stepper setup];
    }
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    return cell;
}

- (GasReminderCell *)gasReminderCellAtIndexPath:(NSIndexPath *)indexPath
{
    GasReminderCell *cell = (GasReminderCell *)[self.tableView dequeueReusableCellWithIdentifier:@"GasReminder"];
    if (!cell) {
        cell = [[GasReminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GasReminder"];
        cell.richLabel.delegate = self;
    }
    cell.richLabel.text = [self.curModel gasRemainder];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    
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
    
    if (tag == 20001) {
        iconV.image = [UIImage imageNamed:@"pm_alipay"];
        titleL.text = @"支付宝支付";
        subTitleL.text = @"推荐支付宝用户使用";
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
    }
    else if (tag == 20002) {
        iconV.image = [UIImage imageNamed:@"pm_wechat"];
        titleL.text = @"微信支付";
        subTitleL.text = @"推荐微信用户使用";
        [cell removeBorderLineWithAlignment:CKLineAlignmentHorizontalTop];
        
    }
    else if (tag == 20003) {
        iconV.image = [UIImage imageNamed:@"pm_uppay"];
        titleL.text = @"银联支付";
        subTitleL.text = @"推荐银联用户使用";
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
#pragma mark - RTLabelDelegate
- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [gAppMgr.navModel pushToViewControllerByUrl:[url absoluteString]];
}

@end
