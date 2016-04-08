//
//  GasCardListVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasCardListVC.h"
#import "GasStore.h"
#import "HKTableViewCell.h"
#import "GasCard.h"
#import "NSString+Split.h"

#import "GasAddCardVC.h"

@interface GasCardListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GasStore *gasStore;

@end

@implementation GasCardListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupGasStore];
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self reloadDataIfNeeded];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.tableView setEditing:NO];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"GasCardListVC dealloc ~");
}

- (void)setupGasStore
{
    self.gasStore = [GasStore fetchOrCreateStore];
    @weakify(self);
    [self.gasStore subscribeWithTarget:self domain:kDomainGasCards receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        if (evt.object && [self isEqual:evt.object]) {
            return ;
        }
        [self reloadWithSignal:evt.signal];
    }];
}

#pragma mark - relaodData
- (void)deleteWithSignal:(RACSignal *)signal
{
    [MobClick event:@"rp505_2"];
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [gToast showingWithText:@"正在删除..." inView:self.view];
    }] subscribeNext:^(RACTuple *tuple) {

        @strongify(self);
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [gToast dismissInView:self.view];
        if (tuple) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[tuple.second integerValue] inSection:0];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self resetSelectedGasCardIDIfNeeded];
    } error:^(NSError *error) {
        
        @strongify(self);
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [gToast showError:error.domain inView:self.view];
    }];
}
- (void)reloadWithSignal:(RACSignal *)signal
{
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        [self.tableView.refreshView beginRefreshing];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self resetSelectedGasCardIDIfNeeded];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        [self.tableView.refreshView endRefreshing];
    }];
}

- (void)reloadDataIfNeeded
{
    RACSignal *signal = [[[self.gasStore getAllGasCardsIfNeeded] setObject:self] sendWithIgnoreError:YES andDelay:0.4];
    [self reloadWithSignal:signal];
}

- (void)reloadData
{
    RACSignal *signal = [[[self.gasStore getAllGasCards] setObject:self] sendWithIgnoreError:YES andDelay:0.4];
    [self reloadWithSignal:signal];
}

#pragma mark - Util
- (void)resetSelectedGasCardIDIfNeeded {
    if ([self.gasStore.gasCards count] == 0 ||
        (self.selectedGasCardID && [self.gasStore.gasCards objectForKey:self.selectedGasCardID])) {
        return;
    }
    self.selectedGasCardID = [self.gasStore.gasCards keyForObjectAtIndex:0];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击添加
    if (indexPath.row >= self.gasStore.gasCards.count) {
        [MobClick event:@"rp505_4"];
        GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //选择银行卡
    else {
        [MobClick event:@"rp505_3"];
        GasCard *card = [self.gasStore.gasCards objectAtIndex:indexPath.row];
        if (card && self.selectedBlock) {
            self.selectedBlock(card);
        }
        self.selectedGasCardID = card.gid;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gasStore.gasCards.count + 1;
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
    if (indexPath.row >= self.gasStore.gasCards.count) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GasCard *card = [self.gasStore.gasCards objectAtIndex:indexPath.row];
    RACSignal *signal = [[[self.gasStore deleteGasCard:card] setObject:self] sendAndIgnoreError];
    [self deleteWithSignal:signal];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row >= self.gasStore.gasCards.count) {
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
    UIImageView *checkboxV = [cell viewWithTag:1004];
    
    GasCard *card = [self.gasStore.gasCards objectAtIndex:indexPath.row];
    logoV.image = [UIImage imageNamed:card.cardtype == 2 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    titleL.text = card.cardtype == 2 ? @"中石油" : @"中石化";
    cardnoL.text = [card.gascardno splitByStep:4 replacement:@" "];
    
    [[RACObserve(self, selectedGasCardID) takeUntilForCell:cell] subscribeNext:^(id x) {
        checkboxV.hidden = ![card.gid isEqual:x];
    }];
    
    cell.customSeparatorInset = UIEdgeInsetsZero;
    return cell;
}


@end
