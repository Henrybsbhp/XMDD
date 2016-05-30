//
//  MutualInsAskForCompensationVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 5/27/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsAskForCompensationVC.h"
#import "HKProgressView.h"

@interface MutualInsAskForCompensationVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CKList *dataSource;

@end

@implementation MutualInsAskForCompensationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDataSource
{
    CKDict *progressCell = [CKDict dictWith:@{kCKItemKey: @"progressCell", kCKCellID: @"ProgressCell"}];
    progressCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    progressCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        HKProgressView *progressView = (HKProgressView *)[cell.contentView viewWithTag:100];
        progressView.normalColor = kBackgroundColor;
        progressView.normalTextColor = kLightTextColor;
        progressView.titleArray = @[@"补偿定价", @"补偿确认", @"补偿结束"];
        progressView.selectedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
        
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.layer.borderWidth = 0.5;
        UIView *bottomBorderView;
        bottomBorderView.backgroundColor = [UIColor whiteColor];
        bottomBorderView.frame = CGRectMake(0, cell.bounds.size.height, cell.frame.size.width, 0.5);
        
        [cell.contentView addSubview:bottomBorderView];
        cell.layer.masksToBounds = YES;
    });
    
    
    CKDict *statusCell = [CKDict dictWith:@{kCKItemKey: @"statusCell", kCKCellID: @"StatusCell"}];
    statusCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 34;
    });
    statusCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *carNumberLabel = (UILabel *)[cell.contentView viewWithTag:100];
        UIImageView *statusImageView = (UIImageView *)[cell.contentView viewWithTag:101];
    });
    
    self.dataSource = $($(progressCell, statusCell));
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (section == 0) {
//        return 5;
//    } else if (section == 1) {
//        return 5;
//    } else if (section == 2) {
//        return 4;
//    } else if (section == 3) {
//        return 5;
//    } else if (section == 4) {
//        return 4;
//    } else if (section == 5) {
//        return 4;
//    } else if (section == 6) {
//        return 4;
//    } else {
//        return 4;
//    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

@end
