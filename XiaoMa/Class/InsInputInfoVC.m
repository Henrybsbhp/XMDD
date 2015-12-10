//
//  InsInputInfoVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsInputInfoVC.h"
#import "HKCellData.h"
#import "HKSubscriptInputField.h"
#import "InsCheckResultsVC.h"

@interface InsInputInfoVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasource;
@end

@implementation InsInputInfoVC

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
    NSMutableArray *datasource = [NSMutableArray array];
    //车牌
    HKCellData *numberCell = [HKCellData dataWithCellID:@"Number" tag:nil];
    numberCell.object = @"浙A242FJ";
    [numberCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 48;
    }];
    [datasource addObject:numberCell];
    
    //行使城市/注册日期
    HKCellData *doubleCell = [HKCellData dataWithCellID:@"Double" tag:nil];
    doubleCell.customInfo[@"city"] = @"杭州";
    doubleCell.customInfo[@"date"] = @"2012-11-27";
    [datasource addObject:doubleCell];
    
    //车架号
    HKCellData *normalCell1 = [HKCellData dataWithCellID:@"Normal" tag:nil];
    normalCell1.customInfo[@"title"] = @"车架号码";
    normalCell1.customInfo[@"subTitle"] = @" (车辆识别代号)";
    normalCell1.object = @"LSVFF66R8C2342058";
    [datasource addObject:normalCell1];
    
    //车辆型号
    HKCellData *normalCell2 = [HKCellData dataWithCellID:@"Normal" tag:nil];
    normalCell2.customInfo[@"title"] = @"车辆型号";
    normalCell2.customInfo[@"subTitle"] = @" (品牌型号非中文部分)";
    normalCell2.object = @"SVW71623HK";
    [datasource addObject:normalCell2];
    
    //发动机号
    HKCellData *normalCell3 = [HKCellData dataWithCellID:@"Normal" tag:nil];
    normalCell3.customInfo[@"title"] = @"发动机号";
    normalCell3.object = @"149S7FI9";
    [datasource addObject:normalCell3];

    //过户车辆
    HKCellData *switchCell = [HKCellData dataWithCellID:@"Switch" tag:nil];
    switchCell.object = @NO;
    [switchCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 50;
    }];
    [datasource addObject:switchCell];
    
    //过户日期
    HKCellData *dateCell = [HKCellData dataWithCellID:@"Date" tag:nil];
    dateCell.object = @"2012-11-27";
    [dateCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 44;
    }];
    [datasource addObject:dateCell];
    //达达帮忙
    HKCellData *helpCell = [HKCellData dataWithCellID:@"Help" tag:nil];
    [helpCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 57;
    }];
    [helpCell setSelectedBlock:^(UITableView *tableView, NSIndexPath *indexPath) {
    }];
    [datasource addObject:helpCell];
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    InsCheckResultsVC *vc = [UIStoryboard vcWithId:@"InsCheckResultsVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
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
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Number" tag:nil]) {
        [self resetLicenseNumberCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Double" tag:nil]) {
        [self resetDoubleItemCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Normal" tag:nil]) {
        [self resetNormalCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Switch" tag:nil]) {
        [self resetSwitchCell:cell forData:data];
    }
    else if ([data equalByCellID:@"Date" tag:nil]) {
        [self resetDateCell:cell forData:data];
    }

    return cell;
}

#pragma mark - Cell
- (void)resetLicenseNumberCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *label = [cell viewWithTag:1001];
    label.text = data.object;
}

- (void)resetDoubleItemCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    HKSubscriptInputField *cityInput = [cell viewWithTag:10012];
    HKSubscriptInputField *dateInput = [cell viewWithTag:10022];
    cityInput.inputField.text = data.customInfo[@"city"];
    dateInput.inputField.text = data.customInfo[@"date"];
}

- (void)resetNormalCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    UILabel *titleL = [cell viewWithTag:10011];
    UIButton *helpB = [cell viewWithTag:10012];
    HKSubscriptInputField *inputF = [cell viewWithTag:10013];
    
    //标题
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedString];
    NSAttributedString *titleStr = [[NSAttributedString alloc] initWithString:data.customInfo[@"title"] attributes:
                                    @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                      NSForegroundColorAttributeName: HEXCOLOR(@"#20ab2a")}];
    [attrStr appendAttributedString:titleStr];
    NSString *subTitle = data.customInfo[@"subTitle"];
    if (subTitle) {
        NSAttributedString *subTitleStr = [[NSAttributedString alloc] initWithString:subTitle attributes:
                                           @{NSFontAttributeName: [UIFont systemFontOfSize:13],
                                             NSForegroundColorAttributeName: HEXCOLOR(@"#888888")}];
        [attrStr appendAttributedString:subTitleStr];
    }
    titleL.attributedText = attrStr;
    
    //输入框
    
    //显示帮助
    [[[helpB rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
    }];
}

- (void)resetSwitchCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
}

- (void)resetDateCell:(UITableViewCell *)cell forData:(HKCellData *)data
{
    
}

@end
