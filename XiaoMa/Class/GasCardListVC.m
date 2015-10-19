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

#import "GasAddCardVC.h"

@interface GasCardListVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GasCardStore *cardStore;
@property (nonatomic, strong) NSArray *cardList;

@end

@implementation GasCardListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupCardStore
{
    self.cardStore = [GasCardStore fetchOrCreateStore];
    [self.cardStore subscribeEventsWithTarget:self receiver:^(CKStore *store, CKStoreEvent *evt) {
    }];
}

- (void)reloadData
{
    [self.cardStore sendEvent:[self.cardStore getAllCardBaseInfos]];
    GasCard *card = [[GasCard alloc] init];
    card.gascardno = @"123456789012345";
    card.cardtype = 2;
    self.cardList = @[card];
    [self.tableView reloadData];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击添加
    if (indexPath.row >= self.cardList.count) {
        GasAddCardVC *vc = [UIStoryboard vcWithId:@"GasAddCardVC" inStoryboard:@"Gas"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //选择银行卡
    else {
        self.model.curGasCard = [self.cardList safetyObjectAtIndex:indexPath.row];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cardList.count + 1;
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
    if (indexPath.row >= self.cardList.count) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GasCard *card = [self.cardList safetyObjectAtIndex:indexPath.row];
    [self.cardStore sendEvent:[self.cardStore deleteCardByGID:card.gid]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row >= self.cardList.count) {
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
    
    GasCard *card = [self.cardList safetyObjectAtIndex:indexPath.row];
    logoV.image = [UIImage imageNamed:card.cardtype == 1 ? @"gas_icon_cnpc" : @"gas_icon_snpn"];
    titleL.text = card.cardtype == 1 ? @"中石油" : @"中石化";
    cardnoL.text = [card prettyCardNumber];

    return cell;
}


@end
