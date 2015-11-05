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
#import "BankCardStore.h"

@interface MyBankVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;
@property (nonatomic, strong) NSArray *bankCards;
@property (nonatomic, strong) BankCardStore *bankStore;
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
    [self setupBankStore];
    [self.bankStore sendEvent:[self.bankStore getAllBankCards]];
}

- (void)setupAdView
{
    CKAsyncMainQueue(^{
        self.advc  =[ADViewController vcWithADType:AdvertisementBankCardBinding boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:@"rp314-1"];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

- (void)setupBankStore
{
    self.bankStore = [BankCardStore fetchOrCreateStore];
    @weakify(self);
    [self.bankStore subscribeEventsWithTarget:self receiver:^(CKStore *store, CKStoreEvent *evt) {
        @strongify(self);
        NSArray *codes = @[@(kCKStoreEventAdd),@(kCKStoreEventDelete),@(kCKStoreEventReload),@(kCKStoreEventNone),@(kCKStoreEventGet)];
        [evt callIfNeededForCodeList:codes object:nil target:self selector:@selector(reloadWithEvent:)];
    }];
}

- (void)reloadData
{
    [self.bankStore sendEvent:[self.bankStore getAllBankCards]];
}

- (void)reloadWithEvent:(CKStoreEvent *)event
{
    NSInteger code = event.code;
    @weakify(self);
    [[[[event signal] initially:^{

        @strongify(self);
        if (code != kCKStoreEventNone) {
            [self.tableView.refreshView beginRefreshing];
        }
    }] finally:^{
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.bankCards = [self.bankStore.cache allObjects];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];;
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
        HKBankCard *card = [self.bankCards safetyObjectAtIndex:indexPath.row - 1];
        if (self.selectedCardReveicer) {
            CKStoreEvent *evt = [CKStoreEvent eventWithSignal:[RACSignal return:card] code:kCKStoreEventSelect
                                                       object:self.selectedCardReveicer];
            [self.bankStore sendEvent:evt];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        CardDetailVC *vc = [UIStoryboard vcWithId:@"CardDetailVC" inStoryboard:@"Bank"];
        vc.card = card;
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
