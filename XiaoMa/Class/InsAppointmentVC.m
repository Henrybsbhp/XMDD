//
//  InsAppointmentVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/11.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsAppointmentVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "InsCouponView.h"

@interface InsAppointmentVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsAppointmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Datasource
- (void)reloadData
{
    HKCellData *infoCell = [HKCellData dataWithCellID:@"Info" tag:nil];
    [infoCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 250;
    }];
    HKCellData *sectionCell = [HKCellData dataWithCellID:@"Title" tag:nil];
    [sectionCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 35;
    }];
    HKCellData *couponsCell = [HKCellData dataWithCellID:@"Coupon" tag:nil];
    couponsCell.object = @[@"全年免费洗车",@"快速理赔",@"免费道路救援"];
    @weakify(couponsCell);
    [couponsCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(couponsCell);
        return [InsCouponView heightWithCouponCount:[couponsCell.object count] buttonHeight:30];
    }];
    self.datasource = @[infoCell, sectionCell, couponsCell];
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionAppoint:(id)sender
{
    
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource objectAtIndex:indexPath.row];
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
    if ([data equalByCellID:@"Info" tag:nil]) {
        [self resetBaseInfoCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Coupon" tag:nil]){
        [self resetCouponCell:cell forData:data];
    }
    return cell;
}

- (void)resetBaseInfoCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    HKSubscriptInputField *nameF = [cell viewWithTag:1004];
    HKSubscriptInputField *dateF = [cell viewWithTag:1005];
    HKSubscriptInputField *idF = [cell viewWithTag:1006];
}

- (void)resetCouponCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    InsCouponView *couponV = [cell viewWithTag:1001];
    
    couponV.buttonHeight = 30;
    couponV.buttonTitleColor = HEXCOLOR(@"#20ab2a");
    couponV.buttonBorderColor = HEXCOLOR(@"#20ab2a");
    couponV.coupons = data.object;
}

@end
