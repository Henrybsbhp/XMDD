//
//  ChooseBankCardVC.m
//  XiaoMa
//
//  Created by jt on 15/8/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ChooseBankCardVC.h"
#import "ADViewController.h"
#import "HKBankCard.h"
#import "HKConvertModel.h"
#import "PayForWashCarVC.h"
#import "BindBankCardVC.h"
#import "GetBankcardListOp.h"
#import "BankStore.h"
#import "GetUserResourcesV2Op.h"
#import "CouponModel.h"
#import "Masonry.h"

@interface ChooseBankCardVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;

@property (nonatomic, strong) UIButton *defaultButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@end

@implementation ChooseBankCardVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ChooseBankCardVC dealloc");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAdView];
    [self reloadData];
    @weakify(self);
    [self listenNotificationByName:kNotifyRefreshMyBankcardList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self);
        [self reloadData];
        
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            payVc.needChooseResource = YES;
        }
    }];
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self.tableView reloadData];
}

- (void)setupAdView
{
    CKAsyncMainQueue(^{
        self.advc = [ADViewController vcWithADType:AdvertisementBankCardBinding boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:nil];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

- (void)reloadData
{
    CouponModel * couponModel = [[CouponModel alloc] init];
    
    @weakify(self);
    [[[[couponModel rac_getVaildResource:self.service.shopServiceType andShopId:self.shop.shopID] initially:^{
        
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - 60)];
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            
            [self.tableView.refreshView beginRefreshing];
            
        } else {
            [self hideContentViews];
        }
        
        [self removeButton];
        
    }] finally:^{
        
        [self.tableView.refreshView endRefreshing];
    }] subscribeNext:^(GetUserResourcesV2Op * op) {
        
        @strongify(self);
        
        [self.view stopActivityAnimation];
        
        if (![self.tableView isRefreshViewExists]) {
            [self setupRefreshView];
        }
        
        self.bankCards = op.rsp_czBankCreditCard;
        if (self.bankCards.count > 0) {
            
            [self showContentViews];
            [self.tableView reloadData];
            
        } else {
            [self hideContentViews];
            [self addButton];
        }
        
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
        
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            [payVc chooseResource];
        }
    } error:^(NSError *error) {
        [self.view stopActivityAnimation];
        
        if (![self.tableView isRefreshViewExists]) {
            [self.view stopActivityAnimation];
            [self.view showDefaultEmptyViewWithText:@"获取银行卡信息失败，请点击重试" tapBlock:^{
                [self.view hideDefaultEmptyView];
                [self reloadData];
            }];
        }
        
    }];
}

- (void)reloadResources
{
    NSArray * viewcontroller = self.navigationController.viewControllers;
    UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
    if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
    {
        PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
        [payVc requestGetUserResource:YES];
    }
}

- (void)showContentViews
{
    self.tableView.hidden = NO;
}

- (void)hideContentViews
{
    self.tableView.hidden = YES;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击“添加银行卡”
    if (indexPath.row == self.bankCards.count) {
        [MobClick event:@"rp314_3"];
        BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row < self.bankCards.count) {
        [MobClick event:@"rp314_4"];
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            HKBankCard * card = [self.bankCards safetyObjectAtIndex:indexPath.row];
            payVc.selectBankCard = card;
            if (card.couponIds.count)
            {
                NSArray * array = [self.carwashCouponArray arrayByFilteringOperator:^BOOL(HKCoupon *obj) {
                    
                    return [obj.couponId isEqualToNumber:[card.couponIds safetyObjectAtIndex:0]];
                }];
                if (array.count && self.needRechooseCarwashCoupon)
                {
                    payVc.selectCarwashCoupouArray = [NSMutableArray arrayWithObject:[array safetyObjectAtIndex:0]];
                    payVc.couponType = CouponTypeCZBankCarWash;
                }
            }
            [payVc setPaymentChannel:PaymentChannelCZBCreditCard];
            [payVc tableViewReloadData];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.bankCards.count) {
        
        return 114;
        
    }
    
    return 104;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bankCards.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == self.bankCards.count) {
        cell = [self addCellAtIndexPath:indexPath];
    }
    else {
        cell = [self bankCellAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - About Cell
- (UITableViewCell *)promptCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PromptCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)bankCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BankCell" forIndexPath:indexPath];
    UIImageView *bgV = (UIImageView *)[cell.contentView viewWithTag:1000];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *cardTypeL = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *numberL = (UILabel *)[cell.contentView viewWithTag:1004];
    
    HKBankCard *card = [self.bankCards safetyObjectAtIndex:indexPath.row];
    
    if (indexPath.row % 3 == 0) {
        bgV.image = [UIImage imageNamed:@"Bank_redCardBackground_imageView"];
    }
    else if (indexPath.row % 3 == 1) {
        bgV.image = [UIImage imageNamed:@"Bank_greenCardBackground_imageView"];
    }
    else if (indexPath.row % 3 == 2) {
        bgV.image = [UIImage imageNamed:@"Bank_blueCardBackground_imageView"];
    }
    
    logoV.image = [UIImage imageNamed:@"mb_logo"];
    titleL.text = card.cardName;
    cardTypeL.text = card.cardType == HKBankCardTypeCredit ? @"信用卡" : @"储蓄卡";
    numberL.text = [HKConvertModel convertCardNumberForEncryption:card.cardNumber];
    return cell;
}

- (UITableViewCell *)addCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
    return cell;
}

- (void)setupRefreshView
{
    @weakify(self)
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(id x) {
        @strongify(self)
        [self reloadData];
    }];
}

- (void)addButton
{
    @weakify(self);
    [self.view stopActivityAnimation];
    [self.view showEmptyViewWithImageName:@"def_withoutCard" text:@"暂无银行卡" centerOffset:-100 tapBlock:^{
        @strongify(self);
        [self reloadData];
    }];
    
    [self.view addSubview:self.defaultButton];
    const CGFloat top = gAppMgr.deviceInfo.screenSize.height / 2 + 30;
    [self.defaultButton mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(top);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(50);
    }];
}

- (void)removeButton
{
    NSArray *subviews = self.view.subviews;
    [self.view hideDefaultEmptyView];
    
    if ([subviews containsObject:self.defaultButton]) {
        [self.defaultButton removeFromSuperview];
    }
}

- (UIButton *)defaultButton
{
    if (!_defaultButton) {
        _defaultButton = [[UIButton alloc] init];
        [_defaultButton setTitle:@"添加银行卡" forState:UIControlStateNormal];
        _defaultButton.backgroundColor = HEXCOLOR(@"#18D06A");
        _defaultButton.layer.cornerRadius = 5.0f;
        _defaultButton.layer.masksToBounds = YES;
        @weakify(self);
        [[_defaultButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [MobClick event:@"rp314_3"];
            BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    
    return _defaultButton;
}



@end
