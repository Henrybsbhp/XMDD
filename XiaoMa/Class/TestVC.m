//
//  TestVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "TestVC.h"
#import "HKLoadingModel.h"
#import "HKFoldingTableView.h"

@interface TestVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) IBOutlet HKFoldingTableView *tableView;
@property (nonatomic, strong) HKLoadingModel *loadingModel;
@end

@implementation TestVC

- (void)viewDidLoad {
    self.tableView.minFoldingHeight = 70;
    self.tableView.maxFoldingHeight = 160;
    [super viewDidLoad];
    CKAsyncMainQueue(^{
        [self.tableView setFolded:NO animated:NO];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)actionRefresh:(id)sender
{
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 30;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", (int)indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tableView didUpdateScrollContentOffset:scrollView.contentOffset];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tableView.isDragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.tableView.isDecelerating = NO;
    [self.tableView checkFoldedIfNeededWithAnimated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.tableView.isDragging = NO;
    self.tableView.isDecelerating = decelerate;
    [self.tableView checkFoldedIfNeededWithAnimated:YES];
}

@end
