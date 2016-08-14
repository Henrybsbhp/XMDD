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
