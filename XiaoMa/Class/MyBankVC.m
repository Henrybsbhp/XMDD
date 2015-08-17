//
//  MyBankVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyBankVC.h"
#import "ADViewController.h"
#import "HKBankCard.h"
#import "HKConvertModel.h"
#import "CardDetailVC.h"
#import "BindBankCardVC.h"
#import "GetBankcardListOp.h"
#import "MyBankcardsModel.h"

@interface MyBankVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;
@property (nonatomic, strong) NSArray *bankCards;
@end

@implementation MyBankVC

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"rp314"];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"rp314"];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAdView];
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    @weakify(self);
    [self listenNotificationByName:kNotifyRefreshMyBankcardList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self);
        [self reloadData];
    }];
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
    GetBankcardListOp *op = [GetBankcardListOp operation];
    @weakify(self);
    [[[[op rac_postRequest] initially:^{
        
        @strongify(self);
        [self.tableView.refreshView beginRefreshing];
    }] finally:^{
      
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
    }] subscribeNext:^(GetBankcardListOp *rspOp) {
        
        @strongify(self);
        self.bankCards = rspOp.rsp_bankcards;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击“添加银行卡”
    if (indexPath.row > self.bankCards.count) {
        [MobClick event:@"rp314-3"];
        BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //点击某张银行卡
    else if (indexPath.row > 0) {
        [MobClick event:@"rp314-2"];
        CardDetailVC *vc = [UIStoryboard vcWithId:@"CardDetailVC" inStoryboard:@"Bank"];
        vc.card = [self.bankCards safetyObjectAtIndex:indexPath.row - 1];
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - Abount Cell
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
