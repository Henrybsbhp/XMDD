//
//  JTTableViewController.m
//  EasyPay
//
//  Created by jiangjunchen on 14-10-16.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTTableViewController.h"
#import "CKKit.h"

@interface JTTableViewController ()
@end

@implementation JTTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 44;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        return UITableViewAutomaticDimension;
    }
    
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height+1);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
    
}


@end
