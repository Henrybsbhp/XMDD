//
//  TempTableVC.m
//  XMDD
//
//  Created by St.Jimmy on 8/3/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "TempTableVC.h"

@interface TempTableVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKList *dataSource;

@end

@implementation TempTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataSource
{
    CKDict *gasCell = [CKDict dictWith:@{kCKItemKey: @"mutualCompletedCell", kCKCellID: @"MutualCompletedCell"}];
    gasCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 330;
    });
    
    gasCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel *statusLabel = (UILabel *)[cell.contentView viewWithTag:1002];
        UIImageView *brandImageView = (UIImageView *)[cell.contentView viewWithTag:2001];
        UILabel *carNumLabel = (UILabel *)[cell.contentView viewWithTag:2002];
        UILabel *mutualPriceLabel = (UILabel *)[cell.contentView viewWithTag:3002];
        UILabel *mutualTimeLabel = (UILabel *)[cell.contentView viewWithTag:2003];
        UILabel *mutualDescLabel = (UILabel *)[cell.contentView viewWithTag:3003];
        UILabel *startTimeLabel = (UILabel *)[cell.contentView viewWithTag:4001];
        UILabel *endTimeLabel = (UILabel *)[cell.contentView viewWithTag:4002];
        UILabel *servicePriceLabel = (UILabel *)[cell.contentView viewWithTag:5001];
        UILabel *serviceDescLabel = (UILabel *)[cell.contentView viewWithTag:5002];
        UILabel *sumLabel = (UILabel *)[cell.contentView viewWithTag:6001];
        
        titleLabel.text = @"小马互助";
        statusLabel.text = @"等待支付";
        carNumLabel.text = @"浙A2394B";
        mutualPriceLabel.text = @"￥1521.32";
        mutualTimeLabel.text = @"2015.01.01 09:00";
        mutualDescLabel.text = @"互助金";
        startTimeLabel.text = @"保障开始：2016.07.08 00:00";
        endTimeLabel.text = @"保障结束：2017.07.08 00:00";
        servicePriceLabel.text = @"￥900.00";
        serviceDescLabel.text = @"服务费";
        sumLabel.text = @"支付金额：￥2421.32";
        
        UILabel *brandeImageView2 = (UIImageView *)[cell.contentView viewWithTag:7001];
        UILabel *insuranceLabel = (UILabel *)[cell.contentView viewWithTag:7002];
        UILabel *insuranceTimeLabel = (UILabel *)[cell.contentView viewWithTag:7003];
        UILabel *insPricelabel1 = (UILabel *)[cell.contentView viewWithTag:7004];
        UILabel *insPriceLabel2 = (UILabel *)[cell.contentView viewWithTag:7007];
        UILabel *insPriceDescLabel1 = (UILabel *)[cell.contentView viewWithTag:7005];
        UILabel *insPriceDescLabel2 = (UILabel *)[cell.contentView viewWithTag:7009];
        UILabel *insStartTimeLabel = (UILabel *)[cell.contentView viewWithTag:7006];
        UILabel *insEndTimeLabel = (UILabel *)[cell.contentView viewWithTag:7008];
        insuranceLabel.text = @"交强险车船税代买";
        insuranceTimeLabel.text = @"2015.01.01 09:00";
        insPricelabel1.text = @"￥900.00";
        insPriceDescLabel1.text = @"交强险";
        insStartTimeLabel.text = @"保障开始：2016.07.08 00:00";
        insEndTimeLabel.text = @"保障结束：2017.07.08 00:00";
        insPriceLabel2.text = @"￥900.00";
        insPriceDescLabel2.text = @"车船税";
    });
    
    self.dataSource = $(gasCell);
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 330;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section];
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}



@end
