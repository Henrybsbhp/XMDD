//
//  InsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceVC.h"
#import "XiaoMa.h"
#import "ADViewController.h"
#import "HKCellData.h"
#import "NSString+RectSize.h"
#import <MZFormSheetController.h>

#import "InsInputNameVC.h"
#import "InsInputInfoVC.h"


@interface InsuranceVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation InsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupADView];
    [self reloadDataWithCarList:@[@1]];
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp114"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp114"];
}

- (void)setupADView
{
    CKAsyncMainQueue(^{
        self.advc = [ADViewController vcWithADType:AdvertisementInsurance boundsWidth:self.view.frame.size.width
                                          targetVC:self mobBaseEvent:@"rp114-3"];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

#pragma mark - Action
- (void)reloadDataWithCarList:(NSArray *)carlist
{
    NSMutableArray *datasource = [NSMutableArray array];
    //标题
    HKCellData *promptCell = [HKCellData dataWithCellID:@"Prompt" tag:nil];
    NSString *title = @"请选择或添加一辆爱车，保险到期日前60天内，可进行核保。";
    promptCell.object = title;
    @weakify(self);
    [promptCell setHeightBlock:^CGFloat(UITableView *tableView) {
        @strongify(self);
        CGSize fz = [title labelSizeWithWidth:self.tableView.frame.size.width - 28 font:[UIFont systemFontOfSize:13]];
        return ceil(fz.height) + 10;
    }];
    [datasource addObject:promptCell];
    //车牌
    NSArray *carCells = [carlist arrayByMappingOperator:^id(id obj) {
        HKCellData *cell = [HKCellData dataWithCellID:@"Car" tag:nil];
        return cell;
    }];
    [datasource safetyAddObjectsFromArray:carCells];
    //添加车辆
    HKCellData *addCell = [HKCellData dataWithCellID:@"Add" tag:nil];
    addCell.customInfo[@"prefix"] = @"浙";
    addCell.customInfo[@"suffix"] = @"AK477";
    [addCell setHeightBlock:^CGFloat(UITableView *tableView) {
        return 61;
    }];
    [datasource addObject:addCell];
    
    self.datasource = datasource;
    [self.tableView reloadData];
}

- (IBAction)actionInputOwnerName:(id)sender
{
    InsInputNameVC *vc = [UIStoryboard vcWithId:@"InsInputNameVC" inStoryboard:@"Insurance"];
    MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(270, 160) viewController:vc];
    sheet.shouldCenterVertically = YES;
    [sheet presentAnimated:YES completionHandler:nil];
    //取消
    [[[vc.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] take:1] subscribeNext:^(id x) {
        [sheet dismissAnimated:YES completionHandler:nil];
    }];
    //确定
    @weakify(self);
    [[vc.ensureButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [sheet dismissAnimated:YES completionHandler:nil];
        InsInputInfoVC *vc = [UIStoryboard vcWithId:@"InsInputInfoVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.section];
    if (data.heightBlock) {
        return data.heightBlock(tableView);
    }
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCellData *data = [self.datasource safetyObjectAtIndex:indexPath.section];
    JTTableViewCell *cell = (JTTableViewCell *)[tableView dequeueReusableCellWithIdentifier:data.cellID forIndexPath:indexPath];
    if ([data equalByCellID:@"Prompt" tag:nil]) {
        [self resetPromptCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Car" tag:nil]) {
        [self resetCarCell:cell withData:data];
    }
    else if ([data equalByCellID:@"Add" tag:nil]) {
        [self resetAddCarCell:cell withData:data];
    }

    [cell prepareCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

#pragma mark - Cell
- (void)resetPromptCell:(JTTableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *label = [cell.contentView viewWithTag:1001];
    label.text = data.object;

}

- (void)resetCarCell:(JTTableViewCell *)cell withData:(HKCellData *)data
{
    UILabel *numberL = [cell viewWithTag:1002];
    UIButton *stateB = [cell viewWithTag:1003];
    UIImageView *arrowV = [cell viewWithTag:1004];
}

- (void)resetAddCarCell:(JTTableViewCell *)cell withData:(HKCellData *)data
{
    
}
@end
