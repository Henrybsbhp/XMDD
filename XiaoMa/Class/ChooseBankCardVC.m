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
#import "GetUserResourcesV2Op.h"

@interface ChooseBankCardVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;

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
    [[[[gAppMgr.myUser.couponModel rac_getVaildResource:self.service.shopServiceType andShopId:self.shop.shopID] initially:^{
        
        [self.tableView.refreshView beginRefreshing];
    }] finally:^{
        
        [self.tableView.refreshView endRefreshing];
    }] subscribeNext:^(GetUserResourcesV2Op * op) {
        
        self.bankCards = op.rsp_czBankCreditCard;
        [self.tableView reloadData];
        
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            [payVc chooseResource];
        }
    } error:^(NSError *error) {
        
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击“添加银行卡”
    if (indexPath.row == 0) {
        
    }
    else if (indexPath.row > self.bankCards.count) {
        [MobClick event:@"rp314_3"];
        BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [MobClick event:@"rp314_4"];
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            HKBankCard * card = [self.bankCards safetyObjectAtIndex:indexPath.row - 1];
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
    if (indexPath.row == 0) {
        return 28;
    }
    else if (indexPath.row > self.bankCards.count) {
        return 114;
    }
    return 104;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bankCards.count + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [self promptCellAtIndexPath:indexPath];
    }
    else if (indexPath.row > self.bankCards.count) {
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
    
    HKBankCard *card = [self.bankCards safetyObjectAtIndex:indexPath.row-1];
    
    bgV.image = [[UIImage imageNamed:@"mb_bg_czb"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 140)];
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




@end
