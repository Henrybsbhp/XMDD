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
    GetUserResourcesV2Op * op = [GetUserResourcesV2Op operation];
    [[[[op rac_postRequest] initially:^{
        
        [self.tableView.refreshView beginRefreshing];
    }] finally:^{
       
        [self.tableView.refreshView endRefreshing];
    }] subscribeNext:^(GetUserResourcesV2Op * op) {
        
        gAppMgr.myUser.abcCarwashesCount = op.rsp_freewashes;
        gAppMgr.myUser.abcIntegral = op.rsp_bankIntegral;
        gAppMgr.myUser.validCZBankCreditCard = op.rsp_czBankCreditCard;
        self.bankCards = op.rsp_czBankCreditCard;
        NSArray * carwashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCarWash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        NSArray * czBankcarwashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCZBankCarWash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        NSArray * sortedCarwashfilterArray  = [carwashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.validthrough == [obj1.validthrough laterDate:obj2.validthrough];
        }];
        NSArray * sortedCZBankcarwashfilterArray  = [czBankcarwashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.validthrough == [obj1.validthrough laterDate:obj2.validthrough];
        }];
        
        NSMutableArray * carwashArray = [NSMutableArray arrayWithArray:sortedCZBankcarwashfilterArray];
        [carwashArray addObjectsFromArray:sortedCarwashfilterArray];
        gAppMgr.myUser.validCarwashCouponArray = [NSArray arrayWithArray:carwashArray];
        
        NSArray * cashfilterArray = [op.rsp_coupons arrayByFilteringOperator:^BOOL(HKCoupon * c) {
            
            if (c.conponType == CouponTypeCash)
            {
                if (c.valid)
                {
                    return YES;
                }
            }
            return NO;
        }];
        gAppMgr.myUser.validCashCouponArray = [cashfilterArray sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(HKCoupon  * obj1, HKCoupon  * obj2) {
            
            return obj1.couponAmount > obj2.couponAmount;
        }];
        
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
        [payVc requestGetUserResource];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击“添加银行卡”
    if (indexPath.row == 0) {
        
    }
    else if (indexPath.row > self.bankCards.count) {
        [MobClick event:@"rp314-3"];
        BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [MobClick event:@"rp314-4"];
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            HKBankCard * card = [self.bankCards safetyObjectAtIndex:indexPath.row - 1];
            payVc.selectBankCard = card;
            if (card.couponIds.count)
            {
                NSArray * array = [gAppMgr.myUser.validCarwashCouponArray arrayByFilteringOperator:^BOOL(HKCoupon *obj) {
                    
                    return [obj.couponId isEqualToNumber:[card.couponIds safetyObjectAtIndex:0]];
                }];
                if (array.count)
                {
                    payVc.selectCarwashCoupouArray = [NSMutableArray arrayWithObject:[array safetyObjectAtIndex:0]];
                    payVc.couponType = CouponTypeCZBankCarWash;
                }
            }
            [payVc setPlatform:PayWithXMDDCreditCard];
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
