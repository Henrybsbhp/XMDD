//
//  InsSubmitResultVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsSubmitResultVC.h"
#import "HKCellData.h"
#import "CKLine.h"
#import "InsCouponView.h"

@interface InsSubmitResultVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsSubmitResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Datasource
- (void)reloadData {
    HKCellData *headerCell = [HKCellData dataWithCellID:@"Header" tag:nil];
    [headerCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 66;
    }];
    HKCellData *titleCell = [HKCellData dataWithCellID:@"Title" tag:nil];
    [titleCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 35;
    }];
    HKCellData *couponsCell = [HKCellData dataWithCellID:@"Coupon" tag:nil];
    couponsCell.object = @[@"全年免费洗车",@"快速理赔",@"免费道路救援"];
    @weakify(couponsCell);
    [couponsCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(couponsCell);
        return [InsCouponView heightWithCouponCount:[couponsCell.object count] buttonHeight:30];
    }];
    
    self.datasource = @[headerCell, titleCell, couponsCell];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionOrder:(id)sender {
}

- (IBAction)actionShare:(id)sender {
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Coupon" tag:nil]) {
        [self setupCouponCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Title" tag:nil]) {
        [self setupTitleCell:cell forData:nil];
    }
    return cell;
}

- (void)setupTitleCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    CKLine *line1 = [cell viewWithTag:1001];
    CKLine *line2 = [cell viewWithTag:1003];
    
    line1.lineColor = HEXCOLOR(@"#20ab2a");
    line2.lineColor = HEXCOLOR(@"#20ab2a");
}

- (void)setupCouponCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    InsCouponView *couponV = [cell viewWithTag:1001];
    
    couponV.buttonHeight = 30;
    couponV.buttonTitleColor = HEXCOLOR(@"#20ab2a");
    couponV.buttonBorderColor = HEXCOLOR(@"#20ab2a");
    couponV.coupons = data.object;
}

@end
