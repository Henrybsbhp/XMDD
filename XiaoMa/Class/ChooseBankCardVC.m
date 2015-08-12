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
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self reloadData];
}

- (void)setupAdView
{
    CKAsyncMainQueue(^{
        self.advc  =[ADViewController vcWithADType:AdvertisementBankCardBinding boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:nil];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

- (void)reloadData
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击“添加银行卡”
    if (indexPath.row >= self.bankCards.count) {
        
    }
    else {
        NSArray * viewcontroller = self.navigationController.viewControllers;
        UIViewController * vc = [viewcontroller safetyObjectAtIndex:viewcontroller.count - 2];
        if (vc && [vc isKindOfClass:[PayForWashCarVC class]])
        {
            PayForWashCarVC * payVc = (PayForWashCarVC *)vc;
            HKBankCard * card = [self.bankCards safetyObjectAtIndex:indexPath.row];
            payVc.selectBankCard = card;
            [payVc setPlatform:PayWithXMDDCreditCard];
            [payVc tableViewReloadData];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.bankCards.count) {
        return 114;
    }
    return 104;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bankCards.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row >= self.bankCards.count) {
        cell = [self addCellAtIndexPath:indexPath];
    }
    else {
        cell = [self bankCellAtIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Abount Cell
- (UITableViewCell *)bankCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BankCell" forIndexPath:indexPath];
    UIImageView *bgV = (UIImageView *)[cell.contentView viewWithTag:1000];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *cardTypeL = (UILabel *)[cell.contentView viewWithTag:10032];
    UILabel *numberL = (UILabel *)[cell.contentView viewWithTag:1004];
    
    HKBankCard *card = [self.bankCards safetyObjectAtIndex:indexPath.row];
    
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
