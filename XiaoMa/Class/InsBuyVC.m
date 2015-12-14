//
//  InsBuyVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsBuyVC.h"
#import "CKLine.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"

#import "InsPayResultVC.h"

@interface InsBuyVC ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsBuyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupHeaderView];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupHeaderView
{
    UILabel *titleL = [self.headerView viewWithTag:1001];
    CKLine *line = [self.headerView viewWithTag:1002];
    line.lineAlignment = CKLineAlignmentHorizontalBottom;
}

#pragma Datasource
- (void)reloadData
{
    NSMutableArray *datasource = [NSMutableArray array];
    HKCellData *infoCell = [HKCellData dataWithCellID:@"Info" tag:nil];
    [infoCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 260;
    }];
    [datasource addObject:[NSArray arrayWithObject:infoCell]];

    HKCellData *sectionCell = [HKCellData dataWithCellID:@"Section" tag:nil];
    [sectionCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 33;
    }];
    HKCellData *coverageCell = [HKCellData dataWithCellID:@"Coverage" tag:nil];
    [datasource addObject:[NSArray arrayWithObjects:sectionCell, coverageCell, nil]];
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionBuy:(id)sender
{
    InsPayResultVC *vc = [UIStoryboard vcWithId:@"InsPayResultVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource safetyObjectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [[self.datasource safetyObjectAtIndex:indexPath.section] safetyObjectAtIndex:indexPath.row];
    JTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Info" tag:nil]) {
        [self resetBaseInfoCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Coverage" tag:nil]){
        [self resetCoverageCell:cell forData:data];
    }
    cell.customSeparatorInset = UIEdgeInsetsZero;
    [cell prepareCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (void)resetBaseInfoCell:(JTTableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    HKSubscriptInputField *nameF = [cell viewWithTag:1004];
    HKSubscriptInputField *dateF = [cell viewWithTag:1005];
    HKSubscriptInputField *idF = [cell viewWithTag:1006];
}

- (void)resetCoverageCell:(JTTableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *titleL = [cell viewWithTag:1001];
    UILabel *detailL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    CKLine *vline = [cell viewWithTag:1004];
    
    vline.lineAlignment = CKLineAlignmentVerticalRight;
}


@end
