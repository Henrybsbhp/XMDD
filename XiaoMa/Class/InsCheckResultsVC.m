//
//  InsCheckResultsVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsCheckResultsVC.h"
#import "HKCellData.h"
#import "CKLine.h"
#import "InsCouponView.h"

#import "InsCheckResultsVC.h"
#import "InsBuyVC.h"

@interface InsCheckResultsVC ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSMutableArray *datasource;

@end

@implementation InsCheckResultsVC

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
    HKCellData *cell1 = [HKCellData dataWithCellID:@"Uppon" tag:nil];
    HKCellData *cell2 = [HKCellData dataWithCellID:@"Down" tag:nil];
    cell2.object = @[@"85折优惠",@"全年免费洗车",@"快速理赔"];
    @weakify(cell2);
    [cell2 setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(cell2);
        return [InsCouponView heightWithCouponCount:[cell2.object count] buttonHeight:25]+10;
    }];
    [datasource addObject:[NSMutableArray arrayWithObjects:cell1,cell2, nil]];
    
    self.datasource = datasource;
    
    [self.tableView reloadData];
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
    return 137;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Uppon" tag:nil]) {
        [self resetUpponCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Down" tag:nil]){
        [self resetDownCell:cell forData:data];
    }
    return cell;
}

- (void)resetUpponCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    CKLine *line1 = [cell viewWithTag:10001];
    CKLine *line2 = [cell viewWithTag:10002];
    CKLine *line3 = [cell viewWithTag:10003];
    CKLine *line4 = [cell viewWithTag:10004];
    CKLine *line5 = [cell viewWithTag:10005];
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    UIButton *buyB = [cell viewWithTag:1004];
    
    line1.lineAlignment = CKLineAlignmentHorizontalTop;
    line2.lineAlignment = CKLineAlignmentVerticalLeft;
    line3.lineAlignment = CKLineAlignmentVerticalRight;
    line4.lineAlignment = CKLineAlignmentHorizontalBottom;
    line5.lineAlignment = CKLineAlignmentHorizontalBottom;
    line5.lineOptions = CKLineOptionDash;
    line5.dashLengths = @[@3, @2];

    @weakify(self);
    [[[buyB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        InsBuyVC *vc = [UIStoryboard vcWithId:@"InsBuyVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)resetDownCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    CKLine *line1 = [cell viewWithTag:10001];
    CKLine *line2 = [cell viewWithTag:10002];
    CKLine *line3 = [cell viewWithTag:10003];
    InsCouponView *couponV = [cell viewWithTag:1001];

    line1.lineAlignment = CKLineAlignmentVerticalLeft;
    line2.lineAlignment = CKLineAlignmentVerticalRight;
    line3.lineAlignment = CKLineAlignmentHorizontalBottom;
    couponV.buttonHeight = 25;
    couponV.coupons = data.object;
}

@end
