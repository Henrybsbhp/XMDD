//
//  InsPayFaildVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "InsPayFaildVC.h"
#import "HKCellData.h"
#import "NSString+Format.h"

@interface InsPayFaildVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsPayFaildVC

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
- (void)reloadData
{
    HKCellData *headerCell = [HKCellData dataWithCellID:@"Header" tag:nil];
    [headerCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 66;
    }];
    HKCellData *baseCell = [HKCellData dataWithCellID:@"Base" tag:nil];
    [baseCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 115;
    }];
    
    self.datasource = @[headerCell, baseCell];
    [self.tableView reloadData];
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
    if ([data equalByCellID:@"Base" tag:nil]) {
        [self resetBaseCell:cell forData:data];
    }

    return cell;
}

- (void)resetBaseCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *titleL = [cell viewWithTag:1002];
    UILabel *priceL = [cell viewWithTag:1003];
    UILabel *numberL = [cell viewWithTag:1004];
    
    [logoV setImageByUrl:self.insOrder.picUrl withType:ImageURLTypeOrigin defImage:@"ins_comp_def" errorImage:@"ins_comp_def"];
    titleL.text = self.insOrder.inscomp;
    priceL.text = [NSString formatForRoundPrice2:self.insOrder.fee];
    numberL.text = self.insOrder.licencenumber;
}

@end
