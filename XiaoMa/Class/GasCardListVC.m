//
//  GasCardListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasCardListVC.h"
#import "GasCardStore.h"
#import "HKTableViewCell.h"
#import "GasCard.h"
#import "NSString+Split.h"

#import "GasAddCardVC.h"

@interface GasCardListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GasCardStore *cardStore;

@end

@implementation GasCardListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self setupCardStore];
    [self.cardStore sendEvent:[self.cardStore getAllCardsIfNeeded]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCardStore
{
    self.cardStore = [GasCardStore fetchOrCreateStore];
    @weakify(self);
    [self.cardStore subscribeEventsWithTarget:self receiver:^(CKStore *store, CKStoreEvent *evt) {
        @strongify(self);
        [evt callIfNeededForCode:kCKStoreEventGet object:nil target:self selector:@selector(reloadWithEvent:)];
        [evt callIfNeededForCode:kCKStoreEventAdd object:nil target:self selector:@selector(reloadWithEvent:)];
        [evt callIfNeededForCode:kCKStoreEventDelete object:nil target:self selector:@selector(deleteWithEvent:)];
        [evt callIfNeededForCode:kCKStoreEventNone object:nil target:self selector:@selector(reloadWithEvent:)];
    }];
}

#pragma mark - relaodData
- (void)deleteWithEvent:(CKStoreEvent *)evt
{
    @weakify(self);
    [[[evt signal] initially:^{
        
        @strongify(self);
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [gToast showingWithText:@"正在删除..." inView:self.view];
    }] subscribeNext:^(RACTuple *tuple) {

        @strongify(self);
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [gToast dismissInView:self.view];
        NSNumber *index = [tuple second];
        if (index) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[index integerValue] inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [gToast showError:error.domain inView:self.view];
    }];
}
- (void)reloadWithEvent:(CKStoreEvent *)evt
{
    @weakify(self);
    CKStoreEvent *event = evt;
    [[[[event signal] initially:^{
        
        @strongify(self);
        if (evt.code != kCKStoreEventNone) {
            [self.tableView.refreshView beginRefreshing];
        }
    }] finally:^{
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)reloadData
{
    [self.cardStore sendEvent:[self.cardStore getAllCards]];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击添加
    if (indexPath.row >= self.cardStore.cache.count) {
        GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //选择银行卡
    else {
        GasCard *card = [self.cardStore.cache objectAtIndex:indexPath.row];
        if (![card.gid isEqual:self.model.curGasCard.gid]) {
            CKStoreEvent *evt = [CKStoreEvent eventWithSignal:[RACSignal return:card] code:kCKStoreEventSelect object:self.model];
            [self.cardStore sendEvent:evt];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cardStore.cache.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.cardStore.cache.count) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GasCard *card = [self.cardStore.cache objectAtIndex:indexPath.row];
    [self.cardStore sendEvent:[self.cardStore deleteCardByGID:card.gid]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row >= self.cardStore.cache.count) {
        cell = [self addGasCardCellAtIndexPath:indexPath];
    }
    else {
        cell = [self gasCardCellAtIndexPath:indexPath];
    }
    if ([cell isKindOfClass:[HKTableViewCell class]]) {
        [(HKTableViewCell *)cell prepareCellForTableView:tableView atIndexPath:indexPath];
    }
    return cell;
}
                
#pragma mark - About Cell
///添加油卡
- (HKTableViewCell *)addGasCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = (HKTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"AddGasCard"
                                                                                    forIndexPath:indexPath];
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
    
    GasCard *card = [self.cardStore.cache objectAtIndex:indexPath.row];
    logoV.image = [UIImage imageNamed:card.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    titleL.text = card.cardtype == 2 ? @"中石油" : @"中石化";
    cardnoL.text = [card.gascardno splitByStep:4 replacement:@" "];

    return cell;
}


@end
